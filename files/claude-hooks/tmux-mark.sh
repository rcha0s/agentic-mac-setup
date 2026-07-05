#!/bin/bash
# Mark the current tmux window AND the current pane with a status.
# Usage: tmux-mark.sh <state>
#   running    → glyph "●", window "● claude", pane state "running"
#   done       → glyph "✓", window "✓ claude", pane state "done"
#   attention  → glyph "⚠", window "⚠ claude", pane state "attention"
#   clear      → no glyph, window "claude", pane state empty
#
# Writes ~/.claude/state/pane-<TMUX_PANE>.state so tmux.conf's
# pane-border-format can render per-pane status without a re-source.
#
# Silent no-op outside tmux. Ignore all failures to keep hooks robust.

state="$1"
[ -n "$TMUX" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

case "$state" in
  running)   glyph="●"; label="● claude"; pane_state="running"   ;;
  done)      glyph="✓"; label="✓ claude"; pane_state="done"      ;;
  attention) glyph="⚠"; label="⚠ claude"; pane_state="attention" ;;
  clear)     glyph=""; label="claude"; pane_state="" ;;
  *) exit 0 ;;
esac

# Window rename (as before). Keeps per-window color pattern working
# alongside the per-pane one.
tmux rename-window "$label" 2>/dev/null || true

# Per-pane state file. TMUX_PANE looks like "%17"; scrub the '%' so we get
# a filesystem-safe name.
STATE_DIR="${HOME}/.claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null || true
pane_id="${TMUX_PANE#%}"
STATE_FILE="$STATE_DIR/pane-${pane_id}.state"

if [ -z "$pane_state" ]; then
  rm -f "$STATE_FILE" 2>/dev/null || true
else
  printf '%s\n' "$pane_state" > "$STATE_FILE" 2>/dev/null || true
fi
