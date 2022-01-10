set nocompatible
filetype off
set shell=/bin/bash

set hidden

call plug#begin('~/.vim/bundle')

if has('nvim')
  Plug 'neovim/nvim-lspconfig'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'vim-airline/vim-airline'
call plug#end()
call glaive#Install()
filetype plugin indent on


set tabstop=2 softtabstop=2 shiftwidth=2
set autoindent expandtab foldmethod=indent smarttab ruler
set incsearch smartcase ignorecase hlsearch
set mouse=""
set background=light
set inccommand=nosplit
set completeopt=menuone,longest,noselect
syntax sync minlines=1000
syntax on

let g:deoplete#enable_at_startup = 1
let g:airline#extensions#tabline#enabled = 1

nnoremap <leader>m :make<CR>
vnoremap <leader>s :sort<CR>
nnoremap <leader>ss :syntax sync fromStart<CR>
vnoremap <leader>f :FormatLines<CR>
nnoremap <leader>f :FormatCode<CR>
nnoremap <C-D> :e `dirname %`<CR>
nnoremap <leader>ga :!git add %<CR>
nnoremap <leader>t :FZF<CR>
imap <C-J> <ESC><C-J>
nnoremap <C-J> /<+[^+]*+><CR>cf>
inoremap <C-K> <++><ESC>
inoremap D<< std::cerr << __FILE__ ":" << __LINE__ <<
nnoremap <C-U> :e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>

nnoremap <leader>gd :term git diff %<CR>
nnoremap <leader>ga :term git add -p %<CR>
nnoremap <leader>gc :term git commit<CR>
nnoremap <leader>gaa :term git add -p<CR>

" The default diff colorscheme has foreground=background in some cases.
if &diff
  colorscheme evening
endif

" Configure treesitter and LSP.
lua <<EOF
local nvim_lsp = require('lspconfig')

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  --Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end
nvim_lsp.clangd.setup{ on_attach = on_attach }  -- apt install clangd
nvim_lsp.gopls.setup{ on_attach = on_attach } -- apt install gopls
nvim_lsp.zls.setup{ on_attach = on_attach } -- https://github.com/zigtools/zls
nvim_lsp.tsserver.setup{ on_attach = on_attach }  -- npm install -g typescript typescript-language-server
nvim_lsp.vimls.setup{ on_attach = on_attach }  -- npm install -g vim-language-server
nvim_lsp.pyright.setup{ on_attach = on_attach } -- npm install -g pyright
nvim_lsp.sumneko_lua.setup {
  cmd = {"/home/sagarm/code/lua-language-server/bin/Linux/lua-language-server", "-E", "/home/sagarm/code/lua-language-server/main.lua"},
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = vim.split(package.path, ';'),
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand('$VIMRUNTIME/lua')] = true,
          [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        },
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}
nvim_lsp.rls.setup {
  on_attach = on_attach,
  settings = {
    rust = {
      unstable_features = true,
      build_on_save = false,
      all_features = true,
    },
  },
}

require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained",
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
EOF

" Tree-sitter based folding. I prefer indent-based for C++, Rust.
" set foldmethod=expr
" set foldexpr=nvim_treesitter#foldexpr()
