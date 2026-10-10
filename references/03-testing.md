# Phase 3 — Testing & TDD

Goal: the repo has (a) the non-negotiable TDD rule in CLAUDE.md, (b) a `tdd`
skill for the red-green-refactor loop, (c) a repo-specific `testing` skill that
is the single source of truth for layers, commands and rules.

## 1. Discover the stack

Inspect the repo (package.json / pyproject.toml / go.mod, existing test config,
CI). Then confirm with the user:
- Test runner(s) and commands per layer (unit / integration / e2e / other).
- Integration backing services: for Supabase projects the local stack via
  `pnpm exec supabase start` + `.env.test` (+ pgTAP as a security layer, like
  igea-saas); for other stacks ask what "real dependencies" means (docker
  compose db, testcontainers, none).
- Trophy shape is the default: fat integration middle, thin E2E top, unit for
  pure logic. Layer decision rule: DB/state involved → integration; needs a
  browser to fail → E2E; otherwise unit.

## 2. Install the skills

- **tdd**: `npx skills add mattpocock/skills --skill tdd` (installs into
  `.agents/skills/tdd/`, symlinks `.claude/skills/tdd`, records it in
  `skills-lock.json`). Generic — never edit it; it reads `GLOSSARY.md`, which
  in our repos is `CONTEXT.md`, and that's fine.
- **testing**: copy `templates/skills/testing/SKILL.md` →
  `.claude/skills/testing/SKILL.md` and fill every `{{PLACEHOLDER}}` with the
  answers from step 1. The non-negotiable rules section is copied verbatim —
  never weaken it. For stacks with extra layers (e.g. pgTAP), add a row and a
  short section; use igea-saas' testing skill as the reference example of a
  fully filled version.

## 3. CLAUDE.md block (verbatim, Italian)

Append under Mandatory rules:

```md
**TDD — non negoziabile.** Ogni modifica (feature, fix, refactor) va fatta con
approccio test-driven: scrivi il test che fallisce prima del codice, poi
implementa fino a farlo passare. Usa sempre la skill `tdd` per il ciclo
red-green-refactor e la skill `testing` per scegliere il layer giusto e le
convenzioni dei test. Nessuna modifica va considerata completa senza la
copertura di test corrispondente.
```

## 4. Evidence

Copy `templates/docs/agents/evidence.md` → `docs/agents/evidence.md` and fill
every `{{PLACEHOLDER}}` with the real commands and main path from step 1. Ship
reads it to decide what proof goes in the PR. Reference example of a filled
version: igea-livekit-agent's `docs/agents/evidence.md`.

## 5. Wire-up

- If a `tests/` folder exists, add a 3-line `tests/AGENTS.md` pointing at the
  `testing` skill (single source of truth, don't duplicate).
- Ensure the test commands land in CLAUDE.md's Commands section and, if the
  ship phase ran, in `.claude/ship.md`'s Commands section.
