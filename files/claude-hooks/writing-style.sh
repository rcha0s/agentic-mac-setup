#!/usr/bin/env bash
# UserPromptSubmit hook: if the prompt describes writing user-facing prose
# destined for a Google Doc or Confluence page, nudge Claude to invoke the
# `writing-style` skill BEFORE drafting.
#
# The skill owns the actual rules. This hook's job is to keep the nudge
# OFF for chat, code, commits, PRs.
#
# Non-blocking; always exits 0.
set -u
input=$(cat)

prompt=$(printf '%s' "$input" | jq -r '.prompt // ""' 2>/dev/null)
[ -n "$prompt" ] || exit 0

# Signal 1: an authoring verb.
verb_re='(^|[^[:alnum:]_])(write|draft|create|update|revise|rewrite|edit|compose|author|prepare)([^[:alnum:]_]|$)'
if ! printf '%s' "$prompt" | grep -Eiq "$verb_re"; then
  exit 0
fi

# Signal 2: destination is a Google Doc or Confluence wiki.
# Match either the platform name/URL or the artifact type ("google doc",
# "wiki page", "confluence page"). Deliberately narrow — do NOT match
# "readme", "markdown file", "PR description", "commit message".
dest_re='(google[[:space:]-]?docs?|docs\.google\.com|confluence|wiki[[:space:]-]?page|smar-wiki|atlassian\.net/wiki|gws docs)'
if ! printf '%s' "$prompt" | grep -Eiq "$dest_re"; then
  exit 0
fi

msg="MANDATORY BEFORE DRAFTING: This prompt asks you to produce user-facing prose for a Google Doc or Confluence page. Before writing any prose (including a first draft in a scratchpad), invoke the \`writing-style\` skill via the Skill tool. The skill lists the AI-tell patterns to avoid at the sentence and structural level. Skipping it produces prose that reads as AI-generated and undermines reader trust — the whole point of using this skill.\n\nInvoke it now with: Skill(skill=\"writing-style\"). Then draft."

jq -n --arg ctx "$msg" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$ctx}}'
exit 0
