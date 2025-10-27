--  Setting leader key must happen before plugins are required (otherwise
--  wrong leader will be used)
vim.g.mapleader = ','
vim.g.maplocalleader = '\\'

-- nvim-tree.lua requires that netrw is disabled
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- If we're using nvim, might as well go all in on lua
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- ###########################################################################
-- Plugins
-- ###########################################################################

-- Bootstrap vim-plug if it's not installed
vim.cmd [[
 let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
 if empty(glob(data_dir . '/autoload/plug.vim'))
     silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
     autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
 endif
]]

vim.cmd([[
call plug#begin()
Plug 'AndrewRadev/splitjoin.vim'                                  " Switch between single-line and multiline forms of code
Plug 'AndrewRadev/writable_search.vim'                            " Grep for something, then write the original files directly through the search results
Plug 'DataWraith/auto_mkdir'                                      " Allows you to save files into directories that do not exist yet
Plug 'EdenEast/nightfox.nvim'                                     " 🦊A highly customizable theme for vim and neovim with support for lsp, treesitter and a variety of plugins
Plug 'Exafunction/windsurf.nvim'                                  " A native neovim extension for Codeium
Plug 'Glench/Vim-Jinja2-Syntax'                                   " Jinja2 syntax highlighting
Plug 'L3MON4D3/LuaSnip'                                           " Snippet Engine for Neovim written in Lua.
Plug 'Olical/conjure'                                             " Interactive evaluation for Neovim.
Plug 'OliverChao/telescope-picker-list.nvim'                      " A plugin that helps you use any pickers in telescope
Plug 'PaterJason/cmp-conjure'                                     " nvim-cmp source for conjure.
Plug 'RRethy/nvim-treesitter-endwise'                             " Tree-sitter aware alternative to tpope's vim-endwise
Plug 'YounesElhjouji/nvim-copy'                                   " Copy the content of files—from visible buffers, Git-modified files, etc. to clipboard
Plug 'elixir-editors/vim-elixir'                                  " Vim configuration files for Elixir
Plug 'folke/neodev.nvim'                                          " Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API
Plug 'gbprod/yanky.nvim'                                          " Improved Yank and Put functionalities for Neovim
Plug 'guns/vim-clojure-static'                                    " Clojure syntax highlighting and indentation
Plug 'guns/vim-sexp'                                              " Precision editing for s-expressions
Plug 'hashivim/vim-terraform'                                     " basic vim/terraform integration
Plug 'honza/vim-snippets'                                         " Default snippets'
Plug 'hrsh7th/cmp-buffer'                                         " nvim-cmp source for buffer words
Plug 'hrsh7th/cmp-cmdline'                                        " nvim-cmp source for vim's cmdline
Plug 'hrsh7th/cmp-nvim-lsp'                                       " nvim-cmp source for neovim builtin LSP client
Plug 'hrsh7th/cmp-nvim-lua'                                       " nvim-cmp source for nvim lua
Plug 'hrsh7th/cmp-path'                                           " nvim-cmp source for path
Plug 'hrsh7th/nvim-cmp'                                           " A completion plugin for neovim coded in Lua
Plug 'j-hui/fidget.nvim'                                          " Extensible UI for Neovim notifications and LSP progress messages
Plug 'kylechui/nvim-surround'                                     " Add/change/delete surrounding delimiter pairs with ease.
Plug 'lewis6991/gitsigns.nvim'                                    " Adds git related signs to the gutter, as well as utilities for managing changes
Plug 'mason-org/mason-lspconfig.nvim', { 'tag': 'v1.32.0' }       " Extension to mason.nvim that makes it easier to use lspconfig
Plug 'mason-org/mason.nvim', { 'tag': 'v1.11.0' }                 " Easily install and manage LSP servers, DAP servers, linters, and formatters
Plug 'mhinz/vim-grepper'                                          " 👾 Helps you win at grep
Plug 'neovim/nvim-lspconfig'                                      " Quickstart configs for Nvim LSP
Plug 'norcalli/nvim-colorizer.lua'                                " The fastest Neovim colorizer.
Plug 'nvim-lua/plenary.nvim'                                      " All the lua functions I don't want to write twice
Plug 'nvim-lualine/lualine.nvim'                                  " A blazing fast and easy to configure neovim statusline plugin written in pure lua
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' } " FZF sorter for telescope written in c
Plug 'nvim-telescope/telescope-ui-select.nvim'                    " Neovim core stuff can fill the telescope picker
Plug 'nvim-telescope/telescope.nvim'                              " Find, Filter, Preview, Pick. All lua, all the time
Plug 'nvim-tree/nvim-tree.lua'                                    " A file explorer tree for neovim written in lua
Plug 'nvim-tree/nvim-web-devicons'                                " Provides Nerd Font icons (glyphs) for use by neovim plugins
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }     " Nvim Treesitter configurations and abstraction layer
Plug 'nvim-treesitter/nvim-treesitter-textobjects'                " Syntax aware text-objects, select, move, swap, and peek support
Plug 'nvimtools/none-ls.nvim'                                     " Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
Plug 'olimorris/codecompanion.nvim'                               " ✨ AI-powered coding, seamlessly in Neovim
Plug 'petertriho/cmp-git'                                         " Git source for nvim-cmp
Plug 'preservim/vim-pencil'                                       " Rethinking Vim as a tool for writing
Plug 'rebelot/kanagawa.nvim'                                      " NeoVim dark colorscheme inspired by the colors of the famous painting by Katsushika Hokusai
Plug 'reedes/vim-lexical'                                         " Build on Vim’s spell/thes/dict completion
Plug 'saadparwaiz1/cmp_luasnip'                                   " luasnip completion source for nvim-cmp
Plug 'scrooloose/nerdcommenter'                                   " quickly (un)comment lines
Plug 'sindrets/diffview.nvim'                                     " Single tabpage interface for easily cycling through diffs for all modified files for any git rev
Plug 'sjl/vitality.vim'                                           " Make Vim play nicely with iTerm 2 and tmux
Plug 'slim-template/vim-slim'                                     " Syntax highlighting for slim
Plug 'tpope/vim-abolish'                                          " easily search for, substitute, and abbreviate multiple variants of a word
Plug 'tpope/vim-bundler'                                          " makes source navigation of bundled gems easier
Plug 'tpope/vim-cucumber'                                         " provides syntax highlighting, indenting, and a filetype plugin
Plug 'tpope/vim-dispatch'                                         " Asynchronous build and test dispatcher
Plug 'tpope/vim-endwise'                                          " wisely add 'end' in ruby, endfunction/endif/more in vim script, etc
Plug 'tpope/vim-fugitive'                                         " Git plugin
Plug 'tpope/vim-leiningen'                                        " static support for Leiningen
Plug 'tpope/vim-projectionist'                                    " project configuration
Plug 'tpope/vim-rails'                                            " Rails helpers
Plug 'tpope/vim-rake'                                             " makes Ruby project navigation easier for non-Rails projects
Plug 'tpope/vim-repeat'                                           " Enable repeating supported plugin maps with '.'
Plug 'tpope/vim-rhubarb'                                          " GitHub extension for fugitive.vim
Plug 'tpope/vim-sexp-mappings-for-regular-people'                 " vim-sexp mappings rely on meta key; these don't
Plug 'vim-ruby/vim-ruby'                                          " packaged w/ vim but this is latest and greatest
Plug 'vim-test/vim-test'                                          " Run your tests at the speed of thought
Plug 'windwp/nvim-autopairs'                                      " autopairs for neovim written by lua
call plug#end()
]])

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

local colorscheme = vim.env.NVIM_COLORSCHEME or 'nightfox'
vim.cmd('colorscheme ' .. colorscheme)

-- ###########################################################################
-- Plugin Configuration
-- ###########################################################################

require('colorizer').setup()
require('lualine').setup({})
require('nvim-surround').setup()
require('nvim-autopairs').setup({ check_ts = true })
require("nvim_copy").setup()
require("yanky").setup()

vim.cmd "let g:NERDDefaultAlign = 'left'"
vim.cmd "let NERDSpaceDelims = 1"
vim.cmd "let test#strategy = 'spawn'"

-- diffview
require('diffview').setup({
  default_args = {
    DiffviewOpen = { "--imply-local" },
  }
})

-- gitsigns
require('gitsigns').setup({
  on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({ ']c', bang = true })
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({ '[c', bang = true })
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)
  end
})

-- codecompanion
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = vim.env.NVIM_AI_CHAT_PROVIDER or "anthropic",
    },
    inline = {
      adapter = vim.env.NVIM_AI_COMPLETION_PROVIDER or "anthropic",
    },
  },
})

-- windsurf
require("codeium").setup({ enable_cmp_source = false, virtual_text = { enabled = true } })
require('codeium.virtual_text').set_statusbar_refresh(function()
  require('lualine').refresh()
end)

-- nvim-tree
require("nvim-tree").setup({
  actions = {
    open_file = {
      quit_on_open = true
    }
  }
})

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
    ensure_installed = { 'bash', 'clojure', 'elixir', 'go', 'graphql', 'heex', 'html', 'javascript', 'lua', 'markdown', 'python', 'ruby', 'toml', 'typescript', 'yaml', 'vimdoc', 'vim' },
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
-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  bashls = {},
  clojure_lsp = {},
  elixirls = {
    cmd = { "~/.local/share/nvim/mason/packages/elixir-ls/language_server.sh" }
  },
  eslint = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' }, globals = { "vim" } }
    }
  },

  solargraph = {},
  stimulus_ls = {},
  tailwindcss = {},
  ts_ls = {}
}

-- Setup neovim lua configuration
require('neodev').setup()

vim.lsp.config("*", {
  capabilities = vim.lsp.protocol.make_client_capabilities()
})

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
    vim.lsp.config(server_name, {
      capabilities = capabilities,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    })
    vim.lsp.enable(server_name)
  end,
}

-- null-ls
local null_ls = require('null-ls')

null_ls.setup({
  debug = true,
  sources = {
    null_ls.builtins.diagnostics.credo,
    null_ls.builtins.diagnostics.djlint,
    null_ls.builtins.diagnostics.rubocop,
    null_ls.builtins.formatting.cljstyle,
    null_ls.builtins.formatting.djlint,
    null_ls.builtins.formatting.mix,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.rubocop,
    null_ls.builtins.formatting.shellharden,
    null_ls.builtins.formatting.shfmt
  }
})

-- nvim-cmp
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_snipmate').lazy_load()
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
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<C-k>'] = cmp.mapping(function(fallback)
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
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'git' },
  },
}

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

require("cmp_git").setup()

-- ###########################################################################
-- Keymaps
-- ###########################################################################

vim.keymap.set('n', '<leader><space>', ":let @/=''<cr>",
  { noremap = true, desc = 'Clear out recent search highlighting' })
vim.keymap.set('n', '<leader><space><space>', ":%s/\\s\\+$//<cr>",
  { noremap = true, desc = 'Strip extraneous whitespace' })

vim.keymap.set('n', '<leader><leader>', "<c-^>", { noremap = true, desc = 'Switch to alternate file' })
vim.keymap.set('n', '<C-c>', ":bp\\|bd #<CR>", { noremap = true, desc = 'Delete focused buffer without losing split' })
vim.keymap.set('n', '<leader>d', ":bufdo bd<CR>", { noremap = true, desc = 'Delete all buffers' })

vim.keymap.set("n", "<localleader>p", require('telescope').extensions.picker_list.picker_list,
  { noremap = true, desc = 'Open Telescope picker list' })
vim.keymap.set("n", "<C-p>", require('telescope.builtin').find_files, { noremap = true, desc = 'Open Telescope' })

vim.keymap.set('n', 'Q', "@q", { desc = 'Apply macro under cursor' })
vim.keymap.set('v', 'Q', "@q", { desc = 'Apply macro on selection' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<C-i>', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })

vim.keymap.set('n', 'qo', ":copen<CR>", { noremap = true, desc = 'Open quickfix window' })
vim.keymap.set('n', 'qc', ":cclose<CR>", { noremap = true, desc = 'Close quickfix window' })

vim.keymap.set('n', '<leader>g', ":Git<CR>", { noremap = true, desc = 'Fugitive status buffer' })

vim.keymap.set('n', '<leader>cp', function()
  vim.fn.setreg('+', vim.fn.expand('%'))
  print('Copied: ' .. vim.fn.expand('%'))
end, { desc = 'Copy relative path' })

vim.keymap.set('c', "%%", "<C-R>=expand('%:h').'/'<CR>", { noremap = true, desc = 'Expand current file path' })
vim.keymap.set('', '<leader>e', ":NvimTreeFindFileToggle<CR>", { desc = 'Open file tree' })

vim.keymap.set('n', 'gs', "<plug>(GrepperOperator)", { desc = 'Search for the current selection' })
vim.keymap.set('x', 'gs', "<plug>(GrepperOperator)", { desc = 'Search for the current selection' })

vim.keymap.set('n', '<CR><CR>', ":TestLast<CR>", { noremap = true, desc = 'Run last test' })

vim.keymap.set('n', '<leader>f', "gg=G<CR>", { noremap = true, desc = 'Quickly re-indent file (does not use LSP)' })

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

-- yanky.nvim
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")

-- TODO: <c-p> conflicts with telescope mapping
-- vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
-- vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyPreviousEntry)")

-- codecompanion
vim.keymap.set({ "n", "v" }, "<LocalLeader>ca", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })
vim.cmd([[cab cc CodeCompanion]]) -- Expand 'cc' into 'CodeCompanion' in the command line

-- diffview
vim.keymap.set({ "n", "v" }, "<LocalLeader>do", "<cmd>DiffviewOpen<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<LocalLeader>dc", "<cmd>DiffviewClose<cr>", { noremap = true, silent = true })

-- ###########################################################################
-- Autocommands
-- ###########################################################################

-- LSP keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(ev)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
    end

    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
    nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

    vim.keymap.set('v', '<leader>ca', vim.lsp.buf.code_action, { buffer = ev.buf, desc = 'LSP: [C]ode [A]ction' })

    vim.api.nvim_buf_create_user_command(ev.buf, 'Format', function(_)
      vim.lsp.buf.format()
    end, { desc = 'Format current buffer with LSP' })
  end
})

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
  pattern = "*.ex,*.exs,*.heex,*.lua,*.js,*.jsx,*.ts,*.tsx",
  command = ":Format"
})

-- Fix known issue with slim plugin
-- https://github.com/slim-template/vim-slim?tab=readme-ov-file#known-issues
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.slim",
  command = "setlocal filetype=slim"
})

-- vim: ts=2 sts=2 sw=2 et
