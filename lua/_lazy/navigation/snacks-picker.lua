---@diagnostic disable: assign-type-mismatch
local M = {}

---@type snacks.picker.Action.spec
local function set_picker_win(picker, _, _)
  local eligible_wins = require('open-window').get_eligible_pick_windows()
  if #eligible_wins <= 1 then
    return false
  end

  local temp_hidden = false

  if not picker.layout.split then
    picker.layout:hide()
    temp_hidden = true
  end

  local win = require('winpick').select()
  if not win then
    if temp_hidden then
      picker.layout:unhide()
    end

    return true
  end

  picker.main = win
  if temp_hidden then
    vim.defer_fn(function()
      if not picker.closed then
        picker.layout:unhide()
      end
    end, 100)
  end
end

---@param mode string|string[]?
local function no_op(mode)
  return {
    function() end,
    desc = 'which-key', -- This hides from help window
    mode = mode or { 'i', 'n' },
  }
end

---@type snacks.picker.Action.spec
local function exec_cmd(picker, _, action)
  ---@cast action { cmd: string }
  assert(action.cmd, 'exec_cmd action requires a cmd')
  picker:norm(function()
    vim.cmd(action.cmd)
  end)
end

---@type snacks.picker.Action.spec
local function toggle_layout(picker, _, action)
  ---@cast action snacks.picker.layout.Action
  assert(action.layout, 'Layout action requires a layout')
  local opts = type(action.layout) == 'table' and { layout = action.layout } or action.layout
  ---@cast opts snacks.picker.Config
  local layout = Snacks.picker.config.layout(opts)
  picker:set_layout(layout)

  if (layout.layout.position or 'float') ~= 'float' then
    picker.opts.auto_close = false
    picker.opts.jump.close = false
    picker:toggle('preview', { enable = false })
  end
end

---@type snacks.picker.Action.spec
local function toggle_regex(picker, _, _)
  picker.opts.regex = not picker.opts.regex
  picker.list:set_target()
  picker:find()
end

---@type snacks.picker.Config
M.options = {
  win = {
    input = {
      keys = {
        ['<S-CR>'] = no_op(),
        ['<C-Down>'] = no_op(),
        ['<C-Up>'] = no_op(),
        ['<M-d>'] = no_op(),
        ['<M-f>'] = no_op(),
        ['<c-d>'] = no_op(),
        ['<c-u>'] = no_op(),
        ['<c-g>'] = no_op(),
        ['<c-j>'] = no_op(),
        ['<c-k>'] = no_op(),
        ['<c-n>'] = no_op(),
        ['<c-p>'] = no_op(),
        ['<c-t>'] = no_op(),
        ['j'] = no_op 'n',
        ['k'] = no_op 'n',
        ['q'] = no_op 'n',
        ['<c-r>#'] = no_op(),
        ['<c-r>%'] = no_op(),
        ['<c-r><c-a>'] = no_op(),
        ['<c-r><c-f>'] = no_op(),
        ['<c-r><c-l>'] = no_op(),
        ['<c-r><c-p>'] = no_op(),
        ['<c-r><c-w>'] = no_op(),
        ['<c-w>f'] = { 'layout_default', mode = { 'i', 'n' }, desc = 'Layout default' },
        ['<c-w>d'] = { 'layout_vertical', mode = { 'i', 'n' }, desc = 'Layout vertical' },
        ['<c-w>D'] = { 'layout_dropdown', mode = { 'i', 'n' }, desc = 'Layout dropdown' },
        ['<c-w>v'] = { 'layout_vscode', mode = { 'i', 'n' }, desc = 'Layout vscode' },
        ['<c-w>k'] = { 'layout_top', mode = { 'i', 'n' }, desc = 'Layout top' },
        ['<c-w>j'] = { 'layout_bottom', mode = { 'i', 'n' }, desc = 'Layout bottom' },
        ['<c-w>l'] = { 'layout_right', mode = { 'i', 'n' }, desc = 'Layout right' },
        ['<c-w>h'] = { 'layout_left', mode = { 'i', 'n' }, desc = 'Layout left' },
        ['<M-S-Up>'] = { 'go_win_up', mode = { 'i' }, desc = 'Win up' },
        ['<M-S-Down>'] = { 'go_win_down', mode = { 'i' }, desc = 'Win down' },
        ['<M-S-Right>'] = { 'go_win_right', mode = { 'i' }, desc = 'Win right' },
        ['<M-S-Left>'] = { 'go_win_left', mode = { 'i' }, desc = 'Win left' },
        ['<M-Down>'] = { 'history_forward', mode = { 'i', 'n' } },
        ['<M-Up>'] = { 'history_back', mode = { 'i', 'n' } },
        ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
        ['<M-h>'] = { 'toggle_hidden', mode = { 'i', 'n' }, desc = 'Toggle hidden' },
        ['<M-i>'] = { 'toggle_ignored', mode = { 'i', 'n' }, desc = 'Toggle ignored' },
        ['<M-l>'] = { 'toggle_live', mode = { 'i', 'n' } },
        ['<c-v>'] = { { 'set_picker_win', 'vsplit' }, mode = { 'i', 'n' }, desc = 'Open vsplit' },
        ['<c-x>'] = { { 'set_picker_win', 'split' }, mode = { 'i', 'n' }, desc = 'Open vsplit' },
        ['<c-s>'] = { { 'set_picker_win', 'jump' }, mode = { 'i', 'n' }, desc = 'Pick window' },
      },
    },
    list = {
      keys = {
        ['<2-LeftMouse>'] = no_op(),
        ['<S-CR>'] = no_op(),
        ['<M-d>'] = no_op(),
        ['<M-f>'] = no_op(),
        ['<c-d>'] = no_op(),
        ['<c-j>'] = no_op(),
        ['<c-k>'] = no_op(),
        ['<c-n>'] = no_op(),
        ['<c-p>'] = no_op(),
        ['<c-t>'] = no_op(),
        ['<c-u>'] = no_op(),
        ['q'] = no_op(),
        ['<Esc>'] = 'focus_input',
        ['<c-w>f'] = { 'layout_default', mode = { 'i', 'n' }, desc = 'Layout default' },
        ['<c-w>d'] = { 'layout_vertical', mode = { 'i', 'n' }, desc = 'Layout vertical' },
        ['<c-w>D'] = { 'layout_dropdown', mode = { 'i', 'n' }, desc = 'Layout dropdown' },
        ['<c-w>v'] = { 'layout_vscode', mode = { 'i', 'n' }, desc = 'Layout vscode' },
        ['<c-w>k'] = { 'layout_top', mode = { 'i', 'n' }, desc = 'Layout top' },
        ['<c-w>j'] = { 'layout_bottom', mode = { 'i', 'n' }, desc = 'Layout bottom' },
        ['<c-w>l'] = { 'layout_right', mode = { 'i', 'n' }, desc = 'Layout right' },
        ['<c-w>h'] = { 'layout_left', mode = { 'i', 'n' }, desc = 'Layout left' },
        ['<c-v>'] = { { 'set_picker_win', 'vsplit' }, mode = { 'i', 'n' }, desc = 'Open vsplit' },
        ['<c-x>'] = { { 'set_picker_win', 'split' }, mode = { 'i', 'n' }, desc = 'Open vsplit' },
        ['<c-s>'] = { { 'set_picker_win', 'jump' }, mode = { 'i', 'n' }, desc = 'Pick window' },
      },
    },
    preview = {
      keys = {
        ['q'] = no_op(),
        ['<Esc>'] = 'focus_input',
      },
    },
  },
  toggles = {
    hidden = '(+hidden)',
    ignored = '(+ignored)',
  },
  actions = {
    set_picker_win = set_picker_win,
    exec_cmd = exec_cmd,
    toggle_layout = toggle_layout,
    go_win_up = { action = 'exec_cmd', cmd = 'wincmd k' },
    go_win_down = { action = 'exec_cmd', cmd = 'wincmd j' },
    go_win_left = { action = 'exec_cmd', cmd = 'wincmd h' },
    go_win_right = { action = 'exec_cmd', cmd = 'wincmd l' },
    layout_default = { action = 'toggle_layout', layout = 'default' },
    layout_vertical = { action = 'toggle_layout', layout = 'vertical' },
    layout_dropdown = { action = 'toggle_layout', layout = 'dropdown' },
    layout_vscode = { action = 'toggle_layout', layout = 'vscode' },
    layout_top = { action = 'toggle_layout', layout = 'top' },
    layout_bottom = { action = 'toggle_layout', layout = 'bottom' },
    layout_right = { action = 'toggle_layout', layout = 'right' },
    layout_left = { action = 'toggle_layout', layout = 'left' },
    toggle_regex = toggle_regex,
  },
  formatters = {
    file = {
      truncate = 120,
    },
  },
}

---@param str string
---@return string[]
local function split_by_comma(str)
  local result = {}
  if not str or str == '' then
    return result
  end

  for item in string.gmatch(str, '([^,]+)') do
    local trimmed = item:match '^%s*(.-)%s*$'
    if trimmed ~= '' then
      table.insert(result, trimmed)
    end
  end

  return result
end

---@param value nil|string|string[]
---@return string?
local function value_to_string(value)
  if type(value) == 'string' then
    return value
  elseif type(value) == 'table' and #value > 0 then
    return table.concat(value, ', ')
  end
  return nil
end

---@param value nil|string[]
---@return boolean
local function is_truthy_string_list(value)
  if value and type(value) == 'table' and #value > 0 then
    return true
  end

  return false
end

---@param value nil|string|string[]
---@return boolean
local function is_truthy_string_or_string_list(value)
  if not value then
    return false
  end

  if type(value) == 'string' and value ~= '' then
    return true
  elseif type(value) == 'table' and #value > 0 then
    return true
  end

  return false
end

---@class CreateFilterActionConfig
---@field opt_key string -- The key in picker.opts (e.g., 'ft', 'dirs')
---@field prompt string -- The input prompt (e.g., 'File Type(s):')
---@field icon_prefix string -- The icon prefix (e.g., 'Type:', 'Dirs:')
---@field hl_group string -- The highlight group name
---@field get_opt_value_string fun(value: any): string? -- Convert current option value to string
---@field get_opt_has_value fun(value: any): boolean -- Check if current option has value

---@param picker any
---@param config CreateFilterActionConfig
local function create_filter_action(picker, config)
  local current_value = picker.opts[config.opt_key]
  local current_str = config.get_opt_value_string(current_value)
  local toggle_key = config.opt_key .. '_toggle'

  vim.ui.input({ prompt = config.prompt, default = current_str or '' }, function(input)
    if input and input ~= '' then
      picker.opts[config.opt_key] = split_by_comma(input)
      vim.api.nvim_set_hl(0, config.hl_group, { link = 'SnacksPickerToggleRegex' })
      picker.opts[toggle_key] = config.get_opt_has_value(picker.opts[config.opt_key])

      picker.opts.toggles[toggle_key] = {
        icon = config.icon_prefix .. ' ' .. input,
        enabled = true,
        value = true,
      }
    else
      picker.opts[config.opt_key] = nil
      picker.opts.toggles[toggle_key] = { icon = '', enabled = false, value = false }
    end

    local new_str = config.get_opt_value_string(picker.opts[config.opt_key])
    if current_str ~= new_str then
      picker.list:set_target()
      picker:find()
    end
  end)
end

---@class InitOptionToggleConfig
---@field opt_key string -- The key in picker.opts (e.g., 'ft', 'dirs')
---@field icon_prefix string -- The icon prefix (e.g., 'Type:', 'Dirs:')
---@field get_opt_value_string fun(value: any): string? -- Convert current option value to string

---@param opts snacks.picker.Config|snacks.picker.files.Config
---@param config InitOptionToggleConfig
local function set_init_option_toggle(opts, config)
  local opt_string_value = config.get_opt_value_string(opts[config.opt_key])

  if opt_string_value and opt_string_value ~= '' then
    local toggle_key = config.opt_key .. '_toggle'

    opts[toggle_key] = true
    opts.toggles[toggle_key] = {
      icon = config.icon_prefix .. ' ' .. opt_string_value,
      enabled = true,
      value = true,
    }
  end
end

---@type snacks.picker.files.Config|{}
local file_opts = {
  win = {
    input = {
      keys = {
        ['<M-g>'] = { 'filter_ftype', mode = { 'i', 'n' }, desc = 'Filter ext' },
        ['<M-d>'] = { 'filter_dirs', mode = { 'i', 'n' }, desc = 'Filter dirs' },
        ['<M-e>'] = { 'exclude_patterns', mode = { 'i', 'n' }, desc = 'Exclude patterns' },
      },
    },
  },
  actions = {
    filter_ftype = function(picker)
      create_filter_action(picker, {
        opt_key = 'ft',
        prompt = 'File Extension(s):',
        icon_prefix = 'Ext:',
        hl_group = 'SnacksPickerToggleFtToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_or_string_list,
      })
    end,
    filter_dirs = function(picker)
      create_filter_action(picker, {
        opt_key = 'dirs',
        prompt = 'Filter Directory(s):',
        icon_prefix = 'Dirs:',
        hl_group = 'SnacksPickerToggleDirsToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_list,
      })
    end,
    exclude_patterns = function(picker)
      create_filter_action(picker, {
        opt_key = 'exclude',
        prompt = 'Exclude Patterns:',
        icon_prefix = 'Exclude:',
        hl_group = 'SnacksPickerToggleExcludeToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_list,
      })
    end,
  },
  ---@param opts snacks.picker.files.Config
  config = function(opts)
    set_init_option_toggle(opts, {
      opt_key = 'ft',
      icon_prefix = 'Ext:',
      get_opt_value_string = value_to_string,
    })

    set_init_option_toggle(opts, {
      opt_key = 'dirs',
      icon_prefix = 'Dirs:',
      get_opt_value_string = value_to_string,
    })

    set_init_option_toggle(opts, {
      opt_key = 'exclude',
      icon_prefix = 'Exclude:',
      get_opt_value_string = value_to_string,
    })

    return opts
  end,
}

---@type snacks.picker.grep.Config|{}
local grep_opts = {
  toggles = {
    regex = { icon = 'rgx: OFF', value = false },
  },
  win = {
    input = {
      keys = {
        ['<M-g>'] = { 'apply_glob', mode = { 'i', 'n' }, desc = 'Apply glob' },
        ['<M-d>'] = { 'filter_dirs', mode = { 'i', 'n' }, desc = 'Filter dirs' },
        ['<M-e>'] = { 'exclude_patterns', mode = { 'i', 'n' }, desc = 'Exclude patterns' },
        ['<M-r>'] = { 'toggle_regex', mode = { 'i', 'n' }, desc = 'Toggle Regex' },
      },
    },
  },
  actions = {
    apply_glob = function(picker)
      create_filter_action(picker, {
        opt_key = 'glob',
        prompt = 'Glob(s):',
        icon_prefix = 'Glob:',
        hl_group = 'SnacksPickerToggleGlobToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_or_string_list,
      })
    end,
    filter_dirs = function(picker)
      create_filter_action(picker, {
        opt_key = 'dirs',
        prompt = 'Filter Directory(s):',
        icon_prefix = 'Dirs:',
        hl_group = 'SnacksPickerToggleDirsToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_list,
      })
    end,
    exclude_patterns = function(picker)
      create_filter_action(picker, {
        opt_key = 'exclude',
        prompt = 'Exclude Patterns:',
        icon_prefix = 'Exclude:',
        hl_group = 'SnacksPickerToggleExcludeToggle',
        get_opt_value_string = value_to_string,
        get_opt_has_value = is_truthy_string_list,
      })
    end,
  },
  ---@param opts snacks.picker.files.Config
  config = function(opts)
    set_init_option_toggle(opts, {
      opt_key = 'glob',
      icon_prefix = 'Glob:',
      get_opt_value_string = value_to_string,
    })

    set_init_option_toggle(opts, {
      opt_key = 'dirs',
      icon_prefix = 'Dirs:',
      get_opt_value_string = value_to_string,
    })

    set_init_option_toggle(opts, {
      opt_key = 'exclude',
      icon_prefix = 'Exclude:',
      get_opt_value_string = value_to_string,
    })

    return opts
  end,
}

---@type snacks.picker.buffers.Config|{}
local buffer_opts = {
  win = {
    input = {
      keys = {
        ['<c-x>'] = { { 'set_picker_win', 'split' }, mode = { 'i', 'n' }, desc = 'Open vsplit' },
        ['<c-d>'] = { 'bufdelete', mode = { 'n', 'i' } },
      },
    },
  },
}

local function set_mappings()
  vim.keymap.set('n', '<leader>fb', function()
    Snacks.picker.buffers { current = false }
  end, { desc = '[F]ind [B]uffers' })

  vim.keymap.set('n', '<leader>fB', function()
    Snacks.picker.buffers { current = true }
  end, { desc = '[F]ind [B]uffers - include current' })

  vim.keymap.set('n', '<leader>fc', function()
    Snacks.picker.command_history()
  end, { desc = '[F]ind [C]ommand history' })

  vim.keymap.set('n', '<leader>fd', function()
    Snacks.picker.diagnostics_buffer()
  end, { desc = '[F]ind [D]iagnostics - buffer' })

  vim.keymap.set('n', '<leader>fD', function()
    Snacks.picker.diagnostics()
  end, { desc = '[F]ind [D]iagnostics - workspace' })

  vim.keymap.set('n', '<leader>ff', function()
    Snacks.picker.files()
  end, { desc = '[F]ind [F]iles' })

  vim.keymap.set('n', '<leader>fg', function()
    Snacks.picker.grep()
  end, { desc = '[F]ind [G]rep' })

  vim.keymap.set('n', '<leader>fG', function()
    Snacks.picker.grep_buffers()
  end, { desc = '[F]ind [G]rep - buffers' })

  vim.keymap.set({ 'n', 'v' }, '<leader>fw', function()
    Snacks.picker.grep_word()
  end, { desc = '[F]ind [G]rep word' })

  vim.keymap.set('n', '<leader>fj', function()
    Snacks.picker.jumps()
  end, { desc = '[F]ind [J]umps' })

  vim.keymap.set('n', '<leader>fL', function()
    Snacks.picker.lines()
  end, { desc = '[F]ind [L]ines' })

  vim.keymap.set('n', '<leader>fn', function()
    Snacks.picker.notifications()
  end, { desc = '[Find] [N]otifications' })

  vim.keymap.set('n', '<leader>fo', function()
    Snacks.picker.recent()
  end, { desc = '[Find] [O]ld files' })

  vim.keymap.set('n', '<leader>fr', function()
    Snacks.picker.resume()
  end, { desc = '[Find] [R]esume' })

  vim.keymap.set('n', '<leader>fs', function()
    Snacks.picker.search_history()
  end, { desc = '[Find] [S]earch history' })

  vim.keymap.set('n', '<leader>fu', function()
    Snacks.picker.undo()
  end, { desc = '[Find] [U]ndo' })

  vim.keymap.set('n', '<leader>fR', function()
    Snacks.picker.registers()
  end, { desc = '[Find] [R]egisters' })

  vim.keymap.set('n', '<leader>fls', function()
    Snacks.picker.lsp_symbols()
  end, { desc = '[Find] [L]sp [S]ymbols' })

  vim.keymap.set('n', '<leader>flS', function()
    Snacks.picker.lsp_workspace_symbols()
  end, { desc = '[Find] [L]sp [S]ymbols - workspace' })

  vim.keymap.set('n', '<leader>flr', function()
    Snacks.picker.lsp_references()
  end, { desc = '[Find] [L]sp [R]eferences' })

  vim.keymap.set('n', '<leader>fld', function()
    Snacks.picker.lsp_definitions()
  end, { desc = '[Find] [L]sp [D]efinitions' })

  vim.keymap.set('n', '<leader>flD', function()
    Snacks.picker.lsp_declarations()
  end, { desc = '[Find] [L]sp [D]eclarations' })

  vim.keymap.set('n', '<leader>flt', function()
    Snacks.picker.lsp_type_definitions()
  end, { desc = '[Find] [L]sp [T]ype definitions' })

  vim.keymap.set('n', '<leader>fli', function()
    Snacks.picker.lsp_implementations()
  end, { desc = '[Find] [L]sp [I]mplementation' })
end

function M.setup()
  local files = Snacks.picker.files
  local grep = Snacks.picker.grep
  local grep_word = Snacks.picker.grep_word
  local buffers = Snacks.picker.buffers

  ---@param opts snacks.picker.files.Config?
  ---@return snacks.Picker
  Snacks.picker.files = function(opts)
    opts = vim.tbl_extend('force', file_opts, opts or {})
    return files(opts)
  end

  ---@param opts snacks.picker.grep.Config?
  ---@return snacks.Picker
  Snacks.picker.grep = function(opts)
    opts = vim.tbl_extend('force', grep_opts, opts or {})
    return grep(opts)
  end

  ---@param opts snacks.picker.grep.Config?
  ---@return snacks.Picker
  Snacks.picker.grep_word = function(opts)
    opts = vim.tbl_extend('force', grep_opts, opts or {})
    return grep_word(opts)
  end

  ---@param opts snacks.picker.buffers.Config?
  ---@return snacks.Picker
  Snacks.picker.buffers = function(opts)
    opts = vim.tbl_extend('force', buffer_opts, opts or {})
    return buffers(opts)
  end

  set_mappings()
end

return M
