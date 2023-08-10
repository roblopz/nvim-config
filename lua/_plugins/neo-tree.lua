return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	cmd = "Neotree",
	keys = {
		{
			"<leader>tt",
			"<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'left' })<CR>",
			"Toggle Tree",
		},
		{
			"<leader>tf",
			"<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'left' })<CR>",
			"Focus File",
		},
		{
			"<leader>to",
			function()
				local nt = require("neo-tree.command")
				nt.execute({ action = "close" })
				nt.execute({ position = "float" })
			end,
			"Toggle Tree Float",
		},
		{
			"<leader>tp",
			function()
				local nt = require("neo-tree.command")
				nt.execute({ action = "close" })
				nt.execute({ position = "float", reveal = true })
			end,
			"Focus File Float",
		},
		{
			"<leader>tb",
			"<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
			"Tree buffers",
		},
		{
			"<leader>tg",
			"<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
			"Tree Git Status",
		},
	},
	deactivate = function()
		vim.cmd([[Neotree close]])
	end,
	init = function()
		-- Open tree at init
		vim.fn.timer_start(1, function()
			vim.cmd("Neotree show")
		end)
	end,
	opts = {
		enable_git_status = false,
    enable_diagnostics = false,
		open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
		enable_normal_mode_for_inputs = true,
		filesystem = {
			use_libuv_file_watcher = true,
		},
		buffers = {
			show_unloaded = false,
		},
	},
}
