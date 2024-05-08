return {
	{
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
				["]b"] = { "<Cmd>bnext<CR>", "Next buffer" },
				["[b"] = { "<Cmd>bprev<CR>", "Prev buffer" },
				["<leader>bb"] = { "<Cmd>b#<CR>", "Buffer toggle" },
			})

			-- Misc
			wk.register({
				["<leader>"] = {
					["<space>"] = {
						function()
							vim.cmd("nohlsearch")
							require("flash").toggle(false)
						end,
						"Toggle off highlight search",
					},
					["o"] = { "o<Esc>", "(n) Insert blank line below" },
					["O"] = { "O<Esc>", "(n) Insert blank line above" },
				},
				["<S-Up>"] = { "<S-v><Up>", "Enter l-visual up" },
				["<S-Down>"] = { "<S-v><Down>", "Enter l-visual down" },
				["<"] = { "<gv", mode = "v" },
				[">"] = { ">gv", mode = "v" },
			})

			-- Special commands (some map from terminal emmulator) - n
			wk.register({
				["<C-space>"] = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover docs", mode = "n" },
				["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "n" }, -- <Cmd-w>
				["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "n" }, -- <Cmd-A-w>
				["ã-2"] = { "<Cmd>:Format<CR>", "Formatting", mode = "n" }, -- <A-S-f>
				["ã-3"] = { "<Cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature toggle", mode = "n" }, -- <A-Space>
				["ã-4"] = { "<Cmd>:EslintFixAll<CR>", "Lint", mode = "n" }, -- <A-S-e>
				["ã-5"] = { "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action", mode = "n" }, -- <Cmd-.>
				["ã-6"] = { "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename", mode = "n" }, -- F2
			})

			-- Special commands (some map from terminal emmulator) - i
			wk.register({
				["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "i" },
				["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "i" },
				["ã-2"] = { "<Cmd>:Format<CR>", "Formatting", mode = "i" },
				["ã-3"] = { "<Cmd>lua vim.lsp.buf.signature_help()<CR>", "Signature toggle", mode = "i" }, -- <A-Space>
				["ã-4"] = { "<Cmd>:EslintFixAll<CR>", "Lint", mode = "i" },
			})
		end,
	},
	-- Misc
	{
		"misc",
		dev = true,
		dir = "<this>",
		name = "misc",
		init = function()
			vim.api.nvim_create_autocmd("BufReadPost", {
				callback = function()
					local exclude = { "gitcommit" }
					local buf = vim.api.nvim_get_current_buf()
					if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
						return
					end
					local mark = vim.api.nvim_buf_get_mark(buf, '"')
					local lcount = vim.api.nvim_buf_line_count(buf)
					if mark[1] > 0 and mark[1] <= lcount then
						pcall(vim.api.nvim_win_set_cursor, 0, mark)
					end
				end,
			})
		end,
		config = function() end,
	},
}
