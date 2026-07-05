#!/bin/bash
# Aggregate Claude Code state across every pane in the current tmux session.
# Prints a per-pane indicator suitable for the tmux status bar.
#
# Output shape (colored via tmux #[...] escapes):
#   1.1:●  2.1:✓  2.2:●  2.3:·  2.4:⚠
# where 2.4 means "window 2, pane_in_window index 4".
#
# Empty panes (no Claude Code state) render as a dim `·` so every live
# pane appears in the indicator and you can tell at a glance that nothing
# is "missing" from the display.

STATE_DIR="${HOME}/.claude/state"

command -v tmux >/dev/null 2>&1 || exit 0
tmux display-message -p '#{session_name}' >/dev/null 2>&1 || exit 0

session="$(tmux display-message -p '#{session_name}')"

tmp_live=$(mktemp -t fleet-live) || exit 0
tmp_state=$(mktemp -t fleet-state) || { rm -f "$tmp_live"; exit 0; }
trap 'rm -f "$tmp_live" "$tmp_state"' EXIT

# Live pane list: "<pane_id_no_pct> <window_index> <pane_index_in_window>"
tmux list-panes -s -t "$session" -F '#{pane_id} #{window_index} #{pane_index}' 2>/dev/null \
  | sed 's/^%//' > "$tmp_live"

[ -s "$tmp_live" ] || exit 0

# State records: "<pane_id_no_pct> <state>"
if [ -d "$STATE_DIR" ]; then
  for f in "$STATE_DIR"/pane-*.state; do
    [ -e "$f" ] || continue
    pane_id="${f##*/pane-}"
    pane_id="${pane_id%.state}"
    state=$(cat "$f" 2>/dev/null)
    [ -n "$state" ] || continue
    printf '%s %s\n' "$pane_id" "$state" >> "$tmp_state"
  done
fi

# awk emits one segment per LIVE pane, using state if we have one.
awk -v state_file="$tmp_state" '
BEGIN {
  # Build pane -> state map from state file (if any).
  while ((getline line < state_file) > 0) {
    split(line, f, " ")
    pane_state[f[1]] = f[2]
  }
  close(state_file)
}
{
  pane = $1; win = $2; idx = $3
  state = pane_state[pane]
  if (state == "running")        g = "#[fg=green,bold]●#[default]"
  else if (state == "done")      g = "#[fg=colour244]✓#[default]"
  else if (state == "attention") g = "#[fg=yellow,bold]⚠#[default]"
  else                            g = "#[fg=colour238]·#[default]"

  key = win * 1000 + idx
  segs[key] = "#[fg=white]" win "." idx ":#[default]" g
  keys[++nkeys] = key
}
END {
  # Insertion sort keys[]
  for (i = 2; i <= nkeys; i++) {
    v = keys[i]; j = i - 1
    while (j >= 1 && keys[j] > v) { keys[j+1] = keys[j]; j-- }
    keys[j+1] = v
  }
  out = ""
  for (i = 1; i <= nkeys; i++) out = out segs[keys[i]] " "
  sub(/ $/, "", out)
  printf "%s", out
}
' "$tmp_live"
