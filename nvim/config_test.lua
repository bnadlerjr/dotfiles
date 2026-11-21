local function absent(command)
  assert(vim.fn.exists(':' .. command) == 0, command .. ' should not be available')
end

absent('CmpStatus')
absent('CodeCompanion')
absent('ConjureEval')

assert(vim.fn.maparg('<C-Space>', 'x') == '', 'custom Tree-sitter selection should be removed')
assert(vim.fn.maparg('an', 'x') ~= '', 'native Tree-sitter selection should be available')
assert(vim.fn.maparg('<C-Space>', 'i') ~= '', 'manual LSP completion should be mapped')

vim.cmd('new test.md')
vim.cmd('setfiletype markdown')
assert(vim.bo.textwidth == 0, 'Soft Pencil should use visual wrapping')
assert(vim.wo.conceallevel == 0, 'Soft Pencil should not conceal Markdown')

print('Neovim config checks passed')
