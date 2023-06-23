local telescope = require 'telescope'
local winThere = require 'win-there'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'

local M = {}

function M.makeMappings(fn, crOpen)
  local res = {
    ["<C-s>"] = winThere.map_telescope(fn, 'pick'),
    ["<C-v>"] = winThere.map_telescope(fn, 'vsplit'),
    ["<C-x>"] = winThere.map_telescope(fn, 'hsplit')
  }

  if crOpen then
    res["<cr>"] = winThere.map_telescope(fn, "open")
  end

  return res
end

M.setup = function()
  telescope.load_extension('live_grep_args')

  telescope.load_extension("yank_history");

  telescope.setup {
    defaults = {
      layout_config = {
        scroll_speed = 10
      },
      mappings = {
        i = {
          ["<esc>"] = actions.close
        }
      }
    },
    pickers = {
      find_files = {
        mappings = {
          i = M.makeMappings(builtin.find_files),
        }
      },
      live_grep = {
        mappings = {
          i = M.makeMappings(builtin.live_grep)
        }
      },
      buffers = {
        mappings = {
          i = M.makeMappings(builtin.buffers)
        }
      },
      oldfiles = {
        mappings = {
          i = M.makeMappings(builtin.oldfiles)
        }
      }
    },
  }
end

M.live_grep = function(opts)
  opts = opts or {}

  if not opts.mappings then opts.mappings = {} end
  if not opts.mappings.i then opts.mappings.i = {} end

  opts.mappings.i = vim.tbl_extend("force", M.makeMappings(M.live_grep), opts.mappings.i)
  telescope.extensions.live_grep_args.live_grep_args(opts)
end

return M
