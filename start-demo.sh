#!/bin/sh
# Demo entrypoint: runs a local redis, the Celery worker, and the API in
# one container so the full pipeline fits a single free-tier web service.
# Demo packaging only; production runs these as separate services.
set -e

# Translate a platform DATABASE_URL once, for both the worker and the API.
if [ -n "$DATABASE_URL" ]; then
  case "$DATABASE_URL" in
    postgresql+asyncpg://*) export RAG_DATABASE_URL="$DATABASE_URL" ;;
    postgres://*) export RAG_DATABASE_URL="postgresql+asyncpg://${DATABASE_URL#postgres://}" ;;
    postgresql://*) export RAG_DATABASE_URL="postgresql+asyncpg://${DATABASE_URL#postgresql://}" ;;
  esac
fi
export RAG_REDIS_URL="${RAG_REDIS_URL:-redis://localhost:6379/0}"
: "${PORT:=8000}"

echo "Starting local redis (demo only)..."
redis-server --daemonize yes --port 6379 --save '' --appendonly no --dir /tmp

echo "Running database migrations (also CREATE EXTENSION vector)..."
alembic upgrade head

echo "Starting Celery worker in the background..."
celery -A rag_platform.worker.celery_app:app worker --loglevel=INFO --concurrency=1 &

echo "Starting API on port $PORT..."
exec uvicorn rag_platform.main:app --host 0.0.0.0 --port "$PORT"
