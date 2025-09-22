return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'
    local Path = require 'plenary.path'

    local function normalize_path(buf_name, root)
      return Path:new(buf_name):make_relative(root)
    end

    local function find_window_with_buffer(filename)
      for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)

          if buf_name == vim.fn.fnamemodify(filename, ':p') then
            return win
          end
        end
      end
      return nil
    end

    harpoon:setup {
      default = {
        display = function(list_item)
          local open_in_win = find_window_with_buffer(list_item.value)

          if open_in_win then
            return list_item.value .. ' '
          else
            return list_item.value
          end
        end,

        create_list_item = function(config, name)
          local bufnr = vim.api.nvim_get_current_buf()
          local bufname = vim.api.nvim_buf_get_name(bufnr)

          name = name or normalize_path(bufname, config.get_root_dir())

          local test_bufnr = vim.fn.bufnr(name, false)
          local pos = { 1, 0 }

          if test_bufnr ~= -1 then
            pos = vim.api.nvim_win_get_cursor(0)
          end

          return {
            value = name,
            context = {
              bufnr = test_bufnr ~= -1 and test_bufnr or bufnr,
              bufname = bufname,
              row = pos[1],
              col = pos[2],
            },
          }
        end,
      },
    }

    local function toggle_quick_menu()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end

    vim.keymap.set('n', '<leader>+', function()
      harpoon:list():add()
    end, { desc = 'Add file to harpoon' })

    vim.keymap.set('n', '<leader>-', function()
      harpoon:list():remove()
    end, { desc = 'Remove file from harpoon' })

    vim.keymap.set('n', '<leader>fH', function()
      toggle_quick_menu()
    end, { desc = 'Toggle harpoon menu' })

    harpoon:extend {
      UI_CREATE = function(cx)
        vim.cmd 'set cursorline'

        local function get_current_item()
          local idx = vim.fn.line '.'
          return harpoon.ui.active_list.items[idx]
        end

        local function harpoon_win_open(options)
          local idx = vim.fn.line '.'
          local item = get_current_item()
          local filename = item and item.value

          if not filename then
            vim.notify 'No item to open'
            return
          end

          toggle_quick_menu()

          local opts = vim.tbl_deep_extend('force', options, {
            cb = function(res)
              if not res.opened then
                toggle_quick_menu()
                vim.api.nvim_win_set_cursor(0, { idx, 0 })
              else
                local bufnr = vim.api.nvim_get_current_buf()
                local lines = vim.api.nvim_buf_line_count(bufnr)

                if item.context.row > lines then
                  item.context.row = lines
                end

                local row = item.context.row
                local row_text = vim.api.nvim_buf_get_lines(0, row - 1, row, false)
                local col = #row_text[1]

                if item.context.col > col then
                  item.context.col = col
                end

                vim.api.nvim_win_set_cursor(0, {
                  item.context.row or 1,
                  item.context.col or 0,
                })
              end
            end,
          })

          require('open-window').open(filename, opts)
        end

        vim.keymap.set('n', '<C-v>', function()
          harpoon_win_open { mode = 'vsplit' }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-x>', function()
          harpoon_win_open { mode = 'split' }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<C-s>', function()
          harpoon_win_open { mode = 'pick' }
        end, { buffer = cx.bufnr })

        vim.keymap.set('n', '<S-CR>', function()
          local item = get_current_item()
          local filename = item and item.value

          if not filename then
            vim.notify 'No item to open'
            return
          end

          local found_win = find_window_with_buffer(filename)
          if found_win then
            toggle_quick_menu()
            vim.api.nvim_set_current_win(found_win)
          else
            harpoon.ui:select_menu_item()
          end
        end, { buffer = cx.bufnr })
      end,
    }
  end,
}
