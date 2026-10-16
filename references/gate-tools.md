# Gate tools catalogue

Extra automated gates the ship setup can propose.
Propose only those whose signal the repo shows, the 2–4 most valuable first, each with one line on what it would catch here.
The user picks; nothing is added by default.
Configure each to exit non-zero on findings (e.g. `semgrep --error`, `pip-audit --strict`): one that only prints problems passes silently.

Where a picked tool goes:

- **static** (no running app) → a line under `.agents/ship.md` Commands; fast ones also in pre-commit.
- **runtime** (needs the app up) → `.agents/verify.md` Gates, with a pass threshold.
- **slow** (minutes, flaky, or costly) → a scheduled CI job, never `/ship`.

| Signal in the repo | Tool | Kind | Catches |
|---|---|---|---|
| Public website, landing pages | Lighthouse CI (`lhci autorun`) | runtime | performance, SEO, accessibility regressions against a budget |
| Any UI | axe-core / pa11y | runtime | accessibility violations |
| Frontend bundle | size-limit | static | bundle size creeping past a budget |
| Postgres functions, RLS, triggers | pgTAP | static | broken SQL logic and row-level security, tested in the DB |
| SQL migrations | squawk | static | migrations that lock tables or break running code |
| Web app or API exposed to users | OWASP ZAP baseline | runtime | missing security headers, cookie flags, common web vulns |
| Any code | semgrep | static | insecure patterns (injection, unsafe deserialisation, …) |
| Any repo | gitleaks | static | committed secrets |
| Dependencies | osv-scanner / `npm audit` / `pip-audit` | static | known-vulnerable packages |
| Dockerfile, IaC | trivy, hadolint, checkov | static | vulnerable images, misconfigured infra |
| OpenAPI spec | schemathesis | runtime | endpoints crashing or breaking their own spec on generated inputs |
| OpenAPI spec | oasdiff | static | breaking API changes against the base branch |
| JS/TS | knip | static | dead files, exports, dependencies |
| JS/TS | dependency-cruiser | static | forbidden imports between layers |
| Python | import-linter | static | forbidden imports between layers |
| Python | vulture | static | dead code |
| Shell scripts | shellcheck | static | shell bugs |
| GitHub Actions | actionlint | static | broken workflows |
| Strong test suite already | Stryker / mutmut | slow | tests that pass without checking anything |

Not in the list but clearly fitting the repo (a framework's own linter, a domain validator) → propose it too.
