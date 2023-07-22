local M = {}

M.setup = function()
  -- Static indentation color / "surimiOrange" from kanagawa theme
  vim.cmd('hi MiniIndentscopeSymbol guifg=#FFA066')

  -- This provides overall indentation lines
  require 'indent_blankline'.setup({
    char = "│",
    filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
    show_trailing_blankline_indent = false,
    show_current_context = false,
  })

  -- Used on command to toggle static indentation lines
  local mini_indent = require 'mini.indentscope'
  mini_indent.setup({
    symbol = "│",
    options = {
      border = 'bottom',
      indent_at_cursor = false,
      try_as_border = true
    },
    draw = {
      delay = 500,
      animation = mini_indent.gen_animation.quadratic({ easing = 'in-out', duration = 350, unit = 'total' })
    },
  })

  -- Disable mini so it triggers manually only
  vim.cmd('au! MiniIndentscope')

  -- Provider scope indentation
  require('hlchunk').setup({
    chunk = {
      enable = true,
      use_treesitter = true,
      notify = true, -- notify if some situation(like disable chunk mod double time)
      exclude_filetypes = {
        aerial = true,
        dashboard = true,
        help = true,
        Trouble = true,
        lazy = true
      },
      chars = {
        horizontal_line = "─",
        vertical_line = "│",
        left_top = "╭",
        left_bottom = "╰",
        right_arrow = ">",
      },
      style = {
        { fg = "#7AA89F" },
      },
    },
    indent = {
      enable = false,
    },
    line_num = {
      enable = false
    },
    blank = {
      enable = false,
    },
    context = {
      enable = false
    }
  })
end

return M
