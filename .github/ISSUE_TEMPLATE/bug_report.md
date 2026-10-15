---
name: Bug report
about: Report a defect in the RAG platform
title: ""
labels: bug
assignees: ""
---

## What happened

What the API or the worker did. Paste the error message, the status code, or the document status if you have one.

## Expected

What should have happened instead.

## Reproduce

1. Steps, starting from how the service was run
2. The call you made (endpoint and payload shape), with tokens and real document content removed
3. Where it went wrong: upload, ingest worker, retrieval, or answering

## Environment

- Version or commit:
- How it runs: Docker Compose or local (`make dev`)
- Python version:
- Embedding and answer provider: fake, anthropic, or local
