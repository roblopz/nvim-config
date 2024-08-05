local function set_floating_win_mappings(bufnr, winid)
	local function minimize_floating_win()
		local o_width = vim.api.nvim_win_get_width(winid)
		local o_height = vim.api.nvim_win_get_height(winid)

		vim.api.nvim_win_set_width(winid, 40)
		vim.api.nvim_win_set_height(winid, 1)

		-- Return restore fn
		return function()
			vim.api.nvim_win_set_width(winid, o_width)
			vim.api.nvim_win_set_height(winid, o_height)
		end
	end

	local function set_map(keymap, open_win_opts)
		vim.keymap.set("n", keymap, function()
			local restore_win = minimize_floating_win()

			open_win_opts.cb = function(res)
				if res.opened then
					vim.api.nvim_set_current_win(winid)
					vim.cmd("close")
				else
					restore_win()
				end
			end

			open_win_opts.on_open_set_cursor = vim.api.nvim_win_get_cursor(winid)

			require("open-window").open(bufnr, open_win_opts)
		end, { buffer = bufnr })
	end

	set_map("<c-v>", { mode = "split" })
	set_map("<c-x>", { mode = "split", horizontal = true })
	set_map("<c-s>", { mode = "pick" })
end

local function clear_floating_win_mappings(bufnr)
	vim.keymap.del("n", "<c-v>", { buffer = bufnr })
	vim.keymap.del("n", "<c-x>", { buffer = bufnr })
	vim.keymap.del("n", "<c-s>", { buffer = bufnr })
end

local function on_preview_win_post_open(bufnr, winid)
	set_floating_win_mappings(bufnr, winid)

	vim.api.nvim_create_autocmd({ "WinClosed" }, {
		buffer = bufnr,
		once = true,
		callback = function(...)
			if not pcall(clear_floating_win_mappings, bufnr) then
				vim.notify("Error clearing floating window events", vim.log.levels.WARN)
			end
		end,
	})
end

return {
	{
		"goto-preview",
		dependencies = { "nvim-telescope/telescope.nvim" },
		config = function()
			local goto_preview = require("goto-preview")

			goto_preview.setup({
				width = 160,
				height = 40,
				opacity = nil,
				resizing_mappings = false,
				focus_on_open = true,
				dismiss_on_move = false,
				post_open_hook = on_preview_win_post_open
			})
		end,
	},
	{
		name = "lsp-goto",
		dev = true,
		dir = "<here>",
		dependencies = { "rmagatti/goto-preview", "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"gdg",
				"<Cmd>lua vim.lsp.buf.definition()<CR>",
				desc = "Go to definition",
			},
			{
				"gdp",
				"<Cmd>lua require('goto-preview').goto_preview_definition()<CR>",
				desc = "Preview definition",
			},
			{
				"gdx",
				"<Cmd>lua require'lsp-goto'.go_to_definition({ mode = 'split', horizontal = true })<CR>",
				desc = "Open definition - vsplit",
			},
			{
				"gdv",
				"<Cmd>lua require'lsp-goto'.go_to_definition({ mode = 'split' })<CR>",
				desc = "Open definition - hsplit",
			},
			{
				"gds",
				"<Cmd>lua require'lsp-goto'.go_to_definition({ mode = 'pick' })<CR>",
				desc = "Open definition - Pick window",
			},
			{
				"gdr",
				"<Cmd>Telescope lsp_references layout_strategy=horizontal<CR>",
				desc = "References - Preview",
			},
			{
				"gdq",
				"<Cmd>lua vim.lsp.buf.references()<CR>",
				desc = "References - Quickfix",
			},
		},
		config = function()
			require("lsp-goto").setup()
		end,
	},
}
