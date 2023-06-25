local M = {}

M.init = function()
  -- Yanky mappings
  vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
  vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
  vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
  vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
  vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
  vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")
  vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
  vim.keymap.set("n", "=p", "<Plug>(YankyPutAfterFilter)")
  vim.keymap.set("n", "=P", "<Plug>(YankyPutBeforeFilter)")

  -- Substitute mappings
  vim.keymap.set("n", "s", require('substitute').operator, { noremap = true })
  vim.keymap.set("n", "ss", require('substitute').line, { noremap = true })
  vim.keymap.set("n", "S", require('substitute').eol, { noremap = true })
  vim.keymap.set("x", "s", require('substitute').visual, { noremap = true })

  local wk = require 'which-key'

  -- Windows & Quickfix
  wk.register({
    ["<leader>wo"] = { "<Cmd>lua require'win-there'.open(vim.fn.getbufinfo()[1].bufnr)<CR>", "Open current window at..." },
    ["<leader>qf"] = {
      f = { "<Cmd>copen<CR>", "Focus quickfix window" },
      c = { "<Cmd>cclose<CR>", "Close quickfix window" }
    },
    ["<M-Right>"] = { "<C-w>l", "Window right" },
    ["<M-Left>"] = { "<C-w>h", "Window left" },
    ["<M-Up>"] = { "<C-w>k", "Window up" },
    ["<M-Down>"] = { "<C-w>j", "Window down" },
    ["<C-c>"] = { "<Cmd>close<CR>", "Close window" },
    ["]q"] = { "<Cmd>cn<CR>", "QuickFix down" },
    ["[q"] = { "<Cmd>cp<CR>", "QuickFix up" }
  })

  -- Misc
  wk.register({
    ["<leader>"] = {
      ["<space>"] = { "<Cmd>nohlsearch<CR>", "Toggle off highlight search" },
      ["o"] = { "o<Esc>", "(n) Insert blank line below" },
      ["O"] = { "O<Esc>", "(n) Insert blank line above" },
    },
    ["<S-Up>"] = { "<S-v><Up>", "Enter l-visual up" },
    ["<S-Down>"] = { "<S-v><Down>", "Enter l-visual down" },
  })

  -- Telescope and vim.select
  wk.register({
    name = "Telescope...",
    f = { "<Cmd>lua require'telescope.builtin'.find_files() <CR>", "Find files" },
    g = { "<Cmd>lua require'custom-telescope'.live_grep()<CR>", "Live grep" },
    b = { "<Cmd>lua require'telescope.builtin'.buffers() <CR>", "Buffers" },
    r = { "<Cmd>lua require'telescope.builtin'.registers() <CR>", "Registers" },
    o = { "<Cmd>lua require'telescope.builtin'.oldfiles() <CR>", "Recents" },
    c = { "<Cmd>Telescope yank_history<CR>", "Telescope yank ring" },
    y = { "<Cmd>YankyRingHistory<CR>", "Prompt yank ring" }
  }, { prefix = "<leader>f" })

  wk.register({
    ["t"] = { "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'left' })<CR>", "Toggle Tree" },
    ["f"] = { "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'left' })<CR>", "Focus File" },
    ["o"] = { "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'float' })<CR>", "Toggle Tree" },
    ["p"] = { "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float' })<CR>", "Focus File" },
    ["b"] = {
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
      "Buffers" },
    ["g"] = {
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'git_status' })<CR>",
      "Git" }
  }, { prefix = "<leader>t" })

  -- Coding diagnostics
  wk.register({
    ["]e"] = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "Diagnostics Next" },
    ["[e"] = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diagnostics Prev" },
    ["]E"] = {
      function() require 'lspsaga.diagnostic':goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
      "Go to next error"
    },
    ["[E"] = {
      function() require 'lspsaga.diagnostic':goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
      "Go to prev error"
    },
    ["<leader>eq"] = { "<Cmd>lua vim.diagnostic.setqflist()<CR>", "Diagnostics to quickfix" },
    ["<leader>el"] = { "<cmd>Lspsaga show_line_diagnostics<CR>", "Line Diagnostics" },
    ["<leader>eb"] = { "<cmd>Lspsaga show_buf_diagnostics<CR>", "Buffer Diagnostics" },
    ["<leader>ew"] = { "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Workspace Diagnostics" },
  })

  -- Special commands (some map from terminal emmulator)
  wk.register({
    ["<C-space>"] = { "<Cmd>Lspsaga hover_doc<CR>", "Hover docs", mode = "n" },
    ["<C-h>"] = { "<Cmd>Lspsaga hover_doc ++keep<CR>", "Hover docs and keep", mode = "n" },
    ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "n" },                                                  -- <Cmd-w>
    ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "n" },                                                 -- <Cmd-A-w>
    ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "n" },                     -- <A-S-f>
    ["ã-3"] = { "<Cmd>lua require'lsp_signature'.toggle_float_win()<CR>", "Formatting", mode = "n" }, -- <A-Space>
    ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "n" },                                          -- <A-S-e>
    ["ã-5"] = { "<Cmd>Lspsaga code_action<CR>", "Code Action", mode = "n" },                         -- <Cmd-.>
    ["ã-6"] = { "<Cmd>Lspsaga rename<CR>", "Rename", mode = "n" },                                   -- F2
  })
  wk.register({
    ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "i" },
    ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "i" },
    ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "i" },
    ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "i" },
  })

  -- LSP
  wk.register({
    ["gd"] = {
      name = "Definition",
      g = { "<Cmd>lua vim.lsp.buf.type_definition()<CR>", "Go to type definition" },
      p = { "<Cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", "Preview type definition" },
      v = { "<Cmd>lua require('custom-lsp.keymaps').go_to_definition({ mode = 'vsplit' })<CR>", "Win-Open vsplit" },
      s = { "<Cmd>lua require('custom-lsp.keymaps').go_to_definition({ mode = 'pick' })<CR>", "Win-Open pick" },
      x = { "<Cmd>lua require('custom-lsp.keymaps').go_to_definition({ mode = 'hsplit' })<CR>", "Win-Open hsplit" }
    },
    ["gr"] = {
      p = { "<Cmd>lua require('goto-preview').goto_preview_references()<CR>", "Preview references" },
      q = { "<Cmd>lua vim.lsp.buf.references()<CR>", "Quickfix references" },
    },
    ["gh"] = { "<cmd>Lspsaga lsp_finder<CR>", "LSP def info" }
  })

  ----------------
  -- Plugin setup
  ----------------

  wk.setup({})

  require 'custom-telescope'.setup()

  require('kanagawa').setup({
    transparent = true,
    terminalColors = true,
    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },

        -- Save an hlgroup with dark background and dimmed foreground
        -- so that you can use it where your still want darker windows.
        -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

        -- Popular plugins that open floats will link to NormalFloat by default;
        -- set their background accordingly if you wish to keep them dark and borderless
        LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
        MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
      }
    end,
    colors = {
      theme = {
        all = {
          ui = {
            bg_gutter = "none"
          }
        }
      }
    }
  })

  vim.cmd("colorscheme kanagawa-wave");
  local palette_colors = require("kanagawa.colors").setup().palette

  vim.cmd('hi Visual guibg=#314768')

  vim.cmd(string.format("hi DiagnosticError guifg=%s", palette_colors.peachRed))
  vim.cmd(string.format("hi DiagnosticWarn guifg=%s", palette_colors.carpYellow))
  vim.cmd(string.format("hi DiagnosticInfo guifg=%s", palette_colors.waveAqua2))
  vim.cmd(string.format("hi DiagnosticHint guifg=%s", palette_colors.autumnGreen))

  vim.fn.sign_define("DiagnosticSignError", { text = "E", texthl = "DiagnosticError" })
  vim.fn.sign_define("DiagnosticsSigWarning", { text = "W", texthl = "DiagnosticWarn" })
  vim.fn.sign_define("DiagnosticsSigInformation", { text = "I ", texthl = "DiagnosticInfo" })
  vim.fn.sign_define("DiagnosticSignHint", { text = "H", texthl = "DiagnosticHint" })

  require("neo-tree").setup({
    enable_git_status = false,
    enable_diagnostics = true,
    open_files_do_not_replace_types = { "terminal", "trouble", "qf" },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      name = {
        trailing_slash = false,
        use_git_status_colors = false,
        highlight = "NeoTreeFileName",
      },
      git_status = {
        symbols = {
          -- Change type
          added     = "",
          modified  = "",
          deleted   = "✖",
          renamed   = "",
          -- Status type
          untracked = "",
          ignored   = "",
          unstaged  = "",
          staged    = "",
          conflict  = "",
        }
      },
      diagnostics = {
        symbols = {
          error = "",
          warn = "",
          info = " ",
          hint = "",
        },
        highlights = {
          error = "DiagnosticError",
          hint  = "DiagnosticHint",
          info  = "DiagnosticInfo",
          warn  = "DiagnosticWarn",
        },
      },
    },
    window = {
      position = "left",
      width = 40,
      mappings = {
        ["<space>"] = {
          "toggle_node",
          nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
        },
        ["P"] = { "toggle_preview", config = { use_float = true } },
        ["<esc>"] = "revert_preview",
        ["l"] = "focus_preview",
        ["<cr>"] = "open",
        ["<C-s>"] = "open_with_window_picker",
        ["<C-v>"] = "vsplit_with_window_picker",
        ["<C-x>"] = "split_with_window_picker",
        ["C"] = "close_node",
        ["z"] = "close_all_nodes",
        ["a"] = {
          "add",
          -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
          -- some commands may take optional config options, see `:h neo-tree-mappings` for details
          config = {
            show_path = "none" -- "none", "relative", "absolute"
          }
        },
        ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["c"] = {
          "copy",
          config = { show_path = "relative" },
        },
        ["m"] = {
          "move",
          config = { show_path = "relative" },
        },
        ["q"] = "close_window",
        ["R"] = "refresh",
        ["?"] = "show_help",
        ["<"] = "prev_source",
        [">"] = "next_source",
      }
    },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = false,
      window = {
        mappings = {
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
          ["H"] = "toggle_hidden",
          ["/"] = "fuzzy_finder",
          ["D"] = "fuzzy_finder_directory",
          ["#"] = "fuzzy_sorter",
          ["f"] = "filter_on_submit",
          ["F"] = "clear_filter",
          ["[g"] = "prev_git_modified",
          ["]g"] = "next_git_modified",
        },
        fuzzy_finder_mappings = {
          ["<down>"] = "move_cursor_down",
          ["<C-n>"] = "move_cursor_down",
          ["<up>"] = "move_cursor_up",
          ["<C-p>"] = "move_cursor_up",
        },
      }
    },
    buffers = {
      follow_current_file = true,
      group_empty_dirs = true,
      show_unloaded = true,
      window = {
        mappings = {
          ["bd"] = "buffer_delete",
          ["<bs>"] = "navigate_up",
          ["."] = "set_root",
        }
      },
    },
    git_status = {
      window = {
        position = "float",
        mappings = {
          ["A"]  = "git_add_all",
          ["gu"] = "git_unstage_file",
          ["ga"] = "git_add_file",
          ["gr"] = "git_revert_file",
          ["gc"] = "git_commit",
          ["gp"] = "git_push",
          ["gg"] = "git_commit_and_push",
        }
      }
    }
  })

  require 'custom-lualine'.setup()

  require 'window-picker'.setup {
    include_current_win = true,
    selection_chars = 'ABCDEFGHIJKLMNOPQRSTUVXYZ',
    current_win_hl_color = '#4493c8',
    other_win_hl_color = '#54aeeb',
    filter_rules = {
      bo = {
        filetype = require 'win-there'.excludeWinFileTypes,
        buftype = { 'terminal' }
      }
    }
  }

  require 'yanky'.setup {
    ring = {
      history_length = 20,
      storage = "shada",
      sync_with_numbered_registers = true,
      cancel_event = "update",
    },
    system_clipboard = {
      sync_with_ring = true,
    },
    highlight = {
      on_put = true,
      on_yank = true,
      timer = 400,
    },
    preserve_cursor_position = { enabled = true }
  }

  require 'substitute'.setup {
    on_substitute = require("yanky.integration").substitute(),
    yank_substituted_text = false,
    highlight_substituted_text = {
      enabled = true,
      timer = 400,
    },
    range = {
      prefix = "s",
      prompt_current_text = false,
      confirm = false,
      complete_word = false,
      motion1 = false,
      motion2 = false,
      suffix = "",
    },
    exchange = {
      motion = false,
      use_esc_to_cancel = true,
    },
  }

  require 'substitute'.setup {
    on_substitute = require("yanky.integration").substitute(),
    yank_substituted_text = false,
    highlight_substituted_text = {
      enabled = true,
      timer = 350,
    },
    range = {
      prefix = "s",
      prompt_current_text = false,
      confirm = false,
      complete_word = false,
      motion1 = false,
      motion2 = false,
      suffix = "",
    },
    exchange = {
      motion = false,
      use_esc_to_cancel = true,
    },
  }

  require 'custom-bqf'.setup()

  require 'nvim-autopairs'.setup {
    check_ts = true
  }

  local animate = require 'mini.animate'
  animate.setup({
    cursor = {
      enable = true,
      timing = animate.gen_timing.linear({ duration = 150, unit = 'total' })
    },
    scroll = {
      enable = false,
    },
    resize = {
      enable = true,
      timing = animate.gen_timing.linear({ duration = 100, unit = 'total' })
    },
    open = {
      enable = false,
    },
    close = {
      enable = false,
    },
  })

  require 'neoscroll'.setup {
    performance_mode = false,
    hide_cursor = false,         -- Hide cursor while scrolling
    stop_eof = true,             -- Stop at <EOF> when scrolling downwards
    respect_scrolloff = true,    -- Stop scrolling when the cursor reaches the scrolloff margin of the file
    cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  }

  require 'indent_blankline'.setup({
    char = "│",
    filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
    show_trailing_blankline_indent = false,
    show_current_context = false,
  })

  local miniIndentScope = require 'mini.indentscope'
  require 'mini.indentscope'.setup({
    symbol = "│",
    draw = {
      delay = 100,
      animation = miniIndentScope.gen_animation.none()
    },
    options = { try_as_border = true },
  })

  require 'custom-illuminate'.setup()

  require("mason").setup()

  require("mason-lspconfig").setup()

  require 'custom-lsp'.setup()

  require 'nvim-treesitter.configs'.setup({
    highlight = {
      enable = true,
    },
    indent = {
      enable = true
    },
    autotag = {
      enable = true,
    },
    context_commentstring = { enable = true, enable_autocmd = false },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<tab>v",
        node_incremental = "<tab>v",
        scope_incremental = "<nop>",
        node_decremental = "<bs>",
      },
    },
    textobjects = {
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]F"] = { query = "@function.inner", desc = "Next start of function inner" },
          ["]f"] = { query = "@function.outer", desc = "Next start of function outer", },
        },
        goto_previous_start = {
          ["[F"] = { query = "@function.inner", desc = "Next end of function inner" },
          ["[f"] = { query = "@function.outer", desc = "Next end of function outer", },
        },
      },
    },
  })

  require 'mini.comment'.setup {
    hooks = {
      pre = function()
        require("ts_context_commentstring.internal").update_commentstring({})
      end,
    },
  }

  local nullLs = require 'null-ls'
  nullLs.setup {
    sources = {
      nullLs.builtins.code_actions.eslint_d,
      nullLs.builtins.diagnostics.eslint_d,
      nullLs.builtins.formatting.prettier
    }
  }

  require 'custom-goto-preview'.setup()

  require("nvim-surround").setup()

  vim.api.nvim_create_user_command("ESLintFix", function()
    local uv = vim.loop
    local stdout = assert(uv.new_pipe(false), "Must be able to create pipe")
    local stderr = assert(uv.new_pipe(false), "Must be able to create pipe")

    vim.cmd("silent w")
    handle, pid_or_err = uv.spawn('npx', {
      args = { 'eslint_d', '--fix', string.format("%s", vim.fn.expand('%')) },
      stdio = { nil, stdout, stderr },
      cwd = vim.fn.getcwd(),
      detached = false
    }, function()
      if handle and not handle:is_closing() then
        handle:close()
      end

      vim.schedule(function()
        stdout:read_stop()
        stderr:read_stop()
        stdout:close()
        stderr:close()
        vim.cmd("checktime")
      end
      )
    end)

    if not handle then
      stdout:close()
      stderr:close()
      vim.notify('Error running eslint: ' .. pid_or_err, vim.log.levels.ERROR)
    end
  end, { desc = "Run esling fix on current file" })

  -- Clean unopened buffers
  vim.api.nvim_create_user_command("BufClean", function()
    local bufrs = vim.fn.getbufinfo({ bufloaded = 1, buflisted = 1 })
    for _, buf in pairs(bufrs) do
      if buf.hidden == 1 then
        vim.cmd(string.format('%sbd', buf.bufnr))
      end
    end
  end, { bang = true, desc = "Close hidden buffers" })
end

return M
