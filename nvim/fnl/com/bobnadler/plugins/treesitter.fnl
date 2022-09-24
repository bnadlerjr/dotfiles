(module com.bobnadler.plugins.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup
  {:endwise {:enable true}
   :highlight {:enable true}
   :indent {:enable true}
   :ensure_installed [:bash
                      :clojure
                      :elixir
                      :fennel
                      :graphql
                      :html
                      :python
                      :ruby
                      :typescript
                      :yaml]})
