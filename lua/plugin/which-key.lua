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

    -- Special commands (some map from terminal emmulator)
  wk.register({
    ["<C-space>"] = { "<Cmd>Lspsaga hover_doc<CR>", "Hover docs", mode = "n" },
    ["<C-h>"] = { "<Cmd>Lspsaga hover_doc ++keep<CR>", "Hover docs and keep", mode = "n" },
    ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "n" }, -- <Cmd-w>
    ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "n" }, -- <Cmd-A-w>
    ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "n" }, -- <A-S-f>
    ["ã-3"] = { "<Cmd>lua require'lsp_signature'.toggle_float_win()<CR>", "Formatting", mode = "n" }, -- <A-Space>
    ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "n" }, -- <A-S-e>
    ["ã-5"] = { "<Cmd>Lspsaga code_action<CR>", "Code Action", mode = "n" }, -- <Cmd-.>
    ["ã-6"] = { "<Cmd>Lspsaga rename<CR>", "Rename", mode = "n" }, -- F2
  })

  wk.register({
    ["ã-0"] = { "<Cmd>w<CR>", "Save", mode = "i" },
    ["ã-1"] = { "<Cmd>wa<CR>", "Save", mode = "i" },
    ["ã-2"] = { "<Cmd>lua vim.lsp.buf.format()<CR>", "Formatting", mode = "i" },
    ["ã-4"] = { "<Cmd>ESLintFix<CR>", "Lint", mode = "i" },
  })


  end
}
