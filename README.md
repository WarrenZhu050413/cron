# claude-cron

Contract-driven autonomous improvement for any codebase.

## What It Is

A methodology for continuous codebase improvement. One agent runs sprints: plan deliverables → generate in parallel → verify against calibrated criteria → loop until all pass → reflect and ship.

## Setup

1. Create `cron/` in your project:
   ```
   mkdir -p cron/contracts
   echo '{"sprint": 1, "round": 0, "mode": "plan"}' > cron/state.json
   ```

2. Write `cron/contracts/user-contract.json` — your goals + quality bar with calibration. See [`templates/user-contract-example.json`](templates/user-contract-example.json).

3. Write `cron/cron.md` — the methodology. Copy from [`templates/cron.md`](templates/cron.md) and customize.

4. Schedule:
   ```
   CronCreate(cron="*/5 * * * *", recurring=true,
     prompt="Read cron/cron.md. Execute the current phase based on cron/state.json.")
   ```

## How It Works

```
plan → negotiate → generate → verify → (loop until all pass) → reflect → next sprint
```

- **Plan**: Explore codebase. Produce 10-15 independent deliverables with calibrated verifiers.
- **Negotiate**: Check plan quality (ambitious enough? criteria testable? calibration specific?). Loop until clean.
- **Generate**: ≤15 parallel executor sub-agents, one per deliverable.
- **Verify**: ≤15 parallel verifier sub-agents. Check quality bar + deliverable criteria. Live E2E testing. Loop until ALL pass.
- **Reflect**: Encode bugs as lint rules. Ship. Raise quality bar thresholds.

## The 3 Core Files

| File | What | Who writes it |
|------|------|--------------|
| `cron/cron.md` | Methodology (state machine + principles) | Agent, from template |
| `cron/contracts/user-contract.json` | Goals + quality bar with calibration | Operator (evolves from user input) |
| `cron/state.json` | Current sprint/round/mode | System (auto-updated) |

Everything else (deliverables, executor reports, verifier reports, summaries) is created by the system as it runs.

## Calibration

Every criterion — in the quality bar, in deliverables, in plan quality — has calibration:

```json
{
  "criterion": "Description of what must be true",
  "calibration": {
    "fail": "What failure looks like (concrete example)",
    "pass": "What passing looks like (concrete example)",
    "high_pass": "What excellence looks like (concrete, hard to achieve)"
  }
}
```

This prevents rubber-stamp verification. The verifier compares against these concrete examples.

## User Contract Evolves

When the operator provides requirements or feedback, the system evaluates: is this a durable quality bar? If yes, add it to `user-contract.json` with calibration and inform the operator.
