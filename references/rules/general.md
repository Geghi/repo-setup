# General rules

Rules that fit any repo, whatever its architecture. Format and usage: [README.md](README.md).
Each entry: problem → check. The example is reference only; re-design per repo.

## Tests never touch a hosted environment
- **Problem:** an integration/e2e run with a misconfigured env deletes or writes real rows.
- **Applies when:** tests create or delete data in a DB or external service.
- **Check:** the test env loader asserts the DB/API URL is local (localhost, docker host) and aborts otherwise; a unit test covers the guard.
- **Example:** igea-saas `tests/unit/test-env-local-guard.test.ts` (`assertLocalSupabaseUrl`).

## No real secret in tracked example env files
- **Problem:** someone regenerates `.env.example` from a hosted project and commits a production key.
- **Applies when:** the repo tracks an env example with credential-shaped values.
- **Check:** pre-commit script on the staged file: values must match the known public/local defaults.
- **Example:** igea-saas `scripts/check-test-env-example.mjs`.

## One import style
- **Problem:** relative imports (`../../x`) break on moves and hide module boundaries.
- **Applies when:** the language/bundler supports a path alias.
- **Check:** lint ban on relative imports (ESLint `no-restricted-imports` + a `no-restricted-syntax` selector for dynamic `import("./x")`), plus a test that the rule stays in every config block that overrides it.
- **Example:** igea-saas `eslint.config.mjs`, `tests/unit/eslint-no-relative-imports.test.ts`.

## Size and complexity caps
- **Problem:** files and functions grow until nobody (human or agent) can read them whole.
- **Applies when:** always; tune limits to the repo.
- **Check:** lint caps on file lines, function lines and cognitive complexity (ESLint `max-lines`, `max-lines-per-function`, `sonarjs/cognitive-complexity`; Ruff `C901`/`PLR0915` in Python), warn tier below error tier.
- **Example:** igea-saas `eslint.config.mjs` (800 lines/file, complexity warn 10 / error 15).

## No stray console output
- **Problem:** `console.log` debugging ships to production and bypasses the logger.
- **Applies when:** the repo has a logger.
- **Check:** lint `no-console: error` in source, off in scripts.
- **Example:** igea-saas `eslint.config.mjs`.
