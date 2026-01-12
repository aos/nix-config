---
name: kagi-search
description: Web search via Kagi. Use when specifically asked to search Kagi, or when needing to find current information, documentation, facts, or web content. Returns search results and Quick Answers.
---

# Kagi Search

Search the web using Kagi. Returns search results with titles, URLs, snippets, and optionally a Quick Answer summary with references.

## Setup

Requires `kagi-search` CLI in PATH

## Usage

```bash
# Human-readable output (colored, hyperlinked)
kagi-search "query"

# JSON output (for programmatic use)
kagi-search --json "query"

# Limit results (default: 10)
kagi-search -n 5 "query"

# Read query from stdin
echo "query" | kagi-search

# Debug mode (logs to stderr)
kagi-search -d "query"
```

## JSON Output Format

```json
{
  "results": [
    {
      "title": "Page Title",
      "url": "https://example.com",
      "snippet": "Description text..."
    }
  ],
  "quick_answer": {
    "markdown": "Formatted answer...",
    "raw_text": "Plain text answer...",
    "references": [
      { "title": "Source", "url": "https://..." }
    ]
  }
}
```

## Workflow

1. Run `kagi-search --json "query"`
2. Parse JSON response
3. Check `quick_answer` first - often has the direct answer with citations
4. Use `results` array for detailed sources and additional context
