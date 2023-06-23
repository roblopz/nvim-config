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
    Plug 'neovim/nvim-lspconfig'                                " Lspconfig
    Plug 'nvim-lua/plenary.nvim'                                " Required for many plugins
    Plug 'nvim-tree/nvim-web-devicons'                          " Icons
    Plug 'MunifTanjim/nui.nvim'                                 " Required for neo-tree
    Plug 'nvim-neo-tree/neo-tree.nvim'                         " Explorer
    Plug 's1n7ax/nvim-window-picker'                            " Window picker fn
    Plug 'nvim-lualine/lualine.nvim'                            " Status line
    Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.2' }    " Telescope
    Plug 'nvim-telescope/telescope-live-grep-args.nvim'         " Enable args for telescope grep
    Plug 'gbprod/yanky.nvim'                                    " Yank ring
    Plug 'gbprod/substitute.nvim'                               " s-key substitutions
call plug#end()

colorscheme kanagawa-wave

autocmd User TelescopePreviewerLoaded setlocal nonumber

lua << EOF
  require 'setup'.init{}
  vim.cmd('source ses')
EOF
