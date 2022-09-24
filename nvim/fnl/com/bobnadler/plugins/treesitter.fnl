(module com.bobnadler.plugins.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup
  {:highlight {:enable true}
   :indent {:enable true}
   :ensure_installed [:bash
                      :clojure
                      :elixir
                      :fennel
                      :graphql
                      :html
                      :python
                      :ruby
                      :typscript
                      :yaml]})
