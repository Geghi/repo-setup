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

Runtime model map — list supported runtimes and their model/effort for each level. The ship skill selects the active runtime; this file stays the source of truth.

| Level | {{Runtime 1}} | {{Runtime 2}} |
| ----- | ------------- | ------------- |
| light | {{model, effort}} | {{model, effort}} |
| standard | {{model, effort}} | {{model, effort}} |
| deep (optional; enable only if explicitly chosen at setup) | {{model, effort or disabled}} | {{model, effort or disabled}} |

For each role, define its responsibility/scope, category (bundled, specialist, verifier or docs), and, for repo-specific roles, the repo-root path to its prompt under `.agents/ship/agents/`. `/ship` chooses its level on every run from that scope, the intent, and the code diff size; there is no per-role base level.

| Role | Category | Responsibility / scope | Prompt |
| ---- | -------- | ---------------------- | ------ |
| `review-general` | bundled | General review of the diff | `.agents/ship/references/review-general.md` |
| `review-standards` | bundled | Repo coding standards | `.agents/ship/references/review-standards.md` |
| `review-spec` | bundled | Intent/spec compliance | `.agents/ship/references/review-spec.md` |
| `review-tests` | specialist | Test truthfulness and coverage; delete if absent | `.agents/ship/agents/review-tests/review-tests.md` |
| `verifier` | verifier | Runtime verification | `.agents/ship/references/verifier.md` |
| `docs-engineer` | docs | Update repo documentation | `.agents/ship/agents/docs-engineer/docs-engineer.md` |
| `{{review-name}}` | specialist | {{the single recurring risk it owns}} | `.agents/ship/agents/{{review-name}}/{{review-name}}.md` |

## Commands

One line per tool; each must exit non-zero on failure. Mark `serial` what can't run alongside the others (shared DB, fixed port).

- Install: `{{pnpm install}}`
- Lint: `{{pnpm lint}}` (fix: `{{pnpm lint:fix}}`)
- Typecheck: `{{pnpm typecheck}}`
- Test: `{{pnpm test:unit}}`
- {{One `Test:` line per other layer chosen as a gate at setup (integration, e2e, contract, DB, …): command, `serial` if it shares a DB or port, what it needs, `only if the diff touches <paths>` when it applies, and what to report when its stack is down ("not run", never "passed"). E.g. `Test: pnpm test:integration — serial, needs the local Supabase stack; down → report "not run"`. Delete if unit is the only gating layer.}}
- {{Extra gates picked at setup that need no running app, e.g. `Gate: semgrep --config auto --error`, `Gate: supabase test db — serial`. Delete if none.}}
- Never run automatically: {{e2e, golden, live endpoints, paid APIs — and why}}

## Verify

- `verifiers: {{1}}` {{— raise for risky surfaces, e.g. 3 for checkout/auth}}. How to run and drive the app: `.agents/verify.md`.

## Never fix

{{Repo additions to `fix-rules.md`, each with why — e.g. `supabase/migrations/`, auth, timezone logic. Delete if none.}}

## Ignore patterns

{{Lockfiles, generated code, vendored dirs, snapshots — kept out of every reviewer's diff. Delete if none.}}

## Delivery

- {{If tied to a tracker: the status `/ship` sets when the PR exists, what happens to the issue on merge as chosen at setup (nothing / in-review / done), what the PR must carry for that (e.g. a closing keyword + key in the body), and which status the tracker sets itself.}}
- **Gate:** anything still blocking, or checks failing → {{open a `[BLOCKED]` draft PR anyway / hold the push and ask first}}.

## Never flag

{{Deliberate patterns that look wrong, each with WHY it's deliberate — the reason stops the same false positive coming back. Grows by hand.}}
