" .vimrc
" Bob Nadler, Jr.

" Settings
set autoread                    " Detect file changes refresh buffer
set background=light            " Light colored background
set backspace=indent,eol,start  " Backspace of newlines
set cursorline                  " Highlight current line
set expandtab                   " Expand tabs to spaces
set formatoptions=qrn1          " http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
set hlsearch                    " Highlight matches to recent searches
set ignorecase                  " Ignore case when searching
set incsearch                   " Use incremental search
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

" Install / load plugins
exec "source ~/.vim/bundles.vim"

" Enable bundled matchit macros
runtime macros/matchit.vim

" Misc
filetype on
filetype plugin on
filetype plugin indent on
syntax on
let mapleader = ","

" Make bash aliases available when running shell commands
let $BASH_ENV = "~/bin/dotfiles/bash/aliases"

" Word wrap without line breaks for text files
au BufRead,BufNewFile *.txt,*.md,*.markdown,*.rdoc set wrap linebreak nolist textwidth=0 wrapmargin=0

" Change cursor shape in insert mode; iTerm2 only; also works w/ tmux
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Make it easy to clear out searches to get rid of highlighting
nnoremap <leader><space> :let @/=''<cr>

" Map to strip extraneous whitespace
nnoremap <leader><space><space> :%s/\s\+$//<cr>

" Autmatically insert escape syntax when searching
nnoremap / /\v

" Ctrl-P Mappings
nnoremap <Leader>f :CtrlP<cr>
let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
let g:ctrlp_custom_ignore = '\v\~$|\.o$|\.exe$|\.bak$|\.pyc|\.swp|\.class$|coverage/|log/|tmp/|cover/|dist/|\.git|tags|node_modules/|.DS_Store|env/|cover-unit/'

" Quickly switch to alternate file
nnoremap <Leader><Leader> <c-^>

" Map toggle comment function from NERDCommenter
nnoremap <Leader>c <space>

" Make it easier to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Map ,e and ,v to open files in the same directory as the current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

" Clone paragraph
noremap cp yap<S-}>p

" Align current paragraph
noremap <leader>a =ip

" Apply macros w/ Q
nnoremap Q @q
vnoremap Q :norm @q<cr>

" Regenerate ctags and cscope.out using starscope gem
map <F9> :StarscopeUpdate<cr>

" Save the current file, then run the most recent test file that was saved
let g:testify_launcher = "Dispatch"
nmap <CR><CR> :w | TestifyRunFile<CR>

" Rails specific key mappings
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" Toggle paste/nopaste mode
map <F10> :set paste!<CR>

" Toggle TagBar
map <F8> :TagbarToggle<CR>

" Quickly re-indent file
map <Leader>= gg=G``<CR>

" Colors
let g:solarized_termcolors=256
let g:solarized_visibility="high"
let g:solarized_contrast="high"
colorscheme solarized
set colorcolumn=79

" Put useful info in status line (airline)
set laststatus=2
let g:airline_powerline_fonts = 1

" Set tmux as default target for vim-slime
let g:slime_target = "tmux"

" When viewing a git tree or blob, quickly move up to view parent
autocmd User fugitive
  \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
  \   nnoremap <buffer> .. :edit %:h<CR> |
  \ endif

" Auto-clean fugitive buffers
autocmd BufReadPost fugitive://* set bufhidden=delete

" populate the argument list with each of the files named in the quickfix list
command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
function! QuickfixFilenames()
  " Building a hash ensures we get each buffer only once
  let buffer_numbers = {}
  for quickfix_item in getqflist()
    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  endfor
  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
endfunction
