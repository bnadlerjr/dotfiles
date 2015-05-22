if exists('g:loaded_starscope')
    finish
endif
let g:loaded_starscope = 1

command! -nargs=0 StarscopeUpdate call starscope#Update()
