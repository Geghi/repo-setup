# Issue tracker: Multica (CLI)

Issues and PRDs for {{PROJECT_NAME}} live in **Multica**, accessed through the
`multica` CLI (local daemon, see `multica --help`). There is **one shared
{{PROJECT_NAME}} project** for all repos; repos are distinguished by a
**project label**. For this repo the project label is **`{{REPO_LABEL}}`**.

- Project: **{{PROJECT_NAME}}** — id `{{PROJECT_ID}}`
- Issue keys: `{{ISSUE_PREFIX}}-NN`
- Output: every command accepts `--output json`

## Commands the skills use

```bash
# Create (title required; description via stdin to preserve markdown)
multica issue create --title "..." --project {{PROJECT_ID}} \
  --description-stdin < body.md
# Sub-issue: add --parent <parent-id>; ordered barrier groups via --stage N

# Labels (additive — no wholesale-replace footgun)
multica issue label add <issue> <label>
multica issue label remove <issue> <label>

# Read / find
multica issue get <issue> --output json
multica issue list --project <id> --output json
multica issue search "<text>" --output json

# Comment
multica issue comment --help   # subcommands for add/list

# Status — valid: backlog, todo, in_progress, in_review, done, blocked, cancelled
multica issue status <issue> <status> --no-start
```

> ⚠️ **Always pass `--no-start` on status changes during triage.** A status
> change can otherwise enqueue an agent run on the issue's assignee. Same
> caution with `--assignee` on create: assigning can start work.

## Labels

Existing workspace labels (don't create new ones without asking):

- **Project labels** (repo binding): `{{REPO_LABEL}}`{{SIBLING_LABELS}}
- **Triage roles**: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`
- **Category**: `Bug`, `enhancement`, `Improvement`

Every issue carries one project label (`{{REPO_LABEL}}` for this repo) plus
category/triage labels as needed.

## Conventions

- **Create an issue**: `multica issue create` with the {{PROJECT_NAME}} project
  id, a title, a Markdown description, then `multica issue label add` for
  `{{REPO_LABEL}}` + category/triage labels.
- **Ignore done/cancelled issues by default** when listing or triaging, unless
  explicitly asked about closed work.
- **Closing issues**: set status `done`; for `wontfix` set status `cancelled`
  (always with `--no-start`). See `docs/agents/triage-labels.md`.
- **Blocking relations**: no first-class blocks/blocked-by link — model ordered
  work as sub-issues with `--stage N` under a parent, or set status `blocked`
  and name the blocker in the description.

## PR linking

The webhook links a PR to an issue when a routable key (`{{ISSUE_PREFIX}}-NN`)
appears in the PR **title, body, or branch**. Close-on-merge requires the key
immediately after a closing keyword in title or body (`Closes {{ISSUE_PREFIX}}-42`,
`Fixes …`, `Resolves …`); a bare mention links without closing.
`multica issue pull-requests <issue>` reads back the linked PRs and their state.

## Cross-repo issues

This repo is `{{REPO_LABEL}}`, but you may create issues for sibling repos when
the work belongs there, and split cross-repo work into a parent + per-repo
sub-issues (one project label per issue).

## When a skill says "publish to the issue tracker"

Create a Multica issue in the {{PROJECT_NAME}} project with the `{{REPO_LABEL}}` label.

## When a skill says "fetch the relevant ticket"

`multica issue get <issue> --output json`, then the comment list for its discussion.
