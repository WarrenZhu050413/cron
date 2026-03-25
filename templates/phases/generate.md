# Generate — Parallel Executors Build Against Contract

Launch up to 15 executor sub-agents in ONE message. All parallel, worktree isolation.

## 1. Read Context

- `contracts/sprint-{N}/deliverables/` — what to build
- If round >1: `contracts/sprint-{N}/round-{M-1}/verifier/` — bugs to fix from last round

## 2. Launch Executors

One sub-agent per independent deliverable. Each agent:
- Reads its deliverable JSON (description + verifier)
- Builds the feature
- Writes the test if it doesn't exist (the test IS the verifier)
- Does code-level validation inline (tsc, vitest for changed files)
- Commits after each meaningful change
- Writes `contracts/sprint-{N}/round-{M}/executor/{deliverable}.json`

If round >1: only launch executors for FAILED deliverables (read _summary.json).

## 3. Update State

When all executors complete: `state.json`: `{mode: "verify", round: M, sprint: N}`
