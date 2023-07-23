return {
  dir = "",
  name = "vim-config",
  init = function()
    vim.cmd("source ~/.config/nvim/config.vim")
  end,
}
