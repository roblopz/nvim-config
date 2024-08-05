local function getTelescopeOpts(state, path)
	return {
		cwd = path,
		search_dirs = { path },
		attach_mappings = function(prompt_bufnr)
			local actions = require("telescope.actions")
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local action_state = require("telescope.actions.state")
				local selection = action_state.get_selected_entry()
				local filename = selection.filename
				if filename == nil then
					filename = selection[1]
				end
				-- any way to open the file without triggering auto-close event of neo-tree?
				require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
			end)
			return true
		end,
	}
end

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
				-- nt.execute({ action = "close" })
				nt.execute({ position = "float" })
			end,
			"Toggle Tree Float",
		},
		{
			"<leader>tp",
			function()
				local nt = require("neo-tree.command")
				-- nt.execute({ action = "close" })
				nt.execute({ position = "float", reveal = true })
			end,
			"Focus File Float",
		},
		{
			"<leader>tb",
			"<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
			"Tree buffers",
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
	opts = function()
		local neo_util = require("neo-tree.utils")

		local function make_win_open(opts)
			local function get_bufrn_or_path(tree_node)
				if tree_node and tree_node.type == "file" then
					local bufnr = tree_node.extra and tree_node.extra.bufnr
					if not bufnr then
						bufnr = neo_util.find_buffer_by_name(tree_node.path)
					end

					if bufnr and bufnr ~= -1 then
						return bufnr
					elseif tree_node.path then
						return tree_node.path
					end
				end

				return nil
			end

			return function(state)
				local bufnr_or_path = get_bufrn_or_path(state.tree:get_node())
				if bufnr_or_path then
					require("open-window").open(bufnr_or_path, opts)
				end
			end
		end

		return {
			enable_git_status = false,
			enable_diagnostics = false,
			open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
			window = {
				mappings = {
					["z"] = "none",
					["Z"] = "close_all_nodes",
					["<C-v>"] = make_win_open({ mode = "split" }),
					["<C-x>"] = make_win_open({ mode = "split", horizontal = true }),
					["<C-s>"] = make_win_open({ mode = "pick" }),
					["f"] = "telescope_find",
					["g"] = "telescope_grep",
					["<C-o>"] = "system_open",
				},
			},
			filesystem = {
				use_libuv_file_watcher = true,
			},
			buffers = {
				show_unloaded = false,
			},
			commands = {
				telescope_find = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()

					if node.type == "directory" then
						require("telescope.builtin").find_files(getTelescopeOpts(state, path))
					end
				end,
				telescope_grep = function(state)
					local node = state.tree:get_node()

					if node.type == "directory" then
						local path = node:get_id()
						require("telescope.builtin").live_grep(getTelescopeOpts(state, path))
					end
				end,
				system_open = function(state)
					local node = state.tree:get_node()
					local path = node:get_id()

          if node.type == 'file' then
            path = vim.fn.fnamemodify(path, ':h')
          end

          vim.notify(path)

					vim.fn.jobstart({ "open", "-g", path }, { detach = true })
				end,
			},
		}
	end,
}
