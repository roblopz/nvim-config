return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    local devicons = require 'nvim-web-devicons'

    local function make_path_getter(bufnr)
      local parts = vim.split(vim.api.nvim_buf_get_name(bufnr), '/', { trimempty = true })
      local parts_length = #parts

      return function(parent_dir_length, part_only)
        part_only = part_only or false

        if parent_dir_length == nil or parent_dir_length <= 0 then
          parent_dir_length = 0
        end

        if part_only then
          return parts_length - parent_dir_length > 0 and parts[parts_length - parent_dir_length] or ''
        end

        local res = parts[parts_length]

        if not res then
          return 'No Name'
        end

        for i = 1, parent_dir_length, 1 do
          res = parts[parts_length - i] .. '/' .. res
        end

        return res
      end
    end

    require('incline').setup {
      window = {
        placement = {
          horizontal = 'right',
          vertical = 'top',
        },
      },
      hide = { cursorline = 'focused_win' },
      render = function(props)
        local path_getter = make_path_getter(props.buf)
        local short_fname = path_getter()

        if not short_fname or short_fname == '' then
          short_fname = '[No Name]'
        end

        local ft_icon, ft_color = devicons.get_icon_color(short_fname)

        local function get_diagnostic_label()
          local icons = { error = ' ', warn = ' ', info = ' ', hint = ' ' }
          local label = {}

          for severity, icon in pairs(icons) do
            local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
            if n > 0 then
              table.insert(label, { icon .. n .. ' ', group = 'DiagnosticSign' .. severity })
            end
          end
          if #label > 0 then
            table.insert(label, { '| ' })
          end

          return label
        end

        local function get_harpoon_items()
          local harpoon = require 'harpoon'
          local h_items = harpoon:list().items
          local bufname = vim.api.nvim_buf_get_name(props.buf)
          local label = {}

          for item_idx, item in ipairs(h_items) do
            if item.context.bufname == bufname then
              table.insert(label, { item_idx .. ' ', guifg = '#A2E57B', gui = 'bold' })
            else
              table.insert(label, { item_idx .. ' ', guifg = '#8b9798' })
            end
          end

          if #label > 0 then
            table.insert(label, 1, { '󰛢 ', guifg = '#61AfEf' })
            table.insert(label, { '| ' })
          end
          return label
        end

        local function get_file_name()
          local filename = path_getter(2)

          local label = {}
          table.insert(label, { (ft_icon or '') .. ' ', guifg = ft_color, guibg = 'none' })
          table.insert(label, { vim.bo[props.buf].modified and ' ' or '', guifg = '#d19a66' })
          table.insert(label, { filename, gui = vim.bo[props.buf].modified and 'bold,italic' or 'bold' })

          if not props.focused then
            label['group'] = 'BufferInactive'
          end

          return label
        end

        return {
          { '', guifg = '#3a4449' },
          {
            { get_diagnostic_label() },
            { get_harpoon_items() },
            { get_file_name() },
            guibg = '#3a4449',
          },
          { '', guifg = '#314449' },
        }
      end,
    }
  end,
}
