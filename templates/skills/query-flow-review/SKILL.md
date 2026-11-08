---
name: query-flow-review
description: Flow-aware database round-trip reviewer. Reviews a diff inside its reachable flow (route, cron, queue, worker) and flags avoidable round trips: split queries that belong together (prefer an embedded read or join), repeated reads, discarded data, N+1 reads/writes. Use when reviewing or shipping a diff that touches data access, when the user asks how many queries or round trips a flow makes, or invokes query-flow-review.
---

# Query flow review

You review the flow a diff lives in, not just the diff: one entry point's data-access
flow, every round trip it makes, the ones the diff added, and the ones it merely
sits beside but could fix.

Read-only. No code changes, no production calls, no migrations, no tracker writes
from inside this review — findings only.

**Input:** the diff (or the entry point to map) and the repo around it.
Missing → ask.

## Output mode

Two modes, resolved up front:

- **Ship mode** — you are a reviewer inside a `/ship`-style round: report through
  the repo's reviewer output contract. Resolve `.agents/ship/references/output.md`
  from the target repository root; it is authoritative for severity, `finding` /
  `why` / `fix` shape, and `needs_user`. Never guess what it does not say.
- **Standalone mode** — no ship contract found (or the user asked the flow questions
  directly). Return, in this order: **coverage** (entry points traced, branches
  skipped and why), the **request inventory** as a numbered list in execution
  order, the **findings** table below, **accepted reasons** for round trips you
  deliberately do not flag, and **unresolved questions**. Never pad: coverage
  without a finding is a fine result.

## 0 — Learn how this codebase talks to its data

Before tracing anything:

- The DB client / ORM / query builder and its call shape (`.select()`, `db.query`,
  `prisma.x.findMany`, `.rpc(...)`): that shape is what you grep for.
- Every cache layer in the path: per-request memoisation, in-process LRU, Redis,
  HTTP cache, stored in-flight promises. For each: key, lifetime (request,
  process, TTL), where its scope begins and ends.
- Where entry points are wired (router, queue registration, cron, framework
  conventions).
- Docs, flow maps, ADRs the repo keeps. They are the guide; the code wins.

Completion: you can name the call shape and every cache layer the traced path
crosses — you must mark inventory entries as `(cache)` or not, so guessing here
corrupts every later step.

## 1 — Trace the flow

From every entry point the diff can affect, follow the reachable flow depth-first,
past module boundaries and barrels, until each branch reaches I/O.

Include what the diff did not touch: unchanged helpers it now runs through,
provider/adapter branches (both sides of a port), loops, retry and error paths
that still hit the store, background tasks and side effects it enqueues with data
it just read.

Completion: every reachable I/O call from every affected entry point is in the
inventory. A helper you cannot name is a hole, not a shortcut.

## 2 — Inventory every request

One numbered entry per awaited network call, in execution order. Per call:
file::symbol, table/service/procedure, read or write, sequential or inside a
parallel group, loop multiplicity (in this loop × what), conditional on what,
cache scope and proven hit or miss — **cache hit = 0** after the first call in
its scope, and only when that scope truly exists on this path.

Then shape it as **explicit scenarios**, never formulas: normal case, each early
exit, each flag on/off. Per scenario count: DB requests, other HTTP, queued
writes, and the number of sequential waits (a parallel group is one wait).
"For 3 clinicians in one month: 9" — show the scenario, keep any formula to
itself.

## 3 — What counts as a finding

Flat list; scan for every line. A finding claims a round trip is *avoidable* with
equivalent behaviour; anything that merely costs more you could not cut is not here.

- **Unnecessary split query**: one read that separates a table from its linked
  data already needed in the same result — the embedded-read / join
  ("dammi i servizi ciascuno con i suoi tipi") replaces two calls with one;
  you verify the relation exists and the tenant filter carries into the joined
  read before proposing it.
- **Repeated read**: the same rows read twice in one flow — a second lookup for
  logging, a fetch when a retry re-enters, re-loading between two branches.
  Reuse the result in hand, or raise it through a cache that already exists.
- **Discarded data**: rows fetched, then used only to derive something one query
  fewer — or not used at all (diagnostics whose result the flow never reads).
- **N+1 reads/writes**: one call per element where one call per set works, lazy
  relation loads that hide it, per-iteration config or settings loads (these are
  the classic hidden second trip per item).
- **Avoidable refetch after write**: a write that already returns the new state
  (`RETURNING`, upsert response), followed by a reselect of what the write
  handed back.
- **Sequential independent awaits**: candidate for parallelism — but say exactly
  what it buys: fewer sequential waits, the same number of round trips.
  Never book it as a round-trip saving.

Unsure it can merge without changing behaviour → report it **as a question**, not
a finding.

## 4 — Preference ladder, and the risks each step carries

Pass every finding through the ladder, cheapest structural change first:

1. **Reuse / elimination** — pass the value in hand; drop the call whose data
   nobody reads.
2. **Embedded read / join** — one request resolving table plus relations
   (relations resolved server-side are still one round trip, not N).
3. **Batching** — one read or write per set: a range read split in code, one
   `IN (...)`/`inFilter`, or one statement per group instead of per element.
4. **RPC / stored procedure** — merge or atomicity a client-side tool cannot buy.
   Only here, and name it as the bigger change: migrations, error independence,
   concurrent writers.

Cross-check the semantic risks of what you propose: left vs inner join and what a
null row does to it, cardinality surprises (a nested list multiplies row counts),
ordering / limits / pagination the merged query must preserve, malformed or
partial rows, per-item vs all-at-once failures (with a join, one provider failure
loses what independent calls would have saved), freshness a cached or batched read
gives away, and any read-after-write, lock, or atomicity the original sequence
banked on.

Never propose to cut: a tenant / ownership filter, a validation, or an audit
write. Parallelism reduces waiting, never round trips — say so at that ladder
step. Mark what you cannot verify **unverified** (relationships, timing), never
invent feasibility or savings.

Completion: every finding names the ladder rung you chose, the saving (`3 → 2`
in the scenario that matters), and the risks you ruled out — or you say what
remains unverified.

## 5 — Findings table

One row per finding:

- `class` — prefix on `finding`: **introduced** (the diff created it),
  **worsened** (the diff makes an existing one worse — more runs, a busier loop),
  or **existing-flow** (pre-existing, the flow around it).
- `evidence` — `path::symbol` plus a scenario count, e.g. `availability-search::for 3 clinicians, 17 → 10`.
- The rest of the fields follow the mode: in ship mode the repo's output contract
  owns severity, wording bounds and `needs_user`; existing-flow opportunities are
  usually **`needs_user: yes`** (they expand scope beyond the diff) and
  pre-existing issues are ordinarily warnings — a severity bump needs a regression
  or a hard written repo rule. Standalone mode carries its own table from §Output mode.

Before returning, re-run this check once: every finding — did you trace the call
in the flow, prove the data is unused or removable without a behaviour change,
and name the scenario that shows the saving? A "maybe also" that fails the
check is an unresolved question, never a row.
