--  Setting leader key must happen before plugins are required (otherwise
--  wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

-- Install `lazy.nvim` plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- ###########################################################################
-- Plugins
-- ###########################################################################
require('lazy').setup({
  'AndrewRadev/splitjoin.vim',                  -- Switch between single-line and multiline forms of code
  'AndrewRadev/writable_search.vim',            -- Grep for something, then write the original files directly through the search results
  'DataWraith/auto_mkdir',                      -- Allows you to save files into directories that do not exist yet
  'Exafunction/codeium.nvim',                   -- A native neovim extension for Codeium
  'Glench/Vim-Jinja2-Syntax',                   -- Jinja2 syntax highlighting
  'elixir-editors/vim-elixir',                  -- Vim configuration files for Elixir
  'guns/vim-clojure-static',                    -- Clojure syntax highlighting and indentation
  'guns/vim-sexp',                              -- Precision editing for s-expressions
  'hashivim/vim-terraform',                     -- basic vim/terraform integration
  'kylechui/nvim-surround',                     -- Add/change/delete surrounding delimiter pairs with ease.
  'lewis6991/gitsigns.nvim',                    -- Adds git related signs to the gutter, as well as utilities for managing changes
  'mbbill/undotree',                            -- The undo history visualizer for VIM
  'mhinz/vim-grepper',                          -- 👾 Helps you win at grep
  'norcalli/nvim-colorizer.lua',                -- The fastest Neovim colorizer.
  'nvim-lualine/lualine.nvim',                  -- A blazing fast and easy to configure neovim statusline plugin written in pure lua
  'nvimtools/none-ls.nvim',                     -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
  'reedes/vim-lexical',                         -- Build on Vim’s spell/thes/dict completion
  'scrooloose/nerdcommenter',                   -- quickly (un)comment lines
  'sjl/vitality.vim',                           -- Make Vim play nicely with iTerm 2 and tmux
  'tpope/vim-abolish',                          -- easily search for, substitute, and abbreviate multiple variants of a word
  'tpope/vim-bundler',                          -- makes source navigation of bundled gems easier
  'tpope/vim-cucumber',                         -- provides syntax highlightling, indenting, and a filetype plugin
  'tpope/vim-dispatch',                         -- Asynchronous build and test dispatcher
  'tpope/vim-fugitive',                         -- Git plugin
  'tpope/vim-leiningen',                        -- static support for Leiningen
  'tpope/vim-projectionist',                    -- project configuration
  'tpope/vim-rails',                            -- Rails helpers
  'tpope/vim-rake',                             -- makes Ruby project navigation easier for non-Rails projects
  'tpope/vim-repeat',                           -- Enable repeating supported plugin maps with '.'
  'tpope/vim-rhubarb',                          -- GitHub extension for fugitive.vim
  'tpope/vim-sexp-mappings-for-regular-people', -- vim-sexp mappings rely on meta key; these don't
  'vim-ruby/vim-ruby',                          -- packaged w/ vim but this is latest and greatest
  'vim-test/vim-test',                          -- Run your tests at the speed of thought

  -- Quickstart configs for Nvim LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',           -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
      'williamboman/mason-lspconfig.nvim', -- Extension to mason.nvim that makes it easier to use lspconfig
      { 'j-hui/fidget.nvim', opts = {} },  -- Extensible UI for Neovim notifications and LSP progress messages
      'folke/neodev.nvim'                  -- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API
    }
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',            -- Snippet Engine & its associated nvim-cmp source
      'saadparwaiz1/cmp_luasnip',    -- luasnip completion source for nvim-cmp
      'hrsh7th/cmp-nvim-lsp',        -- nvim-cmp source for neovim builtin LSP client
      'hrsh7th/cmp-path',            -- nvim-cmp source for path
      'rafamadriz/friendly-snippets' -- Adds a number of user-friendly snippets
    }
  },

  {
    'EdenEast/nightfox.nvim', -- 🦊A highly customizable theme for vim and neovim with support for lsp, treesitter and a variety of plugins
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'nightfox'
    end
  },

  -- Find, Filter, Preview, Pick. All lua, all the time
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'OliverChao/telescope-picker-list.nvim',      -- A plugin that helps you use any pickers in telescope
      'nvim-lua/plenary.nvim',                      -- All the lua functions I don't want to write twice
      'nvim-telescope/telescope-ui-select.nvim',    -- Neovim core stuff can fill the telescope picker
      {
        'nvim-telescope/telescope-fzf-native.nvim', -- FZF sorter for telescope written in c
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end
      }
    }
  },

  -- Nvim Treesitter configurations and abstraction layer
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects', -- Syntax aware text-objects, select, move, swap, and peek support
      'RRethy/nvim-treesitter-endwise',              -- Tree-sitter aware alternative to tpope's vim-endwise
      'windwp/nvim-autopairs'                        -- autopairs for neovim written by lua
    },
    build = ':TSUpdate',
  },
}, {})

-- ###########################################################################
-- Settings
-- ###########################################################################
vim.o.colorcolumn = "79"               -- Show vertical column
vim.o.completeopt = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.cursorline = true                -- Highlight current line
vim.o.expandtab = true                 -- Expand tabs to spaces
vim.o.ignorecase = true                -- Ignore case when searching
vim.o.list = true                      -- Show invisible chars
vim.o.listchars = "tab:»·,trail:·"     -- Show tabs and trailing whitespace only
vim.o.scrolloff = 3                    -- Always show 3 lines around cursor
vim.o.showmatch = true                 -- Show matching braces
vim.o.smartcase = true                 -- Turn case sensitive search back on in certain cases
vim.o.termguicolors = true             -- Enables 24-bit RGB color
vim.o.timeoutlen = 300                 -- Decrease update time
vim.o.updatetime = 250
vim.o.wrap = true                      -- Turn on line wrapping
vim.wo.number = true                   -- Display line numbers
vim.wo.signcolumn = 'yes'              -- Always show signcolumn

-- ###########################################################################
-- Plugin Configuration
-- ###########################################################################

require('codeium').setup({})
require('colorizer').setup()
require('gitsigns').setup()
require('lualine').setup({})
require('nvim-surround').setup()
require('nvim-autopairs').setup({ check_ts = true })

vim.cmd "let g:NERDDefaultAlign = 'left'"
vim.cmd "let NERDSpaceDelims = 1"
vim.cmd "let test#strategy = 'dispatch'"

-- Telescope
local ts_builtin = require('telescope.builtin')

local picker_map = {
  ["Buffers"] = ts_builtin.buffers,
  ["Oldfiles"] = ts_builtin.oldfiles,
  ["Find Files"] = ts_builtin.find_files,
  ["Live Grep"] = ts_builtin.live_grep
}

local get_pickers_to_cycle = function()
  local ordered_pickers = {
    "Find Files",
    "Buffers",
    "Live Grep",
    "Oldfiles"
  }
  local pickers_to_cycle = {}
  local i = 1
  for _, title in ipairs(ordered_pickers) do
    pickers_to_cycle[i] = title
    i = i + 1
  end
  return pickers_to_cycle
end

local next_picker = function(prompt_bufnr)
  local pickers_to_cycle = get_pickers_to_cycle()
  local state = require("telescope.actions.state")
  local current_picker = state.get_current_picker(prompt_bufnr)

  local next_index = 1
  for i, title in ipairs(pickers_to_cycle) do
    if title == current_picker.prompt_title then
      next_index = i + 1
      if next_index > #pickers_to_cycle then
        next_index = 1
      end
      break
    end
  end
  local next_title = pickers_to_cycle[next_index]
  local new_picker = picker_map[next_title]
  return new_picker({ ["default_text"] = state.get_current_line() })
end

local previous_picker = function(prompt_bufnr)
  local pickers_to_cycle = get_pickers_to_cycle()
  local state = require("telescope.actions.state")
  local current_picker = state.get_current_picker(prompt_bufnr)

  local prev_index = 1
  for i, title in ipairs(pickers_to_cycle) do
    if title == current_picker.prompt_title then
      prev_index = i - 1
      if prev_index == 0 then
        prev_index = #pickers_to_cycle
      end
      break
    end
  end
  local prev_title = pickers_to_cycle[prev_index]
  local new_picker = picker_map[prev_title]
  return new_picker({ ["default_text"] = state.get_current_line() })
end

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = require('telescope.actions').close,
        ['<C-f>'] = next_picker,
        ['<C-b>'] = previous_picker
      }
    },
    pickers = {
      find_files = {
        find_command = { 'rg', '--files', '--hidden', '--iglob', '!.git', '--ignore-file', '.gitignore' }
      }
    },
    extensions = {
      picker_list = {}
    }
  }
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require("telescope").load_extension, "picker_list")

-- Treesitter
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    endwise = { enable = true },
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = { 'bash', 'clojure', 'elixir', 'go', 'graphql', 'html', 'javascript', 'lua', 'python', 'ruby', 'toml', 'typescript', 'yaml', 'vimdoc', 'vim' },
    auto_install = false,
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        include_surrounding_whitespace = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['am'] = '@function.outer',
          ['im'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner'
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        }
      }
    }
  }
end, 0)

-- LSP
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  clojure_lsp = {},
  elixirls = {},
  eslint = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } }
    }
  },

  solargraph = {},
  stimulus_ls = {},
  tailwindcss = {},
  tsserver = {}
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- null-ls
local null_ls = require('null-ls')

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.credo,
    null_ls.builtins.diagnostics.djlint,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.diagnostics.rubocop,
    null_ls.builtins.formatting.cljstyle,
    null_ls.builtins.formatting.djlint,
    null_ls.builtins.formatting.eslint,
    null_ls.builtins.formatting.mix,
    null_ls.builtins.formatting.rubocop
  }
})

-- nvim-cmp
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-e>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete()
      end
    end),
    ['<C-y>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'codeium' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- ###########################################################################
-- Keymaps
-- ###########################################################################

vim.keymap.set('n', '<leader><space>', ":let @/=''<cr>", { noremap = true, desc = 'Clear out recent search highlighting' })
vim.keymap.set('n', '<leader><space><space>', ":%s/\\s\\+$//<cr>", { noremap = true, desc = 'Strip extraneous whitespace' })

vim.keymap.set('n', '<leader><leader>', "<c-^>", { noremap = true, desc = 'Switch to alternate file' })
vim.keymap.set('n', '<C-c>', ":bp\\|bd #<CR>", { noremap = true, desc = 'Delete focused buffer without losing split' })
vim.keymap.set('n', '<leader>d', ":bufdo bd<CR>", { noremap = true, desc = 'Delete all buffers' })

vim.keymap.set("n", "<localleader>p", require('telescope').extensions.picker_list.picker_list, { noremap = true, desc = 'Open Telescope picker list' })
vim.keymap.set("n", "<C-p>", require('telescope.builtin').find_files, { noremap = true, desc = 'Open Telescope' })

vim.keymap.set('n', 'Q', "@q", { desc = 'Apply macro under cursor' })
vim.keymap.set('v', 'Q', "@q", { desc = 'Apply macro on selection' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<C-i>', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

vim.keymap.set('n', 'qo', ":copen<CR>", { noremap = true, desc = 'Open quickfix window' })
vim.keymap.set('n', 'qc', ":cclose<CR>", { noremap = true, desc = 'Close quickfix window' })

vim.keymap.set('n', '<leader>g', ":Git<CR>", { noremap = true, desc = 'Fugitive status buffer' })

vim.keymap.set('c', "%%", "<C-R>=expand('%:h').'/'<CR>", { noremap = true, desc = 'Expand current file path' })
vim.keymap.set('', '<leader>e', ":edit " .. vim.fn.expand('%:h') .. '/', { desc = 'Open file in the same directory as the current file' })

vim.keymap.set('n', 'gs', "<plug>(GrepperOperator)", { desc = 'Search for the current selection' })
vim.keymap.set('x', 'gs', "<plug>(GrepperOperator)", { desc = 'Search for the current selection' })

vim.keymap.set('n', '<CR><CR>', ":TestLast<CR>", { noremap = true, desc = 'Run last test' })

-- Move through wordwraps with 'k' and 'j'
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Make it easier to switch between windows
vim.keymap.set('n', '<C-h>', "<C-w>h", { noremap = true, silent = true })
vim.keymap.set('n', '<C-j>', "<C-w>j", { noremap = true, silent = true })
vim.keymap.set('n', '<C-k>', "<C-w>k", { noremap = true, silent = true })
vim.keymap.set('n', '<C-l>', "<C-w>l", { noremap = true, silent = true })

-- Keep cursor centered when moving up and down
vim.keymap.set('n', '<C-f>', "<C-f>zz", { noremap = true, silent = true })
vim.keymap.set('n', '<C-b>', "<C-b>zz", { noremap = true, silent = true })
vim.keymap.set('n', '<C-d>', "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set('n', '<C-u>', "<C-u>zz", { noremap = true, silent = true })

-- Move visual blocks up and down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- ###########################################################################
-- Autocommands
-- ###########################################################################

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.selmer",
  command = "set filetype=jinja"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  command = "setlocal noexpandtab"
})

-- Add spell checking and autowrap for Git commit messages
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  command = "setlocal spell textwidth=72"
})

-- Auto-clean fugitive buffers
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "fugitive://*",
  command = "set bufhidden=delete"
})

-- Word wrap with line breaks for text files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.txt,*.md,*.markdown,*.rdoc",
  command = "set wrap linebreak nolist textwidth=79 wrapmargin=0"
})

-- vim-lexical setup
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit,markdown,md,txt,rdoc,html,erb,jinja",
  command = "call lexical#init()"
})

-- Set compilers based on file types
vim.api.nvim_create_autocmd("FileType", {
  pattern = "elixir",
  command = "compiler mix"
})

-- Autoformat files using LSP before saving; only doing this for languages
-- that have "official" formatters
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.ex,*.exs",
  command = "call Format"
})

-- vim: ts=2 sts=2 sw=2 et
