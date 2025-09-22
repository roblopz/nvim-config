return {
  'kylechui/nvim-surround',
  event = 'VeryLazy',
  opts = {
    keymaps = {
      normal = 'ys', -- Surround by motion (ysiw)
      normal_cur_line = 'yS', -- Surround current line adding above/below line
      visual = 'S', -- Surround selection
      visual_line = 'gS', -- Surround selection adding above/below line
      delete = 'ds',
      change = 'cs',
      normal_cur = false, -- Surround current line
      change_line = false,
      insert = false,
      insert_line = false,
      normal_line = false, -- Surround by motion (i.e. iw) and add above/below,
    },
    surrounds = {
      ['j'] = {
        add = { '{/* ', ' */}' },
      },
    },
  },
}
