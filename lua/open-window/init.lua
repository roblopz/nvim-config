---@class OpenWindowOptions
---@field mode? 'pick'|'split'|'vsplit' -- Default: 'pick'
---@field cb? fun(result: {opened: boolean}): any -- Callback function
---@field on_open_set_cursor? number[] -- [row, col] cursor position
---@field pick_window_include_current? boolean -- Default: true

---@class OpenWindowResult
---@field proceed boolean

---@class WinMap
---@field id integer
---@field bufnr integer

---@alias WinFilterFunc fun(winid: integer, bufnr: integer?): boolean

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
    'incline',
    'noice',
    'harpoon',
  },
}

---@type OpenWindowOptions
local default_options = {
  mode = 'pick',
  cb = function(res)
    if res.opened and 1 == 2 then
      print ''
    end
  end,
  on_open_set_cursor = nil,
  pick_window_include_current = true,
}

---@param bool boolean
---@param if_true any
---@param if_false any
---@return any
local function coalesce(bool, if_true, if_false)
  if bool then
    return if_true
  else
    return if_false
  end
end

---@param opts OpenWindowOptions
---@return number
function M.get_pick_target_win_count(opts)
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

---@param winid integer
---@param bufnr integer?
---@return boolean
function M.default_win_pick_filter(winid, bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local ftype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  local exclude = vim.tbl_contains(M.excludeWinFileTypes, ftype)
  local is_floating = vim.api.nvim_win_get_config(winid).relative ~= ''

  return not exclude and not is_floating
end

---@param filter (fun(winid: integer, bufnr: integer?, default_filter: WinFilterFunc): boolean)?
---@return WinMap[]
function M.get_eligible_pick_windows(filter)
  local win_map = vim.tbl_map(function(winid)
    return {
      id = winid,
      bufnr = vim.api.nvim_win_get_buf(winid),
    }
  end, vim.api.nvim_tabpage_list_wins(0))

  local eligible_wins = vim.tbl_filter(function(win_item)
    if filter then
      -- return true
      return filter(win_item.id, win_item.bufnr, M.default_win_pick_filter)
    end

    return M.default_win_pick_filter(win_item.id, win_item.bufnr)
  end, win_map)

  return eligible_wins
end

---@param opts OpenWindowOptions
---@return OpenWindowResult
local function switch_to_target_window(opts)
  if M.get_pick_target_win_count(opts) > 1 then
    local target_win_id = require('winpick').select {
      filter = function(winid, bufnr, default_filter)
        if not opts.pick_window_include_current and (winid == vim.api.nvim_get_current_win()) then
          return false
        end

        return default_filter(winid, bufnr)
      end,
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

---@param bufnr_or_fname number|string
local function open_in_current_window(bufnr_or_fname)
  local bufnr = type(bufnr_or_fname) == 'number' and bufnr_or_fname or vim.fn.bufnr(bufnr_or_fname, true)

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end

  if not vim.api.nvim_get_option_value('buflisted', { buf = bufnr }) then
    vim.api.nvim_set_option_value('buflisted', true, { buf = bufnr })
  end

  vim.api.nvim_win_set_buf(0, bufnr)
end

---@param winid number
---@param options OpenWindowOptions
local function set_win_cursor(winid, options)
  if options.on_open_set_cursor and #options.on_open_set_cursor > 1 then
    vim.api.nvim_win_set_cursor(winid, options.on_open_set_cursor)
  end
end

---@param bufnr_or_fname number|string
---@param options? OpenWindowOptions
---@return any
local function open_split(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if switch_to_target_window(opts).proceed then
    vim.cmd(coalesce(opts.mode == 'split', 'split', 'vs'))
    open_in_current_window(bufnr_or_fname)
    set_win_cursor(vim.api.nvim_get_current_win(), opts)
    opened = true
  end

  return opts.cb { opened = opened }
end

---@param bufnr_or_fname number|string
---@param options? OpenWindowOptions
---@return any
local function open_pick(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if switch_to_target_window(opts).proceed then
    open_in_current_window(bufnr_or_fname)
    set_win_cursor(vim.api.nvim_get_current_win(), opts)
    opened = true
  end

  return opts.cb { opened = opened }
end

---@param bufnr_or_fname? number|string
---@param options? OpenWindowOptions
M.open = function(bufnr_or_fname, options)
  bufnr_or_fname = bufnr_or_fname or vim.api.nvim_get_current_buf()
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if opts.mode == 'vsplit' or opts.mode == 'split' then
    open_split(bufnr_or_fname, opts)
  else
    open_pick(bufnr_or_fname, opts)
  end
end

return M
