# templates/skills

| Skill | Phase | Source | Placeholders |
|---|---|---|---|
| `testing/` | 03-testing | ours | yes — fill from the stack scan |
| `to-tickets/` | 02-tracker | mattpocock/skills (glossary → `CONTEXT.md`) | none |
| `triage/` | 02-tracker | mattpocock/skills (glossary → `CONTEXT.md`) | none |

Copied as-is (no placeholders), into `.claude/skills/<name>/`:

| Skill | Phase | Source |
|---|---|---|
| `tdd/` | 03-testing | mattpocock/skills (glossary → `CONTEXT.md`) |
| `ship/` | 01-ship | ours (formerly global `~/.claude/skills/ship`) |
| `pr/` | 01-ship | mattpocock/skills (glossary → `CONTEXT.md`) |
| `codebase-design/` | 03-testing | mattpocock/skills, needed by `tdd` (glossary → `CONTEXT.md`) |
| `grill-with-docs/` | 04-docs | mattpocock/skills — wrapper, calls the two below |
| `grilling/` | 04-docs | mattpocock/skills |
| `domain-modeling/` | 04-docs | mattpocock/skills (glossary → `CONTEXT.md`) |
| `improve-codebase-architecture/` | 04-docs | mattpocock/skills, needs `codebase-design` + `grilling` + `domain-modeling` (glossary → `CONTEXT.md`) |
