local M = {}

M.res = {}

M.format = function()
  vim.lsp.buf.format({
    filter = function(client)
      M.res[client.name] = true

      -- apply whatever logic you want (in this example, we'll only use null-ls)
      return client.name == "null-ls"
    end,
  })
end

return M
