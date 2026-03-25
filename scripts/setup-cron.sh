#!/usr/bin/env bash
set -euo pipefail

# setup-cron.sh — Contract-driven cron architecture
# Usage: ./setup-cron.sh [PROJECT_DIR]

PROJECT_DIR="${1:-.}"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates"

if [[ -d "$PROJECT_DIR/cron/phases" ]]; then
  echo "⚠ cron/ already exists — skipping"
  exit 0
fi

echo "Creating cron/ at $PROJECT_DIR/cron/"

mkdir -p "$PROJECT_DIR/cron"/{contracts,phases/explorers/{e1-harness,e2-stress,e3-codebase,e4-infra,_retired},protocols,logs/rounds}

# Phase files
for phase in plan negotiate generate verify reflect; do
  cp "$TEMPLATE_DIR/phases/$phase.md" "$PROJECT_DIR/cron/phases/"
done

# Explorers
cp "$TEMPLATE_DIR/explorers/_defaults.md" "$PROJECT_DIR/cron/phases/explorers/"
cp "$TEMPLATE_DIR/explorers/discovery-swarm.md" "$PROJECT_DIR/cron/phases/explorers/"
for edir in e1-harness e2-stress e3-codebase e4-infra; do
  tmpl="$TEMPLATE_DIR/explorers/$edir/mission.md.tmpl"
  [[ -f "$tmpl" ]] && cp "$tmpl" "$PROJECT_DIR/cron/phases/explorers/$edir/mission.md"
done

# Protocols
cp "$TEMPLATE_DIR/protocols/user-prompt-reaction.md" "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/escalation.md" "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/bug-regression-prevention.md" "$PROJECT_DIR/cron/protocols/"

# Scoring + Finding schema
cp "$TEMPLATE_DIR/scoring-rubric.md" "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/finding-schema.ts" "$PROJECT_DIR/cron/"

# State
echo '{"sprint": 1, "round": 0, "mode": "plan"}' > "$PROJECT_DIR/cron/state.json"

# REVIEW.md
[[ ! -f "$PROJECT_DIR/REVIEW.md" ]] && cp "$TEMPLATE_DIR/REVIEW.md.tmpl" "$PROJECT_DIR/REVIEW.md"

# Logs
touch "$PROJECT_DIR/cron/logs/summary.jsonl"

echo "✓ cron/ created"
echo ""
echo "  cron/contracts/     ← user-contract.json + sprint-{N}/ (Claude generates)"
echo "  cron/phases/        ← plan, negotiate, generate, verify, reflect"
echo "  cron/protocols/     ← bug-prevention, escalation, user-prompt"
echo "  cron/state.json     ← sprint/round/mode state machine"
echo ""
echo "  Next: write user-contract.json + constitution.md"
