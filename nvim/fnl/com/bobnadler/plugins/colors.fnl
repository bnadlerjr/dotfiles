(module com.bobnadler.plugins.solarized
  {autoload {nvim aniseed.nvim}})

(nvim.ex.autocmd "vimenter * ++nested colorscheme solarized")
