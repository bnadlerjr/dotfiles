(module com.bobnadler.plugins.treesitter
  {autoload {treesitter nvim-treesitter.configs}})

(treesitter.setup
  {:endwise {:enable true}

   ;; highlighting looks awful for some reason so disable it for now
   :highlight {:enable false}

   :indent {:enable true}
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
