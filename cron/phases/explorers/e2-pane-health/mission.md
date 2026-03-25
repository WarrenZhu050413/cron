# E2: Pane Health Monitor

## PROMPT

Check if both project cron agents are alive and ACTUALLY following the constitution (not just claiming to).

**For each pane (cron:1.0, cron:2.0):**

1. `tmux capture-pane -t "{pane}" -p -S -40` — read last 40 lines
2. Check for signs of REAL work:
   - Agents launched? (look for "agents launched", "Explorer", "Exec")
   - Tool calls happening? (Read, Write, Bash, Agent output)
   - Spinner active with token count? ("Working...", "↑ Xk tokens")
3. **CRITICAL: Detect empty loops** — the #1 failure mode:
   - Mentions "Looping" or "Cycle N. Looping" WITHOUT launching agents → **P0 VIOLATION**
   - Rapid tick numbers incrementing with no agent launches → **P0 VIOLATION**
   - "Prod healthy. Looping." or "Health check. Looping." → **P0 VIOLATION**
   - Summary.jsonl has ticks with `explorers_launched: 0` → **P0 VIOLATION**
   - Tick numbers in summary.jsonl jump (e.g., 20→32) without intermediate logs → agent was idle or doing empty loops
4. Check for stagnation:
   - Same output as previous check? (compare to last meta-tick's pane snapshot)
   - Mentions "steady state", "converged", "nothing to do"?
   - Idle prompt with no activity for >10 min?
5. Check for constitution compliance:
   - Did it read constitution.md or phases/plan.md?
   - Did it launch ≥8 explorers?
   - Is it in a real Plan, Execute, or Reflect phase?
6. Process check:
   - `tmux display-message -t "{pane}" -p '#{pane_pid}'` then `pgrep -P` for claude

**Also check summary.jsonl for ghost ticks:**
```bash
tail -5 {project_dir}/cron/logs/summary.jsonl
```
Look for: `explorers_launched: 0`, `executors_launched: 0`, missing fields, tick number gaps.

**Report:**
- Per-pane: status (ACTIVE/EMPTY-LOOP/IDLE/STUCK/DEAD), current phase, agent count, concerning patterns
- If EMPTY-LOOP → **P0 finding** — agent is burning tokens without doing real work
- If STUCK or DEAD → P0 finding
- If health-check-only or stagnation language → P1 finding

**When EMPTY-LOOP detected, the meta-cron MUST:**
1. Write an Enforcement Notice into the project's constitution.md (per remind-agent.md protocol)
2. Notify the pane via tmux

## WHY/PURPOSE
Empty loops are the worst failure mode — the agent LOOKS alive (process running, pane active, even incrementing tick numbers) but does NO real work. This wastes tokens and time while giving a false sense of progress. The pane monitor must distinguish "actually working" from "pretending to work."

## EVOLVES WHEN
- New empty-loop patterns observed → add detection rules
- False positives (agent is mid-cycle, not looping) → tighten criteria
- The word "Looping" should NEVER appear in healthy pane output
