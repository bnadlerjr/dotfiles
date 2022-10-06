(module com.bobnadler.mapping
  {autoload {nvim aniseed.nvim
             utils com.bobnadler.utils}})

(set nvim.g.mapleader ",")
(set nvim.g.maplocalleader "\\")

;; Make it easy to clear out searches to get rid of highlighting
(utils.nnoremap "<leader><space>" ":let @/=''<cr>")

;; Map to strip extraneous whitespace
(utils.nnoremap "<leader><space><space>" ":%s/\\s\\+$//<cr>")

;; Quickly switch to alternate file
(utils.nnoremap "<Leader><Leader>" "<c-^>")

;; Delete focused buffer without losing split
(utils.nnoremap "<C-c>" ":bp\\|bd #<CR>")

;; Delete all buffers
(utils.map "<Leader>d" ":bufdo bd<CR>")

;; Map ,e to open files in the same directory as the current file
(utils.cnoremap "%%" "<C-R>=expand('%:h').'/'<cr>")
(utils.map "<leader>e" ":edit %%")

;; Make it easier to switch between windows
(utils.nnoremap "<C-h>" "<C-w>h")
(utils.nnoremap "<C-j>" "<C-w>j")
(utils.nnoremap "<C-k>" "<C-w>k")
(utils.nnoremap "<C-l>" "<C-w>l")

;; Open and close the quickfix window
(utils.noremap "qo" ":copen<CR>")
(utils.noremap "qc" ":cclose<CR>")

;; Apply macros w/ Q
(utils.nnoremap "Q" "@q")
(utils.vnoremap "Q" ":norm @q<cr>")

;; Toggle paste/nopaste mode
(utils.map "<F10>" ":set paste!<CR>")

;; Neogit
(utils.nnoremap "<leader>g" ":Neogit<CR>")

;; Telescope
(utils.nnoremap "<C-p>" ":lua require('telescope.builtin').find_files()<CR>")

;; Quickly re-indent file
(utils.nnoremap "<leader>=" "gg=G``<CR>")

;; Terminal shortcuts
(utils.tnoremap "<Esc>" "<C-\\><C-n>")
(utils.tnoremap "<C-v><Esc>" "<Esc>")
(utils.tnoremap "<C-h>" "<C-\\><C-n><C-w>h")
(utils.tnoremap "<C-j>" "<C-\\><C-n><C-w>j")
(utils.tnoremap "<C-k>" "<C-\\><C-n><C-w>k")
(utils.tnoremap "<C-l>" "<C-\\><C-n><C-w>l")
