# Reflect — "Heal, learn, ship."

The centerpiece of the loop. The more Execute does, the more Reflect has to process. This phase should be proportionally substantial.

Plan finds problems. Execute fixes them. **Reflect makes the system learn** — it prevents the class of bug, not just this instance. Over time, the prevention hierarchy gets stronger and the system becomes self-healing.

## 1. Test

**Nothing ships broken.** Every change from Execute gets validated.

1. Clean worktrees: `rm -rf .claude/worktrees/`
2. Merge each worktree branch: `git merge <branch> --no-verify --no-edit`
3. Resolve conflicts (prefer newer/better change)
4. Kill stale processes: `pkill -f "vitest|tsx.*server" --older 35m 2>/dev/null`
5. Run full test suite IN PARALLEL:
   - Compilation check (tsc/cargo check/go vet/mypy)
   - Unit + integration tests (vitest/pytest/go test/cargo test)
   - Frontend build (if applicable)
   - Frontend tests (if applicable)
6. **Fix or revert** any failures. Do not proceed with broken code.

## 2. Prevent

**MANDATORY for every bug found this cycle.** Follow `cron/protocols/bug-regression-prevention.md`.

For every bug — whether found by explorers, test failures, or execution agents:

1. **Root cause** — why did this bug exist? What allowed it?
2. **Prevent the CLASS** at the highest possible level:

   | Level | Prevention | Catches at |
   |-------|-----------|------------|
   | 1 | **Type constraint** (branded type, union exhaustiveness) | Write time |
   | 2 | **Linter rule** (custom ESLint/ruff/clippy rule) | Lint time |
   | 3 | **Pre-commit gate** (regex check, ratchet, script) | Commit time |
   | 4 | **Contract test** (schema validation, output invariant) | Test time |
   | 5 | **Regression test** (exact reproduction) | Test time |
   | 6 | **Explorer check** (add to mission.md) | Review time |

   Always try Level 1 first. A regression test alone (Level 5) is the LOWEST form of prevention.

3. **Write the prevention** — execute, don't plan. Verify it catches the original bug.
4. **Update explorer** — if no explorer would have caught this, add a check or create a new explorer.

## 3. Consolidate

The system learns from this cycle:

- **Explorer missions**: Green = scope too narrow (expand), not "domain is clean." Sharpen missions that found nothing, expand missions that found a lot.
- **CLAUDE.md**: Keep accurate — test counts, architecture, deploy instructions. This is the authoritative project reference.
- **Auto-memory**: Add learnings from this cycle. Remove stale entries.
- **Constitution**: Update if procedures changed.
- **Carry-forward**: Write unfixed findings to `cron/logs/rounds/tick-N-carryforward.json`. These auto-elevate priority at next Plan.

## 4. Ship

1. **Deploy** (if applicable):
   - Normal ticks: deploy to test/staging only
   - Coherency ticks: promote to production (with rollback on failure)
   - Skip deploy for docs/test-only changes
2. **Git push**: `git push origin <branch>`
3. **Log this cycle**:
   - Append to `cron/logs/summary.jsonl`:
     ```json
     {"tick": N, "timestamp": "ISO", "findings": N, "fixed": N, "prevented": N, "deployed": bool, "duration_s": N}
     ```
   - Write detailed round log to `cron/logs/rounds/tick-NNN.jsonl`

## 5. Escalate

Anything the loop can't fix → escalation queue per `cron/protocols/escalation.md`.

---

## Coherency Mode (every Nth tick)

On coherency ticks, Reflect adds these AFTER the normal steps:

### Constitution + Protocol Review
- Re-read `cron/constitution.md` — do principles still apply?
- Check `cron/protocols/` — are protocols still accurate?
- Verify `cron/constitution.md` is current and accurate
- **CLAUDE.md deep check**: Not just counts — verify architecture description, deploy instructions, conventions are all current.

### Rejuvenation Agents (5 agents, parallel)

Launch 5 strategic insight agents:

```
R1: "Read summary.jsonl (last 10 ticks). What PATTERN? Improving or going in circles?"
R2: "Read all explorer reports. Which findings keep recurring? That's a systemic issue."
R3: "Compare current codebase to 10 ticks ago. Did we add bloat or reduce complexity?"
R4: "Read the test suite. Are tests ACTUALLY hard, or recipe-followable?"
R5: "If a user tested this right now with 5 queries, what would disappoint them?"
```

These produce **strategic insight**, not code. Feed their findings into the next Plan's carry-forward.

### Hook + Automation Gap Analysis
Ask: "Is there repeated manual work a hook could automate?"
