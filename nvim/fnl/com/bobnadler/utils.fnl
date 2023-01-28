(module com.bobnadler.utils
  {autoload {nvim aniseed.nvim}})

(defn- set-keymap [mode opts from to]
  (nvim.set_keymap mode from to opts))

(def map (partial set-keymap "" {}))
(def noremap (partial set-keymap "" {:noremap true}))

(def nmap (partial set-keymap "n" {}))
(def xmap (partial set-keymap "x" {}))

(def cnoremap (partial set-keymap "c" {:noremap true}))
(def nnoremap (partial set-keymap "n" {:noremap true}))
(def tnoremap (partial set-keymap "t" {:noremap true}))
(def vnoremap (partial set-keymap "v" {:noremap true}))
