# Contributing

Short version: branch from main, keep the change small, run `make ci`, open a PR.

## Prerequisites

- Python 3.12. The package requires it (`requires-python = ">=3.12"` in `pyproject.toml`), and CI runs 3.12.
- Docker, for Postgres with pgvector and for Redis. Integration tests need a real Postgres.

## Setup

```bash
pip install -e ".[dev]"
docker compose up --build -d
make migrate
curl -s localhost:8000/healthz
```

`make migrate` runs `alembic upgrade head` inside the api container. The health check should return `{"status":"ok"}`. Interactive docs are at http://localhost:8000/docs.

Without Docker, run the API with `make dev` (uvicorn against `src/`). You still need Postgres and Redis reachable.

## Checks

- Lint: `ruff check src tests migrations` (what CI runs; `make lint` covers `src`)
- Types: `mypy`, configured in `pyproject.toml` for the `rag_platform` package under `src/`
- Unit tests: `make test-unit` (`pytest tests/unit`). No services needed.
- Integration tests: `make test-integration` (`pytest tests/integration`). Needs Postgres up first, for example `docker compose up db`. The suite recreates the database and runs the real Alembic migrations each session.
- Coverage: `make test-cov`
- All of the above: `make ci`

## Rules that matter here

- Tenant isolation is enforced in code, not in the database (ADR 0002). `tenant_id` comes from the JWT, never from the request body. If you touch `src/rag_platform/retrieval`, the API routes, or `src/rag_platform/models.py`, add or update tests at both the API level and the SQL level.
- `src/rag_platform/models.py` is the source of truth for the schema. Change the model, then add a migration with `make revision`. CI runs `alembic upgrade` plus `alembic check`, so model and migration drift fails the build.
- Read the ADR before you change an area it covers. ADRs live in `docs/adr`. The load-bearing ones: 0001 (providers), 0002 (tenant isolation), 0003 (hybrid retrieval), 0004 (auth), 0005 (ingest jobs).

## Where things live

- `src/rag_platform/api`: routes and dependency accessors
- `src/rag_platform/ingestion`: parsers (pdf, md, html) and the sentence-packing chunker
- `src/rag_platform/retrieval`: tenant-scoped queries, RRF hybrid search, rerank
- `src/rag_platform/llm`: provider interface with anthropic, local, and fake implementations
- `src/rag_platform/worker`: Celery app and the ingest task
- `src/rag_platform/services`: ingestion orchestration
- `tests/unit` and `tests/integration`: split by whether a test needs Postgres

## Branches and commits

- Branch names: short and plain, such as `fix/chunker-empty-doc` or `feat/retrieval-rerank-flag`.
- Commit subjects: short, imperative, one change per commit. Example: `Return 404 for cross-tenant document reads`.
- Keep formatting-only changes in their own commit.

## Pull requests

- Fill in the PR template. Say what changed, the exact commands you ran, and the result.
- CI must pass: ruff, mypy, unit tests, migration check, integration tests against a pgvector service, and the Docker build.
- If you change retrieval or answering code, note the coverage from `make test-cov` in the PR. Core paths (answering, retrieval, security, models) sit at 100 percent and should stay there.
