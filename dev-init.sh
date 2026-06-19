#!/bin/bash
# Development environment startup for Open Notebook
# Assumes SurrealDB is already running externally (per .env config)

set -e

echo "=== Open Notebook Dev Startup ==="

# Check SurrealDB connectivity
SURREAL_PORT=${SURREAL_PORT:-25000}
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
echo "Starting API backend (port 25055)..."
uv run --env-file .env run_api.py &
sleep 3

# Start background worker in background
echo "Starting background worker..."
uv run --env-file .env surreal-commands-worker --import-modules commands &
sleep 2

# Start frontend (foreground)
echo "Starting Next.js frontend (port 8073)..."
echo ""
echo "✅ All services starting!"
echo "  Frontend: http://localhost:8073"
echo "  API:      http://localhost:25055"
echo "  API Docs: http://localhost:25055/docs"
echo ""
cd frontend && npm run dev
