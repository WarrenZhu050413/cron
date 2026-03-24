#!/usr/bin/env bash
# Plugin SessionStart hook: inject cron reminder if this is a cron pane
# This hook fires on EVERY session start. It checks if we're in the cron pane
# (via cron.env) and if so, injects the cron_create_reminder.md.

# Consume stdin (hook input)
INPUT=$(cat)

# Look for cron/ directory in the current project
PROJECT_DIR="$(pwd)"
CRON_ENV="$PROJECT_DIR/cron/watchdog/cron.env"

# Only act if this project has a cron loop configured
[[ -f "$CRON_ENV" ]] || exit 0

source "$CRON_ENV"
PANE="$CRON_PANE"
REMINDER_FILE="$PROJECT_DIR/cron/cron_create_reminder.md"
LOG_FILE="$PROJECT_DIR/cron/logs/watchdog.log"

[[ -f "$REMINDER_FILE" ]] || exit 0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [plugin-hook] $*" >> "$LOG_FILE" 2>/dev/null; }

# Check if THIS process is running inside the cron pane
cron_pane_pid=$(tmux display-message -t "$PANE" -p '#{pane_pid}' 2>/dev/null) || exit 0
my_pid=$$; is_cron=false
while [[ "$my_pid" -gt 1 ]]; do
  [[ "$my_pid" == "$cron_pane_pid" ]] && { is_cron=true; break; }
  my_pid=$(ps -o ppid= -p "$my_pid" 2>/dev/null | tr -d ' ') || break
done
[[ "$is_cron" != "true" ]] && exit 0

log "SESSION START: injecting cron_create_reminder.md"
cat "$REMINDER_FILE"
