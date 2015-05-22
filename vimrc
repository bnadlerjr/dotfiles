" .vimrc
" Bob Nadler, Jr.

"#############################################################################
" Install / load plugins
"#############################################################################

" Required for Vundle
filetype off

let need_to_install_plugins=0

" Bootstrap Vundle if it's not installed
if empty(system("grep lazy_load ~/.vim/bundle/Vundle.vim/autoload/vundle.vim"))
    silent !mkdir -p ~/.vim/bundle
    silent !rm -rf ~/.vim/bundle/Vundle.vim
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/Vundle.vim
    let need_to_install_plugins=1
endif

set runtimepath+=~/.vim/bundle/Vundle.vim

call vundle#begin()

Plugin 'gmarik/Vundle.vim'                          " let Vundle manage Vundle, required

Plugin 'AndrewRadev/writable_search.vim'            " Grep for something, then write the original files directly through the search results
Plugin 'DataWraith/auto_mkdir'                      " Allows you to save files into directories that do not exist yet
Plugin 'Glench/Vim-Jinja2-Syntax'                   " Jinja2 syntax highlighting
Plugin 'JazzCore/ctrlp-cmatcher'                    " CtrlP C matching extension
Plugin 'MarcWeber/vim-addon-mw-utils'               " vim-snipmate dependency
Plugin 'airblade/vim-gitgutter'                     " shows a git diff in the gutter (sign column) and stages/reverts hunks
Plugin 'altercation/vim-colors-solarized'           " Solarized color theme
Plugin 'bling/vim-airline'                          " lean & mean status/tabline for vim that's light as air
Plugin 'chazy/cscope_maps'                          " cscope keyboard mappings
Plugin 'digitaltoad/vim-jade'                       " Jade syntax highlighting
Plugin 'ervandew/supertab'                          " Perform all your vim insert mode completions with Tab
Plugin 'garbas/vim-snipmate'                        " handy code snippets
Plugin 'godlygeek/csapprox'                         " dependency for Solarized
Plugin 'guns/vim-clojure-static'                    " Clojure syntax highlighting and indentation
Plugin 'guns/vim-sexp'                              " Precision editing for s-expressions
Plugin 'jpalardy/vim-slime'                         " Send code from vim buffer to a REPL
Plugin 'juvenn/mustache.vim'                        " Mustache support
Plugin 'kana/vim-textobj-user'                      " dependency for rubyblock
Plugin 'kchmck/vim-coffee-script'                   " ugh... a necessary evil... for now
Plugin 'kien/ctrlp.vim'                             " Fuzzy file, buffer, mru, tag, etc finder
Plugin 'majutsushi/tagbar'                          " displays tags in a window, ordered by scope
Plugin 'nelstrom/vim-textobj-rubyblock'             " custom text object for selecting Ruby blocks
Plugin 'rking/ag.vim'                               " plugin for the_silver_searcher
Plugin 'scrooloose/nerdcommenter'                   " quickly (un)comment lines
Plugin 'scrooloose/nerdtree'                        " A tree explorer plugin
Plugin 'tomtom/tlib_vim'                            " vim-snipmate dependency
Plugin 'tpope/vim-abolish'                          " easily search for, substitute, and abbreviate multiple variants of a word
Plugin 'tpope/vim-bundler'                          " makes source navigation of bundled gems easier
Plugin 'tpope/vim-classpath'                        " Clojure JVM classpath
Plugin 'tpope/vim-cucumber'                         " provides syntax highlightling, indenting, and a filetype plugin
Plugin 'tpope/vim-dispatch'                         " Asynchronous build and test dispatcher
Plugin 'tpope/vim-fireplace'                        " Clojure nrepl support
Plugin 'tpope/vim-fugitive'                         " Git plugin
Plugin 'tpope/vim-haml'                             " HAML support
Plugin 'tpope/vim-leiningen'                        " static support for Leiningen
Plugin 'tpope/vim-projectionist'                    " project configuration
Plugin 'tpope/vim-ragtag'                           " Ghetto HTML / XML mappings
Plugin 'tpope/vim-rails'                            " Rails helpers
Plugin 'tpope/vim-rake'                             " makes Ruby project navigation easier for non-Rails projects
Plugin 'tpope/vim-repeat'                           " Enable repeating supported plugin maps with '.'
Plugin 'tpope/vim-sexp-mappings-for-regular-people' " vim-sexp mappings rely on meta key; these don't
Plugin 'tpope/vim-surround'                         " makes working w/ quotes, braces,etc. easier
Plugin 'vim-ruby/vim-ruby'                          " packaged w/ vim but this is latest and greatest

call vundle#end()

if 1 == need_to_install_plugins
    silent! PluginInstall
    q
endif

"#############################################################################
" Settings
"#############################################################################
set autoread                    " Detect file changes refresh buffer
set background=light            " Light colored background
set backspace=indent,eol,start  " Backspace of newlines
set colorcolumn=79              " Show vertical column
set cursorline                  " Highlight current line
set expandtab                   " Expand tabs to spaces
set formatoptions=qrn1          " http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
set hlsearch                    " Highlight matches to recent searches
set ignorecase                  " Ignore case when searching
set incsearch                   " Use incremental search
set laststatus=2                " Use two rows for status line
set list                        " Show invisible chars
set listchars=tab:»·,trail:·    " Show tabs and trailing whitespace only
set nocompatible                " Not compatible w/ vi
set number                      " Display line numbers
set ruler                       " Show line and column number of cursor
set scrolloff=3                 " Always show 3 lines around cursor
set showmatch                   " Show matching braces
set smartcase                   " Turn case sensitive search back on in certain cases
set sw=4 sts=4 ts=4             " 4 spaces
set t_Co=256                    " Use 256 colors
set textwidth=79                " Text width for line wrapping
set wildmenu                    " Autocomplete filenames
set wildmode=list:longest,full  " Show completions as list with longest match then full matches
set wrap                        " Turn on line wrapping

"#############################################################################
" Misc
"#############################################################################

" Enable bundled matchit macros
runtime macros/matchit.vim

filetype on
filetype plugin on
filetype plugin indent on
syntax on
let mapleader = ","

" Make bash aliases available when running shell commands
let $BASH_ENV = "~/bin/dotfiles/bash/aliases"

" Change cursor shape in insert mode; iTerm2 only; also works w/ tmux
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

"#############################################################################
" Plugin configuration
"#############################################################################

let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
let g:ctrlp_custom_ignore = '\v\~$|\.o$|\.exe$|\.bak$|\.pyc|\.swp|\.class$|coverage/|log/|tmp/|cover/|dist/|\.git|tags|node_modules/|.DS_Store|env/|cover-unit/'

let g:testify_launcher = "Dispatch"

let g:solarized_termcolors=256
let g:solarized_visibility="high"
let g:solarized_contrast="high"

let g:airline_powerline_fonts = 1

let g:slime_target = "tmux"

"#############################################################################
" Keymaps
"#############################################################################

" Make it easy to clear out searches to get rid of highlighting
nnoremap <leader><space> :let @/=''<cr>

" Map to strip extraneous whitespace
nnoremap <leader><space><space> :%s/\s\+$//<cr>

" Quickly switch to alternate file
nnoremap <Leader><Leader> <c-^>

" Map toggle comment function from NERDCommenter
nnoremap <Leader>c <space>

" Quickly re-indent file
map <Leader>= gg=G``<CR>

" Rails specific key mappings
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" Map ,e and ,v to open files in the same directory as the current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" Autmatically insert escape syntax when searching
nnoremap / /\v

" Make it easier to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Clone paragraph
noremap cp yap<S-}>p

" Align current paragraph
noremap <leader>a =ip

" Apply macros w/ Q
nnoremap Q @q
vnoremap Q :norm @q<cr>

" Save the current file, then run the most recent test file that was saved
nmap <CR><CR> :w | TestifyRunFile<CR>

" Toggle TagBar
map <F8> :TagbarToggle<CR>
"
" Regenerate ctags and cscope.out using starscope gem
map <F9> :StarscopeUpdate<cr>

" Toggle paste/nopaste mode
map <F10> :set paste!<CR>

"#############################################################################
" Autocommands
"#############################################################################

" When viewing a git tree or blob, quickly move up to view parent
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

" Auto-clean fugitive buffers
autocmd BufReadPost fugitive://* set bufhidden=delete

" Word wrap without line breaks for text files
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=0 wrapmargin=0


colorscheme solarized
