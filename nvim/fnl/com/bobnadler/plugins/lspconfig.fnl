(module com.bobnadler.plugins.lspconfig
  {autoload {nvim aniseed.nvim
             mason mason
             mason-lspconfig mason-lspconfig
             lsp lspconfig
             cmplsp cmp_nvim_lsp}})

(mason.setup)
(mason-lspconfig.setup
  {:ensure_installed
   [
    ; :bashls
    :clojure_lsp
    ; :cucumber_language_server
    :elixirls
    ; :eslint
    ; :graphql
    ; :html
    ; :jsonls
    :solargraph
    ; :terraformls
    ; :tsserver
    ; :yamlls
    ]})

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
                    (nvim.buf_set_keymap bufnr :n :gd "<Cmd>lua vim.lsp.buf.definition()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :gr "<cmd>lua vim.lsp.buf.references()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :K "<Cmd>lua vim.lsp.buf.hover()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>ld "<Cmd>lua vim.lsp.buf.declaration()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lt "<cmd>lua vim.lsp.buf.type_definition()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lh "<cmd>lua vim.lsp.buf.signature_help()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>ln "<cmd>lua vim.lsp.buf.rename()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>le "<cmd>lua vim.diagnostic.open_float()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lq "<cmd>lua vim.diagnostic.setloclist()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lf "<cmd>lua vim.lsp.buf.formatting()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lj "<cmd>lua vim.diagnostic.goto_next()<CR>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lk "<cmd>lua vim.diagnostic.goto_prev()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :n :<leader>la "<cmd>lua vim.lsp.buf.code_action()<CR>" {:noremap true})
                    (nvim.buf_set_keymap bufnr :v :<leader>la "<cmd>lua vim.lsp.buf.range_code_action()<CR> " {:noremap true})
                    ;telescope
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lw ":lua require('telescope.builtin').diagnostics()<cr>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>lr ":lua require('telescope.builtin').lsp_references()<cr>" {:noremap true})
                    ; (nvim.buf_set_keymap bufnr :n :<leader>li ":lua require('telescope.builtin').lsp_implementations()<cr>" {:noremap true})

                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
                    ; -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
                    ; -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
                    ; -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>', opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
                    ; vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

                    ))]

  (lsp.clojure_lsp.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})

  (lsp.solargraph.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities})
  (lsp.elixirls.setup {:on_attach on_attach
                          :handlers handlers
                          :capabilities capabilities}))
