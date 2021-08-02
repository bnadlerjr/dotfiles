. ~/dotfiles/bash/env
. $(brew --prefix)/etc/bash_completion.d/git-completion.bash
. $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
. ~/dotfiles/bash/git-prompt
. ~/dotfiles/bash/config
. ~/dotfiles/bash/aliases

# Allow git-completion to work with "g" alias
__git_complete g __git_main

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# TODO: Figure out what I need to cleanup to get rid of this since I'm using asdf instead
export PATH="$PATH:$HOME/.rvm/bin"

# asdf setup
. $(brew --prefix)/opt/asdf/asdf.sh
. $(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash

# Setup direnv
eval "$(direnv hook bash)"
