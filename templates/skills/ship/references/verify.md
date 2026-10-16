# Verify

Reviewers read the diff; verifiers run the code and use it.
How to run and drive this repo lives in its recipe, `.agents/verify.md`: this file is only the flow.

## Recipe

Written once at setup (repo-setup's ship phase).
Missing → skip verify and report "no verify recipe: run the ship setup".
The recipe says there is nothing to run → skip verify.
The diff changed how the code starts or is reached (scripts, env vars, ports, routes, auth) → open finding: update `.agents/verify.md`.

## Launch

`verifiers` from `ship.md` (default 1); the user can override per run.
Launch them in a single message as `general-purpose` subagents, prompt = the whole of `references/verifier.md`, plus: the intent, the base branch, the changed-file list, its port (recipe's port + its index) and its angle (the recipe's list, in order; with one verifier, the first two).

The recipe lists gates (e.g. Lighthouse, ZAP) → tell the first verifier to run them.

## Fix

As in step 4: commit (`fix: address verify findings`), re-run step 5, then re-run only the verifiers whose angle found something.
Max 2 rounds; anything unresolved stays open, with its reproduce steps.
