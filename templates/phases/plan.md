# Plan — Explore + Produce Sprint Deliverables

Run ONCE per sprint. Produce 10-15 independent deliverables with calibrated verifiers.

## 1. Context

Read in parallel:
- `cron/contracts/user-contract.json` — goals, quality bars
- Previous sprint's round reports — what worked, what failed
- `CLAUDE.md` — architecture, conventions
- `REVIEW.md` — semantic quality rules
- `git log -20 --oneline`
- Production state

## 2. Explore

Launch 15 explorer sub-agents in parallel. Find problems, opportunities, improvements.

## 3. Produce Deliverables

Create `contracts/sprint-{N}/contract.json` + `deliverables/*.json`.

Rules:
- **10-15 deliverables** (cap at 15)
- **Each is INDEPENDENT** — no dependencies. If two things depend on each other, merge them.
- **Each has calibration** — fail/pass/high_pass examples
- **Specify WHAT, not HOW** — description + verifier description, not implementation details
- **10x heuristic** — assume generators are 10x more capable than you'd guess. Be ambitious.
- **Verifiers point to tests** — if the test doesn't exist, the executor writes it. Include qualitative description too.

## 4. Update State

`state.json`: `{mode: "negotiate", round: 0, sprint: N}`
