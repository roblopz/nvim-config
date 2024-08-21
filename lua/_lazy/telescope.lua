local function live_grep_glob()
  local state = require 'telescope.actions.state'
  local prompt_input = state.get_current_line()

  vim.ui.input({ prompt = 'glob:' }, function(glob)
    if glob then
      vim.api.nvim_buf_set_var(vim.api.nvim_get_current_buf(), 'grep', glob)

      require('telescope.builtin').live_grep {
        default_text = prompt_input,
        glob_pattern = glob,
        prompt_title = string.format('Live Grep: %s', glob),
      }
    end
  end)
end

local function make_win_map(win_mode, builtin, is_grep)
  return function(prompt_bufnr)
    local open_win = require 'custom.open-window'
    local state = require 'telescope.actions.state'
    local entry = state.get_selected_entry()

    if not entry then
      vim.notify 'No telescope entry info'
      return
    end

    local bufnr_or_fname = entry.bufnr or entry.path or entry.filename
    local prompt_input = state.get_current_line()

    if not bufnr_or_fname then
      vim.notify 'No telescope bufnr/filename info'
      return
    end

    local open_win_opts = {
      mode = 'pick',
      cb = function(res)
        if not res.opened then
          if is_grep then
            local grep = vim.api.nvim_buf_get_var(vim.api.nvim_get_current_buf(), 'grap')
            vim.notify(string.format('var: %s', grep))
          end

          if type(builtin) == 'string' then
            local opts = { default_text = prompt_input }

            if builtin == 'lsp_references' then
              opts['show_line'] = false
            end

            require('telescope.builtin')[builtin](opts)
          elseif builtin then
            builtin { default_text = prompt_input }
          end
        end
      end,
      on_open_set_cursor = { entry.lnum, entry.col },
    }

    if win_mode == 'vsplit' then
      open_win_opts.mode = 'split'
      open_win_opts.horizontal = false
    elseif win_mode == 'hsplit' then
      open_win_opts.mode = 'split'
      open_win_opts.horizontal = true
    end

    require('telescope.actions').close(prompt_bufnr)
    open_win.open(bufnr_or_fname, open_win_opts)
  end
end

local function get_mappings(builtin, with_grep)
  local maps = {
    ['<C-s>'] = make_win_map('pick', builtin, with_grep),
    ['<C-v>'] = make_win_map('vsplit', builtin, with_grep),
    ['<C-x>'] = make_win_map('hsplit', builtin, with_grep),
  }

  if with_grep then
    maps['<C-f>'] = live_grep_glob
  end

  return {
    i = maps,
    n = maps,
  }
end

return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-tree/nvim-web-devicons' },
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
          mappings = get_mappings 'find_files',
        },
        live_grep = {
          mappings = get_mappings('live_grep', true),
        },
        grep_string = {
          mappings = get_mappings 'grep_string',
        },
        buffers = {
          mappings = get_mappings 'buffers',
        },
        oldfiles = {
          mappings = get_mappings 'oldfiles',
        },
        diagnostics = {
          mappings = get_mappings 'diagnostics',
        },
        lsp_references = {
          mappings = get_mappings 'lsp_references',
        },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = '[F]ind [F]iles' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind current [W]ord' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F] [G]rep' })
    vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = '[F]ind [D]iagnostics' })
    vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
    vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = '[F]ind [O]ld files' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[F]ind [B]uffers' })

    vim.keymap.set('n', '<leader>f/', function()
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>fG', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[F]ind [G]rep in Open Files' })

    vim.keymap.set('n', '<leader>fc', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[F]ind in [C]onfig files' })

    vim.keymap.set('n', '<leader>fz', function()
      local vimgrep_arguments = { 'rg', '-g', '**/*.json*' }
      require('telescope.builtin').live_grep { vimgrep_arguments = vimgrep_arguments }
    end, { desc = 'Telescope test' })
  end,
}
