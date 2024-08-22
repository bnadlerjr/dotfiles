. ~/dotfiles/bash/env
. $(brew --prefix)/etc/bash_completion.d/git-completion.bash
. $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
. ~/dotfiles/bash/git-prompt
. ~/dotfiles/bash/config
. ~/dotfiles/bash/aliases

# Allow git-completion to work with "g" alias
__git_complete g __git_main

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# asdf setup
if [ -f $(brew --prefix)/opt/asdf/libexec/asdf.sh ]; then
    # For new M1 systems
    . $(brew --prefix)/opt/asdf/libexec/asdf.sh
fi

if [ -f $(brew --prefix)/opt/asdf/asdf.sh ]; then
    # For older systems
    . $(brew --prefix)/opt/asdf/asdf.sh
fi

. $(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash

# Yarn setup (must come after asdf setup since Yarn is managed by asdf)
export PATH="$(yarn global bin):$PATH"

# Setup direnv
eval "$(direnv hook bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -f ~/.local/bashrc ]; then
    . ~/.local/bashrc
fi
