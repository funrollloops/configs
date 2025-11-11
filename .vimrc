set nocompatible
filetype off
set shell=/bin/bash
set hidden

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
set autoread
syntax sync minlines=1000
syntax on

augroup golang
  autocmd!
  autocmd FileType go set noexpandtab
augroup END

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
nnoremap <leader>ga :term git add -p %<CR>i
nnoremap <leader>gc :term git commit<CR>i
nnoremap <leader>gca :term git commit --amend<CR>i
nnoremap <leader>gaa :term git add -p<CR>i

" Automatically reload the file if it was changed outside of Vim.
augroup auto_reload
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold * if mode() != 'c' | checktime | endif
  autocmd FileChangedShellPost * echohl WarningMsg | echom "File changed on disk. Reloading..." | echohl None
augroup END
