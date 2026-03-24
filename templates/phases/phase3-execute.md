# Phase 3: Parallel Execution (~5 min)

Launch all streams in a SINGLE message. All use `model: "opus"`, `isolation: "worktree"`.

Each prompt MUST include:

- Specific findings with file:line refs
- Clear scope (suggest non-overlapping files to reduce conflicts)
- "Commit with descriptive messages."

## Stream Classification

**Foreground** = blocking work. Use for:

- Any change that Phase 5's test suite will evaluate
- Changes to shared infrastructure (server entry, core modules, build config)
- Work that must be correct before deploy

**Background** = independent cleanup. Use for:

- Tests, docs, CSS-only polish, dead code removal
- Work that is additive and does not affect the test suite gate
- Explorer-driven research for the next tick

Rule of thumb: if the test suite would catch a regression, it is foreground.

Streams 1-4 foreground by default. Stream 5 background. Override when warranted.

**Straggler policy**: Wait for foreground. Don't wait for background.

## Anti-stagnation

If Phase 2 produced 0 findings (all explorers green):
- DO NOT SKIP Phase 3
- Instead, allocate streams to: test hardening, code quality, documentation accuracy, stress testing
- There is ALWAYS executable improvement work
