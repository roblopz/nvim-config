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
vim.opt.signcolumn = 'auto'
-- Decrease update time
vim.opt.updatetime = 250
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
vim.opt.softtabstop = -1
vim.opt.shiftwidth = 2
vim.opt.tabstop = 8
vim.opt.fillchars = { eob = ' ' }

-- Load configs in vim format
vim.cmd(string.format('source %s', vim.fn.stdpath 'config' .. '/config.vim'))

if vim.fn.getenv 'TERM_PROGRAM' == 'ghostty' then
  vim.opt.title = true
  vim.opt.titlestring = "%{fnamemodify(getcwd(), ':~')} - Nvim"
end

--[[ ============================= MAPPINGS ============================== ]]

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- W and WA
vim.keymap.set({ 'n', 'i' }, 'ã-Xss', '<cmd>w<CR>')
vim.keymap.set({ 'n', 'i' }, 'ã-Xsa', '<cmd>wa<CR>')
-- Window moving & closing
vim.keymap.set({ 'n' }, '<C-c>', '<Cmd>close<CR>')
vim.keymap.set({ 'n' }, '<M-S-Right>', '<C-w>l')
vim.keymap.set({ 'n' }, '<M-S-Left>', '<C-w>h')
vim.keymap.set({ 'n' }, '<M-S-Up>', '<C-w>k')
vim.keymap.set({ 'n' }, '<M-S-Down>', '<C-w>j')
-- Enter visual
vim.keymap.set({ 'n' }, '<S-Up>', '<S-v><Up>')
vim.keymap.set({ 'n' }, '<S-Down>', '<S-v><Down>')
-- Tabs
vim.keymap.set({ 'n' }, '<C-w>tt', '<Cmd>tabnew<CR>')
vim.keymap.set({ 'n' }, '<C-w>tc', '<Cmd>tabclose<CR>')

--[[ ============================== LAZYVIM ============================== ]]

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

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
        { '<leader>t', group = 'NeoTree [T]oggle' },
        { '<leader>to', group = 'NeoTree Float' },
        { '<leader>f', group = '[F]ind' },
        { '<leader>fl', group = '[L]sp' },
        { '<leader>q', group = '[Q]uick list' },
        { '<leader>h', group = '[H]ighlight' },
        { '<leader>hw', group = '[H]ighlight word' },
        { '<leader>hc', group = 'Clear [H]ighlight' },
        { '<C-w>o', group = '[W]indow [O]pen at' },
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

vim.api.nvim_create_augroup('AutoAdjustResize', { clear = true })

vim.api.nvim_create_autocmd('VimResized', {
  group = 'AutoAdjustResize',
  callback = function()
    vim.cmd 'wincmd ='
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
