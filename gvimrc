" .gvimrc
" Bob Nadler, Jr.

set guioptions-=T   " Turn off GUI menu

" Setup fonts
if has("win32")
    set guifont=Lucida_Console:h10
else
    set guifont=Monaco\ for\ Powerline:h14
endif
