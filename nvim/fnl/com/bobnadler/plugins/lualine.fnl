(module com.bobnadler.plugins.lualine
  {autoload {lualine lualine}})

(let [(ok? lualine) (pcall #(require :lualine))]
  (when ok?
    (lualine.setup {:options {:theme :solarized_dark}})))
