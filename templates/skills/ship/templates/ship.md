<!--
TEMPLATE — the repo-local config. Lives here as `templates/ship.md`.

Copy to `.agents/ship.md`, fill every {{PLACEHOLDER}}, delete every section that
does not apply, and delete this comment. Never leave a placeholder behind: the
pipeline reads this file as fact.

Keep it a CONFIG, not a manual. Anything that is an agent's own behaviour belongs
in that agent's file, not here.
-->

# ship config — {{repo-name}}

## Repo facts

- Root: `{{absolute path}}`
- Git-reported default branch: `{{main}}`
- **/ship base/target branch: `{{test}}`** — {{why, if it differs from the git
  default. Many teams work and PR against a `test`/`develop` branch, not `main`.
  If they are the same, say so in one line.}}
- Branch naming: `{{feature/<kebab-slug>}}` off `{{base}}`; if already on a
  non-default branch, stay there. {{If runs are tied to an issue, the key goes in
  the branch name — see Issue tracking.}}
- Commit convention: {{Conventional Commits / observed style from `git log`}}
- {{Any commit-authorship rule, e.g. "always the user's own git identity — never
  add a Co-Authored-By trailer or AI attribution". Delete if not applicable.}}

## Issue tracking

{{DELETE THIS WHOLE SECTION if runs are not tied to a tracker.

Keep it to policy. If the repo already documents its tracker, link that file for
the commands and the linking rules instead of repeating them here.}}

Every `/ship` run belongs to a {{tracker}} issue{{, and the branch name carries its
key}} — so this happens after the intent is clear, before the branch exists.

**Commands and linking rules: `{{docs/…}}`.**

1. **Look for an existing issue** matching the intent — one the conversation
   already named, one the current branch already carries, or one that turns up
   searching the intent's keywords. Found and still open → move it to
   `{{in-progress}}`. Already {{in-review/done/cancelled}} → stop and ask.
2. **Nothing matches → create it**, `{{in-progress}}`, described from the intent.
   {{Which labels are automatic, and which must never be applied to work already
   under way.}}
3. **Carry the key**: {{how this tracker establishes the link — branch name, PR
   title, PR body, or a combination. Verified against its own docs, not assumed.}}

## Reviewers

Namespace: `ship`. {{Only change this if the repo already groups its agents under a different folder — then substitute it everywhere below.}} Launch all {{N}} in parallel every run, **plus the ship
skill's own bundled default generalist** (always injected automatically — do not
add a local generalist here, it would duplicate that reviewer).

{{Any reviewer scoped to a subsystem must self-exit fast when the diff does not
touch it: check the changed-file list first and return an empty finding list
without reading further files. State that here once, for the ones it applies to.}}

| Reviewer          | Model    | Scope                                              |
| ----------------- | -------- | -------------------------------------------------- |
| `{{review-name}}` | {{opus}} | {{the single recurring risk it owns, in one line}} |

Folder tree:

```
.claude/agents/ship/docs-engineer/docs-engineer.md
.claude/agents/ship/{{review-name}}/{{review-name}}.md
.claude/agents/ship/{{review-name}}/references/{{topic}}.md
```

## Commands

- Install: `{{pnpm install}}`
- Lint: `{{pnpm lint}}` (fix: `{{pnpm lint:fix}}`)
- Typecheck: `{{pnpm build}}` {{note if the repo has no separate typecheck script}}
- Test: `{{pnpm test:unit}}` — {{name explicitly any suite that must NEVER run
  automatically (e2e, golden, anything needing live endpoints or paid APIs) and
  why. This is the most expensive thing to get wrong.}}

## Verify

- Recipe: `.agents/verify.md` (how to start, reach and stop the app — written
  and kept current by `/ship` step 5b).
- `verifiers: {{1}}` — {{raise for risky surfaces, e.g. 3 for checkout/auth}}.
- {{Anything verifiers must never do: hit production, send real emails/SMS,
  charge cards. Delete if none.}}

## Docs

Single agent, `docs-engineer` — the **only** one with write access. Its full brief
lives in `.claude/agents/ship/docs-engineer/docs-engineer.md`; do not
duplicate it here.

- Launch it after the code is final, so it documents what actually shipped.
- It writes {{the repo's doc paths, e.g. `map/**`, `docs/**`, `CONTEXT.md`,
  `changelog/**`}}, and a `.claude/skills/*/SKILL.md` only when the diff changed
  that skill's flow.
- New ADRs: it **proposes** them in the report, never writes the file.

## Never fix

Repo additions to `references/fix-rules.md`'s "Ask, never fix" list: {{e.g.
anything under `src/server/authz/`, `supabase/migrations/`, timezone logic — say
why each one. Delete the section if the defaults are enough.}}

## Ignore patterns

{{Lockfiles, generated code, vendored directories, snapshots — kept out of every
reviewer's diff. Pure token cost with no signal. Delete the section if none.}}

## Delivery

- Push with `git push -u origin HEAD`, open the PR into `{{base}}` with the `pr`
  skill. An open PR for the branch into `{{base}}` → update it, never duplicate.
- {{If runs are tied to a tracker: what the PR must carry for the issue to close on
  merge — state the exact form, verified against the tracker's docs.}}
- {{Then set the issue to its review status. Say which transitions the tracker
  performs by itself and which `/ship` must do.}}
- **Gate:** anything still `blocking` after the fix rounds, or lint/typecheck/tests
  failing — {{open a `[BLOCKED]` draft PR anyway / hold the push and ask first}}.
  {{If tied to a tracker: leave the issue in progress.}}

## Never flag

{{Deliberate patterns that look wrong. Each entry: what not to flag, and WHY it is
deliberate — the reason is what stops the same false positive coming back every
run. This section grows by hand as the repo teaches you what is noise.}}
