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
    - 'cron/cron_tick.md'
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

A reusable framework for continuous, autonomous codebase improvement. 5-phase cycle: Explore → Synthesize → Execute → Reflect → Complete.

## Setup (new project)

Read `~/claude-cron/cron_setup.md` and follow its 5-phase instructions to set up a cron loop in the current project.

## Management (existing loop)

- **Start the loop**: Read `cron/cron_create_reminder.md`, schedule with `CronCreate`
- **Explorer rotation**: Read `cron/phases/phase1-explore/phase1-explore.md`, follow rotation protocol
- **Watchdog install**: Run `bash ~/claude-cron/scripts/install-watchdog.sh`
- **Coherency review**: Read `cron/phases/coherency-review/coherency-review.md`
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
