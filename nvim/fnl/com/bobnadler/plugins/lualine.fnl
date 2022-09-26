(module com.bobnadler.plugins.lualine)

(comment
  (lualine.get_config))

(let [(ok? lualine) (pcall #(require :lualine))]
  (when ok?
    (lualine.setup {:inactive_sections {:lualine_c [{1 "filename" :path 1}]}
                    :options {:theme :solarized_dark}
                    :sections {:lualine_c [{1 "filename" :path 1}]}})))
