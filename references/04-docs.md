# Phase 4 — Docs & code map

Goal: the repo has the standard documentation skeleton and, for existing
codebases, a "System map" for agents (Van Clief's icm-architect form).

## 1. Documentation skeleton

- Create `docs/adr/`, `docs/prd/`, `docs/agents/` (empty dirs are
  fine; `.gitkeep` if needed).
- Copy `templates/skills/{grill-with-docs,grilling,domain-modeling,improve-codebase-architecture}/`
  → `.claude/skills/` — they create and maintain `CONTEXT.md` and ADRs.
  `improve-codebase-architecture` also needs `codebase-design` (phase 03).
- **Coding standards**: copy `templates/CODING_STANDARDS.md.template` →
  `CODING_STANDARDS.md` (repo root). Fill it from the scan — conventions the
  code already follows consistently (helpers everyone uses, error/logging
  shape, API contract, auth pattern) — and confirm with the user. Existing repo:
  move code-writing rules out of `CLAUDE.md` into it, leave a pointer. New repo
  with nothing to infer: one placeholder-free section or none; it grows lazily.
- Prose docs (`CONTEXT.md`, `CODING_STANDARDS.md`, `docs/agents/`) are one short sentence per line, so parallel branches rebase without conflicts.
- Copy format guides into `docs/agents/`:
  - `templates/adr/ADR-FORMAT.md` → `docs/agents/adr-format.md`
  - `templates/adr/CONTEXT-FORMAT.md` → `docs/agents/context-format.md`
- **Lazy creation rule** (the template's table already says it): `CONTEXT.md`,
  ADRs and PRDs are created when first needed, never pre-filled with invented
  content. PRDs: `docs/prd/YYYY-MM-DD-<slug>.md`.

## 2. CLAUDE.md

Repo has a map → fill the template's `{{MAP_RULE_LINE}}` and `{{MAP_ROW}}`.
No map → delete both. Nothing else.

## 3. System map (existing repos only)

Skip entirely for new/empty repos — never invent cards for code that doesn't
exist. For an existing codebase:

1. Read `templates/map/system-map.md` (vendored verbatim from
   RinDig/icm-architect — see `templates/map/ATTRIBUTION.md`) and follow its
   slice pipeline. **Slice 0 is mandatory and gated**: present the inventory and
   proposed clusters, get explicit approval before writing anything.
2. Card templates: copy `templates/map/_templates/` into the target `map/_templates/`.
3. Respect its budgets (entry 300–800 tokens, CONTEXT 200–500, cards cite
   `path::symbol` (never a line number where a symbol exists), never copy code; dead/aspirational code marked `ghost`).
4. It is fine to stop after slice 1–2 (structure + object stubs) and leave
   remaining cards as incremental work — say so in the closing summary.
5. Add an architecture test that fails on a citation whose file is gone or
   whose symbol is no longer defined (reference:
   `prospector/backend/tests/architecture/test_map_citations.py`).
6. `map/AGENTS.md` and `map/routing.md` are symlinks to `map/CLAUDE.md`, never `cp` copies: `ln -s CLAUDE.md map/AGENTS.md && ln -s CLAUDE.md map/routing.md`.
   A copy drifts the first time someone edits `CLAUDE.md` and forgets the twins.
   Add an architecture test that fails unless both are symlinks resolving to `map/CLAUDE.md`.
7. Map updates are proportional to the change.
   A change that only adds or renames symbols updates the `path::symbol` citations and nothing else.
   Prose (why, Hits / Does not hit, steps) is rewritten only when behaviour changes.
   Write this rule into `map/CLAUDE.md` and the ship docs engineer.
8. Cards and map entry files are one sentence per line, like every prose doc.
9. Fill the map placeholders from section 2 (the map itself lives in
   `map/CLAUDE.md`).
