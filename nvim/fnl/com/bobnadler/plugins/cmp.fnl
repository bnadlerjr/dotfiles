(module com.bobnadler.plugins.cmp
  {autoload {cmp cmp
             lspkind lspkind
             luasnip luasnip}})

(defn- expand-snippet [args]
  (luasnip.lsp_expand args.body))

(def- mapping
  {:<C-b> (cmp.mapping.scroll_docs (- 4))
   :<C-f> (cmp.mapping.scroll_docs 4)
   :<C-Space> (cmp.mapping.complete)
   :<C-e> (cmp.mapping.abort)
   :<C-y> (cmp.mapping.confirm {:select true})})

(def- sources
  [{:name "conjure"}
   {:name "nvim_lsp"}
   {:name "luasnip"}
   {:name "buffer"}
   {:name "path"}])

(cmp.setup
  {:formatting {:format (lspkind.cmp_format)}
   :mapping mapping
   :snippet {:expand expand-snippet}
   :sources sources})
