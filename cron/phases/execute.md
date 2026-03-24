# Meta-Execute — "Fix drift + improve framework"

## Remind Drifting Agents

For each project with violations, inject a reminder via tmux:

```bash
TMPFILE=$(mktemp)
cat > "$TMPFILE" << 'MSG'
[REMINDER from meta-cron] Your last tick violated the constitution:
- [specific violation]
Re-read cron/constitution.md. The relevant rule: [quote the rule].
Next cycle: [specific instruction to fix].
MSG
tmux load-buffer "$TMPFILE"
tmux paste-buffer -t "[pane]"
sleep 0.3
tmux send-keys -t "[pane]" Enter
rm "$TMPFILE"
```

Keep reminders SHORT and SPECIFIC. Quote the exact constitution rule being violated.

## Update Framework Templates

If the same violation appears in BOTH projects, the framework template is unclear. Fix it:
- Edit `~/claude-cron/templates/` files to make the rule clearer
- Stronger language, concrete examples, explicit minimums
- Commit with message: `enforce: [what was unclear] — [how it's clearer now]`

## Propagate Patterns

If one project has a pattern the other doesn't and the framework doesn't:
1. Extract the pattern into the appropriate template
2. Note it in the reminder to the other project

## Rules

- NEVER modify project `cron/` files directly — only send reminders
- Framework template changes are the primary output — make drift structurally harder
- One commit per improvement (micro-commits)
