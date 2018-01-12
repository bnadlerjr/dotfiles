function! RunRepl(cmd)
  if executable('rlwrap')
    call termopen('rlwrap ' . a:cmd)
  else
    call termopen(a:cmd)
  endif
endfunction

abbrev break (com.gfredericks.debug-repl/break!)
command! -buffer Lein :call RunRepl("lein repl")

" Clojure REPL Workflow
nnoremap <LocalLeader>rf :call fireplace#echo_session_eval('(refresh)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rg :call fireplace#echo_session_eval('(go)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rp :call fireplace#echo_session_eval('(stop)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rr :call fireplace#echo_session_eval('(reset)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rs :call fireplace#echo_session_eval('(start)', {'ns': 'user'})<CR>
