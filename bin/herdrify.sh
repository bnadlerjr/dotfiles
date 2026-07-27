#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Opens a project in a herdr workspace.
#
# The herdr twin of tmuxify.sh. Pipes results of `fd` for project directories to
# `FZF`. Takes the result and either creates a new herdr workspace (labeled with
# the project name) or focuses the workspace if one already exists for that
# project. Runs alongside tmuxify.sh during the herdr trial.
#
# All of these must be available on $PATH:
# * fd
# * fzf
# * herdr
# * jq

# Not all my machines have the same directories, so filter out the ones that
# don't exist on the machine that's running this script.
potential_directories=(
    ~/dev/cyrus
    ~/dev/flatiron
    ~/dev/gust
    ~/dev/instinct
    ~/dev/personal
    ~/dev/spikes
)

directories=()
for dir in "${potential_directories[@]}"; do
    if [ -d "$dir" ]; then
        # fd requires paths to be relative or absolute without tilde expansion
        expanded_dir=$(realpath "$dir")
        directories+=("$expanded_dir")
    fi
done

projects=$(fd --hidden --exact-depth 1 --type directory . "${directories[@]}")

# I want dotfiles as a project, but it's in my $HOME directory and I don't want
# to move it & break the symlink script. So I'm appending the dotfiles directory
# to the list explicitly. Note the use of $'' which is required to insert the
# newline.
projects+=$'\n'"$HOME/dotfiles"
selection=$(echo "$projects" | fzf)

if [[ -z $selection ]]; then
    exit 0
fi

label=$(basename "$selection")

# Ensure the herdr server is running so the workspace socket API is reachable.
# A successful `workspace list` is the liveness probe; if it fails, start a
# headless server and wait briefly for the socket. (borrowed from bin/herdr-workspace)
ensure_server() {
    herdr workspace list &> /dev/null && return 0
    herdr server &> /dev/null &
    for _ in $(seq 1 50); do
        herdr workspace list &> /dev/null && return 0
        sleep 0.1
    done
    echo "herdrify.sh: error: herdr server did not start" >&2
    exit 1
}

ensure_server

# Resolve an existing workspace for this project by its label, else create one.
# Matching is by exact label, same one-project-per-name assumption tmuxify makes
# with session names.
workspace_id=$(herdr workspace list |
    jq -r --arg label "$label" \
        '.result.workspaces[] | select(.label == $label) | .workspace_id' |
    head -n 1 || true)

if [[ -z $workspace_id ]]; then
    workspace_id=$(herdr workspace create \
        --cwd "$selection" \
        --label "$label" \
        --no-focus |
        jq -r '.result.workspace.workspace_id')
fi

herdr workspace focus "$workspace_id" > /dev/null

# If we're not already inside herdr, attach so the focused workspace is visible;
# detaching returns here, like tmuxify's `tmux attach`. Inside herdr the attached
# client already follows the focus change (and nesting is disabled by default).
if [[ -z ${HERDR_PANE_ID:-} ]]; then
    herdr
fi
