# Plan — Produce Tick Contract

Run ONCE per sprint. Read the user contract, explore the codebase, write a tick contract with deliverables + verifiers.

## 1. Read Contracts + Context

In parallel:
- `cron/user-contract` — what must always hold
- `cron/verify-report.md` — last sprint's verification results (what failed, what to improve)
- `CLAUDE.md` — architecture, conventions
- `REVIEW.md` — semantic quality rules
- `git log -20 --oneline` — recent changes
- `warren_escalation_queue.md` — open items
- Production: `curl -s http://8.135.53.164/health`

## 2. Discover

Launch 15-20 explorer agents. All opus, all parallel. Find problems, opportunities, improvements.

## 3. Write Tick Contract

Write `cron/contracts/sprint-{N}/tick-contract`:

**Rules for writing good contracts:**
- Specify WHAT to deliver, never HOW to implement
- Each deliverable gets a CONCRETE verifier (a command that outputs pass/fail)
- Verifiers should be HARD to pass — push quality forward, don't rubber-stamp
- Include progression verifiers that raise the bar beyond current state
- Include discovery verifiers that probe for implied requirements
- Enough work for 6 rounds (don't plan just 1 round of small fixes)
- Standards must be higher than last sprint's contract

## 4. Update State

`state.json`: `{mode: "generate", round: 1, sprint: N}`
