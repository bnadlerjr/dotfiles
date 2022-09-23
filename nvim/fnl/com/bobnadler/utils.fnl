(module com.bobnadler.utils
  {autoload {nvim aniseed.nvim}})

(defn- set-keymap [mode opts from to]
  (nvim.set_keymap mode from to opts))

(def map (partial set-keymap "" {}))
(def noremap (partial set-keymap "" {:noremap true}))

(def cnoremap (partial set-keymap "c" {:noremap true}))
(def nnoremap (partial set-keymap "n" {:noremap true}))
(def vnoremap (partial set-keymap "v" {:noremap true}))
