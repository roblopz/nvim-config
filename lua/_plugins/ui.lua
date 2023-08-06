return {
  { "stevearc/dressing.nvim" },
  { "brenoprata10/nvim-highlight-colors" },
  { "rcarriga/nvim-notify" },
  { "kevinhwang91/nvim-bqf",             opts = { preview = { auto_preview = false } } },
  {
    "echasnovski/mini.animate",
    opts = function()
      local animate = require 'mini.animate'

      return {
        cursor = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 200, unit = 'total' })
        },
        scroll = {
          enable = false,
        },
        resize = {
          enable = true,
          timing = animate.gen_timing.linear({ duration = 140, unit = 'total' })
        },
        open = {
          enable = false,
        },
        close = {
          enable = false,
        },
      }
    end
  },
  {
    "karb94/neoscroll.nvim",
    opts = {
      performance_mode = false,
      hide_cursor = false,         -- Hide cursor while scrolling
      stop_eof = true,             -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = true,    -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
    }
  }
}
