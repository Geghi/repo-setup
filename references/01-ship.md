# Phase 1 — ship

Goal: the repo has a working `/ship` pipeline (`.claude/ship.md` + reviewer agents).

1. If `.claude/ship.md` already exists in the target repo, report "ship already
   initialized" and stop this phase (offer to revisit it only if the user asks).
2. Check the ship skill is installed: `~/.claude/skills/ship/SKILL.md` must exist.
   If missing, have the user install it first:
   ```bash
   git clone https://github.com/Geghi/ship ~/virtual_desktop/projects/shared-agents/ship
   ln -s ~/virtual_desktop/projects/shared-agents/ship ~/.claude/skills/ship
   ```
3. Install the `pr` skill: `npx skills add mattpocock/skills --skill pr`
   (into `.agents/skills/pr/`, symlinked from `.claude/skills/pr`). Ship writes
   the PR body with it; the full ship report stays in the terminal.
4. Run the ship guided setup: read `~/.claude/skills/ship/references/init.md`
   and follow it exactly (investigate → conversation → write `.claude/ship.md`
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
