---
name: browser-tools
description: Fetch and extract content from web pages using Lightpanda headless browser. Use when you need to retrieve webpage content that requires JavaScript execution. Handles dynamic/JS-rendered pages unlike simple HTTP fetches.
---

# Browser Tools

Headless browser for fetching web content. Unlike curl/fetch, this executes JavaScript and renders dynamic pages.

## Fetch Page Content

```bash
./scripts/fetch.sh https://example.com
./scripts/fetch.sh https://example.com --quiet
./scripts/fetch.sh https://example.com --raw
./scripts/fetch.sh https://example.com --strip js
./scripts/fetch.sh https://example.com --timeout 30000
```

Fetches a URL, executes JavaScript, and returns content. Output wrapped in `<webpage>` tags.

**Options:**
- `--raw` - Return full HTML instead of stripped content
- `--strip <mode>` - What to remove: `js`, `ui`, `css`, `full` (default)
- `--timeout <ms>` - HTTP timeout in milliseconds (default: 10000)
- `--quiet` - Suppress stderr logging

**Strip modes:**
- `js` - Remove script tags only
- `ui` - Remove images, video, CSS, SVG
- `css` - Remove style tags only
- `full` - Remove all of the above (default, best for text extraction)

## Direct Lightpanda Usage

For more control, use `lightpanda` directly:

```bash
# Fetch with full HTML
lightpanda fetch --dump https://example.com

# Fetch with stripped content
lightpanda fetch --dump --strip_mode full https://example.com

# Start CDP server for Puppeteer/Playwright
lightpanda serve --host 127.0.0.1 --port 9222
```

## Workflow

1. For most pages: `./scripts/fetch.sh <url> --quiet`
2. For debugging/raw HTML: `./scripts/fetch.sh <url> --raw`
3. For JS-heavy SPAs, increase timeout: `./scripts/fetch.sh <url> --timeout 30000`
