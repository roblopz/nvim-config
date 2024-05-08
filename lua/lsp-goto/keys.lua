local M = {}

local function get_lsp_conf(data)
  local uri = data.targetUri or data.uri
  local range = data.targetSelectionRange or data.targetRange or data.range

  return uri, { range.start.line + 1, range.start.character }
end

local handle = function(result, open_win_opts)
  if not result then
    return
  end

  local data = result[1] or result
  local target = nil
  local cursor_position = {}

  if vim.tbl_isempty(data) then
    print "The LSP returned no results. No preview to display."
    return
  end

  target, cursor_position = get_lsp_conf(data)
  local buffer = type(target) == "string" and vim.uri_to_bufnr(target) or target

  require 'open-window'.open(
    buffer,
    vim.tbl_deep_extend('force', open_win_opts or {}, { on_open_set_cursor = cursor_position })
  )
end

local handler = function(_, open_win_options)
  return function(_, result, _, _)
    handle(result, open_win_options)
  end
end

local legacy_handler = function(_, open_win_opts)
  return function(_, _, result)
    handle(result, open_win_opts)
  end
end

local get_handler = function(lsp_call, open_win_opts)
  -- Only really need to check one of the handlers
  if debug.getinfo(vim.lsp.handlers["textDocument/definition"]).nparams == 4 then
    return handler(lsp_call, open_win_opts)
  else
    return legacy_handler(lsp_call, open_win_opts)
  end
end

local function makeHandler(lsp_call)
  return function(open_win_opts)
    local params = vim.lsp.util.make_position_params()
    local success, _ = pcall(
      vim.lsp.buf_request,
      0,
      lsp_call,
      params,
      get_handler(lsp_call, open_win_opts)
    )

    if not success then
      print("goto-preview: Error calling LSP" + lsp_call + ". The current language lsp might not support it.")
    end
  end
end

M.go_to_definition = makeHandler("textDocument/definition")
M.go_to_type_definition = makeHandler("textDocument/typeDefinition")
M.go_to_implementation = makeHandler("textDocument/implementation")

return M
