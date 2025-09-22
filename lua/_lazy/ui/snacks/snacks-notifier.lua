local M = {}

---@type snacks.notifier.Config|{}
M.options = {
  enabled = true,
  timeout = 5000,
  level = vim.log.levels.DEBUG,
  style = 'fancy',
  sort = { 'added', 'level' },
  icons = {
    error = ' ',
    warn = ' ',
    info = ' ',
    debug = ' ',
    trace = '󰳟 ',
  },
}

function M.setup()
  vim.api.nvim_set_hl(0, 'SnackNotifySuccessBorder', { fg = '#4F6752', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'SnackNotifySuccessSuccessFooter', { fg = '#4F6752', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'SnackNotifySuccessSuccessIcon', { fg = '#a9dc76', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'SnackNotifySuccessSuccessMsg', { fg = '#fcfcfa', bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'SnackNotifySuccessSuccessTitle', { fg = '#a9dc76', bg = 'NONE' })

  local snack_notify = Snacks.notifier.notify

  ---@param msg string
  ---@param level? snacks.notifier.level|number
  ---@param opts? snacks.notifier.Notif.opts
  ---@diagnostic disable-next-line: duplicate-set-field
  Snacks.notifier.notify = function(msg, level, opts)
    if level == 'success' and (opts == nil or not opts.hl) then
      opts = opts or {}
      opts.icon = ' '
      opts.hl = {
        border = 'SnackNotifySuccessBorder',
        footer = 'SnackNotifySuccessSuccessFooter',
        icon = 'SnackNotifySuccessSuccessIcon',
        msg = 'SnackNotifySuccessSuccessMsg',
        title = 'SnackNotifySuccessSuccessTitle',
      }
    end

    return snack_notify(msg, level, opts)
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function(msg, level, opts)
    vim.notify = Snacks.notifier.notify
    return Snacks.notifier.notify(msg, level, opts)
  end
end

return M
