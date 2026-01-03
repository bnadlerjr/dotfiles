#!/bin/bash

# Get the directory this script is stored in; assumes dotfiles to be symlinked
# are in the same directory as this file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOTFILES=( asdfrc bash_profile bashrc ctags default-gems default-npm-packages editorconfig emacs.d gemrc gitconfig gitignore_global gvimrc iex.exs lein psqlrc tmux.conf tool-versions vimrc vim )

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
        echo " ...removing folder ${symlink_path}"
        rm -r $symlink_path
        ln -s $file_path $symlink_path
        echo " ...${symlink_path} re-linked"
    fi
done

echo " ...removing bin folder"
rm -r ~/bin
ln -s ${DIR}/bin ~/bin
echo " ...bin folder re-linked"

echo " ...removing ghostty folder"
rm -r ~/.config/ghostty
ln -s ${DIR}/ghostty ~/.config/ghostty
echo " ...ghostty folder re-linked"

echo " ...removing ~/.claude/CLAUDE.md"
rm -r ~/.claude/CLAUDE.md
ln -s ${DIR}/claude/CLAUDE-PERSONAL.md ~/.claude/CLAUDE.md
echo " ...~/.claude/CLAUDE.md re-linked"

echo " ...removing ~/.claude/settings.json"
rm -r ~/.claude/settings.json
ln -s ${DIR}/claude/settings.json ~/.claude/settings.json
echo " ...~/.claude/settings.json re-linked"

echo " ...removing ~/.config/ccstatusline/settings.json"
rm -r ~/.config/ccstatusline/settings.json
ln -s ${DIR}/claude/ccstatusline.json ~/.config/ccstatusline/settings.json
echo " ...~/.config/ccstatusline/settings.json re-linked"

echo " ...removing ~/.claude/commands"
rm -r ~/.claude/commands
ln -s ${DIR}/claude/commands ~/.claude/commands
echo " ...~/.claude/commands re-linked"

echo " ...removing ~/.claude/agents"
rm -r ~/.claude/agents
ln -s ${DIR}/claude/agents ~/.claude/agents
echo " ...~/.claude/agents re-linked"

echo " ...removing ~/.claude/skills"
rm -r ~/.claude/skills
ln -s ${DIR}/claude/skills ~/.claude/skills
echo " ...~/.claude/skills re-linked"

echo " ...removing ~/.config/karabiner/karabiner.json"
rm -r ~/.config/karabiner/karabiner.json
ln -s ${DIR}/karabiner/karabiner.json ~/.config/karabiner/karabiner.json
echo " ...~/.config/karabiner/karabiner.json re-linked"
