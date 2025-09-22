local M = {}

M.setup = function()
  local function clone_window(open_opts)
    local bufnr = vim.api.nvim_get_current_buf()
    local win_id = vim.api.nvim_get_current_win()
    local is_floating = vim.api.nvim_win_get_config(win_id).relative ~= ''

    local o_width = vim.api.nvim_win_get_width(win_id)
    local o_height = vim.api.nvim_win_get_height(win_id)

    if is_floating then
      vim.api.nvim_win_set_width(win_id, 20)
      vim.api.nvim_win_set_height(win_id, 1)
    end

    require('open-window').open(
      bufnr,
      vim.tbl_deep_extend('force', open_opts, {
        cb = function(res)
          if is_floating then
            if res.opened then
              if not vim.wo.number then
                vim.cmd 'set number'
              end

              if not vim.wo.relativenumber then
                vim.cmd 'set relativenumber'
              end

              vim.api.nvim_win_close(win_id, false)
            else
              vim.api.nvim_win_set_width(win_id, o_width)
              vim.api.nvim_win_set_height(win_id, o_height)
            end
          end
        end,
      })
    )
  end

  vim.keymap.set('n', '<C-w>ov', function()
    clone_window { mode = 'vsplit' }
  end, { desc = 'Open this window - vsplit' })

  vim.keymap.set('n', '<C-w>ox', function()
    clone_window { mode = 'split' }
  end, { desc = 'Open this window - hsplit' })

  vim.keymap.set('n', '<C-w>os', function()
    clone_window { mode = 'pick' }
  end, { desc = 'Open this window - pick' })

  vim.keymap.set('n', '<C-w>op', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local buf_loc = vim.api.nvim_win_get_cursor(0)

    local editor_width = vim.o.columns
    local editor_height = vim.o.lines
    local win_width = math.max(math.floor(editor_width / 3), 160)
    local win_height = math.max(math.floor(editor_height / 3), 30)

    local floating_win_id = vim.api.nvim_open_win(bufnr, true, {
      relative = 'cursor',
      width = math.min(win_width, editor_width),
      height = math.min(win_height, win_height),
      row = 1,
      col = -1,
      style = 'minimal',
      border = 'rounded',
    })

    vim.api.nvim_win_set_cursor(floating_win_id, { buf_loc[1], buf_loc[2] })
    if not vim.wo.number then
      vim.cmd 'set number'
    end

    if not vim.wo.relativenumber then
      vim.cmd 'set relativenumber'
    end

    vim.cmd 'norm! zz'
  end, { desc = 'Open this window - preview' })
end

return M
