return {
	{ "stevearc/dressing.nvim" },
	{
		"rcarriga/nvim-notify",
		opts = {
			background_colour = "#000000",
		},
	},
	{
		"kevinhwang91/nvim-bqf",
		opts = {
			preview = { auto_preview = false },
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
	-- Search & jump enhancements
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
      label = {
        style = "overlay",
        rainbow = {
          enabled = true,
          shade = 5
        }
      },
			modes = {
				search = {
					enabled = false,
					highlight = { backdrop = true },
				},
				char = {
          enabled = false,
				},
			},
		},
		keys = {
      -- stylua: ignore start
      { "<leader>jj", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "<leader>jv", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Treesitter select" },
      { "<leader>js", mode = { "n" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			-- stylua: ignore end
		},
	},
	-- Noice ui
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		opts = {
			lsp = {
				progress = {
					enabled = false,
				},
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				command_palette = true, -- position the cmdline and popupmenu together
				lsp_doc_border = true, -- add a border to hover docs and signature help
			},
			messages = {
				enabled = false,
			},
		},
    config = function (_, opts)
      require'noice'.setup(opts)
			vim.api.nvim_set_keymap("n", "<leader>.", "<cmd>:NoiceDismiss<cr>", { noremap = true })
      vim.cmd('set cmdheight=0')
    end
	},
  {
    "sindrets/diffview.nvim"
  }
}
