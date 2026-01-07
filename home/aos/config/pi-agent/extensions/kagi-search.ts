/**
 * Kagi Search Extension for pi
 *
 * Provides a kagi_search tool that searches Kagi and returns results.
 * Uses the kagi-search CLI tool which must be available in PATH.
 *
 * Usage:
 * 1. Ensure this extension is loaded (add to ~/.pi/agent/settings.json or symlink to ~/.pi/agent/extensions/)
 * 2. Ask pi to "search kagi for <query>"
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";

interface SearchResult {
  title: string;
  url: string;
  snippet: string;
}

interface QuickAnswer {
  markdown: string;
  raw_text: string;
  references: Array<{ title?: string; url?: string }>;
}

interface KagiResponse {
  results: SearchResult[];
  quick_answer?: QuickAnswer;
}

export default function kagiSearchExtension(pi: ExtensionAPI) {
  pi.registerTool({
    name: "kagi_search",
    label: "Kagi Search",
    description:
      "Search Kagi for information. Use this when specifically asked to search Kagi. Returns search results and optionally a Quick Answer summary.",
    parameters: Type.Object({
      query: Type.String({ description: "The search query" }),
      num_results: Type.Optional(
        Type.Number({
          description: "Number of results to return (default: 10, max: 20)",
          minimum: 1,
          maximum: 20,
        })
      ),
    }),

    async execute(_toolCallId, params, onUpdate, _ctx, signal) {
      const { query, num_results = 10 } = params as {
        query: string;
        num_results?: number;
      };

      // Show progress
      onUpdate?.({
        content: [{ type: "text", text: `Searching Kagi for: ${query}` }],
      });

      try {
        // Execute kagi-search command
        const result = await pi.exec(
          "kagi-search",
          ["--json", "-n", String(num_results), query],
          { signal, timeout: 60000 }
        );

        if (result.code !== 0) {
          return {
            content: [
              {
                type: "text",
                text: `Search failed: ${result.stderr || "Unknown error"}`,
              },
            ],
            details: { error: result.stderr },
            isError: true,
          };
        }

        // Parse JSON response
        const response: KagiResponse = JSON.parse(result.stdout);

        // Format results for LLM
        let resultText = "";

        // Include Quick Answer if available
        if (response.quick_answer) {
          const qa = response.quick_answer;
          resultText += "## Quick Answer\n\n";
          resultText += qa.raw_text || qa.markdown || "";
          resultText += "\n\n";

          if (qa.references && qa.references.length > 0) {
            resultText += "### References\n";
            qa.references.slice(0, 5).forEach((ref, i) => {
              if (ref.title && ref.url) {
                resultText += `${i + 1}. [${ref.title}](${ref.url})\n`;
              }
            });
            resultText += "\n";
          }
        }

        // Include search results
        if (response.results && response.results.length > 0) {
          resultText += "## Search Results\n\n";
          response.results.forEach((r, i) => {
            resultText += `### ${i + 1}. ${r.title}\n`;
            resultText += `URL: ${r.url}\n`;
            if (r.snippet) {
              resultText += `${r.snippet}\n`;
            }
            resultText += "\n";
          });
        }

        if (!resultText) {
          resultText = "No results found.";
        }

        return {
          content: [{ type: "text", text: resultText }],
          details: {
            query,
            num_results: response.results?.length || 0,
            has_quick_answer: !!response.quick_answer,
            results: response.results,
            quick_answer: response.quick_answer,
          },
        };
      } catch (error) {
        const errorMessage =
          error instanceof Error ? error.message : String(error);
        return {
          content: [{ type: "text", text: `Search error: ${errorMessage}` }],
          details: { error: errorMessage },
          isError: true,
        };
      }
    },

    // Custom rendering for tool calls
    renderCall(args, theme) {
      const { query, num_results } = args as {
        query?: string;
        num_results?: number;
      };
      let text = theme.fg("toolTitle", theme.bold("kagi_search "));
      if (query) {
        text += theme.fg("accent", `"${query}"`);
      }
      if (num_results) {
        text += theme.fg("muted", ` (${num_results} results)`);
      }
      return new Text(text, 0, 0);
    },

    // Custom rendering for results
    renderResult(result, { expanded }, theme) {
      const details = result.details as {
        query?: string;
        num_results?: number;
        has_quick_answer?: boolean;
        results?: SearchResult[];
        error?: string;
      } | undefined;

      if (details?.error) {
        return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);
      }

      let text = theme.fg("success", "✓ ");
      if (details?.has_quick_answer) {
        text += theme.fg("accent", "Quick Answer + ");
      }
      text += theme.fg("muted", `${details?.num_results || 0} results`);

      // Show first 5 result titles
      const results = details?.results || [];
      results.slice(0, 5).forEach((r, i) => {
        text += "\n" + theme.fg("muted", `${i + 1}. `) + theme.fg("fg", r.title);
      });

      return new Text(text, 0, 0);
    },
  });
}
