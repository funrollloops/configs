set nocompatible
filetype off
set shell=/bin/bash

set hidden

call plug#begin('~/.vim/bundle')
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
if !has('nvim')
  Plug 'Valloric/YouCompleteMe', { 'do': 'sudo -H npm install -g tern typescript && sudo -H pip2 install jedi && python2 ./install.py --clang-completer --gocode-completer --tern-completer --rust-completer' }
  Plug 'scrooloose/syntastic'
else
  Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'scrooloose/nerdtree'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'vim-airline/vim-airline'
Plug 'vim-syntastic/syntastic'
Plug 'rust-lang/rust.vim'
call plug#end()
call glaive#Install()
filetype plugin indent on


set tabstop=2 softtabstop=2 shiftwidth=2
set autoindent expandtab foldmethod=indent smarttab ruler
set incsearch smartcase ignorecase hlsearch
set mouse=""
set background=light
set inccommand=nosplit
syntax sync minlines=1000
syntax on

let g:deoplete#enable_at_startup = 1

let g:airline#extensions#tabline#enabled = 1

"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_typescript_tsc_fname = ''
"let g:syntastic_javascript_closurecompiler_script="/home/sagarm/.bin/closure-compiler"
let g:syntastic_javascript_closurecompiler_script="make"
let g:syntastic_enable_javascript_checker = 1
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_python_pylint_args = '--rcfile=/home/sagarm/.pylintrc'
let g:syntastic_javascript_checkers = ['closurecompiler']
let g:syntastic_go_checkers = ['go', 'govet']
let g:syntastic_cpp_compiler_options = ' -std=c++14 -stdlib=libc++'

let g:syntastic_enable_rust_checker = 1
autocmd FileType rust let g:syntastic_rust_checkers = ['cargo']

let g:LanguageClient_serverCommands = {
    \ 'cpp': ['clangd-6.0'],
    \ 'rust': ['/home/sagarm/.cargo/bin/rls'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ }

let g:rustfmt_autosave = 1

" Use python2 ./install.py --clang-completer when installing YCM.
let g:ycm_server_python_interpreter = '/usr/bin/python2'
autocmd FileType python let b:codefmt_formatter = 'yapf'

" Disable go autofmt from vim-go because closes all folds on bufwrite.
let g:go_fmt_autosave = 0
autocmd BufWritePre *.go :FormatCode<CR>

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

function SetLSPShortcuts()
  nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
  nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
  nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
  nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
  nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
  nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
  nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
  nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
  nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
  nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
  autocmd!
  autocmd FileType cpp,c,typescript,javascript call SetLSPShortcuts()
augroup END
