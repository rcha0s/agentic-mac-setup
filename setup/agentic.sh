#!/bin/bash
#
# agentic.sh — install Kun Chen's agentic tooling stack on top of the Nix base.
#
# Called at the end of setup/mac.sh. Safe to run standalone and re-run.
# Every step is idempotent: presence checks before install.
#
# Installs:
#   - AXI skills:   gh-axi, chrome-devtools-axi, tasks-axi, lavish-axi
#   - Orchestration: gnhf, no-mistakes, treehouse, firstmate (clone only)
#
# Prereqs (checked below): node >= 20, npm, gh, git, curl.
#
# Skip with:  SKIP_AGENTIC=1 bash setup/mac.sh
# Dry-run:    DRY_RUN=1 bash setup/agentic.sh

set -euo pipefail

DRY_RUN="${DRY_RUN:-0}"

log() { printf '\033[1;34m[agentic]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[agentic]\033[0m %s\n' "$*" >&2; }
run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '\033[2m  would run: %s\033[0m\n' "$*"
  else
    "$@"
  fi
}

require() {
  local cmd="$1"
  local hint="${2:-install it and re-run}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "missing required command: $cmd — $hint"
    exit 1
  fi
}

# --- Prereqs ---------------------------------------------------------------

log "checking prerequisites"
require node "run setup/mac.sh first so nvm + Node LTS is installed"
require npm  "npm ships with node"
require git  "should be provided by the Nix base"
require gh   "install via 'brew install gh' or add to nix/user.nix"
require curl "should be present on macOS"

node_major=$(node -v | sed 's/^v//; s/\..*//')
if [ "$node_major" -lt 20 ]; then
  warn "node version < 20 detected ($(node -v)). AXI tools require Node 20+."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  warn "gh is not authenticated. Run 'gh auth login' before using gh-axi / firstmate."
fi

# --- Global npm packages ---------------------------------------------------

install_npm_global() {
  local pkg="$1"
  if npm ls -g --depth=0 --parseable 2>/dev/null | grep -q "/${pkg}$"; then
    log "already installed globally: $pkg"
  else
    log "installing globally: $pkg"
    run npm install -g "$pkg"
  fi
}

log "installing AXI CLIs (npm globals)"
install_npm_global gh-axi
install_npm_global chrome-devtools-axi
install_npm_global tasks-axi
install_npm_global lavish-axi
install_npm_global gnhf

# --- Claude Code skills ----------------------------------------------------

install_skill() {
  local repo="$1"
  local skill_name="$2"
  local skill_dir="$HOME/.claude/skills/${skill_name}"
  if [ -d "$skill_dir" ]; then
    log "skill already installed: $skill_name"
  else
    log "installing skill: $repo → $skill_name"
    run npx --yes skills add "$repo" --skill "$skill_name" -g
  fi
}

log "installing Claude Code skills"
install_skill kunchenguid/gh-axi              gh-axi
install_skill kunchenguid/chrome-devtools-axi chrome-devtools-axi
install_skill kunchenguid/tasks-axi           tasks-axi
install_skill kunchenguid/lavish-axi          lavish

# --- SessionStart hooks ----------------------------------------------------

log "registering SessionStart hooks"
run gh-axi setup hooks              || warn "gh-axi setup hooks failed (non-fatal)"
run chrome-devtools-axi setup hooks || warn "chrome-devtools-axi setup hooks failed (non-fatal)"
run tasks-axi setup hooks           || warn "tasks-axi setup hooks failed (non-fatal)"

# --- gnhf config -----------------------------------------------------------

GNHF_CFG="$HOME/.gnhf/config.yml"
if [ -f "$GNHF_CFG" ]; then
  log "gnhf config already present: $GNHF_CFG"
else
  log "writing gnhf config: $GNHF_CFG"
  run mkdir -p "$(dirname "$GNHF_CFG")"
  if [ "$DRY_RUN" != "1" ]; then
    cat > "$GNHF_CFG" <<'YAML'
agent: claude
maxConsecutiveFailures: 3
preventSleep: true
commitMessage:
  preset: conventional
YAML
  fi
fi

# --- no-mistakes -----------------------------------------------------------

if command -v no-mistakes >/dev/null 2>&1; then
  log "no-mistakes already installed"
else
  log "installing no-mistakes (curl | sh from kunchenguid/no-mistakes)"
  run bash -c 'curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh'
fi

# --- treehouse -------------------------------------------------------------

if command -v treehouse >/dev/null 2>&1; then
  log "treehouse already installed"
else
  log "installing treehouse (curl | sh from kunchenguid/treehouse)"
  run bash -c 'curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh' \
    || warn "treehouse install failed — check the README for the current install command"
fi

if command -v treehouse >/dev/null 2>&1 && [ ! -f "$HOME/.config/treehouse/config.toml" ]; then
  log "initializing treehouse config"
  run treehouse init
fi

# --- firstmate (clone only) ------------------------------------------------

FIRSTMATE_DIR="$HOME/github/firstmate"
if [ -d "$FIRSTMATE_DIR/.git" ]; then
  log "firstmate already cloned: $FIRSTMATE_DIR"
else
  log "cloning firstmate → $FIRSTMATE_DIR"
  run mkdir -p "$(dirname "$FIRSTMATE_DIR")"
  run git clone https://github.com/kunchenguid/firstmate.git "$FIRSTMATE_DIR"
fi

# --- Claude Code hint ------------------------------------------------------

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
HINT='Use `gh-axi` for GitHub and `chrome-devtools-axi` for browser automation. Prefer `tasks-axi` for backlog operations and `lavish-axi` for HTML-artifact review.'
if [ -f "$CLAUDE_MD" ] && grep -qF "gh-axi" "$CLAUDE_MD"; then
  log "CLAUDE.md AXI hint already present"
else
  log "appending AXI hint to $CLAUDE_MD"
  run mkdir -p "$(dirname "$CLAUDE_MD")"
  if [ "$DRY_RUN" != "1" ]; then
    printf '\n<!-- kun-chen agentic stack -->\n%s\n' "$HINT" >> "$CLAUDE_MD"
  fi
fi

log "agentic stack installed."
log "next steps:"
log "  - gh auth login              (if not already authenticated)"
log "  - cd ~/github/firstmate && claude    (opens the fleet supervisor)"
log "  - in any repo:  no-mistakes init     (per-repo, enables git push no-mistakes)"
