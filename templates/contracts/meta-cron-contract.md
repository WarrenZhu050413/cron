# Meta-Cron Contract

> Simple: check on the project crons every tick. Report status. Enforce if drifting.

## What to Check (every tick)

For each monitored project:

1. **Pane alive?** `tmux capture-pane -t "{pane}" -p -S -20 | tail -10`
2. **Last tick recent?** `tail -1 {project}/cron/logs/summary.jsonl` — timestamp within last 30 min?
3. **State progressing?** `cat {project}/cron/state.json` — mode/round/sprint changing?
4. **Verifiers passing?** `cat {project}/cron/verify-report.md` — general verifiers all pass?
5. **Empty loops?** Pane output shows "Looping" without agents = violation
6. **Contract exists?** `{project}/cron/tick-contract.md` and `{project}/cron/user-contract` exist?

## What to Do

- **All healthy**: Log status, move on
- **Pane dead/stuck**: Write enforcement into their `cron/constitution.md` + notify pane
- **Empty loops**: Write enforcement notice
- **General verifiers failing**: P0 alert to operator
- **No tick-contract**: Agent hasn't planned — remind it to read constitution

## Monitored Projects

Update this list as projects adopt the cron system.

| Project | Pane | Dir |
|---------|------|-----|
| ChengXing | cron:1.0 | /Users/kevinster/ChengXing-Bot |
| ChengXing v2 | cron:cron-v2 | /Users/kevinster/ChengXing-Bot-cron-v2 |
| KaiFeng | cron:2.0 | /Users/kevinster/KaiFeng-GTM-work |

## Output

Log to stdout (the operator's monitoring cron reads it). One-line per project:
```
[2026-03-25T10:00Z] CX: ACTIVE sprint=1 round=3 mode=verify | KF: ACTIVE tick=125 8exp/4exec | CX-v2: ACTIVE sprint=1 round=2
```
