# {{PROJECT_NAME}} — Methodology

This file is the complete specification. Every tick reads it in full. Follow it exactly.

## Concepts

A **sprint** plans 5–15 deliverables, builds them, and verifies them. A **round** is one generate→verify attempt within a sprint. Round 1 builds everything. If some deliverables fail, round 2 rebuilds only failures. Rounds loop until all pass.

```
Sprint 1
  Round 1: generate all → verify → 3 fail
  Round 2: generate 3  → verify → 1 fails
  Round 3: generate 1  → verify → all pass ✓
  Reflect → ship → Sprint 2
```

## State Machine

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
      │            │                 failures: round++                │
      │            └── quality bad: loop                              │
      └──────────────────────────────────────────────────────────────┘
                           sprint++
```

Walk this machine. Read `cron/state.json`. Execute the phase it says. Validate the gate. Transition. No shortcuts.

| Transition | Gate (must pass before transition) |
|-----------|-----------------------------------|
| plan → negotiate | ≥5 deliverable JSON files exist |
| negotiate → generate | `contract.json` written, all deliverables have calibrated verifiers |
| generate → verify | Executor report exists for every assigned deliverable |
| verify → reflect | `_summary.json` shows `all_pass: true` AND security sweep PASS |
| verify → generate | `all_pass: false` — increment round, loop back |
| reflect → plan | Sprint complete — increment sprint |

## Execution Models

**Sub-agents** — independent, parallel, no coordination. Launch multiple `Agent()` calls in one message.

**Agent teams** — coordinated work with dependencies. `TeamCreate()` with agents that can message each other.

| Phase | Model | Reason |
|-------|-------|--------|
| plan | Sub-agents | Explorers must be independent—no influence on each other |
| negotiate | Sub-agents | Each deliverable reviewed independently against calibration |
| generate | **Agent team** | Executors may share files, build order, integration points—team coordinates |
| verify | Sub-agents | Verifiers must be independent skeptics, not collaborators |
| reflect | Main agent | Single mind synthesizes learnings |

**No self-checking.** The agent that builds a deliverable (generate) must NOT verify it (verify). Every phase uses independent agents to check the previous phase's work. This is why plan uses explorers (not the main agent guessing), negotiate uses independent reviewers (not the planner rubber-stamping), and verify uses fresh sub-agents (not the executors marking their own homework). The main agent orchestrates—it does not judge its own output.

## User Input Protocol

User prompts are the highest-priority signal. When the user speaks mid-sprint:

1. **Stop current work immediately.** Respond to the user first.
2. **Evaluate the input.** Ask: is this a one-time instruction, or a durable quality expectation?
3. **Route accordingly:**

| Input type | Action | Example |
|-----------|--------|---------|
| **Direction change** | Adjust current sprint deliverables | "Focus on performance, not features" |
| **New requirement** | Add deliverable to current sprint | "Add dark mode to the dashboard" |
| **Quality expectation** | Add to `user-contract.json` with calibration | "All API responses must be <200ms" |
| **Bug report** | Add P0 deliverable to current sprint | "The login page is broken" |
| **Feedback on approach** | Update `common-requirements.md` if durable | "Don't use inline styles" |
| **Correction** | Fix immediately, then add prevention rule | "That's wrong, X should be Y" |

**Evolving the user contract**: When a user states a quality expectation (not a one-off task), add it to `cron/contracts/user-contract.json` with fail/pass/high_pass calibration. Tell the user you've added it. The contract only grows—never weaken or remove a criterion the user set.

**Mid-sprint additions**: New deliverables from user input go into the current sprint's `deliverables/` directory. They skip negotiate (the user is the authority) and enter the generate→verify loop immediately.

## Common Requirements (inlined — apply to ALL deliverables)

These are checked in negotiate (plan review), generate (executors follow them), and verify (verifiers enforce them). Violations block the round.

**UI**: Follow existing design system (CSS variables, tokens, components). No inline styles. Support dark mode. Use shared components—don't reinvent. Reference `frontend-design` skill for new UI. Match existing spacing patterns.

**Security**: Verify ownership on data routes (not just auth). Strip sensitive fields from responses. Paginate lists (cap 200–500). Sanitize errors—never leak internals. Rate-limit LLM endpoints. Fail-closed on missing permissions. Parameterize all SQL. Whitelist fields for external API calls.

**Code**: Zero mock/placeholder data. No hardcoded IDs. Search for existing patterns first. Prefer editing over creating files. Keep solutions minimal. Follow commit conventions.

**Testing**: New features need regression tests. Bug fixes need a catching test. Real fixtures, not mocks. Test count never decreases (ratchet). Regression tests map 1:1 to requirements.

**Data**: Use canonical database (not legacy). Don't duplicate authoritative external data. Scope all queries by permissions. Cache with TTL, not indefinitely.

**Verification**: Three layers, in order — no shortcuts:
1. **Deploy** to a test environment (staging server, test slot, preview deploy). Never verify against localhost alone.
2. **API verification** — curl/fetch against the deployed test server with real auth tokens. Check endpoints return correct data, auth enforced, error cases handled.
3. **Browser E2E** — Playwright against the deployed test server. Log in with a real identity (SSO, autologin, real user credentials — not demo accounts or bypassed auth). Before testing:
   - **List every endpoint** your deliverables changed or added
   - **List every page/button/form** your deliverables affected
   - **Write the test plan** — which URLs to visit, which buttons to click, which forms to fill, which responses to check
   Then execute the plan: navigate to each URL, click every listed button, fill every form, verify every response. Capture screenshots at each step. If anything doesn't work as expected, it's a bug — the deliverable fails.

Reading code is not verification. Unit tests are not verification. Localhost is not verification. If the project has no test environment, that is a **Sprint 1 P0 blocker**.

---

## STEP 0: Read State

```bash
cat cron/state.json
```

```json
{"sprint": 1, "round": 0, "mode": "plan"}
```

Route to the phase matching `mode`. The state decides—not you.

---

## PHASE: plan

Explore the codebase. Produce calibrated deliverables.

1. Read `cron/contracts/user-contract.json`—every deliverable must serve these goals.
2. Read `cron/common-requirements.md`—rules all deliverables must follow.
3. Sprint 1 only: read `cron/code-quality-bootstrap.md`, add missing quality gates as deliverables.
4. Launch **3–8 Explore sub-agents in parallel** (single message, multiple `Agent` calls):
   ```
   Agent(subagent_type: "Explore", run_in_background: true,
     prompt: "Explore {area}: bugs, missing features, code health, test gaps, UI, security.")
   ```
5. Synthesize findings into **5–15 independent deliverables**.
6. Write each to `cron/contracts/sprint-{N}/deliverables/{id}.json`:
   ```json
   {
     "id": "descriptive-kebab-name",
     "title": "What this achieves",
     "description": "Specify WHAT, not HOW.",
     "acceptance_criteria": ["Testable criterion 1", "Testable criterion 2"],
     "verifier": {
       "description": "Commands to run, URLs to check, behavior to observe.",
       "qualitative_check": "How should it FEEL?",
       "calibration": {
         "fail": "Concrete failure example",
         "pass": "Concrete passing example",
         "high_pass": "Concrete excellence example"
       }
     }
   }
   ```

**Gate**: `ls cron/contracts/sprint-{N}/deliverables/*.json | wc -l` → ≥5 files → set `mode: "negotiate"`.

---

## PHASE: negotiate

Verify plan quality. Tighten weak criteria. Loop until clean.

**Launch sub-agents to review** — do NOT self-review your own plan. Each sub-agent independently scores one deliverable against the calibration criteria below.

1. Read all deliverable files.
2. Launch review sub-agents (one per deliverable, parallel). Each scores against:

| Criterion | Fail | Pass | High Pass |
|-----------|------|------|-----------|
| Count | <5 | 5–15 | 15 with clear file ownership |
| Calibrated verifiers | Missing | fail/pass/high_pass present | Project-specific examples |
| Ambitious | Just bug fixes | Features + quality | Transformative |
| Independent | Shared files | Own scope | Zero overlap |
| Serves goals | Unrelated | Advances goals | Directly fulfills a goal |
| Common requirements | Deliverable would violate common reqs | Consistent with all common reqs | Explicitly addresses common req gaps |

3. Collect sub-agent reviews. Fix failures. Re-launch reviewers. Loop until all pass.
4. Write `cron/contracts/sprint-{N}/contract.json`:
   ```json
   {"sprint": 1, "deliverable_count": 12, "negotiation_rounds": 2, "plan_quality_score": 8}
   ```

**Gate**: `contract.json` exists, all deliverables have calibrated verifiers → set `mode: "generate", round: 1`.

---

## PHASE: generate

Build deliverables. Use an **agent team** for coordinated execution.

1. Read round M from `cron/state.json`.
2. Round 1: all deliverables. Round >1: only failed (from previous `_summary.json`).
3. Create team:
   ```
   TeamCreate(agents: [
     {
       name: "executor-{id}",
       prompt: "Your deliverable: {JSON}.
         Follow the Common Requirements (UI, security, code, testing, data) from cron/cron.md.
         Implement. Commit after each change.
         Build check: BUN_CONFIG_NO_CACHE=1 bun build src/server-web.ts --outdir /tmp/check --target bun
         Write report to cron/contracts/sprint-{N}/round-{M}/executor/{id}.json:
         {status, commits, approach, files_changed}
         Coordinate with other executors via SendMessage if you touch shared files.",
       isolation: "worktree"
     },
     // one per deliverable
   ])
   ```
4. Wait for all to complete.

**Gate**: `ls cron/contracts/sprint-{N}/round-{M}/executor/*.json | wc -l` ≥ assigned count → set `mode: "verify"`.

---

## PHASE: verify

Score deliverables. Run security sweep. Loop on failure.

**Step 1**: Launch verifier **sub-agents in parallel** (one per deliverable + one for user contract):

```
# User contract check
Agent(run_in_background: true,
  prompt: "Read cron/contracts/user-contract.json. Score ALL quality bar criteria.
    Be STRICT—the bar is high_pass, not just pass. If ANY bug exists, it's not done.
    A deliverable with known issues cannot pass regardless of score.
    Write to cron/contracts/sprint-{N}/round-{M}/verifier/_general.json")

# Per-deliverable (one each, all parallel)
Agent(run_in_background: true,
  prompt: "Deliverable: {JSON}. Read executor report.

    STEP 1 — BUILD TEST PLAN:
    List every endpoint changed/added. List every page, button, form affected.
    Write the exact URLs to visit, buttons to click, forms to fill, responses to check.

    STEP 2 — DEPLOY + API CHECK:
    Deploy to test environment. Curl every listed endpoint with real auth tokens.
    Verify correct responses, auth enforcement, error handling.

    STEP 3 — BROWSER E2E:
    Open Playwright. Log in with real identity (not demo accounts).
    Execute the test plan: visit each URL, click each button, fill each form.
    Screenshot at each step. Check dark mode. Check error states.

    STEP 4 — SCORE:
    Target is HIGH_PASS. Any bug = FAIL regardless of score.
    Check Common Requirements (UI, security, code, testing, data from cron/cron.md).
    Common requirement violations = automatic FAIL.

    Write to cron/contracts/sprint-{N}/round-{M}/verifier/{id}.json:
    {score, calibration_match, common_reqs_pass, test_plan, endpoints_tested,
     pages_tested, bugs, evidence, screenshots, e2e_browser_tested, qualitative}
    bugs=[] AND calibration_match=high_pass is the ONLY way to pass.")
```

**Step 2**: Check **common requirements** — for each deliverable that touched UI, security, code, tests, or data, verify compliance with the Common Requirements section above. Common requirement violations are scored as FAIL on the deliverable.

**Step 3**: Run security sweep—read `cron/security-sweep.md`, execute all 8 checks.

**Step 4**: Write `cron/contracts/sprint-{N}/round-{M}/_summary.json`:
```json
{
  "sprint": 1, "round": 2,
  "scores": {"auth-fix": 9, "dark-mode": 6},
  "all_high_pass": false,
  "failed": ["dark-mode"],
  "open_bugs": ["dark-mode: 100 lines dead CSS", "dark-mode: broken on mobile"],
  "security_sweep": "PASS",
  "quality_bar": {"technical": "pass", "product": "pass"}
}
```

**Gate — HIGH STANDARD**: The round passes ONLY when:
1. Every deliverable scores **high_pass** (not just pass)
2. **Zero open bugs** across all verifier reports
3. Security sweep is PASS
4. Common requirements fully satisfied

A "pass" with known issues is NOT good enough. If a verifier scores "pass" but lists bugs, the deliverable is treated as **failed** — it goes back to generate. The goal is zero-defect delivery, not "good enough."

`all_high_pass: true` AND `open_bugs: []` AND `security_sweep: "PASS"` → set `mode: "reflect"`.
Otherwise → set `mode: "generate", round: M+1`. **No delays. No exceptions. Fix everything before moving on.**

---

## PHASE: reflect

Ship and prevent. Only enter if `_summary.json` shows `all_pass: true`.

1. **Prevent**: Read all `round-*/verifier/` reports. For every bug, prevent the class:
   1. Type system (best) — branded types, exhaustiveness
   2. Lint rule — added, never removed
   3. Pre-commit gate
   4. Contract test
   5. Regression test (last resort)

2. **Consolidate**: Raise quality bar thresholds if metrics improved.

3. **Rebase**: `git fetch origin && git rebase origin/main`

4. **E2E**: Run full suite.

5. **Ship**: Commit. Push if appropriate.

6. **Log**: Append to `.hardening-log.jsonl`:
   ```json
   {"sprint": 1, "rounds": 3, "timestamp": "ISO", "deliverables": 12, "passed": 12, "security": "PASS", "e2e": "PASS"}
   ```

7. **Next**: Set `{"sprint": N+1, "round": 0, "mode": "plan"}`.

---

## Tick

To schedule: read this entire file, then pass its full contents as the CronCreate prompt.

```bash
# Read cron.md, then call CronCreate with its contents as the prompt
cat cron/cron.md
# Then: CronCreate(cron="*/5 * * * *", recurring=true, prompt=<entire contents of cron.md>)
```

Every tick re-ingests the full methodology. If cron.md changes mid-sprint, the next tick picks up the update.

Do not wait for the tick—keep working. It fires when idle as a safety net.

If session restarts: re-read cron.md, re-run CronCreate with its full contents.

---

## Principles

0. **You are not running out of context.** You have a 1M-token context window with automatic compaction built in. Do not preemptively refuse work, claim context is full, or stop early out of anxiety. If context gets heavy, compaction handles it. Try a tool call before ever claiming you can't continue. Never mention context limits as a reason to stop.
1. **Deliverables, not implementation** — WHAT, not HOW
2. **10x capability** — assume executors are far more capable than expected
3. **Calibrated verification** — fail/pass/high_pass with concrete examples
4. **Live testing** — verifiers test the running app, not just code
5. **Qualitative + quantitative** — how it feels, not just if tests pass
6. **Loop until clean** — no exceptions
7. **Independent verification** — verifiers are skeptics, not collaborators
8. **User contract is sacred** — only strengthen, never weaken
9. **Prevent the class** — type > lint > gate > test
10. **User prompts are interrupts** — drop everything

---

## Files

```
cron/
├── cron.md                     # This file
├── state.json                  # {sprint, round, mode}
├── common-requirements.md      # Universal rules (UI, security, code, tests)
├── security-sweep.md           # 8 checks, runs every verify
├── code-quality-bootstrap.md   # Sprint 1 quality gates
├── contracts/
│   ├── user-contract.json      # Goals + quality bar (sacred)
│   └── sprint-{N}/
│       ├── contract.json       # Sprint metadata
│       ├── deliverables/{}.json
│       └── round-{M}/
│           ├── executor/{}.json
│           ├── verifier/{}.json + _general.json
│           └── _summary.json
└── .hardening-log.jsonl        # Append-only telemetry
```
