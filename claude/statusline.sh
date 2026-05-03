#!/usr/bin/env bash
# Status line for Claude Code. Reads the JSON status payload from stdin and prints
# one ANSI-colored line: model | context | git-branch | git-changes | version.
set -uo pipefail

readonly CYAN=$'\033[36m'
readonly GRAY=$'\033[90m'
readonly MAGENTA=$'\033[35m'
readonly YELLOW=$'\033[33m'
readonly RESET=$'\033[0m'
readonly SEP=" | "

input="$(cat)"

model="$(jq -r '.model.display_name // "?"' <<<"$input" 2>/dev/null || echo "?")"
version="$(jq -r '.version // "?"' <<<"$input" 2>/dev/null || echo "?")"
cwd="$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input" 2>/dev/null || echo "")"

# Context info comes from Claude Code directly (.context_window). Older CLI
# versions without this field degrade to "? (?)".
tokens_label="?"
pct_label="?"
n="$(jq -r '.context_window.current_usage
            | (.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens)' \
     <<<"$input" 2>/dev/null)"
pct="$(jq -r '.context_window.used_percentage // empty' <<<"$input" 2>/dev/null)"
[[ "$n" =~ ^[0-9]+$ ]] && tokens_label="$((n / 1000))k"
[[ "$pct" =~ ^[0-9]+$ ]] && pct_label="${pct}%"

branch=""
changes=""
if [[ -n "$cwd" ]] && cd "$cwd" 2>/dev/null && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch="$(git branch --show-current 2>/dev/null || true)"
    shortstat="$(git diff HEAD --shortstat 2>/dev/null || true)"
    adds="$(grep -oE '[0-9]+ insertion' <<<"$shortstat" | grep -oE '[0-9]+' || echo 0)"
    dels="$(grep -oE '[0-9]+ deletion' <<<"$shortstat" | grep -oE '[0-9]+' || echo 0)"
    changes="+${adds:-0} -${dels:-0}"
fi

parts=()
parts+=("${CYAN}${model}${RESET}")
parts+=("${GRAY}${tokens_label} (${pct_label})${RESET}")
[[ -n "$branch" ]] && parts+=("${MAGENTA}⎇ ${branch}${RESET}")
[[ -n "$changes" ]] && parts+=("${YELLOW}${changes}${RESET}")
parts+=("v${version}")

out=""
for i in "${!parts[@]}"; do
    (( i > 0 )) && out+="$SEP"
    out+="${parts[$i]}"
done
printf '%s' "$out"
