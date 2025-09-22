local M = {}

---@type snacks.win.Config|{}
M.styles = {
  relative = 'cursor',
  keys = {
    close = { '<C-c>', { 'cmp_close', 'cancel' }, mode = { 'i', 'n' }, expr = true },
  },
}

return M
