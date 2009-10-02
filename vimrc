" .vimrc
" Bob Nadler, Jr.

" Settings
set autoread
set background=dark
set backspace=indent,eol,start
set backup

if has("win32")
    set backupdir=C:\Home\tmp
else
    set backupdir=~/tmp/
endif

set cursorline
set expandtab
set hlsearch
set nocompatible
set number
set ruler

if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
    set guifont=Lucida_Console:h10
else
    set runtimepath+=~/bin/dotfiles/vim/after
endif

set showmatch
set showmode
set showcmd
set sw=4 sts=4 ts=4
set wildmenu
set wildmode=list:longest,full

" Mappings
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap " ""<Left>
inoremap ' ''<Left>

" Misc
colorscheme railscasts
filetype plugin on
syntax on
