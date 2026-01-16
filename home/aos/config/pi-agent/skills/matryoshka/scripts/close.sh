#!/usr/bin/env bash
# Close the current session and free memory

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}

RESPONSE=$(curl -s -X POST "http://${LATTICE_HOST}:${LATTICE_PORT}/close")

echo "$RESPONSE" | jq -r 'if .success then .message else "Error: \(.error)" end'
