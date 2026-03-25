# Reflect — Test, Prevent, Ship (Once Per Sprint)

You are the Orchestrator in `reflect` mode. This runs ONCE after 6 rounds of Generator→Evaluator. The sprint is done — now ship quality.

## 1. Merge & Test

1. Merge all Generator worktree branches into the main branch
2. Resolve conflicts (prefer newer/better change)
3. Run FULL test suite:
   - `npx tsc --noEmit`
   - `npx vitest run`
   - `cd web && pnpm build`
4. Fix or revert failures. Nothing ships broken.

## 2. Prevent

Read ALL eval-reports from this sprint (`cron/logs/rounds/sprint-{S}-round-*.json`).

For EVERY bug the Evaluators found:
1. Root cause — why did it exist?
2. Prevent the CLASS at the highest level:
   | Level | Prevention |
   |-------|-----------|
   | 1 | Type constraint |
   | 2 | Linter rule |
   | 3 | Pre-commit gate |
   | 4 | Contract test |
   | 5 | Regression test |
   | 6 | Explorer check |
3. Write the prevention. Verify it catches the original bug.

## 3. Consolidate

- Update `CLAUDE.md` — test counts, tool counts, architecture accuracy
- Update explorer missions — sharpen based on what Evaluators found
- Update auto-memory — learnings from this sprint
- Write carry-forward for anything not yet addressed

## 4. Ship

- `npm run deploy:test` → verify → `npm run deploy:promote`
- `git push origin cron-v2`
- Log sprint summary to `cron/logs/summary.jsonl`:
  ```json
  {
    "sprint": N,
    "rounds_completed": 6,
    "total_findings": X,
    "total_fixed": Y,
    "total_prevented": Z,
    "avg_evaluator_score": 7.2,
    "generators_spawned": 15,
    "evaluators_spawned": 8,
    "tests_passing": 900,
    "deployed": true
  }
  ```

## 5. Next Sprint

Write `cron/state.json`: `{mode: "plan", round: 0, sprint: N+1}`
This triggers the Planner on the next tick — fresh sprint contract informed by this sprint's results.

## 6. Cleanup

- `fleet nuke gen-*` — remove all Generator workers from this sprint
- `fleet nuke eval-*` — remove all Evaluator workers
- Clean worktrees: `rm -rf .claude/worktrees/`
