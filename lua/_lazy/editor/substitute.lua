return {
  'gbprod/substitute.nvim',
  dependencies = { 'gbprod/yanky.nvim' },
  opts = function()
    return {
      on_substitute = require('yanky.integration').substitute(),
      highlight_substituted_text = {
        enabled = true,
        timer = 400,
      },
      range = {
        prefix = 's',
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        motion1 = false,
        motion2 = false,
        suffix = '',
      },
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
      },
    }
  end,
  config = function(_, opts)
    require('substitute').setup(opts)
    vim.keymap.set('n', 's', require('substitute').operator, { noremap = true })
    vim.keymap.set('n', 'ss', require('substitute').line, { noremap = true })
    vim.keymap.set('n', 'S', require('substitute').eol, { noremap = true })
    vim.keymap.set('x', 's', require('substitute').visual, { noremap = true })

    _G.prepend_star_register = function()
      -- Return the string to set the '*' register for the next command
      return '"*'
    end

    _G.prepend_del_register = function()
      -- Return the string to set the '_' register for the next command
      return '"_'
    end

    -- Map <Tab> in normal mode and visual mode to prepend the '*' register
    vim.api.nvim_set_keymap('n', '<Tab>', 'v:lua.prepend_star_register()', { noremap = true, expr = true, silent = true })
    vim.api.nvim_set_keymap('v', '<Tab>', 'v:lua.prepend_star_register()', { noremap = true, expr = true, silent = true })
    vim.api.nvim_set_keymap('n', '-', 'v:lua.prepend_del_register()', { noremap = true, expr = true, silent = true })
    vim.api.nvim_set_keymap('v', '-', 'v:lua.prepend_del_register()', { noremap = true, expr = true, silent = true })

    local function copy_to_clipboard(value)
      vim.fn.setreg('+', value)
      vim.notify('Copied: ' .. value)
    end

    vim.keymap.set('n', '<leader>yf', function()
      copy_to_clipboard(vim.fn.fnamemodify(vim.fn.expand '%', ':.'))
    end, { desc = 'Yank full file path' })

    vim.keymap.set('n', '<leader>yF', function()
      copy_to_clipboard(vim.fn.expand '%:p')
    end, { desc = 'Yank full file path' })

    vim.keymap.set('n', '<leader>yab', function()
      copy_to_clipboard(require('opencode.context').buffer())
    end, { desc = 'Yank buffer context' })

    vim.keymap.set('n', '<leader>yaB', function()
      copy_to_clipboard(require('opencode.context').buffers())
    end, { desc = 'Yank all buffer context' })

    vim.keymap.set('n', '<leader>yac', function()
      copy_to_clipboard(require('opencode.context').cursor_position())
    end, { desc = 'Yank cursor position context' })

    vim.keymap.set('v', '<leader>ya', function()
      copy_to_clipboard(require('opencode.context').visual_selection())
    end, { desc = 'Yank selection context' })

    vim.keymap.set('n', '<leader>yat', function()
      copy_to_clipboard(require('opencode.context').visible_text())
    end, { desc = 'Yank visible text context' })

    vim.keymap.set('n', '<leader>yad', function()
      copy_to_clipboard(require('opencode.context').diagnostics(true))
    end, { desc = 'Yank line diagnostics context' })

    vim.keymap.set('n', '<leader>yaD', function()
      copy_to_clipboard(require('opencode.context').diagnostics())
    end, { desc = 'Yank all diagnostics context' })

    vim.keymap.set('n', '<leader>yaq', function()
      copy_to_clipboard(require('opencode.context').quickfix())
    end, { desc = 'Yank quickfix context' })
  end,
}
