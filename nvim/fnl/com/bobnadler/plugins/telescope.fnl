(module com.bobnadler.plugins.telescope
  {autoload {nvim aniseed.nvim
             telescope telescope
             themes telescope.themes}})

(telescope.setup
  {:defaults {:file_ignore_patterns ["node_modules"]}
   :extensions {:ui-select {1 (themes.get_dropdown {})}}
   :pickers {:find_files
             {:find_command ["rg" "--files" "--iglob" "!.git" "--hidden"]}}})

(telescope.load_extension "ui-select")

;; TODO: Make a utils module
(nvim.set_keymap :n :<C-p> ":lua require('telescope.builtin').find_files()<CR>" {:noremap true})
