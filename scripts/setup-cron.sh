#!/usr/bin/env bash
set -euo pipefail

# setup-cron.sh — Set up contract-driven cron in a project
# Usage: bash ~/claude-cron/scripts/setup-cron.sh [PROJECT_DIR]

PROJECT_DIR="${1:-.}"

if [[ -f "$PROJECT_DIR/cron/state.json" ]]; then
  echo "⚠ cron/ already exists — skipping"
  exit 0
fi

echo "Setting up cron/ at $PROJECT_DIR/"

mkdir -p "$PROJECT_DIR/cron/contracts"
echo '{"sprint": 1, "round": 0, "mode": "plan"}' > "$PROJECT_DIR/cron/state.json"

# Copy templates
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)/templates"
cp "$TEMPLATE_DIR/cron.md" "$PROJECT_DIR/cron/cron.md"
cp "$TEMPLATE_DIR/user-contract-example.json" "$PROJECT_DIR/cron/contracts/user-contract-example.json"

echo "✓ Done"
echo ""
echo "  cron/cron.md                          ← methodology (customize for your project)"
echo "  cron/state.json                       ← state machine"
echo "  cron/contracts/user-contract-example.json  ← copy to user-contract.json + fill in"
echo ""
echo "  Next:"
echo "    1. cp cron/contracts/user-contract-example.json cron/contracts/user-contract.json"
echo "    2. Edit user-contract.json with your goals + quality bar"
echo "    3. Edit cron/cron.md with your project name"
echo "    4. CronCreate(cron=\"*/5 * * * *\", prompt=\"Read cron/cron.md. Execute current phase.\")"
