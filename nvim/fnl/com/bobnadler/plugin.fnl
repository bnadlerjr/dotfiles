(module com.bobnadler.plugin
  {autoload {nvim aniseed.nvim
             a aniseed.core
             : packer}})

(defn safe-require-plugin-config [name]
  (let [full-name (.. :com.bobnadler.plugins. name)
        (ok? val-or-err) (pcall require full-name)]
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
  :AndrewRadev/splitjoin.vim {}                  ;; Switch between single-line and multiline forms of code
  :AndrewRadev/writable_search.vim {}            ;; Grep for something, then write the original files directly through the search results
  :DataWraith/auto_mkdir {}                      ;; Allows you to save files into directories that do not exist yet
  :Glench/Vim-Jinja2-Syntax {}                   ;; Jinja2 syntax highlighting
  :Olical/conjure {}                             ;; Interactive evaluation for Neovim.
  :elixir-editors/vim-elixir {}                  ;; Vim configuration files for Elixir
  :guns/vim-clojure-static {}                    ;; Clojure syntax highlighting and indentation
  :guns/vim-sexp {:mod :sexp}                    ;; Precision editing for s-expressions
  :hashivim/vim-terraform {}                     ;; basic vim/terraform integration
  :kylechui/nvim-surround {:mod :surround}       ;; Add/change/delete surrounding delimiter pairs with ease.
  :lewis6991/gitsigns.nvim {:mod :gitsigns}      ;; Git integration for buffers
  :lifepillar/vim-solarized8 {:mod :colors}      ;; Optimized Solarized colorschemes. Best served with true-color terminals!
  :reedes/vim-lexical {}                         ;; Build on Vim’s spell/thes/dict completion
  :scrooloose/nerdcommenter {:mod :comments}     ;; quickly (un)comment lines
  :tpope/vim-abolish {}                          ;; easily search for, substitute, and abbreviate multiple variants of a word
  :tpope/vim-bundler {}                          ;; makes source navigation of bundled gems easier
  :tpope/vim-cucumber {}                         ;; provides syntax highlightling, indenting, and a filetype plugin
  :tpope/vim-leiningen {}                        ;; static support for Leiningen
  :tpope/vim-projectionist {}                    ;; project configuration
  :tpope/vim-rails {}                            ;; Rails helpers
  :tpope/vim-rake {}                             ;; makes Ruby project navigation easier for non-Rails projects
  :tpope/vim-repeat {}                           ;; Enable repeating supported plugin maps with '.'
  :tpope/vim-sexp-mappings-for-regular-people {} ;; vim-sexp mappings rely on meta key; these don't
  ; *** :tpope/vim-endwise {}                   ;; wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
  ; *** :tpope/vim-ragtag {}                     ;; Ghetto HTML / XML mappings
  ; *** :vim-test/vim-test {}                    ;; Run your tests at the speed of thought
  )
