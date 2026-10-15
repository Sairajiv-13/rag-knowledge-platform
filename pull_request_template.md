## Summary

What this PR does, in two or three sentences.

## What changed

- Point by point. Name the modules touched, for example `src/rag_platform/retrieval` or `src/rag_platform/worker`.

## Tests

List the exact commands you ran and the result of each.

- `ruff check src tests migrations`:
- `mypy`:
- `make test-unit`:
- `make test-integration` (if you touched the API, retrieval, models, or the worker):
- Migration added with `make revision`, if `models.py` changed:

## Risks or rollback

What could this break, and how would you revert it if it misbehaves in production? If tenant isolation is affected, say so plainly here.
