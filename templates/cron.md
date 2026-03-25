# {{PROJECT_NAME}} — Methodology

> This file IS the tick. The CronCreate prompt says "Read cron/cron.md and execute."
> Follow it top-to-bottom. Do not skip phases. Do not skip gates.

---

## HOW THIS WORKS

### Sprints and Rounds

Work is organized into **sprints**. Each sprint plans a batch of 5-15 independent deliverables, then builds and verifies them.

Within a sprint, the **generate→verify** cycle may loop multiple times. Each loop is a **round**. Round 1 attempts all deliverables. If some fail verification, round 2 re-generates only the failures. Rounds repeat until every deliverable passes. Only then does the sprint complete.

```
Sprint 1
  └─ Round 1: generate all → verify all → 3 fail
  └─ Round 2: generate 3 failures → verify 3 → 1 still fails
  └─ Round 3: generate 1 failure → verify 1 → all pass ✓
  └─ Reflect → ship → Sprint 2
```

### State Transition Diagram

```
                    ┌─────────────────────────────────────────┐
                    │                                         │
                    ▼                                         │
  ┌──────┐    ┌───────────┐    ┌──────────┐    ┌──────────┐  │   ┌─────────┐
  │ plan │───▶│ negotiate │───▶│ generate │───▶│  verify  │──┘   │ reflect │
  └──────┘    └───────────┘    └──────────┘    └──────────┘      └─────────┘
      ▲            │                ▲               │                 │
      │            │                │               │                 │
      │            │                └───────────────┘                 │
      │            │                 any deliverable                  │
      │            │                 failed: round++                  │
      │            │                                                  │
      │            └── plan quality bad: loop negotiate               │
      │                                                               │
      └───────────────────────────────────────────────────────────────┘
                              sprint++, next cycle
```

**You MUST walk through this state machine.** Read `cron/state.json`, execute the phase it says, validate the gate, transition. No shortcuts.

- `plan` → produces deliverable JSONs → gate: ≥5 files exist → `negotiate`
- `negotiate` → validates plan quality → gate: contract.json written → `generate` (round=1)
- `generate` → executor sub-agents build features → gate: all executor reports exist → `verify`
- `verify` → verifier sub-agents score + security sweep → gate: `_summary.json` with `all_pass: true` → `reflect`
- `verify` (failures) → gate: `all_pass: false` → **back to `generate`** (round++)
- `reflect` → prevention, rebase, E2E, ship → `plan` (sprint++)

---

## STEP 0: READ STATE + GATE CHECK

```bash
cat cron/state.json
```

State schema: `{"sprint": N, "round": M, "mode": "plan|negotiate|generate|verify|reflect"}`

**Route to the correct phase below based on `mode`.** Do not choose — the state decides.

---

## PHASE: plan

> Goal: Explore the codebase and produce independent, calibrated deliverables.

### What to do

1. Read `cron/contracts/user-contract.json` — your north star. Every deliverable must serve these goals.
2. Read `cron/common-requirements.md` — universal rules all deliverables must follow.
3. If sprint 1: read `cron/code-quality-bootstrap.md` and add missing quality gates as deliverables.
4. **Launch 3-8 Explore agents IN PARALLEL** (single message, multiple Agent tool calls):
   - Each explores a different area: existing bugs, missing features, code health, test gaps, UI issues, security surface.
   - Each agent gets `subagent_type: "Explore"`, `run_in_background: true`.
5. When explorers return, synthesize findings into **5-15 independent deliverables**.
6. Write each deliverable to `cron/contracts/sprint-{N}/deliverables/{name}.json`:

```json
{
  "id": "descriptive-kebab-name",
  "title": "What this deliverable achieves",
  "description": "Detailed description. Specify WHAT, not HOW.",
  "acceptance_criteria": ["Testable criterion 1", "Testable criterion 2"],
  "verifier": {
    "description": "How to verify this works. Be specific — commands to run, URLs to check, behavior to observe.",
    "qualitative_check": "How should it FEEL to use? What would a user notice?",
    "calibration": {
      "fail": "Concrete example of what failure looks like",
      "pass": "Concrete example of what passing looks like",
      "high_pass": "Concrete example of what excellence looks like"
    }
  }
}
```

### Gate check before transition

```bash
ls cron/contracts/sprint-{N}/deliverables/*.json | wc -l
```

- **≥5 deliverable files exist** → update state to `"mode": "negotiate"` → continue
- **<5 files** → you skipped the plan. Go back and write deliverables.

---

## PHASE: negotiate

> Goal: Verify plan quality. Tighten criteria. Loop until clean.

### What to do

1. Read ALL deliverable files in `cron/contracts/sprint-{N}/deliverables/`.
2. Check each against these criteria:

| Criterion | Fail | Pass | High Pass |
|-----------|------|------|-----------|
| 5-15 independent deliverables | <5 | 5-15 | 15 with clear file ownership |
| Each has calibrated verifier | Missing calibration | fail/pass/high_pass present | Calibration with project-specific examples |
| Ambitious (10x heuristic) | Just bug fixes | Features + quality | Transformative |
| Independent (no file overlap) | Deliverables share files | Own file scope | Zero overlap |
| Serves user contract goals | Unrelated to goals | Advances goals | Directly fulfills a goal |

3. If any criterion fails: edit the deliverable files to fix. Loop until all pass.
4. Write `cron/contracts/sprint-{N}/contract.json`:

```json
{"sprint": N, "deliverable_count": X, "negotiation_rounds": Y, "plan_quality_score": Z}
```

### Gate check before transition

- **contract.json exists AND all deliverables have calibrated verifiers** → update state to `"mode": "generate", "round": 1` → continue
- **Otherwise** → keep negotiating.

---

## PHASE: generate

> Goal: Build all deliverables. Parallel execution via sub-agents.

### What to do

1. Read `cron/state.json` for current round M.
2. If round 1: execute ALL deliverables. If round >1: read `_summary.json` from previous round, execute ONLY failed deliverables.
3. **For each deliverable, launch an executor sub-agent IN PARALLEL** (one Agent tool call per deliverable, all in a single message):

```
Agent(
  prompt: "You are an executor. Your deliverable: {paste deliverable JSON}.
    Read cron/common-requirements.md for universal rules.
    Implement the deliverable. Commit after each meaningful change.
    Build check: BUN_CONFIG_NO_CACHE=1 bun build src/server-web.ts --outdir /tmp/check --target bun 2>&1 | tail -3
    Write your report to cron/contracts/sprint-{N}/round-{M}/executor/{deliverable-id}.json:
    {\"status\": \"done|blocked\", \"commits\": [\"sha1\", ...], \"approach\": \"what I did\", \"files_changed\": [...]}",
  subagent_type: "general-purpose",
  run_in_background: true,
  isolation: "worktree"
)
```

4. Wait for ALL executor agents to complete.

### Gate check before transition

```bash
ls cron/contracts/sprint-{N}/round-{M}/executor/*.json | wc -l
```

- **Executor report count ≥ number of assigned deliverables** → update state to `"mode": "verify"` → continue
- **Missing reports** → some executors didn't finish. Check their output. Re-launch failed ones.

---

## PHASE: verify

> Goal: Score every deliverable against its calibration. Run security sweep. Loop on failure.

### What to do

**Step 1: Launch verifier sub-agents IN PARALLEL** (one per deliverable + one for user contract):

```
# User contract verifier
Agent(
  prompt: "You are a verifier. Read cron/contracts/user-contract.json.
    Check ALL quality bar criteria against the current codebase.
    For each criterion, score: does it match fail, pass, or high_pass from the calibration?
    Be STRICT — if it doesn't match the 'pass' example, it's not a pass.
    Write report to cron/contracts/sprint-{N}/round-{M}/verifier/_general.json:
    {\"quality_bar\": [{\"criterion\": \"...\", \"score\": \"fail|pass|high_pass\", \"evidence\": \"...\"}]}",
  subagent_type: "general-purpose",
  run_in_background: true
)

# Per-deliverable verifiers (one each)
Agent(
  prompt: "You are a verifier. Your deliverable: {paste deliverable JSON}.
    Read the executor report at cron/contracts/sprint-{N}/round-{M}/executor/{id}.json.
    TEST LIVE — run the commands in the verifier description. Check the actual app behavior.
    Score against calibration: does it match fail, pass, or high_pass?
    If score < pass: file specific bugs with file:line.
    Write qualitative assessment — not just 'test passed' but how the experience FEELS.
    Write report to cron/contracts/sprint-{N}/round-{M}/verifier/{id}.json:
    {\"score\": 0-10, \"calibration_match\": \"fail|pass|high_pass\", \"evidence\": \"...\", \"live_test\": \"...\", \"bugs\": [...], \"qualitative\": \"...\"}",
  subagent_type: "general-purpose",
  run_in_background: true
)
```

**Step 2: Security sweep** (after verifiers complete)

Read `cron/security-sweep.md`. Execute ALL 8 checks. Record results.

**Step 3: Write summary**

```bash
# After all verifiers complete, write _summary.json
```

```json
{
  "sprint": N, "round": M,
  "scores": {"deliverable-1": 7, "deliverable-2": 4},
  "all_pass": false,
  "failed": ["deliverable-2"],
  "security_sweep": "PASS|BLOCK",
  "quality_bar": {"technical": "pass", "product": "pass"}
}
```

### Gate check — this is the critical enforcement point

```bash
cat cron/contracts/sprint-{N}/round-{M}/_summary.json
```

- **`all_pass: true` AND `security_sweep: "PASS"`** → update state to `"mode": "reflect"` → continue
- **ANY deliverable failed OR security BLOCK** → update state to `"mode": "generate", "round": M+1` → **GO BACK TO GENERATE PHASE**. The failed deliverables list tells generators what to fix. **This loop is mandatory. You cannot skip to reflect with failures.**

---

## PHASE: reflect

> Goal: Prevent bug classes. Consolidate. Ship. Prepare for next sprint.

### Gate check BEFORE entering reflect

```bash
cat cron/contracts/sprint-{N}/round-{M}/_summary.json | grep '"all_pass"'
```

**If `all_pass` is not `true`: you cannot be here. Go back to verify.**

### What to do

1. **Prevention** — Read ALL `round-*/verifier/` reports from this sprint. For every bug found:
   - Root cause — why did it exist?
   - Prevent the CLASS at the highest level:
     1. Type system (branded types, exhaustiveness)
     2. Lint rule (ESLint/Biome — rules are added, never removed)
     3. Pre-commit gate (script that blocks commits)
     4. Contract test (schema validation)
     5. Regression test (last resort)

2. **Consolidate** — Update project documentation if needed. Raise quality bar thresholds in user-contract.json if metrics improved.

3. **Rebase** — `git fetch origin && git rebase origin/main` — keep branch fresh.

4. **E2E tests** — Run the full E2E suite:
   ```bash
   bash .claude/scripts/e2e/e2e-chatbot.sh 2>&1 | tail -5
   bash .claude/scripts/e2e/e2e-dashboard.sh 2>&1 | tail -5
   ```

5. **Ship** — Commit all changes. Push if appropriate.

6. **Log** — Append to `.hardening-log.jsonl`:
   ```json
   {"sprint": N, "rounds": M, "timestamp": "ISO", "deliverables": X, "passed": Y, "security": "PASS", "e2e": "results"}
   ```

7. **Next sprint** — Update state: `{"sprint": N+1, "round": 0, "mode": "plan"}`

---

## TICK SCHEDULE

```
CronCreate(cron="3,18,33,48 * * * *", recurring=true,
  prompt="Read cron/cron.md. Execute from STEP 0. Follow the gates — do not skip phases.")
```

**Do NOT wait for the tick.** Keep working continuously. The tick fires when you're idle — it's a safety net, not a pace-setter.

**If session restarts:** Re-run CronCreate. State persists in `cron/state.json`.

---

## PRINCIPLES

1. **Deliverables, not implementation** — specify WHAT, never HOW
2. **10x capability** — assume generators are 10x more capable than expected
3. **Calibrated verification** — every criterion has fail/pass/high_pass with concrete examples
4. **Live E2E testing** — verifiers test the RUNNING app, not just read code
5. **Qualitative + quantitative** — how it FEELS, not just if tests pass
6. **Loop until clean** — generate→verify rounds continue until ALL pass. No exceptions.
7. **Independent parallelism** — up to 15 deliverables, each built by its own sub-agent in parallel
8. **User contract is sacred** — checked every verify round. Only strengthen, never weaken.
9. **Every bug prevents its class** — type > lint > gate > test (highest level possible)
10. **User prompts are interrupts** — drop everything when the operator speaks

---

## FILE LAYOUT

```
cron/
├── cron.md                              # THIS FILE — the methodology
├── state.json                           # {"sprint": N, "round": M, "mode": "..."}
├── common-requirements.md               # Universal rules (UI, security, code, tests)
├── security-sweep.md                    # 8 automated checks — runs every verify
├── code-quality-bootstrap.md            # Sprint 1 quality gate checklist
├── contracts/
│   ├── user-contract.json               # Goals + quality bar (sacred)
│   └── sprint-{N}/
│       ├── contract.json                # Sprint metadata
│       ├── deliverables/                # One JSON per deliverable
│       │   ├── {name}.json
│       │   └── ...
│       └── round-{M}/
│           ├── executor/                # One JSON per executor report
│           ├── verifier/                # One JSON per verifier report + _general.json
│           └── _summary.json            # Aggregate scores, pass/fail, security sweep
└── .hardening-log.jsonl                 # Append-only improvement telemetry
```
