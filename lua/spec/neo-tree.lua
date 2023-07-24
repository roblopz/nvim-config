return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    {
      "<leader>tt",
      "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'left' })<CR>",
      "Toggle Tree",
    },
    {
      "<leader>tf",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'left' })<CR>",
      "Focus File",
    },
    {
      "<leader>to",
      "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'float' })<CR>",
      "Toggle Tree Float",
    },
    {
      "<leader>tp",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float' })<CR>",
      "Focus File Float",
    },
    {
      "<leader>tb",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
      "Tree buffers",
    },
    {
      "<leader>tg",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
      "Tree Git Status",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- Open tree at init
    vim.fn.timer_start(1, function()
      vim.cmd('Neotree show')
    end)
  end,
  opts = {
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
      follow_current_file = {
        enabled = false
      },
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
      follow_current_file = {
        enabled = true
      },
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
  }
}
