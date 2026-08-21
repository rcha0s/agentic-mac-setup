#!/usr/bin/env bash
# PreToolUse hook for ExitPlanMode: nudges Claude to run the
# `auto-permissions-from-plan` skill so that the just-approved plan's
# implementation can proceed without unnecessary permission prompts.
#
# This hook is non-blocking. It only emits additionalContext that tells
# Claude to invoke the skill BEFORE the first non-permission tool call
# in the implementation phase.
#
# The skill itself is responsible for the safety rails (no destructive
# auto-allows, project-local only, narrow patterns, idempotent merge).
set -u
input=$(cat)

# Only fire on ExitPlanMode events
tool_name=$(printf '%s' "$input" | jq -r '.tool_name // ""' 2>/dev/null)
[ "$tool_name" = "ExitPlanMode" ] || exit 0

msg="MANDATORY FIRST ACTION: The plan has just been approved. Before ANY tool call to start implementing, you MUST invoke the \`auto-permissions-from-plan\` skill via the Skill tool. This is not optional — skipping it causes the exact permission-fatigue the user is trying to eliminate.\n\nHard rules the skill enforces: never auto-allow destructive commands (rm -rf, force-push, --no-verify, terraform destroy, etc.); project-local only (never global); narrow patterns over broad ones; idempotent merge against existing entries.\n\nInvoke it now with: Skill(skill=\"auto-permissions-from-plan\"). After the skill prints its summary, continue with the planned implementation."

jq -n --arg ctx "$msg" '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$ctx}}'
exit 0
