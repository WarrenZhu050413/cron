#!/usr/bin/env bash
set -euo pipefail

# Cron Watchdog — crash recovery + periodic reminder + crash-loop protection
# Checks every CRON_WATCHDOG_INTERVAL minutes, re-injects reminder every CRON_REMINDER_INTERVAL minutes
# Usage: ./watchdog.sh
# Config: cron/watchdog/cron.env

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
source "$PROJECT_DIR/cron/watchdog/cron.env"

PANE="$CRON_PANE"
INTERVAL="$CRON_WATCHDOG_INTERVAL"
REMINDER_INTERVAL="${CRON_REMINDER_INTERVAL:-60}"
MAX_RESTARTS="${CRON_MAX_RESTARTS_PER_HOUR:-3}"
MAX_TICK_DURATION="${CRON_MAX_TICK_DURATION:-600}"
RESTART_DELAY="${CRON_RESTART_DELAY:-10}"
TICK_FILE="$PROJECT_DIR/cron/cron_tick.md"
SESSION_ID_FILE="$PROJECT_DIR/.claude/cron-session-id"
LOG_FILE="$PROJECT_DIR/cron/logs/watchdog.log"
RESTART_LOG="/tmp/$(basename "$PROJECT_DIR")-cron-restarts"
CLAUDE_FLAGS="--dangerously-skip-permissions --model $CRON_MODEL --effort $CRON_EFFORT"

# Track when the last reminder was sent (epoch seconds)
LAST_REMINDER=0

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [watchdog] $*" | tee -a "$LOG_FILE"
}

get_pane_pid() {
  tmux display-message -t "$PANE" -p '#{pane_pid}' 2>/dev/null
}

get_claude_pid() {
  local pane_pid
  pane_pid=$(get_pane_pid) || return 1
  pgrep -P "$pane_pid" -f "claude" 2>/dev/null | head -1 || true
}

extract_session_id() {
  local captured sid
  captured=$(tmux capture-pane -t "$PANE" -p -S -10 2>/dev/null)
  sid=$(echo "$captured" | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | tail -1)
  if [[ -n "$sid" ]]; then echo "$sid" > "$SESSION_ID_FILE"; echo "$sid"
  elif [[ -f "$SESSION_ID_FILE" ]]; then cat "$SESSION_ID_FILE"; fi
}

check_crash_loop() {
  # Track restarts per hour — max CRON_MAX_RESTARTS_PER_HOUR
  local hour_ago=$(($(date +%s) - 3600))
  touch "$RESTART_LOG"
  local recent
  recent=$(awk -v t="$hour_ago" '$1 > t' "$RESTART_LOG" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$recent" -ge "$MAX_RESTARTS" ]]; then
    log "CRASH-LOOP: $recent restarts in last hour (max $MAX_RESTARTS), backing off"
    return 1
  fi
  echo "$(date +%s)" >> "$RESTART_LOG"
  # Prune old entries
  local tmp; tmp=$(mktemp)
  awk -v t="$hour_ago" '$1 > t' "$RESTART_LOG" > "$tmp" && mv "$tmp" "$RESTART_LOG"
  return 0
}

inject_bootstrap() {
  # Build message from cron_create_reminder.md + cron_tick.md
  local reminder_file="$PROJECT_DIR/cron/cron_create_reminder.md"
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" <<MSGEOF
<From-Cron-Watchdog>
$(cat "$reminder_file")

Here is the tick content to schedule (from cron/cron_tick.md):

$(cat "$TICK_FILE")
</From-Cron-Watchdog>
MSGEOF
  tmux load-buffer "$tmp"
  rm -f "$tmp"
  tmux paste-buffer -t "$PANE"
  sleep 0.5
  tmux send-keys -t "$PANE" Enter
  LAST_REMINDER=$(date +%s)
  log "BOOTSTRAP injected (cron_create_reminder.md + cron_tick.md)"
}

restart_claude() {
  local sid="$1"

  if ! check_crash_loop; then
    log "SKIP restart due to crash-loop protection"
    return 1
  fi

  log "RESTART: launching claude in $PANE"
  local cmd="cd $PROJECT_DIR && claude $CLAUDE_FLAGS"
  if [[ -n "$sid" ]]; then cmd="$cmd -c $sid"; log "RESTART: resuming session $sid"; fi
  tmux send-keys -t "$PANE" "$cmd" Enter
  sleep "$RESTART_DELAY"
  if get_claude_pid > /dev/null; then
    log "RESTART: claude is alive"; sleep 3; inject_bootstrap
  else
    log "RESTART: failed, will retry next cycle"
  fi
}

ensure_pane() {
  local session="${PANE%%:*}"
  local win_pane="${PANE#*:}"
  local window="${win_pane%%.*}"

  # Ensure tmux server is running
  if ! tmux list-sessions &>/dev/null; then
    log "SETUP: tmux server not running, starting it"
    tmux new-session -d -s "$session" -c "$PROJECT_DIR"
  fi

  if ! tmux has-session -t "$session" 2>/dev/null; then
    log "SETUP: creating tmux session '$session'"
    tmux new-session -d -s "$session" -c "$PROJECT_DIR"
  fi
  if ! tmux list-windows -t "$session" -F '#{window_index}' 2>/dev/null | grep -qx "$window"; then
    log "SETUP: creating window $session:$window"
    tmux new-window -t "$session:$window" -c "$PROJECT_DIR"
  fi
  if ! tmux list-panes -t "$session:$window" -F '#{pane_index}' 2>/dev/null | grep -qx "${win_pane#*.}"; then
    log "SETUP: pane $PANE not found, using $session:$window.0"
    PANE="$session:$window.0"
  fi
}

# ---- Main loop ----

mkdir -p "$(dirname "$LOG_FILE")"
log "Watchdog started: pane=$PANE check=${INTERVAL}m reminder=${REMINDER_INTERVAL}m model=$CRON_MODEL max_restarts=$MAX_RESTARTS/hr"

while true; do
  ensure_pane
  claude_pid=$(get_claude_pid || true)

  if [[ -n "$claude_pid" ]]; then
    sid=$(extract_session_id || true)
    log "ALIVE: claude PID=$claude_pid session=${sid:-unknown}"

    # Periodic reminder: re-inject every REMINDER_INTERVAL
    if [[ "$REMINDER_INTERVAL" -gt 0 ]]; then
      now=$(date +%s)
      elapsed=$(( (now - LAST_REMINDER) / 60 ))
      if [[ "$elapsed" -ge "$REMINDER_INTERVAL" ]]; then
        log "REMINDER: ${elapsed}m since last injection, re-injecting"
        inject_bootstrap
      fi
    fi
  else
    log "DEAD: no claude process in $PANE"
    sid=$(extract_session_id || true)
    [[ -z "$sid" && -f "$SESSION_ID_FILE" ]] && sid=$(cat "$SESSION_ID_FILE")
    restart_claude "${sid:-}"
  fi

  sleep "$((INTERVAL * 60))"
done
