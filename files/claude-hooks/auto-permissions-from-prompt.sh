#!/usr/bin/env bash
# UserPromptSubmit hook: if the just-submitted prompt describes concrete
# tool/command work, emit additionalContext nudging Claude to run the
# `auto-permissions-from-prompt` skill BEFORE the first tool call.
#
# The skill itself owns the safety rails (deny list, project-local only,
# narrow patterns, idempotent merge, ≥1-NEW threshold). This hook's only
# job is to keep the nudge OFF for conversational / non-action prompts.
#
# Non-blocking; always exits 0.
set -u
input=$(cat)

prompt=$(printf '%s' "$input" | jq -r '.prompt // ""' 2>/dev/null)
[ -n "$prompt" ] || exit 0

# Signal 1: an imperative-action verb anywhere in the prompt.
# Word-boundary regex, case-insensitive. No head-window: we accept
# front-loaded context like "in the auth module, please run ...".
verb_re='(^|[^[:alnum:]_])(run|build|test|install|deploy|commit|push|refactor|implement|fix|add|create|edit|write|remove|migrate|scaffold|generate|check|apply|start|stop|open|format|lint|verify|validate|list|pull|fetch|clone|debug|compile|bundle|restart|review|investigate|update|upgrade|setup|configure|rebuild|reinstall|rerun|reload|render|serve|watch|kill|spawn|launch|patch|revert|rollback|tag|release|package|publish|import|export|move|copy|rename|delete|drop|make|do)([^[:alnum:]_]|$)'
if ! printf '%s' "$prompt" | grep -Eiq "$verb_re"; then
  exit 0
fi

# Signal 2: a concrete tool token OR a shell-command signal (backticks
# or fenced code block) anywhere in the prompt.
# The `verb_that_is_a_command` set (commit, push, pull, fetch, clone,
# rebase, deploy, restart, rebuild, reinstall) satisfies signal 2 too
# — these words ARE the command, so "commit and push" needs no extra
# tool token to count.
tool_re='(^|[^[:alnum:]_/-])(npm|pnpm|yarn|bun|node|npx|pytest|ruff|mypy|pylint|flake8|black|isort|cargo|rustc|go|gofmt|make|cmake|gradle|mvn|docker|podman|kubectl|helm|terraform|ansible|gh|git|glab|curl|wget|jq|yq|nix|brew|apt|python|python3|pip|pip3|poetry|uv|tsc|eslint|prettier|biome|jest|vitest|playwright|sh|bash|zsh|awk|sed|grep|rg|ag|find|fd|ls|cat|head|tail|chmod|chown|ssh|scp|rsync|tmux|screen|psql|mysql|sqlite3|redis-cli|aws|gcloud|az|nvim|vim|code|commit|push|pull|fetch|clone|rebase|deploy|restart|rebuild|reinstall|checkout|merge|stash|amend|revert)([^[:alnum:]_-]|$)'
if ! printf '%s' "$prompt" | grep -Eiq "$tool_re" \
   && ! printf '%s' "$prompt" | grep -Eq '`[^`]+`|```'; then
  exit 0
fi

msg="MANDATORY FIRST ACTION: This prompt describes concrete tool/command work. Before ANY other tool call (including Read, Bash, Grep, or planning tools), you MUST invoke the \`auto-permissions-from-prompt\` skill via the Skill tool. This is not optional and not advisory — skipping it causes the exact permission-fatigue the user is trying to eliminate.\n\nThe skill will silently skip if there are no new permissions to add (existing allowlist already covers this prompt), so calling it when unneeded is cheap. It enforces the same deny list and project-local scope as \`auto-permissions-from-plan\` (writes ONLY to <project-root>/.claude/settings.local.json — never user-global).\n\nInvoke it now with: Skill(skill=\"auto-permissions-from-prompt\"). Then proceed with the task."

jq -n --arg ctx "$msg" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}'
exit 0
