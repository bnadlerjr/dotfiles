(module com.bobnadler.plugins.telescope
  {autoload {actions telescope.actions
             themes telescope.themes}})

(let [(ok? telescope) (pcall #(require :telescope))]
  (when ok?
    (telescope.setup
      {:defaults
       {:file_ignore_patterns ["node_modules"]
        :mappings {:i {:<C-f> false
                       :<C-u> false}}}
       :extensions {:ui-select {1 (themes.get_dropdown {})}}
       :pickers {:find_files
                 {:find_command ["rg" "--files" "--iglob" "!.git" "--hidden"]}}})
    (telescope.load_extension "ui-select")))
