" .gvimrc
" Bob Nadler, Jr.

set colorcolumn=80  " Color column for line wrapping
set guioptions-=T   " Turn off GUI menu

" Setup fonts
if has("win32")
    set guifont=Lucida_Console:h10
else
    set guifont=Monaco\ for\ Powerline:h14
endif
