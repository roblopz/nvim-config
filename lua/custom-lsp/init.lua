local M = {}

M.setup = function()
  local lspconfig = require 'lspconfig'
  local cmp = require 'cmp'
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local lspkind = require('lspkind')

  require("neodev").setup()

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-d>'] = cmp.mapping.scroll_docs(4),
      ['<C-u>'] = cmp.mapping.scroll_docs(-4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<Tab>'] = cmp.mapping.confirm({ select = true })
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
    }, {
      name = 'async_path'
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol_text',  -- show only symbol annotations
        maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

        -- The function below will be called before any actual modifications from lspkind
        -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        before = function(entry, vim_item)
          return vim_item
        end
      })

    }
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local function on_lsp_attach(client, bufnr)
    require 'lsp_signature'.on_attach({
      bind = true,
      max_height = 40,
      max_width = 100,
      wrap = true,
      floating_window = true,
      floating_window_above_cur_line = true,
      hint_enable = false,
      hi_parameter = "LspSignatureActiveParameter",
      transparency = nil,                       -- disabled by default, allow floating win transparent value 1~100,
      shadow_blend = 36,                        -- if you using shadow as border use this set the opacity
      shadow_guibg = 'Black',                   -- if you using shadow as border use this set the color
      always_trigger = false,
      toggle_key = 'ã-3',                    -- toggle signature on and off in insert mode
      toggle_key_flip_floatwin_setting = false, -- true: toggle float setting after toggle key pressed
      select_signature_key = '<c-d>',           -- cycle to next signature, e.g. '<M-n>' function overloading
      move_cursor_key = '<c-u>',                -- imap, use nvim_set_current_win to move cursor between current win and floating
      zindex = 200,
      handler_opts = {
        border = 'rounded'
      }
    }, bufnr)

    -- Not all of this is actually used
    require 'lspsaga'.setup({
      scroll_preview = {
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
      },
      ui = {
        title = true,
        border = "single",
        winblend = 0,
        expand = "",
        collapse = "",
        code_action = "💡",
        incoming = " ",
        outgoing = " ",
        hover = '� ',
        kind = {},
      },
      lightbulb = {
        enable = false
      },
      finder = {
        max_height = 0.8,
        min_width = 50,
        force_max_height = false,
        keys = {
          jump_to = 'l',
          expand_or_jump = 'o',
          vsplit = 'v',
          split = 'x',
          tabe = 't',
          tabnew = 'r',
          quit = { 'q', '<ESC>' },
          close_in_preview = '<ESC>',
        },
      },
      definition = {
        edit = "<C-o>",
        vsplit = "<C-v>",
        split = "<C-x>",
        tabe = "<C-t>",
        quit = { 'q', '<ESC>' },
      },
      code_action = {
        num_shortcut = true,
        show_server_name = false,
        extend_gitsigns = true,
        keys = {
          quit = { 'q', '<ESC>' },
          exec = "<CR>",
        },
      },
      hover = {
        max_width = 0.8,
        open_link = 'gx',
        open_browser = '!chrome'
      },
      diagnostic = {
        on_insert = false,
        on_insert_follow = false,
        insert_winblend = 0,
        show_code_action = true,
        show_source = true,
        jump_num_shortcut = true,
        max_width = 0.8,
        max_height = 0.6,
        max_show_width = 0.9,
        max_show_height = 0.6,
        text_hl_follow = true,
        border_follow = true,
        extend_relatedInformation = false,
        keys = {
          exec_action = 'o',
          quit = 'q',
          expand_or_jump = '<CR>',
          quit_in_show = { 'q', '<ESC>' },
        },
      },
      rename = {
        quit = "<C-c>",
        exec = "<CR>",
        mark = "x",
        confirm = "<CR>",
        in_select = false,
      },
      outline = {
        win_position = "right",
        win_with = "",
        win_width = 40,
        preview_width = 0.4,
        show_detail = true,
        auto_preview = true,
        auto_refresh = true,
        auto_close = true,
        auto_resize = false,
        custom_sort = nil,
        keys = {
          expand_or_jump = 'o',
          quit = { '<ESC>', 'q' }
        },
      },
    })
  end

  lspconfig.tsserver.setup {
    capabilities = capabilities,
    on_attach = on_lsp_attach
  }

  lspconfig.lua_ls.setup {
    capabilities = capabilities,
    on_attach = on_lsp_attach
  }
end

return M
