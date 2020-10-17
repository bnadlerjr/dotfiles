" General
nmap <LocalLeader>r :Require<cr>
nmap <LocalLeader>R :Require!<cr>
nmap <LocalLeader>ei <Plug>FireplacePrint<Plug>(sexp_inner_element)``
nmap <LocalLeader>ee <Plug>FireplacePrint<Plug>(sexp_outer_list)``
nmap <LocalLeader>et <Plug>FireplacePrint<Plug>(sexp_outer_top_list)``

" Clojure REPL Workflow
nnoremap <LocalLeader>rf :call fireplace#echo_session_eval('(refresh)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rg :call fireplace#echo_session_eval('(go)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rp :call fireplace#echo_session_eval('(stop)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rr :call fireplace#echo_session_eval('(reset)', {'ns': 'user'})<CR>
nnoremap <LocalLeader>rs :call fireplace#echo_session_eval('(start)', {'ns': 'user'})<CR>

" Use fireplace for running tests instead of testify plugin
nmap <buffer> <CR><CR> cpr
