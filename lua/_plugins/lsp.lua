return {
	{ "nvim-lua/plenary.nvim" },
	-- Lsp
	{
		"neovim/nvim-lspconfig",
		name = "old-lsp",
		dev = true,
		enabled = false,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		opts = {
			-- options for vim.diagnostic.config()
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = " ●",
				},
				severity_sort = true,
			},
			-- add any global capabilities here
			capabilities = {
				textDocument = {
					foldingRange = {
						dynamicRegistration = false,
						lineFoldingOnly = true,
					},
				},
			},
			-- Automatically format on save
			--autoformat = true,
			-- Enable this to show formatters used in a notification useful for debugging formatter issues
			--format_notify = false,
			servers = {
				jsonls = {},
				lua_ls = {
					-- mason = false, -- set to false if you don't want this server to be installed with mason
					-- Use this to add any additional keymaps
					-- for specific lsp servers
					-- keys = {},
					settings = {
						Lua = {
							format = {
								enable = false, -- Using stylua
							},
							runtime = {
								version = "LuaJIT",
							},
							workspace = {
								library = vim.api.nvim_get_runtime_file("", true),
								checkThirdParty = false,
							},
							diagnostics = {
								globals = { "vim", "plugin_module" },
							},
						},
					},
				},
			},
			-- you can do any additional lsp server setup here
			-- return true if you don't want this server to be setup with lspconfig
			setup = {
				-- example to setup with typescript.nvim
				-- tsserver = function(_, opts)
				--   require("typescript").setup({ server = opts })
				--   return true
				-- end,
				-- Specify * to use this function as a fallback for any server
				-- ["*"] = function(server, opts) end,
			},
		},
		config = function(_, opts)
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local servers = opts.servers
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			-- Capabilities, extended from lsp_default + "options.capabilities" here + cmd
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities(),
				opts.capabilities or {}
			)

			-- Hide icons on gutter
			vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "" })
			vim.fn.sign_define("DiagnosticsSigWarning", { text = "", texthl = "" })
			vim.fn.sign_define("DiagnosticsSigInformation", { text = " ", texthl = "" })
			vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "" })

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})

				-- Make bordered windows in hover
				local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
				function vim.lsp.util.open_floating_preview(contents, syntax, lsp_opts, ...)
					lsp_opts = lsp_opts or {}
					lsp_opts.border = lsp_opts.border or "rounded" -- <.Here
					return orig_util_open_floating_preview(contents, syntax, lsp_opts, ...)
				end

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end

				_G.seq = _G.seq or {}
				table.insert(_G.seq, "LSP")
				require("lspconfig")[server].setup(server_opts)
			end

			-- get all the servers that are available thourgh mason-lspconfig
			local have_mason, mlsp = pcall(require, "mason-lspconfig")
			local all_mslp_servers = {}
			if have_mason then
				all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
			end

			local ensure_installed = {}
			for server, server_opts in pairs(servers) do
				if server_opts then
					server_opts = server_opts == true and {} or server_opts
					-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
					if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
						setup(server)
					else
						ensure_installed[#ensure_installed + 1] = server
					end
				end
			end

			if have_mason then
				mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
			end
		end,
	},
	-- Snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
			config = function()
				require("luasnip.loaders.from_vscode").lazy_load()
			end,
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
	},
	-- auto completion
	{
		"hrsh7th/nvim-cmp",
		name = "old-cmp",
		dev = true,
		enabled = false,
		version = false, -- last release is way too old
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
			"onsails/lspkind.nvim",
		},
		opts = function()
			vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

			local cmp = require("cmp")
			local cmp_defaults = require("cmp.config.default")()
			local lspkind = require("lspkind")

			return {
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-u>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<Tab>"] = cmp.mapping.confirm({ select = true }),
					["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol_text", -- show only symbol annotations
						maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
						ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
						-- The function below will be called before any actual modifications from lspkind
						-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
						before = function(_, vim_item)
							return vim_item
						end,
					}),
				},
				experimental = {
					ghost_text = {
						hl_group = "CmpGhostText",
					},
				},
				sorting = cmp_defaults.sorting,
			}
		end,
		config = function(_, opts)
			local cmp = require("cmp")

			-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},
	-- formatters
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "mason.nvim", "nvim-lua/plenary.nvim" },
		opts = function()
			local nls = require("null-ls")
			return {
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
				sources = {
					nls.builtins.code_actions.eslint_d,
					nls.builtins.diagnostics.eslint_d,
					nls.builtins.formatting.prettier,
					nls.builtins.formatting.stylua,
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
		"rmagatti/goto-preview",
		dependencies = { "nvim-telescope/telescope.nvim" },
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
				"<Cmd>lua require('util.lsp.keys').go_to_definition({ mode = 'split', horizontal = true })<CR>",
				desc = "Open definition - vsplit",
			},
			{
				"gdv",
				"<Cmd>lua require('util.lsp.keys').go_to_definition({ mode = 'split' })<CR>",
				desc = "Open definition - hsplit",
			},
			{
				"gds",
				"<Cmd>lua require('util.lsp.keys').go_to_definition({ mode = 'pick' })<CR>",
				desc = "Open definition - Pick window",
			},
			{
				"grp",
				"<Cmd>lua require('goto-preview').goto_preview_references()<CR>",
				desc = "References - Preview",
			},
			{
				"grq",
				"<Cmd>lua vim.lsp.buf.references()<CR>",
				desc = "References - Quickfix",
			},
		},
		opts = function()
			local function minimize_win(winid)
				local o_width = vim.api.nvim_win_get_width(winid)
				local o_height = vim.api.nvim_win_get_height(winid)

				vim.api.nvim_win_set_width(winid, 40)
				vim.api.nvim_win_set_height(winid, 1)

				-- Return restore fn
				return function()
					vim.api.nvim_win_set_width(winid, o_width)
					vim.api.nvim_win_set_height(winid, o_height)
				end
			end

			local function set_win_mappings(bufnr, winid, keymap, open_win_opts)
				vim.keymap.set("n", keymap, function()
					local restore_win = minimize_win(winid)

					open_win_opts.cb = function(res)
						if res.opened then
							vim.api.nvim_win_close(winid, true)
						else
							restore_win()
						end
					end

					open_win_opts.on_open_set_cursor = vim.api.nvim_win_get_cursor(winid)

					require("open-window").open(bufnr, open_win_opts)
				end, { buffer = bufnr })
			end

			local function clear_all(bufnr, cmdid)
				vim.keymap.del("n", "<c-v>", { buffer = bufnr })
				vim.keymap.del("n", "<c-x>", { buffer = bufnr })
				vim.keymap.del("n", "<c-s>", { buffer = bufnr })
				vim.api.nvim_del_autocmd(cmdid)
			end

			return {
				width = 160,
				height = 40,
				opacity = nil,
				resizing_mappings = false,
				focus_on_open = true,
				dismiss_on_move = false,
				post_open_hook = function(bufnr, winid)
					vim.api.nvim_create_autocmd({ "WinClosed" }, {
						callback = function(ev)
							local is_match = tostring(ev.match) == tostring(winid)

							if is_match then
								if not pcall(clear_all, bufnr, ev.id) then
									vim.notify("Error clearing floating window events", vim.log.levels.WARN)
								end
							end
						end,
					})

					set_win_mappings(bufnr, winid, "<c-v>", { mode = "split" })
					set_win_mappings(bufnr, winid, "<c-x>", { mode = "split", horizontal = true })
					set_win_mappings(bufnr, winid, "<c-s>", { mode = "pick" })
				end,
				references = {
					telescope = require("telescope.themes").get_dropdown({
						results_title = "References",
						winblend = 0,
						layout_strategy = "horizontal",
						show_line = false,
						layout_config = {
							preview_cutoff = 1,
							prompt_position = "bottom",
							width = function(_, max_columns, _)
								return math.min(max_columns, 220)
							end,
							height = function(_, _, max_lines)
								return math.min(max_lines, 50)
							end,
						},
						attach_mappings = function(_, map)
							local mappings = require("util.telescope").get_mappings(function(reopen_prompt_args)
								require("goto-preview").goto_preview_references(reopen_prompt_args)
							end)

							for mapKey, mapFn in pairs(mappings) do
								map("i", mapKey, mapFn)
							end

							return true
						end,
					}),
				},
			}
		end,
	},
	-- Signature help
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {
			bind = true,
			max_height = 40,
			max_width = 100,
			wrap = true,
			floating_window = false,
			floating_window_above_cur_line = true,
			hint_enable = false,
			hi_parameter = "LspSignatureActiveParameter",
			transparency = nil,
			shadow_blend = 36, -- if you using shadow as border use this set the opacity
			shadow_guibg = "Black", -- if you using shadow as border use this set the color
			always_trigger = false,
			toggle_key = "ã-3", -- toggle signature on and off in insert mode <A-Space>
			toggle_key_flip_floatwin_setting = true, -- true: toggle float setting after toggle key pressed
			select_signature_key = "<c-d>", -- cycle to next signature, e.g. '<M-n>' function overloading
			move_cursor_key = "<c-u>", -- imap, use nvim_set_current_win to move cursor between current win and floating
			zindex = 200,
			handler_opts = {
				border = "rounded",
			},
		},
	},
	{
		"nvimdev/lspsaga.nvim",
		opts = {
			border = "rounded",
			symbol_in_winbar = { enable = false },
			callhierarchy = { enable = false },
			code_action = { enable = false },
			definition = { enable = false },
			finder = { enable = false },
			hover_doc = { enable = false },
			implement = { enable = false },
			lightbulb = { enable = false },
			outline = { enable = false },
			rename = { enable = false },
			beacon = { enable = false },
		},
		config = function(_, opts)
			require("lspsaga").setup(opts)
		end,
	},
}
