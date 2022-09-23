(module com.bobnadler.core
  {autoload {nvim aniseed.nvim}})

(set nvim.o.autoread true)                ;; Detect file changes refresh buffer
(set nvim.o.background "dark")            ;; Background color
(set nvim.o.backspace "indent,eol,start") ;; Backspace of newlines
(set nvim.o.colorcolumn 79)               ;; Show vertical column
(set nvim.o.cursorline true)              ;; Highlight current line
;; (set nvim.o.diffopt+=vertical          ;; Use vertical diffs
(set nvim.o.encoding "utf-8")             ;; Use utf-8 encoding
(set nvim.o.expandtab true)               ;; Expand tabs to spaces
(set nvim.o.formatoptions "qrn1")         ;; http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
(set nvim.o.hlsearch true)                ;; Highlight matches to recent searches
(set nvim.o.ignorecase true)              ;; Ignore case when searching
(set nvim.o.incsearch true)               ;; Use incremental search
(set nvim.o.laststatus 2)                 ;; Use two rows for status line
(set nvim.o.list true)                    ;; Show invisible chars
(set nvim.o.listchars "tab:»·,trail:·")   ;; Show tabs and trailing whitespace only
(set nvim.o.compatible false)             ;; Not compatible w/ vi
(set nvim.o.number true)                  ;; Display line numbers
(set nvim.o.ruler true)                   ;; Show line and column number of cursor
(set nvim.o.scrolloff 3)                  ;; Always show 3 lines around cursor
(set nvim.o.showmatch true)               ;; Show matching braces
(set nvim.o.smartcase true)               ;; Turn case sensitive search back on in certain cases
;; (set nvim.o.sw=4 sts=4 ts=4            ;; 4 spaces
(set nvim.o.termguicolors true)           ;; Use 256 colors
(set nvim.o.textwidth 0)                  ;; Do not break lines
(set nvim.o.wildmenu true)                ;; Autocomplete filenames
(set nvim.o.wildmode "list:longest,full") ;; Show completions as list with longest match then full matches
(set nvim.o.wrap true)                    ;; Turn on line wrapping

;; Don't know if these are needed anymore...
;; (vim.cmd "filetype on")
;; (vim.cmd "filetype plugin on")
;; (vim.cmd "filetype plugin indent on")
;; (vim.cmd "syntax on")
