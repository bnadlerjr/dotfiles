" .vimrc
" Bob Nadler, Jr.

" Settings
set autoread                    " Detect file changes refresh buffer
set background=light            " Light colored background
set backspace=indent,eol,start  " Backspace of newlines
set cursorline                  " Highlight current line
set expandtab                   " Expand tabs to spaces
set formatoptions=qrn1
set hlsearch                    " Highlight matches to recent searches
set list                        " Show invisible chars
set listchars=tab:»·,trail:·    " Show tabs and trailing whitespace only
set nocompatible                " Not compatible w/ vi
set number                      " Display line numbers
set ruler                       " Show line and column number of cursor
set scrolloff=3                 " Always show 3 lines around cursor
set showmatch                   " Show matching braces
set showmode                    " Show which mode buffer is in
set showcmd                     " Command info in lower right
set sw=4 sts=4 ts=4             " 4 spaces
set t_Co=256                    " Use 256 colors
set textwidth=79                " Text width for line wrapping
set wildmenu                    " Autocomplete filenames
set wildmode=list:longest,full
set wrap                        " Turn on line wrapping

" Setup runtime paths
if has("win32")
    set runtimepath+=C:\Home\Bin\dotfiles\vim
    set runtimepath+=C:\Home\Bin\dotfiles\vim\after
else
    set runtimepath+=~/bin/dotfiles/vim/after
endif

" Misc
filetype on
filetype plugin on
syntax on
let mapleader = ","

" Use pathogen to load bundles
call pathogen#runtime_append_all_bundles()

" Make it easy to clear out searches to get rid of highlighting
nnoremap <leader><space> :let @/=''<cr>

" FuzzyFinder Mappings
nnoremap <Leader>f :FufFile<CR>
nnoremap <Leader>r :FufRenewCache<CR>

" Map toggle comment function from NERDCommenter
nnoremap <Leader>c <space>

" Buffer Navigation Mappings
nnoremap <D-H> :bp<CR>
nnoremap <D-L> :bn<CR>

" Match bracket pairs using <tab>
nnoremap <tab> %
vnoremap <tab> %

" Open a new vertial window and switch over to it
nnoremap <leader>w <C-w>v<C-w>l
nnoremap <leader>wo <C-w>v<C-w>l :FufRenewCache<CR> :FufFile<CR>

" Make it easier to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Don't rely on arrow keys!
inoremap <Up> <Esc>
nnoremap <Up> <Esc>

inoremap <Down> <Esc>
nnoremap <Down> <Esc>

inoremap <Left> <Esc>
nnoremap <Left> <Esc>

inoremap <Right> <Esc>
nnoremap <Right> <Esc>

" Put useful info in status line
:set laststatus=2
:set statusline=%<%f%=\ [%1*%M%*%n%R%H]\ %-19(%3l,%02c%03V%)%O'%02b'
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" Colors
colorscheme solarized
