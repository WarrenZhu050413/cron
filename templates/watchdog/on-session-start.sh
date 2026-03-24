#!/usr/bin/env bash
# SessionStart hook: inject cron_create_reminder.md once per session
# Claude reads it, schedules CronCreate, and begins the loop
# Config: cron/watchdog/cron.env

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$PROJECT_DIR/cron/watchdog/cron.env"

PANE="$CRON_PANE"
REMINDER_FILE="$PROJECT_DIR/cron/cron_create_reminder.md"
LOG_FILE="$PROJECT_DIR/cron/logs/watchdog.log"

# Consume stdin
INPUT=$(cat)

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [hook] $*" >> "$LOG_FILE"; }

# Only fire in cron pane — walk process tree to check
cron_pane_pid=$(tmux display-message -t "$PANE" -p '#{pane_pid}' 2>/dev/null) || exit 0
my_pid=$$; is_cron=false
while [[ "$my_pid" -gt 1 ]]; do
  [[ "$my_pid" == "$cron_pane_pid" ]] && { is_cron=true; break; }
  my_pid=$(ps -o ppid= -p "$my_pid" 2>/dev/null | tr -d ' ') || break
done
[[ "$is_cron" != "true" ]] && exit 0

log "SESSION START: injecting cron_create_reminder.md"
cat "$REMINDER_FILE"
