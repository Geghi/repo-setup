# Phase 1 — ship

Goal: the repo has a working `/ship` pipeline.

1. Copy `templates/skills/ship/` → `.claude/skills/ship/` and `templates/skills/pr/` → `.claude/skills/pr/`.
2. `.agents/ship.md` exists → stop ("ship already initialized"). Otherwise run the guided setup below.

Produce `.agents/ship.md`, `.agents/verify.md` and the agents this repo needs, **with the user**.
Work out what you can first, so the conversation is about what you can't infer: which reviewers this repo deserves, and what each should obsess over.
My defaults (still confirm): always push and open a PR; blocking findings → `[BLOCKED]` draft PR.

## 1. Investigate first

- Git root, remote, default branch, branch naming (`git branch -r`)
- `CLAUDE.md` / `AGENTS.md` / `CODING_STANDARDS.md` / `CONTEXT.md` / `README` — the repo's own rules are the
  raw material for checklists and never-fix rules
- `package.json` scripts (or Makefile, `pyproject.toml`, `go.mod`) → lint,
  typecheck, test, and the install command
- Where docs live: `docs/`, `CONTEXT.md`, `docs/adr/`, a `changelog/` convention
- What the codebase *is*: multi-tenant? auth model? DB access pattern? external
  contracts? public-facing? That shapes the reviewer set.
- **An issue tracker**: a doc describing one (`docs/**` mentioning tickets,
  issues, a board), a CLI on `PATH`, an MCP server, issue keys in `git log`
  or branch names, a `.github/ISSUE_TEMPLATE`, or just the remote's own issues.
  Note what you find; the next step decides what to do with it.

## 2. Then the conversation

Present findings compactly, propose a reviewer set with a reason each, then ask —
a few at a time, not a wall — and let the user redirect:

- **Base/working branch?** Always ask: many teams branch off and PR against `test`/`develop`, not the git default.
- **Which reviewers?** The generalist is already covered — `templates/skills/ship/references/review-general.md`
  runs on every `/ship` in every repo automatically, no setup, nothing to add to
  `ship.md` for it.
  **`review-tests` is the one to propose first**, and in most repos the answer is
  yes: test truthfulness is not a domain concern, it is what decides whether every
  other check meant anything, and a repo whose code ships without a human reading
  it has nothing else guarding it. Use `templates/ship/review-tests.md`. Skip it only
  when the repo genuinely has no test suite.
  The standards reviewer and the Spec reviewer are bundled too. Code-writing
  rules go in `CODING_STANDARDS.md` — never a reviewer just to enforce them.
  Beyond that, *specialists*: propose 0–3, and only for a real recurring risk this
  repo has actually hit
  (tenancy isolation, data security, query performance, API contract stability,
  accessibility, concurrency, this repo's own written architecture rules).
  **Don't add one because it sounds thorough** — a reviewer with nothing to find
  is noise, and it duplicates ground the generalist already covers.
- **What should each obsess over?** Ask what has actually bitten them here. Worth
  more than any checklist you can infer, and belongs verbatim in the agent file.
- **For `review-tests`: which coverage gaps are blocking, not warnings?** The
  template's section 3 is deliberately empty — ask what a missing test has actually
  cost them (a silent isolation leak, a DST bug, an unasserted audit row, a
  rounding error). And ask **who reads the shipped code**: if a human reviews every
  PR, soften the template's paranoid calibration; if nobody does, keep it.
- **Extra gates?** Read `references/gate-tools.md`, match it against what step 1 found, and propose the 2–4 that fit best, one line each on what they'd catch here. The user picks; add nothing they didn't.
- **Model?** Default `opus` for repo reviewers; bundled agents run `opus` at effort `medium`. Propose a cheaper model only for a mechanical, narrow reviewer, and say why.
- **Areas to leave alone?** Generated code, vendored files, legacy under rewrite.
- **Tie each run to an issue?** Only worth asking when step 1 found a tracker.
  Some teams want every `/ship` to belong to a ticket — find it or create it before
  branching, so the branch can carry its key — others find that pure friction on a
  solo repo. Ask, and if yes, also ask **what status a run should set** on start
  and on PR (commonly in-progress, then in-review).
  **If they want PRs linked to issues, do not guess how that tracker links them.**
  Conventions differ and are easy to get subtly wrong — a key in the branch may
  link without closing, a closing keyword may need to sit immediately before the
  key, some trackers ignore commit messages entirely. Read that tracker's own
  documentation and confirm: what establishes the link (branch, PR title, PR body),
  what closes the issue on merge, and which status transitions happen by themselves
  versus which `/ship` must perform. Record the answer, and where you verified it.
- **Delivery:** which base branch, and **what happens when something is still
  blocking** — a `[BLOCKED]` draft PR anyway, or hold the push and ask first?
  The PR body is always the `pr` skill; the full report is terminal only.
- **What must ship never fix on its own?** Beyond `templates/skills/ship/references/fix-rules.md`'s
  defaults — areas where only the user decides (auth, migrations, money…).
- **What must reviewers NOT flag** — deliberate patterns that look wrong. Prevents
  the same false positive every single run.
- **Which doc paths may the docs agent write?** (its own table, not `ship.md`) Confirm what step 1 found: docs
  folder, glossary/context file, changelog convention, a `map/` code map if the
  repo has one. Getting this wrong means either stale docs or an agent editing
  something the user considers hand-written.

## 3. Write the files

**Everything you write starts from `templates/ship/`**. Copy,
fill every `{{PLACEHOLDER}}`, delete the sections that do not apply, and delete
the leading HTML comment. Never leave a placeholder in the target repo — the
pipeline reads these files as fact.

| Template | Copy to | One per |
|---|---|---|
| `templates/ship/ship.md` | `.agents/ship.md` | repo |
| `templates/ship/docs-engineer.md` | `.claude/agents/ship/docs-engineer/docs-engineer.md` | repo |
| `templates/ship/verify.md` | `.agents/verify.md` | repo |
| `templates/ship/review-tests.md` | `.claude/agents/ship/review-tests/review-tests.md` | repo (recommended) |
| `templates/ship/review-agent.md` | `.claude/agents/ship/review-<name>/review-<name>.md` | recurring risk |

The templates carry the structure and the reasoning behind each section; this file
only covers what they cannot know.

### ship.md

Run every command once and prove each can fail (a broken test, a planted finding), then restore: a tool that exits 0 on problems hides them from `/ship`.
Mark `serial` the ones that share a DB or a fixed port.
E2E runs automatically only on a local stack with its own DB, and only when the diff touches what the user sees: ask which paths count (UI code, plus the API contracts it consumes) and write them as `only if the diff touches <paths>`.
Take most care over **Commands** (suites that must never run automatically) and **Delivery** (what happens when something is blocking).
If the repo already documents its tracker, `ship.md` links that doc and states only the `/ship` policy.

### verify.md

Fill the placeholders from how the repo already runs: package scripts, `Makefile`, `.env.example`, `docker-compose.yml`, README.
Ask only what you can't find: test credentials, what verifiers must never hit.
Prove it by starting and stopping the app once. Nothing runnable → the one-line form from the template.

### docs-engineer

Fill its writable-paths table from what
step 1 found about where docs live. The `map/` section is optional: keep it only if
the repo actually has a `map/` code map, delete the whole block otherwise.

### Reviewers

One folder each, under `.claude/agents/ship/` so they stay clear of the repo's
general-purpose agents. Keep each one **narrow**: the diff, its own history, and
the specific files its domain concern lives in — not a whole-repo audit.
`review-general.md` already reads broadly to judge the diff correctly on its own;
a specialist's value is precision on one recurring risk, not repeating that breadth.

```
.claude/agents/ship/review-<name>/
    review-<name>.md            the agent
    references/<topic>.md       optional deep detail, loaded on demand
```

**When to split into `references/`**: the criterion is **the trigger, not the
length**. Detail that is long, repo-specific and relevant to only part of a diff
goes in a reference, and the agent file says *when* to read it ("read this whenever
the diff touches an API route"). If you cannot name the slice of a diff that
triggers it, it belongs in the agent file. Two or three per reviewer is plenty.
**No frontmatter** — they are documents, not agents.

## 4. Close

Show the user everything you wrote. Tell them to edit the checklists freely: those
files are the system, and they're meant to be tuned by hand as the repo teaches them
what to look for. Nothing under `.claude/` is ever changed by a ship run — reviewers
are read-only and the reviewer instructions are the user's to edit.

Then stop. Don't run the pipeline in the same turn.

**Transition:** `~/.claude/skills/ship` is a symlink to `templates/skills/ship/`, so repos without a local copy still get `/ship`. Once every repo has its own copy: `rm ~/.claude/skills/ship`.
