#!/bin/bash
# UserPromptSubmit hook: record turn-start timestamp AND mark the tmux
# window as "running". Non-fatal on either failure.

STATE_DIR="${HOME}/.claude/state"
mkdir -p "$STATE_DIR"
date +%s > "$STATE_DIR/turn-start.epoch"

# Mark the current tmux window (no-op outside tmux)
"$HOME/.claude/hooks/tmux-mark.sh" running 2>/dev/null || true
