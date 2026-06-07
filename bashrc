. ~/dotfiles/bash/env

if command -v brew >/dev/null 2>&1; then
  . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
  . $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
fi

if [ -f /usr/share/bash-completion/completions/git ]; then
  . /usr/share/bash-completion/completions/git
fi

if [ -f /etc/bash_completion.d/git-prompt ]; then
  . /etc/bash_completion.d/git-prompt
fi

. ~/dotfiles/bash/git-prompt
. ~/dotfiles/bash/config
. ~/dotfiles/bash/aliases

# Allow git-completion to work with "g" alias
__git_complete g __git_main

if command -v brew >/dev/null 2>&1; then
  if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
  fi

  # asdf setup
  export ASDF_DATA_DIR="$HOME/.asdf"
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  . $(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf
fi

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi

if command -v yarn >/dev/null 2>&1; then
  # Yarn setup (must come after asdf setup since Yarn is managed by asdf)
  export PATH="$(yarn global bin):$PATH"
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
