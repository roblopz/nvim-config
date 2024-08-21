local M = {
  excludeWinFileTypes = {
    'NvimTree',
    'neo-tree',
    'notify',
    'TelescopePrompt',
    'qf',
    'dap-repl',
    'quickfix',
    'alpha',
    'trouble',
    'Trouble',
  },
}

local function coalesce(bool, if_true, if_false)
  if bool then
    return if_true
  else
    return if_false
  end
end

M.get_pick_target_win_count = function(opts)
  local target_win_count = 0
  local tab_wins = vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())
  local current_win_id = vim.api.nvim_get_current_win()

  for _, id in ipairs(tab_wins) do
    local win_bufnr = vim.api.nvim_win_get_buf(id)

    -- Check is not excluded and it's not floating
    if
      not vim.tbl_contains(M.excludeWinFileTypes, vim.api.nvim_get_option_value('filetype', { buf = win_bufnr }))
      and vim.api.nvim_win_get_config(id).relative == ''
      and (opts.pick_window_include_current or id ~= current_win_id)
    then
      target_win_count = target_win_count + 1
    end
  end

  return target_win_count
end

local default_options = {
  mode = 'pick',
  horizontal = false,
  cb = function(res)
    if res.opened and 1 == 2 then
      print ''
    end
  end,
  on_open_set_cursor = nil,
  pick_window_show_prompt = false,
  pick_window_include_current = true,
}

local function switch_to_target_window(opts)
  if M.get_pick_target_win_count(opts) > 1 then
    local target_win_id = require('window-picker').pick_window {
      include_current_win = opts.pick_window_include_current,
      show_prompt = opts.pick_window_show_prompt,
    }

    if target_win_id then
      vim.api.nvim_set_current_win(target_win_id)
      return { proceed = true }
    else
      return { proceed = false }
    end
  end

  return { proceed = true }
end

local function open_in_current_window(bufnr_or_fname)
  local bufnr = type(bufnr_or_fname) == 'number' and bufnr_or_fname or vim.fn.bufnr(bufnr_or_fname, true)

  ---@diagnostic disable-next-line: param-type-mismatch
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  ---@diagnostic disable-next-line: assign-type-mismatch
  if not vim.api.nvim_get_option_value('buflisted', { buf = bufnr }) then
    ---@diagnostic disable-next-line: assign-type-mismatch
    vim.api.nvim_set_option_value('buflisted', true, { buf = bufnr })
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  vim.api.nvim_win_set_buf(0, bufnr)
end

local function set_win_cursor(winid, options)
  if options.on_open_set_cursor and #options.on_open_set_cursor > 1 then
    vim.api.nvim_win_set_cursor(winid, options.on_open_set_cursor)
  end
end

M.split = function(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if switch_to_target_window(opts).proceed then
    vim.cmd(coalesce(opts.horizontal, 'split', 'vs'))
    open_in_current_window(bufnr_or_fname)
    set_win_cursor(vim.api.nvim_get_current_win(), opts)
    opened = true
  end

  return opts.cb { opened = opened }
end

M.pick = function(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if switch_to_target_window(opts).proceed then
    open_in_current_window(bufnr_or_fname)
    set_win_cursor(vim.api.nvim_get_current_win(), opts)
    opened = true
  end

  return opts.cb { opened = opened }
end

M.open = function(bufnr_or_fname, options)
  bufnr_or_fname = bufnr_or_fname or vim.api.nvim_get_current_buf()
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if opts.mode == 'split' then
    M.split(bufnr_or_fname, opts)
  else
    M.pick(bufnr_or_fname, opts)
  end
end

M.open_menu = function(bufnr_or_fname, options)
  local menu_opts = { 'Vertical Split', 'Horizontal Split' }
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if M.get_pick_target_win_count(opts) > 1 then
    table.insert(menu_opts, 1, 'Pick Window')
  end

  vim.ui.select(menu_opts, { prompt = 'Open in...' }, function(selection)
    if selection == 'Pick Window' then
      opts.mode = 'pick'
    elseif selection == 'Vertical Split' then
      opts.mode = 'split'
    elseif selection == 'Horizontal Split' then
      opts.mode = 'split'
      opts.horizontal = true
    else
      return
    end

    M.open(bufnr_or_fname, opts)
  end)
end

return M
