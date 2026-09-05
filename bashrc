. ~/dotfiles/bash/env

# Resolve the Homebrew prefix once
BREW_PREFIX=""
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"
fi

# Completion framework; first available entry point wins. Must load before
# __git_complete is called below.
if [ -n "$BREW_PREFIX" ] && [ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]; then
  . "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
elif [ -r /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
  . /etc/bash_completion
fi

# git-completion.bash and git-prompt.sh must load eagerly for the prompt
if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
  . "$BREW_PREFIX/etc/bash_completion.d/git-completion.bash"
elif [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

if [ -n "$BREW_PREFIX" ] && [ -f "$BREW_PREFIX/etc/bash_completion.d/git-prompt.sh" ]; then
  . "$BREW_PREFIX/etc/bash_completion.d/git-prompt.sh"
elif [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt
fi

. ~/dotfiles/bash/git-prompt
. ~/dotfiles/bash/config
. ~/dotfiles/bash/aliases

# Allow git-completion to work with "g" alias
declare -F __git_complete >/dev/null && __git_complete g __git_main

if [ -n "$BREW_PREFIX" ]; then
  # asdf setup
  export ASDF_DATA_DIR="$HOME/.asdf"
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  if [ -f "$BREW_PREFIX/opt/asdf/etc/bash_completion.d/asdf" ]; then
    . "$BREW_PREFIX/opt/asdf/etc/bash_completion.d/asdf"
  fi
fi

if command -v direnv >/dev/null 2>&1; then
  # Setup direnv
  eval "$(direnv hook bash)"
fi

# Handle Homebrew install
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
  [ -f ~/.fzf-git.sh ] && . ~/.fzf-git.sh
# handle local Git Linux install
elif [ -f ~/.fzf.bash ]; then
  . ~/.fzf.bash
  [ -f ~/.fzf-git.sh ] && . ~/.fzf-git.sh
fi

if command -v mise &>/dev/null; then
  eval "$(mise activate bash)"
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if [ -f ~/.local/bashrc ]; then
  . ~/.local/bashrc
fi

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init bash)"; fi
