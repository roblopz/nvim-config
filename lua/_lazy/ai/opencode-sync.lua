return {
  'opencode-sync',
  name = 'opencode-sync',
  dir = vim.fn.stdpath 'config' .. '/lua/opencode-sync',
  dev = true,
  dependencies = {
    {
      'jonstoler/lua-toml',
      init = function()
        local plug = vim.fn.stdpath 'data' .. '/lazy/lua-toml'
        package.path = plug .. '/?.lua;' .. package.path
      end,
    },
  },
  config = function()
    require('opencode-sync').setup()

    vim.keymap.set('n', '<leader>aim', function()
      require('opencode-sync').switch_agent_mode()
    end, { desc = 'Switch agent mode' })

    vim.keymap.set('n', '<leader>ai}', function()
      require('opencode-sync').cycle_model(false)
    end, { desc = 'Next model' })

    vim.keymap.set('n', '<leader>ai{', function()
      require('opencode-sync').cycle_model(true)
    end, { desc = 'Previous model' })
  end,
}
