(module com.bobnadler.plugins.vimtest
  {autoload {utils com.bobnadler.utils}})

(vim.cmd "let test#strategy = 'dispatch'")

;; Quickly run the last test
(utils.nnoremap "<CR><CR>" ":TestLast<CR>")
