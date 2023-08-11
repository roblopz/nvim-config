return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")

		-- Windows & Quickfix
		wk.register({
			["<leader>qf"] = {
				f = { "<Cmd>copen<CR>", "Focus quickfix window" },
				c = { "<Cmd>cclose<CR>", "Close quickfix window" },
			},
			["<M-Right>"] = { "<C-w>l", "Window right" },
			["<M-Left>"] = { "<C-w>h", "Window left" },
			["<M-Up>"] = { "<C-w>k", "Window up" },
			["<M-Down>"] = { "<C-w>j", "Window down" },
			["<C-c>"] = { "<Cmd>close<CR>", "Close window" },
			["]q"] = { "<Cmd>cn<CR>", "QuickFix down" },
			["[q"] = { "<Cmd>cp<CR>", "QuickFix up" },
		})

		-- Misc
		wk.register({
			["<leader>"] = {
				["<space>"] = { function ()
				  vim.cmd("nohlsearch")
          require'flash'.toggle(false)
				end, "Toggle off highlight search" },
				["o"] = { "o<Esc>", "(n) Insert blank line below" },
				["O"] = { "O<Esc>", "(n) Insert blank line above" },
			},
			["<S-Up>"] = { "<S-v><Up>", "Enter l-visual up" },
			["<S-Down>"] = { "<S-v><Down>", "Enter l-visual down" },
		})

		-- Special commands (some map from terminal emmulator) - n
		wk.register({
			["<C-space>"] = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover docs", mode = "n" },
			["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "n" }, -- <Cmd-w>
			["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "n" }, -- <Cmd-A-w>
			["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "n" }, -- <A-S-f>
			["ã-3"] = { "<Cmd>lua require'lsp_signature'.toggle_float_win()<CR>", "Signature toggle", mode = "n" }, -- <A-Space>
			["ã-4"] = { "<Cmd>:FormatWrite<CR>", "Lint", mode = "n" }, -- <A-S-e>
			["ã-5"] = { "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action", mode = "n" }, -- <Cmd-.>
			["ã-6"] = { "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename", mode = "n" }, -- F2
		})

		-- Special commands (some map from terminal emmulator) - i
		wk.register({
			["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "i" },
			["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "i" },
			["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "i" },
			["ã-4"] = { "<Cmd>:Format<CR>", "Lint", mode = "i" },
		})

		-- LSP diagnostics
		wk.register({
			["]d"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "next" })
				end,
				"Diagnostics next",
			},
			["[d"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "prev" })
				end,
				"Diagnostics prev",
			},
			["]D"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "next", severity = vim.diagnostic.severity.ERROR })
				end,
				"Error next",
			},
			["[D"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "prev", severity = vim.diagnostic.severity.ERROR })
				end,
				"Error prev",
			},
			["]a"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "next", trigger_action = true })
				end,
				"Code action next",
			},
			["[a"] = {
				function()
					require("util.lsp.diagnostic").jump({ dir = "prev", trigger_action = true })
				end,
				"Code action prev",
			},
			["]A"] = {
				function()
					require("util.lsp.diagnostic").jump({
						dir = "next",
						severity = vim.diagnostic.severity.ERROR,
						trigger_action = true,
					})
				end,
				"Error code action next",
			},
			["[A"] = {
				function()
					require("util.lsp.diagnostic").jump({
						dir = "prev",
						severity = vim.diagnostic.severity.ERROR,
						trigger_action = true,
					})
				end,
				"Error code action prev",
			},
			["<leader>dq"] = { "<Cmd>lua vim.diagnostic.setqflist()<CR>", "Diagnostics to quickfix" },
			["<leader>db"] = {
				"<cmd>lua vim.diagnostic.open_float({ scope = 'b', source = true })<CR>",
				"Buffer Diagnostics",
			},
		})
	end,
}
