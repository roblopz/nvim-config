--[[ ============================== CONFIGS ============================== ]]

vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.opt.number = true
vim.opt.relativenumber = true
-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'
-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
-- vim.schedule(function()
--   vim.opt.clipboard = 'unnamedplus'
-- end)
-- Enable break indent
vim.opt.breakindent = true
-- Save undo history
vim.opt.undofile = true
-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300
-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true
-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'
-- Show which line your cursor is on
vim.opt.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
-- hsplit to top
vim.opt.splitbelow = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Load configs in vim format
vim.cmd(string.format('source %s', vim.fn.stdpath 'config' .. '/config.vim'))

--[[ ============================= MAPPINGS ============================== ]]

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- W and WA
vim.keymap.set({ 'n', 'i' }, 'ã-0', '<cmd>w<CR>')
vim.keymap.set({ 'n', 'i' }, 'ã-1', '<cmd>wa<CR>')
-- Window moving & closing
vim.keymap.set({ 'n' }, '<M-Right>', '<C-w>l')
vim.keymap.set({ 'n' }, '<M-Left>', '<C-w>h')
vim.keymap.set({ 'n' }, '<M-Up>', '<C-w>k')
vim.keymap.set({ 'n' }, '<M-Down>', '<C-w>j')
vim.keymap.set({ 'n' }, '<C-c>', '<Cmd>close<CR>')
-- Enter visual
vim.keymap.set({ 'n' }, '<S-Up>', '<S-v><Up>')
vim.keymap.set({ 'n' }, '<S-Down>', '<S-v><Down>')

local function clone_window(open_opts)
  local bufnr = vim.api.nvim_get_current_buf()
  local win_id = vim.api.nvim_get_current_win()
  local is_floating = vim.api.nvim_win_get_config(win_id).relative ~= ''

  local o_width = vim.api.nvim_win_get_width(win_id)
  local o_height = vim.api.nvim_win_get_height(win_id)

  if is_floating then
    vim.api.nvim_win_set_width(win_id, 20)
    vim.api.nvim_win_set_height(win_id, 1)
  end

  require('custom.open-window').open(
    bufnr,
    vim.tbl_deep_extend('force', open_opts, {
      cb = function(res)
        if is_floating then
          if res.opened then
            if not vim.wo.number then
              vim.cmd 'set number'
            end

            if not vim.wo.relativenumber then
              vim.cmd 'set relativenumber'
            end

            vim.api.nvim_win_close(win_id, false)
          else
            vim.api.nvim_win_set_width(win_id, o_width)
            vim.api.nvim_win_set_height(win_id, o_height)
          end
        end
      end,
    })
  )
end

-- Open this window in another window
vim.keymap.set('n', '<C-w>ov', function()
  clone_window {
    mode = 'split',
    horizontal = false,
  }
end, { desc = 'Open this window - vsplit' })

vim.keymap.set('n', '<C-w>ox', function()
  clone_window {
    mode = 'split',
    horizontal = true,
  }
end, { desc = 'Open this window - hsplit' })

vim.keymap.set('n', '<C-w>os', function()
  clone_window {}
end, { desc = 'Open this window - pick where' })

--[[ ============================== LAZYVIM ============================== ]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- :help lazy.nvim-lazy.nvim-structuring-your-plugins
  { import = '_lazy' },

  -- Detect tabstop and shiftwidth automatically
  {
    'tpope/vim-sleuth',
  },
  -- Which key
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()

      require('which-key').add {
        { 'gd', group = 'LSP [G]o' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>f', group = '[F]ind' },
      }
    end,
  },
  -- Add lua types
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  -- Add lya meta
  { 'Bilal2453/luvit-meta', lazy = true },
}, {
  ui = {
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
