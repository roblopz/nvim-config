local function live_grep_glob()
  local state = require 'telescope.actions.state'
  local prompt_input = state.get_current_line()

  vim.ui.input({ prompt = 'glob:' }, function(glob)
    if glob then
      require('telescope.builtin').live_grep {
        default_text = prompt_input,
        glob_pattern = glob,
        prompt_title = string.format('Live Grep: %s', glob),
      }

      vim.api.nvim_buf_set_var(0, 'glob', glob)
    end
  end)
end

local function find_files_glob()
  local state = require 'telescope.actions.state'
  local prompt_input = state.get_current_line()

  vim.ui.input({ prompt = 'glob:' }, function(glob)
    if glob then
      require('telescope.builtin').find_files {
        default_text = prompt_input,
        find_command = { 'rg', '--files', '--glob', glob },
        prompt_title = string.format('Find Files: %s', glob),
      }

      vim.api.nvim_buf_set_var(0, 'glob', glob)
    end
  end)
end

local function find_files_toggle_hidden()
  local state = require 'telescope.actions.state'
  local prompt_input = state.get_current_line()

  local showing_hidden = not (vim.b.hidden_shown or false)
  vim.notify(string.format('Toggle hidden: %s', showing_hidden))
  local glob = vim.b.glob

  local opts = {
    default_text = prompt_input,
    hidden = showing_hidden,
    no_ignore = showing_hidden,
    prompt_title = showing_hidden and 'Find Files (+hidden)' or 'Find Files',
  }

  if glob then
    opts.find_command = { 'rg', '--files', '--glob', glob }
    opts.prompt_title = opts.prompt_title .. string.format(': %s', glob)
  end

  require('telescope.builtin').find_files(opts)
  vim.api.nvim_buf_set_var(0, 'hidden_shown', showing_hidden)
end

local function make_open_win_maps(win_mode, builtin)
  return function(prompt_bufnr)
    local open_win = require 'open-window'
    local state = require 'telescope.actions.state'
    local entry = state.get_selected_entry()

    if not entry then
      vim.notify 'No telescope entry info'
      return
    end

    local bufnr_or_fname = entry.bufnr or entry.path or entry.filename or entry[1]
    local prompt_input = state.get_current_line()

    if not bufnr_or_fname then
      vim.notify 'No telescope bufnr/filename info'
      return
    end

    local open_win_opts = {
      mode = 'pick',
      cb = function(res)
        if not res.opened then
          local opts = { default_text = prompt_input }

          if builtin == 'lsp_references' then
            opts['show_line'] = false
          end

          if type(builtin) == 'string' then
            require('telescope.builtin')[builtin](opts)
          elseif builtin then
            builtin(opts)
          end
        end
      end,
      on_open_set_cursor = { entry.lnum, entry.col },
    }

    if win_mode == 'vsplit' then
      open_win_opts.mode = 'vsplit'
    elseif win_mode == 'hsplit' then
      open_win_opts.mode = 'split'
    end

    require('telescope.actions').close(prompt_bufnr)
    open_win.open(bufnr_or_fname, open_win_opts)
  end
end

local function make_picker_maps(builtin, extra)
  local maps = {
    ['<C-s>'] = make_open_win_maps('pick', builtin),
    ['<C-v>'] = make_open_win_maps('vsplit', builtin),
    ['<C-x>'] = make_open_win_maps('hsplit', builtin),
  }

  if extra then
    maps = vim.tbl_deep_extend('force', maps, extra)
  end

  return {
    i = maps,
    n = maps,
  }
end

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  -- branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-tree/nvim-web-devicons' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  config = function()
    local actions = require 'telescope.actions'

    require('telescope').setup {
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
      defaults = {
        prompt_prefix = ' ',
        selection_caret = ' ',
        layout_strategy = 'vertical',
        sorting_strategy = 'ascending',
        layout_config = {
          scroll_speed = 10,
          prompt_position = 'top',
          mirror = true,
        },
        mappings = {
          i = {
            ['<c-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<c-l>'] = actions.smart_send_to_loclist + actions.open_loclist,
          },
          n = {
            ['<c-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<c-l>'] = actions.smart_send_to_loclist + actions.open_loclist,
          },
        },
      },
      pickers = {
        find_files = {
          mappings = make_picker_maps('find_files', {
            ['<C-f>'] = find_files_glob,
            ['<C-h>'] = find_files_toggle_hidden,
          }),
        },
        live_grep = {
          mappings = make_picker_maps('live_grep', {
            ['<C-f>'] = live_grep_glob,
          }),
        },
        grep_string = {
          mappings = make_picker_maps('grep_string', {
            ['<C-f>'] = live_grep_glob,
          }),
        },
        buffers = {
          mappings = make_picker_maps 'buffers',
        },
        oldfiles = {
          mappings = make_picker_maps 'oldfiles',
        },
        diagnostics = {
          mappings = make_picker_maps 'diagnostics',
        },
        lsp_references = {
          mappings = make_picker_maps 'lsp_references',
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- local builtin = require 'telescope.builtin'
    -- vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
    -- vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
    -- vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F] [G]rep' })
    -- vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
    -- vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
    -- vim.keymap.set('n', '<leader>fo', '<Cmd>Telescope oldfiles cwd_only=true<cr>', { desc = '[F]ind [O]ld files' })
    -- vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })
    -- vim.keymap.set('n', '<leader>fB', builtin.current_buffer_fuzzy_find, { desc = 'Fuzzily search in current [B]uffer' })

    -- vim.keymap.set('n', '<leader>fG', function()
    --   builtin.live_grep {
    --     grep_open_files = true,
    --     prompt_title = 'Live Grep in Open Files',
    --   }
    -- end, { desc = '[F]ind [G]rep in Open Files' })
    --
    -- vim.keymap.set('n', '<leader>fc', function()
    --   builtin.live_grep { cwd = vim.fn.stdpath 'config' }
    -- end, { desc = '[F]ind in [C]onfig files' })

    -- Harpoon

    local telescope_conf = require('telescope.config').values

    local function toggle_telescope()
      local harpoon_files = require('harpoon'):list()
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Harpoon',
          finder = require('telescope.finders').new_table {
            results = file_paths,
          },
          previewer = telescope_conf.file_previewer {},
          sorter = telescope_conf.generic_sorter {},
          attach_mappings = function(_prompt_bufnr, map)
            local maps = make_picker_maps(toggle_telescope)

            for mode, mode_maps in pairs(maps) do
              for key, val in pairs(mode_maps) do
                map(mode, key, val)
              end
            end

            return true
          end,
        })
        :find()
    end

    vim.keymap.set('n', '<leader>fh', function()
      toggle_telescope()
    end, { desc = 'Open harpoon window' })
  end,
}
