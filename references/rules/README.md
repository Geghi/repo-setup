# Automated rules catalogue

Generic good practices enforced by a check (test, lint rule, type guard), not by review.
Each rule is a pattern: the example comes from one repo and must be re-designed for the target repo (paths, helpers, exemptions).

## When to use it

- At setup: after the phases, scan the repo, propose the rules whose "Applies when" holds, add only the ones the user picks.
- At a version update: when `changelog/vN.md` adds a rule, run the same check for that rule only.
- In any repo: a new check that would hold elsewhere too → propose adding it here.

## Where to look

Pick the files that match the repo's architecture; a repo can match several.

- Every repo → [general.md](general.md)
- Has a server / API layer (route handlers, controllers, RPC) → [backend.md](backend.md)
- Has a UI (React, Vue, Svelte, mobile) → [frontend.md](frontend.md)

New architecture (CLI, data pipeline, mobile, infra) → add a file and a line here.

## How to apply a rule

1. Check "Applies when" against the repo; skip silently if it doesn't hold.
2. Grep the repo for current occurrences; show the user the count and a few examples.
3. Ask: add the rule? The user picks, never auto-add.
4. Yes → write the check red first (it must fail on the occurrences found, or on a planted one if there are none), fix or exempt each occurrence with a reason, then green.
5. Add one line to the repo's `CODING_STANDARDS.md` naming the rule and its check.

## Rule format

Each rule in a file is a `##` section with:

- **Problem:** the bug class, one sentence.
- **Applies when:** what to look for in the repo.
- **Check:** preferred mechanism, then the fallback.
- **False positives:** where they come from, how to exempt.
- **Example:** where and how it was done, marked "reference only, re-design per repo".
