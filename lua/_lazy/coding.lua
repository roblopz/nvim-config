return {
  {
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      -- Integrate with native comments rather than setup the plugin
      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option)
        return option == 'commentstring' and require('ts_context_commentstring.internal').calculate_commentstring() or get_option(filetype, option)
      end
    end,
  },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        -- M+S+f
        'ã-2',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
      {
        'ã-4',
        function()
          -- Check eslint first

          local lsp_clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
          local lsp_client_names = {}

          for _, client in ipairs(lsp_clients) do
            lsp_client_names[#lsp_client_names + 1] = client.name
          end

          if vim.tbl_contains(lsp_client_names, 'eslint') then
            vim.cmd 'silent EslintFixAll'
          else
            require('conform').format { async = true, lsp_fallback = true }
          end
        end,
        mode = '',
        desc = '[E]slint / Format',
      },
    },
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    config = true,
  },
  {
    'windwp/nvim-autopairs',
    opts = { check_ts = true },
  },
  {
    'RRethy/vim-illuminate',
    event = 'BufEnter',
    keys = {
      {
        ']]',
        function()
          require('illuminate').goto_next_reference(false)
        end,
        mode = '',
        desc = 'Next token reference',
      },
      {
        '[[',
        function()
          require('illuminate').goto_prev_reference(false)
        end,
        mode = '',
        desc = 'Prev token reference',
      },
    },
    config = function()
      require('illuminate').configure {
        filetypes_denylist = {
          'qf',
        },
      }

      vim.api.nvim_create_user_command('ToggleFreezeReferences', function()
        require('illuminate').toggle_freeze_buf(false)
      end, { desc = 'Toggle buffere freeze references highlight' })
    end,
  },
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    opts = {
      keymaps = {
        normal = 'ys', -- Surround by motion (ysiw)
        normal_cur_line = 'yS', -- Surround current line adding above/below line
        visual = 'S', -- Surround selection
        visual_line = 'gS', -- Surround selection adding above/below line
        delete = 'ds',
        change = 'cs',
        normal_cur = false, -- Surround current line
        change_line = false,
        insert = false,
        insert_line = false,
        normal_line = false, -- Surround by motion (i.e. iw) and add above/below,
      },
      surrounds = {
        ['j'] = {
          add = { '{/* ', ' */}' },
        },
      },
    },
    config = function(_, opts)
      require('nvim-surround').setup(opts)
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = {
        char = '│',
      },
    },
  },
  -- Indentation
  {
    'echasnovski/mini.indentscope',
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      draw = {
        animation = function()
          return 5
        end,
      },
      symbol = '│',
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = {
          'help',
          'alpha',
          'dashboard',
          'neo-tree',
          'Trouble',
          'trouble',
          'lazy',
          'mason',
          'notify',
          'toggleterm',
          'lazyterm',
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      label = {
        style = 'overlay',
        rainbow = {
          enabled = true,
          shade = 5,
        },
      },
      modes = {
        search = {
          enabled = false,
          highlight = { backdrop = true },
        },
        char = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        'gs',
        mode = { 'n', 'x', 'o' },
        function()
          require('flash').jump()
        end,
        desc = 'Flash jump',
      },
      {
        'gS',
        mode = { 'n', 'o', 'x' },
        function()
          require('flash').treesitter()
        end,
        desc = 'Treesitter select',
      },
    },
  },
}
