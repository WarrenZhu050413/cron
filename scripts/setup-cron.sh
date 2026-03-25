#!/usr/bin/env bash
set -euo pipefail

# setup-cron.sh — JSON-native contract-driven cron
# Usage: ./setup-cron.sh [PROJECT_DIR]

PROJECT_DIR="${1:-.}"
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates"

if [[ -f "$PROJECT_DIR/cron/state.json" ]]; then
  echo "⚠ cron/ already exists — skipping"
  exit 0
fi

echo "Creating cron/ at $PROJECT_DIR/cron/"

mkdir -p "$PROJECT_DIR/cron/contracts"
echo '{"sprint": 1, "round": 0, "mode": "plan"}' > "$PROJECT_DIR/cron/state.json"

echo "✓ cron/ created"
echo ""
echo "  cron/state.json              ← sprint/round/mode state machine"
echo "  cron/contracts/              ← user-contract.json + sprint-{N}/"
echo ""
echo "  Next:"
echo "    1. Write cron/contracts/user-contract.json (see ~/claude-cron/templates/user-contract-example.json)"
echo "    2. Write cron/cron.md (from ~/claude-cron/templates/cron.md.tmpl)"
echo "    3. CronCreate(cron=\"*/5 * * * *\", prompt=\"Read cron/cron.md. Execute current phase.\")"
