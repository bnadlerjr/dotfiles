(module com.bobnadler.plugins.cmp
  {autoload {nvim aniseed.nvim
             cmp cmp
             lspkind lspkind
             luasnip luasnip
             loaders luasnip.loaders.from_vscode}})

(defn- has-words-before []
  (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
    (and (not= col 0)
         (= (: (: (. (vim.api.nvim_buf_get_lines 0 (- line 1) line true) 1) :sub col col) :match "%s") nil))))

(defn- tab [fallback]
  (if
    (cmp.visible) (cmp.select_next_item)
    (luasnip.expand_or_jumpable) (luasnip.expand_or_jump)
    (has-words-before) (cmp.complete)
    :else (fallback)))

(defn- shift-tab [fallback]
  (if
    (cmp.visible) (cmp.select_prev_item)
    (luasnip.jumpable -1) (luasnip.jump -1)
    :else (fallback)))

(defn- expand-snippet [args]
  (luasnip.lsp_expand args.body))

(def- formatting
  {:mode "symbol_text"
   :maxwidth 50
   :ellipsis_char "..."
   :menu {:buffer "[Buffer]"
          :cmdline "[CmdLine]"
          :conjure "[Conjure]"
          :luasnip "[LuaSnip]"
          :nvim_lsp "[LSP]"
          :path "[Path]"}})

(def- mapping
  {:<C-n> (cmp.mapping.select_next_item)
   :<C-p> (cmp.mapping.select_prev_item)
   :<C-b> (cmp.mapping.scroll_docs (- 4))
   :<C-f> (cmp.mapping.scroll_docs 4)
   :<C-Space> (cmp.mapping.complete)
   :<C-e> (cmp.mapping.close)
   :<C-y> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Insert :select true})
   :<CR> (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Insert :select true})
   :<Tab> (cmp.mapping tab {1 :i 2 :s})
   :<S-Tab> (cmp.mapping shift-tab {1 :i 2 :s})})

(def- sources
  [{:name "nvim_lsp" :keyword_length 3}
   {:name "conjure" :keyword_length 3}
   {:name "buffer" :keyword_length 3}
   {:name "luasnip" :keyword_length 3}
   {:name "path" :keyword_length 3}
   {:name "cmdline" :keyword_length 3}])

(set nvim.o.completeopt "menuone,noselect")
(loaders.lazy_load)
(cmp.setup
  {:formatting {:format (lspkind.cmp_format formatting)}
   :mapping mapping
   :snippet {:expand expand-snippet}
   :sources sources
   :window {:documentation (cmp.config.window.bordered)}})