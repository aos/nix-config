#!/usr/bin/env bash
# Load a document into the lattice session

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}

# Start server if not running
if ! curl -s "http://${LATTICE_HOST}:${LATTICE_PORT}/health" >/dev/null 2>&1; then
    "$(dirname "$0")/start-server.sh" "${LATTICE_PORT}"
fi

if [ "$1" = "-" ]; then
    # Read from stdin
    CONTENT=$(cat)
    BODY=$(jq -n --arg content "$CONTENT" '{"content": $content}')
elif [ -n "$1" ]; then
    FILE_PATH=$(realpath "$1")
    if [ ! -f "$FILE_PATH" ]; then
        echo "Error: File not found: $FILE_PATH"
        exit 1
    fi
    BODY=$(jq -n --arg path "$FILE_PATH" '{"filePath": $path}')
else
    echo "Usage: $0 <file-path>"
    echo "   or: cat file.txt | $0 -"
    exit 1
fi

# Load document
RESPONSE=$(curl -s -X POST "http://${LATTICE_HOST}:${LATTICE_PORT}/load" \
    -H "Content-Type: application/json" \
    -d "$BODY")

echo "$RESPONSE" | jq -r 'if .success then "Loaded: \(.data)" else "Error: \(.error)" end'
