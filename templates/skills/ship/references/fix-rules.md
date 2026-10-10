# Fix rules

`ship` fixes **every** finding, whatever its severity, except the ones below.
Those go to the PR's Merge Danger untouched, each with a concrete fix plan.

## Ask, never fix

1. **Product decisions** — the fix changes how an existing, already-shipped flow
   behaves for the user, questions the intent, or reverses a deliberate choice
   noted in the intent or commits.
2. **Needs the user** — a secret, a credential, a choice between two valid
   approaches, missing information.
3. **A failing test** where it's unclear whether the test or the code is wrong.
4. **Weakening an existing test** — modifying, skipping, or deleting an
   assertion. Adding tests is always fine.
5. **Two reviewers disagree** on the same line.
6. **Anything under `.claude/` or `.agents/`** — the skill's config, reviewers,
   their references. A reviewer that can rewrite its own instructions can teach
   itself to stop reporting a class of bug.
7. Anything `.agents/ship.md` lists under **Never fix**.

Reviewers mark these with `needs_user: yes`. `ship` may still decide a row is
one of the above even if the reviewer said `no` — never the other way round.

## After

One commit per round (`fix: address review findings`), separate from the
feature commit. Every fix listed in the terminal report with `file:line` and
what changed.
