return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      'ã-Xf', -- M+S+f
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
    {
      'ã-Xe', -- M+S+e
      function()
        -- Try eslint first
        local lsp_clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
        local lsp_client_names = {}

        for _, client in ipairs(lsp_clients) do
          lsp_client_names[#lsp_client_names + 1] = client.name
        end

        if vim.tbl_contains(lsp_client_names, 'eslint') then
          ---@diagnostic disable-next-line: param-type-mismatch
          local ok = pcall(vim.cmd, 'silent LspEslintFixAll')
          if not ok then
            vim.cmd 'w'
            vim.cmd 'e'
            vim.defer_fn(function()
              vim.cmd 'silent LspEslintFixAll'
            end, 250)
          end
        else
          require('conform').format { async = true, lsp_fallback = true }
        end
      end,
      mode = '',
      desc = '[E]slint / Format',
    },
  },
  opts = {
    notify_on_error = true,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettierd', 'prettier', stop_after_first = true },
      typescript = { 'prettierd', 'prettier', stop_after_first = true },
      graphql = { 'prettierd', 'prettier', stop_after_first = true },
      typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    },
  },
}
