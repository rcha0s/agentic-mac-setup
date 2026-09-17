#!/bin/bash
# Stop hook: nudge /compact or /clear once a session's transcript grows
# past a size threshold. Long sessions cost more even with prompt
# caching, and the fix (compact mid-task, clear when switching tasks)
# is easy to forget mid-flow.
#
# Deliberately pure bash + wc, no Skill invocation. A prior hook
# (auto-permissions-from-prompt) invoked a full skill on every single
# UserPromptSubmit and ended up costing 60% of a user's usage. This
# hook exists to fix a similar cost problem, so it must not repeat that
# mistake: it only ever prints a notification, once per session.
#
# Override CLAUDE_CONTEXT_NUDGE_CHARS to change the threshold
# (default ~500000 chars, roughly 125k tokens at ~4 chars/token).

STATE_DIR="${HOME}/.claude/state"
THRESHOLD_CHARS="${CLAUDE_CONTEXT_NUDGE_CHARS:-500000}"

input=$(cat)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
session_id=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)

[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
[ -n "$session_id" ] || session_id="unknown"

mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
MARKER="$STATE_DIR/context-hygiene.$session_id.notified"

# Only nudge once per session — a long session that stays over
# threshold should not renotify on every subsequent turn.
[ -f "$MARKER" ] && exit 0

size=$(wc -c < "$transcript" 2>/dev/null | tr -d ' ')
case "$size" in
  ''|*[!0-9]*) exit 0 ;;
esac

[ "$size" -ge "$THRESHOLD_CHARS" ] || exit 0

touch "$MARKER" 2>/dev/null

approx_k_tokens=$(( size / 4 / 1000 ))
osascript -e "display notification \"~${approx_k_tokens}k tokens of context this session. /compact to keep going cheaper, /clear if starting something new.\" with title \"Claude Code context nudge\"" 2>/dev/null || true
