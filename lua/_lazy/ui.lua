return {
  {
    'loctvl842/monokai-pro.nvim',
    priority = 1000,
    opts = {
      -- transparent_background = true,
      filter = 'machine',
      background_clear = {
        'float_win',
        'telescope',
        'which-key',
        'renamer',
        'notify',
        'neo-tree',
      },
    },
    config = function(_, opts)
      local monokai = require 'monokai-pro'
      monokai.setup(opts)
      monokai.load()
    end,
  },
  {
    -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  { 'stevearc/dressing.nvim' },
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true,
  },
  {
    's1n7ax/nvim-window-picker',
    opts = {
      selection_chars = 'ABCDEFGHIJKLMNOPQRSTUVXYZ',
      filter_rules = {
        bo = {
          filetype = {
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
        },
      },
      highlights = {
        statusline = {
          focused = {
            fg = '#ededed',
            bg = '#44cc41',
            bold = true,
          },
          unfocused = {
            fg = '#ededed',
            bg = '#44cc41',
            bold = true,
          },
        },
        winbar = {
          focused = {
            fg = '#ededed',
            bg = '#44cc41',
            bold = true,
          },
          unfocused = {
            fg = '#ededed',
            bg = '#44cc41',
            bold = true,
          },
        },
      },
    },
  },
  {
    'b0o/incline.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local devicons = require 'nvim-web-devicons'

      local function path_itera(buf)
        local parts = vim.split(vim.api.nvim_buf_get_name(buf), '/', { trimempty = true })
        local index = #parts + 1

        return function()
          index = index - 1
          if index > 0 then
            return parts[index]
          end
        end
      end

      require('incline').setup {
        -- hide = {
        --   cursorline = 'focused_win',
        -- },
        render = function(props)
          -- local path_get = path_itera(props.buf)
          --
          -- local short_fname = path_get()
          -- if short_fname == '' then
          --   short_fname = '[No Name]'
          -- end
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
          if filename == '' then
            filename = '[No Name]'
          end

          local ft_icon, ft_color = devicons.get_icon_color(filename)

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

          -- local function get_harpoon_items()
          --   local harpoon = require 'harpoon'
          --   local marks = harpoon:list().items
          --   local current_file_path = vim.fn.expand '%:p:.'
          --   local label = {}
          --
          --   for id, item in ipairs(marks) do
          --     if item.value == current_file_path then
          --       table.insert(label, { id .. ' ', guifg = '#FFFFFF', gui = 'bold' })
          --     else
          --       table.insert(label, { id .. ' ', guifg = '#434852' })
          --     end
          --   end
          --
          --   if #label > 0 then
          --     table.insert(label, 1, { '󰛢 ', guifg = '#61AfEf' })
          --     table.insert(label, { '| ' })
          --   end
          --   return label
          -- end

          local function get_file_name()
            -- local filename = short_fname or ''
            --
            -- if filename:match 'index%.[jt]sx?$' ~= nil then
            --   for i = 1, 2 do
            --     local prev_path = path_get()
            --     if prev_path then
            --       filename = prev_path .. '/' .. filename
            --     else
            --       break
            --     end
            --   end
            -- end

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
              { get_file_name() },
              guibg = '#3a4449',
            },
            { '', guifg = '#314449' },
          }
        end,
      }
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      vim.cmd 'set cmdheight=0'

      local search_count = require 'lualine.components.searchcount' {}
      local selection_count = require 'lualine.components.selectioncount'
      local progress = require 'lualine.components.progress'

      local function custom_indicator()
        local mode = vim.fn.mode(true)
        local rec = vim.fn.reg_recording()

        if rec ~= '' then
          return 'Rec @ ' .. rec
        elseif vim.v.hlsearch > 0 then
          return search_count:update_status()
        elseif mode:match 'V' or mode:match 'v' then
          local line_start = vim.fn.line 'v'
          local line_end = vim.fn.line '.'
          local sel_count = selection_count()
          local suffix = ''

          if mode:match 'V' or line_start ~= line_end then
            suffix = ' lines'
          else
            suffix = ' chars'
          end

          return sel_count .. suffix
        end

        return progress()
      end

      local theme = require 'lualine.themes.monokai-pro'
      theme.normal.c = { fg = '#f2fffc', bg = '#273136' }
      theme.normal.x = { fg = '#f2fffc', bg = '#273136' }

      require('lualine').setup {
        options = {
          theme = theme,
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch' },
          lualine_c = {
            {
              'filename',
              file_status = true,
              newfile_status = false,
              path = 1,
              -- 0: Just the filename
              -- 1: Relative path
              -- 2: Absolute path
              -- 3: Absolute path, with tilde as the home directory
              -- 4: Filename and parent dir, with tilde as the home directory
              symbols = {
                modified = '[+]', -- Text to show when the file is modified.
                readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
                unnamed = '[No Name]', -- Text to show for unnamed buffers.
                newfile = '[New]', -- Text to show for newly created file before first write
              },
            },
          },
          lualine_x = {},
          lualine_y = { custom_indicator },
          lualine_z = { 'location' },
        },
        extensions = {
          'quickfix',
          'lazy',
          'mason',
          'neo-tree',
        },
      }
    end,
  },
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
  },
  {
    'folke/noice.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      cmdline = {
        enabled = true,
      },
      messages = {
        enabled = false,
      },
      popupmenu = {
        enabled = false,
      },
      -- commands = {},
      notify = {
        enabled = false,
      },
      lsp = {
        progress = {
          enabled = false,
        },
        hover = {
          enabled = false,
        },
        signature = {
          enabled = false,
        },
        message = {
          enabled = false,
        },
      },
      presets = {
        command_palette = true
      },
    },
    config = function(_, opts)
      require('noice').setup(opts)
      vim.api.nvim_set_keymap('n', '<leader>.', '<cmd>:NoiceDismiss<cr>', { noremap = true })
      vim.cmd 'set cmdheight=0'
    end,
  },
}
