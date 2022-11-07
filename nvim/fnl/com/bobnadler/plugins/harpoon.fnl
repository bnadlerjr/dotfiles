(module com.bobnadler.plugins.harpoon
  {autoload {utils com.bobnadler.utils}})

(utils.nnoremap "<LocalLeader>m" "<cmd>lua require('harpoon.mark').add_file()<CR>")
(utils.nnoremap "<C-e>" "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>")

(utils.nnoremap "<LocalLeader>f" "<cmd>lua require('harpoon.ui').nav_file(1)<CR>")
(utils.nnoremap "<LocalLeader>d" "<cmd>lua require('harpoon.ui').nav_file(2)<CR>")
(utils.nnoremap "<LocalLeader>s" "<cmd>lua require('harpoon.ui').nav_file(3)<CR>")
(utils.nnoremap "<LocalLeader>a" "<cmd>lua require('harpoon.ui').nav_file(4)<CR>")
