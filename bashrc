. ~/bin/dotfiles/bash/env
. ~/bin/dotfiles/bash/git-completion
. ~/bin/dotfiles/bash/git-prompt
. ~/bin/dotfiles/bash/config
. ~/bin/dotfiles/bash/aliases
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# added by travis gem
[ -f /Users/numfar/.travis/travis.sh ] && source /Users/numfar/.travis/travis.sh
