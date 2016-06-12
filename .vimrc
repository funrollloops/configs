set nocompatible
filetype off
set shell=/bin/bash

call plug#begin('~/.vim/bundle')
Plug 'Valloric/YouCompleteMe', { 'do': 'sudo -H npm install -g tern typescript && sudo -H pip2 install jedi && python2 ./install.py --clang-completer --gocode-completer --tern-completer' }
Plug 'scrooloose/syntastic'
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
call plug#end()
call glaive#Install()
filetype plugin indent on


set tabstop=2 softtabstop=2 shiftwidth=2
set autoindent expandtab foldmethod=indent smarttab ruler
set incsearch smartcase ignorecase hlsearch
syntax sync minlines=1000
syntax on

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
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

" Use python2 ./install.py --clang-completer when installing YCM.
let g:ycm_server_python_interpreter = '/usr/bin/python2'
autocmd FileType python let b:codefmt_formatter = 'yapf'

" Disable go autofmt from vim-go because closes all folds on bufwrite.
let g:go_fmt_autosave = 0
autocmd BufWritePre *.go :FormatCode<CR>

nnoremap <leader>m :make<CR>
nnoremap <leader>ss :syntax sync fromStart<CR>
vnoremap <leader>f :FormatLines<CR>
nnoremap <leader>f :FormatCode<CR>
nnoremap <C-D> :e `dirname %`<CR>
nnoremap <leader>ga :!git add %<CR>
nnoremap <leader>t :FZF<CR>
imap <C-J> <ESC><C-J>
nnoremap <C-J> /<+[^+]*+><CR>cf>
inoremap <C-K> <++><ESC>

nnoremap <leader>gd :term git diff %<CR>
nnoremap <leader>ga :term git add -p %<CR>
nnoremap <leader>gaa :term git add -p<CR>
