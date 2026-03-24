# Cron Setup — Autonomous Improvement Loop

> Give this file to any Claude instance. It will set up a complete autonomous improvement loop in the current project.

You are about to set up an autonomous improvement loop — a 5-phase cycle that continuously discovers problems, fixes them, prevents recurrence, and deploys. The loop runs every 5 minutes, uses parallel explorer agents to surface findings, and parallel execution agents to fix everything found.

**Framework location**: `~/claude-cron/`

Follow these 5 phases exactly.

---

## Phase A: Understand the Project (~30s)

Read the project to understand what you're working with:

1. Read `CLAUDE.md` (if it exists) — this is the authoritative project reference
2. Read `package.json` / `Cargo.toml` / `go.mod` / `pyproject.toml` / `Makefile` — detect language and tooling
3. `git log -10 --oneline` — recent activity
4. `ls src/` or equivalent source directory
5. `ls test/` or equivalent test directory
6. Check if `cron/` already exists:
   - **If yes**: This is a MIGRATION. Read existing `cron/` files, understand the current setup, and reconcile with the framework templates. Do not overwrite evolved files.
   - **If no**: This is a FRESH SETUP. Continue to Phase B.

Detect:
- **Language**: TypeScript, Python, Go, Rust, etc.
- **Test runner**: vitest, jest, pytest, go test, cargo test, etc.
- **Build tool**: vite, webpack, cargo, go build, etc.
- **Deploy target**: SSH host, CI/CD, Docker, none
- **Domain**: What does this project do? Who uses it?

---

## Phase B: Interview the Operator

Present this table. Auto-fill defaults from what you detected. Ask the operator to confirm or override.

| # | Topic | Question | Default |
|---|-------|----------|---------|
| 1 | **Project name** | What should the loop call this? | `[directory name]` |
| 2 | **Deploy target** | SSH host / URL / CI / none? | `[auto-detect from scripts/, Dockerfile, CI config]` |
| 3 | **Test commands** | What runs the full test suite? | `[auto-detect: npx vitest run / pytest / go test ./... / cargo test]` |
| 4 | **Stress target** | API endpoint or UI URL to stress-test? | `[auto-detect from CLAUDE.md or package.json scripts]` |
| 5 | **Vision** | One sentence: what is this project trying to become? | `[from README or CLAUDE.md]` |
| 6 | **Tmux pane** | Which pane for the cron session? | `[current pane if in tmux, else "cron:0.0"]` |

Tell the operator: "Reply with just the numbers and your choice, e.g. `1: MyProject, 5: Build the best X in the world` — anything you skip I'll use the default."

---

## Phase C: Generate Infrastructure

### Step 1: Run the scaffold script

```bash
bash ~/claude-cron/scripts/setup-cron.sh "$(pwd)"
```

This creates the directory structure and copies all 100% generic files.

### Step 2: Generate project-specific files

Read each `.tmpl` file from `~/claude-cron/templates/` as a structural blueprint. **Do not copy `.tmpl` files verbatim** — understand their intent and generate project-specific versions using what you learned in Phases A and B.

Generate these files in `cron/`:

#### `cron/vision.md`
Read `~/claude-cron/templates/vision.md.tmpl`. Write a vision document using the operator's answer from question 5. Expand it into a proper north star — purpose, quality bar, success metrics. Include the "Never Idle" and "Always-Available Work" sections adapted to this project's domain.

#### `cron/constitution.md`
Read `~/claude-cron/templates/constitution.md.tmpl`. Generate a constitution with:
- All principles (verbatim from template — these are universal)
- Architecture section filled in with this project's specifics (deploy target, machine, project dir)
- Phase table (verbatim)
- Protocol list (include `bug-regression-prevention.md`)
- Explorer table customized for this project

#### `cron/cron_tick.md`
Read `~/claude-cron/templates/cron_tick.md.tmpl`. Generate the tick prompt with:
- Project name
- Explorer table matching the constitution
- Rules (verbatim from template)

#### `cron/config.json`
Read `~/claude-cron/templates/config.json.tmpl`. Fill in:
- `test_suites` with the detected test commands
- `auto_deploy` based on whether there's a deploy target

#### `cron/phases/phase1-explore/phase1-explore.md`
The scaffold copied a generic version. Customize it:
- Fill in the explorer table with E1-E4 (always) + E5-E8 (project-specific rotating explorers)
- Add project-specific context-gather steps to the pre-step (e.g., check production feedback, check deploy health)
- Customize the discovery swarm prompts for this project's domain

#### `cron/phases/phase5-complete/phase5-complete.md`
The scaffold copied a generic version. Customize it:
- Replace `{{TEST_COMMANDS}}` with actual commands
- Replace `{{DEPLOY_COMMANDS}}` with actual deploy steps (or remove if no deploy)

#### `cron/protocols/deploy.md`
Read `~/claude-cron/templates/protocols/deploy.md.tmpl`. Write project-specific deploy steps.

### Step 3: Generate explorer missions

**Always create E1-E4** (core explorers — never rotated):

For each, read `~/claude-cron/templates/explorers/e{N}/mission.md.tmpl` and generate a project-specific version at `cron/phases/phase1-explore/explorers/e{N}-{name}/mission.md`.

- **E1 harness**: Fill in compile, test, lint commands for this project
- **E2 stress**: Fill in the stress target (API URL, CLI, UI endpoint)
- **E3 codebase**: Fill in source directory, max file lines threshold
- **E4 infra**: Fill in deploy host, health endpoint

**Then create 4 rotating explorers (E5-E8)** based on the project type. Choose from:

| If the project has... | Create explorer for... |
|----------------------|----------------------|
| A web frontend | **UI quality** — design tokens, accessibility, rendering |
| An API | **API contract** — schema validation, error responses, rate limiting |
| A database | **Data quality** — null rates, constraints, query performance |
| User-facing features | **Client scenarios** — real user workflows, edge cases |
| LLM/AI integration | **Prompt quality** — system prompt health, output quality |
| External dependencies | **Integration health** — API availability, version compatibility |
| A scraper/crawler | **Scraping health** — success rates, data freshness, rate limiting |
| Email/messaging | **Delivery health** — bounce rates, template rendering |

Also read `~/claude-cron/examples/chengxing/explorers/` and `~/claude-cron/examples/kaifeng/explorers/` for real-world examples of how mission.md files should look.

### Step 4: Copy the discovery swarm

The scaffold already copied `discovery-swarm.md` to the explorers directory. Review it and customize the 15 agent prompts for this project's specific codebase, tech stack, and domain.

---

## Phase D: Install Watchdog

Run the install script:

```bash
bash ~/claude-cron/scripts/install-watchdog.sh "$(pwd)"
```

This will:
1. Detect the current tmux pane (or use the operator's answer from question 6)
2. Write `cron/watchdog/cron.env`
3. Install SessionStart + Stop hooks in `.claude/settings.local.json`
4. Offer to install as a launchd agent (macOS) or systemd service (Linux)

---

## Phase E: Summary + Start

Print a summary:

```
=== Cron Loop Installed ===
Project:    {name}
Explorers:  {count} (E1-E4 core + E5-E8 rotating)
Test suite: {commands}
Deploy:     {target or "none"}
Watchdog:   {pane}

Files created:
  cron/vision.md          — north star
  cron/constitution.md    — principles + invariants
  cron/cron_tick.md       — tick injection prompt
  cron/config.json        — configuration
  cron/phases/            — 5 phase procedures
  cron/protocols/         — event-triggered procedures
  cron/watchdog/          — crash recovery + hooks

To start: Read cron/cron_create_reminder.md and follow its instructions.
To start watchdog: nohup cron/watchdog/cron-watchdog.sh &
```

Ask the operator: "Should I begin the first tick now?"

If yes, read `cron/cron_create_reminder.md` and follow its instructions to schedule the recurring tick via `CronCreate`, then begin the first tick immediately.
