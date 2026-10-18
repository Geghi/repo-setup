---
name: ship
description: Branch, commit, multi-agent parallel code review, fix, lint/typecheck, docs update, push and PR — a repo-agnostic shipping gate. Use when the user says "ship this", "ship it", "review and ship", "manda in review", or invokes /ship.
user-invocable: true
---

# ship

Takes the work in the tree to a reviewed, documented, pushed branch, plus a report of what needs the user.
This file only orchestrates: the reviewers do the reviewing.
Repo config lives in `.agents/ship.md` and the agents under `.claude/agents/ship/`.

## 0 — Version and config

**Version check, first.** The source is `~/virtual_desktop/projects/shared-agents/repo-setup/`.
Its version is the top `## vN` heading of its `CHANGELOG.md`; this repo's is the number in `.agents/repo-setup-version` (missing = none).

- This repo is behind → say "repo-setup vN, this repo has vM / none", list the `CHANGELOG.md` lines in between, and ask to update.
  Yes → read `changelog/vK.md` for each missing version, oldest first, and apply it: copy what it says to copy; for a changed template, propose the edit to this repo's filled copy only where it fits, show it, and apply what the user accepts. Then write `N` to `.agents/repo-setup-version`, commit it alone (`chore: update repo-setup to vN`), continue.
  No → continue with what's there.
- Source folder missing (another machine) → skip silently.

Then read `.agents/ship.md` at the repo root.
Missing → the repo isn't set up: say so and stop. Setup is the source's `references/01-ship.md`.
It is authoritative for base branch, reviewers, commands, never-fix, ignore patterns and delivery: never guess what it doesn't say.

Empty `$(git rev-parse --git-dir)/ship-check/` and `ship-evidence/`: each run keeps only its own logs and captures.

## 1 — Intent

What the user set out to accomplish, from this conversation — not what the diff does.
Reviewers use it to tell a deliberate decision from a mistake.
Ask one question only if you genuinely can't tell.

## 2 — Branch and commit

`/ship` is the consent: no confirmations.

1. On the base branch → create `feature/<kebab-slug>` (or the repo's convention). On any other branch → stay.
2. `git add -A` and commit per the repo's convention. Untracked files that clearly don't belong → note them in the report so the user fixes `.gitignore`.
3. Clean tree → review this branch's commits; nothing to review → stop and say so.
4. `git fetch origin && git rebase origin/<base>`. Conflict → `git rebase --abort`, report it as blocking with the files.

Never `--no-verify`: a failing hook means fix the cause.

## 3 — Review

Launch in a single message, in parallel:

- every reviewer listed in `ship.md`;
- the bundled ones — `references/review-general.md`, `references/review-standards.md`, `references/review-spec.md` — as `general-purpose` subagents, prompt = the whole file.

Every bundled agent (reviewers here, verifiers in step 6) runs on model `opus`, effort `medium`, unless `ship.md` overrides it.

Give each: the base branch and `git diff <base>...HEAD` to run itself (never paste the diff), the intent verbatim, and the changed-file list minus `ship.md`'s ignore patterns (and tell it to skip those paths).
Nothing else: never the implementer's reasons for a design or test-layer choice ("the query didn't change, so unit is enough"). Reviewers judge those choices themselves.
Reviewers are read-only.

## 4 — Fix

Only you edit, one fix at a time, after every reviewer has returned: parallel edits corrupt each other.
Fix every finding of any severity, without asking, except those in `references/fix-rules.md` and `ship.md`'s Never fix; those stay open.
Commit the round (`fix: address review findings`).

Then a second round, fresh agents: only the reviewers that had findings, plus `review-general`, each told to review the fix commits (`git diff <sha before the fixes>..HEAD`), not the whole branch. Add a **settled** list: one line per earlier finding, `file:line — decision — why`.
They may flag a regression or a reason that doesn't hold in the code, not re-argue the decision; a row that only reverses one is dropped.
Max 2 rounds; whatever is still unresolved stays open.

## 5 — Lint, typecheck, test

`ship.md`'s commands, after the fixes.

- Each command on its own, never chained with `&&` or `;`: one exit code per tool.
- All at once, as parallel Bash calls in one message; those marked `serial` run afterwards, one at a time.
- Full output to `$(git rev-parse --git-dir)/ship-check/<name>.log`; never filter it (`| tail`, `| grep`, `> /dev/null`). Long or truncated → read the log file in full.
- Exit code ≠ 0 means failed, whatever the output says.
- A command marked `only if the diff touches <paths>` runs only when a changed file matches; otherwise skip it and say so in the report.
- Toolchain missing (`node_modules`, `.venv`) → run the install once. "Module not found" is setup, never a finding.
- Lint/typecheck and extra gate failures: fix and re-run, max 3 rounds, then blocking. A gate fix that falls under `references/fix-rules.md` stays open instead.
- Failing tests: never fix on your own. Blocking: the test may be right and the code wrong, and that call is the user's.
- A fix here changed behaviour, not just formatting or types (typically a gate fix) → one `review-general` pass on those changes only, its findings handled as in step 4, no further round.
- Stash only by name: `git stash push -u -m "<name>"` … `git stash pop "stash^{/<name>}"`.

## 6 — Verify

Diff with a runtime effect → follow `references/verify.md`. Otherwise skip, one line in the report.

## 7 — Docs

Launch the `docs-engineer` agent with the same inputs as the reviewers: the only agent with write access, run now so it documents the final code.

## 8 — Deliver

Push (`git push -u origin HEAD`) and open the PR, with the tracker steps and blocking gate from `ship.md`'s Delivery; a gate that says "ask first" is honoured exactly.
The PR body uses the `pr` skill, never the ship report:

- **Evidence** per `docs/agents/evidence.md` (missing → the red→green test names), max 3 proofs, preferring the verifiers' captures in `$(git rev-parse --git-dir)/ship-evidence/`. The diff touches UI → visual evidence is mandatory; can't produce it → blocking, ask.
- **Merge Danger**: door, blast radius, and every open finding with `file:line` and a concrete fix plan.
- **Title**: the intent, in the commit convention.

An open PR for this branch → update it, never open a second. Blocking and the gate allows publishing → draft, title prefixed `[BLOCKED]`.

## 9 — Report

Terminal only, in plain language. Lead with the PR link and what the user must decide.

```markdown
## ship report — <branch>

**Intent:** <what the user set out to do>
**Reviewers:** <names> · **Found:** <N blocking, N warnings, N nits> · **Fixed:** <N> · **Open:** <N>
**Verify:** <N verifiers · N found · N fixed — or "skipped: <why>">

### 🔴 Needs you

<every open finding — what, why, proposed fix, file:line>

### ✅ Fixed

<file:line — what changed>

### 📚 Docs

<files updated; ADRs proposed>

### 🔧 Checks

lint · typecheck · tests: pass/fail

PR: <PR link>
```
