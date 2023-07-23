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

" Don't jump next on search
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
nnoremap <silent> g* :let @/=expand('<cword>') <bar> set hls <cr>

autocmd User TelescopePreviewerLoaded setlocal nonumber
