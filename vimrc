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
set list                        " Show invisible chars
set listchars=tab:»·,trail:·    " Show tabs and trailing whitespace only
set nocompatible                " Not compatible w/ vi
set number                      " Display line numbers
set ruler                       " Show line and column number of cursor
set scrolloff=3                 " Always show 3 lines around cursor
set shellcmdflag=-ic            " Load bashrc so we have access to aliases
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

" Use pathogen to load bundles
call pathogen#runtime_append_all_bundles()

" Misc
filetype on
filetype plugin on
filetype plugin indent on
syntax on
let mapleader = ","

" Change cursor shape in insert mode; iTerm2 only
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"

" Make it easy to clear out searches to get rid of highlighting
nnoremap <leader><space> :let @/=''<cr>

" FuzzyFinder Mappings
nnoremap <Leader>f :FufRenewCache<CR>:FufFile **/<CR>
nnoremap <Leader>t :FufRenewCache<CR>:FufTag<CR>
nnoremap <Leader>b :FufRenewCache<CR>:FufBuffer<CR>

let g:fuf_file_exclude = '\v\~$|\.o$|\.exe$|\.bak$|\.swp|\.class$|coverage/|\.git|tags'

" Ack: find word under cursor
nnoremap <C-x>f :Ack<CR>

" Map toggle comment function from NERDCommenter
nnoremap <Leader>c <space>

" Match bracket pairs using <tab>
nnoremap <tab> %
vnoremap <tab> %

" Make it easier to switch between windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Put useful info in status line
:set laststatus=2
:set statusline=%<%f%=\ [%1*%M%*%n%R%H]\ %-19(%3l,%02c%03V%)%O'%02b'
:hi User1 term=inverse,bold cterm=inverse,bold ctermfg=red

" Smart tab completion. Taken from http://vim.wikia.com/wiki/VimTip102
function! CleverTab()
    if pumvisible()
        return "\<C-N>"
    endif
    if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
        return "\<Tab>"
    elseif exists('&omnifunc') && &omnifunc != ''
        return "\<C-X>\<C-O>"
    else
        return "\<C-N>"
    endif
endfunction
inoremap <Tab> <C-R>=CleverTab()<CR>

" Map ,e and ,v to open files in the same directory as the current file
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map <leader>e :edit %%
map <leader>v :view %%

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

" ctags helper functions from
" http://vim.wikia.com/wiki/Autocmd_to_update_ctags_file

    " This function deletes all tag entries for the given file from a
    " tags file.
    function! DelTagOfFile(file)
        let fullpath = a:file
        let cwd = getcwd()
        let tagfilename = cwd . "/tags"
        let f = substitute(fullpath, cwd . "/", "", "")
        let f = escape(f, './')
        let cmd = 'sed -i "/' . f . '/d" "' . tagfilename . '"'
        let resp = system(cmd)
    endfunction

    " This function updates a tags file by deleting all tags entries
    " for the current open file and then regenerates the tags file
    " using the 'append' option.
    function! UpdateTags()
        let f = expand("%:p")
        call DelTagOfFile(f)
        let cwd = getcwd()
        let tagfilename = cwd . "/tags"
        let cmd = 'ctags -a -f ' . tagfilename . '"' . f . '"'
        let resp = system(cmd)
    endfunction

" Whenever these file types are saved, regenerate the tags for it.
autocmd BufWritePost *.rb,*.js call UpdateTags()

" Rails specific key mappings
map <leader>gr :topleft :split config/routes.rb<cr>
map <leader>gg :topleft 100 :split Gemfile<cr>

" Use two-space indent for coffee-script files
au BufNewFile,BufReadPost *.coffee setl shiftwidth=2 expandtab

" Map to external script that formats Ruby hashes
vmap <F2> !format_hash.rb<CR>

" Colors
let g:solarized_termcolors=256
let g:solarized_visibility="high"
let g:solarized_contrast="high"
colorscheme solarized
