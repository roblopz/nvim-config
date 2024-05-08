return {
	-- Actual colorscheme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
			})
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

			local lualine_winbar = require("lualine-winbar")
			lualine_winbar.setup()

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
					lualine_a = {
						"mode",
						{
							require("noice").api.statusline.mode.get,
							cond = require("noice").api.statusline.mode.has,
							color = { fg = "#353535", gui = "bold" },
						},
					},
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
							lualine_winbar.win_bar_fname(2),
							cond = function()
								return vim.bo.filetype ~= "neo-tree"
							end,
						},
					},
					lualine_y = { "diagnostics" },
				},
				inactive_winbar = {
					lualine_c = {
						{
							lualine_winbar.win_bar_fname(2),
							cond = function()
								return vim.bo.filetype ~= "neo-tree"
							end,
						},
					},
					lualine_x = { "diagnostics" },
				},
			}
		end,
		config = true,
	},
}
