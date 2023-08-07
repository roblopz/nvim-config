local M = {}

local util = require("util")

M.jump = function(opts)
	opts = vim.tbl_deep_extend("force", {
		dir = "next",
		trigger_action = false,
		float = {
			scope = "l",
			source = true,
		},
	}, opts or {})

	local has_diagnostic = vim.diagnostic.get_next() ~= nil

	if has_diagnostic then
		local do_jump = util.coalesce(opts.dir == "next", vim.diagnostic.goto_next, vim.diagnostic.goto_prev)
		local float_opts = util.coalesce(opts.trigger_action, false, opts.float)

		do_jump({ severity = opts.severity, float = float_opts })

		if opts.trigger_action then
			vim.lsp.buf.code_action()
		end
	end
end

return M
