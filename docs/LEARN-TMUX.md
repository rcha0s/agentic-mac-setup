# Learn tmux

tmux is the **load-bearing primitive** of Kun's workflow. Every shell you open lives inside a tmux session. Reason: sessions persist across terminal restarts, so your window layouts survive reboots and you can attach from any device.

## The mental model (3 layers)

```
tmux server (background process)
 └── session (a named collection of windows, usually "main")
 └── window (like a browser tab, has a name, contains panes)
 └── pane (a single shell, split horizontally or vertically)
```

- **Server**: one background daemon; you rarely think about it.
- **Session**: your "workspace." Persists until the server exits or you kill it.
- **Window**: like a tab. Numbered from 1.
- **Pane**: a rectangle running one shell.

## The prefix

Every tmux keybind starts with the **prefix key** to distinguish it from stuff sent to the shell. Our config sets prefix = **C-a** (control+a).

Every command below is: `press C-a, release, then press the next key`. Notation: `C-a d` means "control-a then d".

## Absolute essentials: memorize these first

| Do this | Press |
|---|---|
| Attach to session (auto-created by our zshrc) | happens on shell start |
| **Detach** (leave tmux; server keeps running) | `C-a d` |
| Re-attach later | `tmux attach` or just open a new terminal |
| List sessions | `tmux ls` |
| New window | `C-a c` |
| Next / previous window | `C-a n` / `C-a p` |
| Jump to window N (our config is 1-indexed) | `C-a 1`, `C-a 2`, ... |
| Interactive window picker | `C-a w` |
| Interactive session picker | `C-a s` |
| Split vertically (side-by-side) | `C-a \|` |
| Split horizontally (stacked) | `C-a -` |
| Move between panes | `C-a h/j/k/l` (vim-style) |
| Close pane (or `exit`) | `C-a x` |
| Rename current window | `C-a ,` |
| Command prompt (type any tmux command) | `C-a :` |
| Reload config | `C-a r` |
| Zoom current pane fullscreen (toggle) | `C-a z` |

## Sessions vs. windows vs. panes: which one do I want?

The three layers exist for different reasons. Pick by the question you're
answering:

| Question | Answer |
|---|---|
| A different project (different repo, different mental context) | New **session** (`tmux new -s <name>`) |
| A different concern in the same project (frontend / backend / logs / notes) | New **window** in current session (`C-a c`) |
| Related views of the same concern (edit + run + tail logs, all at once) | New **pane** in current window (`C-a \|` / `C-a -`) |

## Building layouts: several concurrent things visible at once

Splitting is the important skill.

```
C-a |      # split current pane left/right
C-a -      # split current pane top/bottom
```

Splits act on the **current pane**, not the whole window. So to build a 4-pane
grid: split once vertically, move to the right pane, split it horizontally,
move back to the left pane, split it horizontally. Result: 2x2 grid.

Once you have a bunch of panes, use built-in layout presets:

- `C-a Space` cycles through the standard layouts: `even-horizontal`,
  `even-vertical`, `main-horizontal`, `main-vertical`, `tiled`. `tiled`
  auto-evens N panes into a grid. Fastest way to arrange 8 panes.
- `C-a M-1` through `C-a M-5` jump directly to layouts 1-5.

Resizing:

- `C-a z` **zoom** current pane fullscreen (toggle). Kun's most-used tmux
  command. Watch one thing at a time without losing the grid.
- `C-a` then arrow keys (or `H` / `J` / `K` / `L`) resize the pane border by
  5 cells. Hold for continuous resize.
- Mouse drag on any pane border also works (`mouse on` in our config).

## Recipes for common shapes

**Two agents side by side.** One window, two panes:

```
C-a |
```

**Edit + run + logs.** One window, three panes with editor on top, run and
logs sharing the bottom:

```
C-a -              # split window into top/bottom
C-a j              # move to bottom pane
C-a |              # split bottom into left/right
```

**8 agents visible at once (Kun-style).** Two windows, 4-tile grid in each:

```
# In window 1:
C-a |; C-a l; C-a -; C-a h; C-a -    # 4 panes, 2x2 grid
C-a c                                # new window
# In window 2: repeat the 4-pane split
```

Switch between the two agent groups with `C-a 1` / `C-a 2`, or `C-a w` for
the picker. Zoom any single agent with `C-a z`.

**A 4x2 grid of 8 panes in one window** (harder to read on a laptop but
works on a large monitor):

```
# Create 8 panes any way, then normalize:
C-a Space           # cycle to 'tiled' layout
```

## Copy mode (scroll back: copy text)

Terminal doesn't scroll normally inside tmux. Enter **copy mode** instead:

| Action | Press |
|---|---|
| Enter copy mode | `C-a [` |
| Move cursor (vi keys) | `h/j/k/l`, `w`, `b`, `gg`, `G`, `/` for search |
| Start selection | `v` |
| Copy selection | `y` (yanks to system clipboard on macOS) |
| Exit copy mode | `q` or `Esc` |

Mouse also works (`set -g mouse on` in our config), so you can also just scroll and click-drag.

## Agent status indicators

If you run Claude Code inside tmux, our hooks surface agent state in two
places so a glance anywhere on screen tells you what's happening.

### Per-pane border (primary, for split-pane workflow)

Every pane has a top border. Its right side shows the state of the Claude
Code session running inside **that specific pane**, updated every 2s:

| What you see on the pane border | Meaning |
|---|---|
| `● running` (green, bold) | agent is working on a turn |
| `✓ done` (dim gray) | last turn completed |
| `⚠ input needed` (yellow, bold) | Claude wants the human's input |
| (nothing) | no Claude Code running in that pane |

This is the "look at all four panes at once" pattern: you keep working in
one pane and see the state of the other three by peripheral vision on
their borders. No window switching required.

### Per-window title (secondary, for window-picker glance)

The tmux window's *name* also gets a matching glyph prefix (`● claude` /
`✓ claude` / `⚠ claude`) and the status bar at the bottom colors each
window accordingly. Useful when you keep multiple windows and want the
status-bar picker (`C-a w`) to show colors.

Caveat: window rename is "last writer wins" across panes. If two panes in
the same window both run Claude Code, the window title reflects only the
most-recent transition. The **pane borders are the ground truth**.

### How it works

Three Claude Code hooks under `~/.claude/hooks/`:
- `turn-start.sh` on `UserPromptSubmit` → state = running
- `turn-done-notify.sh` on `Stop` → state = done (also sends an OS
 notification if the turn took ≥ 10 seconds)
- `turn-attention.sh` on `Notification` → state = attention, OS notification

They call `tmux-mark.sh <state>`, which:
1. Writes `~/.claude/state/pane-<PANE_ID>.state`
2. Renames the current tmux window with the matching glyph

The tmux `pane-border-format` calls `tmux-pane-status.sh` per pane every
2s, reads the state file, prints a colored glyph. Outside tmux the hooks
are silent no-ops.

### Secondary signal: activity indicator

`monitor-activity on` in our config also flags background panes that
produced output (Claude streaming, tests running, etc.). This is a
subtle "something happened over there" cue, distinct from the primary
hook-driven state.

## Persistence: the killer feature

Our config includes two plugins that make sessions survive reboots:

- **tmux-resurrect**: manual save/restore: `C-a C-s` save, `C-a C-r` restore
- **tmux-continuum**: auto-saves every 15 min, auto-restores on tmux server start (already enabled)

**First-run**: after installing our config, press `C-a I` (capital I) once to install the plugin manager plugins. You'll see a "Installing..." message; wait a few seconds; done. Only needed once.

## Multi-session workflow

Kun runs a session per project:

```bash
tmux new -s myproject       # start a named session from a fresh shell
# do work; C-a d to detach
tmux new -s another         # new project
tmux ls                     # list all sessions
tmux attach -t myproject    # attach to specific
tmux kill-session -t old    # delete a session you no longer need
```

Our zsh auto-attaches to `main` on interactive shell open. Once inside any
session, `C-a s` shows an interactive session picker (arrow to pick, Enter to
switch). `C-a $` renames the current session.

**Attach vs. switch:** if a session is already attached in another terminal,
`tmux attach -t <name>` will attach a second client to it (both terminals
see and drive the same screen). That's what lets you attach from a phone
mid-day and pick up where you left off.

## Sending commands to panes from outside

Useful for agent workflows, send text to a specific pane programmatically:

```bash
tmux send-keys -t main:1.2 "npm test" Enter # session:window.pane
```

## Cheat sheet reference

Pin this: <https://tmuxcheatsheet.com/>

## Learn more

- Official man page: `man tmux` (the definitive reference)
- **Dreams of Code: "Tmux has forever changed the way I write code"**: <https://www.youtube.com/watch?v=DzNmUNvnB04>
- **HackerSploit: Complete tmux Tutorial** (longer, methodical): <https://www.youtube.com/watch?v=Yl7NFenTgIo>
- **devaslife: dev workflow with tmux and vim**: <https://www.youtube.com/watch?v=sSOfr2MtRU8>
- See `docs/RESOURCES.md` for the full index

## Learning path (2 hours total)

1. **20 min**, watch the Dreams of Code video above
2. **30 min**, do a real work task inside tmux; force yourself to use only splits/windows, no new terminal tabs
3. **20 min**, read the "Copy mode" section of the official man page
4. **kill the tmux server, reboot, re-attach**, see resurrect restore your layout. This is the "oh, that's why" moment
5. **repeat for a week**, muscle memory forms

Rule of thumb from Kun: if you're opening a new terminal window instead of a new tmux pane, you're doing it wrong.
