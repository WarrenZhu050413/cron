#!/usr/bin/env bash
# Stop hook: block Claude from stopping in the cron pane and inject the tick
# Uses native hook mechanism (stdout JSON) — no tmux send-keys needed
# Config: cron/watchdog/cron.env

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$PROJECT_DIR/cron/watchdog/cron.env"

PANE="$CRON_PANE"
TICK_FILE="$PROJECT_DIR/cron/cron_tick.md"
LOG_FILE="$PROJECT_DIR/cron/logs/watchdog.log"

# Read hook input from stdin
INPUT=$(cat)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [hook] $*" >> "$LOG_FILE"; }

# Check if THIS process is running inside the cron pane
cron_pane_pid=$(tmux display-message -t "$PANE" -p '#{pane_pid}' 2>/dev/null) || exit 0
my_pid=$$; is_cron=false
while [[ "$my_pid" -gt 1 ]]; do
  [[ "$my_pid" == "$cron_pane_pid" ]] && { is_cron=true; break; }
  my_pid=$(ps -o ppid= -p "$my_pid" 2>/dev/null | tr -d ' ') || break
done

[[ "$is_cron" != "true" ]] && exit 0  # Not in cron pane — allow stop

# Always block — the cron loop should never stop voluntarily
TICK_CONTENT=$(cat "$TICK_FILE")
REASON="<From-Cron-Stop-Tick>
${TICK_CONTENT}
</From-Cron-Stop-Tick>"

# Escape for JSON
REASON_JSON=$(printf '%s' "$REASON" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

log "BLOCK: injecting tick via native Stop hook"
printf '{"decision": "block", "reason": %s}' "$REASON_JSON"
