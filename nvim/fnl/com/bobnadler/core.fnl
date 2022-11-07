(module com.bobnadler.core
  {autoload {a aniseed.core
             nvim aniseed.nvim}})

;; If we're using nvim, might as well go all in on lua
(set nvim.g.loaded_node_provider 0)
(set nvim.g.loaded_perl_provider 0)
(set nvim.g.loaded_python3_provider 0)
(set nvim.g.loaded_ruby_provider 0)

(let [options
      {:cursorline  true  ;; Highlight current line
       :expandtab   true  ;; Expand tabs to spaces
       :ignorecase  true  ;; Ignore case when searching
       :list        true  ;; Show invisible chars
       :number      true  ;; Display line numbers
       :scrolloff   3     ;; Always show 3 lines around cursor
       :showmatch   true  ;; Show matching braces
       :signcolumn  "yes" ;; Alway show signcolumn
       :smartcase   true  ;; Turn case sensitive search back on in certain cases
       :shiftwidth  4     ;; 4 spaces for everything
       :softtabstop 4
       :tabstop     4
       :textwidth   0     ;; Do not break lines
       :wrap        true  ;; Turn on line wrapping
       }]
  (each [option value (pairs options)]
    (a.assoc nvim.o option value))

  (nvim.ex.set "colorcolumn=79")            ;; Show vertical column
  (nvim.ex.set "diffopt+=vertical")         ;; Use vertical diffs
  (nvim.ex.set "listchars=tab:»·,trail:·")  ;; Show tabs and trailing whitespace only

  (nvim.ex.colorscheme "solarized"))
