" .vimrc
" Bob Nadler, Jr.

" Settings
set autoread                    " Detect file changes refresh buffer
set background=dark
set backspace=indent,eol,start  " Backspace of newlines

set cursorline                  " Highlight current line
set expandtab                   " Expand tabs to spaces
set hlsearch                    " Highlight matches to recent searches
set nocompatible                " Not compatible w/ vi
set number                      " Display line numbers
set ruler                       " Show line and column number of cursor
set guioptions-=T               " Turn off GUI menu
set showmatch                   " Show matching braces
set showmode                    " Show which mode buffer is in
set showcmd                     " Command info in lower right
set sw=4 sts=4 ts=4             " 4 spaces
set wildmenu                    " Autocomplete filenames
set wildmode=list:longest,full

" Setup runtime paths
if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
    set guifont=Lucida_Console:h10
else
    set runtimepath+=~/bin/dotfiles/vim/after
endif

" Misc
filetype on
filetype plugin on
syntax on
colorscheme vividchalk

" Use pathogen to load bundles
call pathogen#runtime_append_all_bundles()
