#!/bin/bash
# Notification hook: fires when Claude Code wants the human's input mid-run
# (e.g., a permission prompt, a tool needs confirmation, or an ambiguous
# decision). Mark the tmux window as "attention needed" so a glance at the
# status bar reveals which agent is waiting.

"$HOME/.claude/hooks/tmux-mark.sh" attention 2>/dev/null || true

# Also send an OS notification (regardless of duration — attention events
# are always worth surfacing).
osascript -e 'display notification "Claude needs input" with title "Claude Code" sound name "Purr"' 2>/dev/null || true
