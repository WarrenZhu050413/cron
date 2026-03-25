# {{PROJECT_NAME}} — Methodology

## State Machine

Read `cron/state.json`. Execute the phase.

```
plan → negotiate → generate → verify → (loop until all pass) → reflect → next sprint
```

| Mode | Do | Next |
|------|-----|------|
| `plan` | Explore. Draft `contracts/sprint-{N}/deliverables/*.json` (10-15 independent, each with calibrated verifier). | → `negotiate` |
| `negotiate` | Check plan quality against calibration (below). Ambitious enough? Criteria testable? Calibration specific? Loop until clean. | → `generate` (round=1) |
| `generate` | Launch ≤15 parallel executor sub-agents (one per deliverable, worktree isolation). If round >1: fix failed deliverables only. | → `verify` |
| `verify` | Launch ≤15 parallel verifier sub-agents. Check ALL quality bars from user-contract.json + each deliverable's criteria. Live E2E testing. | → `generate` if any fail, → `reflect` if all pass |
| `reflect` | Encode bugs as lint rules (type > lint > gate > test). Consolidate. Ship. Raise quality bar thresholds. | → `plan` (sprint++) |

## Plan Quality Calibration (used during negotiate)

```json
{
  "plan_quality": [
    {"criterion": "10-15 independent deliverables", "calibration": {"fail": "<5", "pass": "8-15", "high_pass": "15 with clear file ownership"}},
    {"criterion": "Each deliverable has calibrated verifier", "calibration": {"fail": "missing calibration", "pass": "fail/pass/high_pass present", "high_pass": "calibration with project-specific examples"}},
    {"criterion": "Ambitious (10x heuristic)", "calibration": {"fail": "just bug fixes", "pass": "features + quality", "high_pass": "transformative"}},
    {"criterion": "Independent (no dependencies)", "calibration": {"fail": "deliverables share files", "pass": "own file scope", "high_pass": "zero overlap"}}
  ]
}
```

## Contracts (all JSON)

- `contracts/user-contract.json` — goals + quality bar (calibrated). Sacred. Evolves from user input.
- `contracts/sprint-{N}/contract.json` — sprint metadata.
- `contracts/sprint-{N}/deliverables/*.json` — `{description, verifier: {description, qualitative, test, calibration}}`.
- `contracts/sprint-{N}/round-{M}/executor/*.json` — `{status, commits, approach}`.
- `contracts/sprint-{N}/round-{M}/verifier/*.json` — `{score, evidence, live_test, bugs, calibration_match}`.
- `contracts/sprint-{N}/round-{M}/_summary.json` — `{scores, all_pass, failed}`.

## Principles

1. **Deliverables, not implementation** — WHAT, not HOW
2. **10x capability** — assume generators are 10x more capable than expected
3. **Calibrated verification** — every criterion has fail/pass/high_pass
4. **Live E2E testing** — verifiers test the RUNNING app
5. **Qualitative + quantitative** — how it FEELS, not just if tests pass
6. **Loop until clean** — rounds until ALL pass
7. **Independent parallelism** — up to 15 deliverables, all parallel
8. **User contract is sacred** — checked every round, evolves from user input
9. **Every bug prevents its class** — encode as: type > lint > gate > test
10. **User prompts are interrupts** — drop everything

## CronCreate

```
CronCreate(cron="*/5 * * * *", recurring=true,
  prompt="Read cron/cron.md. Execute the current phase based on cron/state.json.")
```
