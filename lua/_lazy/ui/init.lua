return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'window-clone',
    name = 'window-clone',
    dir = vim.fn.stdpath 'config' .. '/lua/window-clone',
    dev = true,
    config = function()
      require('window-clone').setup()
    end,
  },
  require '_lazy.ui.monokai-theme',
  require '_lazy.ui.snacks',
  require '_lazy.ui.win-pick',
  require '_lazy.ui.colorizer',
  require '_lazy.ui.incline',
  require '_lazy.ui.lualine',
  require '_lazy.ui.noice',
}
