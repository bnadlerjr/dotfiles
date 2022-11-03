#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

languages=$(echo "bash clojure elixir javascript lua python ruby typescript" | tr " " "\n")
core_utils=$(echo "awk bat cat chmod chown cp docker docker-compose fd find git git-commit git-rebase git-status git-worktree grep head jq kill less ls lsof make mv ps rename rg rm sed ssh tail tar tr xargs" | tr " " "\n")

selected=$(echo -e "$languages\n$core_utils" | fzf)
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter Query: " query

if echo "$languages" | grep -qs "$selected"; then
    url="https://cht.sh/$selected/$(echo "$query" | tr " " "+")"
else
    url="https://cht.sh/$selected~$query"
fi

curl -s $url | less -R
