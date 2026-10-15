# Contributing

Short version: branch from main, keep the change small, run `make check`, open a PR.

## Prerequisites

- Python 3.11 or newer. CI runs 3.12, and the README quickstart uses 3.12.
- Docker, if you want the full local stack (Postgres, Redis, Qdrant, Ollama).

## Setup

```bash
pip install -e ".[dev]"
cp .env.example .env
```

The defaults in `.env.example` are sandbox safe. Tests need no real keys and no running services.

To run the stack:

```bash
make up        # docker compose: Postgres, Redis, Qdrant, Ollama, api, worker
make api       # terminal 1, without Docker
make worker    # terminal 2, without Docker
```

Run `pre-commit install` once after cloning. The hooks in `.pre-commit-config.yaml` run ruff and basic file checks on each commit, the same checks CI runs.

## Checks

Run these before you push. `make check` runs the first four in one go.

- `make lint`: ruff check and format check over `app`, `tests`, `scripts`, `evals`
- `make type`: mypy in strict mode over `app` and `evals`
- `make cov`: pytest with the coverage gate, 80 percent minimum on `app`
- `make eval`: the evaluation harness in `evals/`, minimum accuracy 0.90
- `make test`: the plain suite, no coverage gate

The test suite is hermetic. SQLite stands in for Postgres, fakeredis for Redis, and every external integration runs through a sandbox adapter in `app/adapters`. Tests live in `tests/unit`, `tests/integration`, and `tests/smoke`. Smoke tests call a live LLM, self-skip when none is reachable, and stay out of the default run.

CI also runs `python -m scripts.idempotency_check`. If you touch request handling or the worker in `app/jobs`, make sure external idempotency keys stay deterministic (ADR-0017).

## Where things live

- `app/graph`: LangGraph nodes, retry, and the pipeline build
- `app/jobs`: Redis queue and the idempotent worker
- `app/adapters`: ports, with real and sandbox implementations (llm, knowledge, jira, slack, email)
- `app/security`: JWT, scopes, rate limiting, SSRF egress guard
- `app/db`: async SQLAlchemy engine, models, repository
- `docs/adr`: architecture decision records, 0001 to 0021. Read the ADR for an area before you change how it behaves.

## Branches and commits

- Branch names: short and plain, such as `fix/token-refresh-race` or `feat/slack-adapter-retries`.
- Commit subjects: short, imperative, one change per commit. Example: `Reject expired scopes at the API layer`.
- Keep formatting-only changes in their own commit so the real change stays easy to review.

## Pull requests

- Fill in the PR template. Say what changed, the exact commands you ran, and the result.
- CI must pass: lint, type check, coverage gate, eval gate, idempotency check, and the Docker build.
- If you change code in `app/`, note the coverage number from `make cov` in the PR.
- If a change alters a decision recorded in `docs/adr`, say so in the PR and update or add the ADR.
