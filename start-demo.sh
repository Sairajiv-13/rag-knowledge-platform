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
  CRED=$(python -m rag_platform.cli create-credential --tenant demo --name public-demo || true)
  echo "$CRED"
  CID=$(printf '%s' "$CRED" | python -c "import sys, json; print(json.load(sys.stdin)['client_id'])" || true)
  CS=$(printf '%s' "$CRED" | python -c "import sys, json; print(json.load(sys.stdin)['client_secret'])" || true)
  # Print SHA-256 checksums of both values (the secret's hash is the same
  # one the database stores) so hand-copied credentials can be verified
  # against them before use.
  python -c "import hashlib, sys; print('demo client_id sha256:', hashlib.sha256(sys.argv[1].encode()).hexdigest()); print('demo secret sha256:', hashlib.sha256(sys.argv[2].encode()).hexdigest())" "$CID" "$CS" || true
  # Which database this shell (and therefore the CLI) is talking to.
  python -c "import os; from urllib.parse import urlparse; u = urlparse(os.environ.get('RAG_DATABASE_URL', '')); print('demo db target:', u.hostname, u.port, u.path)" || true
  # Self-test: once the API is up, exchange the new credential from inside
  # this same container and print the result, so a login failure can be
  # located (inside the container vs from the public URL). Python is used
  # because the slim image has no curl.
  (
    python - "$PORT" "$CID" "$CS" <<'PYEOF' || true
import sys, time, urllib.request, urllib.parse, urllib.error
port, cid, cs = sys.argv[1], sys.argv[2], sys.argv[3]
base = "http://localhost:" + port
for _ in range(45):
    try:
        urllib.request.urlopen(base + "/healthz", timeout=3)
        break
    except Exception:
        time.sleep(2)
data = urllib.parse.urlencode({"grant_type": "client_credentials", "client_id": cid, "client_secret": cs}).encode()
req = urllib.request.Request(base + "/v1/auth/token", data=data)
try:
    with urllib.request.urlopen(req, timeout=15) as r:
        print("bootstrap self-test token exchange:", r.status, r.read().decode()[:200])
except urllib.error.HTTPError as e:
    print("bootstrap self-test token exchange:", e.code, e.read().decode()[:200])
except Exception as e:
    print("bootstrap self-test token exchange: error", repr(e))
PYEOF
  ) &
fi

echo "Starting Celery worker in the background..."
celery -A rag_platform.worker.celery_app:app worker --loglevel=INFO --concurrency=1 &

echo "Starting API on port $PORT..."
exec uvicorn rag_platform.main:app --host 0.0.0.0 --port "$PORT"
