# claude-cron — Setup

> Contract-driven autonomous improvement for any codebase.

## Install (one time per project)

```bash
bash ~/claude-cron/scripts/setup-cron.sh "$(pwd)"
```

Creates `cron/` in your project with phases, explorers, protocols, security sweep, and common requirements.

## Configure (one time per project)

1. **Write `cron/contracts/user-contract.json`** — your goals + quality bars with fail/pass/high_pass calibration. See `~/claude-cron/templates/user-contract-example.json`.
2. **Write `cron/cron.md`** — copy from `~/claude-cron/templates/cron.md`. Replace `{{PROJECT_NAME}}` with your project name.
3. **Review `cron/code-quality-bootstrap.md`** — run the checklist. Missing items become Sprint 1 deliverables.

## Run

```
CronCreate(
  cron: "3,18,33,48 * * * *",
  recurring: true,
  prompt: "Read cron/cron.md. Execute the current phase. If mid-tick, continue. If idle, start fresh."
)
```

That's it. The state machine reads `cron/state.json` and loops:

```
Plan → Negotiate → Generate → Verify (+ security sweep) → Reflect → next sprint
```

## Manual tick (no cron)

Just say: "Read cron/cron.md and execute the current phase."

## If session restarts

Re-run the CronCreate above. State persists in `cron/state.json` — the loop picks up where it left off.

## Key files

| File | Purpose |
|------|---------|
| `cron/cron.md` | Methodology (state machine + principles) — **the entry point** |
| `cron/contracts/user-contract.json` | Permanent goals + quality bars (sacred, never weaken) |
| `cron/state.json` | Sprint/round/mode state |
| `cron/common-requirements.md` | Universal rules for all deliverables (UI, security, code, tests) |
| `cron/security-sweep.md` | 8 automated security checks — runs every verify round |
| `cron/code-quality-bootstrap.md` | Architecture scaffolding checklist (Sprint 1) |
| `cron/phases/` | plan, negotiate, generate, verify, reflect |
| `cron/phases/explorers/` | e1-harness, e2-stress, e3-codebase, e4-infra + custom |
