#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Opens a project in a tmux session.
#
# Pipes results of `fd` for project directories to `FZF`. Takes the result and
# either creates a new tmux session (with the name of the project) or attaches
# to a session if one already exists for that project.
#
# The inspiration for this came from @ThePrimeagen's [Developer Productivity][1]
# course.
#
# Requirements:
# * tmux
# * fd
#
# [1]: https://frontendmasters.com/courses/developer-productivity/

directories=$(fd --hidden --exact-depth 1 --type directory . \
            ~/dev/personal \
            ~/dev/flatiron \
            )

# I want dotfiles as a project, but it's in my $HOME directory and I don't want
# to move it & break the symlink script. So I'm appending the dotfiles directory
# to the list explicitly. Note the use of $'' which is required to insert the
# newline.
#
# When / if I switch to stow I can probably move the folder & remove this hack.
projects="$directories"$'\n'"$HOME/dotfiles"
session=$(echo "$projects" | fzf)

if [[ -z $session ]]; then
    exit 0
fi

session_name=$(basename "$session")

if ! tmux info &> /dev/null; then
    tmux new-session -s "$session_name" -c "$session"
    exit 0
fi

if ! tmux has-session -t="$session_name" 2> /dev/null; then
    tmux new-session -ds "$session_name" -c "$session"
fi

tmux switch-client -t "$session_name"
