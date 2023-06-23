local util = require 'util'

local M = {}

M.excludeWinFileTypes = { 'NvimTree', "neo-tree", "notify", "TelescopePrompt", "qf", "dap-repl", "quickfix" }

local defaultSetupOpts = {
  setup_commands = true,
  exclude_win_filetypes = M.excludeWinFileTypes,
  quickfix = {
    enable = true,
    mappings = {
      menu = "<C-M>",
      vsplit = "<C-V>",
      hsplit = "<C-X>",
      pick = "<C-S>",
      menub = "<S-M>",
      vsplitb = "<S-V>",
      hsplitb = "<S-X>",
      pickb = "<S-S>"
    },
  }
}

local function open_window(bufInfo, openMode)
  if bufInfo == nil then
    error("Invalid argument at open function")
  end

  if bufInfo.buffer == nil and not bufInfo.fPath then
    error("Open target bufnr or fPath not received!")
  end

  if openMode == 'vert' or openMode == 'vertical' then
    vim.cmd('vs')
  end

  if openMode == 'horizontal' or openMode == 'horz' then
    vim.cmd('split')
  end

  if bufInfo.buffer ~= nil then
    vim.cmd(string.format("b%d", bufInfo.buffer.bufnr))
    util.ensure_buf_listed(bufInfo.buffer.bufnr)
  else
    vim.cmd(string.format("e %s", bufInfo.fPath))
  end
end

local function open_window_with_picker(bufInfo)
  if bufInfo == nil then
    error("Invalid argument at open_picker")
  end

  if bufInfo.buffer == nil and not bufInfo.fPath then
    error("Open target bufnr or fPath not received!")
  end

  local openOnWinId = require 'window-picker'.pick_window({ include_current_win = true })
  if openOnWinId ~= nil then
    local targetWinnr = vim.fn.getwininfo(openOnWinId)[1].winnr
    -- Switch to target window
    vim.cmd(string.format('%swincmd w', targetWinnr))

    if bufInfo.buffer ~= nil then
      vim.cmd(string.format('b%d', bufInfo.buffer.bufnr))
      util.ensure_buf_listed(bufInfo.buffer.bufnr)
    else
      vim.cmd(string.format("e %s", bufInfo.fPath))
    end

    return true
  end

  return false
end

local function open_split(bufInfo, winLayout, callback, direction)
  local originalWin = vim.api.nvim_get_current_win()
  local splitFromWin = originalWin

  if #winLayout.windows > 1 then
    splitFromWin = require 'window-picker'.pick_window({ include_current_win = true })
  end

  if splitFromWin == nil then
    callback(false)
    return
  end

  if originalWin ~= splitFromWin then
    vim.api.nvim_set_current_win(splitFromWin)
  end

  open_window(bufInfo, direction)
  callback(true)
end

local modeActions = {
  openNew = {
    t = "New window",
    trigger = function(bufInfo, _, callback)
      open_window(bufInfo, nil)
      callback(true)
    end
  },
  vsplit = {
    t = "Vertical split",
    trigger = function(bufInfo, winLayout, callback)
      open_split(bufInfo, winLayout, callback, 'vertical')
    end
  },
  hsplit = {
    t = "Horizontal split",
    trigger = function(bufInfo, winLayout, callback)
      open_split(bufInfo, winLayout, callback, 'horizontal')
    end
  },
  pick = {
    t = "Pick window",
    trigger = function(bufInfo, _, callback)
      callback(open_window_with_picker(bufInfo))
    end
  }
}

local function set_win_cursor(cursorOpt, originalWinId, targetWinId)
  if cursorOpt then
    if type(cursorOpt) == 'boolean' then
      local originalCursor = vim.api.nvim_win_get_cursor(originalWinId)
      vim.api.nvim_win_set_cursor(targetWinId, originalCursor)
    elseif type(cursorOpt) == 'table' and #cursorOpt > 1 then
      vim.api.nvim_win_set_cursor(targetWinId, cursorOpt)
    end
  end
end

local function get_default_open_modes(winLayout)
  local modesRes = {}
  local tabWinCount = #winLayout.windows

  if tabWinCount > 1 then
    table.insert(modesRes, "pick")
  end

  if tabWinCount > 0 then
    table.insert(modesRes, "vsplit")
    table.insert(modesRes, "hsplit")
  end

  return modesRes
end

local function get_telescope_entry_info()
  local state = require 'telescope.actions.state'
  local entry = state.get_selected_entry()

  if entry ~= nil then
    return {
      entry = entry,
      bufnr_or_filename = entry.bufnr or entry.path or entry.filename,
      input = state.get_current_line()
    }
  else
    return {
      entry = nil,
      bufnr_or_filename = nil,
      input = state.get_current_line()
    }
  end
end

local function get_bmode(mode)
  local resMode = mode
  local isBack = false

  if util.endsWith(resMode, "b") then
    isBack = true
    resMode = string.sub(resMode, 1, string.len(resMode) - 1)
  end

  return resMode, isBack
end

local function setup_quickfix(qfOptions)
  local function isQf(bufnr)
    return vim.api.nvim_buf_get_option(bufnr or vim.fn.bufnr(), "filetype") == "qf"
  end

  local function onQfMap(mode)
    return function()
      if not isQf() then return end

      local qfWin = vim.api.nvim_get_current_win()
      local itemIdx = vim.api.nvim_win_get_cursor(qfWin)[1]
      ---@diagnostic disable-next-line: undefined-field
      local item = vim.fn.getqflist({ items = 0 }).items[itemIdx]
      local useMode, backToQf = get_bmode(mode)

      if item and item.bufnr then
        M.open(item.bufnr, {
          modes = util.coalesce(useMode == 'menu', nil, { useMode }),
          set_cursor = util.coalesce(item.lnum ~= nil, { item.lnum, item.col or 0 }, nil),
          callback = function(opened)
            if opened then
              vim.fn.setqflist({}, 'a', { idx = itemIdx })
            end
          end,
          stay = backToQf
        })
      end
    end
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    callback = function(args)
      if args.buf and isQf(args.buf) then
        for map, key in pairs(qfOptions.mappings) do
          if defaultSetupOpts.quickfix.mappings[map] and key then
            vim.keymap.set("n", key, onQfMap(map), { noremap = true, buffer = args.buf })
          end
        end
      end
    end
  })
end

function M.open(bufnr_or_filename, opts)
  local defaultOpts = {
    prompt_title = "Open in new window",
    callback = function(opened) end,
    modes = nil, -- e.g. { 'vsplit', 'pick' }
    stay = false,
    set_cursor = true -- Either boolean to try restore cursor from original window OR an object { lnum, col }
  }

  opts = vim.tbl_extend("force", defaultOpts, opts or {}) or defaultOpts

  local winLayout = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })
  local bufInfo = util.get_buffer_info(bufnr_or_filename, { useWinLayout = winLayout })
  local defaultModes = get_default_open_modes(winLayout)

  -- Check the action is actually available to perform
  local useModes = defaultModes

  if opts.modes ~= nil then
    useModes = vim.tbl_filter(function(m) return vim.tbl_contains(defaultModes, m) end, opts.modes)
  end

  local originalWinId = winLayout.currentWindow.winid
  local restoreWindow = false

  if winLayout.currentWindow.excluded then
    local availableWin = util.tbl_first(winLayout.windows, function(w) return not w.excluded end)
    if not availableWin then
      util.warn("No available windows")
      return opts.callback(false)
    else
      vim.api.nvim_set_current_win(availableWin.winid)
      restoreWindow = true
    end
  end

  local function onModeSelected(selected)
    if selected then
      modeActions[selected].trigger(
        bufInfo,
        winLayout,
        function(opened)
          if opened then
            local newWindId = vim.api.nvim_get_current_win()
            set_win_cursor(opts.set_cursor, originalWinId, newWindId)

            -- If stay in original window
            if opts.stay then
              vim.api.nvim_set_current_win(originalWinId)
            end
          elseif restoreWindow then
            vim.api.nvim_set_current_win(originalWinId)
          end

          return opts.callback(opened)
        end
      )
    else
      if restoreWindow then
        vim.api.nvim_set_current_win(originalWinId)
      end

      opts.callback(false)
    end
  end

  -- Default to create new window
  if not useModes or #useModes == 0 then
    useModes = { "openNew" }
  end

  if #useModes == 1 then
    return onModeSelected(useModes[1])
  else
    vim.ui.select(
      useModes,
      {
        prompt = opts.prompt_title,
        format_item = function(item)
          if modeActions[item] then return modeActions[item].t end
          return item.tostring
        end
      },
      onModeSelected
    )
  end
end

function M.map_telescope(fn, mode)
  return function(promptBufn)
    local entryInfo = get_telescope_entry_info()
    local entry = entryInfo.entry

    if entryInfo.bufnr_or_filename ~= nil then
      local winLayout = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })

      if #winLayout.windows == 0 then
        util.warn("No available windows")
        return
      end

      local originalInput = entryInfo.input or ""
      require 'telescope.actions'.close(promptBufn)

      if entry ~= nil then
        M.open(entryInfo.bufnr_or_filename, {
          modes = { mode },
          set_cursor = { entry.lnum, entry.col },
          callback = function(opened)
            if not opened then
              fn({ default_text = originalInput })
            else
            end
          end
        })
      end
    end
  end
end

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaultSetupOpts, opts or {}) or defaultSetupOpts

  M.excludeWinFileTypes = opts.excludeWinFileTypes

  if opts.quickfix.enable then
    setup_quickfix(opts.quickfix);
  end

  if opts.setup_commands then
    vim.api.nvim_create_user_command("WinThere", function(argOpts)
      local parsedOpts = {}
      local openOpts = {}

      for _, arg in ipairs(argOpts.fargs) do
        if arg:find("=") == nil then
          parsedOpts[arg] = true
        else
          local param = vim.split(arg, "=")
          local key = table.remove(param, 1)
          param = table.concat(param, "=")
          parsedOpts[key] = param
        end
      end

      local mode = parsedOpts.mode
      local winLayput = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })
      if #winLayput.windows > 1 then
        openOpts.modes = util.coalesce(mode ~= nil, { mode }, nil)
      else
        openOpts.modes = util.coalesce(mode == 'vsplit' or mode == 'hsplit', { mode }, nil)
      end

      if openOpts.modes and openOpts.modes[1] == "menu" then
        openOpts.modes = nil
      end

      if parsedOpts.stay == "true" or parsedOpts.stay == true then openOpts.stay = true end

      if parsedOpts.title then
        local title = string.match(argOpts.args, [[title="([^"]+)]])
        if title then
          openOpts.prompt_title = title
        else
          openOpts.prompt_title = parsedOpts.title
        end
      end

      M.open(vim.fn.bufnr(), openOpts)
    end, { bang = true, desc = "Open window <there>", nargs = "*" })
  end
end

return M
