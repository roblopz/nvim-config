local M = {}

---@type snacks.indent.Config|{}
M.options = {
  enabled = true,
  indent = { hl = 'SnacksIndent' },
  scope = {
    enabled = true,
    char = '│',
    only_current = true,
    hl = 'SnacksIndentScope',
  },
  animate = {
    enabled = vim.fn.has 'nvim-0.10' == 1,
    style = 'out',
    easing = 'linear',
    duration = {
      step = 15,
      total = 300,
    },
  },
}

return M
