#!/bin/bash
# Aggregate Claude Code state across every pane in the current tmux session.
# Prints a per-pane indicator suitable for the tmux status bar.
#
# Output shape (colored via tmux #[...] escapes):
#   1.1:●  2.1:✓  2.2:●  2.3:·  2.4:⚠
# where W.P means "window W, pane_index P". Empty panes render as a dim `·`.
#
# Performance: called every status-interval seconds. Kept fast by doing
# all state parsing in a single awk pass; no mktemp, no per-file forks.

STATE_DIR="${HOME}/.claude/state"
[ -d "$STATE_DIR" ] || exit 0

live=$(tmux list-panes -s -F '#{pane_id} #{window_index} #{pane_index}' 2>/dev/null | sed 's/^%//')
[ -n "$live" ] || exit 0

printf '%s\n' "$live" | awk -v state_dir="$STATE_DIR" '
{
  pane_to_win[$1] = $2
  pane_to_idx[$1] = $3
  seen[$1] = 1
}
END {
  cmd = "ls " state_dir "/pane-*.state 2>/dev/null"
  while ((cmd | getline path) > 0) {
    n = split(path, parts, "/")
    fname = parts[n]
    sub(/^pane-/, "", fname)
    sub(/\.state$/, "", fname)
    if (!(fname in seen)) continue

    if ((getline state < path) > 0) {
      pane_state[fname] = state
    }
    close(path)
  }
  close(cmd)

  n = 0
  for (p in seen) {
    k = pane_to_win[p] * 1000 + pane_to_idx[p]
    keys[++n] = k
    key_to_pane[k] = p
  }
  for (i = 2; i <= n; i++) {
    v = keys[i]; j = i - 1
    while (j >= 1 && keys[j] > v) { keys[j+1] = keys[j]; j-- }
    keys[j+1] = v
  }

  out = ""
  for (i = 1; i <= n; i++) {
    k = keys[i]
    p = key_to_pane[k]
    st = pane_state[p]
    if (st == "running")        g = "#[fg=green,bold]●#[default]"
    else if (st == "done")      g = "#[fg=colour244]✓#[default]"
    else if (st == "attention") g = "#[fg=yellow,bold]⚠#[default]"
    else                         g = "#[fg=colour238]·#[default]"

    w = pane_to_win[p]; idx = pane_to_idx[p]
    out = out "#[fg=white]" w "." idx ":#[default]" g " "
  }
  sub(/ $/, "", out)
  printf "%s", out
}
'
