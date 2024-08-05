return {
	-- Main Lsp & cmp
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-cmdline",
			"onsails/lspkind.nvim",
			"L3MON4D3/LuaSnip",
		},
		opts = {
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = false,
					prefix = " ●",
				},
				signs = false,
				severity_sort = true,
				float = {
					border = "rounded",
					severity_sort = true,
					source = true,
				},
			},
			capabilities = {
				textDocument = {
					foldingRange = {
						dynamicRegistration = false,
						lineFoldingOnly = true,
					},
				},
			},
			servers = {
				jsonls = true,
				tsserver = true,
				lua_ls = {
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
        eslint = {
          settings = {
            -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
            workingDirectories = { mode = "auto" },
          },
        },
			},
			cmp = function()
				local cmp = require("cmp")
				local cmp_defaults = require("cmp.config.default")()
				local lspkind = require("lspkind")

				-- vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

				return {
					snippet = {
						expand = function(args)
              _G.aa = args.body;
							require("luasnip").lsp_expand(args.body)
						end,
					},
					completion = {
						completeopt = "menu,menuone,noselect",
					},
					mapping = cmp.mapping.preset.insert({
						["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
						["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
						["<C-d>"] = cmp.mapping.scroll_docs(-4),
						["<C-u>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = true }),
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" },
						{ name = "buffer" },
						{ name = "path" },
					}),
					formatting = {
						format = lspkind.cmp_format({
							mode = "symbol_text", -- Only symbol annotations
							maxwidth = 50, -- characters
							ellipsis_char = "...", -- Truncate text if > maxwidth
						}),
					},
					experimental = {
            ghost_text = false
						-- ghost_text = {
						-- 	hl_group = "CmpGhostText",
						-- },
					},
					sorting = cmp_defaults.sorting,
					window = {
						completion = cmp.config.window.bordered(),
						documentation = cmp.config.window.bordered(),
					},
				}
			end,
		},
		config = function(_, opts)
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- Capabilities, extended from lsp_default + "options.capabilities" here + cmd
			local default_capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities(),
				opts.capabilities or {}
			)

			-- Overwrite to make bordered lsp windows
			local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
			---@diagnostic disable-next-line: duplicate-set-field
			function vim.lsp.util.open_floating_preview(contents, syntax, lsp_opts, ...)
				lsp_opts = lsp_opts or {}
				lsp_opts.border = lsp_opts.border or "rounded" -- <.Here
				return orig_util_open_floating_preview(contents, syntax, lsp_opts, ...)
			end

			-- Setup cmp
			local cmp = require("cmp")
			cmp.setup(type(opts.cmp) == "function" and opts.cmp() or (opts.cmp or {}))

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

			local function get_specific_server_opts(server_key)
				local s_opts = opts.servers[server_key]

				if s_opts then
					if type(s_opts) == "boolean" then
						return {}
					elseif type(s_opts) == "function" then
						return s_opts()
					end
				end

				return s_opts or nil
			end

			for server_key, _ in pairs(opts.servers) do
				local specific_server_opts = get_specific_server_opts(server_key)

				if specific_server_opts ~= nil then
					local final_opts = vim.tbl_deep_extend("force", {
						capabilities = vim.deepcopy(default_capabilities),
					}, specific_server_opts)

					require("lspconfig")[server_key].setup(final_opts)
				end
			end
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
	-- Snippets, required for cmp
	{
		"L3MON4D3/LuaSnip",
		run = "make install_jsregexp",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
	},
}
