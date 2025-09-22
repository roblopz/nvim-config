return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      require 'lspconfig'
      local lsp_maps = require '_lazy.lsp.util.mappings'

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = lsp_maps.set_lsp_mappings,
      })

      vim.diagnostic.config {
        severity_sort = true,
        virtual_lines = false,
        virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },
        },
      }
    end,
  },
  { 'mason-org/mason.nvim', opts = {} },
  require '_lazy.lsp.mason-lspconfig',
  require '_lazy.lsp.formatting',
}
