local telescope_util = require("custom-util.telescope")

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-telescope/telescope-live-grep-args.nvim" },
		commit = vim.fn.has("nvim-0.9.0") == 0 and "057ee0f8783" or nil,
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		keys = {
      -- stylua: ignore start
      -- Files
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fF", "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", desc = "Find Files (all)" },
      -- Commands
      { "<leader>fc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      -- Windows
      { "<leader>fw", "<cmd>Telescope windows<cr>", desc = "Windows" },
      {
        "<leader>fb",
        function ()
          require'telescope.builtin'.buffers({
            sort_lastused = true,
            ignore_current_buffer = true,
            only_cwd = true,
          })
        end,
        desc = "Buffers (not current)"
      },
      {
        "<leader>fB",
        function ()
          require'telescope.builtin'.buffers({
            sort_lastused = true,
            only_cwd = true,
          })
        end,
        desc = "Buffers (all)"
      },
      -- old files
      { "<leader>fo", function () require'telescope.builtin'.oldfiles({ cwd = vim.loop.cwd() }) end, desc = "Recent (cwd)" },
      { "<leader>fO", "<cmd>Telescope oldfiles<cr>", desc = "Recent (all cwd's)" },
      -- Git
      { "<leader>fs", "<cmd>Telescope git_status<CR>", desc = "status" },
      -- Current buffer
      { "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer find" },
      -- Diagnostics
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      -- Grep
      { "<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", desc = "Live grep" },
      { "<leader>fG", "<cmd>Telescope grep_string mode=v<cr>", desc = "Grep Word" },
			-- stylua: ignore end
		},
		opts = function()
			local lga_actions = require("telescope-live-grep-args.actions")

			return {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					layout_strategy = "vertical",
					sorting_strategy = "ascending",
					layout_config = {
						scroll_speed = 10,
						prompt_position = "top",
						mirror = true,
					},
				},
				extensions = {
					live_grep_args = {
						mappings = {
							i = vim.tbl_deep_extend(
								"force",
								telescope_util.get_mappings(function(reopen_prompt_args)
									---@diagnostic disable-next-line: different-requires
									require("telescope").extensions.live_grep_args.live_grep_args(reopen_prompt_args)
								end),
								{
									["<C-k>"] = lga_actions.quote_prompt(),
									["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
									["<Tab>"] = function(prompt)
										local actions = require("telescope.actions")
										actions.toggle_selection(prompt)
										actions.move_selection_worse(prompt)
									end,
								}
							),
						},
					},
				},
				pickers = {
					find_files = {
						mappings = {
							i = telescope_util.get_mappings("find_files"),
						},
					},
					live_grep = {
						mappings = {
							i = telescope_util.get_mappings("live_grep"),
						},
					},
					grep_string = {
						mappings = {
							i = telescope_util.get_mappings("grep_string"),
						},
					},
					buffers = {
						mappings = {
							i = telescope_util.get_mappings("buffers"),
						},
					},
					oldfiles = {
						mappings = {
							i = telescope_util.get_mappings("oldfiles"),
						},
					},
					lsp_references = {
						mappings = {
							i = telescope_util.get_mappings("oldfiles"),
						},
					},
				},
			}
		end,
		config = function(_, opts)
			---@diagnostic disable-next-line: different-requires
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("live_grep_args")
			telescope.load_extension("windows")
		end,
	},
}
