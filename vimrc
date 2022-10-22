" .vimrc
" Bob Nadler, Jr.

"#############################################################################
" Install / load plugins
"#############################################################################

let need_to_install_plugins=0

" Bootstrap vim-plug if it's not installed
if empty(system("grep vim-plug ~/.vim/autoload/plug.vim"))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    let need_to_install_plugins=1
endif

call plug#begin()

Plug 'AndrewRadev/splitjoin.vim'                    " Switch between single-line and multiline forms of code
Plug 'AndrewRadev/writable_search.vim'              " Grep for something, then write the original files directly through the search results
Plug 'DataWraith/auto_mkdir'                        " Allows you to save files into directories that do not exist yet
Plug 'Glench/Vim-Jinja2-Syntax'                     " Jinja2 syntax highlighting
Plug 'SirVer/ultisnips'                             " The ultimate snippet solution for Vim.
Plug 'airblade/vim-gitgutter'                       " shows a git diff in the gutter (sign column) and stages/reverts hunks
Plug 'andyl/vim-textobj-elixir'                     " Make text objects with various elixir block structures
Plug 'bling/vim-airline'                            " lean & mean status/tabline for vim that's light as air
Plug 'dense-analysis/ale'                           " Check syntax in Vim asynchronously and fix files, with Language Server Protocol (LSP) support
Plug 'ecomba/vim-ruby-refactoring'                  " Refactoring tool for Ruby in vim!
Plug 'elixir-editors/vim-elixir'                    " Vim configuration files for Elixir
Plug 'ericbn/vim-solarized'                         " A simpler fork of the awesome Solarized colorscheme for Vim by Ethan Schoonover
Plug 'guns/vim-clojure-static'                      " Clojure syntax highlighting and indentation
Plug 'guns/vim-sexp'                                " Precision editing for s-expressions
Plug 'hashivim/vim-terraform'                       " basic vim/terraform integration
Plug 'honza/vim-snippets'                           " Default snippets
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } " Fuzzy search
Plug 'junegunn/fzf.vim'                             " FZF vim integration
Plug 'juvenn/mustache.vim'                          " Mustache support
Plug 'kana/vim-textobj-user'                        " dependency for rubyblock
Plug 'lifepillar/vim-mucomplete'                    " Chained completion that works the way you want!
Plug 'liquidz/vim-iced', {'for': 'clojure'}         " Clojure Interactive Development Environment for Vim8/Neovim
Plug 'nelstrom/vim-textobj-rubyblock'               " custom text object for selecting Ruby blocks
Plug 'pangloss/vim-javascript'                      " Vastly improved Javascript indentation and syntax support
Plug 'paulyeo21/vim-textobj-rspec'                  " Creates text objects for rspec blocks
Plug 'prabirshrestha/vim-lsp'                       " async language server protocol plugin for vim and neovim
Plug 'reedes/vim-lexical'                           " Build on Vim’s spell/thes/dict completion
Plug 'rhysd/vim-lsp-ale'                            " Bridge between vim-lsp and ALE
Plug 'scrooloose/nerdcommenter'                     " quickly (un)comment lines
Plug 'sjl/vitality.vim'                             " Make Vim play nicely with iTerm 2 and tmux
Plug 'tpope/vim-abolish'                            " easily search for, substitute, and abbreviate multiple variants of a word
Plug 'tpope/vim-bundler'                            " makes source navigation of bundled gems easier
Plug 'tpope/vim-cucumber'                           " provides syntax highlightling, indenting, and a filetype plugin
Plug 'tpope/vim-dispatch'                           " Asynchronous build and test dispatcher
Plug 'tpope/vim-endwise'                            " wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
Plug 'tpope/vim-fugitive'                           " Git plugin
Plug 'tpope/vim-leiningen'                          " static support for Leiningen
Plug 'tpope/vim-projectionist'                      " project configuration
Plug 'tpope/vim-ragtag'                             " Ghetto HTML / XML mappings
Plug 'tpope/vim-rails'                              " Rails helpers
Plug 'tpope/vim-rake'                               " makes Ruby project navigation easier for non-Rails projects
Plug 'tpope/vim-repeat'                             " Enable repeating supported plugin maps with '.'
Plug 'tpope/vim-sexp-mappings-for-regular-people'   " vim-sexp mappings rely on meta key; these don't
Plug 'tpope/vim-surround'                           " makes working w/ quotes, braces,etc. easier
Plug 'tpope/vim-unimpaired'                         " pairs of handy bracket mappings
Plug 'vim-ruby/vim-ruby'                            " packaged w/ vim but this is latest and greatest
Plug 'vim-test/vim-test'                            " Run your tests at the speed of thought
Plug 'vimwiki/vimwiki'                              " Personal Wiki for Vim

" Neovim specific plugins
if has('nvim')
    Plug 'github/copilot.vim' " Neovim plugin for GitHub Copilot
endif

call plug#end()

if 1 == need_to_install_plugins
    silent! PlugInstall
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

" Use a line cursor within insert mode and a block cursor everywhere else.
"
" Reference chart of values:
"   Ps = 0  -> blinking block.
"   Ps = 1  -> blinking block (default).
"   Ps = 2  -> steady block.
"   Ps = 3  -> blinking underline.
"   Ps = 4  -> steady underline.
"   Ps = 5  -> blinking bar (xterm).
"   Ps = 6  -> steady bar (xterm).
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"

" Make bash aliases available when running shell commands
let $BASH_ENV = "~/bin/dotfiles/bash/aliases"

"#############################################################################
" Plugin configuration
"#############################################################################

let g:airline_powerline_fonts = 1
let g:airline#extensions#ale#enabled = 1

let g:ale_sign_column_always = 1
let g:ale_sign_error = "✘"
let g:ale_sign_warning = "✘"

let g:iced#nrepl#ns#refresh_after_fn = 'user/start'
let g:iced#nrepl#ns#refresh_before_fn = 'user/stop'
let g:iced_default_key_mapping_leader = '<LocalLeader>'
let g:iced_enable_clj_kondo_analysis = v:true
let g:iced_enable_default_key_mappings = v:true

let g:lexical#spell_key = '<leader>s'
let g:lexical#thesaurus_key = '<leader>t'
let g:lexical#dictionary = ['/usr/share/dict/words']
let g:lexical#spellfile = ['~/.vim/spell/en.utf-8.add']
let g:lexical#thesaurus = ['~/.vim/thesaurus/mthesaur.txt']

" This gets rid of the annoying 'A>' in the gutter for LSPs that support lots
" of code actions.
let g:lsp_document_code_action_signs_enabled = 0

let test#strategy = "dispatch"

" Redefine UltiSnips trigger; rely on mucomplete instead
let g:UltiSnipsExpandTrigger = "<f5>"        " Do not use <tab>
let g:UltiSnipsJumpForwardTrigger = "<c-b>"  " Do not use <c-j>

let g:NERDDefaultAlign = 'left'
let NERDSpaceDelims = 1

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki/',
                     \ 'syntax': 'markdown', 'ext': '.md'}]

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

" Toggle paste/nopaste mode
map <F10> :set paste!<CR>

" Vim Iced
nnoremap <localleader>rc <Plug>(iced_refresh)
nnoremap <localleader>ra <Plug>(iced_refresh_all)

" Quickly yank from cursor to end of line
nnoremap Y y$

" Copy selected text to system clipboard, joining single newlines and
" preserving multiple newlines
vmap <C-c> "+y:let @+ = substitute(@+, "\n\n", "±", "g")<CR>
    \      \|:let @+ = substitute(@+, "\n", " ", "g")<CR>
    \      \|:let @+ = substitute(@+, "±", "\\n\\n", "g")<CR>

" FZF
nnoremap <C-p> :Files<CR>
nnoremap <Leader>a :Rg<CR>
nnoremap <Leader>* :Rg <C-R><C-W><CR>

"#############################################################################
" Functions
"#############################################################################

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> <f2> <plug>(lsp-rename)
    nmap <buffer> K <plug>(lsp-hover)
    nmap <buffer> ga <plug>(lsp-code-action)
    let g:mucomplete#completion_delay = 100
    let g:mucomplete#reopen_immediately = 0
endfunction

function! LoadMucomplete()
    set completeopt+=menuone
    set completeopt+=noselect
    set complete-=i
    set complete-=t

    let g:mucomplete#enable_auto_at_startup = 1
    let g:mucomplete#chains = {}
    let g:mucomplete#chains['default'] = {
                \              'default': ['ulti', 'omni', 'path', 'keyp', 'keyn', 'uspl'],
                \              '.*string.*': ['uspl'],
                \              '.*comment.*': ['uspl']
                \            }
    let g:mucomplete#chains['markdown'] = ['path', 'keyn', 'uspl', 'dict']
    let g:mucomplete#chains['gitcommit'] = g:mucomplete#chains['markdown']

    inoremap <plug>(TryUlti) <c-r>=TryUltiSnips()<cr>
    imap <expr> <silent> <plug>(TryMU) TryMUcomplete()
    imap <expr> <silent> <tab> "\<plug>(TryUlti)\<plug>(TryMU)"
endfunction

function! TryUltiSnips()
    if !pumvisible() " With the pop-up menu open, let Tab move down
        call UltiSnips#ExpandSnippetOrJump()
    endif
    return ''
endfunction

let g:ulti_expand_or_jump_res = 0
function! TryMUcomplete()
    return g:ulti_expand_or_jump_res ? "" : "\<plug>(MUcompleteFwd)"
endfunction

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

" Word wrap with line breaks for text files
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=79 wrapmargin=0

" vim-lexical setup
augroup lexical
    autocmd!
    autocmd FileType gitcommit,markdown,md,txt,rdoc,html,erb,ruby,elixir,clojure,jinja call lexical#init()
augroup END

" Source vimrc upon save
augroup vimrc
    autocmd! BufWritePost $MYVIMRC source % | echom "Reloaded " . $MYVIMRC | redraw
    autocmd! BufWritePost $MYGVIMRC if has('gui_running') | so % | echom "Reloaded " . $MYGVIMRC | endif | redraw
augroup END

" LSP Support
if executable('solargraph')
    augroup lsp_ruby
        au!
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'solargraph',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
                    \ 'whitelist': ['ruby'],
                    \ })
    augroup END
endif

if executable('clojure-lsp')
    augroup lsp_clojure
        au!
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'clojure-lsp',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'clojure-lsp']},
                    \ 'allowlist': ['clojure', 'clojurescript']
                    \ })
    augroup END
endif

if executable('elixir-ls')
    augroup lsp_elixir
        au!
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'elixir-ls',
                    \ 'cmd': {server_info->[&shell, &shellcmdflag, '~/dev/elixir/elixir-ls-1.10/language_server.sh']},
                    \ 'allowlist': ['elixir']
                    \ })
    augroup END
endif

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

augroup LazyLoadMucomplete
    autocmd!
    autocmd CursorHold,CursorHoldI * call LoadMucomplete() | call plug#load('vim-mucomplete') | autocmd! LazyLoadMucomplete
augroup end
