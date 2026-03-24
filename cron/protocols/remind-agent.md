# Protocol: Remind a Drifting Agent

When a project cron is violating the constitution, send a reminder.

## Format

```bash
TMPFILE=$(mktemp)
cat > "$TMPFILE" << 'MSG'
[META-CRON REMINDER] Constitution violation detected in your last cycle:

VIOLATION: {specific violation — e.g., "0 explorers launched (minimum 8)"}
RULE: {quote the exact constitution invariant}
ACTION: {specific instruction — e.g., "Next cycle: launch at least 8 explorers in Plan. Read cron/phases/plan.md."}
MSG
tmux load-buffer "$TMPFILE"
tmux paste-buffer -t "{pane}"
sleep 0.3
tmux send-keys -t "{pane}" Enter
rm "$TMPFILE"
```

## Rules

- Keep reminders SHORT and SPECIFIC — one violation per reminder
- Quote the exact constitution rule
- Give a specific corrective action
- Don't lecture — just state the fact and the fix
- If the same reminder was sent last tick and ignored → escalate to Warren
