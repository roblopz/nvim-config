-- Load configs in vim format
vim.cmd(string.format("source %s", vim.fn.stdpath('config') .. "/config.vim"))

-- Helper for plugin spec
_G.plugin_module = function(name)
  return vim.fn.stdpath('config') .. '/lua/custom-plugin/' .. name;
end

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
require("lazy").setup("_plugins")
