#!/usr/bin/env bash
# Start lattice-http server in background

set -e

LATTICE_PORT=${LATTICE_PORT:-3456}
LATTICE_HOST=${LATTICE_HOST:-localhost}
LATTICE_TIMEOUT=${LATTICE_TIMEOUT:-600}

# Check if server is already running
if curl -s "http://${LATTICE_HOST}:${LATTICE_PORT}/health" >/dev/null 2>&1; then
    echo "Lattice server already running on http://${LATTICE_HOST}:${LATTICE_PORT}"
    exit 0
fi

# Start server in background
nohup lattice-http \
    --port "${LATTICE_PORT}" \
    --host "${LATTICE_HOST}" \
    --timeout "${LATTICE_TIMEOUT}" \
    > /tmp/lattice-http.log 2>&1 &

SERVER_PID=$!

# Wait for server to be ready
echo "Starting lattice-http server on http://${LATTICE_HOST}:${LATTICE_PORT}..."
for i in {1..30}; do
    if curl -s "http://${LATTICE_HOST}:${LATTICE_PORT}/health" >/dev/null 2>&1; then
        echo "Server is ready (PID: ${SERVER_PID})"
        exit 0
    fi
    sleep 0.5
done

echo "Failed to start server. Check /tmp/lattice-http.log"
kill ${SERVER_PID} 2>/dev/null || true
exit 1
