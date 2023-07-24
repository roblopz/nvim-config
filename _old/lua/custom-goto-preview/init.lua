local M = {}

local function minimize_win(winid)
  local o_width = vim.api.nvim_win_get_width(winid)
  local o_height = vim.api.nvim_win_get_height(winid)

  vim.api.nvim_win_set_width(winid, 40)
  vim.api.nvim_win_set_height(winid, 1)

  -- Return restore fn
  return function()
    vim.api.nvim_win_set_width(winid, o_width)
    vim.api.nvim_win_set_height(winid, o_height)
  end
end

local function set_open_win_maps(bufnr, winid, keymap, open_win_opts)
  vim.keymap.set(
    'n',
    keymap,
    function()
      local restore_win = minimize_win(winid)

      open_win_opts.cb = function (res)
        if (res.opened) then
            vim.api.nvim_win_close(winid, true)
        else
            restore_win()
        end
      end

      open_win_opts.on_open_set_cursor = vim.api.nvim_win_get_cursor(winid)

      require 'open-window'.open(bufnr, open_win_opts)
    end,
    { buffer = bufnr }
  )
end

local function clear_all(bufnr, cmdid)
  vim.keymap.del("n", "<c-v>", { buffer = bufnr })
  vim.keymap.del("n", "<c-x>", { buffer = bufnr })
  vim.keymap.del("n", "<c-s>", { buffer = bufnr })
  vim.keymap.del("n", "<c-o>", { buffer = bufnr })
  vim.api.nvim_del_autocmd(cmdid)
end

function M.setup()
  require('goto-preview').setup({
    width = 160,
    height = 40,
    opacity = nil,
    resizing_mappings = false,
    focus_on_open = true,
    dismiss_on_move = false,
    post_open_hook = function(bufnr, winid)
      vim.api.nvim_create_autocmd({ 'WinClosed' }, {
        callback = function(ev)
          local is_match = tostring(ev.match) == tostring(winid)

          if is_match then
            if not pcall(clear_all, bufnr, ev.id) then
              vim.notify('Error clearing floating window events', vim.log.levels.WARN);
            end
          end
        end
      })

      set_open_win_maps(bufnr, winid, '<c-v>', { mode = "split" })
      set_open_win_maps(bufnr, winid, '<c-x>', { mode = "split", horizontal = true })
      set_open_win_maps(bufnr, winid, '<c-s>', { mode = "pick" })
      -- set_open_win_maps(bufnr, winid, '<c-o>', { 'open' }, bufnr, winid)
    end,
    references = {
      telescope = require 'telescope.themes'.get_dropdown({
        results_title = "References",
        winblend = 0,
        layout_strategy = "horizontal",
        show_line = false,
        layout_config = {
          preview_cutoff = 1, -- Preview should always show (unless previewer = false)

          width = function(_, max_columns, _)
            return math.min(max_columns, 220)
          end,

          height = function(_, _, max_lines)
            return math.min(max_lines, 50)
          end,

          prompt_position = "bottom"
        },
        attach_mappings = function(_, map)
          local mappings = require 'custom-telescope'.make_win_mappings(
            function(reopen_prompt_args)
              require('goto-preview').goto_preview_references(reopen_prompt_args)
            end
          )

          for mapKey, mapFn in pairs(mappings) do
            map("i", mapKey, mapFn)
          end

          return true
        end
      })
    }
  })
end

return M;
