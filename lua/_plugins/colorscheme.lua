return {
	-- Actual colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			vim.cmd("colorscheme catppuccin-mocha")
		end,
	},
	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function()
			-- Hide tabline
			vim.cmd("set showtabline=0")

			local lualine_util = require("util.lualine")
			lualine_util.setup()

			return {
				options = {
					theme = "auto",
					globalstatus = true,
					-- disabled_filetypes = {
					-- 	statusline = { "dashboard", "alpha" },
					-- 	winbar = { "dashboard", "alpha" },
					-- },
				},
				extensions = { "neo-tree", "quickfix", "nvim-dap-ui" },
				tabline = {},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = { { "filename", path = 3 } },
					lualine_x = { "filetype" },
					lualine_y = {
						{
							"tabs",
							mode = 1,
						},
						{
							"progress",
							cond = function()
								return #vim.api.nvim_list_tabpages() < 2
							end,
						},
					},
					lualine_z = { "location" },
				},
				winbar = {
					lualine_c = {
						{
              lualine_util.win_bar_fname(2),
              cond = function ()
                return vim.bo.filetype ~= 'neo-tree'
              end
            },
					},
					lualine_y = { "diagnostics" },
				},
				inactive_winbar = {
					lualine_c = {
						{
							lualine_util.win_bar_fname(),
              cond = function ()
                return vim.bo.filetype ~= 'neo-tree'
              end
						},
					},
					lualine_x = { "diagnostics" },
				},
			}
		end,
		config = true,
	},
}
