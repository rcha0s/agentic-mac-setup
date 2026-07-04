# Learn Neovim

Neovim is your editor when you need it. In Kun's workflow it does **filesystem navigation, diff review, small manual edits, and git surface** — the agent writes the bulk of code, but Neovim is the surgical tool.

## Modes (the one concept you have to internalize)

Neovim starts in **normal mode**, not insert mode. This is the single biggest thing that trips people up.

| Mode | What you do | Enter from normal via |
|---|---|---|
| **Normal** | Move, delete, yank, run commands. Default state. | `Esc` from any other mode |
| **Insert** | Type text like a normal editor. | `i` (insert), `a` (append), `o` (new line below), `O` (new line above) |
| **Visual** | Select text. | `v` (char), `V` (line), `Ctrl-v` (block) |
| **Command** | Type `:` commands like `:w`, `:q`. | `:` |
| **Terminal** | An interactive shell inside a buffer. | `:terminal` |

Every "learn Vim" tutorial hammers this. The 10-minute investment pays off forever.

## The single best interactive intro

```
vimtutor
```

Type that in a terminal. It's a built-in 30-minute interactive tutorial that comes with Vim/Neovim. **Do this first.**

## Essential normal-mode motions

| Do | Press |
|---|---|
| Left / down / up / right | `h j k l` |
| Word forward / back | `w` / `b` |
| End of word / previous end | `e` / `ge` |
| Line start / end | `0` / `$` |
| Top / bottom of file | `gg` / `G` |
| Jump to line N | `<N>G` (e.g., `42G`) |
| Search forward / back | `/pattern` / `?pattern`, then `n`/`N` to iterate |
| Next occurrence of word under cursor | `*` |
| Go to definition (LSP later) | `gd` |
| Back to previous location | `Ctrl-o` (forward: `Ctrl-i`) |

## Essential editing (all normal mode)

| Do | Press |
|---|---|
| Delete char / line | `x` / `dd` |
| Change word (delete + insert) | `cw` |
| Yank (copy) line | `yy` |
| Paste after / before | `p` / `P` |
| Undo / redo | `u` / `Ctrl-r` |
| Repeat last change | `.` |
| Save / quit / save-and-quit | `:w` / `:q` / `:wq` |
| Save all / quit-all | `:wa` / `:qa` |

`.` is the most underrated key on the keyboard. It repeats the last edit.

## Our config — what's installed

- **[lazy.nvim](https://lazy.folke.io)** — plugin manager. Bootstraps itself on first run.
- **[oil.nvim](https://github.com/stevearc/oil.nvim)** — edit the filesystem like a buffer.
- **[neogit](https://github.com/NeogitOrg/neogit)** — Magit-style git UI.
- **[snacks.nvim](https://github.com/folke/snacks.nvim)** — folke's collection: picker, dashboard, notifier, indent guides, statuscolumn.

Leader key is **space**. So `<leader>ff` means "press space, then f, then f".

## First-run checklist

1. Open Neovim: `nvim`
2. **lazy.nvim will bootstrap** — clones itself, installs the 4 plugins listed above. Watch the progress; hit `q` when done.
3. Quit and reopen. Now the plugins are loaded.

## Config keybinds (from `~/.config/nvim/lua/plugins/*.lua`)

### File navigation (oil.nvim)

| Do | Press |
|---|---|
| Open parent directory (like a file browser) | `-` |
| Also open oil | `<space>e` |
| Inside oil: create file/dir | just type it as a new line, `:w` to apply |
| Inside oil: delete | delete the line, `:w` to apply |
| Inside oil: quit | `q` |

Oil's magic: the filesystem is a **buffer**. Renaming = editing text. Deleting a file = deleting a line. Creating a directory = adding `newdir/` on a new line. Save with `:w` to apply.

### Fuzzy find (snacks picker)

| Do | Press |
|---|---|
| Smart find (files + recent) | `<space><space>` |
| Find files | `<space>ff` |
| Grep content | `<space>fg` |
| Recent files | `<space>fr` |
| Buffers | `<space>fb` |
| Help pages | `<space>fh` |
| Keymaps | `<space>fk` |

`<space>fk` is the "I forgot a keybind" escape hatch — search all defined keybinds by description.

### Git (neogit)

| Do | Press |
|---|---|
| Open neogit status | `<space>gg` |
| Commit | `<space>gc` |
| Pull / push | `<space>gp` / `<space>gP` |
| Diffview open / close | `<space>gd` / `<space>gD` |

Inside neogit: `s` to stage, `u` to unstage, `x` to discard, `cc` to commit, `?` for help.

## Learn more

**Best resources for you specifically** (since you don't have prior Neovim config):

1. **[ThePrimeagen — Neovim as your editor](https://www.youtube.com/watch?v=w7i4amO_zaE)** — 12 min, no-nonsense
2. **[TJ DeVries — Kickstart.nvim walkthrough](https://www.youtube.com/watch?v=stqUbv-5u2s)** — the author of neovim.io walks through a from-scratch config
3. **[Josean Martinez — full custom Neovim setup](https://www.youtube.com/watch?v=vdn_pKJUda8)** — 1hr, covers plugin management + LSP
4. **[Neovim docs on lua config](https://neovim.io/doc/user/lua-guide.html)** — official, dense but authoritative

## Learning path (4 hours to competent)

1. **30 min** — run `vimtutor` end to end. Do not skip.
2. **20 min** — ThePrimeagen video above
3. **1 hour** — open your own project in nvim, use `<space>ff` to jump around, `<space>fg` to grep. Force yourself.
4. **30 min** — try oil.nvim: press `-`, navigate to a random directory, rename a file by editing the buffer, `:w`
5. **30 min** — try neogit: `<space>gg` inside a repo, stage/commit a change
6. **1 hour** — customize one thing. Add a keybind. Break something. Fix it.

After ~2 weeks of daily use, motions become muscle memory. That's the payoff.

## Common pitfalls

- **"How do I quit?"** → `:q` (or `:q!` to discard changes)
- **"Nothing is typing"** → you're in normal mode. Press `i`.
- **"Arrow keys don't work in insert mode"** → they do; but learn hjkl in normal mode instead. You'll thank yourself.
- **Neovim froze** → you probably hit `Ctrl-s` which sends XOFF to the terminal. Press `Ctrl-q` to resume.
- **Plugin errors on startup** → `:Lazy` shows plugin status; `:Lazy sync` re-installs.
