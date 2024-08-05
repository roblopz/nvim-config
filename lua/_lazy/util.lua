return {
	{
		"s1n7ax/nvim-window-picker",
		name = "window-picker",
		event = "VeryLazy",
		version = "2.*",
		opts = {
			selection_chars = "ABCDEFGHIJKLMNOPQRSTUVXYZ",
			filter_rules = {
				bo = {
					filetype = {
						"NvimTree",
						"neo-tree",
						"notify",
						"TelescopePrompt",
						"qf",
						"dap-repl",
						"quickfix",
					},
				},
			},
			highlights = {
				show_prompt = false,
				statusline = {
					focused = {
						fg = "#ededed",
						bg = "#44cc41",
						bold = true,
					},
					unfocused = {
						fg = "#ededed",
						bg = "#44cc41",
						bold = true,
					},
				},
				winbar = {
					focused = {
						fg = "#ededed",
						bg = "#44cc41",
						bold = true,
					},
					unfocused = {
						fg = "#ededed",
						bg = "#44cc41",
						bold = true,
					},
				},
			},
		},
		config = function(_, opts)
			require("window-picker").setup(opts)
		end,
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = true,
	},
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup(nil, {
				names = false,
				css_fn = true,
			})
		end,
	},
	{
		"pocco81/high-str.nvim",
		config = function()
			local highlight_colors = {
				color_0 = { "#ADFF2F", "smart" }, -- Cosmic charcoal
				color_1 = { "#e5c07b", "smart" }, -- Pastel yellow
				color_2 = { "#7FFFD4", "smart" }, -- Aqua menthe
				color_3 = { "#8A2BE2", "smart" }, -- Proton purple
				color_4 = { "#FF4500", "smart" }, -- Orange red
				color_5 = { "#008000", "smart" }, -- Office green
				color_6 = { "#0000FF", "smart" }, -- Just blue
				color_7 = { "#FFC0CB", "smart" }, -- Blush pink
				color_8 = { "#FFF9E3", "smart" }, -- Cosmic latte
				color_9 = { "#7d5c34", "smart" }, -- Fallow brown
			}

			require("high-str").setup({
				verbosity = 0,
				saving_path = "/tmp/highstr/",
				highlight_colors = highlight_colors,
			})

			local idx = 0
			for _ in pairs(highlight_colors) do
				_G.one = "gh" .. idx
				_G.two = string.format(":<C-u>HSHighlight %s<CR>", idx)

				vim.api.nvim_set_keymap("v", "gh" .. idx, string.format(":<C-u>HSHighlight %s<CR>", idx), {
					noremap = true,
					silent = true,
				})

				idx = idx + 1
			end

			vim.api.nvim_set_keymap("v", "ghh", ":<C-u>HSHighlight 0<CR>", {
				noremap = true,
				silent = true,
			})

			vim.api.nvim_set_keymap("v", "gH", ":<C-u>HSRmHighlight<CR>", {
				noremap = true,
				silent = true,
			})
		end,
	},
}
