return {
  'kevinhwang91/nvim-ufo',
  dependencies = { 'kevinhwang91/promise-async' },
  config = function()
    vim.o.foldcolumn = '0'
    vim.o.foldlevel = 20
    vim.o.foldlevelstart = 20
    vim.o.foldenable = true
    require('ufo').setup()

    vim.keymap.set('n', 'zR', "<cmd>lua require'ufo'.openAllFolds()<CR>")
    vim.keymap.set('n', 'zM', "<cmd>lua require'ufo'.closeAllFolds()<CR>")
    vim.keymap.set('n', 'zr', "<cmd>lua require'ufo'.openFoldsExceptKinds()<CR>")
    vim.keymap.set('n', 'zm', "<cmd>lua require'ufo'.closeFoldsWith()<CR>")
    vim.keymap.set('n', 'zp', "<cmd>lua require'ufo'.peekFoldedLinesUnderCursor()<CR>")
  end,
}
