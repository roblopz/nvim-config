local function get_qflist()
  local qfs = require 'bqf.qfwin.session'
  if not qfs then
    return nil
  end

  local qs = qfs:get()
  if not qs then
    return nil
  end

  return qs:list(), qs, qfs
end

local function is_qf_preview_open(qwinid)
  local pvs = require 'bqf.preview.session'
  local ps = pvs:get(qwinid)
  return ps ~= nil and ps:validate()
end

local function qflist_win_open(opts, bqf_default)
  local open_win = require 'open-window'
  local pick_target_win_count = open_win.get_pick_target_win_count {
    pick_window_include_current = false,
  }

  if pick_target_win_count < 2 then
    bqf_default()
  else
    local qflist, qs = get_qflist()
    if not qflist or not qs then
      vim.notify("Couldn't get qflist!", vim.log.levels.WARN)
      return
    end

    local size = qflist:getQfList({ size = 0 }).size
    if size <= 0 then
      vim.notify('Empty qflist', vim.log.levels.WARN)
      return
    end

    local prev_winid = qs:previousWinid()
    ---@diagnostic disable-next-line: param-type-mismatch
    local is_prev_win_valid = type(prev_winid) == 'number' and prev_winid > 0 and vim.api.nvim_win_is_valid(prev_winid)

    if not is_prev_win_valid then
      vim.notify('file window is invalid', vim.log.levels.WARN)
      vim.cmd [[exe "norm! \<CR>"]]
      return
    end

    local qwinid = vim.api.nvim_get_current_win()
    local idx = vim.api.nvim_win_get_cursor(qwinid)[1]
    qflist:changeIdx(idx)

    local entry = qflist:item(idx)
    local bufnr, lnum, col = entry.bufnr, entry.lnum, entry.col
    if bufnr == 0 then
      vim.notify("Couldn't get item bufnr!", vim.log.levels.WARN)
      return
    end

    local preview_toggled = false
    if is_qf_preview_open(qwinid) then
      require('bqf.preview.handler').toggleWindow()
      preview_toggled = true
    end

    open_win.open(
      bufnr,
      vim.tbl_deep_extend('force', opts, {
        on_open_set_cursor = { lnum, col },
        cb = function(res)
          if not res.opened and preview_toggled then
            require('bqf.preview.handler').toggleWindow()
          end
        end,
      })
    )
  end
end

local function drop_quickfix_item(index)
  ---@diagnostic disable-next-line: unused-local
  local qflist, qs, qfs = get_qflist()

  if not qflist or not qfs then
    vim.notify("Couldn't get qflist!", vim.log.levels.WARN)
    return
  end

  local qfinfo = qflist:getQfList { size = 0, items = {} }
  if qfinfo.size <= 0 then
    vim.notify('Empty qflist', vim.log.levels.WARN)
    return
  end

  local items = qfinfo.items

  qfs:saveWinView(vim.api.nvim_get_current_win())
  table.remove(items, index)
  vim.fn.setqflist(items, 'r')

  local new_idx = #items >= index and index or #items

  if new_idx > 0 then
    vim.fn.setqflist({}, 'r', { idx = new_idx })
  end
end

local function is_quickfix_window(win_id)
  return vim.fn.getwininfo(win_id or vim.api.nvim_get_current_win())[1].quickfix == 1
end

return {
  'kevinhwang91/nvim-bqf',
  dependencies = {
    {
      'junegunn/fzf',
    },
  },
  config = function()
    require('bqf').setup {
      -- auto_resize_height = true,
      preview = {
        win_height = 40,
        winblend = 0
      },
      func_map = {
        open = '<CR>',
        ptoggleitem = 'p',
        ptoggleauto = 'P',
        pscrollup = '<C-b>',
        pscrolldown = '<C-f>',
        pscrollorig = '<C-o>',
        prevhist = '<',
        nexthist = '>',
        prevfile = '<C-p>',
        nextfile = '<C-n>',
        stoggledown = '<Tab>',
        stoggleup = '<S-Tab>',
        filter = '<C-q>',
        filterr = '<S-q>',
        ptogglemode = 'zp',
        openc = '', -- 'o',
        drop = '', --'O',
        split = '', --'<C-x>',
        vsplit = '', --'<C-v>',
        tab = '', --'t',
        tabb = '', --'T',
        tabc = '', --'<C-t>',
        tabdrop = '', --'',
        lastleave = '', -- [['"]],
        stogglevm = '', -- '<Tab>',
        stogglebuf = '', -- [['<Tab>]],
        sclear = '', -- 'z<Tab>',
        fzffilter = 'zf', -- 'zf',
      },
    }

    vim.keymap.set('n', ']q', '<Cmd>cnext<cr>', { desc = 'qflist next' })
    vim.keymap.set('n', '[q', '<Cmd>cprev<cr>', { desc = 'qflist prev' })
    vim.keymap.set('n', '<leader>qf', '<Cmd>copen<cr>', { desc = 'qflist focus' })
    vim.keymap.set('n', '<leader>qc', '<Cmd>cclose<cr>', { desc = 'qflist close' })

    vim.keymap.set('n', '<leader>qq', function()
      vim.cmd 'copen'
      require('bqf.qfwin.handler').open()
    end, { desc = 'qflist open first' })

    -- Function to sort quickfix items by filename
    local function sortQuickfixByFilename(ascending)
      -- Get the current quickfix list
      local quickfix_list = vim.fn.getqflist()

      -- Helper function to retrieve filename from bufnr
      local function get_filename(item)
        if item.bufnr and item.bufnr > 0 then
          return vim.fn.bufname(item.bufnr)
        else
          return '' -- Sort nil or empty filenames last
        end
      end

      -- Sort the quickfix list by filename
      table.sort(quickfix_list, function(a, b)
        if ascending then
          return get_filename(a) < get_filename(b)
        else
          return get_filename(a) > get_filename(b)
        end
      end)

      -- Set the sorted quickfix list back
      vim.fn.setqflist({}, 'r', { items = quickfix_list })
      print 'Quickfix list sorted by filename.'
    end

    vim.keymap.set('n', '<leader>qs', function()
      sortQuickfixByFilename(false)
    end, { desc = 'qflist sort by filename (descending)' })

    vim.keymap.set('n', '<leader>qS', function()
      sortQuickfixByFilename(true)
    end, { desc = 'qflist sort by filename (ascending)' })

    local previous_win = nil

    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
      callback = function()
        vim.defer_fn(function()
          local win_id = vim.api.nvim_get_current_win()
          local is_quickfix = is_quickfix_window(win_id)
          local is_floating = vim.api.nvim_win_get_config(win_id).relative ~= ''

          if not is_quickfix and not is_floating then
            previous_win = win_id
          end
        end, 100)
      end,
    })

    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter' }, {
      callback = function()
        if is_quickfix_window() then
          vim.api.nvim_buf_set_keymap(0, 'n', '<C-v>', '', {
            desc = 'Pick vertical split',
            noremap = true,
            silent = true,
            callback = function()
              qflist_win_open({
                mode = 'vsplit',
              }, function()
                require('bqf.qfwin.handler').open(false, 'vsplit')
              end)
            end,
          })

          vim.api.nvim_buf_set_keymap(0, 'n', '<C-x>', '', {
            desc = 'Pick horizontal split',
            noremap = true,
            silent = true,
            callback = function()
              qflist_win_open({
                mode = 'split',
              }, function()
                require('bqf.qfwin.handler').open(false, 'split')
              end)
            end,
          })

          vim.api.nvim_buf_set_keymap(0, 'n', '<C-s>', '', {
            desc = 'Open in pick window',
            noremap = true,
            silent = true,
            callback = function()
              qflist_win_open({ mode = 'pick' }, function()
                require('bqf.qfwin.handler').open(false)
              end)
            end,
          })

          vim.api.nvim_buf_set_keymap(0, 'n', 'dd', '', {
            desc = 'Delete history entry',
            noremap = true,
            silent = true,
            callback = function()
              local qwinid = vim.api.nvim_get_current_win()
              local idx = vim.api.nvim_win_get_cursor(qwinid)[1]
              drop_quickfix_item(idx)
            end,
          })

          vim.api.nvim_buf_set_keymap(0, 'n', '<Bs>', '', {
            desc = 'Go back to code window',
            noremap = true,
            silent = true,
            callback = function()
              if previous_win and vim.api.nvim_win_is_valid(previous_win) then
                vim.api.nvim_set_current_win(previous_win)
              else
                vim.cmd 'wincmd k'
              end
            end,
          })
        end
      end,
    })
  end,
}
