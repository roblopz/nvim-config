
local M = {}

-- Apply fn over current tab and optionally on all open tabs
-- fn returns not nil or false to quit and return | nil or true keep executing
local function doInTabs(fn, applyInAllTabs)
  local currentTabnr = vim.fn.tabpagenr()
  local currentTab = vim.fn.gettabinfo(currentTabnr)[1]

  local res = fn(currentTab)

  if res then return res
  elseif applyInAllTabs then
    local allTabs = vim.fn.gettabinfo()
    for _, tab in ipairs(allTabs) do
      if tab.tabnr ~= currentTabnr then
        res = fn(tab)
        if res then return res end
      end
    end
  end
end

local function isTargetBufferInTab(targetBufnr, tabnr)
  local tabBuffers = vim.fn.tabpagebuflist(tabnr)
  if tabBuffers ~= 0 then
    for _, bufNr in ipairs(tabBuffers) do
      if bufNr == targetBufnr then
        return true
      end
    end
  end

  return false
end

local function getOpenWindows(lookInAllTabs)
  local api = vim.api
  local excludeFileTypes = { 'NvimTree', "neo-tree", "notify" }

  local wins = {}

  doInTabs(function (tab)
    local tabWins = api.nvim_tabpage_list_wins(tab.tabnr)
    for _, win in ipairs(tabWins) do
      table.insert(wins, win)
    end
  end, lookInAllTabs)

  return vim.tbl_filter(function (winId)
    local winBuf = api.nvim_win_get_buf(winId)
    local winFileType = api.nvim_buf_get_option(winBuf, 'filetype')
    return not vim.tbl_contains(excludeFileTypes, winFileType)
  end, wins)
end

function M.printObj(o)
  local function dump(_o)
     if type(_o) == 'table' then
        local s = '{ '
        for k,v in pairs(_o) do
           if type(k) ~= 'number' then k = '"'..k..'"' end
           s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
     else
        return tostring(_o)
     end
  end

  print(dump(o))
end

function M.hasWindowsOpen(lookInAllTabs)
  local openWins = getOpenWindows(lookInAllTabs)
  return openWins ~= nil and next(openWins) ~= nil
end

function M.getOpenBufferNumberByName(fileName, lookInAllTabs)
  print(fileName)
  return doInTabs(function (tab)
    local tabBuffers = vim.fn.tabpagebuflist(tab.tabnr)
    for _, bufN in ipairs(tabBuffers) do
      local bufName = vim.fn.bufname(bufN)
      if (fileName == bufName) then
        return bufN
      end
    end
  end, lookInAllTabs)
end

function M.goToBuffer(bufN, opts)
  if bufN == nil then
    print('No buffer number supplied!')
    return
  elseif vim.fn.bufloaded(bufN) == 0 then
    print(string.format("Buffer '%s' not loaded!", bufN))
    return
  end

  -- If there are no windows open, open new loading buffer
  local availableWins = getOpenWindows()
  if availableWins == nil then
    vim.cmd(string.format('b%s', bufN))
    return
  end

  opts = opts or {
    -- Try switch to an existing window first (if buffer is already open)
    trySwitch = true,
    -- If opening the buffer, prompt-select an existing window
    useExistingWindow = true,
    -- If opening a new window (!useExistingWindow) open mode 
    onOpenMode = 'ask' -- | vertical |  horizontal
  }

  local trySwitch = opts.trySwitch
  local useExistingWin = opts.useExistingWindow
  local onOpenMode = opts.onOpenMode

  if type (trySwitch) ~= 'boolean' then trySwitch = true end
  if type (useExistingWin) ~= 'boolean' then useExistingWin = true end
  if type (onOpenMode) ~= 'string' then onOpenMode = 'ask' end
  -- Try switch to existing window in which bufN might be already loaded...
  if trySwitch then

    local bufWin = next(vim.fn.win_findbuf(bufN))
    -- Buffer is loaded in 'some' window, locate it and switch
    if bufWin ~= nil then
      local currentTabNr = vim.fn.tabpagenr()
      local bufrWinLocated = false

     doInTabs(function (tab)
       if isTargetBufferInTab(bufN, tab.tabnr) then
         bufrWinLocated = true

         -- Buffer is in another tab
         if tab.tabnr ~= currentTabNr then
          vim.cmd(string.format('tabn%d', tab.tabnr))
         end

         return true
       end
     end, true)

      if bufrWinLocated then
        local originalSettingVal = vim.api.nvim_command_output('set switchbuf?')
        vim.cmd('set switchbuf=useopen') -- Set seeting so we use exsting buff-window
        vim.cmd(string.format('sb%d', bufN))
        vim.cmd(string.format('set %s', originalSettingVal)) -- Restore setting
      end

      return
    end
  end

  -- Didn't try to switch to existing OR buffer is not loaded in any window
  if useExistingWin then -- Pick a window to open buffer
    local openOnWinId = require'window-picker'.pick_window({ include_current_win = true })
    if openOnWinId ~= nil then
      local targetWinnr = vim.fn.getwininfo(openOnWinId)[1].winnr
      vim.cmd(string.format('%swincmd w', targetWinnr))
      vim.cmd(string.format('%sb', bufN))
    end
  else -- Open in new window
    local winSetting = ''

    if onOpenMode == 'vertical' then winSetting = 'vert'
    elseif onOpenMode == 'horizontal' then winSetting = ''
    else
      local openMode = vim.fn.confirm('Open window mode: ', '&Vertical\n&Horizontal', 1)
      if openMode == nil or openMode <= 0 then
        return
      else
        if openMode == 1 then winSetting = 'vert'
        else winSetting = '' end
      end
    end

    local originalSettingVal = vim.api.nvim_command_output('set switchbuf?')
    vim.cmd('set switchbuf=uselast') -- Set seeting so we use exsting buff-window
    vim.cmd(string.format('%s sb%d', winSetting, bufN))
    vim.cmd(string.format('set %s', originalSettingVal)) -- Restore setting
  end
end


return M
