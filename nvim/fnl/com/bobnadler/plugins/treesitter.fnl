(module com.bobnadler.plugins.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup
  {:endwise {:enable true}

   ;; highlighting looks awful for some reason so disable it for now
   :highlight {:enable false}

   ;; this causes weird indentation issues...
   ;; ```ruby
   ;; while true
   ;;   foo = something.s <-- as soon as the '.' is typed, the line is outdented
   ;; end
   ;; ```
   ;;
   ;; I've also noticed this happening in Elixir and Clojure.
   ;;
   :indent {:enable false}

   :textobjects {:select {:enable true
                          :include_surrounding_whitespace true
                          :keymaps {:af "@function.outer"
                                    :if "@function.inner"
                                    :am "@function.outer"
                                    :im "@function.inner"
                                    :ac "@class.outer"
                                    :ic "@class.inner"
                                    :ab "@block.outer"
                                    :ib "@block.inner"}}
                 :move {:enable true
                        :set_jumps true
                        :goto_next_start {"]m" "@function.outer"
                                          "]]" "@class.outer"}
                        :goto_next_end {"]M" "@function.outer"
                                        "][" "@class.outer"}
                        :goto_previous_start {"[m" "@function.outer"
                                              "[[" "@class.outer"}
                        :goto_previous_end {"[M" "@function.outer"
                                            "[]" "@class.outer"}}}
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
