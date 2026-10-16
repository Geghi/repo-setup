---
name: ship
description: Branch, commit, multi-agent parallel code review, fix, lint/typecheck, docs update, push and PR — a repo-agnostic shipping gate. Use when the user says "ship this", "ship it", "review and ship", "manda in review", or invokes /ship.
user-invocable: true
version: 8
---

# ship

Takes the work in your tree to a reviewed, documented, pushed branch plus a report
of what needs your attention. Runs **entirely in-session**: no daemons, no
subprocesses, no extra terminals. The only parallelism is sub-agents.

The skill is repo-agnostic. Everything repo-specific lives in **`.agents/ship.md`**
in the repo, plus the agents under `.claude/agents/<namespace>/`. Both are
generated from `templates/` at setup — see `references/init.md`.

## 0 — Version and config

**Version check, before anything else.** The source of truth is
`~/virtual_desktop/projects/shared-agents/repo-setup/templates/skills/ship/`.
Compare its `SKILL.md` frontmatter `version` with this repo's
`.claude/skills/ship/SKILL.md`:

- Repo has no `.claude/skills/ship/`, or its version is lower → tell the user
  ("ship vN in repo-setup, this repo has vM / none") and **ask to update before
  proceeding**. Yes → copy the whole folder over `.claude/skills/ship/`, commit
  it alone (`chore(ship): update skill to vN`), then continue with the new
  version. No → continue with what's there.
- Source folder missing (another machine) → skip the check silently.

Then read `.agents/ship.md` from `git rev-parse --show-toplevel`.

**Only a legacy `.claude/ship.md`?** The repo uses the old format. Offer to
migrate before proceeding: move it to `.agents/ship.md`; turn "Auto-fix" into
"Never fix" (keep its never-touch list, drop the whitelist); rewrite Delivery
per `templates/ship.md` (PR body via `pr`, update an open PR); in each repo
reviewer, `autofix` → `needs_user`; delete any repo generalist reviewer whose
job the bundled `review-general` + `review-standards` now do, moving its
code-writing rules into `CODING_STANDARDS.md`. Show the diff, commit it alone.

**Missing?** The repo isn't set up: read `references/init.md` and run the guided
setup. Don't run the pipeline in the same turn — setup ends, the user reviews, they
invoke `/ship` again.

It is authoritative for base branch, reviewers, lint/typecheck/test commands, docs
paths, never-fix additions, delivery, ignore patterns. Where this says "from
`ship.md`", never guess.

If `ship.md` lists **ignore patterns** (lockfiles, generated code, vendored
files — `uv.lock`, `package-lock.json`, `dist/`, migrations snapshots, etc.):
drop matching paths from the changed-file list you hand each reviewer in step
3, and tell every reviewer explicitly to skip those paths even though they run
their own `git diff <base>...HEAD` — a reviewer that dutifully reads a 4,000-line
lockfile diff because nobody told it not to has burned the run's whole token
budget on zero signal. A repo with none listed reviews the full diff, same as
today.

## 1 — Intent

**What the user set out to accomplish** — not what the diff does. Derive it from
this conversation: the goal, the tradeoffs, anything that looks surprising without
that context. Reviewers use it to tell a deliberate decision from a mistake.

Ask only if you genuinely can't tell — one question, then continue.

## 2 — Branch and commit

No confirmations. `/ship` is the consent.

1. `git status --porcelain`, `git branch --show-current`.
2. **On the default branch** (per `ship.md`) → create `feature/<kebab-slug>` from
   the intent, or the repo's convention. **Already on a non-default branch → stay
   there.** This is why worktrees need no special handling: a worktree is always
   already on its own branch.
3. `git add -A` and commit, per the repo's commit convention. `.gitignore` already
   decides what stays out — don't second-guess it file by file. If something
   untracked shows up that clearly shouldn't be committed (a worktree manager's
   metadata, an editor scratch file), say so in the final report so the user can
   fix `.gitignore`; that's the right place for it, not a rule here.
4. Already-clean tree with commits on this branch → review those. Clean with
   nothing to review → stop and say so.
5. **Rebase onto the base branch** before anyone reads the diff: `git fetch origin`
   then `git rebase origin/<base>` (base from `ship.md`). Reviewers must see a diff
   against the *current* tip, not a stale one. A conflict is not yours to resolve:
   `git rebase --abort`, and report it as `blocking` (files listed) — the user
   decides how to reconcile.

Never `--no-verify`. A failing pre-commit hook means fix the cause and retry.

## 3 — Parallel review

Launch every reviewer in `ship.md`, **plus the default generalist reviewer
below**, **in a single message** so they all run concurrently. Each repo
reviewer is a subagent type with its own model and checklist — the expertise
lives there, not here.

**Default reviewer — always included, every repo, no setup needed:** read
`references/review-general.md` (bundled with this skill, not the repo) and
launch it as one more subagent in the same batch — `subagent_type:
general-purpose` (or `code-reviewer` if available), model `sonnet` unless
`ship.md` overrides it, its prompt being that file's "Instructions" section
verbatim plus the same base branch / diff command / intent / changed-file list
every other reviewer gets. It has no persisted file in the repo because it
doesn't need one: it's the same judge on every run, everywhere. Repo-specific
reviewers in `ship.md` are additions on top of it, not replacements for it.

**Standards reviewer — always included.** Read `references/review-standards.md`
and launch it the same way as the generalist. It checks the diff against the
repo's `CODING_STANDARDS.md` plus a code-smell baseline; repo-specific rules
belong in that file, not in a custom reviewer.

**Spec reviewer — always included.** Does the code do what
was asked? Find the spec: an issue key in the branch/commits (fetched via the
tracker doc `ship.md` points at), a path in the conversation, or the intent
itself. Launch one more `general-purpose` subagent in the same batch with the
spec, the diff command, and this brief: "Report (a) requirements missing or
partial, (b) behaviour nobody asked for (scope creep), (c) requirements that
look implemented but wrong. Quote the spec line for each." Same output table.
No spec beyond the intent → still run it against the intent.

Layout, one folder per reviewer under a namespace (`ship` by convention):

```
.claude/agents/<namespace>/<reviewer>/
    <reviewer>.md        the agent: frontmatter + core checklist
    references/*.md      deep detail, loaded by the agent on demand
```

`references/*.md` are **not** agents (no frontmatter); the agent points at them by
path and loads only what the diff touches. That's how a reviewer holds a lot of
repo knowledge without paying for all of it every run.

Reviewers are **read-only**. Give each:

- base branch and the diff command (`git diff <base>...HEAD`) — let them run it,
  don't paste a huge diff into the prompt
- the intent, verbatim
- the changed-file list
- explicit permission to read any file for context — a finding based on the diff
  alone, without looking at surrounding code, is how false positives are born
- the **plain-language rule**, spelled out to every reviewer: write `finding`,
  `why` and `fix` in simple language a non-technical person can follow — jargon
  only when there is no plain word for it. Prefer short, bullet-like phrasing
  over long prose. For anything even slightly non-obvious, include a tiny
  concrete example inside the field (e.g. "if the caller says 'Rossi' twice,
  the second booking overwrites the first") instead of extra abstract
  explanation. When the `fix` changes the code's structure, show it as a very
  short before → after snippet (one or two lines each) so the reason is
  visible at a glance — only where it genuinely helps. Keep it compact — one
  small example, not a tutorial.
- a note that review runs **before** step 7 (Deliver): this run's own branch may
  not be pushed and its PR may not exist yet, on purpose — that's not a code
  finding, see `review_scope` below

Required output shape, nothing else — **TOON**, not repeated `key: value`
blocks. One header line naming the fields once, then one compact row per
finding, instead of six labeled lines per finding — this is most of where the
token cost of a multi-reviewer run lives, so the format is not optional
polish:

```
findings[N]{severity,file,finding,why,fix,needs_user,review_scope}:
  blocking,src/foo.py:42,<one sentence: what is wrong>,<the concrete failure — which input or state produces which bad outcome>,<what should change>,no,source
  nit,src/bar.py:7,...,...,...,yes,source
```

Rules for the table, spell these out to every reviewer:

- `N` in the header must equal the row count. Zero findings → header only, no
  rows (`findings[0]{severity,file,finding,why,fix,needs_user,review_scope}:`) —
  never omit the line entirely, and never pad it to avoid an empty table.
- One row per finding, fields in the declared order, comma-delimited.
- A field containing a comma or newline must be wrapped in double quotes, with
  any literal double quote inside it doubled (standard CSV-style escaping) —
  never reformat prose to dodge quoting, just quote it.
- `severity` is exactly `blocking`, `warning`, or `nit`; `needs_user` is exactly
  `yes` or `no` (`yes` = product decision or needs something only the user has,
  see `references/fix-rules.md`). No other values, no extra columns.
- `review_scope` is exactly one of:
  - `source` — a finding about the code itself. The default; nearly every
    finding is this.
  - `pipeline-owned-delivery` — the finding's _only_ claim is that this run's
    own branch/push/PR/CI state isn't there yet (no PR open, CI not green,
    branch not pushed). Review runs before `ship`'s own Deliver step (step 7)
    — of course that state doesn't exist yet, this run hasn't reached it. Tell
    reviewers explicitly not to flag it as a code problem.
  - `external-delivery` — a genuine lifecycle requirement this run does _not_
    own (a different, pre-existing PR or artifact that must land first). This
    one stays in scope; it will not resolve itself.
    A reviewer that isn't sure which applies should default to `source` — that's
    the one nothing downstream throws away.

Immediately after collecting all reviewers' tables (still step 3, before step
4's fixes), **drop every row tagged `pipeline-owned-delivery`** and log a
one-line count of how many were dropped and why (e.g. "dropped 2 findings
about this run's own not-yet-open PR — step 7 handles that"). Every other row,
including `external-delivery`, proceeds to step 4 exactly like `source` rows —
the tag only controls this one strip, nothing else about severity/needs_user
handling changes.

`blocking` = breaks something, leaks data, or violates a hard rule in the repo's
guidelines. Not "I'd have written it differently". Tell reviewers to return an
empty table rather than pad it, and to report an uncertain finding rather than
stay silent. **No finding is ever discarded, downgraded, or filtered** — a
false positive costs a scroll, a lost positive costs a production bug.

## 4 — Fix

**Only you edit**, sequentially, after all reviewers return. Reviewers must never
edit: parallel edits to one file corrupt each other, and a fix landing mid-review
invalidates the diff another agent is still reading.

Read `references/fix-rules.md` plus `ship.md`'s **Never fix** list. **Fix every
finding — blocking, warning and nit — except those rules' exceptions.** Do not
ask first. The exceptions stay untouched and go to the PR's Merge Danger with a
concrete fix plan.

**Missing or weak test coverage is always fixed.** Write the test (red, then
green when it pins a code fix); when a new test passes on the first run, prove
it can fail with a throwaway mutation of the code it guards, then restore.
Never weaken or delete an existing assertion to make a test pass.
"Needs a harness / test setup" is not a reason to skip: first look for an
existing one (test helpers folder, mocks and fixtures in sibling tests of the
same layer) and use it. Only if none exists, build the minimal one. A coverage
gap goes to Merge Danger only after round 2, naming what you searched.

Commit each round separately (`fix: address review findings`).

Then re-run step 3 **in full, every reviewer, fresh**: a fix in one file can
introduce a problem only another reviewer would catch. Max 2 fix rounds;
whatever is still open after round 2 goes to Merge Danger.

Hand every round-2 reviewer a **decided in round 1** list in its prompt, one line
per round-1 finding: `file:line — what was decided — why` (fixed this way, kept
on purpose, or sent to Merge Danger). Tell them these are **settled**: they may
flag a regression the fix introduced, or a decision whose stated reason does not
hold in the code, but not re-argue the choice itself (e.g. round 1 raised a cap
to 4000, so round 2 does not ask to lower it again). A round-2 row that only
reverses a settled decision is dropped from the fixes and logged in one line.

## 5 — Lint, typecheck, test

Commands from `ship.md`, in order, **after** the fixes — fixes break things too.

**First check the toolchain exists.** A fresh worktree has no `node_modules` /
`.venv` / `vendor` (gitignored); if missing, run the repo's install command once. A
"module not found" is a _setup_ problem, never a finding about the user's code —
don't burn fix rounds on it.

- **Lint/typecheck failures**: mechanical, fix and re-run, max 3 rounds. Still
  failing → report as `blocking`.
- **Test failures**: never fix on your own initiative. A red test is a `blocking`
  finding — the test may be right and the code wrong, and that call is the user's.
- **Baseline check via stash: always named** (never bare `git stash`/`pop` —
  parallel agents collide): `git stash push -u -m "<name>"` … `git stash pop
"stash^{/<name>}"`.

## 5b — Verify

Reviewers *read* the diff; verifiers *run* the app and use it like a user.
They catch what only shows at runtime: a page that crashes on real data, a
button wired to nothing, a broken layout, a regression in a flow next door.

**Skip** when the diff has no runtime effect (docs, comments, tests only) —
say so in one line in the report.

**The recipe — `.agents/verify.md`.** How to run *this* app: install, start
command, port (and how to override it), env/seed data, test login, how to
drive it (`chrome-devtools-axi` for web UIs, the CLI or `curl` for APIs/tools),
how to stop it. Missing → write it now from `package.json` / `Makefile` /
README, prove it by starting the app once, and commit it alone
(`chore(ship): add verify recipe`). The diff changed how the app starts or is
reached (scripts, env vars, ports, routes, auth) → update the recipe in the
same way. That is what keeps it maintained: every ship touches it when it
drifts.

**Count:** `verifiers` from `ship.md` (default 1). The user can override per run
("ship with 3 verifiers"). Launch them **in a single message**, read-only on
code, each with:

- the recipe path, the intent, the changed-file list, `git diff <base>...HEAD`
- **its own port** (base port + its index) so parallel servers don't collide
- **its own angle** (with N > 1, split these; with 1, cover the first two):
  1. the changed flow, happy path, end to end
  2. edge inputs on that flow: empty, very long, wrong type, double submit,
     back button, reload mid-flow
  3. adjacent flows that share the changed code (find them via the callers of
     what the diff touches) — regressions
  4. the same flows on a phone-width viewport and with a slow network (web only)
- the same TOON table and plain-language rule as the reviewers, `review_scope`
  always `source`; each row's `why` states the exact steps that reproduce it
- an instruction to save a screenshot or short recording of what it checked
  into `$(git rev-parse --git-dir)/ship-evidence/` (inside `.git`, so never
  committed, one per worktree) and list the paths at the end — step 7
  reuses them as Evidence
- an instruction to stop every process it started before returning

Can't start the app at all (missing secret, external service down) → one
`blocking` row, `needs_user: yes`, saying what is missing. Never mark the run
as verified without having run it.

**Fix** the findings exactly as in step 4 (same rules, same Never fix list,
you are the only editor), commit (`fix: address verify findings`), re-run
step 5, then re-run the verifiers **whose angle produced a finding**. Max 2
rounds; anything still open goes to Merge Danger with its reproduce steps.

## 6 — Docs

Launch the **`docs-engineer`** agent named in `ship.md` — a single agent, the
**only** one with write access, restricted to the doc paths listed there. It runs
now so it documents the final code. Its own file holds its brief; `ship.md` only
says which paths it may write.

It updates what exists and adds what the change introduced. A new **ADR** it
_proposes_ in the report rather than writing: ratifying an architectural decision
is the user's call.

## 7 — Deliver

Follow `ship.md`'s **Delivery** section for the base branch, the tracker steps,
and the blocking gate. Push with `git push -u origin HEAD` only when it says so.
**A repo may gate delivery behind confirmation** ("if anything is blocking, don't
push; ask") — honour it exactly, never resolve it on your own judgment.

The PR body is written with the **`pr` skill** (Summary / Evidence / Merge
Danger), never the ship report:

- **Evidence** — proof the change works, per the repo's `docs/agents/evidence.md`
  (default if missing: level 0 = the red→green test name, 1 = + one real
  input/output, 2 = + a screenshot or short video). Max 3 proofs. Prefer the
  captures the verifiers saved in `$(git rev-parse --git-dir)/ship-evidence/`. Attach media
  the way that doc says. Default if the doc is silent:
  `gh pr edit <n> --attach './file.png#alt'` (gh >= 2.101; images/video, up to 50).
  Audio as mp4 (ffmpeg, black frame).
  **The diff touches UI (pages, components) → visual evidence is mandatory**:
  a browser recording of the changed flow, or a screenshot for a static state.
  Cannot produce it → it is `blocking`: say why and ask, never ship without it silently.
- **Merge Danger** — door and blast radius, plus every finding left open (the
  `fix-rules.md` exceptions and anything unresolved after round 2), each with
  file:line and a concrete fix plan.
- Title: the intent, in the repo's commit convention.

**Open PR for this branch into the base already exists → update its title and
body**, never open a second one. Otherwise create it. Anything blocking and the
gate allows publishing → open as **draft**, title prefixed `[BLOCKED]`.

## 8 — Report back

In the terminal only, using the format below. Plain language, bullets, a tiny
example where a finding isn't self-evident. Lead with the PR link and anything
the user must decide.

## Report format

```markdown
## ship report — <branch> · <PR link>

**Intent:** <what the user set out to do>
**Reviewers:** <names> · **Found:** <N blocking, N warnings, N nits> · **Fixed:** <N> · **Open:** <N>
**Verify:** <N verifiers, angles · N found · N fixed — or "skipped: <why>">

### 🔴 Needs you

<every finding left open — finding, why, proposed fix, file:line; same as Merge Danger>

### ✅ Fixed

<one line each: file:line — what changed>

### 📚 Docs

<files updated; ADRs proposed>

### 🧾 Evidence

<level chosen; full detail is in the PR>

### 🔧 Checks

lint: pass/fail · typecheck: pass/fail · tests: pass/fail
```
