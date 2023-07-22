local M = {}

-- Get full tab info from either tabnr or nvim tab handler
-- If no argument provided then get current tab info
-- Argument is an object of type { tabnr?: number, handler?: number }
local function get_tab_info(arg)
  if arg == nil then
    local nvimCurrentTabHandler = vim.api.nvim_get_current_tabpage()
    local currentTab = vim.fn.gettabinfo(vim.fn.tabpagenr())[1]
    currentTab.handler = nvimCurrentTabHandler
    return currentTab
  elseif arg.tabnr ~= nil then
    local tabs = vim.fn.gettabinfo(arg.tabnr)

    if #tabs > 0 then
      local tab = tabs[1]
      local handlers = vim.api.nvim_list_tabpages()

      for _, h in ipairs(handlers) do
        local hTabnr = vim.api.nvim_tabpage_get_number(h)
        if hTabnr == arg.tabnr then
          tab.handler = h
          return tab
        end
      end
    end

    print(string.format("Tab <tabnr=%s> not found", arg.tabnr))
    return nil
  elseif arg.handler ~= nil then
    local ok, tabnr = pcall(vim.api.nvim_tabpage_get_number, arg.handler)
    if not ok then
      print(string.format("Tab <tab_handler=%s> not found", arg.handler))
      return nil
    end

    return get_tab_info({ tabnr = tabnr })
  end
end

-- Apply fn over current tab and optionally on all open tabs
-- fn returns not nil or false to quit and return | nil or true keep executing
local function tab_do(fn, applyInAllTabs)
  local currentTab = get_tab_info()
  local res = fn(currentTab)

  if res then
    return res
  elseif currentTab ~= nil and applyInAllTabs then
    local allTabHandlers = vim.api.nvim_list_tabpages()
    for _, h in ipairs(allTabHandlers) do
      if h ~= currentTab.handler then
        res = fn(get_tab_info({ handler = h }))
        if res then
          return res
        end
      end
    end
  end
end

function M.coalesce(bool, if_true, if_false)
  if bool then
    return if_true
  else
    return if_false
  end
end

function M.tbl_first(tbl, fn)
  for _, e in pairs(tbl) do
    if fn(e) then
      return e
    end
  end

  return nil
end

function M.printObj(o)
  local function dump(_o)
    if type(_o) == 'table' then
      local s = '{ '
      for k, v in pairs(_o) do
        if type(k) ~= 'number' then k = '"' .. k .. '"' end
        s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
      end
      return s .. '} '
    else
      return tostring(_o)
    end
  end

  print(dump(o))
end

function M.endsWith(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end

function M.ensure_buf_listed(bufnr)
  local listed = vim.fn.getbufvar(bufnr, '&buflisted')
  if listed == 0 then
    vim.fn.setbufvar(bufnr, '&buflisted', 1)
  end
end

-- Returns layout windows information as:
-- { allWindows: <windows without excluding filters>, windows: <windows with excluding filters> }
function M.get_win_layout_info(_opts)
  local defaultOpts = {
    excludeTypes = { 'NvimTree', "neo-tree", "notify", "TelescopePrompt", "qf", "dap-repl", "quickfix", "Trouble" },
    lookInAllTabs = true,
    excludeUnnamed = true,
    excludeFloating = true
  }

  local opts = vim.tbl_extend("force", defaultOpts, _opts or {}) or defaultOpts

  local res = {
    windows = {},
    allWindows = {},
    currentWindow = {}
  }

  local currentWinId = vim.api.nvim_get_current_win()
  local currentTabId = vim.api.nvim_get_current_tabpage()
  local winIDs = {}

  tab_do(function(tab)
    local tabWinIDs = vim.api.nvim_tabpage_list_wins(tab.handler)
    for _, id in ipairs(tabWinIDs) do
      table.insert(winIDs, id)
    end
  end, opts.lookInAllTabs)

  for _, id in ipairs(winIDs) do
    local winTabid = vim.api.nvim_win_get_tabpage(id)
    local bufnr = vim.api.nvim_win_get_buf(id)

    local win = {
      winid = id,
      winnr = vim.api.nvim_win_get_number(id),
      tabid = winTabid,
      tabnr = vim.api.nvim_tabpage_get_number(winTabid),
      bufnr = bufnr,
      bufname = vim.api.nvim_buf_get_name(bufnr),
      isActive = id == currentWinId,
      isInCurrentTab = currentTabId == winTabid,
      ftype = vim.api.nvim_buf_get_option(bufnr, 'filetype'),
      isFloating = vim.api.nvim_win_get_config(id).relative ~= ""
    }

    local exclude = (opts.excludeUnnamed and (not win.bufname or win.bufname == "")) or
        (opts.excludeTypes and vim.tbl_contains(opts.excludeTypes, vim.api.nvim_buf_get_option(bufnr, 'filetype'))) or
        (opts.excludeFloating and win.isFloating)

    win.excluded = exclude
    table.insert(res.allWindows, win)

    if not win.excluded then
      table.insert(res.windows, win)
    end

    if win.winid == currentWinId then
      res.currentWindow = win
    end
  end

  return res
end

function M.get_buffer_info(bufnr_or_filename, _opts)
  local t = type(bufnr_or_filename)
  if t ~= "number" and t ~= "string" then
    print(string.format("Bad argument %s at fn getFullBufferInfo", bufnr_or_filename))
    return nil
  end

  local defaultOptions = {
    getWinLayoutOptions = nil,
    useWinLayout = nil
  }

  local opts = vim.tbl_extend("force", defaultOptions, _opts or {}) or {}

  local res = {
    argIsBufnr = false,
    argIsFile = false,
    fPath = nil,
    buffer = nil,
    window = nil
  }

  local bufnr = nil

  if t == "number" then
    res.argIsBufnr = true

    if vim.fn.bufexists(bufnr_or_filename) then
      bufnr = bufnr_or_filename
    end
  else
    res.argIsFile = true
    res.fPath = bufnr_or_filename

    local targetBuffer = M.tbl_first(vim.fn.getbufinfo(), function(buf)
      return buf.name == bufnr_or_filename
    end)

    if targetBuffer then
      bufnr = targetBuffer.bufnr
    end
  end

  if bufnr ~= nil then
    res.buffer = {
      bufnr = bufnr,
      fname = vim.fn.bufname(bufnr),
      loaded = vim.fn.bufloaded(bufnr),
      listed = vim.fn.buflisted(bufnr),
      ftype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    };

    res.fPath = res.buffer.fname

    local layout = opts.useWinLayout or M.get_win_layout_info(opts.getWinLayoutOptions)
    local bufWin = M.tbl_first(layout.allWindows, function(win)
      return win.bufnr == bufnr
    end)

    if bufWin ~= nil then
      res.window = bufWin
    end
  end

  return res
end

function M.get_working_directory()
  local lspUtil = require 'lspconfig.util'
  local startpath = vim.fn.getcwd()
  return lspUtil.find_git_ancestor(startpath) or lspUtil.find_package_json_ancestor(startpath)
end

function M.warn(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'warn')
end

function M.info(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'info')
end

function M.error(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'error')
end

function M.get_base_config_path()
  local config_paths = vim.api.nvim_list_runtime_paths()
  for _, path in ipairs(config_paths) do
    if string.find(path, ".config/nvim") then
      return path
    end
  end
end

return M
