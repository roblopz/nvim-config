local M = {
	is_setup = false,
}

local function path_itera(buf)
	local parts = vim.split(vim.api.nvim_buf_get_name(buf), "/", { trimempty = true })
	local index = #parts + 1
	return function()
		index = index - 1
		if index > 0 then
			return parts[index]
		end
	end
end

local function icon_from_devicon(ft)
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if not ok then
		return ""
	end
	return devicons.get_icon_by_filetype(ft)
end

local function get_win_bar_path(buf, folder_level)
	local ft = vim.bo[buf].filetype
	local icon, hl = icon_from_devicon(ft)

	local bar = {
		prefix = "%#WinbarFname",
		sep = "%#WinbarFnameSep#" .. " › " .. "%*",
	}

  folder_level = folder_level or 0

	local items = {}
	local folder = " " .. "%*"

	for item in path_itera(buf) do
		item = #items == 0
				and "%#" .. (hl or "SagaFileIcon") .. "#" .. (icon and icon .. " " or "") .. "%*" .. bar.prefix .. "FileName#" .. item .. "%*"
			or bar.prefix .. "Folder#" .. folder .. bar.prefix .. "FolderName#" .. item .. "%*"
		items[#items + 1] = item

		if #items > folder_level then
			break
		end
	end

	local barstr = ""
	for i = #items, 1, -1 do
		barstr = barstr .. items[i] .. (i > 1 and bar.sep or "")
	end

	return barstr
end

M.win_bar_fname = function(path_depth)
	return function()
		local winid = vim.api.nvim_get_current_win()
		local winconf = vim.api.nvim_win_get_config(winid)

		if #winconf.relative ~= 0 then
			return
		end

    path_depth = path_depth or 0

    -- Go up one level if fname is "index".xx?
    local fname = vim.fn.expand('%:t')
    if fname:match('index%.[jt]sx?$') ~= nil and path_depth < 1 then
      path_depth = 1
    end

		return get_win_bar_path(vim.fn.bufnr(), path_depth)
	end
end

M.setup = function()
	if M.is_setup then
		return
	end

	local hlss = {
		WinbarFnameFolder = { link = "Title" },
		WinbarFnameFolderName = { link = "Comment" },
		WinbarFnameSep = { link = "Operator" },
	}

	for group, conf in pairs(hlss) do
		vim.api.nvim_set_hl(0, group, vim.tbl_extend("keep", conf, { default = true }))
	end
end

return M
