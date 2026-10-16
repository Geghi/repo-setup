# repo-setup

- Every change here is versioned: add a `## vN — YYYY-MM-DD` entry on top of `CHANGELOG.md` saying what changed and how a set-up repo catches up:
  - a verbatim file changed (`templates/skills/*`) → "copy X over Y";
  - a template changed → what changed and why, so the repo's filled copy can be adapted where it makes sense for that repo (never "re-copy the template");
  - a new template → "fill X into Y, as in `references/0N-*.md`".
- Set-up repos pull changes from this checkout via `/ship`, and other machines via `git pull`: after any edit, ask the user to commit and push. Never leave changes here uncommitted.

## Where things go

- `templates/skills/*` is copied verbatim into every repo: nothing repo-specific, nothing only setup needs.
- Repo-specific content is a template under `templates/` with `{{PLACEHOLDERS}}`, filled once at setup.
- Setup logic (investigate, ask, fill templates) lives in `references/0N-*.md`, one file per phase, never inside a skill.
- A skill never does setup work at runtime: config missing → say so and stop.
- Don't assume the app type (UI, API, CLI, library) in generic files: that belongs in the repo's filled template.

## Writing skills and agents

- One rule, one owner. Before adding a line, check whether it already lives elsewhere; point to it instead of restating it.
- A skill orchestrates; an agent's behaviour lives in its own file; a repo config holds only facts that differ per repo.
- Agent files are self-contained: each names everything it needs (output contract, rules) and its whole file is its prompt. Never rely on the orchestrator to pass it.
- Paths an agent reads are repo-root paths as installed (`.claude/skills/<skill>/...`), never relative to this repo.
- Name another skill's concept in one place only (e.g. the `pr` skill's Merge Danger, only in ship's deliver step).
- Agent output: hard limits (fields, word counts), not "be concise".
- Trim: instructions, not justifications. One short sentence per line.
