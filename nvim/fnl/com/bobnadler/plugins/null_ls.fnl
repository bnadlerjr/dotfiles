(module com.bobnadler.plugins.null_ls
  {autoload {a aniseed.core}})

(let [(ok? null_ls) (pcall #(require :null-ls))
      diagnostics (a.get-in null_ls [:builtins :diagnostics])
      formatting (a.get-in null_ls [:builtins :formatting])]
  (when ok?
    (null_ls.setup
      {:sources [(a.get formatting :djlint)
                 (a.get formatting :fnlfmt)
                 (a.get formatting :cljstyle)
                 (a.get formatting :rubocop)
                 (a.get formatting :mix)
                 (a.get diagnostics :credo)
                 (a.get diagnostics :djlint)
                 (a.get diagnostics :rubocop)
                 (a.get diagnostics :clj_kondo)]})))
