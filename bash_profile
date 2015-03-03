if [ -f ~/.bashrc ]; then
        source ~/.bashrc
fi

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# Git bash completion
which -s brew
if [[ $? != 0 ]] ; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
      . $(brew --prefix)/etc/bash_completion
    fi
fi
