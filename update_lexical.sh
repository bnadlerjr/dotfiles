#!/bin/bash
set -euxo pipefail

# Updates Thesaurus and dictionary for vim-lexical

wget -O ~/.vim/thesaurus/mthesaur.txt https://raw.githubusercontent.com/zeke/moby/master/words.txt
