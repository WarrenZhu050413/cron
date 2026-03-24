---
description: Set up an autonomous improvement loop (Plan → Execute → Reflect) in the current project
argument-hint: Optional project name
---

# Cron Setup

You are setting up an autonomous improvement loop in the current project. This is a 3-phase cycle that runs continuously: **Plan** (massive parallel discovery) → **Execute** (massive parallel fixes) → **Reflect** (test, prevent, consolidate, ship).

Read `~/claude-cron/cron_setup.md` and follow its instructions exactly. It will guide you through:

1. **Phase A**: Understand the project (read CLAUDE.md, detect language/framework/tools)
2. **Phase B**: Interview the operator (6-question table with auto-detected defaults)
3. **Phase C**: Generate infrastructure (scaffold + project-specific files)
4. **Phase D**: Install watchdog (tmux pane detection + hooks)
5. **Phase E**: Summary + offer to start first cycle

If an argument was provided: $ARGUMENTS — use it as the project name (question 1).
