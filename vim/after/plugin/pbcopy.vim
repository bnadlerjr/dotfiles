if exists('g:loaded_pbcopy')
    finish
endif
let g:loaded_pbcopy = 1

command! -nargs=0 CopyFilename call pbcopy#Filename()
