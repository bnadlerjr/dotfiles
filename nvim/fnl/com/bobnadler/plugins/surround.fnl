(module com.bobnadler.plugins.surround)

(let [(ok? nvim-surround) (pcall #(require :nvim-surround))]
  (when ok?
    (nvim-surround.setup {})))
