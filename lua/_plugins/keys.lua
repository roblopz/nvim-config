return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    local wk = require("which-key")

    -- Windows & Quickfix
    wk.register({
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

    -- Special commands (some map from terminal emmulator) - n
    wk.register({
      ["<C-space>"] = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover docs", mode = "n" },
      -- ["<C-h>"] = { "<Cmd>Lspsaga hover_doc ++keep<CR>", "Hover docs and keep", mode = "n" },
      ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "n" },                                                      -- <Cmd-w>
      ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "n" },                                                     -- <Cmd-A-w>
      ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "n" },                         -- <A-S-f>
      ["ã-3"] = { "<Cmd>lua require'lsp_signature'.toggle_float_win()<CR>", "Signature toggle", mode = "n" }, -- <A-Space>
      ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "n" },                                              -- <A-S-e>
      ["ã-5"] = { "<Cmd>lua vim.lsp.buf.code_action()<CR>", "Code Action", mode = "n" },                   -- <Cmd-.>
      ["ã-6"] = { "<Cmd>lua vim.lsp.buf.rename()<CR>", "Rename", mode = "n" },                             -- F2
    })

    -- Special commands (some map from terminal emmulator) - i
    wk.register({
      ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "i" },
      ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "i" },
      ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "i" },
      ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "i" },
    })

    -- LSP diagnostics
    wk.register({
      ["]d"] = { "<cmd>Lspsaga diagnostic_jump_next<CR>", "Diagnostics Next" },
      ["[d"] = { "<cmd>Lspsaga diagnostic_jump_prev<CR>", "Diagnostics Prev" },
      ["]D"] = {
        function() require 'lspsaga.diagnostic':goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
        "Go to next error"
      },
      ["[D"] = {
        function() require 'lspsaga.diagnostic':goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
        "Go to prev error"
      },
      ["<leader>dq"] = { "<Cmd>lua vim.diagnostic.setqflist()<CR>", "Diagnostics to quickfix" },
      ["<leader>dl"] = { "<cmd>Lspsaga show_line_diagnostics<CR>", "Line Diagnostics" },
      ["<leader>db"] = { "<cmd>Lspsaga show_buf_diagnostics<CR>", "Buffer Diagnostics" },
      ["<leader>dw"] = { "<cmd>Lspsaga show_workspace_diagnostics<CR>", "Workspace Diagnostics" },
    })
  end
}
