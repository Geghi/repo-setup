# Backend rules

Rules for repos with a server / API layer. Format and usage: [README.md](README.md).

## Raw error messages never reach the client

- **Problem:** a `catch` puts `error.message` in the response body, so users see `fetch failed`, SQL errors, stack fragments or English dev strings; it can also leak internals.
- **Applies when:** route handlers / controllers return errors to a UI the end user reads.
- **Check:**
  - Preferred: a conformance test that scans the route files and fails when a caught error's message flows into the response (`error: message`, `description: message`, `err instanceof Error ? err.message : …`), with an exemption map where each entry has a reason.
  - Optional: a lint rule (ESLint `no-restricted-syntax`, Ruff/semgrep elsewhere) banning the extraction idiom inside the API folder. Noisier: it also flags legitimate sentinel matching (`message.includes("not found")`); move those behind one exempted helper.
  - The fix side: one shared mapper `unexpected error → { status, user message }` (network failure → 503 "service unreachable", anything else → 500 generic message); the raw message goes only to the logger.
- **False positives:** messages the code itself wrote (validation summaries, mapped domain errors). Exempt them by file + reason.

## Every route goes through the access policy
- **Problem:** a route that resolves the user/tenant by hand skips the shared auth or tenant check.
- **Applies when:** there is a shared auth/authorization wrapper for handlers.
- **Check:** conformance test scanning route files: each handler starts with the policy helper; exemptions (webhooks, public endpoints) listed with a reason.

## Every handler has an outer error boundary
- **Problem:** an unexpected throw becomes a silent framework 500 with no log.
- **Applies when:** handlers are plain functions the framework calls (Next route handlers, serverless).
- **Check:** conformance test: each handler has a top-level try/catch or the shared wrapper.

## Mutations write an audit row, with no PII
- **Problem:** significant writes leave no trace, or the trace leaks personal data.
- **Applies when:** the product needs an audit log (regulated domains, multi-tenant B2B).
- **Check:** conformance test: mutating routes call the audit helper; audit payload keys are IDs/structural only.

## Writes invalidate the caches they affect
- **Problem:** a server-side cached read serves stale role/billing/config after a mutation.
- **Applies when:** the repo caches reads by tag/key on the server.
- **Check:** conformance test: every writer of a cached table calls the matching invalidation helper.

## Query round trips in one entry flow
- **Problem:** a route, cron, queue job or worker makes N database round trips where one embedded read, join or batched call would answer in N-1 or fewer — avoidable delay and cost on every run of the flow, and it compounds in loops (N+1).
- **Applies when:** the repo has any server / API / cron / queue code with a database reachable from an entry point.
- **Check:** no practical lint / dataflow rule today — enforcement is review-time, via the shipped `query-flow-review` skill (the `review-query-flow` row in the ship reviewer table). It traces the flow, inventories the requests per scenario and flags the avoidable ones.
- **False positives:** separate reads that are necessary — taken under a lock or inside a transaction for atomicity, a deliberate freshness refetch after write, or independent failure domains where one merged call would lose per-item results to a single failure.
