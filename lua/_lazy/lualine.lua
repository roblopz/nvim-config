return {
	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function()
			local lualine_winbar = require("lualine-winbar")
			lualine_winbar.setup()

      local theme = require'lualine.themes.material'
      theme.inactive.c.bg = "#1f1f28"
      theme.normal.c.bg = "#1f1f28"

			return {
				options = {
					theme = theme,
					globalstatus = true,
					disabled_filetypes = {
						statusline = { "dashboard", "alpha" },
						winbar = { "dashboard", "alpha" },
					},
				},
				extensions = { "neo-tree", "quickfix", "nvim-dap-ui" },
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = { { "filename", path = 3 } },
					lualine_x = { "filetype" },
					lualine_y = { "progress" },
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
					lualine_x = { "diagnostics" },
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
