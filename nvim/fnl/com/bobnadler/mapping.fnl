(module com.bobnadler.mapping
  {autoload {nvim aniseed.nvim}})

(set nvim.g.mapleader ",")
(set nvim.g.maplocalleader "\\")

(defn- set-keymap [mode opts from to]
  (nvim.set_keymap mode from to opts))

(def map (partial set-keymap "" {}))
(def noremap (partial set-keymap "" {:noremap true}))

(def cnoremap (partial set-keymap "c" {:noremap true}))
(def nnoremap (partial set-keymap "n" {:noremap true}))
(def vnoremap (partial set-keymap "v" {:noremap true}))

;; Make it easy to clear out searches to get rid of highlighting
(nnoremap "<leader><space>" ":let @/=''<cr>")

;; Map to strip extraneous whitespace
(nnoremap "<leader><space><space>" ":%s/\\s\\+$//<cr>")

;; Quickly switch to alternate file
(nnoremap "<Leader><Leader>" "<c-^>")

;; Delete focused buffer without losing split
(nnoremap "<C-c>" ":bp\\|bd #<CR>")

;; Delete all buffers
(map "<Leader>d" ":bufdo bd<CR>")

;; Map ,e to open files in the same directory as the current file
(cnoremap "%%" "<C-R>=expand('%:h').'/'<cr>")
(map "<leader>e" ":edit %%")

;; Make it easier to switch between windows
(nnoremap "<C-h>" "<C-w>h")
(nnoremap "<C-j>" "<C-w>j")
(nnoremap "<C-k>" "<C-w>k")
(nnoremap "<C-l>" "<C-w>l")

;; Open and close the quickfix window
(noremap "qo" ":copen<CR>")
(noremap "qc" ":cclose<CR>")

;; Apply macros w/ Q
(nnoremap "Q" "@q")
(vnoremap "Q" ":norm @q<cr>")

;; Toggle paste/nopaste mode
(map "<F10>" ":set paste!<CR>")
