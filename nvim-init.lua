vim.cmd('source ~/.vimrc')

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

vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/Tsuzat/NeoSolarized.nvim',
  { src = 'https://github.com/nvim-telescope/telescope.nvim', version = '0.1.x' },
  'https://github.com/nvim-tree/nvim-tree.lua',
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/rmagatti/auto-session',
  'https://github.com/github/copilot.vim',
  'https://github.com/neovim/nvim-lspconfig',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'master' },
}, { confirm = false })

-- Solarized colorscheme
vim.cmd [[ colorscheme NeoSolarized ]]

-- Fuzzy Search
require('telescope').setup({
  defaults = {
    wrap_results = true,
    layout_strategy = 'vertical',
  }
})
local telescope = require('telescope.builtin')
vim.keymap.set('n', '<leader>tt', telescope.find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>tg', telescope.live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>tb', telescope.buffers, { desc = "Find Buffers" })
vim.keymap.set('n', '<leader>th', telescope.help_tags, { desc = "Find Help Tags" })

-- File Explorer
require("nvim-tree").setup({
  actions = {
    change_dir = {
      enable = false,
    },
  },
})
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle File Explorer" })

-- Statusline
require('lualine').setup({
  options = {
    theme = 'auto'
  }
})

-- Git Integration
require('gitsigns').setup()
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = "Preview git hunk" })
vim.keymap.set('n', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = "Stage git hunk" })
vim.keymap.set('n', '<leader>gu', ':Gitsigns undo_stage_hunk<CR>', { desc = "Undo stage hunk" })
vim.keymap.set('n', '<leader>gr', ':Gitsigns reset_hunk<CR>', { desc = "Reset git hunk" })
vim.keymap.set('v', '<leader>gs', ':Gitsigns stage_hunk<CR>', { desc = "Stage git hunk (visual)" })
vim.keymap.set('n', ']c', ':Gitsigns next_hunk<CR>', { desc = "Next git hunk" })
vim.keymap.set('n', '[c', ':Gitsigns prev_hunk<CR>', { desc = "Previous git hunk" })

-- Autoformatter
require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'gofmt' },
    python = { 'yapf' },
    cpp = { 'clang-format' },
    c = { 'clang-format' },
    bash = { 'shfmt' },
    rust = { 'rustfmt' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    yaml = { 'prettier' },
  },
--format_on_save = {
--  timeout_ms = 500,
--  lsp_fallback = true,
--},
})
vim.keymap.set({'n', 'v'}, '<leader>f', function() require('conform').format({lsp_fallback=true}) end, { desc = "Format code" })

-- Session Manager
require('auto-session').setup({
  log_level = 'error',
})

-- LSP Configuration
vim.lsp.config('pyright', {
  cmd = {"uv", "run", "--with=pyright", "--", "pyright-langserver", "--stdio"},
})
vim.lsp.config('bashls', {
  cmd = {"/usr/bin/env", "bash-language-server", "start" },
})
for _, lang in ipairs({'clangd', 'gopls', 'zls', 'ts_ls', 'vimls', 'pyright',
                       'rust_analyzer', 'bashls'}) do
  vim.lsp.enable(lang)
end

-- Treesitter for Syntax Highlighting
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
