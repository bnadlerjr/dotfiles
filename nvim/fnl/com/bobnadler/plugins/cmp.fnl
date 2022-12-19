(module com.bobnadler.plugins.cmp
  {autoload {cmp cmp
             lspkind lspkind
             luasnip luasnip}})

(defn- expand-or-jump-forward []
  (when (luasnip.expand_or_jumpable)
    (luasnip.expand_or_jump)))

(defn- jump-back []
  (when (luasnip.jumpable -1)
    (luasnip.jump -1)))

(defn- expand-snippet [args]
  (luasnip.lsp_expand args.body))

(defn- toggle-completion-menu []
  (if (cmp.visible)
    (cmp.close)
    (cmp.complete)))

(def- mapping
  {:<C-Space> (cmp.mapping.complete)
   :<C-b> (cmp.mapping.scroll_docs (- 4))
   :<C-e> toggle-completion-menu
   :<C-f> (cmp.mapping.scroll_docs 4)
   :<C-n> (cmp.mapping.select_next_item)
   :<C-p> (cmp.mapping.select_prev_item)
   :<C-j> expand-or-jump-forward
   :<C-k> jump-back
   :<C-y> (cmp.mapping.confirm {:select true})})

(def- sources
  [{:name "path"}
   {:name "conjure"}
   {:name "nvim_lsp" :keyword_length 3}
   {:name "buffer" :keyword_length 3}
   {:name "luasnip" :keyword_length 2}])

(cmp.setup
  {:formatting {:format (lspkind.cmp_format)}
   :mapping mapping
   :snippet {:expand expand-snippet}
   :sources sources})
