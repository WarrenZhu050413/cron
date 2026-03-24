# Phase 5: Complete (~3 min)

**Purpose:** Verify, ship, record. The tick is not done until everything is verified.

## Steps

1. **Clean worktrees**: `rm -rf .claude/worktrees/`
2. **Merge** each worktree branch: `git merge <branch> --no-verify --no-edit`
3. **Resolve conflicts** (prefer newer/better change)
4. **Kill stale processes**: `pkill -f "vitest|tsx.*server" --older 35m 2>/dev/null`
5. **Run test suite** IN PARALLEL:
   {{TEST_COMMANDS}}

   Adapt to your project. Examples:
   - TypeScript: `npx tsc --noEmit`, `npx vitest run`, `cd web && pnpm build`
   - Python: `mypy .`, `pytest`, `ruff check .`
   - Go: `go vet ./...`, `go test ./...`
   - Rust: `cargo check`, `cargo test`
6. **Fix or revert** failures. Do not deploy broken code.
7. **Deploy** if applicable:
   {{DEPLOY_COMMANDS}}

   - Normal ticks: deploy to test/staging only
   - Coherency review ticks: promote to production (with rollback on failure)
   - Skip deploy for docs/test-only changes
8. **Git push**: `git push origin <branch>`
9. **Log this tick** — append to `cron/logs/summary.jsonl`:
   ```json
   {"tick": N, "timestamp": "ISO", "findings": N, "fixed": N, "deployed": bool, "duration_s": N}
   ```
10. **Detailed round log** — write to `cron/logs/rounds/tick-NNN.jsonl`:
    ```json
    {"phase": "explore", "explorer": "e1-harness", "findings": [...], "duration_ms": N}
    {"phase": "execute", "stream": 1, "fixed": N, "files_changed": [...]}
    {"phase": "complete", "tests_passed": N, "deployed": bool, "commit": "hash"}
    ```
11. **Escalation check**: if any blocker was discovered, append to escalation queue per `cron/protocols/escalation.md`
