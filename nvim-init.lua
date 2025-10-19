vim.cmd('source ~/.vimrc')

-- lazy.nvim Bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g['deoplete#enable_at_startup'] = 1
vim.g['airline#extensions#tabline#enabled'] = 1

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my.lsp', {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { silent = true, buffer = bufnr, desc = 'LSP: ' .. desc })
    end
    local showWorkspaceFolders = function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end
    if client:supports_method('textDocument/implementation') then
      map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    end
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
    map('n', 'K', vim.lsp.buf.hover, 'Show docstring')
    map('n', '<C-k>', vim.lsp.buf.signature_help, 'Signature help')
    map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, 'Add workspace folder')
    map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Remove workspace folder')
    map('n', '<leader>wl', showWorkspaceFolders, 'Show workspace folders')
    map('n', '<leader>D', vim.lsp.buf.type_definition, 'Type definition')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Action: Rename')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
    map('n', 'gr', vim.lsp.buf.references, 'Go to references')
    map('n', '<leader>e', vim.diagnostic.show, 'Show Errors')
    map('n', '[d', vim.diagnostic.goto_prev, 'Previous Error')
    map('n', ']d', vim.diagnostic.goto_next, 'Next Error')
    map('n', '<leader>q', vim.diagnostic.toqflist, 'Set quickfix list')

    if client:supports_method('textDocument/completion') then
      -- Optional: trigger autocompletion on EVERY keypress. May be slow!
      -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
      -- client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
    end
  end,
})

require("lazy").setup({
  { -- Fuzzy Search
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local telescope = require('telescope.builtin')
      vim.keymap.set('n', '<leader>t', telescope.find_files, { desc = "Find Files" })
      vim.keymap.set('n', '<leader>fg', telescope.live_grep, { desc = "Live Grep" })
      vim.keymap.set('n', '<leader>fb', telescope.buffers, { desc = "Find Buffers" })
      vim.keymap.set('n', '<leader>fh', telescope.help_tags, { desc = "Find Help Tags" })
    end,
  },
  { -- File Explorer
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({})
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle File Explorer" })
    end,
  },
  { -- Statusline
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto'
        }
      })
    end,
  },
  { -- Git Integration
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
      vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = "Preview git hunk" })
      vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = "Stage git hunk" })
      vim.keymap.set('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = "Undo stage hunk" })
    end,
  },
  { -- Autoformatter
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          go = { 'gofmt' },
          python = { 'yapf' },
          cpp = { 'clang-format' },
          c = { 'clang-format' },
          bash = { 'shfmt' },
          javascript = { 'prettier' },
          typescript = { 'prettier' },
          yaml = { 'prettier' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
      vim.keymap.set({'n', 'v'}, '<leader>f', function() require('conform').format() end, { desc = "Format code" })
    end,
  },

  { -- Session Manager
    'rmagatti/auto-session',
    config = function()
      require('auto-session').setup({
        log_level = 'error',
      })
    end,
  },
  { 'github/copilot.vim' }, -- AI / Copilot
  { -- LSP Configuration
    'neovim/nvim-lspconfig',
    config = function()
      local nvim_lsp = require('lspconfig')
      local on_attach = function(client, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      end
      vim.lsp.config('bashls', {
        cmd = {"/snap/bin/bash-language-server", "start" },
      })
      for _, lang in ipairs({'clangd', 'gopls', 'zls', 'ts_ls', 'vimls', 'pyright',
                             'rust_analyzer', 'bashls'}) do
        vim.lsp.enable(lang)
      end
    end,
  },
  { -- Treesitter for Syntax Highlighting
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {"c", "lua", "cpp", "bash", "go", "javascript", "typescript", "vim", "yaml"},
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
      }
    end,
  },
  { -- Solarized colorscheme
    'Tsuzat/NeoSolarized.nvim',
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      vim.cmd [[ colorscheme NeoSolarized ]]
    end
  }
})
