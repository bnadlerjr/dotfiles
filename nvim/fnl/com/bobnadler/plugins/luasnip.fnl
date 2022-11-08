(module com.bobnadler.plugins.luasnip
  {autoload {luasnip luasnip
             loaders luasnip.loaders.from_snipmate}})

(luasnip.config.set_config
  {:history true
   :updateevents "TextChanged,TextChangedI"})

(loaders.lazy_load)
