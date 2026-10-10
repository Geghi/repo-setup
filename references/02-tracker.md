# Phase 2 — Issue tracker (Multica)

Goal: the repo is wired to my self-hosted Multica (local Docker, frontend :3090,
backend :8090) and documents how agents track issues there.

## 1. Machine prerequisites (one-time, verify then guide)

```bash
multica --version          # CLI installed?
multica workspace list --output json   # profile + login working?
```

If the CLI is missing or not logged in, guide the user (these are their actions):

```bash
curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash
multica setup self-host --profile local --server-url http://localhost:8090
multica login              # creates a PAT in ~/.multica/config.json
```

Suggest (optional, user action in Claude Code): `/plugin marketplace add multica-ai/multica-cli`
then `/plugin install multica-cli@multica-cli`.

## 2. Workspace / project / label

Multica model: **workspace → project (links multiple GitHub repos as resources)
→ issues**. My pattern: one project per product, one **project label per repo**
(e.g. `FRONTEND`, `BACKEND`).

Ask:
- Is this repo part of an existing product/project? → `multica workspace list`,
  list projects, pick one; agree on a new **repo label** (uppercase, short).
- New product? → create the project in the Multica UI or CLI (name = product),
  note its project id and issue key prefix.
- Then add this repo as a **resource** of the project (Multica UI → project →
  resources; link the GitHub repo with its default branch).

Record: project name, project id, issue key prefix (e.g. `IGEA`), repo label.

## 3. Generate the docs

Copy and fill (`{{PROJECT_NAME}}`, `{{PROJECT_ID}}`, `{{ISSUE_PREFIX}}`,
`{{REPO_LABEL}}`, `{{SIBLING_LABELS}}`):

- `templates/docs/agents/issue-tracker.md` → `docs/agents/issue-tracker.md`
- `templates/docs/agents/triage-labels.md` → `docs/agents/triage-labels.md`

Ensure the workspace has the triage labels (`needs-triage`, `needs-info`,
`ready-for-agent`, `ready-for-human`) and the repo label; create missing ones
only after asking.

## 4. Install the tracker skills (mandatory — the docs alone are inert)

The docs above describe the tracker; these two skills are what *use* it.
Copy verbatim (no placeholders) into `.claude/skills/`:

- `templates/skills/to-tickets/` → `.claude/skills/to-tickets/` — plan/spec/conversation → tracer-bullet tickets with blocking edges
- `templates/skills/triage/` → `.claude/skills/triage/` (+ `AGENT-BRIEF.md`, `OUT-OF-SCOPE.md`) — triage state machine, agent briefs, `.out-of-scope/`

They speak in canonical roles (`needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`, `bug`, `enhancement`); `docs/agents/triage-labels.md`
is the mapping they read. If the workspace uses different category labels (e.g.
`Feature` instead of `enhancement`), add a **Category → label** row to that doc.
`triage` step 4 calls `grilling` + `domain-modeling`, installed by phase 04. Both skills say "run `/setup-matt-pocock-skills`" if the tracker config is missing — ignore that: this phase is the setup, and the CLAUDE.md "issues / triage" row is how they find it.

## 5. CLAUDE.md

Fill the template's "issues / triage" row; nothing else.

## Safety rules (bake into every generated doc)

- Always `--output json`.
- Always `--no-start` on status changes during triage; careful with `--assignee`
  on create and @-mentions in comments — both can enqueue paid agent runs.
