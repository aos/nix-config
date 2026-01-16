#!/usr/bin/env bash
# Execute a Nucleus query

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}

if [ -z "$1" ]; then
    echo "Usage: $0 '(grep \"pattern\")'"
    exit 1
fi

COMMAND="$1"

# Ensure server is running
if ! curl -s "http://${LATTICE_HOST}:${LATTICE_PORT}/health" >/dev/null 2>&1; then
    echo "Error: Lattice server not running. Run start-server.sh first."
    exit 1
fi

# Execute query
RESPONSE=$(curl -s -X POST "http://${LATTICE_HOST}:${LATTICE_PORT}/query" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg cmd "$COMMAND" '{"command": $cmd}')")

echo "$RESPONSE" | jq .
