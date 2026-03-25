# claude-cron — Setup

> Contract-driven autonomous improvement for any codebase.

## Install

```bash
bash ~/claude-cron/scripts/setup-cron.sh "$(pwd)"
```

## Configure

1. Write `cron/contracts/user-contract.json` — your goals + quality bars (see `templates/user-contract-example.json`)
2. Customize `cron/cron.md` from the template

## Run

```
CronCreate(cron="*/5 * * * *", recurring=true,
  prompt="Read cron/cron.md. Execute the current phase based on cron/state.json.")
```

## If session restarts

Re-run CronCreate. State persists in `cron/state.json`.
