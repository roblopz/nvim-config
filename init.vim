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

call plug#begin()
    Plug 'rebelot/kanagawa.nvim'                                " Theme
    Plug 'folke/which-key.nvim'                                 " Keybinding helper
    Plug 'nvim-lua/plenary.nvim'                                " Required for many plugins
    Plug 'nvim-tree/nvim-web-devicons'                          " Icons
    Plug 'MunifTanjim/nui.nvim'                                 " Required for neo-tree
    Plug 'nvim-neo-tree/neo-tree.nvim'                          " Explorer
    Plug 's1n7ax/nvim-window-picker'                            " Window picker fn
    Plug 'nvim-lualine/lualine.nvim'                            " Status line
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }    " Telescope
    Plug 'nvim-telescope/telescope-live-grep-args.nvim'         " Enable args for telescope grep
    Plug 'gbprod/yanky.nvim'                                    " Yank ring
    Plug 'gbprod/substitute.nvim'                               " s-key substitutions
    Plug 'kevinhwang91/nvim-bqf'                                " Quickfix window popup and uitl
    Plug 'stevearc/dressing.nvim'                               " Extensions for UI in input's and select's 
    Plug 'windwp/nvim-autopairs'                                " Autopairs
    Plug 'echasnovski/mini.animate'                             " Animage cursor
    Plug 'echasnovski/mini.indentscope'                         " More indentation
    Plug 'lukas-reineke/indent-blankline.nvim'                  " Indentation
    Plug 'RRethy/vim-illuminate'                                " Highlight references
    Plug 'karb94/neoscroll.nvim'                                " Scroll animate
    Plug 'brenoprata10/nvim-highlight-colors'                   " Highlight hex
    Plug 'kylechui/nvim-surround'                               " Surround
    Plug 'windwp/nvim-ts-autotag'                               " Close autotags
    " LSP & Related
    Plug 'williamboman/mason.nvim', { 'do': ':MasonUpdate' }    " Lsp server package manager
    Plug 'williamboman/mason-lspconfig.nvim'                    " Lsp server package manager
    Plug 'neovim/nvim-lspconfig'                                " Main lsp
    Plug 'folke/neodev.nvim'                                    " Lua dev lsp
    Plug 'hrsh7th/nvim-cmp'                                     " Main completion
    Plug 'hrsh7th/cmp-nvim-lsp'                                 " Lsp source
    Plug 'hrsh7th/cmp-cmdline'                                  " CMD
    Plug 'hrsh7th/cmp-buffer'                                   " Buffer words
    Plug 'FelipeLema/cmp-async-path'                            " Sys paths cmp
    Plug 'L3MON4D3/LuaSnip'                                     " Snip
    Plug 'saadparwaiz1/cmp_luasnip'                             " Snip-cmp
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " better code syntax
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'          " Text objects for treesitter
    Plug 'JoosepAlviste/nvim-ts-context-commentstring'          " Language-specific comment string
    Plug 'echasnovski/mini.comment'                             " Comment
    Plug 'jose-elias-alvarez/null-ls.nvim'                      " Linting/formatting/actions LSP middleware  
    Plug 'glepnir/lspsaga.nvim'                                 " LspSaga utils
    Plug 'onsails/lspkind.nvim'                                 " Show symbols on cmp completions
    Plug 'ray-x/lsp_signature.nvim'                             " Signature help
    Plug 'rmagatti/goto-preview'                                " Better than sagas gotoLsp
  call plug#end()

" Avoid jumping next on highlight
nnoremap <silent> * :let @/= '\<' . expand('<cword>') . '\>' <bar> set hls <cr>
nnoremap <silent> g* :let @/=expand('<cword>') <bar> set hls <cr>

autocmd User TelescopePreviewerLoaded setlocal nonumber

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

lua << EOF
  require 'setup'.init{}
EOF
