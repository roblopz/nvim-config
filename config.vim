set nocompatible
set nobackup
set noerrorbells
set mouse=a
syntax on
set noshowmode

let mapleader = ","
set hlsearch
 
" Indentation and tab
set ai
set tabstop=2
set sw=2
set expandtab

" UI
set number
set relativenumber

set noshowmode
set cursorline
set ruler
set list
set splitright

set ignorecase
set smartcase

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set t_Co=256
set autoread

" Avoid jumping next on highlight
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
nnoremap <silent> g* :let @/=expand('<cword>') <bar> set hls <cr>

" Line numbering on telescope prompts
autocmd User TelescopePreviewerLoaded setlocal nonumber

" Refresh file changes
autocmd! FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif

" Line moving
nnoremap <A-j> :m+<CR>==
nnoremap <A-k> :m-2<CR>==
inoremap <A-j> <Esc>:m+<CR>==gi
inoremap <A-k> <Esc>:m-2<CR>==gi
vnoremap <A-j> :m'>+<CR>gv=gv
vnoremap <A-k> :m-2<CR>gv=gv

" Special delete
nnoremap <leader>x "_x
nnoremap <leader>d "_d
nnoremap <leader>D "_D
vnoremap <leader>d "_d
nnoremap <leader>c "_c
nnoremap <leader>C "_C
vnoremap <leader>c "_c