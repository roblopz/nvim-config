-- Set global cwd to this path
_G.cwd = require 'plugin.util'.dirname()

-- Load configs in vim format
vim.cmd(string.format("source %s", _G.cwd .. "config.vim"))

--[[ Load lazy --]]

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup("spec")
