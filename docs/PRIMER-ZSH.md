# zsh Primer (for the bash user)

You spent years in bash. Everything you know still works — zsh is ~95% bash-compatible for interactive use. This primer covers the 5% that matters and the reasons people pick zsh.

## Why zsh at all

Two reasons. One practical:

1. **Since macOS Catalina (2019), zsh is the default login shell.** Apple stopped updating `/bin/bash` at v3.2 (2007) because newer bash is GPLv3. If you stay on `/bin/bash`, you're 18+ years behind on the language.

One nice-to-have:

2. **Better interactive UX out of the box.** Tab completion for command flags, ghost-text history suggestions (with zsh-autosuggestions), syntax highlighting as you type (with zsh-syntax-highlighting).

Not "zsh is more powerful than bash" — for scripting they're comparable. This is purely about **daily driving.**

## What NOT to do

- **Don't install Oh My Zsh.** It's popular, heavy, and slow. Sources ~5000 lines on shell start. Manages your prompt for you (we use starship instead). Adds hundreds of aliases you didn't ask for. If you already have it, remove it (`rm -rf ~/.oh-my-zsh` and delete Oh-My-Zsh lines from `~/.zshrc`) and add just the plugins you actually want.

- **Don't install Prezto or Zim** either. Same category — meta-frameworks that own your shell config.

- **Don't obsess over "is this bash-compatible" scripts.** For scripts, put `#!/bin/bash` (or `#!/usr/bin/env bash`) at the top and it runs under bash regardless of your login shell. Zsh is only for interactive use.

## Config file map — where should what live

zsh reads different files based on how it's invoked. For an interactive login shell (the normal case), the order is:

```
1. /etc/zshenv        (system)
2. ~/.zshenv          (user — always sourced, even non-interactive)
3. /etc/zprofile      (system, login only)
4. ~/.zprofile        (user, login only)
5. /etc/zshrc         (system, interactive only)
6. ~/.zshrc           (user, interactive only)  ← 99% of your config
7. /etc/zlogin        (system, login only)
8. ~/.zlogin          (user, login only)
```

**Rule of thumb:**
- **`~/.zshenv`** — env vars that must be set even for non-interactive scripts (`JAVA_HOME`, `GOPATH`). Rare in practice.
- **`~/.zshrc`** — everything interactive: PATH, aliases, functions, prompt, keybinds, plugins. This is where 99% of your config goes.
- **`~/.zprofile`** — one-time login setup (starting an ssh-agent, printing MOTD). Rarely used on modern Macs.

Our setup uses only `~/.zshrc` and factors additions into `~/.zshrc.local` for tidiness. `~/.zshrc` has a single line:

```
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
```

`~/.zshrc.local` is a symlink into the fork. Everything version-controlled.

## bash → zsh translation guide

99% of your bash config is copy-paste. The parts that differ:

### PS1 prompt strings — different escape codes

| bash | zsh |
|---|---|
| `\u` | `%n` |
| `\h` | `%m` |
| `\w` | `%~` |
| `\$` | `%#` |
| `\e[31m` | `%F{red}` |

Sidestep this entirely by using **starship** (we do). It renders identically in bash and zsh.

### `$PS1` vs `$PROMPT`

zsh reads `$PROMPT` (or `$PS1`). Both work; `$PROMPT` is more zsh-idiomatic.

### Array indexing — 1-based

```
arr=(a b c)
echo $arr[1]     # zsh: prints "a" (1-based!)
echo ${arr[0]}   # bash: prints "a"
```

Only matters if you write shell one-liners with arrays. Guard against it with `setopt KSH_ARRAYS` if you want bash behavior — but you usually don't need to.

### `[[ ... ]]` differs slightly

Both support `[[`. zsh's is *stricter* about globbing inside `[[`; most bash `[[ ]]` conditionals port directly.

### Word splitting doesn't happen by default

```
files=$(ls)
for f in $files; do ...   # bash: iterates by word (splits on whitespace)
                          # zsh:  iterates ONCE with the whole string
```

This bites people. The fix: `for f in ${(f)files}` (zsh-idiomatic) or `for f in "${(@f)files}"` or just quote/iterate properly. If you have shell functions that assume bash word-splitting, you may need to tweak them. Our ported `.bash_profile` doesn't rely on this.

### Globbing is more powerful

```
ls **/*.txt      # recursive glob works out of the box (no shopt globstar needed)
ls *.(txt|md)    # alternation
ls *(.)          # only regular files
ls -l *(m-1)     # files modified in last day
```

Delightful once you learn it, but you don't need to for basic use.

## What our zsh config actually does

`~/.zshrc.local` (symlinked into `~/github/agentic-mac-setup/files/zshrc.local`) has two sections:

### Section 1 — ported from `~/.bash_profile`

Everything you had before: PATH extensions (Volta, Java, Go, homebrew, workbrew, LM Studio, jenv, pyenv), env vars (`JAVA_HOME`, `WORKON_HOME`, `NODE_EXTRA_CA_CERTS` for ZScaler), aliases, functions (`code`, `aws_login`, `claude` MCP-env wrapper).

The `claude` function is the most important — it walks up from `$PWD` finding the nearest `.env` and sources it into a subshell before launching Claude Code. This is how MCP servers in `.mcp.json` get their tokens.

### Section 2 — Kun-style additions

- git aliases (`m`, `pull`, `push`, `amend`, `rebasem`, …)
- agent shortcuts (`cc`, `gnfun`, `th`, `nm`)
- zsh-autosuggestions + zsh-syntax-highlighting sourced from Homebrew paths
- `^f` (Ctrl-F) accepts the current autosuggestion
- starship prompt init
- tmux auto-attach on interactive shell start

## The three plugins worth installing

Just these three, no meta-framework:

1. **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** — ghost-text of your most recent matching command as you type. Press `→` or `Ctrl-F` (we bound this) to accept.
2. **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** — colors commands as you type: red if not found, green if it exists. Catches typos before you hit enter.
3. **starship** (not strictly a zsh plugin) — prompt renderer, config in `~/.config/starship.toml`.

`brew install zsh-autosuggestions zsh-syntax-highlighting starship` — all three done.

Sourcing order matters: **syntax-highlighting must be sourced last** or it won't highlight commands entered before it loaded. Our config sources it last.

## Keybinds — the sane defaults

zsh defaults to emacs-mode line editing (`Ctrl-A` = start of line, `Ctrl-E` = end, `Ctrl-R` = history search). Same as bash. Only worth knowing:

| Key | Does |
|---|---|
| `Ctrl-A` / `Ctrl-E` | line start / end |
| `Ctrl-R` | search history backward |
| `Ctrl-U` | delete line |
| `Ctrl-W` | delete previous word |
| `Ctrl-L` | clear screen |
| `Ctrl-F` (our bind) | accept autosuggestion |
| `↑` / `↓` | history prev/next |
| `Alt-.` | insert last argument of previous command |

If you prefer vi-mode: `bindkey -v` in your config. Kun doesn't and neither do I — vi-mode in a prompt is more effort than it's worth. Save vi keybinds for Neovim.

## History

`HISTSIZE` (in-memory, per-session), `SAVEHIST` (on disk), `HISTFILE` (path). Ours:

```
HISTFILE=~/.zsh_history
HISTSIZE=100
SAVEHIST=10000
setopt HIST_IGNORE_DUPS    # don't record two identical commands in a row
setopt SHARE_HISTORY       # share history across concurrent sessions
```

`Ctrl-R` searches this. Autosuggestions read from it.

## Debugging zsh startup

Slow shell? Time it:

```
time zsh -i -c exit
```

Anything over 200ms means something is doing work on startup. To find what:

```
zsh -xv 2>&1 | head -200
```

The `-x` traces every command; `-v` echoes each line before executing. Redirect to a file and diff between working and slow states.

## Further reading

- `man zshall` — the mother of all man pages; 800+ pages of everything zsh
- **[zsh.sourceforge.io/Guide/](https://zsh.sourceforge.io/Guide/)** — user-friendly guide by the developers
- **[zsh vs bash](https://apple.stackexchange.com/questions/361870/what-are-the-practical-differences-between-bash-and-zsh)** — SO answer, good practical diff
- **starship docs**: <https://starship.rs/config/> — prompt customization
