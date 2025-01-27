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
# All of these must be available on $PATH:
# * fd
# * tmux
# * my personal fork of tmuxinator that has "pause" and "resume" support
#
# [1]: https://frontendmasters.com/courses/developer-productivity/

mux="$HOME/dev/personal/tmuxinator/bin/tmuxinator"

# Function to check if tmuxinator is available
tmuxinator_available() {
  if [[ -x "$mux" ]]; then
    return 0
  fi
  return 1
}

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
#
# When / if I switch to stow I can probably move the folder & remove this hack.
projects+=$'\n'"$HOME/dotfiles"
session=$(echo "$projects" | fzf)

if [[ -z $session ]]; then
    exit 0
fi

session_name=$(basename "$session")

# If tmux isn't running at all, we always want to start a new session.
if ! tmux info &> /dev/null; then
    # Check if there's a tmuxinator config that matches the project name. If
    # so, start a new session using tmuxinator and the config. Otherwise, start
    # a new plain tmux session.
    if tmuxinator_available && $mux list -n | grep -F -q -x "$session_name"; then
        $mux start "$session_name"
    else
        tmux new-session -s "$session_name" -c "$session" -n "workspace"
    fi
    exit 0
fi

# If there's currently a tmuxinator session running, pause it.
current_tmux_session_name=$(tmux display-message -p "#S")
if tmuxinator_available && $mux list -n | grep -F -q -x "$current_tmux_session_name"; then
    $mux pause "$current_tmux_session_name"
fi

# If tmux is running but doesn't have a session for the project, start one
# using the same logic as above.
if ! tmux has-session -t="$session_name" 2> /dev/null; then
    if tmuxinator_available && $mux list -n | grep -F -q -x "$session_name"; then
        $mux start "$session_name" --no-attach
    else
        tmux new-session -ds "$session_name" -c "$session" -n "workspace"
    fi
fi

# If the session we're connecting to has a tmuxinator config, resume it.
if tmuxinator_available && $mux list -n | grep -F -q -x "$session_name"; then
    $mux resume "$session_name"
fi

# Prevent nesting of tmux sessions. If tmux is already running, switch to the
# session we just created. If it's not running, attach to the session instead.
if [ -n "$TMUX" ]; then
    if tmux has-session -t="$session_name" 2> /dev/null; then
        tmux switch-client -t "$session_name"
    fi
else
    tmux attach -t "$session_name"
fi
