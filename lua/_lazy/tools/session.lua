return {
  {
    'folke/persistence.nvim',
    event = 'BufReadPre',
    config = function()
      require('persistence').setup {
        dir = vim.fn.stdpath 'state' .. '/sessions/',
        branch = true,
      }

      vim.api.nvim_create_autocmd('User', {
        pattern = 'PersistenceSavePre',
        callback = function()
          ---@diagnostic disable-next-line: param-type-mismatch
          pcall(vim.cmd, ':Neotree close')
        end,
      })
    end,
  },
}
