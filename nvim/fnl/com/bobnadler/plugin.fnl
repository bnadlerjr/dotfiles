(module com.bobnadler.plugin
  {autoload {nvim aniseed.nvim
             a aniseed.core
             : packer}})

(defn safe-require-plugin-config [name]
  (let [(ok? val-or-err) (pcall require (.. :dotfiles.plugin. name))]
    (when (not ok?)
      (print (.. "dotfiles error: " val-or-err)))))

(defn- use [...]
  "Iterates through the arguments as pairs and calls packer's use function for
  each of them. Works around Fennel not liking mixed associative and sequential
  tables as well."
  (let [pkgs [...]]
    (packer.startup
      (fn [use]
        (for [i 1 (a.count pkgs) 2]
          (let [name (. pkgs i)
                opts (. pkgs (+ i 1))]
            (-?> (. opts :mod) (safe-require-plugin-config))
            (use (a.assoc opts 1 name)))))))
  nil)

(use
  :wbthomason/packer.nvim {}            ;; A use-package inspired plugin manager for Neovim.
  :lifepillar/vim-solarized8 {}         ;; Optimized Solarized colorschemes. Best served with true-color terminals!
  )

(vim.cmd "autocmd vimenter * ++nested colorscheme solarized8")
