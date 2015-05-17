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

set runtimepath+=~~/.vim/after

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
nnoremap <Leader>b :CtrlPBuffer<cr>

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

" Quickly rename a file
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'))
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction

" Whenever certain file types are saved, regenerate the tags for it.
function! UpdateTags()
    if filereadable('tags')
        let f = expand('%')
        call system('sed -i "" "/' . escape(f, '/') . '/d" tags')
        call system('ctags -a ' . f)
    endif
endfunction
au BufWritePost *.rb,*.js,*.py call UpdateTags()

" Dictionary for commands to run tests based on filetype
let g:bn_test_runners = {
    \'ruby': '!ruby ',
    \'rspec': '!./bin/rspec ',
    \'python': '!nosetests -s ' }

" If the current file is a test file, then save it to a tab level variable. Run
" the test file saved in the variable.
function! RunTestFile()
    let filename = expand("%")
    if -1 != match(filename, '\(_spec\|_test\).rb\|_test.py$')
        let t:bn_test_file=filename
    elseif !exists("t:bn_test_file")
        echo "No test file found."
        return
    end

    let runner = &filetype
    if -1 != match(t:bn_test_file, '_spec.rb')
        let runner = 'rspec'
    end

    if 1 == has_key(g:bn_test_runners, runner)
        execute g:bn_test_runners[runner] . t:bn_test_file
    else
        echo "No test runner specified for " . runner
    end
endfunction

" Save the current file, then run the test file saved in the t:bn_test_file
" variable.
nmap <CR><CR> :w | call RunTestFile()<CR>

" Rails specific key mappings
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" Toggle paste/nopaste mode
map <F10> :set paste!<CR>

" Quickly re-indent file; saves a mark with the current position in the 'z'
" register
map <F7> mzgg=G`z<CR>

" Colors
let g:solarized_termcolors=256
let g:solarized_visibility="high"
let g:solarized_contrast="high"
colorscheme solarized
set colorcolumn=79

" Put useful info in status line (powerline)
set laststatus=2
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim

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
