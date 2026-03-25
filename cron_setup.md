# Cron Setup — Contract-Driven Autonomous Improvement

> Give this file to any Claude instance. It will set up a contract-driven improvement loop.

Two contracts drive everything:
- **User Contract**: operator's goals, user journeys, quality bar, general verifiers (always checked)
- **Tick Contract**: per-sprint deliverables + verifiers (planner writes, verifier checks)

State machine: `Plan → Generate → Verify → (6 rounds) → Reflect → next sprint`

**Framework**: `~/claude-cron/`

---

## Phase A: Understand the Project

1. Read `CLAUDE.md` — architecture, conventions
2. Read `package.json` / `Cargo.toml` / `go.mod` — detect language/tooling
3. `git log -10 --oneline` — recent activity
4. Check if `cron/` exists (migration vs fresh)

Detect: language, test runner, build tool, deploy target, domain.

---

## Phase B: Interview the Operator

| # | Topic | Question | Default |
|---|-------|----------|---------|
| 1 | **Project name** | What should the loop call this? | `[dir name]` |
| 2 | **Deploy target** | SSH host / URL / CI / none? | `[auto-detect]` |
| 3 | **Test commands** | Full test suite command? | `[auto-detect]` |
| 4 | **Stress target** | API/UI to stress-test? | `[auto-detect]` |
| 5 | **Vision** | One sentence: what is this project becoming? | `[from README]` |
| 6 | **Top 3 user journeys** | End-to-end flows that must NEVER break? | `[from CLAUDE.md]` |

---

## Phase C: Generate Infrastructure

### Step 1: Scaffold

```bash
bash ~/claude-cron/scripts/setup-cron.sh "$(pwd)"
```

### Step 2: Write User Contract

Read `~/claude-cron/templates/user-contract.tmpl`. Generate `cron/user-contract` with:
- Goals from operator's vision answer
- Features from CLAUDE.md
- User journeys from operator's answer (question 6)
- Quality bar (tests pass, types clean, prod alive, domain-specific rules)
- General verifiers (concrete bash commands)
- Directional verifiers (test count > N, type holes < M)

**This is the most important file.** It defines what the system must always be. Write it with HIGH standards.

### Step 3: Write Constitution

Read `~/claude-cron/templates/constitution.md.tmpl`. Generate `cron/constitution.md` — the state machine that reads state.json and routes to phases.

### Step 4: Write remaining files

- `cron/contracts/user-contract` — north star (from `~/claude-cron/templates/user-contract.tmpl`)
- `cron/config.json` — intervals, thresholds
- `cron/state.json` — `{sprint: 1, round: 0, mode: "plan"}`
- `cron/phases/plan.md` — customize explorers for this project
- `cron/phases/generate.md` — as-is from template
- `cron/phases/verify.md` — as-is from template
- `cron/phases/reflect.md` — customize test/deploy commands
- `cron/protocols/*` — copy from templates
- Explorer missions (`phases/explorers/e1-e4/mission.md`) — customize for project

### Step 5: Customize REVIEW.md

Copy `~/claude-cron/templates/REVIEW.md.tmpl` to project root as `REVIEW.md`. Add project-specific semantic rules.

---

## Phase D: Summary + Start

```
=== Cron Loop Installed (Contract-Driven) ===
Loop:       Plan → Generate → Verify → (6 rounds) → Reflect
Project:    {name}
Contracts:  user-contract (operator) + contract.md (per-sprint)
Explorers:  {count}
Tests:      {commands}
Deploy:     {target}

Start: Schedule cron/constitution.md via CronCreate (*/5 * * * *)
```

Schedule the constitution as the tick. Begin first Plan phase immediately.
