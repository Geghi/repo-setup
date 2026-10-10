# repo-setup — Giacomo's standard repository setup

Orchestrator that brings any repository (new or existing) to my standard setup.

It is repo-unaware: everything repo-specific is asked interactively or inferred
by scanning. Each phase is self-contained and re-runnable on its own — the user
can say "run only the docs phase".

## How to run

1. **Locate the target repo.** You must be in (or be told) the root of a git
   repository. If not in one, ask for the path. Never set up this skill's own repo.
2. **Detect new vs existing.** Existing = has source code beyond scaffolding.
   Also note per-phase state: `.claude/ship.md` present? `docs/agents/issue-tracker.md` + `.claude/skills/triage/`
   present? `CLAUDE.md` present? tests configured? `docs/agents/evidence.md` present? A phase already done is skipped
   unless the user asks to redo it.
3. **Confirm phases.** Default: all four, in order. Ask once, up front, which to run:
   - **ship** → `references/01-ship.md`
   - **tracker (Multica)** → `references/02-tracker.md` (docs + the `to-prd`/`to-issues`/`triage` skills)
   - **testing/TDD** → `references/03-testing.md`
   - **docs + code map** → `references/04-docs.md`
4. **Run each selected phase** by reading its reference file (paths relative to
   this skill's directory) and following it. Ask questions phase by phase, a few
   at a time — not a wall up front.
5. **CLAUDE.md**: phases append their blocks to the target repo's `CLAUDE.md`.
   If the repo has none, first create it from `templates/CLAUDE.md.template`
   (fill Project/Commands/Layout from the scan or by asking). If one exists,
   merge: never overwrite existing content, add only the missing standard blocks.
   Also copy `templates/AGENTS.md` if the repo has no `AGENTS.md`.
6. **Close with a summary**: what was created/changed, what remains manual
   (e.g. `multica login`, plugin install, creating the GitHub repo/remote).

## Conventions

- Templates live in `templates/` next to this file. Copy with `cp`, then fill
  the `{{PLACEHOLDERS}}`. Never leave a placeholder unfilled in the target repo.
- All generated docs are English; keep the TDD rule block in Italian (it is
  quoted verbatim from the template).
- Never commit in the target repo unless asked; list the created files instead.
