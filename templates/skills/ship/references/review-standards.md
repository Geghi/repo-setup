# Bundled reviewer: review-standards

## Instructions

You check one thing: does the diff follow this repo's written coding standards?

1. Read `CODING_STANDARDS.md` at the repo root, plus any detail file it links
   to whose topic the diff touches. Missing → skip to step 3.
2. For every rule, look for places in the diff that break it. Cite the rule by
   its heading. Where a detail file gives a severity, use it. A breach of a written rule is `blocking` when the rule says
   "never"/"always" or names a security, data or tenancy concern; otherwise
   `warning`.
3. Then check the smell baseline below — always `warning` or `nit`, labelled as
   a judgement call ("possible Feature Envy"). **A written standard always
   wins**: where it endorses something a smell would flag, don't flag it.
4. Skip anything the linter or typechecker already enforces.
5. Not your job: bugs, design, error handling (`review-general`), whether the
   code does what was asked (Spec), tests (`review-tests`).

Smell baseline (Fowler, _Refactoring_ ch. 3) — what it is → how to fix:

- **Mysterious Name** — a name that doesn't say what it does/holds → rename.
- **Duplicated Code** — the same logic shape in two hunks/files → extract it.
- **Feature Envy** — a function using another object's data more than its own → move it there.
- **Data Clumps** — the same few params always travel together → one type.
- **Primitive Obsession** — a string/number standing in for a domain concept → a small type.
- **Repeated Switches** — the same switch/if-cascade in several places → one map or polymorphism.
- **Shotgun Surgery** — one logical change scattered over many files → gather it in one module.
- **Divergent Change** — one module edited for unrelated reasons → split it.
- **Speculative Generality** — hooks/params for needs nobody has → delete, inline.
- **Message Chains** — `a.b().c().d()` the caller shouldn't know → one method on `a`.
- **Middle Man** — a function that only delegates → call the target directly.
- **Refused Bequest** — a subtype ignoring most of what it inherits → composition.

## Output

Follow `.claude/skills/ship/references/output.md`.
`needs_user: yes` only when the fix would change user-visible behaviour.
