# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those
roles to **Multica**, the issue tracker for this repo. See `docs/agents/issue-tracker.md`.

> **Triage labels are separate from project labels.** The project label
> (`{{REPO_LABEL}}` for this repo) records which codebase an issue belongs to
> and is always applied on create. Triage labels below track the issue's
> workflow role. An issue typically carries one project label plus a triage role.

## Role → Multica mapping

| Role (in skills)  | Multica                | Meaning                                  |
| ----------------- | ---------------------- | ---------------------------------------- |
| `needs-triage`    | `needs-triage`         | Maintainer needs to evaluate this issue  |
| `needs-info`      | `needs-info`           | Waiting on reporter for more information |
| `ready-for-agent` | `ready-for-agent`      | Fully specified, ready for an AFK agent  |
| `ready-for-human` | `ready-for-human`      | Requires human implementation            |
| `wontfix`         | **`cancelled` status** | Will not be actioned                     |

Four of the roles are Multica **labels** applied via
`multica issue label add <issue> <label>`. The fifth, `wontfix`, is expressed by
setting the issue's **status to `cancelled`**:

```bash
multica issue status <issue> cancelled --no-start
```

Always pass `--no-start` when changing status during triage, so the change never
enqueues an agent run. Labels are additive (`label add` / `label remove`) —
there is no wholesale-replace footgun on update.
