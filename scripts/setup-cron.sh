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

# Directory structure
mkdir -p "$PROJECT_DIR/cron"/{phases/phase1-explore/explorers/{e1-harness,e2-stress,e3-codebase,e4-infra,_retired},phases/{phase2-synthesis,phase3-execution,phase4-reflect,phase5-complete,coherency-review},protocols,watchdog,logs/rounds}

# Copy 100% generic files verbatim
cp "$TEMPLATE_DIR/finding-schema.ts"        "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/cron_create_reminder.md"  "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/explorers/_defaults.md"   "$PROJECT_DIR/cron/phases/phase1-explore/explorers/"

# Generic phase files
cp "$TEMPLATE_DIR/phases/phase2-synthesize.md"  "$PROJECT_DIR/cron/phases/phase2-synthesis/phase2-synthesis.md"
cp "$TEMPLATE_DIR/phases/phase3-execute.md"     "$PROJECT_DIR/cron/phases/phase3-execution/phase3-execution.md"
cp "$TEMPLATE_DIR/phases/phase4-reflect.md"     "$PROJECT_DIR/cron/phases/phase4-reflect/phase4-reflect.md"
cp "$TEMPLATE_DIR/phases/coherency-review.md"   "$PROJECT_DIR/cron/phases/coherency-review/coherency-review.md"

# Generic protocols
cp "$TEMPLATE_DIR/protocols/user-prompt-reaction.md"  "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/escalation.md"            "$PROJECT_DIR/cron/protocols/"

# Discovery swarm template
cp "$TEMPLATE_DIR/explorers/discovery-swarm.md"  "$PROJECT_DIR/cron/phases/phase1-explore/explorers/"

# Watchdog scripts
cp "$TEMPLATE_DIR/../scripts/watchdog.sh"  "$PROJECT_DIR/cron/watchdog/cron-watchdog.sh"
chmod +x "$PROJECT_DIR/cron/watchdog/cron-watchdog.sh"

# Watchdog hooks
for hook in on-session-start.sh on-stop-tick.sh; do
  cp "$TEMPLATE_DIR/watchdog/$hook" "$PROJECT_DIR/cron/watchdog/$hook"
  chmod +x "$PROJECT_DIR/cron/watchdog/$hook"
done

# Initialize empty log
touch "$PROJECT_DIR/cron/logs/summary.jsonl"

echo "✓ cron/ structure created at $PROJECT_DIR/cron/"
echo "  Directories: $(find "$PROJECT_DIR/cron" -type d | wc -l | tr -d ' ')"
echo "  Files copied: $(find "$PROJECT_DIR/cron" -type f | wc -l | tr -d ' ')"
echo ""
echo "  Next: Claude will generate project-specific files:"
echo "    vision.md, constitution.md, cron_tick.md, config.json,"
echo "    cron.env, explorer missions, deploy protocol"
