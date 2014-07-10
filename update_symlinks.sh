#!/bin/bash

# Get the directory this script is stored in; assumes dotfiles to be symlinked
# are in the same directory as this file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOTFILES=( ackrc bash_profile bashrc ctags emacs.d gemrc gitconfig gitignore_global gvimrc tmux.conf vimrc vim )

for dotfile in "${DOTFILES[@]}"
do
    file_path=${DIR}/${dotfile}
    symlink_path=~/.${dotfile}
    echo; echo "Symlinking ${file_path} to ${symlink_path}"
    if [ -f $symlink_path ];
    then
        read -p "${symlink_path} exists, overwrite? (y/n) " -n 1 -r
        if [[ ^[Yy]$ =~ $REPLY ]]
        then
            rm $symlink_path
            ln -s $file_path $symlink_path
            echo " ...overwrote ${symlink_path}"
        else
            echo " ...skipped"
        fi
    else
        ln -s $file_path $symlink_path
        echo " ...${symlink_path} created"
    fi
done
