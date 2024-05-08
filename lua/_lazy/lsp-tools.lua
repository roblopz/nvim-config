return {
	-- LSP client middleware
	-- {
	-- 	"nvimtools/none-ls.nvim",
	-- 	event = { "BufReadPre", "BufNewFile" },
	-- 	dependencies = { "mason.nvim", "nvim-lua/plenary.nvim" },
	-- 	opts = function()
	-- 		local nls = require("null-ls")
	--
	-- 		return {
	-- 			sources = {
	-- 				-- nls.builtins.code_actions.eslint,
	-- 				nls.builtins.diagnostics.eslint,
	-- 				nls.builtins.formatting.prettier,
	-- 				nls.builtins.formatting.stylua,
	-- 			},
	--        debug = true
	-- 		}
	-- 	end,
	-- },
	-- Run formatters on demand (:Format, :FormatWrite)
	{
		"mhartington/formatter.nvim",
		opts = function()
			return {
				filetype = {
					javascript = {
						require("formatter.filetypes.json").prettier,
					},
					javascriptreact = {
						require("formatter.filetypes.json").prettier,
					},
					typescript = {
            require("formatter.filetypes.json").prettier
					},
					typescriptreact = {
						require("formatter.filetypes.json").prettier,
					},
					json = {
            require("formatter.filetypes.json").prettier
					},
					jsonc = {
            require("formatter.filetypes.json").prettier
					},
					lua = {
						require("formatter.filetypes.lua").stylua,
					},
				},
			}
		end,
	},
	-- Install language servers
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = { "stylua" },
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end

			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
	-- LSP previews
	{
		name = "lsp-goto",
		dev = true,
		dir = "<here>",
		dependencies = { "rmagatti/goto-preview", "nvim-telescope/telescope.nvim" },
		keys = {
			{
				"gdg",
				"<Cmd>lua vim.lsp.buf.definition()<CR>",
				desc = "Go to definition",
			},
			{
				"gdp",
				"<Cmd>lua require('goto-preview').goto_preview_definition()<CR>",
				desc = "Preview definition",
			},
			{
				"gdx",
				"<Cmd>lua require'lsp-goto.keys'.go_to_definition({ mode = 'split', horizontal = true })<CR>",
				desc = "Open definition - vsplit",
			},
			{
				"gdv",
				"<Cmd>lua require'lsp-goto.keys'.go_to_definition({ mode = 'split' })<CR>",
				desc = "Open definition - hsplit",
			},
			{
				"gds",
				"<Cmd>lua require'lsp-goto.keys'.go_to_definition({ mode = 'pick' })<CR>",
				desc = "Open definition - Pick window",
			},
			{
				"grp",
				"<Cmd>lua require'goto-preview'.goto_preview_references()<CR>",
				desc = "References - Preview",
			},
			{
				"grq",
				"<Cmd>lua vim.lsp.buf.references()<CR>",
				desc = "References - Quickfix",
			},
		},
		config = function()
			require("lsp-goto").setup()
		end,
	},
	-- Diagnostics
	{
		"nvimdev/lspsaga.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "]d", "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "Diagnostic next" },
			{ "[d", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "Diagnostic prev" },
			{
				"]D",
				'<Cmd>lua require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>',
				desc = "Error next",
			},
			{
				"[D",
				'<Cmd>lua require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>',
				desc = "Error prev",
			},
			{ "<leader>dq", "<Cmd>lua vim.diagnostic.setqflist()<CR>", desc = "Diagnostics to quickfix" },
			{
				"<leader>db",
				"<cmd>lua vim.diagnostic.open_float({ scope = 'b', source = true })<CR>",
				desc = "Buffer Diagnostics",
			},
		},
		config = function()
			-- Only used for diagnostics
			require("lspsaga").setup({
				symbol_in_winbar = { enable = false },
				callhierarchy = { enable = false },
				definition = { enable = false },
				finder = { enable = false },
				hover = { enable = false },
				lightbulb = { enable = false },
				rename = { enable = false },
				implement = { enable = false },
				beacon = { enable = false },
				outline = { enable = false },
				code_action = { enable = false },
				diagnostic = { enable = true },
			})
		end,
	},
	{
		"akinsho/flutter-tools.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"stevearc/dressing.nvim", -- optional for vim.ui.select
		},
		config = true,
	},
}
