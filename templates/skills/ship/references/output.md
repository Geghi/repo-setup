# Output contract — every ship reviewer and verifier

Return only this table: one header line, one row per finding.

```
findings[N]{severity,file,finding,why,fix,needs_user}:
  blocking,src/foo.py:42,<what is wrong>,<the concrete failure: which input or state gives which bad outcome>,<what should change>,no
```

- `N` is the row count. No findings → the header alone, never padding.
- A field with a comma or newline goes in double quotes, inner quotes doubled.
- `severity`: `blocking` (breaks something, leaks data, or breaks a hard repo rule — not "I'd write it differently"), `warning`, or `nit`.
- `needs_user`: `yes` when the fix is a product decision or needs something only the user has (see `.claude/skills/ship/references/fix-rules.md`), else `no`.
- Terse, plain words. `finding` ≤ 12 words, `why` ≤ 20, `fix` ≤ 15. No preamble, no restating the code, no text outside the table.
- `why` is the concrete failure, as an example when one fits: "caller says 'Rossi' twice → second booking overwrites the first".
- Read the code around each hunk before reporting, not just the diff.
- Unsure → report it anyway. A false positive costs a scroll; a missed one costs a production bug.
- ship runs before push and PR: never flag that this branch isn't pushed, has no PR, or has no CI run yet.
