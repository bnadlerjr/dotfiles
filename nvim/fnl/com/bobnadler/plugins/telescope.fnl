(module com.bobnadler.plugins.telescope
  {autoload {a aniseed.core
             action_state telescope.actions.state
             actions telescope.actions
             builtin telescope.builtin
             themes telescope.themes}})

(defn- cycle-pickers [prompt_bufnr]
  (let [picker (action_state.get_current_picker prompt_bufnr)
        choices {"Find Files" :buffers
                 "Buffers" :live_grep
                 "Live Grep" :find_files}]
    (: builtin (a.get choices picker.prompt_title :find_files))))

(let [(ok? telescope) (pcall #(require :telescope))]
  (when ok?
    (telescope.setup
      {:defaults
       {:file_ignore_patterns ["node_modules"]
        :mappings {:i {:<esc> actions.close
                       :<C-f> cycle-pickers
                       :<C-u> false}}}
       :extensions {:ui-select {1 (themes.get_dropdown {})}}
       :pickers {:find_files
                 {:find_command ["rg" "--files" "--iglob" "!.git" "--hidden"]}}})
    (telescope.load_extension "ui-select")))
