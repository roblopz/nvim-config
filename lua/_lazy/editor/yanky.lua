return {
  'gbprod/yanky.nvim',
  opts = {
    highlight = { timer = 400, on_put = true, on_yank = true },
    ring = { storage = 'shada' },
  },
    -- stylua: ignore start
    keys = {
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "[y", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Cycle backward through yank history" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", mode = { "n", "x" }, desc = "Put after current line" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", mode = { "n", "x" }, desc = "Put before current line" },
      { ">p", "<Plug>(YankyPutAfterCharwiseJoined)", mode = { "n", "x" }, desc = "Put after, charwise" },
      { "<p", "<Plug>(YankyPutBeforeCharwiseJoined)", mode = { "n", "x" }, desc = "Put before, charwise" },
    },
  -- stylua: ignore end
}
