" Re-generate starscope ctag and cscope files
function starscope#Update()
    if !executable('starscope')
        echo "Cannot find starscope gem in PATH"
        return
    endif
    let cmd = "find . -name *.rb | xargs starscope -e ctags -e cscope"
    silent! execute s:GetRunner() . cmd
    call s:addCscopeFile()
    redraw!
endfunction

" Returns a string indicating the runner to use for the command. Uses
" vim-dispatch if available, otherwise defaults to a plain '!'.
function s:GetRunner()
    if exists("g:loaded_dispatch")
        return "Start!"
    else
        return "!"
    endif
endfunction

" Re-connects to a 'cscope.out' file if it exists. Suppresses the 'duplicate
" connection' error if the connection has already been made.
function s:addCscopeFile()
    set nocscopeverbose
    cscope add cscope.out
    set cscopeverbose
endfunction
