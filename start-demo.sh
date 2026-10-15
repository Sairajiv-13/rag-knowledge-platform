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

# One-time demo bootstrap: with RAG_DEMO_BOOTSTRAP=1, create the demo
# tenant and issue its credential, printed to the deploy log (the secret is
# shown exactly once, like the CLI's normal output). The operator copies it
# from the log and then unsets the flag, so redeploys do not mint more
# credentials.
if [ "${RAG_DEMO_BOOTSTRAP:-0}" = "1" ]; then
  echo "Creating the public demo tenant and credential (bootstrap)..."
  python -m rag_platform.cli create-tenant --slug demo --name "Public demo" || true
  python -m rag_platform.cli create-credential --tenant demo --name public-demo > /tmp/demo-credential.json || true
  cat /tmp/demo-credential.json
  # Print SHA-256 checksums of both values (the secret's hash is the same
  # one the database stores) so hand-copied credentials can be verified
  # against them before use.
  python -c "import hashlib, json; d = json.load(open('/tmp/demo-credential.json')); print('demo client_id sha256:', hashlib.sha256(d['client_id'].encode()).hexdigest()); print('demo secret sha256:', hashlib.sha256(d['client_secret'].encode()).hexdigest())" || true
fi

echo "Starting Celery worker in the background..."
celery -A rag_platform.worker.celery_app:app worker --loglevel=INFO --concurrency=1 &

echo "Starting API on port $PORT..."
exec uvicorn rag_platform.main:app --host 0.0.0.0 --port "$PORT"
