# Workflow rules

How to work in this repo. Linked from [CLAUDE.md](../../CLAUDE.md).

- **Dev server** — never run it without asking first.
- **Git stash** — always named: `git stash push -u -m "<name>"` /
  `git stash pop "stash^{/<name>}"`. Never bare stash/pop.
- **Env vars** — only read/edit `.env.example`. Never read `.env.local`.
- **Docs hygiene** — delete it in the code, delete it in the docs: no doc names a
  symbol, file or route that no longer exists. Only `docs/adr/` and `docs/prd/`
  keep history.
- **Prose docs** — one sentence per line (`CONTEXT.md`, map cards, `docs/agents/`), so parallel branches rebase without conflicts.
- **Stale deps** — the post-checkout / post-rewrite hook re-runs the install when a lockfile changed; after a rebase never "fix" a gate failure by hand before it has run.

## Layout

{{ANNOTATED_TREE_OF_TOP_LEVEL_DIRS}}

{{REPO_SPECIFIC_WORKFLOW_RULES — how to work here, never how to write code. Delete if none.}}
