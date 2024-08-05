return {
	-- Run formatters on demand (:Format, :FormatWrite)
	{
		"mhartington/formatter.nvim",
		opts = function()
			return {
				filetype = {
					javascript = {
						require("formatter.filetypes.json").prettier,
					},
					javascriptreact = {
						require("formatter.filetypes.json").prettier,
					},
					typescript = {
						require("formatter.filetypes.json").prettier,
					},
					typescriptreact = {
						require("formatter.filetypes.json").prettier,
					},
					json = {
						require("formatter.filetypes.json").prettier,
					},
					jsonc = {
						require("formatter.filetypes.json").prettier,
					},
					lua = {
						require("formatter.filetypes.lua").stylua,
					},
					graphql = {
						require("formatter.filetypes.graphql").prettier,
					},
				},
			}
		end,
	},
	{
		name = "lsp-diagnostics",
		dev = true,
		dir = "<here>",
		config = function()
			local function make_jump(dir, severity, open_code_actions)
				return function()
					local has_fn = dir == "next" and vim.diagnostic.get_next or vim.diagnostic.get_prev

					if has_fn({ severity = severity }) ~= nil then
						local jump_fn = dir == "next" and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
						jump_fn()

						if open_code_actions then
							vim.lsp.buf.code_action()
						end
					else
						vim.notify("No more diagnostics to move to")
					end
				end
			end

			vim.keymap.set("n", "]d", make_jump("next"))
			vim.keymap.set("n", "[d", make_jump("prev"))
			vim.keymap.set("n", "]D", make_jump("next", nil, true))
			vim.keymap.set("n", "[D", make_jump("prev", nil, true))

			vim.keymap.set("n", "]e", make_jump("next", vim.diagnostic.severity.ERROR))
			vim.keymap.set("n", "[e", make_jump("prev", vim.diagnostic.severity.ERROR))
			vim.keymap.set("n", "]E", make_jump("next", vim.diagnostic.severity.ERROR, true))
			vim.keymap.set("n", "[E", make_jump("prev", vim.diagnostic.severity.ERROR, true))
		end,
	},
}
