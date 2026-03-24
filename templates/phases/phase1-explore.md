# Phase 1: Explore (includes Context pre-step)

## Pre-step: Context Gather (~30s)

Run these in parallel before launching explorers:

1. `git log -10 --oneline` + `git diff --stat` — recent commits + uncommitted work
2. `tail -3 cron/logs/summary.jsonl` — recent tick history + determine tick number
3. Read carry-forward from last tick: `cron/logs/rounds/tick-N-carryforward.json`
4. Read `cron/vision.md` — ground every decision in the north star
5. `TaskList` — prioritize remaining tasks
6. Read auto-memory — check for relevant context from past sessions

### Decision Points

- **Tick number divisible by N** (from `config.json` `coherency_review_every`) → COHERENCY REVIEW (read `cron/phases/coherency-review/coherency-review.md`)
- **User prompt received** → Priority override per `cron/protocols/user-prompt-reaction.md`
- **Escalation queue has items** → Check for resolved items, update queue

## Explore (~2 min)

**Purpose:** Surface problems. Minimum 6, target 8 explorers per tick. Core explorers always run; rotating explorers cycle based on need.

### Core Explorers (always run — 4 slots) `[FIXED]`

| Explorer   | Domain         | Key Checks                                   |
| ---------- | -------------- | -------------------------------------------- |
| E1 harness | Infrastructure | Compilation, tests, lint, pre-commit         |
| E2 stress  | Stress Testing | Adversarial queries/requests, score 0-10     |
| E3 codebase| Code Health    | File sizes, dead code, coverage, staleness   |
| E4 infra   | Production     | Server health, security, deps, bundle size   |

### Rotating Explorers (pick 4+ — cycled at coherency review) `[DYNAMIC]`

Select from the pool each tick. Coherency reviews evaluate productivity and rotate underperformers. **Never fewer than 2 rotating explorers** (total ≥ 6).

Maintain an explorer table in `phase1-explore.md` with columns: Explorer, Domain, Key Checks, Active? (YES/POOL).

### Explorer Lifecycle

1. Read `_defaults.md` for shared settings
2. Read `mission.md` from `cron/phases/phase1-explore/explorers/{explorer}/`
3. Run checks → produce `Finding[]` JSON
4. Report ONLY issues (skip checks that pass)

Launch ALL explorers in a SINGLE message. All use `model: "opus"`, `run_in_background: true`.

Proceed when 80% complete (straggler policy).

## Discovery Swarm (when stuck)

**Trigger:** <3 findings from all explorers, OR 3+ ticks since a meaningful code change.

Launch 15 discovery agents in ONE message. Each has a DIFFERENT lens on the project. They return exactly ONE finding each. Use lenses from `cron/phases/phase1-explore/explorers/discovery-swarm.md`.

Main conversation synthesizes 15 findings into execution streams. This is the anti-stagnation mechanism — there is ALWAYS work to find.
