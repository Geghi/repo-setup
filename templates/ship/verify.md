<!--
TEMPLATE — the repo's verify recipe. Copy to `.agents/verify.md`, fill every {{PLACEHOLDER}}, delete what doesn't apply, delete this comment.
Nothing runnable here (a library, pure config)? Replace the whole file with: "Nothing to run: verify is skipped."
-->

# Verify recipe — {{repo-name}}

## Run

- Start: `{{pnpm dev}}` — port `{{3000}}`, override with `{{PORT=<n>}}`
- Env and seed data: {{.env.example → .env.local, `pnpm db:seed`}}
- Test credentials: {{where they are — never real accounts}}
- Stop: {{Ctrl-C / `docker compose down`}}

## Drive

{{How a verifier exercises it, e.g. "`chrome-devtools-axi` on http://localhost:<port>", "`curl` against /api/*", "run `mycli <cmd>`", "enqueue a job with …"}}

## Angles

One per verifier, in this order:

1. The changed flow, happy path, end to end.
2. Edge inputs on it: {{empty, very long, wrong type, missing auth, repeated calls, …}}
3. Adjacent flows that share the changed code.
4. {{Repo-specific: phone width and slow network for a UI, concurrent calls for an API, …}}

## Gates

{{Extra gates picked at setup that need the app running, run once per ship by the first verifier, each with its pass threshold, e.g. "`npx lhci autorun` — performance ≥ 0.9", "ZAP baseline on http://localhost:<port> — no High alerts". Delete if none.}}

## Evidence

{{What proves a check: a screenshot or short recording for a UI; the request and response, or the command output, for a backend or CLI.}}

## Never

{{Hit production, send real emails/SMS, charge cards, … Delete if none.}}
