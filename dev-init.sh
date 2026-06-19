#!/bin/bash
# Development environment startup for Open Notebook
# Assumes SurrealDB is already running externally (per .env config)
#
# All ports are configurable via .env (so multiple people can run on one host):
#   SURREAL_PORT          (default 25000) - host port SurrealDB listens on
#   API_PORT              (default 25055) - port the API server binds to
#   OPEN_NOTEBOOK_UI_PORT (default 8073)  - port the Next.js dev server binds to

set -e

echo "=== Open Notebook Dev Startup ==="

# Load .env so port overrides are visible to this script (API/worker also use --env-file .env)
if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

# Resolve ports with sensible defaults
SURREAL_PORT=${SURREAL_PORT:-25000}
API_PORT=${API_PORT:-25055}
UI_PORT=${OPEN_NOTEBOOK_UI_PORT:-8073}

# Check SurrealDB connectivity
echo "Checking SurrealDB on port $SURREAL_PORT..."
if ! nc -z localhost "$SURREAL_PORT" 2>/dev/null; then
  echo "❌ SurrealDB not reachable on port $SURREAL_PORT. Please start it first."
  exit 1
fi
echo "✅ SurrealDB is running"

# Install dependencies if needed
echo "Syncing Python dependencies..."
uv sync

echo "Syncing frontend dependencies..."
cd frontend && npm install && cd ..

# Start API backend in background
echo "Starting API backend (port $API_PORT)..."
uv run --env-file .env run_api.py &
sleep 3

# Start background worker in background
echo "Starting background worker..."
uv run --env-file .env surreal-commands-worker --import-modules commands &
sleep 2

# Start frontend (foreground). next dev reads PORT (see frontend/package.json).
export PORT="$UI_PORT"
echo "Starting Next.js frontend (port $UI_PORT)..."
echo ""
echo "✅ All services starting!"
echo "  Frontend: http://localhost:$UI_PORT"
echo "  API:      http://localhost:$API_PORT"
echo "  API Docs: http://localhost:$API_PORT/docs"
echo ""
cd frontend && npm run dev
