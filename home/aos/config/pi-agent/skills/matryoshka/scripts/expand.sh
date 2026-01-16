#!/usr/bin/env bash
# Expand a handle to see full data (with optional limit/offset)

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}

if [ -z "$1" ]; then
    echo "Usage: $0 <variable> [limit] [offset]"
    echo "Example: $0 RESULTS 10"
    echo "         $0 RESULTS 10 20  # Show items 10-19"
    exit 1
fi

VARIABLE="$1"
LIMIT="${2:-0}"
OFFSET="${3:-0}"

# Expand using a query that accesses the variable
if [ "$LIMIT" -eq 0 ]; then
    # No limit - just show the binding
    QUERY="$VARIABLE"
else
    # Use a map to slice the array
    QUERY="(slice $VARIABLE $OFFSET $((OFFSET + LIMIT)))"
fi

RESPONSE=$(curl -s -X POST "http://${LATTICE_HOST}:${LATTICE_PORT}/query" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg cmd "$QUERY" '{"command": $cmd}')")

echo "$RESPONSE" | jq .
