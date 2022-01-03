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

# asdf setup
. $(brew --prefix)/opt/asdf/libexec/asdf.sh
. $(brew --prefix)/opt/asdf/etc/bash_completion.d/asdf.bash

# Yarn setup (must come after asdf setup since Yarn is managed by asdf)
export PATH="$(yarn global bin):$PATH"

# Setup direnv
eval "$(direnv hook bash)"
