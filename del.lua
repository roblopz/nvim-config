local printO = require'util'.printObj

local function test()
  function _G.ttest()
    print('ok')
  end

  vim.api.nvim_buf_set_keymap(1, 'n', '<leader>mm', [[:lua ttest()<CR>]], { noremap = true })
  print('registered')
end

test()
