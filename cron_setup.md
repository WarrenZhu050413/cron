# claude-cron Setup

## TL;DR

```bash
bash ~/claude-cron/scripts/setup-cron.sh "$(pwd)"
```

Then:
1. Write `cron/contracts/user-contract.json` — goals + 4 quality bars with calibration
2. Write `cron/cron.md` — from `~/claude-cron/templates/cron.md.tmpl`
3. `CronCreate(cron="*/5 * * * *", recurring=true, prompt="Read cron/cron.md. Execute current phase.")`

See `~/claude-cron/SETUP.md` for the full guide.
See `~/claude-cron/templates/user-contract-example.json` for the quality bar format.
See `~/claude-cron/templates/cron.md.tmpl` for the methodology template.
