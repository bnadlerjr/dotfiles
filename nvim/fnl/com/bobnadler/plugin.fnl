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
  :AndrewRadev/splitjoin.vim {}                        ;; Switch between single-line and multiline forms of code
  :AndrewRadev/writable_search.vim {}                  ;; Grep for something, then write the original files directly through the search results
  :DataWraith/auto_mkdir {}                            ;; Allows you to save files into directories that do not exist yet
  :Glench/Vim-Jinja2-Syntax {}                         ;; Jinja2 syntax highlighting
  :L3MON4D3/LuaSnip {}                                 ;; Snippet Engine for Neovim written in Lua.
  :Olical/conjure {}                                   ;; Interactive evaluation for Neovim.
  :PaterJason/cmp-conjure {}                           ;; nvim-cmp source for conjure.
  :TimUntersberger/neogit {:mod :neogit}               ;; magit for neovim
  :elixir-editors/vim-elixir {}                        ;; Vim configuration files for Elixir
  :guns/vim-clojure-static {}                          ;; Clojure syntax highlighting and indentation
  :guns/vim-sexp {:mod :sexp}                          ;; Precision editing for s-expressions
  :hashivim/vim-terraform {}                           ;; basic vim/terraform integration
  :hrsh7th/cmp-buffer {}                               ;; nvim-cmp source for buffer words
  :hrsh7th/cmp-cmdline {}                              ;; nvim-cmp source for vim's cmdline
  :hrsh7th/cmp-nvim-lsp {}                             ;; nvim-cmp source for neovim builtin LSP client
  :hrsh7th/cmp-path {}                                 ;; nvim-cmp source for path
  :hrsh7th/nvim-cmp {:mod :cmp}                        ;; A completion plugin for neovim coded in Lua.
  :kylechui/nvim-surround {:mod :surround}             ;; Add/change/delete surrounding delimiter pairs with ease.
  :lewis6991/gitsigns.nvim {:mod :gitsigns}            ;; Git integration for buffers
  :lifepillar/vim-solarized8 {:mod :colors}            ;; Optimized Solarized colorschemes. Best served with true-color terminals!
  :neovim/nvim-lspconfig {:mod :lspconfig}             ;; Quickstart configs for Nvim LSP
  :nvim-lua/plenary.nvim {}                            ;; All the lua functions I don't want to write twice.
  :nvim-lua/popup.nvim {}                              ;; An implementation of the Popup API from vim in Neovim.
  :nvim-lualine/lualine.nvim  {:mod :lualine}          ;; A blazing fast and easy to configure neovim statusline plugin written in pure lua.
  :nvim-telescope/telescope-ui-select.nvim {}          ;; Neovim core stuff can fill the telescope picker.
  :nvim-telescope/telescope.nvim {:mod :telescope}     ;; Find, Filter, Preview, Pick. All lua, all the time.
  :nvim-treesitter/nvim-treesitter {:run ":TSUpdate" :mod :treesitter}  ;; Nvim Treesitter configurations and abstraction layer
  :onsails/lspkind.nvim {}                             ;; vscode-like pictograms for neovim lsp completion items
  :rafamadriz/friendly-snippets {}                     ;; Set of preconfigured snippets for different languages.
  :reedes/vim-lexical {}                               ;; Build on Vim’s spell/thes/dict completion
  :saadparwaiz1/cmp_luasnip {}                         ;; luasnip completion source for nvim-cmp
  :scrooloose/nerdcommenter {:mod :comments}           ;; quickly (un)comment lines
  :tpope/vim-abolish {}                                ;; easily search for, substitute, and abbreviate multiple variants of a word
  :tpope/vim-bundler {}                                ;; makes source navigation of bundled gems easier
  :tpope/vim-cucumber {}                               ;; provides syntax highlightling, indenting, and a filetype plugin
  :tpope/vim-leiningen {}                              ;; static support for Leiningen
  :tpope/vim-projectionist {}                          ;; project configuration
  :tpope/vim-rails {}                                  ;; Rails helpers
  :tpope/vim-rake {}                                   ;; makes Ruby project navigation easier for non-Rails projects
  :tpope/vim-repeat {}                                 ;; Enable repeating supported plugin maps with '.'
  :tpope/vim-sexp-mappings-for-regular-people {}       ;; vim-sexp mappings rely on meta key; these don't
  :williamboman/mason-lspconfig.nvim {}                ;; Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
  :williamboman/mason.nvim {}                          ;; Easily install and manage LSP servers, DAP servers, linters, and formatters.
  ; *** :tpope/vim-endwise {}                          ;; wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
  ; *** :tpope/vim-ragtag {}                           ;; Ghetto HTML / XML mappings
  ; *** :vim-test/vim-test {}                          ;; Run your tests at the speed of thought
  )
