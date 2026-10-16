# Fix rules

`ship` fixes every finding, whatever its severity, except the ones below.
Those stay untouched and are reported as open findings.

## Ask, never fix

1. **Product decisions** — the fix changes how an already-shipped flow behaves for the user, questions the intent, or reverses a deliberate choice noted in the intent or commits.
2. **Needs the user** — a secret, a credential, a choice between two valid approaches, missing information.
3. **A failing test** where it's unclear whether the test or the code is wrong.
4. **Weakening an existing test** — modifying, skipping, or deleting an assertion without a clear reason. Adding tests is always fine.
5. **Two reviewers disagree** on the same line.
6. **Anything under `.claude/` or `.agents/`** — a reviewer that can rewrite its own instructions can teach itself to stop reporting a class of bug.
7. Anything `.agents/ship.md` lists under **Never fix**.

`ship` may treat a row as one of these even if the reviewer said `needs_user: no` — never the other way round.

## Missing tests are always fixed

Write the test: red, then green when it pins a code fix.
A new test that passes on its first run → prove it can fail with a throwaway mutation of the code it guards, then restore.
"Needs a harness" is no excuse: reuse the helpers, mocks and fixtures of sibling tests; only if none exist, build the minimal one.
A coverage gap stays open only after round 2, naming what you searched.
