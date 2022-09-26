(module com.bobnadler.core
  {autoload {a aniseed.core
             nvim aniseed.nvim}})

(let [options
      {:autoread true                ;; Detect file changes refresh buffer
       :background "dark"            ;; Background color
       :backspace "indent,eol,start" ;; Backspace of newlines
       :cursorline true              ;; Highlight current line
       :encoding "utf-8"             ;; Use utf-8 encoding
       :expandtab true               ;; Expand tabs to spaces
       :formatoptions "qrn1"         ;; http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
       :hlsearch true                ;; Highlight matches to recent searches
       :ignorecase true              ;; Ignore case when searching
       :incsearch true               ;; Use incremental search
       :laststatus 2                 ;; Use two rows for status line
       :list true                    ;; Show invisible chars
       :listchars "tab:»·,trail:·"   ;; Show tabs and trailing whitespace only
       :compatible false             ;; Not compatible w/ vi
       :number true                  ;; Display line numbers
       :ruler true                   ;; Show line and column number of cursor
       :scrolloff 3                  ;; Always show 3 lines around cursor
       :showmatch true               ;; Show matching braces
       :smartcase true               ;; Turn case sensitive search back on in certain cases
       :termguicolors true           ;; Use 256 colors
       :textwidth 0                  ;; Do not break lines
       :wildmenu true                ;; Autocomplete filenames
       :wildmode "list:longest,full" ;; Show completions as list with longest match then full matches
       :wrap true                    ;; Turn on line wrapping
       }]
  (each [option value (pairs options)]
    (a.assoc nvim.o option value))

  ;; additional options that can't be set via vim.o
  (nvim.ex.set "colorcolumn=79")) ;; Show vertical column
