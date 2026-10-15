# Security policy

## Supported versions

Security fixes land on the main branch and in the latest tagged release. Older releases do not get security fixes, so stay current.

## Reporting a vulnerability

Do not open a public issue for a security problem. A public issue tells everyone where the hole is before a fix exists.

Email the report to sairn3@gmail.com. Include:

- What you found, in plain words
- The endpoint or module involved, for example `src/rag_platform/retrieval` or the auth routes in `src/rag_platform/api`
- Steps to reproduce, with a tenant token setup described well enough to repeat
- What an attacker gains: reading another tenant's documents, bypassing revocation, quota or rate limit abuse, or something else

You will get a reply within three business days. If the report checks out, the fix ships before any public write-up, and you will be told when it is out. You will be credited in the release notes unless you ask not to be named.

## Areas that get priority

Tenant isolation and token handling are the sensitive parts of this service. `tenant_id` always comes from the JWT, a cross-tenant read returns 404 rather than 403, and token liveness is checked on every request so revocation is immediate. Reports that break any of those three properties go to the front of the queue.
