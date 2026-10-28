# Phase 3 — Testing & TDD

Goal: the repo has (a) the non-negotiable TDD rule in CLAUDE.md, (b) a `tdd`
skill for the red-green-refactor loop, (c) the generic `testing` skill (rules)
plus `docs/agents/testing.md` (this repo's layers, commands, folders).

## 1. Discover the stack

Inspect the repo (package.json / pyproject.toml / go.mod, existing test config,
CI). Then confirm with the user:
- Test runner(s) and commands per layer (unit / integration / e2e / other).
- Integration backing services: for Supabase projects the local stack via
  `pnpm exec supabase start` + `.env.test` (+ pgTAP as a security layer, like
  a Next.js + Supabase repo); for other stacks ask what "real dependencies" means (docker
  compose db, testcontainers, none).
- Trophy shape is the default: fat integration middle, thin E2E top, unit for
  pure logic. Layer decision rule: DB/state involved → integration; needs a
  browser to fail → E2E; otherwise unit.

## 2. Install the skills

- **tdd**: copy `templates/skills/tdd/` and `templates/skills/codebase-design/`
  (tdd calls it) → `.claude/skills/`. Generic, no placeholders.
- **testing**: copy `templates/skills/testing/` → `.claude/skills/testing/`. Generic, no placeholders.
  Then copy `templates/docs/agents/testing.md` → `docs/agents/testing.md` and fill it with the answers from step 1.
  For stacks with extra layers (e.g. pgTAP), add a row and its one-line use.

## 3. CLAUDE.md

The template already has the TDD line. Nothing to add.

## 4. Evidence

Ask the user what a person sees or hears from this repo, since that sets the proof:
- UI (web/mobile) → screenshots or a recording of the main path (`{{LEVEL2_PROOF}}`).
- Voice/call flow → an audio recording or the call transcript.
- Backend/API only, CLI, library → no level 2: delete the Livello 2 section, the
  proof stops at a real request/response or command output (`{{LEVEL1_PROOF}}`).
- Generated files (PDF, email, images) → the produced file attached.
Then ask for the main path to show (`{{MAIN_PATH}}`).

Copy `templates/docs/agents/evidence.md` → `docs/agents/evidence.md` and fill
every `{{PLACEHOLDER}}` with those answers and the commands from step 1. Ship
reads it to decide what proof goes in the PR. Reference example of a filled
version: a Python agent repo's `docs/agents/evidence.md`.

## 5. Wire-up

- If a `tests/` folder exists, add a 3-line `tests/AGENTS.md` pointing at the
  `testing` skill and `docs/agents/testing.md` (don't duplicate).
- Ensure the test commands land in CLAUDE.md's Commands section and, if the
  ship phase ran, in `.agents/ship.md`'s Commands section.

## 6. Guardrail hooks (pre-commit)

The repo's gate runs from pre-commit.
Two rules apply to every repo set up here:

- **complexipy reports failures only.**
  Run it as `complexipy -f` (`--failed`) in the pre-commit hook, in CLAUDE.md's Commands and in `.agents/ship.md`.
  Without `-f` it prints every function and the one that failed is lost in the output.
- **Deps follow the lockfile.**
  A rebased or freshly checked-out worktree with stale `node_modules` or `.venv` fails the gate for no code reason.
  Copy `templates/scripts/sync-deps.sh` → `scripts/sync-deps.sh` and keep one `sync <lockfile> <install command>` line per lockfile (`npm ci`, `uv sync`, ...).
  It re-runs the install only when the lockfile's hash differs from the one stamped in this worktree's git dir.
  Wire it into `.pre-commit-config.yaml`:

  ```yaml
  default_install_hook_types: [pre-commit, post-checkout, post-rewrite]
  default_stages: [pre-commit]
  repos:
    - repo: local
      hooks:
        - id: sync-deps
          name: re-install deps when a lockfile changed
          entry: scripts/sync-deps.sh
          language: system
          pass_filenames: false
          always_run: true
          stages: [post-checkout, post-rewrite]
  ```

  `default_stages` keeps the gate hooks off checkout and rebase.
  Re-run `pre-commit install` once so the two new hook types are installed.
  Check: change the lockfile on a branch, `git checkout` it, the install runs; check out again with no lockfile change, it does not.
