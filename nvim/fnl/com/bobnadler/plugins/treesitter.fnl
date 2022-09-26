(module com.bobnadler.plugins.treesitter)

(let [(ok? treesitter) (pcall #(require :nvim-treesitter.configs))]
  (when ok?
    (treesitter.setup {:endwise {:enable true}
                       :highlight {:enable true
                                   :disable [:clojure :elixir :fennel :ruby]}
                       :indent {:enable true}
                       :textobjects {:select {:enable true
                                              :keymaps {:af "@function.outer"
                                                        :if "@function.inner"
                                                        :am "@function.outer"
                                                        :im "@function.inner"
                                                        :ac "@class.outer"
                                                        :ic "@class.inner"
                                                        :ab "@block.outer"
                                                        :ib "@block.inner"}
                                              :include_surrounding_whitespace true}
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
                                          :yaml]})))
