local M = {}

M.setup = function()
    local wk = require 'which-key'
    local illuminate = require 'illuminate'

    illuminate.configure({ delay = 200 })

    local function trigger(dir)
        illuminate["goto_" .. dir .. "_reference"](false)
    end

    local function map2(buffer)
        wk.register({
            ["]]"] = { function() trigger("next") end, "Next reference", mode = "n", buffer = buffer },
            ["[["] = { function() trigger("prev") end, "Prev reference", mode = "n", buffer = buffer },
        })
    end

    -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
    vim.api.nvim_create_autocmd("FileType", {
        callback = function()
            local buffer = vim.api.nvim_get_current_buf()
            map2(buffer)
        end,
    })
end

return M
