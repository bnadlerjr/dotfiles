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
set showmatch
set showmode
set showcmd
set sw=4 sts=4 ts=4
set wildmenu
set wildmode=list:longest,full

" Setup runtime paths
if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
    set guifont=Lucida_Console:h10
else
    set runtimepath+=~/bin/dotfiles/vim/after
    set runtimepath+=~/bin/dotfiles/vim
endif

" Use pathogen to load bundles
call pathogen#runtime_append_all_bundles()

" Misc
filetype on
filetype plugin on
syntax on

colorscheme jellybeans
