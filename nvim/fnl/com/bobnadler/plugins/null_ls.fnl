(module com.bobnadler.plugins.null_ls
  {autoload {a aniseed.core
             null_ls null-ls}})

(let [formatting (a.get-in null_ls [:builtins :formatting])]
  (null_ls.setup
    {:sources [(a.get formatting :djlint)
               (a.get formatting :fnlfmt)
               (a.get formatting :cljstyle)
               (a.get formatting :rubocop)
               (a.get formatting :mix)
               (a.get diagnostics :credo)
               (a.get diagnostics :djlint)
               (a.get diagnostics :rubocop)
               (a.get diagnostics :clj_kondo)]}))
