" Ruby FileType Plugin
setlocal ai sts=2 sw=2 ts=2 et

" Snippets
iab <buffer> atc attr_accessor
iab <buffer> atr attr_reader
iab <buffer> atw attr_writer
iab <buffer> begin begin<CR><CR>rescue Exception => e<CR>end<Esc>2ka<Tab><C-R>
iab <buffer> case case<CR>end<Esc>k$a
iab <buffer> class class<CR>end<Esc>k$a
iab <buffer> def def<CR>end<Up>
iab <buffer> each each do \|item\|<CR><CR>end<Esc>ka<Tab><C-R>
iab <buffer> if if<CR>end<Esc>k$a
iab <buffer> module module<CR>end<Esc>k$a
iab <buffer> while while<CR>end<Esc>k$a
