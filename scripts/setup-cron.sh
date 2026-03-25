#!/usr/bin/env bash
set -euo pipefail

# setup-cron.sh — Create cron/ directory structure (contract-driven architecture)
# Usage: ./setup-cron.sh [PROJECT_DIR]

PROJECT_DIR="${1:-.}"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates"

if [[ -d "$PROJECT_DIR/cron/phases" ]]; then
  echo "⚠ cron/ already exists at $PROJECT_DIR/cron/ — skipping scaffold"
  exit 0
fi

echo "Creating cron/ structure at $PROJECT_DIR/cron/"

# Directory structure
mkdir -p "$PROJECT_DIR/cron"/{contracts,phases/explorers/{e1-harness,e2-stress,e3-codebase,e4-infra,_retired},protocols,logs/rounds}

# Core files
cp "$TEMPLATE_DIR/finding-schema.ts" "$PROJECT_DIR/cron/"
cp "$TEMPLATE_DIR/scoring-rubric.md" "$PROJECT_DIR/cron/"

# Explorer defaults + swarm
cp "$TEMPLATE_DIR/explorers/_defaults.md" "$PROJECT_DIR/cron/phases/explorers/"
cp "$TEMPLATE_DIR/explorers/discovery-swarm.md" "$PROJECT_DIR/cron/phases/explorers/"

# Seed explorer missions
for edir in e1-harness e2-stress e3-codebase e4-infra; do
  tmpl="$TEMPLATE_DIR/explorers/$edir/mission.md.tmpl"
  dest="$PROJECT_DIR/cron/phases/explorers/$edir/mission.md"
  if [[ -f "$tmpl" && ! -f "$dest" ]]; then
    cp "$tmpl" "$dest"
    echo "  Seeded $edir/mission.md"
  fi
done

# Phase files (plan, generate, verify, reflect)
for phase in plan generate verify reflect; do
  cp "$TEMPLATE_DIR/phases/$phase.md" "$PROJECT_DIR/cron/phases/"
done

# Protocols
cp "$TEMPLATE_DIR/protocols/user-prompt-reaction.md" "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/escalation.md" "$PROJECT_DIR/cron/protocols/"
cp "$TEMPLATE_DIR/protocols/bug-regression-prevention.md" "$PROJECT_DIR/cron/protocols/"

# Initialize state
cat > "$PROJECT_DIR/cron/state.json" << 'EOF'
{"sprint": 1, "round": 0, "mode": "plan"}
EOF

# Contracts directory (user-contract + tick-contract live here)
echo "  Contracts dir: cron/contracts/ (user-contract.md + tick-contract.md)"

# REVIEW.md at project root
if [[ ! -f "$PROJECT_DIR/REVIEW.md" ]]; then
  cp "$TEMPLATE_DIR/REVIEW.md.tmpl" "$PROJECT_DIR/REVIEW.md"
  echo "  Seeded REVIEW.md"
fi

# Initialize log
touch "$PROJECT_DIR/cron/logs/summary.jsonl"

echo "✓ cron/ created at $PROJECT_DIR/cron/"
echo ""
echo "  Structure:"
echo "    cron/contracts/        — user-contract.md + tick-contract.md (Claude generates)"
echo "    cron/phases/           — plan, generate, verify, reflect"
echo "    cron/phases/explorers/ — e1-e4 + discovery swarm"
echo "    cron/protocols/        — bug-prevention, escalation, user-prompt"
echo "    cron/logs/             — summary.jsonl + rounds/"
echo "    cron/state.json        — sprint/round/mode tracking"
echo "    cron/constitution.md   — state machine (Claude generates)"
