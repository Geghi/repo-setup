---
name: testing
description: How to add and run tests in this repo across its layers, including TDD workflow, layer selection, and non-negotiable rules. Use when writing new tests, adding coverage for a feature or bug fix, doing TDD, or deciding which layer a test belongs in.
---

# Testing

This repo's commands, layers, needs and folder structure: `docs/agents/testing.md`. Read it first.

## The layers — pick the LOWEST one that can catch the failure

Trophy shape, not pyramid: fat integration middle, thin E2E top.

- **Unit**: pure logic (parsers, mappers, calculations).
- **Integration**: code against real dependencies (DB, queues).
- **E2E**: user journeys through the real UI.

Decision rule: **does it involve DB/state? → integration. Does it require a
browser (or the full app) to fail? → E2E. Otherwise → unit.**
Extra layers (e.g. pgTAP) and when to use them: `docs/agents/testing.md`.

## TDD workflow

Red → green → refactor — use the `tdd` skill. Short version: pick the layer
first, write the failing test, watch it fail **for the right reason**, write
minimal code, refactor with the test green. Bug fixes ALWAYS start with a
failing regression test reproducing the bug.

## Naming

Behavior-focused test names ("an owner cannot write into another
tenant"), never implementation-focused ("calls update with eq").

## Non-negotiable rules

1. **Never weaken an existing test to go green.** Tests are contracts: if your change makes one fail, the default assumption is that your code is wrong — fix the code. Updating an existing test is fine only when the behaviour change is intentional (the task asks for it): rewrite the assertion to the new expected behaviour, taken from the task or spec, never from the code's output, and keep the case at least as strict as before. Say in the commit which test changed and why. Deleting or skipping a test, or loosening it without a behaviour change, still needs the user first.
2. **Never fake a test to make it pass.** This is the cardinal sin, in every form it takes:
   - Never change an assertion to match the code's current (possibly buggy) output just to go green — verify the expected value is _correct_, from the spec or the user, not from what the code happens to return.
   - Never write tautological tests that cannot fail (asserting a mock returns what you told it to, `expect(x).toBeDefined()` on something always defined, copying the implementation into the expectation).
   - Never mock/stub the very thing under test, and never broaden a mock until the test stops touching real behavior.
   - Never swallow failures (`try/catch` around assertions, `.catch(() => {})`, loosening exact assertions into vacuous ones).
   - Every new test must be seen failing at least once (TDD red, or temporarily break the code/assertion) — a test never seen red proves nothing.
   - If you can't make a test pass honestly, STOP and tell the user the truth: report the failing behavior. A red test reported honestly is worth infinitely more than a green lie.
3. **Never skip tests to get a green run.** A skipped test is a hidden regression.
4. **Isolation by unique data, never by cleanup**: every integration/E2E test file provisions its own isolated data (unique IDs; per-tenant scoping, if any, in `docs/agents/testing.md`). No truncate, no reset between tests, no shared fixtures across files. Two consecutive runs must both pass.
5. **Local stack only**: never point tests at hosted/production services. Never read `.env.local`.
6. **No PII in fixtures/assertions** beyond generated fake data.
7. **Every new feature or bug fix ships with tests** at the appropriate layer.
8. Flakiness is a bug: no sleep-based waits, no retry-until-green locally. If a test needs retries to pass, fix it.
9. **Baseline check via stash: always named.** Never bare `git stash`/`pop` (parallel agents collide). `git stash push -u -m "<name>"` … `git stash pop "stash^{/<name>}"`.

## Parallel worktrees

Several agents run tests at the same time in different worktrees: a run never shares mutable state with another run.

- One test database per worktree, named from the worktree path, created and migrated on demand; never a fixed name.
- One dev-server port per worktree for e2e; never a fixed port.
- Integration tests run inside a transaction rolled back at the end (or on unique data when the code under test commits).
- E2E tests create uniquely named data and assert only on it, never on global counts or empty states.

## Adding a test — quick checklist

1. Pick the layer (rule above). 2. Copy the closest existing test in that folder
as a template. 3. Seed via the shared test helpers — never hand-roll setup when
a helper exists; extend the helper if a new shape is needed. 4. Run the layer's
command twice (repeatability). 5. Run lint + typecheck.
