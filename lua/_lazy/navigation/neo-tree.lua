local function is_target_buf(buf, abs_path)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == nil or name == '' then
    return false
  end

  return vim.fn.fnamemodify(name, ':p') == abs_path
end

local function clean_deleted_buf(path)
  local abs_path = vim.fn.fnamemodify(path, ':p')

  -- 1) Close any windows (across all tabs) showing the buffer(s)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local b = vim.api.nvim_win_get_buf(win)
      if is_target_buf(b, abs_path) then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end

  -- 2) Wipe matching buffers from the buffer list
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if is_target_buf(b, abs_path) then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end
end

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim',
  },
  keys = {
    {
      '<leader>tt',
      "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'left' })<CR>",
      desc = 'Toggle [T]ree',
    },
    {
      '<leader>tf',
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'left' })<CR>",
      desc = 'Tree [F]ocus file',
    },
    {
      '<leader>too',
      function()
        local nt = require 'neo-tree.command'
        -- nt.execute({ action = "close" })
        nt.execute { position = 'float' }
      end,
      desc = '[O]pen float tree',
    },
    {
      '<leader>tof',
      function()
        local nt = require 'neo-tree.command'
        -- nt.execute({ action = "close" })
        nt.execute { position = 'float', reveal = true }
      end,
      desc = '[O]pen float tree and [F]ocus file',
    },
  },
  config = function()
    local function getTelescopeOpts(state, path)
      return {
        cwd = path,
        search_dirs = { path },
        attach_mappings = function(prompt_bufnr)
          local actions = require 'telescope.actions'
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local action_state = require 'telescope.actions.state'
            local selection = action_state.get_selected_entry()
            local filename = selection.filename
            if filename == nil then
              filename = selection[1]
            end
            -- any way to open the file without triggering auto-close event of neo-tree?
            require('neo-tree.sources.filesystem').navigate(state, state.path, filename)
          end)
          return true
        end,
      }
    end

    require('neo-tree').setup {
      enable_git_status = false,
      enable_diagnostics = false,
      window = {
        mappings = {
          ['z'] = 'none',
          ['Z'] = 'close_all_nodes',
          ['zc'] = 'close_node',
          ['<C-v>'] = 'vsplit',
          ['<C-x>'] = 'split',
          ['<C-s>'] = 'pick',
          ['f'] = 'telescope_find',
          ['g'] = 'telescope_grep',
          ['<C-o>'] = 'system_open',
        },
      },
      commands = {
        telescope_find = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          if node.type == 'directory' then
            require('telescope.builtin').find_files(getTelescopeOpts(state, path))
          end
        end,
        telescope_grep = function(state)
          local node = state.tree:get_node()

          if node.type == 'directory' then
            local path = node:get_id()
            require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
          end
        end,
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          if node.type == 'file' then
            path = vim.fn.fnamemodify(path, ':h')
          end

          vim.notify(string.format('System opening %s', path))
          vim.fn.jobstart({ 'open', '-a', 'Finder', path }, { detach = true })
        end,
        vsplit = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          if path and node.type == 'file' then
            require('open-window').open(path, { mode = 'vsplit' })
          end
        end,
        split = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          if path and node.type == 'file' then
            require('open-window').open(path, { mode = 'split' })
          end
        end,
        pick = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()

          if path and node.type == 'file' then
            require('open-window').open(path, { mode = 'pick' })
          end
        end,
      },
      filesystem = {
        commands = {
          delete = function(state)
            local inputs = require 'neo-tree.ui.inputs'
            local path = state.tree:get_node().path
            local msg = 'Are you sure you want to trash ' .. path

            inputs.confirm(msg, function(confirmed)
              if not confirmed then
                return
              end

              vim.fn.system { 'trash', vim.fn.fnameescape(path) }
              clean_deleted_buf(path)
              require('neo-tree.sources.manager').refresh(state.name)
            end)
          end,

          -- over write default 'delete_visual' command to 'trash' x n.
          delete_visual = function(state, selected_nodes)
            local inputs = require 'neo-tree.ui.inputs'

            -- get table items count
            local function get_table_len(tbl)
              local len = 0
              for _ in pairs(tbl) do
                len = len + 1
              end
              return len
            end

            local count = get_table_len(selected_nodes)
            local msg = 'Are you sure you want to trash ' .. count .. ' files ?'

            inputs.confirm(msg, function(confirmed)
              if not confirmed then
                return
              end

              for _, node in ipairs(selected_nodes) do
                vim.fn.system { 'trash', vim.fn.fnameescape(node.path) }
                clean_deleted_buf(node.path)
              end

              require('neo-tree.sources.manager').refresh(state.name)
            end)
          end,
        },
      },
    }
  end,
}
