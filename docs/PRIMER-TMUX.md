# tmux Primer

> `LEARN-TMUX.md` is the cheat-sheet. This is the *why* behind it — enough to make config choices, not just execute keybinds.

## What tmux actually is

tmux is a **terminal multiplexer**: a program that owns real pseudo-terminals (PTYs) and multiplexes many of them into a single terminal window. Split-screen and tabs are the visible surface; the interesting property is that **sessions outlive the terminal that spawned them**.

```
your terminal (WezTerm)
    │  ── (client)
    ▼
tmux server ── background daemon; owns PTYs and buffers
    ├── session "main"
    │   ├── window 1: "editor" → pane running nvim
    │   ├── window 2: "shell"  → 2 panes running zsh
    │   └── window 3: "claude" → pane running claude
    └── session "another-project" (detached)
```

Kill WezTerm — the tmux server keeps running. The zsh, nvim, claude processes keep running. Open a new WezTerm, run `tmux attach`, and you're back exactly where you left off. This is the load-bearing property.

## Three concepts, three keybinds

| Concept | Analogy | Create | Navigate |
|---|---|---|---|
| **Session** | Whole workspace | `tmux new -s name` | `C-a s` (picker), `tmux attach -t name` |
| **Window** | Browser tab | `C-a c` | `C-a n/p`, `C-a <N>` |
| **Pane** | Split view inside a window | `C-a \|` or `C-a -` | `C-a h/j/k/l` |

Everything else in tmux is a variation on those three.

## The prefix key — and why we picked C-a

tmux keybinds need a **prefix** to distinguish "message for tmux" from "message for the shell." Default is `C-b`, which is (a) far from home row and (b) collides with Emacs/readline `backward-char`.

We use `C-a` because:
- Muscle memory: it's what GNU Screen used since the 80s
- Trivial to hit (pinky already on Control)
- Only collides with readline `beginning-of-line`, which most people don't use

Trade-off: if you ever `C-a a` (prefix + `a`), our config forwards a literal `C-a` to the shell (`bind C-a send-prefix`). That's the escape hatch.

## Copy mode — the mode you forget you're in

When you scroll, search, or select in tmux, you're in **copy mode**. It's a modal editor for a scrollback buffer. Enter with `C-a [`, exit with `q`.

Inside copy mode our config sets vi-style keys (`set -g mode-keys vi`):

| Do | Press |
|---|---|
| Move | `h j k l w b gg G` |
| Search forward / back | `/ ?` |
| Start selection | `v` (char) or `V` (line) |
| Yank to system clipboard | `y` |

If you accidentally type into a locked pane, you're probably in copy mode. Press `q`.

## Persistence — how tmux-resurrect + tmux-continuum work

Our config includes both plugins. What they do, in one sentence each:

- **tmux-resurrect**: on demand, save every session/window/pane/layout/cwd/running-command to a text file (`~/.tmux/resurrect/last`) and restore it later.
- **tmux-continuum**: auto-run resurrect save every 15 min, auto-restore on tmux server start.

Together: reboot your Mac, launch WezTerm, tmux server starts, continuum restores the last save — every session and its layout is back. Long-running processes (nvim, servers) don't come back running; their windows do. `@resurrect-strategy-nvim 'session'` in our config means nvim's own session file gets restored, so open buffers come back.

Files worth knowing:
- `~/.tmux/resurrect/last` — most recent save (symlink)
- `~/.tmux/resurrect/tmux_resurrect_*.txt` — history

If restore misbehaves (rare), delete `~/.tmux/resurrect/last` and start fresh.

## Config-that-should-exist — anatomy of `.tmux.conf`

Every non-trivial `.tmux.conf` needs these six sections. Ours has them all:

1. **Prefix rebind** — `unbind C-b; set -g prefix C-a; bind C-a send-prefix`
2. **General knobs** — mouse, history-limit, terminal type, escape-time, mode-keys, base-index
3. **Splits & pane nav** — `bind | split-window`, `bind -` split, `bind h/j/k/l` select-pane
4. **Reload keybind** — `bind r source-file ~/.tmux.conf` (fastest iteration loop for config work)
5. **Status line** — usually minimal; ours shows session name + clock
6. **Plugins (tpm)** — declare plugins, bootstrap tpm if missing, `run '~/.tmux/plugins/tpm/tpm'`

Read our `files/.tmux.conf` alongside this list — every section is labeled.

### One knob that matters: `set -g mouse on`

Enables mouse everywhere: click a pane to focus, drag borders to resize, scroll to enter copy mode. Old-school users disable this; I strongly recommend leaving it on. It's a productivity multiplier.

### One trap: `set -g escape-time`

If you use Vim/Neovim inside tmux, `<Esc>` triggers a delay by default (250ms) because tmux is waiting to see if you're sending an escape sequence. Set `escape-time 10` (or 0) and Neovim becomes snappy.

## Sending commands from outside tmux

Extremely useful for agent workflows:

```
tmux send-keys -t main:1.2 "npm test" Enter
tmux send-keys -t main:claude "review this PR" Enter
```

Format: `session:window.pane`. `main:1.2` = session `main`, window 1, pane 2.

An orchestrator (like firstmate) uses this to poke crewmates in specific panes without stealing focus.

## Debugging

- `tmux info` — full server state
- `tmux list-keys` — all bindings; grep for the one you're wondering about
- `tmux show-options -g` — all global options and their values
- Plugin didn't install? `~/.tmux/plugins/tpm/bin/install_plugins` runs tpm's installer directly
- Status line looks wrong? `tmux source-file ~/.tmux.conf` reloads without restart

## What NOT to spend time on

- **Learning arcane commands**: 90% of tmux value comes from 10 keybinds
- **Perfect status line**: cosmetic; time-sink; the built-in default is fine
- **Powerline / airline**: unnecessary in a Kun-style setup because you rarely see the status bar (frameless single window, single session)
- **Nested tmux**: don't. If you SSH into a machine and want tmux there too, use screen or a differently-prefixed session. Nested tmux with the same prefix is a pain.

## Further reading

- Official man: `man tmux` — dense but authoritative
- **Book: "tmux 2: Productive Mouse-Free Development" by Brian Hogan** — Pragmatic Bookshelf, 88 pages, best single resource
- Awesome tmux list: <https://github.com/rothgar/awesome-tmux>
