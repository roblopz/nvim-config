return {
	{
		"gbprod/yanky.nvim",
		opts = {
			highlight = { timer = 400, on_put = true, on_yank = true },
			ring = { storage = "shada" },
		},
    -- stylua: ignore start
    keys = {
      { "<leader>fy", function() require("telescope").extensions.yank_history.yank_history({ }) end, desc = "Open Yank History" },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put yanked text after cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put yanked text before cursor" },
      { "[y", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Cycle forward through yank history" },
      { "]y", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Cycle backward through yank history" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", mode = { "n", "x" }, desc = "Put after current line" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", mode = { "n", "x" }, desc = "Put before current line" },
      { ">p", "<Plug>(YankyPutAfterCharwiseJoined)", mode = { "n", "x" }, desc = "Put after, charwise" },
      { "<p", "<Plug>(YankyPutBeforeCharwiseJoined)", mode = { "n", "x" }, desc = "Put before, charwise" },
    },
		-- stylua: ignore end
	},
	{
		"gbprod/substitute.nvim",
		dependencies = { "gbprod/yanky.nvim" },
		opts = function()
			return {
				on_substitute = require("yanky.integration").substitute(),
				highlight_substituted_text = {
					enabled = true,
					timer = 400,
				},
				range = {
					prefix = "s",
					prompt_current_text = false,
					confirm = false,
					complete_word = false,
					motion1 = false,
					motion2 = false,
					suffix = "",
				},
				exchange = {
					motion = false,
					use_esc_to_cancel = true,
				},
			}
		end,
		config = function(_, opts)
			require("substitute").setup(opts)
			vim.keymap.set("n", "s", require("substitute").operator, { noremap = true })
			vim.keymap.set("n", "ss", require("substitute").line, { noremap = true })
			vim.keymap.set("n", "S", require("substitute").eol, { noremap = true })
			vim.keymap.set("x", "s", require("substitute").visual, { noremap = true })
		end,
	},
}
