set nocompatible
filetype off
set shell=/bin/bash

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmt'
Plugin 'google/vim-glaive'
call vundle#end()
call glaive#Install()
filetype plugin indent on

set sts=2 sw=2 ts=2 et foldmethod=indent ruler ai
set ic smartcase hlsearch incsearch
syn sync minlines=1000
syntax enable

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
"let g:syntastic_javascript_closurecompiler_script="/home/sagarm/.bin/closure-compiler"
let g:syntastic_javascript_closurecompiler_script="make"
let g:syntastic_enable_javascript_checker = 1
let g:syntastic_python_checkers = ['pylint']
let g:syntastic_javascript_checkers = ['closurecompiler']
let g:ycm_server_python_interpreter = 'usr/bin/python'

autocmd FileType python let b:codefmt_formatter = 'yapf'

vnoremap <leader>f :FormatLines<CR>
nnoremap <leader>f :FormatCode<CR>
nnoremap <C-D> :e `dirname %`<CR>
nnoremap <leader>ga :!git add %<CR>
imap <C-J> <ESC><C-J>
nnoremap <C-J> /<+[^+]*+><CR>cf>
inoremap <C-K> <++><ESC>

nnoremap <leader>gd :term git diff %<CR>
nnoremap <leader>ga :term git add -p %<CR>
nnoremap <leader>gaa :term git add -p<CR>
