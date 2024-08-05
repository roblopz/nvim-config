return {
	{
		"nanozuki/tabby.nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local util = require("custom-util")
			local filename = require("tabby.module.filename")
			local tabbyApi = require("tabby.module.api")

			local theme = {
				fill = "TabLineFill",
				tab_active = "TablineTabActive",
				tab_inactive = "TablineTabInactive",
				win_active = "TablineWinActive",
				win_inactive = "TablineWinInactive",
			}

			local function filterTabWins(win)
				return not util.string.startsWith(win.buf_name(), "neo-tree filesystem")
			end

			vim.cmd("set showtabline=2")

			require("tabby.tabline").set(function(line)
				return {
					line.tabs().foreach(function(tab)
						local hl = tab.is_current() and theme.tab_active or theme.tab_inactive
						return {
							line.sep("", hl, theme.fill),
							tab.number(),
							tab.name(),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					line.spacer(),
					line.wins_in_tab(line.api.get_current_tab(), filterTabWins).foreach(function(win)
						local hl = win.is_current() and theme.win_active or theme.win_inactive
						return {
							line.sep("", hl, theme.fill),
							win.buf_name(),
							line.sep("", hl, theme.fill),
							hl = hl,
							margin = " ",
						}
					end),
					hl = theme.fill,
				}
			end, {
				tab_name = {
					name_fallback = function(tabid)
						local function is_not_excluded_win(winid)
							return tabbyApi.is_not_float_win(winid)
								and not util.buf_excluded(vim.api.nvim_win_get_buf(winid), { "neo-tree" })
						end

						local current_win = vim.api.nvim_tabpage_get_win(tabid)
						local all_wins = vim.api.nvim_tabpage_list_wins(tabid)
						local filtered_wins = vim.tbl_filter(is_not_excluded_win, all_wins)

						local suffix = #filtered_wins - 1 >= 1 and (" [+" .. tostring(#filtered_wins - 1) .. "]") or ""
						return filename.unique(current_win) .. suffix
					end,
				},
				buf_name = {
					mode = "unique",
				},
			})

			vim.api.nvim_create_autocmd({ "WinEnter" }, {
				callback = function()
					require("tabby").tab_rename("Main")
					return true
				end,
			})

			vim.api.nvim_create_user_command("TabNew", function()
				vim.ui.input({ prompt = "New tab name:" }, function(name)
					if name then
						vim.cmd("tabnew")
						require("tabby").tab_rename(name)
					end
				end)
			end, { desc = "New named tab" })

			vim.api.nvim_set_keymap("n", "<leader>tn", ":TabNew<CR>", { noremap = true })
			vim.api.nvim_set_keymap("n", "<leader>tc", ":tabclose<CR>", { noremap = true })
		end,
	},
}
