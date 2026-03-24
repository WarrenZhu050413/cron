# E1: Tick Quality Scorer

## PROMPT

Read summary.jsonl from both monitored projects and score recent ticks.

**Files to read:**
- `/Users/kevinster/ChengXing-Bot/cron/logs/summary.jsonl` (last 10 lines)
- `/Users/kevinster/KaiFeng-GTM-work/cron/logs/summary.jsonl` (last 10 lines)

**For each tick, score (0-60):**

| Check | 0 points | 5 points | 10 points |
|-------|----------|----------|-----------|
| Explorers launched | <4 | 4-7 | ≥8 |
| Findings (or swarm) | 0 without swarm | — | >0 or swarm ran |
| Executors launched | <2 | 2 | ≥3 parallel |
| Tests run | skipped | — | full suite |
| Prevention written | bugs without prevention | — | all bugs prevented |
| Violations | violations logged | — | clean |

**Report:**
- Per-project: last 5 ticks with scores, trend (improving/degrading/stable)
- Flag any tick scoring <30
- Flag any tick with "0 findings" and no discovery swarm
- Flag any tick with violations

## WHY/PURPOSE
The scoring rubric makes compliance objective. Trend detection catches slow degradation before it becomes stagnation.

## EVOLVES WHEN
- New invariants added to constitution → add scoring criteria
- Scoring doesn't correlate with actual quality → recalibrate weights
