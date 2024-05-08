local M = {}

local is_windows = vim.loop.os_uname().version:match("Windows")
local path_separator = is_windows and "\\" or "/"

local id_root_by_files = { ".git", "package.json" }

-- From null-ls: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/lua/null-ls/utils/init.lua
-- Checks if path is root by comparing against id_root_by_files table
local function root_path_matcher(path)
	if not path then
		return nil
	end

	-- escape wildcard characters in the path so that it is not treated like a glob
	path = path:gsub("([%[%]%?%*])", "\\%1")
	for _, pattern in ipairs(id_root_by_files) do
		---@diagnostic disable-next-line: param-type-mismatch
		for _, p in ipairs(vim.fn.glob(M.path.join(path, pattern), true, true)) do
			if M.path.exists(p) then
				return path
			end
		end
	end

	return nil
end

local function get_root_for_path(start_path)
	local start_match = root_path_matcher(start_path)
	if start_match then
		return start_match
	end

	for path in vim.fs.parents(start_path) do
		local match = root_path_matcher(path)
		if match then
			return match
		end
	end
end

function M.coalesce(bool, if_true, if_false)
	if bool then
		return if_true
	else
		return if_false
	end
end

function M.tbl_first(tbl, fn)
	for _, e in pairs(tbl) do
		if fn(e) then
			return e
		end
	end

	return nil
end

function M.split_table(tbl, idx)
	local t1 = {}
	local t2 = {}

	for i = 1, idx do
		t1[i] = tbl[i]
	end

	for i = idx + 1, #tbl do
		t2[i - idx] = tbl[i]
	end

	return t1, t2
end

function M.cwd()
	local has_lsp_util, lsp_util = pcall(require, "lspconfig.util")
	local cwd = vim.fn.getcwd()

	if has_lsp_util then
		return lsp_util.find_git_ancestor(cwd) or lsp_util.find_package_json_ancestor(cwd)
	else
		return cwd
	end
end

M.path = {
	exists = function(filename)
		local stat = vim.loop.fs_stat(filename)
		return stat ~= nil
	end,
	join = function(...)
		return table.concat(vim.tbl_flatten({ ... }), path_separator):gsub(path_separator .. "+", path_separator)
	end,
	-- Gets worspace root
	get_root = function()
		local root

		-- if in named buffer, resolve directly from root_dir
		local fname = vim.api.nvim_buf_get_name(0)
		if fname ~= "" then
			root = get_root_for_path(fname)
		end

		root = root or vim.loop.cwd()
		return root
	end,
	-- has_file fun(patterns: ...): boolean checks if file exists
	has_file = function(...)
		local patterns = vim.tbl_flatten({ ... })
		for _, name in ipairs(patterns) do
			local full_path = vim.loop.fs_realpath(name)
			if full_path and M.path.exists(full_path) then
				return true
			end
		end
		return false
	end,
	-- root_has_file fun(patterns: ...): boolean checks if file exists at root level
	root_has_file = function(...)
		local root = M.path.get_root()
		local patterns = vim.tbl_flatten({ ... })
		for _, name in ipairs(patterns) do
			if M.path.exists(M.path.join(root, name)) then
				return true
			end
		end
		return false
	end,
	-- root_has_file_matches fun(pattern: string): boolean checks if pattern matches a file at root level
	root_has_file_matches = function(pattern)
		local root = M.path.get_root()
		local handle = vim.loop.fs_scandir(root)
		local entry = vim.loop.fs_scandir_next(handle)

		while entry do
			if entry:match(pattern) then
				return true
			end

			entry = vim.loop.fs_scandir_next(handle)
		end

		return false
	end,
	root_matches = function(pattern)
		local root = M.path.get_root()
		return root:find(pattern) ~= nil
	end,
}

function M.warn(msg, inspect)
	require("notify")(M.coalesce(inspect, vim.inspect(msg), msg), "warn")
end

function M.info(msg, inspect)
	require("notify")(M.coalesce(inspect, vim.inspect(msg), msg), "info")
end

function M.error(msg, inspect)
	require("notify")(M.coalesce(inspect, vim.inspect(msg), msg), "error")
end

function M.buf_excluded(exclude, bufnr)
	if not bufnr then
		bufnr = vim.api.nvim_get_current_buf()
	end

	local btype = vim.api.nvim_buf_get_option(bufnr, "filetype")
	return btype == "" or btype == nil or vim.tbl_contains(exclude, btype)
end

return M
