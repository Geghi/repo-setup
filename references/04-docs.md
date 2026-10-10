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
   `path:line`, never copy code; dead/aspirational code marked `ghost`).
4. It is fine to stop after slice 1–2 (structure + object stubs) and leave
   remaining cards as incremental work — say so in the closing summary.
5. Fill the map placeholders from section 2 (the map itself lives in
   `map/CLAUDE.md`).
