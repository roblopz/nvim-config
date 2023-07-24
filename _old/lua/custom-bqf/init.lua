local M = {}

M.setup = function()
  require 'bqf'.setup {
    func_map = {
      -- open
      open = "<CR>",
      -- open in tab
      tab = "t",
      -- open the item in a new tab, but stay at quickfix window
      tabb = "T",
      -- open the item in a new tab, and close quickfix window
      tabc = "<C-t>",
      -- open the item in horz split
      split = "<C-x>",
      -- open the item in vert split
      vsplit = "<C-v>",
      -- go to previous file under the cursor in quickfix window
      prevfile = "<C-k>",
      -- go to next file under the cursor in quickfix window
      nextfile = "<C-j>",
      -- go to previous quickfix list in quickfix window
      prevhist = "<",
      -- go to next quickfix list in quickfix window
      nexthist = ">",
      -- toggle sign and move cursor up
      stoggleup = "<S-Tab>",
      -- toggle sign and move cursor down
      stoggledown = "<Tab>",
      -- scroll up half-page in preview window
      pscrollup = "<C-U>",
      -- scroll down half-page in preview window
      pscrolldown = "<C-D>",
      -- scroll back to original position in preview window
      pscrollorig = "zo",
      -- toggle preview window between normal and max size
      ptogglemode = "zp",
      -- toggle preview for an item of quickfix list
      ptoggleitem = "p",
      -- toggle auto preview when cursor moved
      ptoggleauto = "P",
      -- create new list for signed items
      filter = "zn",
      -- create new list for non-signed items
      filterr = "zN",
      -- Last leave
      lastleave = "zl"
    },
    preview = {
      auto_preview = false
    }
  }

  local function help_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)") .. "help.txt";
  end

  local function get_buf_var(bufnr, v)
    return vim.api.nvim_buf_get_var(bufnr, v)
  end

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    callback = function(ev)
      local buf_type = vim.api.nvim_buf_get_option(ev.buf, 'buftype')

      if buf_type == 'quickfix' and not pcall(get_buf_var, ev.buf, 'qf_maps_set') then
        vim.api.nvim_buf_set_var(ev.buf, 'qf_maps_set', true)

        vim.keymap.set("n", "g?", function()
            local winbuf = vim.api.nvim_create_buf(false, true)

            local contents = vim.fn.readfile(help_path())
            vim.api.nvim_buf_set_lines(winbuf, 0, -1, false, contents)

            vim.api.nvim_open_win(winbuf, true, {
              relative = "editor",
              width = 80,
              height = 50,
              col = 20,
              row = 10,
            })

            vim.api.nvim_buf_set_option(winbuf, 'modifiable', false);
            vim.api.nvim_buf_set_option(winbuf, 'filetype', 'lua');
            vim.cmd('set nonumber')
          end,
          { buffer = ev.buf })
      end
    end
  })
end

return M
