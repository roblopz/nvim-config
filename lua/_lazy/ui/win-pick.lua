return {
  'gbrlsnchs/winpick.nvim',
  config = function()
    local winpick = require 'winpick'
    local open_win = require 'open-window'

    winpick.setup {
      border = 'double',
      filter = open_win.default_win_pick_filter,
      prompt = 'Pick a window: ',
      format_label = winpick.defaults.format_label,
      chars = nil,
    }
  end,
}
