# Learn tmux

tmux is the **load-bearing primitive** of Kun's workflow. Every shell you open lives inside a tmux session. Reason: sessions persist across terminal restarts, so your window layouts survive reboots and you can attach from any device.

## The mental model (3 layers)

```
tmux server (background process)
 └── session (a named collection of windows — usually "main")
      └── window (like a browser tab — has a name, contains panes)
           └── pane (a single shell — split horizontally or vertically)
```

- **Server**: one background daemon; you rarely think about it.
- **Session**: your "workspace." Persists until the server exits or you kill it.
- **Window**: like a tab. Numbered from 1.
- **Pane**: a rectangle running one shell.

## The prefix

Every tmux keybind starts with the **prefix key** to distinguish it from stuff sent to the shell. Our config sets prefix = **C-a** (control+a).

Every command below is: `press C-a, release, then press the next key`. Notation: `C-a d` means "control-a then d".

## Absolute essentials — memorize these first

| Do this | Press |
|---|---|
| Attach to session (auto-created by our zshrc) | happens on shell start |
| **Detach** (leave tmux; server keeps running) | `C-a d` |
| Re-attach later | `tmux attach` or just open a new terminal |
| List sessions | `tmux ls` |
| New window | `C-a c` |
| Next / previous window | `C-a n` / `C-a p` |
| Jump to window N | `C-a <N>` (0-indexed but our config uses 1-indexed) |
| Split vertically (side-by-side) | `C-a \|` |
| Split horizontally (stacked) | `C-a -` |
| Move between panes | `C-a h/j/k/l` (vim-style) |
| Close pane (or `exit`) | `C-a x` |
| Rename current window | `C-a ,` |
| Command prompt (type any tmux command) | `C-a :` |
| Reload config | `C-a r` |
| Zoom current pane fullscreen (toggle) | `C-a z` |

## Copy mode (scroll back, copy text)

Terminal doesn't scroll normally inside tmux. Enter **copy mode** instead:

| Action | Press |
|---|---|
| Enter copy mode | `C-a [` |
| Move cursor (vi keys) | `h/j/k/l`, `w`, `b`, `gg`, `G`, `/` for search |
| Start selection | `v` |
| Copy selection | `y` (yanks to system clipboard on macOS) |
| Exit copy mode | `q` or `Esc` |

Mouse also works (`set -g mouse on` in our config), so you can also just scroll and click-drag.

## Persistence — the killer feature

Our config includes two plugins that make sessions survive reboots:

- **tmux-resurrect** — manual save/restore: `C-a C-s` save, `C-a C-r` restore
- **tmux-continuum** — auto-saves every 15 min, auto-restores on tmux server start (already enabled)

**First-run**: after installing our config, press `C-a I` (capital I) once to install the plugin manager plugins. You'll see a "Installing..." message; wait a few seconds; done. Only needed once.

## Multi-session workflow

Kun runs a session per project:

```bash
tmux new -s myproject      # from a fresh shell (or C-a : new-session)
# do work; C-a d to detach
tmux new -s another        # new project
tmux ls                    # list all sessions
tmux attach -t myproject   # attach to specific
```

Our zsh auto-attaches to `main` on shell open. To switch to a different session inside tmux: `C-a s` shows a session picker.

## Sending commands to panes from outside

Useful for agent workflows — send text to a specific pane programmatically:

```bash
tmux send-keys -t main:1.2 "npm test" Enter   # session:window.pane
```

## Cheat sheet reference

Pin this: <https://tmuxcheatsheet.com/>

## Learn more

- Official man page: `man tmux` (the definitive reference)
- ThePrimeagen tmux (best 20 min primer): <https://www.youtube.com/watch?v=DzNmUNvnB04>
- DevOps Toolbox — "You need to learn tmux RIGHT NOW!!": <https://www.youtube.com/watch?v=Yl7NFenTgIo>
- Dreams of Code "Tmux has forever changed how I write code" (Kun cites this style): <https://www.youtube.com/watch?v=DzNmUNvnB04>

## Learning path (2 hours total)

1. **20 min** — watch ThePrimeagen video above
2. **30 min** — do a real work task inside tmux; force yourself to use only splits/windows, no new terminal tabs
3. **20 min** — read the "Copy mode" section of the official man page
4. **kill the tmux server, reboot, re-attach** — see resurrect restore your layout. This is the "oh, that's why" moment
5. **repeat for a week** — muscle memory forms

Rule of thumb from Kun: if you're opening a new terminal window instead of a new tmux pane, you're doing it wrong.
