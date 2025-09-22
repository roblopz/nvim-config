return {
  'loctvl842/monokai-pro.nvim',
  priority = 1000,
  opts = {
    transparent_background = true,
    terminal_colors = true,
    devicons = true,
    filter = 'machine',
    background_clear = {
      'float_win',
      'telescope',
      'which-key',
      'renamer',
      'notify',
      'neo-tree',
    },
  },
  config = function(_, opts)
    local monokai = require 'monokai-pro'
    monokai.setup(opts)
    monokai.load()

    local visual = { bg = '#475459' }
    local visualYank = { bg = '#667980' }

    for group, p in pairs {
      Visual = visual,
      TelescopePreviewLine = visual,
      Search = { fg = '#272822', bg = '#FFD866' },
      CurSearch = { fg = '#272822', bg = '#A2E57B', gui = 'bold' },
      YankyPut = visualYank,
      YankyYanked = visualYank,
      SubstituteRange = visualYank,
      SubstituteExchange = visualYank,
      SubstituteSubstituted = visualYank,
    } do
      vim.api.nvim_set_hl(0, group, { fg = p.fg, bg = p.bg, bold = p.gui == 'bold' })
    end

    -- FIXME:
    vim.cmd 'hi Comment guifg=#5390A6'
    vim.api.nvim_set_hl(0, 'WinSeparator', { fg = '#3d4e54', bold = true })
  end,
}
