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

(def- mapping
  {:<C-Space> (cmp.mapping.complete)
   :<C-b> (cmp.mapping.scroll_docs (- 4))
   :<C-e> (cmp.mapping.abort)
   :<C-f> (cmp.mapping.scroll_docs 4)
   :<C-n> (cmp.mapping.select_next_item)
   :<C-p> (cmp.mapping.select_prev_item)
   :<C-j> expand-or-jump-forward
   :<C-k> jump-back

   ;; TODO: Decide which of these I like better
   :<C-y> (cmp.mapping.confirm {:select true})
   :<CR> (cmp.mapping.confirm {:select true})})

(def- sources
  [{:name "luasnip"}
   {:name "conjure"}
   {:name "nvim_lsp"}
   {:name "buffer" :keyword_length 5}
   {:name "path" :keyword_length 5}])

(cmp.setup
  {:formatting {:format (lspkind.cmp_format)}
   :mapping mapping
   :snippet {:expand expand-snippet}
   :sources sources})
