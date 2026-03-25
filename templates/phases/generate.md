# Generate — Build Against the Tick Contract

Launch sub-agents to build. You are the orchestrator — you dispatch, you don't build.

## 1. Read Context

- `cron/contracts/sprint-{N}/contract` — deliverables + verifiers (WHAT to build)
- `cron/contracts/sprint-{N}/round-{M}-report` — if round >1, read failures from last verification
- `cron/state.json` — current sprint/round

## 2. Launch Sub-Agents

For each deliverable stream, launch a background Agent:
- Model: opus, isolation: worktree (for code changes) or explore (for research)
- Each agent gets: the deliverable description + relevant file paths + "commit after each change"
- Non-overlapping file ownership between agents
- Agents CAN use their own sub-agents internally

If round >1: agents also get the report failures — specific bugs to fix.

## 3. Wait + Transition

When all agents complete → `state.json`: `{mode: "verify"}`

## Key Rules

- Specify WHAT each agent should deliver, not HOW to implement it
- The tick contract's verifiers will test the output — agents should ship quality
- If an agent gets stuck: kill it, simplify its deliverable, relaunch
