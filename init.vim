" General
set nocompatible
set nobackup
set noerrorbells
set mouse=a
syntax on
set noshowmode

let mapleader = ","

" Util
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

" set switchbuf=useopen
set ignorecase
set smartcase

if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set t_Co=256

" ********** Plugin Registry **********
call plug#begin()
Plug 'olimorris/onedarkpro.nvim'                                     " one-dark-pro theme
Plug 'windwp/nvim-autopairs'                                         " auto-close pairs
Plug 'chentoast/marks.nvim'                                          " marks
Plug 'kyazdani42/nvim-web-devicons'                                  " icons
Plug 'nvim-lualine/lualine.nvim'                                     " status line
Plug 'kyazdani42/nvim-tree.lua'                                      " tree explorer
Plug 'neovim/nvim-lspconfig'                                         " lang server
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}          " better code syntax
Plug 'nvim-lua/plenary.nvim'                                         " Necessary for telescope
Plug 'nvim-telescope/telescope.nvim'                                 " Telescope
Plug 'nvim-telescope/telescope-live-grep-args.nvim'                  " Enable args for telescope grep
Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }                    " Tabs
Plug 'hrsh7th/cmp-nvim-lsp'                                          " Autocompletion lsp integration
Plug 'hrsh7th/cmp-buffer'                                            " Autocompletion buffer?
Plug 'hrsh7th/cmp-path'                                              " Autocompletion path?
Plug 'hrsh7th/cmp-cmdline'                                           " Autocompletion cmdline
Plug 'hrsh7th/nvim-cmp'                                              " Autocompletion main
Plug 'hrsh7th/cmp-vsnip'                                             " Snippet
Plug 'hrsh7th/vim-vsnip'                                             " Snippet
Plug 'onsails/lspkind.nvim'                                          " Autocomplete window icons
Plug 's1n7ax/nvim-window-picker'                                     " Window picker fn
Plug '~/.config/nvim/util'                                           " Custom util funcions
Plug 'folke/lua-dev.nvim'                                            " Lua dev plugin
Plug 'lukas-reineke/indent-blankline.nvim'                           " Indentation lines
Plug 'RRethy/vim-illuminate'                                         " Highlight word under cursor
Plug 'karb94/neoscroll.nvim'                                         " Smooth scrolling
Plug 'kevinhwang91/nvim-bqf'                                         " Quickfix window popup and uitl
Plug 'famiu/bufdelete.nvim'                                          " Delete buffers without loosing winlayout
Plug 'akinsho/toggleterm.nvim', {'tag' : 'v2.*'}                     " Terminals
Plug 'rmagatti/goto-preview'                                         " LSP integration for floating definitions
call plug#end()

noremap <leader>wb <c-w><c-p> " --> Go back to prev window
nnoremap <leader><space> :nohlsearch<CR>

" Insert lines without going into insert mode
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>

lua << EOF
local util = require'util'

require'onedarkpro'.setup {}
vim.o.background = 'dark'
vim.cmd('colorscheme onedarkpro')

-- Delete a buffer
vim.keymap.set('n', '<leader>bd', function ()
  local bufnr = vim.v.count or 0
  require'bufdelete'.bufdelete(bufnr)
end)

-- Switch to buffer by number
vim.keymap.set('n', '<leader>bs', function ()
  local bufnr = vim.v.count
  if bufnr then
    util.goToBuffer(bufnr)
  end
end)

-- Toggle NvimTree OR return to previous window if tree is active already
vim.keymap.set('n', '<C-n>', function()
  local isTree = string.match(vim.fn.bufname('%'), '^NvimTree_%d+$')

  if isTree then
    -- Go back to prev window
    vim.cmd('wincmd p')
  else
    vim.cmd('NvimTreeFocus')
  end
end)

-- Switch to command mode when changing windows
vim.api.nvim_create_autocmd({ "WinEnter" }, {
  callback = function()
    vim.cmd('stopinsert')
  end
})

-- Toggle quickfix window
vim.keymap.set('n', '<leader>qf', function ()
  local currentWinId = vim.fn.win_getid()
  local win = vim.fn.getwininfo(currentWinId)

  -- On quickfix window already --> close it
  if win[1]['quickfix'] == 1 then
    vim.cmd('cclose')
    return
  end

  -- Try locate any open qf window, then go to it if exists OR if entered 2-modified, close directly
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then 
      if vim.v.count == 2 then vim.cmd('cclose')
      else vim.fn.win_gotoid(win.winid) end
      return
    end
  end

  -- No quickfix window is open --> open it if there's anything to show
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd('copen')
  end
end)

-- Toggle terminals
vim.keymap.set('n', '<leader>tt', function ()
  if vim.v.count > 0 then
    vim.cmd(string.format('%s ToggleTerm', vim.v.count))
    return
  end

  vim.cmd('ToggleTermToggleAll')
end)

require'marks'.setup {}

require'nvim-autopairs'.setup{}

require('neoscroll').setup{}

require'bqf'.setup{}

require'toggleterm'.setup {}

require('goto-preview').setup {
  default_mappings = true
}

function _G.set_terminal_keymaps()
  local opts = { noremap = true }
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local function lualineInit(pathOpt)
  local fnameSection = {
    {
      'filename',
      file_status = true,
      path = pathOpt
    }
  }

  if longfPaths then
    fnameSection[1].path = 1
  end

  require'lualine'.setup {
    extensions = { 'nvim-tree', 'quickfix' },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = fnameSection,
      lualine_x = {'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    }
  }
end

local pathOpt = 0

vim.keymap.set('n', '<C-g>', function ()
  pathOpt = pathOpt + 1;
  
  if pathOpt == 2 then pathOpt = 3
  elseif pathOpt > 3 then pathOpt = 0 end

  lualineInit(pathOpt)
end)

lualineInit(pathOpt)

require 'window-picker'.setup { 
  include_current_win = true,
  selection_chars = 'ABCDEFGHIJKLMNOPQRSTUVXYZ',
  current_win_hl_color = '#4493c8',
  other_win_hl_color = '#54aeeb'
}

require("indent_blankline").setup {
    show_current_context = true,
    show_current_context_start = true,
    use_treesitter = true,
    --show_first_indent_level = false
}

require'nvim-tree'.setup {
  open_on_setup = true,
  open_on_tab = true,
  view = {
    number = true,
    relativenumber = true
  },
  filters = {
    dotfiles = true
  },
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        folder_arrow = true,
        git = false
      }
    }
  }
}

require("bufferline").setup{
  options = {
    mode = "buffers",
    numbers = "buffer_id",
    offsets = {
        {
          filetype = "NvimTree",
          highlight = "Directory",
          text_align = "left"
        }
    },
    sort_by = 'tabs',
    left_mouse_command = function (bufnr)
      util.goToBuffer(bufnr)
    end,
    close_command = 'Bdelete %s'
  },
}

require'nvim-treesitter.configs'.setup{
  highlight = {
    enable = true,
  },
}

--[[ *** Telescope *** ]]
local telescope = require'telescope'
local actions = require("telescope.actions")
local transform_mod = require("telescope.actions.mt").transform_mod
local lga_actions = require("telescope-live-grep-args.actions")

local customActions = setmetatable({}, {
  __index = function(_, k)
    error("'telescope.makeTelescopeCmd' does not have a value: " .. tostring(k))
  end,
})

-- Default select: Go to exisint buffer/window if any, or prompt select available window
customActions.default_select = function(promptBufn)
  local state = require'telescope.actions.state'
  local entry = state.get_selected_entry()

  local bufnr = entry.bufnr
  local filename = entry.path or entry.filename

  if entry.bufnr or filename then
    actions.close(promptBufn)
  end

  if bufnr then
    util.goToBuffer(bufnr)
  elseif filename then
    -- if it's open in any window --> Go there
    -- else if winCount > 1 --> Pick window
    -- else --> :e file

    bufnr = util.getOpenBufferNumberByName(filename, true)

    if bufnr ~= nil then
      util.goToBuffer(bufnr)
    elseif util.hasWindowsOpen(false) then
      local targetWinId = require'window-picker'.pick_window()
      if targetWinId ~= nil then
        local targetWinnr = vim.fn.getwininfo(targetWinId)[1].winnr
        vim.cmd(string.format('%swincmd w', targetWinnr))
        vim.cmd(string.format('e %s', filename))
      end
    else
      vim.cmd(string.format('e %s', filename))
    end
  else
    print('No file/bufnumber selected!')
    return
  end

  if entry.lnum and entry.col then
    vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col })
  end
end

customActions = transform_mod(customActions)

telescope.setup{
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = actions.close,
      }
    }
  },
  pickers = {
    find_files = {
      mappings = {
        i = {
          ["<cr>"] = customActions.default_select,
        }
      }
    },
    live_grep = {
      mappings = {
        i = {
          ["<cr>"] = customActions.default_select,
        }
      }
    },
    buffers = {
      mappings = {
        i = {
          ["<cr>"] = customActions.default_select,
        }
      }
    }
  },
}

telescope.load_extension('live_grep_args')

-- Find files
vim.keymap.set('n', '<leader>ff', function () 
  require'telescope.builtin'.find_files()
end)

-- Live grep extension
vim.keymap.set('n', '<leader>fg', function () 
  telescope.extensions.live_grep_args.live_grep_args({ 
    mappings = {
      i = {
        ['<cr>'] = customActions.default_select
      }
    }
  })
end)

-- Find buffers
vim.keymap.set('n', '<leader>fb', function ()
  require'telescope.builtin'.buffers()
end)

-- Registers
vim.keymap.set('n', '<leader>fr', function ()
  require'telescope.builtin'.registers()
end)

--[[ *** End telescope *** ]]

--------------------------
--[[ *** LSP config *** ]]
--------------------------

local lspConfig = require'lspconfig'
local cmp = require'cmp'
local lspkind = require'lspkind'
local cmpNvimLsp = require'cmp_nvim_lsp'

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' },
    }, {
      { name = 'buffer' },
  }),
  formatting = { 
    format = lspkind.cmp_format({
      mode = 'symbol_text',
    })
  },
  view = {
    entries = { name = 'custom', selection_order = 'near_cursor' }
  }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local cmpCapabilities = cmpNvimLsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  require 'illuminate'.on_attach(client)

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
end

local flags = { debounce_text_changes = 15 }

-- ts-server
lspConfig.tsserver.setup { on_attach = on_attach, flags = flags, capabilities = cmpCapabilities }

-- lua server
lspConfig.sumneko_lua.setup(require'lua-dev'.setup {
  lspconfig = { on_attach = on_attach, flags = flags, capabilities = cmpCapabilities }
})

--[[ *** End LSP config *** ]]
EOF
