local function absent(command)
  assert(vim.fn.exists(':' .. command) == 0, command .. ' should not be available')
end

absent('CmpStatus')
absent('CodeCompanion')
absent('ConjureEval')

assert(vim.g.plugs['mason.nvim'].tag == 'v2.*', 'Mason should track v2 releases')
assert(vim.g.plugs['mason-lspconfig.nvim'].tag == 'v2.*', 'mason-lspconfig should track v2 releases')
assert(vim.fn.executable('djlint') == 1, 'djlint should be installed for none-ls')

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

vim.lsp.enable('solargraph', false)
local ruby_fixture = '/tmp/nvim-config-check-rails'
vim.fn.delete(ruby_fixture, 'rf')
vim.fn.mkdir(ruby_fixture .. '/app', 'p')
vim.fn.mkdir(ruby_fixture .. '/config', 'p')
vim.fn.writefile({}, ruby_fixture .. '/config/environment.rb')
vim.fn.writefile({}, ruby_fixture .. '/Gemfile')
vim.fn.writefile({}, ruby_fixture .. '/Gemfile.lock')
vim.cmd('edit ' .. vim.fn.fnameescape(ruby_fixture .. '/config/environment.rb'))
assert(vim.b.rails_root, 'Rails projects should be detected')
assert(vim.b.bundler_lock, 'Bundler projects should be detected')
assert(vim.fn.exists(':A') == 2, 'Projectionist navigation should be available in Ruby projects')
assert(vim.fn.exists(':Rails') == 2, 'Rails commands should be available in Rails projects')
assert(vim.fn.exists(':Bundle') == 2, 'Bundler commands should be available in Ruby projects')

local rake_fixture = '/tmp/nvim-config-check-rake'
vim.fn.delete(rake_fixture, 'rf')
vim.fn.mkdir(rake_fixture .. '/lib', 'p')
vim.fn.writefile({}, rake_fixture .. '/lib/check.rb')
vim.fn.writefile({}, rake_fixture .. '/Rakefile')
vim.cmd('edit ' .. vim.fn.fnameescape(rake_fixture .. '/lib/check.rb'))
assert(vim.b.rake_root, 'Rake projects should be detected')
assert(vim.fn.exists(':A') == 2, 'Projectionist navigation should be available in Rake projects')
assert(vim.fn.exists(':Rake') == 2, 'Rake commands should be available in Rake projects')

vim.cmd('edit /tmp/nvim-config-check.tf')
assert(vim.bo.filetype == 'terraform', 'Terraform files should use the plugin filetype')
assert(vim.fn.exists(':Terraform') == 2, 'Terraform commands should be available')
assert(vim.fn.exists(':TerraformFmt') == 2, 'Terraform formatting should be available')

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
