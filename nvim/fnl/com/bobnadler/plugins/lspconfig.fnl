(module com.bobnadler.plugins.lspconfig
  {autoload {nvim aniseed.nvim
             lsp lspconfig
             cmplsp cmp_nvim_lsp}})

(vim.fn.sign_define "DiagnosticSignError" {:text "" :texthl "DiagnosticSignError"})
(vim.fn.sign_define "DiagnosticSignWarn"  {:text "" :texthl "DiagnosticSignWarn"})
(vim.fn.sign_define "DiagnosticSignInfo"  {:text "" :texthl "DiagnosticSignInfo"})
(vim.fn.sign_define "DiagnosticSignHint"  {:text "" :texthl "DiagnosticSignHint"})

(let [handlers {"textDocument/publishDiagnostics"
                (vim.lsp.with
                  vim.lsp.diagnostic.on_publish_diagnostics
                  {:severity_sort true
                   :update_in_insert false
                   :underline true
                   :virtual_text false})
                "textDocument/hover"
                (vim.lsp.with
                  vim.lsp.handlers.hover
                  {:border "single"})
                "textDocument/signatureHelp"
                (vim.lsp.with
                  vim.lsp.handlers.signature_help
                  {:border "single"})}
      capabilities (cmplsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))
      on_attach (fn [client bufnr]
                  (do
                    (nvim.buf_set_keymap bufnr :n :<C-i> "<cmd>lua vim.diagnostic.open_float()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<C-k> "<cmd>lua vim.lsp.buf.signature_help()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :K "<Cmd>lua vim.lsp.buf.hover()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :gD "<Cmd>lua vim.lsp.buf.declaration()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :ga "<cmd>lua vim.lsp.buf.code_action()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :gr ":lua require('telescope.builtin').lsp_references()<cr>" {:noremap true}))
                    (nvim.buf_set_keymap bufnr :v :ga "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true}))]

  (lsp.clojure_lsp.setup {:on_attach on_attach :handlers handlers :capabilities capabilities})
  (lsp.elixirls.setup {:on_attach on_attach :handlers handlers :capabilities capabilities}))
  (lsp.solargraph.setup {:on_attach on_attach :handlers handlers :capabilities capabilities})
