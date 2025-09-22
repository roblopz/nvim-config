---@diagnostic disable: missing-fields

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function()
    vim.api.nvim_set_hl(0, 'SnacksIndent', { fg = '#545F62' })
    vim.api.nvim_set_hl(0, 'SnacksIndentScope', { fg = '#fc9867' })

    local snacks_picker = require '_lazy.navigation.snacks-picker'
    local snacks_notifier = require '_lazy.ui.snacks.snacks-notifier'
    local snacks_indent = require '_lazy.ui.snacks.snacks-indent'
    local snacks_input = require '_lazy.ui.snacks.snacks-input'

    require('snacks').setup {
      picker = snacks_picker.options,
      notifier = snacks_notifier.options,
      indent = snacks_indent.options,
      input = { enabled = true },
      terminal = { enabled = true },
      scroll = { enabled = true },
      words = { enabled = true },
      scratch = { enabled = true },
      dashboard = { enabled = true },

      styles = {
        terminal = {
          keys = {
            q = '',
            term_normal = {
              '<esc>',
              function(self)
                self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
                if self.esc_timer:is_active() then
                  self.esc_timer:stop()
                  vim.cmd 'stopinsert'
                else
                  self.esc_timer:start(200, 0, function() end)
                  return '<esc>'
                end
              end,
              mode = 't',
              expr = true,
              desc = 'Double escape to normal mode',
            },
            hide_term = {
              '<C-w>c',
              function(self)
                self:hide()
              end,
              mode = 't',
              desc = 'Hide terminal',
            },
          },
        },
        input = snacks_input.styles,
      },
    }

    _G.dd = Snacks.debug.inspect

    snacks_notifier.setup()
    snacks_picker.setup()

    vim.keymap.set('n', '<leader>sl', function()
      Snacks.scratch.open { ft = 'lua' }
    end, { desc = 'TEST - REMOVE 1' })

    vim.keymap.set('n', ']]', function()
      Snacks.words.jump(vim.v.count1)
    end, { desc = 'Next word (reference)' })

    vim.keymap.set('n', '[[', function()
      Snacks.words.jump(-vim.v.count1)
    end, { desc = 'Prev word (reference)' })
  end,
}
