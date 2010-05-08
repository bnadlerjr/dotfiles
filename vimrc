" .vimrc
" Bob Nadler, Jr.

" Settings
set autoread
set background=dark
set backspace=indent,eol,start

set cursorline
set expandtab
set hlsearch
set nocompatible
set number
set ruler
set guioptions-=T

if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
    set guifont=Lucida_Console:h10
else
    set runtimepath+=~/bin/dotfiles/vim/after
    set runtimepath+=~/bin/dotfiles/vim
    set runtimepath+=~/bin/dotfiles/vim/autoload
    set runtimepath+=~/bin/dotfiles/vim/doc
    set runtimepath+=~/bin/dotfiles/vim/ftplugin
    set runtimepath+=~/bin/dotfiles/vim/plugin
    set runtimepath+=~/bin/dotfiles/vim/snippets
    set runtimepath+=~/bin/dotfiles/vim/syntax
endif

set showmatch
set showmode
set showcmd
set sw=4 sts=4 ts=4
set wildmenu
set wildmode=list:longest,full

" Misc
colorscheme railscasts
filetype on
filetype plugin on
syntax on
