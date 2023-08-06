local M = {}

function M.coalesce(bool, if_true, if_false)
  if bool then
    return if_true
  else
    return if_false
  end
end

function M.tbl_first(tbl, fn)
  for _, e in pairs(tbl) do
    if fn(e) then
      return e
    end
  end

  return nil
end

function M.cwd()
  local has_lsp_util, lsp_util = pcall(require, "lspconfig.util")
  local cwd = vim.fn.getcwd()

  if has_lsp_util then
    return lsp_util.find_git_ancestor(cwd) or lsp_util.find_package_json_ancestor(cwd)
  else
    return cwd
  end
end

function M.warn(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'warn')
end

function M.info(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'info')
end

function M.error(msg, inspect)
  require('notify')(M.coalesce(inspect, vim.inspect(msg), msg), 'error')
end

return M
