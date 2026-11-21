local function absent(command)
  assert(vim.fn.exists(':' .. command) == 0, command .. ' should not be available')
end

absent('CmpStatus')
absent('CodeCompanion')
absent('ConjureEval')

assert(vim.fn.maparg('<C-Space>', 'x') == '', 'custom Tree-sitter selection should be removed')
assert(vim.fn.maparg('an', 'x') ~= '', 'native Tree-sitter selection should be available')
assert(vim.fn.maparg('<C-Space>', 'i') ~= '', 'manual LSP completion should be mapped')

local function assert_soft_pencil(filetype)
  vim.cmd('enew')
  vim.cmd('setfiletype ' .. filetype)
  assert(vim.bo.textwidth == 0, 'Soft Pencil should use visual wrapping for ' .. filetype)
  assert(vim.wo.conceallevel == 0, 'Soft Pencil should not conceal ' .. filetype)
end

assert_soft_pencil('markdown')
assert_soft_pencil('text')

vim.lsp.enable('elixirls', false)
vim.cmd('enew')
local elixir_ok, elixir_error = pcall(vim.cmd, 'setfiletype elixir')
assert(elixir_ok, elixir_error)
assert(vim.bo.makeprg == 'mix compile', 'Elixir buffers should use the Mix compiler')

vim.cmd('edit /tmp/nvim-config-check.lexs')
assert(vim.bo.filetype == 'elixir', 'Temple .lexs files should be detected as Elixir')

vim.cmd('edit /tmp/nvim-config-check.eex')
assert(vim.bo.filetype == 'eelixir', 'EEx files should use the embedded Elixir filetype')
assert(vim.bo.syntax == 'eelixir', 'EEx files should load embedded Elixir syntax')
assert(vim.bo.indentexpr ~= '', 'EEx files should load embedded Elixir indentation')

vim.cmd('edit nvim/init.lua')
local attached = vim.wait(10000, function()
  return #vim.lsp.get_clients({ bufnr = 0 }) > 0
end, 100)
assert(attached, 'lua_ls should attach to the Neovim config')
assert(vim.fn.exists(':Format') == 2, 'LspAttach should create the Format command')

print('Neovim config checks passed')
