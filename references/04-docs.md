# Phase 4 — Docs & code map

Goal: the repo has the standard documentation skeleton and, for existing
codebases, a "System map" for agents (Van Clief's icm-architect form).

## 1. Documentation skeleton

- Create `docs/adr/`, `docs/prd/`, `docs/agents/`, `changelog/` (empty dirs are
  fine; `.gitkeep` if needed).
- Copy format guides into `docs/agents/`:
  - `templates/adr/ADR-FORMAT.md` → `docs/agents/adr-format.md`
  - `templates/adr/CONTEXT-FORMAT.md` → `docs/agents/context-format.md`
- **Lazy creation rule** (state it in CLAUDE.md's Agent workflows): `CONTEXT.md`,
  ADRs and PRDs are created when first needed, never pre-filled with invented
  content. PRDs: `docs/prd/YYYY-MM-DD-<slug>.md`. Changelog: after any code
  change, write `changelog/{datetime}_{title}.md`.

## 2. CLAUDE.md block

Append to Agent workflows:

```md
- Domain docs: `CONTEXT.md` (glossary, see `docs/agents/context-format.md`),
  `docs/adr/` (see `docs/agents/adr-format.md`) — created lazily
- Changelog — after any code change, write `changelog/{datetime}_{title}.md`
- Code map (existing repos only): `map/` is how you *navigate* the repo —
  start at `map/CLAUDE.md` (clusters, flows, name collisions) to find where
  something lives before grepping `src/`; open cards only when needed.
  Keeping it true is part of every change: when you change code, update in
  the same change every map card that cites or describes that code (fix the
  `path:line` citations, flows, names), or mark it `stale` if you can't.
```

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
5. Add the Code map block from section 2 to the repo's CLAUDE.md (the map
   catalog itself lives in `map/CLAUDE.md`).
