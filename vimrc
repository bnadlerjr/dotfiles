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
set showmatch                   " Show matching braces
set showmode                    " Show which mode buffer is in
set showcmd                     " Command info in lower right
set sw=4 sts=4 ts=4             " 4 spaces
set wildmenu                    " Autocomplete filenames
set wildmode=list:longest,full

" Setup runtime paths
if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
else
    set runtimepath+=~/bin/dotfiles/vim/after
endif

" Misc
filetype on
filetype plugin on
syntax on
let mapleader = ","
colorscheme vividchalk

" Use pathogen to load bundles
call pathogen#runtime_append_all_bundles()

" FuzzyFinder Mappings
nnoremap <Leader>f :FufFile<CR>

" Buffer Navigation Mappings
nnoremap <D-H> :bp<CR>
nnoremap <D-L> :bn<CR>

" Don't rely on arrow keys!
noremap  <Up> <Esc>
noremap! <Up> <Esc>

noremap  <Down> <Esc>
noremap! <Down> <Esc>

noremap  <Left> <Esc>
noremap! <Left> <Esc>

noremap  <Right> <Esc>
noremap! <Right> <Esc>
