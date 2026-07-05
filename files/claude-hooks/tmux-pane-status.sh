#!/bin/bash
# Called from tmux pane-border-format via #(...). Returns a short colored
# status string based on ~/.claude/state/pane-<id>.state.
#
# Usage: tmux-pane-status.sh <pane_id_without_percent>
#   e.g. tmux-pane-status.sh 17   (for pane %17)
#
# Output is tmux #[fg=...] formatted so it colors correctly in a border.
# Empty output means "no status" — border renders default.

pane_id="${1#%}"
[ -n "$pane_id" ] || exit 0
STATE_FILE="${HOME}/.claude/state/pane-${pane_id}.state"
[ -f "$STATE_FILE" ] || exit 0

state=$(cat "$STATE_FILE" 2>/dev/null)
case "$state" in
  running)   printf '#[fg=green,bold]● running' ;;
  done)      printf '#[fg=colour244]✓ done' ;;
  attention) printf '#[fg=yellow,bold]⚠ input needed' ;;
  *) exit 0 ;;
esac
