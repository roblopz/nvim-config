return {
	{ "stevearc/dressing.nvim" },
	{ "brenoprata10/nvim-highlight-colors" },
	{ "rcarriga/nvim-notify" },
	{ "kevinhwang91/nvim-bqf", opts = { preview = { auto_preview = false } } },
	{
		"echasnovski/mini.animate",
		opts = function()
			local animate = require("mini.animate")

			return {
				cursor = {
					enable = true,
					timing = animate.gen_timing.linear({ duration = 200, unit = "total" }),
				},
				scroll = {
					enable = false,
				},
				resize = {
					enable = true,
					timing = animate.gen_timing.linear({ duration = 140, unit = "total" }),
				},
				open = {
					enable = false,
				},
				close = {
					enable = false,
				},
			}
		end,
	},
	{
		"karb94/neoscroll.nvim",
		opts = {
			performance_mode = false,
			hide_cursor = false, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = true, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
		},
	},
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "MaximilianLloyd/ascii.nvim", "MunifTanjim/nui.nvim" },
		opts = function()
			local dashboard = require("alpha.themes.dashboard")

			dashboard.section.header.val = require("ascii").art.text.neovim.sharp

			vim.api.nvim_create_user_command("StartPageTelescopeOldFiles", function()
				require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() })
			end, { desc = "Old files (in workspace)" })

			dashboard.section.buttons.val = {
				dashboard.button("o", " " .. " Recent files", ":StartPageTelescopeOldFiles <CR>"),
				dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
				dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
				dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
				dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
				dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
				dashboard.button("q", " " .. " Quit", ":qa<CR>"),
			}

			for _, button in ipairs(dashboard.section.buttons.val) do
				button.opts.hl = "AlphaButtons"
				button.opts.hl_shortcut = "AlphaShortcut"
			end

			dashboard.section.header.opts.hl = "AlphaHeader"
			dashboard.section.buttons.opts.hl = "AlphaButtons"
			dashboard.section.footer.opts.hl = "AlphaFooter"
			dashboard.opts.layout[1].val = 8
			return dashboard
		end,
		config = function(_, dashboard)
			-- close Lazy and re-open when the dashboard is ready
			if vim.o.filetype == "lazy" then
				vim.cmd.close()
				vim.api.nvim_create_autocmd("User", {
					pattern = "AlphaReady",
					callback = function()
						require("lazy").show()
					end,
				})
			end

			require("alpha").setup(dashboard.opts)

			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyVimStarted",
				callback = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					dashboard.section.footer.val = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
					pcall(vim.cmd.AlphaRedraw)
				end,
			})
		end,
	},
	-- Workspace search
	{ "nvim-pack/nvim-spectre" },
	-- GIt diff view
	{ "sindrets/diffview.nvim" },
	-- Search & jump enhancements
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				search = {
					enabled = false,
				},
				char = {
					highlight = { backdrop = false },
				},
			},
		},
		keys = {
      -- stylua: ignore start
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
    { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter select" },
    { "<c-s>", mode = { "n" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
			-- stylua: ignore end
		},
	},
	{
		"folke/noice.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
				hover = { enabled = false },
				signature = { enabled = false },
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		},
		keys = {
			{
				"<C-n>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>.",
				"<cmd>Noice dismiss<cr>",
				desc = "Dismiss messages",
			},
		},
		config = function(_, opts)
			require("noice").setup(opts)
			require("telescope").load_extension("noice")
		end,
	},
}
