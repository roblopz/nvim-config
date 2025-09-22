local M = {}

function M.set_lsp_mappings(event)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  local make_jump = function(dir, severity, open_code_actions)
    return function()
      local has_fn = dir == 'next' and vim.diagnostic.get_next or vim.diagnostic.get_prev

      if has_fn { severity = severity } ~= nil then
        local jump_fn = dir == 'next' and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
        jump_fn()

        if open_code_actions then
          vim.lsp.buf.code_action()
        end
      else
        vim.notify('No more diagnostics to move to', 'info', { title = 'LSP Diagnostics' })
      end
    end
  end

  map('gdd', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          vim.cmd('e ' .. item.filename)
          vim.api.nvim_win_set_cursor(0, { item.lnum, item.col })
        end
      end,
    }
  end, 'Goto Definition')

  map('gdv', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('open-window').open(item.filename, {
            mode = 'vsplit',
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - vertical split')

  map('gdx', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('open-window').open(item.filename, {
            mode = 'split',
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - horizontal split')

  map('gds', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('open-window').open(item.filename, {
            mode = 'pick',
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - window pick')

  map('gdp', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]

          local bufnr = vim.fn.bufnr(item.filename, true)
          if not vim.api.nvim_buf_is_loaded(bufnr) then
            vim.fn.bufload(bufnr)
          end

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

          vim.api.nvim_win_set_cursor(floating_win_id, { item.lnum, item.col })
          if not vim.wo.number then
            vim.cmd 'set number'
          end

          if not vim.wo.relativenumber then
            vim.cmd 'set relativenumber'
          end

          vim.cmd 'norm! zz'
        end
      end,
    }
  end, 'Goto Definition - floating window')

  map('gdr', function()
    Snacks.picker.lsp_references()
  end, 'Goto References')

  map('gdD', vim.lsp.buf.declaration, 'Goto Declaration')
  map('gdi', vim.lsp.buf.implementation, 'Goto Implementation')
  map('gdt', vim.lsp.buf.type_definition, 'Type Definition')
  map('<C-space>', vim.lsp.buf.hover, 'Hover Docs')

  -- Signature help
  map('<C-h>', vim.lsp.buf.signature_help, 'Signature Help')
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = event.buf })

  -- Code action (cmd+.)
  map('ã-Xc', vim.lsp.buf.code_action, 'Code Action')

  -- Rename (F2)
  map('ã-Xr', vim.lsp.buf.rename, 'Rename')

  -- Diagnostics
  vim.keymap.set('n', ']dd', make_jump 'next', { desc = 'Next [D]iagnostic' })
  vim.keymap.set('n', '[dd', make_jump 'prev', { desc = 'Prev [D]iagnostic' })
  vim.keymap.set('n', ']DD', make_jump('next', nil, true), { desc = 'Next [D]iagnostic + code action' })
  vim.keymap.set('n', '[DD', make_jump('prev', nil, true), { desc = 'Next [D]iagnostic + code action' })
  vim.keymap.set('n', ']de', make_jump('next', vim.diagnostic.severity.ERROR), { desc = 'Next [E]rror' })
  vim.keymap.set('n', '[de', make_jump('prev', vim.diagnostic.severity.ERROR), { desc = 'Next [E]rror' })
  vim.keymap.set('n', ']DE', make_jump('next', vim.diagnostic.severity.ERROR, true), { desc = 'Next [E]rror + code action' })
  vim.keymap.set('n', '[DE', make_jump('prev', vim.diagnostic.severity.ERROR, true), { desc = 'Next [E]rror + code action' })
end

return M
