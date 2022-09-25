(module com.bobnadler.plugins.telescope
  {autoload {a aniseed.core
             nvim aniseed.nvim
             actions telescope.actions
             builtin telescope.builtin
             themes telescope.themes}})

(var choices [:buffers :live_grep :find_files])

(defn- reset-choices []
  (set choices [:buffers :live_grep :find_files]))

(defn- rotate-choices [v]
  (let [[f s l] v]
    [s l f]))

(defn- cycle-pickers []
  (: builtin (a.first choices))
  (set choices (rotate-choices choices)))

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
    (telescope.load_extension "ui-select")
    (nvim.ex.autocmd "User TelescopeFindPre" (reset-choices))))
