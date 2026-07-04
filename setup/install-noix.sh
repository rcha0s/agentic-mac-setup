#!/bin/bash
#
# install-noix.sh — No-Nix install path for Kun Chen's agentic setup.
#
# What this does:
#   1. brew install: tmux, neovim, starship, zsh-autosuggestions,
#      zsh-syntax-highlighting (all under Workbrew's default allowlist).
#      Casks: wezterm, amethyst (optional, gated by INSTALL_CASKS).
#   2. Symlinks the seeded configs from this fork into $HOME/.config/* and
#      $HOME/.tmux.conf. Backs up any existing non-symlink files first.
#   3. Appends a source line to ~/.zshrc so zshrc.local is loaded.
#   4. Runs setup/agentic.sh to install the AXI + gnhf + no-mistakes +
#      treehouse + firstmate stack.
#
# What this does NOT do:
#   - Determinate Nix installer (no /nix volume, no launchd daemon, no nixbld
#     users, no /etc/zshrc modification).
#   - System-wide sudo mutations. Every step is user-scoped.
#   - Overwrite existing files without backing them up first.
#
# Flags:
#   DRY_RUN=1     preview commands without running them
#   SKIP_BREW=1   skip Homebrew installs (assumes tools present)
#   SKIP_CASKS=1  skip wezterm/amethyst casks (default: install them)
#   SKIP_AGENTIC=1  skip the agentic stack install
#   SKIP_ZSHRC=1  don't touch ~/.zshrc
#
# Usage:
#   cd ~/github/agentic-mac-setup
#   bash setup/install-noix.sh

set -euo pipefail

DOTFILES_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
DRY_RUN="${DRY_RUN:-0}"

log()  { printf '\033[1;34m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[install]\033[0m %s\n' "$*" >&2; }
run()  {
  if [ "$DRY_RUN" = "1" ]; then
    printf '\033[2m  would run: %s\033[0m\n' "$*"
  else
    "$@"
  fi
}

# --- 1. Homebrew packages --------------------------------------------------

if [ "${SKIP_BREW:-0}" != "1" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    warn "brew not found; skipping package install. Install Homebrew (or use Workbrew) and re-run."
  else
    log "installing formulas via brew"
    for f in tmux neovim starship zsh-autosuggestions zsh-syntax-highlighting gh ripgrep fd jq lazygit fastfetch; do
      if brew list --formula "$f" >/dev/null 2>&1; then
        log "  already installed: $f"
      else
        log "  installing: $f"
        run brew install "$f" || warn "failed to install $f (Workbrew allowlist?) — continuing"
      fi
    done

    if [ "${SKIP_CASKS:-0}" != "1" ]; then
      log "installing casks via brew"
      for c in wezterm amethyst; do
        if brew list --cask "$c" >/dev/null 2>&1; then
          log "  already installed: $c"
        else
          log "  installing cask: $c"
          run brew install --cask "$c" || warn "failed to install cask $c (Workbrew allowlist?) — continuing"
        fi
      done
    fi
  fi
fi

# --- 2. Symlink configs ----------------------------------------------------

backup_and_link() {
  local src="$1"   # absolute path inside the fork
  local dst="$2"   # absolute path in $HOME
  local dst_dir
  dst_dir=$(dirname "$dst")
  run mkdir -p "$dst_dir"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      log "  symlink already correct: $dst"
      return
    fi
    log "  replacing existing symlink: $dst"
    run rm "$dst"
  elif [ -e "$dst" ]; then
    local bkp="${dst}.pre-kun-$(date +%Y%m%d-%H%M%S)"
    log "  backing up existing $dst → $bkp"
    run mv "$dst" "$bkp"
  fi
  log "  linking $src → $dst"
  run ln -s "$src" "$dst"
}

log "symlinking seeded configs"
backup_and_link "$DOTFILES_DIR/files/.config/wezterm"  "$HOME/.config/wezterm"
backup_and_link "$DOTFILES_DIR/files/.config/nvim"     "$HOME/.config/nvim"
backup_and_link "$DOTFILES_DIR/files/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$DOTFILES_DIR/files/.tmux.conf"       "$HOME/.tmux.conf"

# zshrc.local is a personal file bootstrapped from a public template on
# first run. Never overwrite an existing one.
if [ ! -f "$DOTFILES_DIR/files/zshrc.local" ]; then
  log "creating files/zshrc.local from files/zshrc.local.example"
  run cp "$DOTFILES_DIR/files/zshrc.local.example" "$DOTFILES_DIR/files/zshrc.local"
fi
backup_and_link "$DOTFILES_DIR/files/zshrc.local"      "$HOME/.zshrc.local"

# --- 3. Wire zshrc.local into ~/.zshrc -------------------------------------

if [ "${SKIP_ZSHRC:-0}" != "1" ]; then
  ZSHRC="$HOME/.zshrc"
  MARKER="# kun-chen agentic stack: source zshrc.local"
  if [ ! -f "$ZSHRC" ]; then
    log "creating $ZSHRC"
    run touch "$ZSHRC"
  fi
  if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
    log "$ZSHRC already sources zshrc.local"
  else
    log "appending zshrc.local source line to $ZSHRC"
    if [ "$DRY_RUN" != "1" ]; then
      {
        printf '\n%s\n' "$MARKER"
        printf '[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"\n'
      } >> "$ZSHRC"
    fi
  fi
fi

# --- 4. Agentic stack ------------------------------------------------------

if [ "${SKIP_AGENTIC:-0}" != "1" ]; then
  log "running setup/agentic.sh"
  DRY_RUN="$DRY_RUN" run bash "$DOTFILES_DIR/setup/agentic.sh"
fi

log "install-noix complete."
log ""
log "next steps:"
log "  1. Restart your terminal (or 'exec zsh') to pick up ~/.zshrc.local."
log "  2. Open WezTerm — it will use $HOME/.config/wezterm/wezterm.lua."
log "  3. In tmux, press prefix (C-a) + I to install the tmux plugins on first run."
log "  4. gh auth login (if you haven't already) — needed by gh-axi, no-mistakes, firstmate."
log "  5. In each repo where you want pre-push validation: no-mistakes init"
