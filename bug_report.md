---
name: Bug report
about: Report a defect in the ops agent
title: ""
labels: bug
assignees: ""
---

## What happened

What the agent or the API did. Paste the error message or the request id if you have one.

## Expected

What should have happened instead.

## Reproduce

1. Steps, starting from how the stack was run
2. The request you sent (channel, subject, body), with any real data removed
3. Where it went wrong: intake, a graph node, the worker, or the report

## Environment

- Version or commit:
- How it runs: Docker Compose (`make up`) or local (`make api` and `make worker`)
- Python version:
- Sandbox mode or real integrations (name which adapters were live):
