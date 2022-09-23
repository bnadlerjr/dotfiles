(module com.bobnadler.plugins.gitsigns)

(let [(ok? gitsigns) (pcall #(require :gitsigns))]
  (when ok?
    (gitsigns.setup {})))
