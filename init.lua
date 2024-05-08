local config_path = vim.fn.stdpath('config')

-- Load configs in vim format
vim.cmd(string.format("source %s", config_path .. "/config.vim"))

-- Helper for plugin spec
_G.plugin_module = function(name)
  return config_path .. '/lua/' .. name;
end

_G.log = function (...)
  print(vim.inspect(...))
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
require("lazy").setup("_lazy")
