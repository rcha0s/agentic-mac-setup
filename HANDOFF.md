# Handoff: Kun-style agentic setup (No-Nix path)

**Status:** the no-Nix install has run. Most of the stack is live on this machine.

## What's installed and working

**Homebrew formulas:**
- tmux, neovim, starship
- zsh-autosuggestions, zsh-syntax-highlighting
- gh, ripgrep, fd, jq, lazygit, fastfetch

**Config symlinks** (edit the sources under `~/github/agentic-mac-setup/files/`):
- `~/.config/wezterm/` → `files/.config/wezterm/`
- `~/.config/nvim/` → `files/.config/nvim/`
- `~/.config/starship.toml` → `files/.config/starship.toml`
- `~/.tmux.conf` → `files/.tmux.conf`
- `~/.zshrc.local` → `files/zshrc.local`
- `~/.zshrc`: has a source line at the bottom loading `.zshrc.local`
- `~/.claude/hooks/*.sh` → `files/claude-hooks/*.sh` (6 hooks: turn
  lifecycle + tmux status integration)

**Agentic CLIs** (Volta-managed for npm, `~/.local/bin` for the two Go tools):
- `gh-axi`, `chrome-devtools-axi`, `tasks-axi`, `lavish-axi`, `gnhf`
- `no-mistakes`, `treehouse`

**Claude Code skills** (already visible in this session):
- `gh-axi`, `chrome-devtools-axi`, `tasks-axi`, `lavish`

**SessionStart hooks** registered for Claude Code, Codex, and OpenCode:
- gh-axi, chrome-devtools-axi, tasks-axi ambient context on session start

**gnhf config** at `~/.gnhf/config.yml`

**firstmate cloned** at `~/github/firstmate/`

## What you still need to do manually

### 1. Install WezTerm.app

Default path:
```bash
brew install --cask wezterm
```

**If your Mac uses Workbrew (or another enterprise Homebrew wrapper) and the
cask is blocked**, either request the cask via `brew workbrew request wezterm`
and re-run, or install directly:
1. <https://wezterm.org/install/macos.html>
2. Download `WezTerm-macos-*.zip`
3. Unzip and drag `WezTerm.app` to `/Applications` (or `~/Applications/` if
   `/Applications` is locked by MDM)
4. Launch. It reads `~/.config/wezterm/wezterm.lua` automatically.

**Amethyst** (optional tiling window manager): `brew install --cask amethyst`,
or download from <https://ianyh.com/amethyst/>.

### 2. Restart your shell

```bash
exec zsh
```

You'll be inside a tmux `main` session with the new prompt.

### 3. Install tmux plugins (one-time)

Inside tmux, press `C-a I` (capital I). tmux-resurrect + tmux-continuum install. Takes ~10 seconds.

### 4. Neovim first-run (bootstrap plugins)

```bash
nvim
```

lazy.nvim will clone itself + install oil.nvim, neogit, snacks.nvim, diffview. Watch the progress; press `q` when done. Quit and reopen.

### 5. Authenticate `gh`

```bash
gh auth login
```

Needed by `gh-axi`, `no-mistakes`, and `firstmate`.

### 6. Per-repo (opt-in): enable `no-mistakes`

```bash
cd <your-repo>
no-mistakes init
```

### 7. Activate the Claude Code turn-lifecycle hooks

The installer symlinks the hook scripts into `~/.claude/hooks/` but does
not modify your `~/.claude/settings.json` (which already contains
per-user secrets and permissions we should not clobber). One-time
manual wiring:

1. Open `~/.claude/settings.json` in your editor.
2. Open `files/claude-hooks/settings.example.json` in the fork.
3. Copy the three entries under the example's `hooks` block
   (`UserPromptSubmit`, `Stop`, `Notification`) into your settings.json's
   `hooks` block. If the block does not exist, add it. If there are
   already `UserPromptSubmit` or `Stop` entries (from other tools like
   the `auto-permissions-from-plan` skill), append rather than replace.
4. Save and restart Claude Code.

What activates:
- Per-pane and session-wide tmux status indicators (green/gray/yellow)
- macOS notification when a turn takes over 10 seconds
- macOS notification when Claude wants your input mid-run

See `docs/LEARN-TMUX.md` "Agent status indicators" for the full picture.

## Where to learn each piece

- `docs/LEARN-WEZTERM.md`: terminal basics, config, videos
- `docs/LEARN-TMUX.md`: the load-bearing primitive; learn this first
- `docs/LEARN-NEOVIM.md`: modes, motions, plugin keybinds, learning path
- `docs/LEARN-AGENTIC.md`: full Kun-style workflow across all 7 agentic tools

## The Nix files are still here: why?

`flake.nix`, `nix/host.nix`, `nix/user.nix`, `setup/mac.sh`, `setup/agentic.sh`, `tests/mac_setup_test.sh` are the **Nix-based reproducibility path** from the upstream repo, preserved for future use.

You can ignore them for now. If you later decide reproducibility across machines is worth the trade-off (personal Mac, or work-Mac after IT clearance), running `bash setup/mac.sh` on a fresh Mac will land the same setup + our seeded configs.

`setup/install-noix.sh` is what we ran here. It's idempotent, safe to re-run to pick up changes.

## Verification checklist

- [ ] `exec zsh` → prompt is starship-styled
- [ ] Shell auto-attaches to tmux `main` session
- [ ] `tmux ls` shows `main`
- [ ] `C-a d` detaches; new terminal window re-attaches to same session
- [ ] `nvim` opens; after first-run bootstrap, `:Oil` shows filesystem
- [ ] `<space><space>` in nvim opens snacks smart picker
- [ ] `<space>gg` in nvim opens Neogit
- [ ] `gh-axi --help` works
- [ ] `gnhf --help` works
- [ ] `treehouse --help` works
- [ ] `no-mistakes --help` works
- [ ] `ls ~/.claude/skills/` shows the four AXI skills
- [ ] `claude` in any repo: SessionStart output mentions gh/chrome/tasks ambient context
- [ ] Reboot: `tmux attach` restores the session (tmux-resurrect)

## Remote access: deliberately skipped

Kun's Layer 4 setup (Tailscale + mosh) enables SSH-from-phone into your
Mac over a WireGuard mesh. **mosh** is installed. **Tailscale is skipped**
on this work Mac:

- Tailscale creates a second encrypted tunnel that corporate security
 can't inspect, a classic split-tunnel / exfiltration flag.
- Would broaden attack surface on the corp Mac for a personal-productivity
 win, not a work need.
- On an enterprise-managed Mac, a request to allowlist it is likely to be
 denied.

If you ever move this setup to a personal Mac, install Tailscale via
`brew install --cask tailscale`, sign in, `tailscale up`, then SSH via the
device's `*.tail….ts.net` hostname. mosh handles connection drops.

## Reverting the install

Non-destructive, everything's user-scoped and reversible.

**Remove config symlinks:**
```bash
for f in ~/.config/wezterm ~/.config/nvim ~/.config/starship.toml ~/.tmux.conf ~/.zshrc.local; do
 [ -L "$f" ] && rm "$f"
done
```

**Restore ~/.zshrc:**
Remove the `# kun-chen agentic stack` lines (the last 2 lines of `~/.zshrc`).

**Uninstall brew formulas** (only the ones you don't want to keep):
```bash
brew uninstall tmux neovim starship zsh-autosuggestions zsh-syntax-highlighting fd jq lazygit fastfetch
```

**Uninstall npm globals:**
```bash
npm uninstall -g gh-axi chrome-devtools-axi tasks-axi lavish-axi gnhf
```
(or `volta uninstall <package>` since Volta manages them)

**Remove Go tools:**
```bash
rm -rf ~/.no-mistakes ~/.local/bin/no-mistakes ~/.local/bin/treehouse
```

**Remove skills:**
```bash
rm -rf ~/.agents/skills ~/.claude/skills/{gh-axi,chrome-devtools-axi,tasks-axi,lavish}
```

**Remove firstmate:**
```bash
rm -rf ~/github/firstmate
```

**Restore any backed-up configs:**
```bash
ls ~/.config/*.pre-kun-* ~/.tmux.conf.pre-kun-* 2>/dev/null
```

## Remotes

- `origin` → `github.com/rcha0s/agentic-mac-setup` (your published repo)
- `upstream` → `github.com/kunchenguid/dotfiles-mac-nix` (Kun's original)

To pull upstream changes later:

```bash
cd ~/github/agentic-mac-setup
git fetch upstream
git merge upstream/main
git push origin main
```
