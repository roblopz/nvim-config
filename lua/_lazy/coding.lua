---@diagnostic disable: unused-local
return {
	-- Treesitter aware comments
	{ "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
	-- Auto close html-like tags
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	},
	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring"},
		cmd = { "TSUpdateSync" },
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			-- context_commentstring = { enable = true, enable_autocmd = false },
			ensure_installed = {
				"html",
				"javascript",
				"jsdoc",
				"json",
				"json5",
				"lua",
				"luadoc",
				"query",
				"regex",
				"tsx",
				"typescript",
				"vim",
				"yaml",
				"sql",
				"graphql",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = ",+",
					node_incremental = ",+",
					node_decremental = ",-",
					scope_incremental = "<nop>",
				},
			},
		},
		config = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				local added = {}
				opts.ensure_installed = vim.tbl_filter(function(lang)
					if added[lang] then
						return false
					end
					added[lang] = true
					return true
				end, opts.ensure_installed)
			end

			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	-- Autopairs
	{
		"windwp/nvim-autopairs",
		opts = { check_ts = true },
	},
	-- Highlight words under cursor
	{
		"RRethy/vim-illuminate",
		config = function()
			local wk = require("which-key")
			local illuminate = require("illuminate")

			illuminate.configure({ delay = 200 })

			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					local buffer = vim.api.nvim_get_current_buf()

					wk.register({
						["]]"] = {
							function()
								illuminate["goto_next_reference"](false)
							end,
							"Next reference",
							mode = "n",
							buffer = buffer,
						},
						["[["] = {
							function()
								illuminate["goto_prev_reference"](false)
							end,
							"Prev reference",
							mode = "n",
							buffer = buffer,
						},
					})
				end,
			})
		end,
	},
	-- Comments
	{
		"numToStr/Comment.nvim",
		opts = {
			custom_commentstring = function()
				return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
			end,
		},
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {
			keymaps = {
				normal = "ys", -- Surround by motion (ysiw)
				normal_cur_line = "yS", -- Surround current line adding above/below line
				visual = "S", -- Surround selection
				visual_line = "gS", -- Surround selection adding above/below line
				delete = "ds",
				change = "cs",
				normal_cur = false, -- Surround current line
				change_line = false,
				insert = false,
				insert_line = false,
				normal_line = false, -- Surround by motion (i.e. iw) and add above/below,
			},
			surrounds = {
				["j"] = {
					add = { "{/* ", " */}" },
				},
			},
		},
		config = function(_, opts)
			require("nvim-surround").setup(opts)
		end,
	},
	-- Indentation
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			indent = {
				char = "│",
			},
		},
	},
	-- Indentation
	{
		"echasnovski/mini.indentscope",
		version = false, -- wait till new 0.7.0 release to put it back on semver
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			draw = {
				animation = function()
					return 5
				end,
			},
			symbol = "│",
			options = { try_as_border = true },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
				callback = function()
					vim.b.miniindentscope_disable = true
				end,
			})
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		event = "BufReadPost",
		keys = {
			{ "zR", "<cmd>lua require'ufo'.openAllFolds()<CR>", desc = "Open all folds" },
			{ "zM", "<cmd>lua require'ufo'.closeAllFolds()<CR>", desc = "Open all folds" },
			{ "zr", "<cmd>lua require'ufo'.openFoldsExceptKinds()<CR>", desc = "Open all folds" },
			{ "zm", "<cmd>lua require'ufo'.closeFoldsWith()<CR>", desc = "Open all folds" },
			{ "zp", "<cmd>lua require'ufo'.peekFoldedLinesUnderCursor()<CR>", desc = "Open all folds" },
		},
		init = function()
			vim.o.foldcolumn = "0"
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		opts = {
			preview = {
				win_config = {
					winblend = 0,
				},
			},
			fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local suffix = ("  %d "):format(endLnum - lnum)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0
				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							---@diagnostic disable-next-line: param-type-mismatch
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end,
		},
	},
	{
		"printer.nvim",
		name = "printer.nvim",
		dev = true,
		dir = "<here>",
		event = "BufWinEnter",
		config = function()
			local function get_js_formatter(variant)
				local js_variant_formatter

				if variant == "object" then
					js_variant_formatter = function(inside, var)
						return string.format("console.log({ %s });", var, var)
					end
				elseif variant == "message" then
					js_variant_formatter = function(inside, var)
						return string.format("console.log('%s --> ', %s);", var, var)
					end
				else
					js_variant_formatter = function(inside, var)
						return string.format("console.log(%s);", var)
					end
				end

				return js_variant_formatter
			end

			local function make_formatters()
				local formatters = {
					lua = function(inside, variable)
						return string.format("print(%s)", variable)
					end,
				}

				local js_ftypes = {
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"json",
					"jsonc",
				}

				for _, js_lang in ipairs(js_ftypes) do
					formatters[js_lang] = get_js_formatter("default")
					formatters[js_lang .. "_object"] = get_js_formatter("object")
					formatters[js_lang .. "_message"] = get_js_formatter("message")
				end

				return formatters
			end

			require("printer").setup({
				formatters = make_formatters(),
			})

			_G.formatters = make_formatters()

			local function print_in_variant(op, variant, select_keys)
				return function()
					vim.b["variant"] = variant or "default"
					local keys = select_keys or ""

					local plug_keys =
						vim.api.nvim_replace_termcodes(string.format("<Plug>(%s)%s", op, keys), true, false, true)
					vim.api.nvim_feedkeys(plug_keys, "n", true)
				end
			end

			vim.keymap.set("n", "gpy", print_in_variant("printer_yank", "default"))
			-- -- Yank print object
			vim.keymap.set("n", "gpo", print_in_variant("printer_yank", "object"))
			-- Yank print message
			vim.keymap.set("n", "gpm", print_in_variant("printer_yank", "message"))
			-- Print below
			-- vim.keymap.set("n", "gpp", print_in_variant("printer_print", "default", 'iw'))
			-- -- Print below object notation
			-- vim.keymap.set("n", "gpo", print_in_variant("printer_print", "object", 'iw'))
			-- -- Print below object message notation
			-- vim.keymap.set("n", "gpm", print_in_variant("printer_print", "message", 'iw'))

			vim.keymap.set("v", "gpy", "<Plug>(printer_yank)")
		end,
	},
}
