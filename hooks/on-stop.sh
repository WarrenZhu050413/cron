#!/usr/bin/env bash
# Plugin Stop hook: block Claude from stopping in the cron pane
# Injects the tick prompt as the reason to continue.

# Read hook input from stdin
INPUT=$(cat)

PROJECT_DIR="$(pwd)"
CRON_ENV="$PROJECT_DIR/cron/watchdog/cron.env"

# Only act if this project has a cron loop configured
[[ -f "$CRON_ENV" ]] || exit 0

source "$CRON_ENV"
PANE="$CRON_PANE"
TICK_FILE="$PROJECT_DIR/cron/cron_tick.md"
LOG_FILE="$PROJECT_DIR/cron/logs/watchdog.log"

[[ -f "$TICK_FILE" ]] || exit 0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [plugin-hook] $*" >> "$LOG_FILE" 2>/dev/null; }

# Check if THIS process is running inside the cron pane
cron_pane_pid=$(tmux display-message -t "$PANE" -p '#{pane_pid}' 2>/dev/null) || exit 0
my_pid=$$; is_cron=false
while [[ "$my_pid" -gt 1 ]]; do
  [[ "$my_pid" == "$cron_pane_pid" ]] && { is_cron=true; break; }
  my_pid=$(ps -o ppid= -p "$my_pid" 2>/dev/null | tr -d ' ') || break
done

[[ "$is_cron" != "true" ]] && exit 0  # Not in cron pane — allow stop

# Block stop and inject tick
TICK_CONTENT=$(cat "$TICK_FILE")
REASON="<From-Cron-Stop-Hook>
${TICK_CONTENT}
</From-Cron-Stop-Hook>"

REASON_JSON=$(printf '%s' "$REASON" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

log "BLOCK: injecting tick via Stop hook"
printf '{"decision": "block", "reason": %s}' "$REASON_JSON"
