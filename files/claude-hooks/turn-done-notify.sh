#!/bin/bash
# Stop hook: (a) mark tmux window as done, (b) notify if this turn took
# longer than THRESHOLD seconds. Reads turn-start timestamp written by
# turn-start.sh.

STATE_DIR="${HOME}/.claude/state"
START_FILE="$STATE_DIR/turn-start.epoch"
THRESHOLD_SECONDS="${CLAUDE_NOTIFY_THRESHOLD_SECONDS:-10}"

# Always mark the window as done, regardless of duration.
"$HOME/.claude/hooks/tmux-mark.sh" done 2>/dev/null || true

# --- duration-gated notification -------------------------------------------

[ -f "$START_FILE" ] || exit 0

start_epoch=$(cat "$START_FILE" 2>/dev/null)
now_epoch=$(date +%s)

case "$start_epoch" in
  ''|*[!0-9]*) exit 0 ;;
esac

elapsed=$(( now_epoch - start_epoch ))
rm -f "$START_FILE"

[ "$elapsed" -ge "$THRESHOLD_SECONDS" ] || exit 0

osascript -e "display notification \"Turn took ${elapsed}s\" with title \"Claude Code done\" sound name \"Tink\"" 2>/dev/null || true
