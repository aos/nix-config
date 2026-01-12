#!/usr/bin/env bash
# Fetch a URL using Lightpanda headless browser.
# Executes JavaScript and returns rendered content.
set -euo pipefail

usage() {
  cat << 'EOF'
Usage: fetch.sh <url> [options]

Options:
  --raw              Return full HTML (default: strip scripts/styles/ui)
  --strip <mode>     Strip mode: js, ui, css, full (default: full)
  --timeout <ms>     HTTP timeout in milliseconds (default: 10000)
  --quiet            Suppress stderr logging

Examples:
  fetch.sh https://example.com
  fetch.sh https://example.com --raw
  fetch.sh https://example.com --strip js
EOF
  exit 1
}

URL=""
STRIP_MODE="full"
RAW=false
TIMEOUT=10000
QUIET=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --raw)
      RAW=true
      shift
      ;;
    --strip)
      STRIP_MODE="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --quiet|-q)
      QUIET=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      URL="$1"
      shift
      ;;
  esac
done

if [[ -z "$URL" ]]; then
  echo "Error: URL required" >&2
  usage
fi

# Build lightpanda command
CMD=(lightpanda fetch --dump --http_timeout "$TIMEOUT")

if [[ "$RAW" == "false" ]]; then
  CMD+=(--strip_mode "$STRIP_MODE")
fi

CMD+=("$URL")

# Execute and wrap output
echo "<webpage url=\"$URL\">"
if [[ "$QUIET" == "true" ]]; then
  "${CMD[@]}" 2>/dev/null
else
  "${CMD[@]}"
fi
echo "</webpage>"
