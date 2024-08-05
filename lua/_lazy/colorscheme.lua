local function set_highlights()
	local tabline_white = "#eeffff"
	local tabline_active = "#658594"
	local tabline_inactive = "#363646"

	-- Define your highlighting groups
	local tab_highlights = {
		TablineWinActive = { fg = tabline_white, bg = tabline_active },
		TablineWinInactive = { fg = tabline_white, bg = tabline_inactive },
		TablineTabActive = { fg = tabline_white, bg = tabline_active },
		TablineTabInactive = { fg = tabline_white, bg = tabline_inactive },
	}

	for group, p in pairs(tab_highlights) do
		vim.api.nvim_set_hl(0, group, { fg = p.fg, bg = p.bg })
	end

	local low_highlight = { fg = "#dcd7ba", bg = "#2d4f67" }
	local text_highlight = { fg = "#223249", bg = "#ffd13b" }
	local text_highlight_alt = { bg = "#484c24" }

	local other_highlights = {
		Visual = { bg = "#4b5263" },
		TelescopePreviewLine = low_highlight,
		Search = text_highlight,
		CurSearch = { fg = text_highlight.fg, bg = "#FFA066" },
		YankyPut = text_highlight_alt,
		YankyYanked = text_highlight_alt,
		SubstituteRange = text_highlight_alt,
		SubstituteExchange = text_highlight_alt,
		SubstituteSubstituted = text_highlight_alt,
	}

	for group, p in pairs(other_highlights) do
		vim.api.nvim_set_hl(0, group, { fg = p.fg, bg = p.bg })
	end
end

return {
	{
		{
			"rebelot/kanagawa.nvim",
			opts = {
				theme = "wave",
				undercurl = true, -- enable undercurls
				commentStyle = { italic = true },
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				transparent = true,
				dimInactive = false,
				terminalColors = true,
				colors = {
					theme = {
						all = {
							ui = {
								bg_gutter = "none",
							},
						},
					},
				},
				overrides = function(colors)
					local theme = colors.theme

					return {
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },
						-- Save an hlgroup with dark background and dimmed foreground
						-- so that you can use it where your still want darker windows.
						-- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
						NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
						-- Popular plugins that open floats will link to NormalFloat by default;
						-- set their background accordingly if you wish to keep them dark and borderless
						LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
						Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
						PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },
					}
				end,
			},

			config = function(_, opts)
				vim.api.nvim_create_autocmd("ColorScheme", {
					pattern = "kanagawa",
					callback = function()
						vim.fn.system("kitty +kitten themes Kanagawa")
					end,
				})

				require("kanagawa").setup(opts)
				vim.cmd("colorscheme kanagawa")
				set_highlights()
			end,
		},
	},
}
