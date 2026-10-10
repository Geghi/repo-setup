# ship — guided setup

Read **only** when `.agents/ship.md` is missing.

Produce `.agents/ship.md` plus the reviewer files this repo needs — **with the
user, not behind their back.** Work out what you can first, so the conversation is
about the one thing you can't infer: *which reviewers this repo deserves, and what
each should obsess over.*

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

- **Base/working branch?** Never assume the git-reported default branch (often
  `main`) is what the user actually works and PRs against — some teams branch off
  and target a `test`/`develop`/`staging` branch day to day instead. Always ask
  explicitly which branch `/ship` should branch from and target. Record both: the
  repo's git default (for reference) and the chosen `/ship` base branch (what
  actually goes in `ship.md`'s Repo facts and Delivery sections) if they differ.
- **Namespace?** Default `ship`; ask only if the repo groups agents some other way.
- **Which reviewers?** The generalist is already covered — `references/review-general.md`
  runs on every `/ship` in every repo automatically, no setup, nothing to add to
  `ship.md` for it.
  **`review-tests` is the one to propose first**, and in most repos the answer is
  yes: test truthfulness is not a domain concern, it is what decides whether every
  other check meant anything, and a repo whose code ships without a human reading
  it has nothing else guarding it. Use `templates/review-tests.md`. Skip it only
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
- **Model per reviewer?** Critical, subtle, high-blast-radius → strongest model.
  Mechanical or narrow → cheaper. Recommend and say why.
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
- **What must ship never fix on its own?** Beyond `references/fix-rules.md`'s
  defaults — areas where only the user decides (auth, migrations, money…).
- **What must reviewers NOT flag** — deliberate patterns that look wrong. Prevents
  the same false positive every single run.
- **Which doc paths may the docs agent write?** Confirm what step 1 found: docs
  folder, glossary/context file, changelog convention, a `map/` code map if the
  repo has one. Getting this wrong means either stale docs or an agent editing
  something the user considers hand-written.

## 3. Write the files

**Everything you write starts from `templates/`** (next to `SKILL.md`). Copy,
fill every `{{PLACEHOLDER}}`, delete the sections that do not apply, and delete
the leading HTML comment. Never leave a placeholder in the target repo — the
pipeline reads these files as fact.

| Template | Copy to | One per |
|---|---|---|
| `templates/ship.md` | `.agents/ship.md` | repo |
| `templates/docs-engineer.md` | `.claude/agents/ship/docs-engineer/docs-engineer.md` | repo |
| `templates/review-tests.md` | `.claude/agents/ship/review-tests/review-tests.md` | repo (recommended) |
| `templates/review-agent.md` | `.claude/agents/ship/review-<name>/review-<name>.md` | recurring risk |

The templates carry the structure and the reasoning behind each section; this file
only covers what they cannot know.

### ship.md

A **config, not a manual.** Anything that is an agent's own behaviour belongs in
that agent's file. The template's sections are the full set — delete what the repo
does not need rather than inventing new ones.

Two sections are worth more care than the rest, because they are the expensive
ones to get wrong: **Commands** (name explicitly any suite that must never run
automatically — e2e, golden, anything hitting live endpoints or paid APIs) and
**Delivery** (what happens when a finding is blocking).

If the repo already documents its tracker somewhere, **`ship.md` points at that
file and states only the `/ship` policy** — when to look for an issue, when to
create one, which statuses to set, how the key reaches the branch and PR. Copying
the tracker's command reference into `ship.md` is duplication that goes stale;
the config says *what this repo wants*, the tracker doc says *how to do it*. If no
such doc exists, keep the commands in `ship.md` but stay minimal.

### docs-engineer

Every repo gets one, and it is the **only** agent with write access — the one place
`Write`/`Edit` appear in a `tools` line. Fill its writable-paths table from what
step 1 found about where docs live. The `map/` section is optional: keep it only if
the repo actually has a `map/` code map, delete the whole block otherwise.

### Reviewers

One folder each, under the namespace so they stay clear of the repo's
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
