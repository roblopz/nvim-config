local spec = {
  require '_lazy.editor.yanky',
  require '_lazy.editor.substitute',
  require '_lazy.editor.surround',
  require '_lazy.editor.flash',
  require '_lazy.editor.folds',
  require '_lazy.editor.cmp',

  {
    'windwp/nvim-autopairs',
    opts = { check_ts = true },
  },
  {
    'windwp/nvim-ts-autotag',
    config = true,
  },
}

vim.list_extend(spec, require '_lazy.editor.treesitter')

return spec
