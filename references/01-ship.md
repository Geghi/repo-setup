# Phase 1 — ship

Goal: the repo has a working `/ship` pipeline (`.agents/ship.md` + reviewer agents).

1. Copy `templates/skills/ship/` → `.claude/skills/ship/` and
   `templates/skills/pr/` → `.claude/skills/pr/`. Ship writes the PR body with
   `pr`; the full ship report stays in the terminal.
2. If `.agents/ship.md` already exists, stop here ("ship already initialized";
   revisit only if asked). Otherwise run the ship guided setup: read `.claude/skills/ship/references/init.md`
   and follow it exactly (investigate → conversation → write `.agents/ship.md`
   and `.claude/agents/ship/…` reviewers). That file is the single source of
   truth for this phase — do not duplicate its logic here.

Notes for the conversation (my defaults, still confirm):
- Delivery: push + PR always, body from the `pr` skill template (Summary /
  Evidence / Merge Danger); blocking findings → draft PR titled `[BLOCKED]`,
  findings + fix plan under Merge Danger.
- Ask explicitly for the base/working branch — never assume the git default.
- The pipeline itself (in the skill, no per-repo config): rebases onto the base
  branch before review, fixes mechanical `blocking` findings itself and re-runs
  every reviewer fresh, max 2 rounds; intent/product findings are never fixed.
  Only `ship.md`'s base branch feeds this — make sure it is the branch the team
  integrates on (e.g. `test`), not the release branch.
