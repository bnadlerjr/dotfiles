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

Plugin 'AndrewRadev/splitjoin.vim'                  " Switch between single-line and multiline forms of code
Plugin 'AndrewRadev/writable_search.vim'            " Grep for something, then write the original files directly through the search results
Plugin 'ConradIrwin/vim-bracketed-paste'            " Handles bracketed-paste-mode in vim (aka. automatic `:set paste`)
Plugin 'DataWraith/auto_mkdir'                      " Allows you to save files into directories that do not exist yet
Plugin 'Glench/Vim-Jinja2-Syntax'                   " Jinja2 syntax highlighting
Plugin 'MarcWeber/vim-addon-mw-utils'               " vim-snipmate dependency
Plugin 'airblade/vim-gitgutter'                     " shows a git diff in the gutter (sign column) and stages/reverts hunks
Plugin 'altercation/vim-colors-solarized'           " Solarized color theme
Plugin 'andyl/vim-textobj-elixir'                   " Make text objects with various elixir block structures
Plugin 'autozimu/LanguageClient-neovim'             " Language Server Protocol (LSP) support for vim and neovim
Plugin 'bling/vim-airline'                          " lean & mean status/tabline for vim that's light as air
Plugin 'christoomey/vim-conflicted'                 " Easy git merge conflict resolution in Vim
Plugin 'dense-analysis/ale'                         " Check syntax in Vim asynchronously and fix files, with Language Server Protocol (LSP) support
Plugin 'elixir-editors/vim-elixir'                  " Vim configuration files for Elixir
Plugin 'ervandew/supertab'                          " Perform all your vim insert mode completions with Tab
Plugin 'garbas/vim-snipmate'                        " handy code snippets
Plugin 'godlygeek/csapprox'                         " dependency for Solarized
Plugin 'guns/vim-clojure-static'                    " Clojure syntax highlighting and indentation
Plugin 'guns/vim-sexp'                              " Precision editing for s-expressions
Plugin 'hashivim/vim-terraform'                     " basic vim/terraform integration
Plugin 'honza/vim-snippets'                         " vim-snipmate default snippets
Plugin 'juvenn/mustache.vim'                        " Mustache support
Plugin 'kana/vim-textobj-user'                      " dependency for rubyblock
Plugin 'ctrlpvim/ctrlp.vim'                         " Fuzzy file, buffer, mru, tag, etc finder
Plugin 'majutsushi/tagbar'                          " displays tags in a window, ordered by scope
Plugin 'mhinz/vim-grepper'                          " 👾 Helps you win at grep
Plugin 'nelstrom/vim-textobj-rubyblock'             " custom text object for selecting Ruby blocks
Plugin 'pangloss/vim-javascript'                    " Vastly improved Javascript indentation and syntax support
Plugin 'reedes/vim-lexical'                         " Build on Vim’s spell/thes/dict completion
Plugin 'scrooloose/nerdcommenter'                   " quickly (un)comment lines
Plugin 'sjl/vitality.vim'                           " Make Vim play nicely with iTerm 2 and tmux
Plugin 'tomtom/tlib_vim'                            " vim-snipmate dependency
Plugin 'tpope/vim-abolish'                          " easily search for, substitute, and abbreviate multiple variants of a word
Plugin 'tpope/vim-bundler'                          " makes source navigation of bundled gems easier
Plugin 'tpope/vim-classpath'                        " Clojure JVM classpath
Plugin 'tpope/vim-cucumber'                         " provides syntax highlightling, indenting, and a filetype plugin
Plugin 'tpope/vim-dispatch'                         " Asynchronous build and test dispatcher
Plugin 'tpope/vim-endwise'                          " wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
Plugin 'tpope/vim-fireplace'                        " Clojure REPL support
Plugin 'tpope/vim-fugitive'                         " Git plugin
Plugin 'tpope/vim-leiningen'                        " static support for Leiningen
Plugin 'tpope/vim-projectionist'                    " project configuration
Plugin 'tpope/vim-ragtag'                           " Ghetto HTML / XML mappings
Plugin 'tpope/vim-rails'                            " Rails helpers
Plugin 'tpope/vim-rake'                             " makes Ruby project navigation easier for non-Rails projects
Plugin 'tpope/vim-repeat'                           " Enable repeating supported plugin maps with '.'
Plugin 'tpope/vim-sexp-mappings-for-regular-people' " vim-sexp mappings rely on meta key; these don't
Plugin 'tpope/vim-surround'                         " makes working w/ quotes, braces,etc. easier
Plugin 'tpope/vim-unimpaired'                       " pairs of handy bracket mappings
Plugin 'vim-ruby/vim-ruby'                          " packaged w/ vim but this is latest and greatest
Plugin 'vim-test/vim-test'                          " Run your tests at the speed of thought

call vundle#end()

if 1 == need_to_install_plugins
    silent! PluginInstall
    q
endif

"#############################################################################
" Settings
"#############################################################################
set autoread                    " Detect file changes refresh buffer
set background=dark             " Background color
set backspace=indent,eol,start  " Backspace of newlines
set colorcolumn=79              " Show vertical column
set cursorline                  " Highlight current line
set diffopt+=vertical           " Use vertical diffs
set encoding=utf-8              " Use utf-8 encoding
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
set textwidth=0                 " Do not break lines
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
colorscheme solarized
let mapleader = ","
let maplocalleader = "\\"

" Make bash aliases available when running shell commands
let $BASH_ENV = "~/bin/dotfiles/bash/aliases"

"#############################################################################
" Plugin configuration
"#############################################################################

let g:airline_powerline_fonts = 1
let g:airline#extensions#ale#enabled = 1

let g:ale_linters = {}
let g:ale_linters.elixir = ['credo', 'dialyxir', 'elixir-ls', 'mix']
let g:ale_elixir_elixir_ls_release = expand("~/dev/elixir/elixir-ls/rel")

let g:ale_sign_column_always = 1
let g:ale_sign_error = "✘"
let g:ale_sign_warning = "✘"

let g:ctrlp_custom_ignore = '\v\~$|\.o$|\.exe$|\.bak$|\.pyc|\.swp|\.class$|coverage/|log/|tmp/|cover/|dist/|\.git|tags|bower_components/|node_modules/|.DS_Store|venv/|cover-unit/|target/|build/|vendor/bundle|deps|_build|doc'

let g:lexical#spell_key = '<leader>s'
let g:lexical#thesaurus_key = '<leader>t'
let g:lexical#dictionary = ['/usr/share/dict/words']
let g:lexical#spellfile = ['~/.vim/spell/en.utf-8.add']
let g:lexical#thesaurus = ['~/.vim/thesaurus/mthesaur.txt']

let g:LanguageClient_serverCommands = {
    \ 'ruby': ['solargraph', 'stdio'],
    \ 'clojure': ['bash', '-c', 'clojure-lsp', 'stdio'],
    \ 'typescript': ['typescript-language-server', '--stdio'],
    \ }

" Use new version of snipMate parser
let g:snipMate = { 'snippet_version' : 1 }

let test#strategy = "dispatch"

let NERDSpaceDelims = 1

" See https://github.com/altercation/vim-colors-solarized/issues/40
call togglebg#map("")

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

" Search for the current word
nnoremap <Leader>* :Grepper -cword -noprompt<CR>

" Search for the current selection
nmap gs <plug>(GrepperOperator)
xmap gs <plug>(GrepperOperator)

" Open search prompt
nnoremap <Leader>a :GrepperAg 

" Bring up Fugitive status buffer
nnoremap <Leader>g :Git<CR>

" Delete focused buffer without losing split
nnoremap <C-c> :bp\|bd #<CR>

" Delete all buffers
map <Leader>d :bufdo bd<CR>

" Map ,e to open files in the same directory as the current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%

" Quickly edit .vimrc file
nnoremap <leader>v :e $MYVIMRC<CR>

" Autmatically insert escape syntax when searching
nnoremap / /\v

" Make it easier to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Open and close the quickfix window
noremap qo :Copen<CR>
noremap qc :cclose<CR>

" Apply macros w/ Q
nnoremap Q @q
vnoremap Q :norm @q<cr>

" Quickly run tests
nmap <CR><CR> :w | :TestFile<CR>
nmap <silent> t<C-n> :TestNearest<CR>

" Toggle TagBar
nnoremap <Leader>t :TagbarToggle<CR>

" Language Client
nmap <silent>K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> gr <Plug>(lcn-references)

"#############################################################################
" Autocommands
"#############################################################################

au BufRead,BufNewFile build.boot set syntax=clojure
au BufRead,BufNewFile *_spec.rb set syntax=ruby
au BufRead,BufNewFile *.selmer set syntax=jinja

autocmd FileType make setlocal noexpandtab

" Add spell checking and autowrap for Git commit messages
autocmd Filetype gitcommit setlocal spell textwidth=72

" When viewing a git tree or blob, quickly move up to view parent
autocmd User fugitive
            \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
            \   nnoremap <buffer> .. :edit %:h<CR> |
            \ endif

" Auto-clean fugitive buffers
autocmd BufReadPost fugitive://* set bufhidden=delete

" vim-conflicted setup
autocmd User VimConflicted
            \ set stl+=%{ConflictedVersion()}
            \ nnoremap ]m :GitNextConflict<cr>

" Word wrap with line breaks for text files
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=79 wrapmargin=0

" vim-lexical setup
augroup lexical
    autocmd!
    autocmd FileType markdown,md,txt,rdoc call lexical#init()
augroup END

" Source vimrc upon save
augroup vimrc
    autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded " . $MYVIMRC | redraw
    autocmd! BufWritePost $MYGVIMRC if has('gui_running') | so % | echom "Reloaded " . $MYGVIMRC | endif | redraw
augroup END

" Hack to get solarized loaded correctly
au VimEnter * ToggleBG
au VimEnter * ToggleBG
