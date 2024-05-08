local M = {}

local util = require("util")

local function make_win_map(win_mode, builtin)
	return function(prompt_bufnr)
		local open_win = require("open-window")
		local state = require("telescope.actions.state")
		local entry = state.get_selected_entry()

		if not entry then
			util.warn("No telescope entry info")
			return
		end

		local bufnr_or_fname = entry.bufnr or entry.path or entry.filename
		local prompt_input = state.get_current_line()

		if not bufnr_or_fname then
			util.warn("No telescope bufnr/filename info")
			return
		end

		local open_win_opts = {
			mode = "pick",
			cb = function(res)
				if not res.opened then
					if type(builtin) == "string" then
						require("telescope.builtin")[builtin]({ default_text = prompt_input })
					elseif builtin then
						builtin({ default_text = prompt_input })
					end
				end
			end,
			on_open_set_cursor = { entry.lnum, entry.col },
		}

		if win_mode == "vsplit" then
			open_win_opts.mode = "split"
			open_win_opts.horizontal = false
		elseif win_mode == "hsplit" then
			open_win_opts.mode = "split"
			open_win_opts.horizontal = true
		end

		require("telescope.actions").close(prompt_bufnr)
		open_win.open(bufnr_or_fname, open_win_opts)
	end
end

M.get_mappings = function(builtin)
	return {
		["<C-s>"] = make_win_map("pick", builtin),
		["<C-v>"] = make_win_map("vsplit", builtin),
		["<C-x>"] = make_win_map("hsplit", builtin),
		["<C-q>"] = function(prompt_bufnr)
			local actions = require("telescope.actions")
			vim.cmd("cexpr []")
			actions.add_selected_to_qflist(prompt_bufnr)
			vim.cmd("copen")
		end,
		["<C-p>"] = function(bufnr)
			require("telescope.actions.layout").toggle_preview(bufnr)
		end,
	}
end

return M
