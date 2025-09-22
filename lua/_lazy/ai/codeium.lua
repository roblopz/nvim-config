return {
  'Exafunction/codeium.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp',
  },
  config = function()
    _G.was_setup = true

    require('codeium').setup {
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 75,
        map_keys = true,
        key_bindings = {
          accept = '<C-a>',
          prev = '<C-{>',
          accept_word = '<C-w>',
          accept_line = '<S-C-w>',
          next = '<C-}>',
          clear = false,
        },
      },
    }

    vim.keymap.set('i', '<C-c>', function()
      local codeium = require 'codeium.virtual_text'
      local state = codeium.status().state

      if state == 'waiting' then
        return
      end

      if state == 'completions' then
        codeium.clear()
      else
        codeium.cycle_or_complete()
      end
    end, { desc = 'Toggle codeium' })

    vim.keymap.set('i', '<C-}>', require('codeium.virtual_text').cycle_or_complete, { desc = 'Codeium next completions' })
  end,
}
