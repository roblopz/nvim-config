local M = {}

local util = require 'util'
M.excludeWinFileTypes = { 'NvimTree', "neo-tree", "notify", "TelescopePrompt", "qf", "dap-repl", "quickfix" }

local default_options = {
  mode = 'pick',
  horizontal = false,
  cb = function(res)
    if res.opened and 1 == 2 then
      print("")
    end
  end,
  on_open_set_cursor = nil
}

local function switch_to_target_window(win_layout)
  if #win_layout.windows > 1 then
    local target_win_id = require 'window-picker'.pick_window({ include_current_win = true, show_prompt = false })

    if target_win_id then
      vim.cmd(string.format('%swincmd w', vim.fn.getwininfo(target_win_id)[1].winnr))
      return { proceed = true }
    else
      return { proceed = false }
    end
  end

  return { proceed = true }
end

local function open_in_current_win(bufnr_or_fname)
  if type(bufnr_or_fname) == "number" then
    vim.cmd(string.format("b%d", bufnr_or_fname))
  else
    -- Filename
    vim.cmd(string.format("e %s", bufnr_or_fname))
  end
end

local function check_cursor(winid, options)
  if options.on_open_set_cursor and #options.on_open_set_cursor > 1 then
    vim.api.nvim_win_set_cursor(winid, options.on_open_set_cursor)
  end
end

M.split = function(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})
  local win_layout = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })

  if switch_to_target_window(win_layout).proceed then
    vim.cmd(util.coalesce(opts.horizontal, 'split', 'vs'));
    open_in_current_win(bufnr_or_fname)
    opened = true
  end

  local current_win_id = vim.api.nvim_get_current_win();
  if opened then
    check_cursor(current_win_id, opts)
  end

  return opts.cb({ opened = opened, current_win_id = current_win_id })
end

M.pick = function(bufnr_or_fname, options)
  local opened = false
  local opts = vim.tbl_deep_extend('force', default_options, options or {})
  local win_layout = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })

  if switch_to_target_window(win_layout).proceed then
    open_in_current_win(bufnr_or_fname)
    opened = true
  end

  local current_win_id = vim.api.nvim_get_current_win();
  if opened then
    check_cursor(current_win_id, opts)
  end

  return opts.cb({ opened = opened, current_win_id = current_win_id })
end

M.open = function(bufnr_or_fname, options)
  bufnr_or_fname = bufnr_or_fname or vim.api.nvim_get_current_buf();
  local opts = vim.tbl_deep_extend('force', default_options, options or {})

  if opts.mode == 'split' then
    M.split(bufnr_or_fname, opts);
  else
    M.pick(bufnr_or_fname, opts)
  end
end

M.open_menu = function(bufnr_or_fname, options)
  local menu_opts = { "Vertical Split", "Horizontal Split" }

  local win_layout = util.get_win_layout_info({ lookInAllTabs = false, excludeTypes = M.excludeWinFileTypes })

  if #win_layout.windows > 1 then
    table.insert(menu_opts, 1, "Pick Window")
  end

  vim.ui.select(
    menu_opts,
    { prompt = "Open in..." },
    function(selection)
      local opts = vim.tbl_deep_extend('force', default_options, options or {})

      if selection == 'Pick Window' then
        opts.mode = 'pick';
      elseif selection == 'Vertical Split' then
        opts.mode = 'split';
      elseif selection == 'Horizontal Split' then
        opts.mode = 'split';
        opts.horizontal = true
      else
        return;
      end

      M.open(bufnr_or_fname, opts);
    end
  )
end

return M
