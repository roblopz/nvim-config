-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remove lazyvim maps
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-l>")
vim.keymap.del("n", "<C-Up>")
vim.keymap.del("n", "<C-Down>")
vim.keymap.del("n", "<C-Left>")
vim.keymap.del("n", "<C-Right>")
vim.keymap.del("n", "<S-h>")
vim.keymap.del("n", "<S-l>")
vim.keymap.del("n", "[b")
vim.keymap.del("n", "]b")
vim.keymap.del("n", "<leader>bb")
vim.keymap.del("n", "<leader>`")
vim.keymap.del({ "i", "n" }, "<esc>")
vim.keymap.del({ "n", "x" }, "gw")

vim.keymap.del("i", ",")
vim.keymap.del("i", ".")
vim.keymap.del("i", ";")
vim.keymap.del("n", "<leader>K")
vim.keymap.del("n", "<leader>l")
vim.keymap.del("n", "<leader>fn")
vim.keymap.del("n", "<leader>xl")
vim.keymap.del("n", "<leader>xq")
vim.keymap.del("n", "[q")
vim.keymap.del("n", "]q")
vim.keymap.del("n", "<leader>uf")
vim.keymap.del("n", "<leader>us")
vim.keymap.del("n", "<leader>uw")
vim.keymap.del("n", "<leader>ul")
vim.keymap.del("n", "<leader>ud")
vim.keymap.del("n", "<leader>uc")
-- Documented on lazyvim, but not found mappings:
-- vim.keymap.del({ "i", "v", "n", "s" }, "<C-s>")
-- vim.keymap.del("n", "<leader>uh")

local wk = require("which-key")

-- Windows & Quickfix
wk.register({
  ["<leader>qf"] = {
    f = { "<Cmd>copen<CR>", "Focus quickfix window" },
    c = { "<Cmd>cclose<CR>", "Close quickfix window" },
  },
  ["<M-Right>"] = { "<C-w>l", "Window right" },
  ["<M-Left>"] = { "<C-w>h", "Window left" },
  ["<M-Up>"] = { "<C-w>k", "Window up" },
  ["<M-Down>"] = { "<C-w>j", "Window down" },
  ["<C-c>"] = { "<Cmd>close<CR>", "Close window" },
  ["]q"] = { "<Cmd>cn<CR>", "QuickFix down" },
  ["[q"] = { "<Cmd>cp<CR>", "QuickFix up" },
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
  ["<leader>i"] = { "<Cmd>lua require'mini.indentscope'.draw()<CR>", "Set context indent line", mode = "n" },
  ["<leader>I"] = { "<Cmd>lua require'mini.indentscope'.undraw()<CR>", "Unset context indent line", mode = "n" },
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
