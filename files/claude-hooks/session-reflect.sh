#!/bin/bash
# Session-end reflection prompt for OPINIONS.md maintenance.
#
# Wire as an additional Stop hook. It maintains a session counter and
# every OPINIONS_REFLECT_EVERY sessions (default: 20) prints a nudge to
# the terminal suggesting the user run a distillation pass.
#
# This deliberately DOES NOT auto-invoke the LLM to rewrite OPINIONS.md.
# Doctrine changes are the human's decision; the hook just surfaces the
# opportunity so it doesn't get forgotten. To actually distill, the user
# runs `claude 'reflect on recent sessions and propose OPINIONS.md
# updates'` and reviews the diff manually.

STATE_DIR="${HOME}/.claude/state"
COUNTER="$STATE_DIR/session-count"
EVERY="${OPINIONS_REFLECT_EVERY:-20}"

mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

# Increment the session counter.
current=0
[ -f "$COUNTER" ] && current=$(cat "$COUNTER" 2>/dev/null)
case "$current" in
  ''|*[!0-9]*) current=0 ;;
esac
next=$((current + 1))
printf '%s\n' "$next" > "$COUNTER" 2>/dev/null || exit 0

# Only nudge every N sessions.
[ $((next % EVERY)) -eq 0 ] || exit 0

# Emit a subtle macOS notification. Silent if osascript is unavailable.
osascript -e "display notification \"~/.claude/OPINIONS.md distillation pass overdue (session $next). Run 'claude \\\"reflect on recent sessions and propose OPINIONS.md updates\\\"' when convenient.\" with title \"OPINIONS.md reflection nudge\"" 2>/dev/null || true
