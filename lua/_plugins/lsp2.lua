return {
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
					source = "if_many",
					prefix = " ●",
				},
				severity_sort = true,
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
			},
			cmp = function()
				local cmp = require("cmp")
				local cmp_defaults = require("cmp.config.default")()
				local lspkind = require("lspkind")

				vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

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
      local cmp_opts = type(opts.cmp) == "function" and opts.cmp() or (opts.cmp or {})
      _G.cmp_opts = cmp_opts
			cmp.setup(cmp_opts)

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
}
