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
Plug 'tpope/vim-obsession'
Plug 'airblade/vim-gitgutter'
Plug 'github/copilot.vim'
call plug#end()
call glaive#Install()
filetype plugin indent on

if executable('rg')
    set grepprg=rg\ --vimgrep
endif

set tabstop=2 softtabstop=2 shiftwidth=2
set autoindent expandtab foldmethod=indent smarttab ruler
set incsearch smartcase ignorecase hlsearch
set mouse=""
set background=light
set inccommand=nosplit
set completeopt=menuone,longest,noselect
syntax sync minlines=1000
syntax on

augroup golang
  autocmd!
  autocmd FileType go set noexpandtab
augroup END

let g:deoplete#enable_at_startup = 1
let g:airline#extensions#tabline#enabled = 1

nnoremap <leader>m :make<CR>
nnoremap <leader>r :e %<CR>
nnoremap <leader>rr :e! %<CR>
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
lua << EOF
local nvim_lsp = require'lspconfig'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function nnoremap(from, to)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', from, to, {noremap=true, silent=true})
  end

  --Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  nnoremap('gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>')
  nnoremap('gd', '<Cmd>lua vim.lsp.buf.definition()<CR>')
  nnoremap('K', '<Cmd>lua vim.lsp.buf.hover()<CR>')
  nnoremap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
  nnoremap('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  nnoremap('<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>')
  nnoremap('<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>')
  nnoremap('<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>')
  nnoremap('<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
  nnoremap('<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  nnoremap('<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  nnoremap('gr', '<cmd>lua vim.lsp.buf.references()<CR>')
  nnoremap('<leader>e', '<cmd>lua vim.diagnostic.show_line_diagnostics()<CR>')
  nnoremap('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
  nnoremap(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
  nnoremap('<leader>q', '<cmd>lua vim.diagnostic.set_loclist()<CR>')
end
nvim_lsp.clangd.setup{ on_attach = on_attach }  -- apt install clangd
nvim_lsp.gopls.setup{ on_attach = on_attach } -- go install golang.org/x/tools/gopls@latest
nvim_lsp.zls.setup{ on_attach = on_attach } -- https://github.com/zigtools/zls
nvim_lsp.ts_ls.setup{ on_attach = on_attach }  -- npm install -g typescript typescript-language-server
nvim_lsp.vimls.setup{ on_attach = on_attach }  -- npm install -g vim-language-server
nvim_lsp.pyright.setup{ on_attach = on_attach } -- npm install -g pyright
nvim_lsp.rls.setup {
  on_attach = on_attach,
  settings = {
    rust = {
      build_on_save = false,
      all_features = true,
    },
  },
}
nvim_lsp.bashls.setup{ cmd = {"/usr/local/bin/bash-language-server", "start" }, on_attach = on_attach }

require'nvim-treesitter.configs'.setup {
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
EOF

Glaive vim-codefmt yapf_executable=yapf3
