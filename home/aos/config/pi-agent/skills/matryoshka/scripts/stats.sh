#!/usr/bin/env bash
# Get document statistics

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}

curl -s "http://${LATTICE_HOST}:${LATTICE_PORT}/stats" | jq .
