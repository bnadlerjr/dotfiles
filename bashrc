# RVM Setup
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin

. ~/dotfiles/bash/env
. ~/dotfiles/bash/git-completion.bash
. ~/dotfiles/bash/git-prompt
. ~/dotfiles/bash/config
. ~/dotfiles/bash/aliases

# Allow git-completion to work with "g" alias
__git_complete g __git_main

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# added by travis gem
[ -f /Users/numfar/.travis/travis.sh ] && source /Users/numfar/.travis/travis.sh

if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi
