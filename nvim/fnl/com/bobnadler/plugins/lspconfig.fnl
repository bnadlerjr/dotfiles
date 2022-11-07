(module com.bobnadler.plugins.lspconfig
  {autoload {a aniseed.core
             cmp cmp_nvim_lsp
             lsp lspconfig}})

(vim.diagnostic.config {:update_in_insert true :virtual_text false})

(vim.fn.sign_define "DiagnosticSignError" {:text "" :texthl "DiagnosticSignError"})
(vim.fn.sign_define "DiagnosticSignWarn"  {:text "" :texthl "DiagnosticSignWarn"})
(vim.fn.sign_define "DiagnosticSignInfo"  {:text "" :texthl "DiagnosticSignInfo"})
(vim.fn.sign_define "DiagnosticSignHint"  {:text "" :texthl "DiagnosticSignHint"})

(defn- on_attach [client bufnr]
  (let [options {:noremap true :buffer bufnr}]
    ;; Enable omni-completion
    (vim.api.nvim_buf_set_option bufnr "omnifunc" "v:lua.vim.lsp.omnifunc")

    ;; Keymaps
    (vim.keymap.set "n" "<C-i>" vim.diagnostic.open_float bufopts)
    (vim.keymap.set "n" "K"     vim.lsp.buf.hover bufopts)
    (vim.keymap.set "n" "[d"    vim.diagnostic.goto_prev bufopts)
    (vim.keymap.set "n" "]d"    vim.diagnostic.goto_next bufopts)
    (vim.keymap.set "n" "ga"    vim.lsp.buf.code_action bufopts)
    (vim.keymap.set "n" "gd"    vim.lsp.buf.definition bufopts)
    (vim.keymap.set "n" "gr"    "<cmd>lua require('telescope.builtin').lsp_references()<cr>" bufopts)
    (vim.keymap.set "v" "ga"    vim.lsp.buf.range_code_action bufopts)))

(def- options
  {:on_attach on_attach
   :capabilities (cmp.default_capabilities)})

(lsp.clojure_lsp.setup options)
(lsp.solargraph.setup options)

(lsp.elixirls.setup
  (a.merge
    options
    {:cmd ["/Users/krevlorn/dev/elixir/elixir-ls-1.10/language_server.sh"]}))
