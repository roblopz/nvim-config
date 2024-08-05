local function merge_config(base, ext)
	local table = {}
	-- copy base
	for key, value in next, base do
		table[key] = value
	end

	for key, value in next, ext do
		old = table[key]
		if type(old) == "table" and type(value) == "table" then
			table[key] = merge_config(old, value)
		else
			table[key] = value
		end
	end

	return table
end

return require("telescope").register_extension({
	setup = function() end,
	exports = {
		windows = function(opts)
			local wins = require("custom-util.telescope-windows")
			wins.windows(merge_config(opts, {
				ignore_current_window = true,
			}))
		end,
	},
})
