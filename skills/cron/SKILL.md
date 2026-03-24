---
name: cron
description: >-
  Set up and manage autonomous improvement loops for any repository.
  Use this skill when: setting up a cron loop, creating an autonomous improvement
  system, configuring explorers, installing a watchdog, or managing tick-based
  improvement cycles. Also use when the user mentions "cron setup", "autonomous loop",
  "improvement loop", "tick loop", "explorer agents", "set up cron", or "USE cron".
  This skill handles the full lifecycle: initial setup, explorer creation, watchdog
  installation, and migration of existing cron systems.
metadata:
  priority: 8
  pathPatterns:
    - 'cron/constitution.md'
    - 'cron/vision.md'
    - 'cron/phases/**'
    - 'cron/watchdog/**'
    - 'cron/cron.md'
  bashPatterns:
    - '\\bcron_setup\\b'
    - '\\binstall-watchdog\\b'
    - '\\bsetup-cron\\b'
retrieval:
  aliases:
    - "cron loop"
    - "autonomous loop"
    - "improvement loop"
    - "tick loop"
    - "cron setup"
  intents:
    - "set up cron"
    - "configure autonomous improvement"
    - "install watchdog"
    - "create explorers"
    - "set up autonomous loop"
    - "configure tick loop"
---

# Autonomous Improvement Loop (claude-cron)

3-phase sprint cycle: **Plan** (massive parallel discovery) → **Execute** (massive parallel fixes) → **Reflect** (test, prevent, consolidate, ship). Each cycle is a sprint compressed via LLM parallelism.

## Setup (new project)

Read `~/claude-cron/cron_setup.md` and follow its instructions to set up a cron loop in the current project. Or use the `/cron-setup` command.

## Management (existing loop)

- **Start the loop**: Read `cron/cron_create_reminder.md`, schedule with `CronCreate`
- **Explorer rotation**: Happens every Plan based on last Reflect's results. Read `cron/phases/plan.md`.
- **Watchdog install**: Run `bash ~/claude-cron/scripts/install-watchdog.sh`
- **Bug prevention**: Follow `cron/protocols/bug-regression-prevention.md` — every bug must prevent its class

## Key Principles

1. **Never idle** — there are NO diminishing returns. Always attempt work.
2. **Every bug prevents its class** — fix → root cause → prevention at the highest level (type > lint > gate > test).
3. **Discovery swarm when stuck** — <3 findings → launch 15-20 agents with different lenses.
4. **Opus everything** — all agents use opus model. No cost cap.
5. **Carry-forward** — unfixed findings auto-elevate priority next tick.

## Reference

- **Framework**: `~/claude-cron/`
- **Templates**: `~/claude-cron/templates/`
- **Examples**: `~/claude-cron/examples/`
- **Scripts**: `~/claude-cron/scripts/`
