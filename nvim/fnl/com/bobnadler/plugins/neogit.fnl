(module com.bobnadler.plugins.neogit
  {autoload {utils com.bobnadler.utils}})

(let [(ok? neogit) (pcall #(require :neogit))]
  (when ok?
    (neogit.setup
      {:disable_commit_confirmation true})))
