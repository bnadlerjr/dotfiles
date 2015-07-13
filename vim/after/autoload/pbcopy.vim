" Copy current buffer filename with relative path to system clipboard
function! pbcopy#Filename()
    silent! execute "!echo -n " . expand("%") . " | pbcopy"
    redraw!
endfunction
