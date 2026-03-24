#!/usr/bin/env bash
set -euo pipefail

# setup-cron.sh — Create cron/ directory structure in a target project
# Usage: ./setup-cron.sh [PROJECT_DIR]
# Called by cron_setup.md during initial setup

PROJECT_DIR="${1:-.}"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates"

if [[ -d "$PROJECT_DIR/cron/phases" ]]; then
  echo "⚠ cron/ already exists at $PROJECT_DIR/cron/ — skipping scaffold"
  echo "  Use cron_setup.md migration flow instead"
  exit 0
fi

echo "Creating cron/ structure at $PROJECT_DIR/cron/"

# Directory structure — 3 phases: plan, execute, reflect
mkdir -p "$PROJECT_DIR/cron"/{phases/explorers/{e1-harness,e2-stress,e3-codebase,e4-infra,_retired},protocols,watchdog,logs/rounds}

# Copy 100% generic files verbatim
cp "$TEMPLATE_DIR/finding-schema.ts"        "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/cron_create_reminder.md"  "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/explorers/_defaults.md"   "$PROJECT_DIR/cron/phases/explorers/"
cp "$TEMPLATE_DIR/explorers/discovery-swarm.md"  "$PROJECT_DIR/cron/phases/explorers/"

# Generic phase files
cp "$TEMPLATE_DIR/phases/plan.md"     "$PROJECT_DIR/cron/phases/"
cp "$TEMPLATE_DIR/phases/execute.md"  "$PROJECT_DIR/cron/phases/"
cp "$TEMPLATE_DIR/phases/reflect.md"  "$PROJECT_DIR/cron/phases/"

# Generic protocols
cp "$TEMPLATE_DIR/protocols/user-prompt-reaction.md"       "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/escalation.md"                 "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/bug-regression-prevention.md"  "$PROJECT_DIR/cron/protocols/"

# Watchdog scripts
cp "$TEMPLATE_DIR/../scripts/watchdog.sh"  "$PROJECT_DIR/cron/watchdog/cron-watchdog.sh"
chmod +x "$PROJECT_DIR/cron/watchdog/cron-watchdog.sh"

# Watchdog hook
cp "$TEMPLATE_DIR/watchdog/on-session-start.sh" "$PROJECT_DIR/cron/watchdog/on-session-start.sh"
chmod +x "$PROJECT_DIR/cron/watchdog/on-session-start.sh"

# Initialize empty log
touch "$PROJECT_DIR/cron/logs/summary.jsonl"

echo "✓ cron/ structure created at $PROJECT_DIR/cron/"
echo "  Directories: $(find "$PROJECT_DIR/cron" -type d | wc -l | tr -d ' ')"
echo "  Files copied: $(find "$PROJECT_DIR/cron" -type f | wc -l | tr -d ' ')"
echo ""
echo "  Next: Claude will generate project-specific files:"
echo "    vision.md, constitution.md, cron_tick.md, config.json,"
echo "    cron.env, explorer missions, deploy protocol"
