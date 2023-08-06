local telescope_util = require("util.telescope")

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
      -- Buffers
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fB", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      -- old files
      { "<leader>fo", function () require'telescope.builtin'.oldfiles({ cwd = vim.loop.cwd() }) end, desc = "Recent (cwd)" },
      { "<leader>fO", "<cmd>Telescope oldfiles<cr>", desc = "Recent (all cwd's)" },
      -- Git
      { "<leader>fi", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>fI", "<cmd>Telescope git_status<CR>", desc = "status" },
      -- Current buffer
      { "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      -- Diagnostics
      { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>fD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      -- Grep
      { "<leader>fg", "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", desc = "Grep (root dir)" },
      { "<leader>fw", "<cmd>Telescope grep_string mode=v<cr>", desc = "Grep Word" },
      -- Marks
      { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			-- stylua: ignore end
		},
		opts = function()
			local lga_actions = require("telescope-live-grep-args.actions")

			return {
				defaults = {
					prompt_prefix = " ",
					selection_caret = " ",
					layout_config = {
						scroll_speed = 10,
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
				},
			}
		end,
		config = function(_, opts)
			---@diagnostic disable-next-line: different-requires
			local telescope = require("telescope")
			telescope.setup(opts)
			telescope.load_extension("live_grep_args")
		end,
	},
}
