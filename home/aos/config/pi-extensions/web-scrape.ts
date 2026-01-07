/**
 * Web Scrape Extension for pi
 *
 * Provides a fetch_url tool that fetches webpage content for the LLM to read.
 * Pure Node.js implementation - no external dependencies (curl, perl, etc.)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";

const MAX_FILE_SIZE = 5_000_000; // 5MB
const FETCH_TIMEOUT = 30_000; // 30 seconds
const MAX_OUTPUT_LENGTH = 100_000; // 100KB

/**
 * Strip HTML tags and extract readable text content
 */
function extractTextFromHtml(html: string): string {
  let text = html;

  // Remove script, style, head, nav, footer blocks entirely
  text = text.replace(/<script[^>]*>[\s\S]*?<\/script>/gi, " ");
  text = text.replace(/<style[^>]*>[\s\S]*?<\/style>/gi, " ");
  text = text.replace(/<head[^>]*>[\s\S]*?<\/head>/gi, " ");
  text = text.replace(/<nav[^>]*>[\s\S]*?<\/nav>/gi, " ");
  text = text.replace(/<footer[^>]*>[\s\S]*?<\/footer>/gi, " ");

  // Remove all remaining HTML tags
  text = text.replace(/<[^>]+>/g, " ");

  // Decode common HTML entities
  text = text.replace(/&nbsp;/gi, " ");
  text = text.replace(/&amp;/gi, "&");
  text = text.replace(/&lt;/gi, "<");
  text = text.replace(/&gt;/gi, ">");
  text = text.replace(/&quot;/gi, '"');
  text = text.replace(/&#39;/gi, "'");
  text = text.replace(/&#x27;/gi, "'");
  text = text.replace(/&#(\d+);/gi, (_, code) => String.fromCharCode(parseInt(code, 10)));
  text = text.replace(/&#x([0-9a-f]+);/gi, (_, code) => String.fromCharCode(parseInt(code, 16)));

  // Normalize whitespace
  text = text.replace(/\s+/g, " ");
  text = text.trim();

  return text;
}

/**
 * Check if content appears to be HTML
 */
function isHtml(content: string): boolean {
  const start = content.slice(0, 1000).toLowerCase();
  return start.includes("<!doctype") || start.includes("<html") || start.includes("<head");
}

export default function webScrapeExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "fetch_url",
    label: "Fetch URL",
    description:
      "Fetch the contents of a URL. Use this to retrieve and read webpage content when given a link.",
    parameters: Type.Object({
      url: Type.String({ description: "The URL to fetch" }),
    }),

    async execute(_toolCallId, params, _onUpdate, _ctx, signal) {
      const { url } = params as { url: string };

      // Validate URL
      try {
        new URL(url);
      } catch {
        return {
          content: [{ type: "text", text: `Invalid URL: ${url}` }],
          isError: true,
        };
      }

      try {
        // Create timeout abort controller
        const timeoutController = new AbortController();
        const timeout = setTimeout(() => timeoutController.abort(), FETCH_TIMEOUT);

        // Combine with external signal if provided
        const abortHandler = () => timeoutController.abort();
        signal?.addEventListener("abort", abortHandler);

        try {
          const response = await fetch(url, {
            signal: timeoutController.signal,
            headers: {
              "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
              "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            },
            redirect: "follow",
          });

          if (!response.ok) {
            return {
              content: [{ type: "text", text: `HTTP error: ${response.status} ${response.statusText}` }],
              isError: true,
            };
          }

          // Read body with size limit
          const reader = response.body?.getReader();
          if (!reader) {
            return {
              content: [{ type: "text", text: "Failed to read response body" }],
              isError: true,
            };
          }

          const chunks: Uint8Array[] = [];
          let totalSize = 0;

          while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            totalSize += value.length;
            if (totalSize > MAX_FILE_SIZE) {
              reader.cancel();
              return {
                content: [{ type: "text", text: `File too large: exceeded ${MAX_FILE_SIZE / 1_000_000}MB limit` }],
                isError: true,
              };
            }
            chunks.push(value);
          }

          // Combine chunks and decode
          const combined = new Uint8Array(totalSize);
          let offset = 0;
          for (const chunk of chunks) {
            combined.set(chunk, offset);
            offset += chunk.length;
          }

          let content = new TextDecoder("utf-8", { fatal: false }).decode(combined);

          // Extract text from HTML if needed
          if (isHtml(content)) {
            content = extractTextFromHtml(content);
          }

          // Truncate if needed
          let truncated = false;
          if (content.length > MAX_OUTPUT_LENGTH) {
            content = content.substring(0, MAX_OUTPUT_LENGTH);
            truncated = true;
          }

          // Format for LLM consumption
          let output = `<webpage url="${url}">\n`;
          output += content.trim();
          if (truncated) {
            output += "\n[TRUNCATED - content exceeded 100KB]";
          }
          output += "\n</webpage>";

          return {
            content: [{ type: "text", text: output }],
          };
        } finally {
          clearTimeout(timeout);
          signal?.removeEventListener("abort", abortHandler);
        }
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        if (errorMessage.includes("abort")) {
          return {
            content: [{ type: "text", text: "Request timed out or was cancelled" }],
            isError: true,
          };
        }
        return {
          content: [{ type: "text", text: `Fetch error: ${errorMessage}` }],
          isError: true,
        };
      }
    },
  });
}
