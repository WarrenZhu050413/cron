#!/usr/bin/env bash
set -euo pipefail

# install-watchdog.sh — Install cron watchdog for current tmux pane
# Usage: ./install-watchdog.sh [PROJECT_DIR]
# Detects current pane, writes cron.env, installs hooks, offers launchd/systemd

PROJECT_DIR="${1:-$(pwd)}"
CRON_DIR="$PROJECT_DIR/cron"
FRAMEWORK_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -d "$CRON_DIR" ]]; then
  echo "Error: $CRON_DIR does not exist. Run setup-cron.sh first."
  exit 1
fi

echo "=== Cron Watchdog Installer ==="
echo "Project: $PROJECT_DIR"
echo ""

# --- Step 1: Detect tmux pane ---

if [[ -n "${TMUX:-}" ]]; then
  CURRENT_SESSION=$(tmux display-message -p '#{session_name}')
  CURRENT_WINDOW=$(tmux display-message -p '#{window_index}')
  CURRENT_PANE=$(tmux display-message -p '#{pane_index}')
  DEFAULT_PANE="$CURRENT_SESSION:$CURRENT_WINDOW.$CURRENT_PANE"
else
  DEFAULT_PANE="cron:0.0"
  echo "Note: Not inside tmux. Using default pane 'cron:0.0'."
fi

if [[ -t 0 ]]; then
  read -rp "Cron pane [$DEFAULT_PANE]: " PANE
  PANE="${PANE:-$DEFAULT_PANE}"
else
  PANE="$DEFAULT_PANE"
fi

echo "→ Using pane: $PANE"

# --- Step 2: Write cron.env ---

cat > "$CRON_DIR/watchdog/cron.env" <<EOF
# Cron loop config — shared by watchdog + hooks
CRON_PANE="$PANE"
CRON_MODEL="opus[1m]"
CRON_EFFORT="high"
CRON_WATCHDOG_INTERVAL=15    # minutes — crash check frequency
CRON_REMINDER_INTERVAL=60    # minutes — re-inject cron_create_reminder.md (0 = disabled)
CRON_MAX_RESTARTS_PER_HOUR=3 # crash-loop protection
CRON_MAX_TICK_DURATION=600   # seconds — kill stuck ticks
CRON_RESTART_DELAY=10        # seconds — wait before respawn
EOF

echo "✓ Wrote $CRON_DIR/watchdog/cron.env"

# --- Step 3: Install hooks into .claude/settings.local.json ---

SETTINGS_DIR="$PROJECT_DIR/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.local.json"
mkdir -p "$SETTINGS_DIR"

SESSION_START_HOOK="$CRON_DIR/watchdog/on-session-start.sh"
STOP_HOOK="$CRON_DIR/watchdog/on-stop-tick.sh"

if [[ -f "$SETTINGS_FILE" ]]; then
  # Check if hooks already configured
  if grep -q "on-session-start.sh" "$SETTINGS_FILE" 2>/dev/null; then
    echo "✓ SessionStart hook already in $SETTINGS_FILE"
  else
    echo "⚠ $SETTINGS_FILE exists — please add hooks manually:"
    echo '  "hooks": {'
    echo '    "SessionStart": [{"type": "command", "command": "'"$SESSION_START_HOOK"'"}],'
    echo '    "Stop": [{"type": "command", "command": "'"$STOP_HOOK"'"}]'
    echo '  }'
  fi
else
  cat > "$SETTINGS_FILE" <<EOF
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "$SESSION_START_HOOK"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "$STOP_HOOK"
      }
    ]
  }
}
EOF
  echo "✓ Created $SETTINGS_FILE with SessionStart + Stop hooks"
fi

# --- Step 4: Offer persistent daemon installation ---

PROJECT_NAME=$(basename "$PROJECT_DIR" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
WATCHDOG_SCRIPT="$CRON_DIR/watchdog/cron-watchdog.sh"

echo ""
echo "=== Daemon Installation ==="

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  PLIST_NAME="com.claude-cron.$PROJECT_NAME.watchdog"
  PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME.plist"

  if [[ -t 0 ]]; then
    read -rp "Install as launchd agent? [Y/n]: " INSTALL_LAUNCHD
    INSTALL_LAUNCHD="${INSTALL_LAUNCHD:-Y}"
  else
    INSTALL_LAUNCHD="n"
  fi

  if [[ "$INSTALL_LAUNCHD" =~ ^[Yy] ]]; then
    # Unload existing if present
    launchctl bootout "gui/$(id -u)/$PLIST_NAME" 2>/dev/null || true

    cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$PLIST_NAME</string>
  <key>ProgramArguments</key>
  <array>
    <string>$WATCHDOG_SCRIPT</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$PROJECT_DIR</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$PROJECT_DIR/cron/logs/watchdog-stdout.log</string>
  <key>StandardErrorPath</key>
  <string>$PROJECT_DIR/cron/logs/watchdog-stderr.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
  </dict>
</dict>
</plist>
EOF
    launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
    echo "✓ Installed launchd agent: $PLIST_NAME"
    echo "  Plist: $PLIST_PATH"
    echo "  Logs: $PROJECT_DIR/cron/logs/watchdog-{stdout,stderr}.log"
  fi
elif [[ "$OS" == "Linux" ]]; then
  echo "To install as systemd user service:"
  echo ""
  echo "  mkdir -p ~/.config/systemd/user"
  echo "  cat > ~/.config/systemd/user/claude-cron-$PROJECT_NAME.service <<'SVC'"
  echo "  [Unit]"
  echo "  Description=Claude Cron Watchdog ($PROJECT_NAME)"
  echo "  After=default.target"
  echo "  [Service]"
  echo "  ExecStart=$WATCHDOG_SCRIPT"
  echo "  WorkingDirectory=$PROJECT_DIR"
  echo "  Restart=always"
  echo "  RestartSec=60"
  echo "  [Install]"
  echo "  WantedBy=default.target"
  echo "  SVC"
  echo "  systemctl --user enable --now claude-cron-$PROJECT_NAME"
fi

echo ""
echo "=== Done ==="
echo "  Manual start: nohup $WATCHDOG_SCRIPT &"
echo "  Tail logs:    tail -f $PROJECT_DIR/cron/logs/watchdog.log"
