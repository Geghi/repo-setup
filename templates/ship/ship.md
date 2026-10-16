<!--
TEMPLATE — the repo-local config. Copy to `.agents/ship.md`, fill every {{PLACEHOLDER}}, delete the sections that don't apply, delete this comment.
Config only: how the pipeline behaves lives in the ship skill, an agent's behaviour lives in its own file.
-->

# ship config — {{repo-name}}

## Repo facts

- Base branch: `{{test}}` {{— why, if it isn't the git default}}
- Branch naming: `{{feature/<kebab-slug>}}`
- Commit convention: {{Conventional Commits / observed style from `git log`}}
- {{Commit-authorship rule, e.g. "never add AI attribution". Delete if none.}}

## Issue tracking

{{DELETE if runs aren't tied to a tracker.}}

Every run belongs to a {{tracker}} issue; commands and linking rules: `{{docs/agents/issue-tracker.md}}`.

- Before branching: find the issue matching the intent (named in the conversation, carried by the branch, or by searching) and set it `{{in-progress}}`. Already {{in-review/done}} → stop and ask. None → create it `{{in-progress}}`.
- The key goes in: {{branch name / PR title / PR body — verified against the tracker's docs}}.

## Reviewers

| Reviewer          | Model    | Scope                                              |
| ----------------- | -------- | -------------------------------------------------- |
| `{{review-name}}` | {{opus}} | {{the single recurring risk it owns, in one line}} |

{{Bundled agents (review-general, review-standards, review-spec, verifiers) run on `opus`, effort `medium`. Override: `Bundled model: <model>, effort <level>`. Delete if the default is fine.}}

## Commands

One line per tool; each must exit non-zero on failure. Mark `serial` what can't run alongside the others (shared DB, fixed port).

- Install: `{{pnpm install}}`
- Lint: `{{pnpm lint}}` (fix: `{{pnpm lint:fix}}`)
- Typecheck: `{{pnpm typecheck}}`
- Test: `{{pnpm test:unit}}`
- {{Test: `pnpm test:integration` — serial}}
- {{E2E: `pnpm test:e2e` — serial, only if the diff touches `frontend/**`, `src/app/**`, `packages/api-types/**`. Runs on the local stack with its own DB, never a shared or hosted one.}}
- {{Extra gates picked at setup that need no running app, e.g. `Gate: semgrep --config auto --error`, `Gate: supabase test db — serial`. Delete if none.}}
- Never run automatically: {{e2e, golden, live endpoints, paid APIs — and why}}

## Verify

- `verifiers: {{1}}` {{— raise for risky surfaces, e.g. 3 for checkout/auth}}. How to run and drive the app: `.agents/verify.md`.

## Never fix

{{Repo additions to `fix-rules.md`, each with why — e.g. `supabase/migrations/`, auth, timezone logic. Delete if none.}}

## Ignore patterns

{{Lockfiles, generated code, vendored dirs, snapshots — kept out of every reviewer's diff. Delete if none.}}

## Delivery

- {{If tied to a tracker: what the PR must carry to close the issue on merge, and which status `/ship` sets vs which the tracker sets itself.}}
- **Gate:** anything still blocking, or checks failing → {{open a `[BLOCKED]` draft PR anyway / hold the push and ask first}}.

## Never flag

{{Deliberate patterns that look wrong, each with WHY it's deliberate — the reason stops the same false positive coming back. Grows by hand.}}
