return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    {
      "<leader>tt",
      "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'left' })<CR>",
      "Toggle Tree",
    },
    {
      "<leader>tf",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'left' })<CR>",
      "Focus File",
    },
    {
      "<leader>to",
      "<Cmd>lua require'neo-tree.command'.execute({ toggle = true, position = 'float' })<CR>",
      "Toggle Tree Float",
    },
    {
      "<leader>tp",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float' })<CR>",
      "Focus File Float",
    },
    {
      "<leader>tb",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
      "Tree buffers",
    },
    {
      "<leader>tg",
      "<Cmd>lua require'neo-tree.command'.execute({ reveal = true, position = 'float', source = 'buffers' })<CR>",
      "Tree Git Status",
    },
  },
}
