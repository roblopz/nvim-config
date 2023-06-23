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
        ["<leader>wo"] = { "<Cmd>WinThere<CR>", "Open current window at..." },
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

    ----------------
    -- Plugin setup
    ----------------

    wk.setup({})

    require 'custom-telescope'.setup()

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

    require 'lualine'.setup {
        options = { theme = 'powerline' },
        -- extensions = { 'nvim-tree', 'quickfix', 'nvim-dap-ui', 'toggleterm' },
        extensions = { 'neo-tree', 'quickfix', 'nvim-dap-ui', 'toggleterm' },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'diagnostics' },
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 1
                }
            },
            lualine_x = { 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {
                {
                    'filename',
                    file_status = true,
                    path = 1
                }
            },
            lualine_x = { 'location' },
            lualine_y = {},
            lualine_z = {}
        },
        winbar = {
            lualine_a = { 'buffers' },
            lualine_b = {},
            lualine_c = { 'filename' },
            lualine_x = {},
            lualine_y = {},
            lualine_z = { 'tabs' }
        },
        inactive_winbar = {
            lualine_a = {'branch' },
            lualine_b = { 'branch' },
            lualine_c = { 'filename' },
            lualine_x = {'branch'},
            lualine_y = {'branch'},
            lualine_z = {'branch'}
        }

    }

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
            timer = 350,
        },
        preserve_cursor_position = { enabled = true }
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
end

return M
