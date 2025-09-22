return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    label = {
      style = 'overlay',
      rainbow = {
        enabled = true,
        shade = 5,
      },
    },
    modes = {
      search = {
        enabled = false,
        highlight = { backdrop = true },
      },
      char = {
        enabled = false,
      },
    },
  },
  keys = {
    {
      'gs',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash jump',
    },
    {
      'gS',
      mode = { 'n', 'o', 'x' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Treesitter select',
    },
  },
}
