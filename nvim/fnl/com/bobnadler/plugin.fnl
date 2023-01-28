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
  ;; These are already bootstrapped in `init.lua` but adding them here so that
  ;; packer knows about them (so that `PackerClean` doesn't prompt to remove them).
  :Olical/aniseed {}
  :lewis6991/impatient.nvim {}
  :wbthomason/packer.nvim {}

  ;; Generic vim plugins
  :AndrewRadev/splitjoin.vim {}                  ;; Switch between single-line and multiline forms of code
  :AndrewRadev/writable_search.vim {}            ;; Grep for something, then write the original files directly through the search results
  :DataWraith/auto_mkdir {}                      ;; Allows you to save files into directories that do not exist yet
  :Exafunction/codeium.vim {}                    ;; Free, ultrafast Copilot alternative for Vim and Neovim
  :Glench/Vim-Jinja2-Syntax {}                   ;; Jinja2 syntax highlighting
  :elixir-editors/vim-elixir {}                  ;; Vim configuration files for Elixir
  :ericbn/vim-solarized {}                       ;; A simpler fork of the awesome Solarized colorscheme for Vim by Ethan Schoonover
  :guns/vim-clojure-static {}                    ;; Clojure syntax highlighting and indentation
  :guns/vim-sexp {:mod :sexp}                    ;; Precision editing for s-expressions
  :hashivim/vim-terraform {}                     ;; basic vim/terraform integration
  :honza/vim-snippets {}                         ;; Default snippets
  :mbbill/undotree {}                            ;; The undo history visualizer for VIM
  :reedes/vim-lexical {}                         ;; Build on Vim’s spell/thes/dict completion
  :scrooloose/nerdcommenter {:mod :comments}     ;; quickly (un)comment lines
  :sjl/vitality.vim {}                           ;; Make Vim play nicely with iTerm 2 and tmux
  :tpope/vim-abolish {}                          ;; easily search for, substitute, and abbreviate multiple variants of a word
  :tpope/vim-bundler {}                          ;; makes source navigation of bundled gems easier
  :tpope/vim-cucumber {}                         ;; provides syntax highlightling, indenting, and a filetype plugin
  :tpope/vim-dispatch {}                         ;; Asynchronous build and test dispatcher
  :tpope/vim-fugitive {}                         ;; Git plugin
  :tpope/vim-leiningen {}                        ;; static support for Leiningen
  :tpope/vim-projectionist {}                    ;; project configuration
  :tpope/vim-rails {}                            ;; Rails helpers
  :tpope/vim-rake {}                             ;; makes Ruby project navigation easier for non-Rails projects
  :tpope/vim-repeat {}                           ;; Enable repeating supported plugin maps with '.'
  :tpope/vim-rhubarb {}                          ;; GitHub extension for fugitive.vim
  :tpope/vim-sexp-mappings-for-regular-people {} ;; vim-sexp mappings rely on meta key; these don't
  :vim-ruby/vim-ruby {}                          ;; packaged w/ vim but this is latest and greatest
  :vim-test/vim-test {:mod :vimtest}             ;; Run your tests at the speed of thought
  :vimwiki/vimwiki {:mod :wiki}                  ;; Personal Wiki for Vim

  ;; Neovim specific plugins

  ;; Snippet Engine for Neovim written in Lua.
  :L3MON4D3/LuaSnip {:mod :luasnip}

  ;; Interactive evaluation for Neovim.
  :Olical/conjure
    {:requires [:PaterJason/cmp-conjure] ;; nvim-cmp source for conjure.
     :mod :conjure}

  ;; A completion plugin for neovim coded in Lua.
  :hrsh7th/nvim-cmp
    {:requires [:hrsh7th/cmp-buffer        ;; nvim-cmp source for buffer words
                :hrsh7th/cmp-nvim-lsp      ;; nvim-cmp source for neovim builtin LSP client
                :hrsh7th/cmp-path          ;; nvim-cmp source for path
                :saadparwaiz1/cmp_luasnip] ;; luasnip completion source for nvim-cmp
     :mod :cmp}

  ;; Quickstart configs for Nvim LSP
  :neovim/nvim-lspconfig
    {:requires [:onsails/lspkind.nvim ;; vscode-like pictograms for neovim lsp completion items
                :simrat39/rust-tools.nvim] ;; Tools for better development in rust using neovim's builtin lsp
     :mod :lspconfig}

  ;; Find, Filter, Preview, Pick. All lua, all the time.
  :nvim-telescope/telescope.nvim
    {:requires [:nvim-telescope/telescope-ui-select.nvim ;; Neovim core stuff can fill the telescope picker.
                :nvim-lua/plenary.nvim]                  ;; All the lua functions I don't want to write twice.
     :mod :telescope}

  :nvim-telescope/telescope-fzf-native.nvim {:run "make"} ;; FZF sorter for telescope written in c

  ;; Nvim Treesitter configurations and abstraction layer
  :nvim-treesitter/nvim-treesitter
    {:requires [:RRethy/nvim-treesitter-endwise               ;; Tree-sitter aware alternative to tpope's vim-endwise
                :nvim-treesitter/nvim-treesitter-textobjects  ;; Syntax aware text-objects, select, move, swap, and peek support.
                :windwp/nvim-autopairs]                       ;; autopairs for neovim written by lua
     :run ":TSUpdate"
     :mod :treesitter}

  ;; Colorschemes
  :EdenEast/nightfox.nvim {}   ;; 🦊A highly customizable theme for vim and neovim with support for lsp, treesitter and a variety of plugins
  :catppuccin/nvim {}          ;; 🍨 Soothing pastel theme for (Neo)vi
  :ellisonleao/gruvbox.nvim {} ;; Lua port of the most famous vim colorscheme
  :folke/tokyonight.nvim {}    ;; 🏙 A clean, dark Neovim theme written in Lua, with support for lsp, treesitter and lots of plugins.
  :jacoborus/tender.vim {}     ;; A 24bit colorscheme for Vim, Airline and Lightline
  :tiagovla/tokyodark.nvim {}  ;; A clean dark theme written in lua for neovim.

  :ThePrimeagen/harpoon {:mod :harpoon}            ;; Getting you where you want with the fewest keystrokes.
  :jose-elias-alvarez/null-ls.nvim {:mod :null_ls} ;; Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
  :kyazdani42/nvim-web-devicons {}                 ;; lua `fork` of vim-web-devicons for neovim
  :kylechui/nvim-surround {:mod :surround}         ;; Add/change/delete surrounding delimiter pairs with ease.
  :lewis6991/gitsigns.nvim {:mod :gitsigns}        ;; Git integration for buffers
  :nvim-lualine/lualine.nvim {:mod :lualine}       ;; A blazing fast and easy to configure neovim statusline plugin written in pure lua.
  )
