local telescope = require 'telescope'
local actions = require 'telescope.actions'
local builtin = require 'telescope.builtin'

local M = {}

local function make_win_map(win_mode, reopen_prompt)
  return function(prompt_bufnr)
    local open_win = require 'open-window'
    local state = require 'telescope.actions.state'
    local entry = state.get_selected_entry()

    if not entry then
      require 'lua.plugins.util'.warn("No telescope entry info")
      return;
    end


    local bufnr_or_fname = entry.bufnr or entry.path or entry.filename;
    local prompt_input = state.get_current_line()

    if not bufnr_or_fname then
      require 'lua.plugins.util'.warn("No telescope bufnr/filename info")
      return;
    end

    local open_win_opts = {
      mode = 'pick',
      cb = function(res)
        if not res.opened then
          reopen_prompt({ default_text = prompt_input })
        end
      end,
      on_open_set_cursor = { entry.lnum, entry.col }
    };

    if win_mode == 'vsplit' then
      open_win_opts.mode = 'split';
      open_win_opts.horizontal = false;
    elseif win_mode == 'hsplit' then
      open_win_opts.mode = 'split';
      open_win_opts.horizontal = true;
    end

    require 'telescope.actions'.close(prompt_bufnr)
    open_win.open(bufnr_or_fname, open_win_opts)
  end
end

M.make_win_mappings = function(telescope_action)
  return {
    ["<C-s>"] = make_win_map('pick', telescope_action),
    ["<C-v>"] = make_win_map('vsplit', telescope_action),
    ["<C-x>"] = make_win_map('hsplit', telescope_action),
    ["<C-q>"] = function(prompt_bufnr)
      vim.cmd('cexpr []')
      actions.add_selected_to_qflist(prompt_bufnr)
      vim.cmd('copen')
    end
  };
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
          i = M.make_win_mappings(builtin.find_files),
        }
      },
      live_grep = {
        mappings = {
          i = M.make_win_mappings(builtin.live_grep)
        }
      },
      buffers = {
        mappings = {
          i = M.make_win_mappings(builtin.buffers)
        }
      },
      oldfiles = {
        mappings = {
          i = M.make_win_mappings(builtin.oldfiles)
        }
      }
    },
  }
end

M.live_grep = function(opts)
  opts = opts or {}

  if not opts.mappings then opts.mappings = {} end
  if not opts.mappings.i then opts.mappings.i = {} end

  opts.mappings.i = vim.tbl_extend("force", M.make_win_mappings(M.live_grep), opts.mappings.i)
  telescope.extensions.live_grep_args.live_grep_args(opts)
end

return M
