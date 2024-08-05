local M = {}

local function make_lsp_handler(lsp_call)
	return function(open_win_opts)
		local function lsp_callback(_, lsp_result, _, _)
			if not lsp_result then
				return
			end

			local data = lsp_result[1] or lsp_result
			if vim.tbl_isempty(data) then
				print("The LSP returned no results. No preview to display.")
				return
			end

			local target = data.targetUri or data.uri
			local range = data.targetSelectionRange or data.targetRange or data.range
			local cursor_position = { range.start.line + 1, range.start.character }
			local buffer = type(target) == "string" and vim.uri_to_bufnr(target) or target

			require("open-window").open(
				buffer,
				vim.tbl_deep_extend("force", open_win_opts or {}, { on_open_set_cursor = cursor_position })
			)
		end

		local success, _ = pcall(vim.lsp.buf_request, 0, lsp_call, vim.lsp.util.make_position_params(), lsp_callback)

		if not success then
			print("goto-preview: Error calling LSP" + lsp_call + ". The current language lsp might not support it.")
		end
	end
end

function M.setup()
	M.go_to_definition = make_lsp_handler("textDocument/definition")
	M.go_to_type_definition = make_lsp_handler("textDocument/typeDefinition")
	M.go_to_implementation = make_lsp_handler("textDocument/implementation")
end

return M
