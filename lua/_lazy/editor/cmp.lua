return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    {
      'L3MON4D3/LuaSnip',
      build = (function()
        if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      dependencies = {
        {
          'rafamadriz/friendly-snippets',
          config = function()
            require('luasnip.loaders.from_vscode').lazy_load()
          end,
        },
      },
    },
    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'cmp-under-comparator',
    'lukas-reineke/cmp-under-comparator',
  },
  config = function()
    local cmp = require 'cmp'
    local luasnip = require 'luasnip'
    local types = require 'cmp.types'
    luasnip.config.setup {}

    cmp.setup {
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      completion = { completeopt = 'menu,menuone,noselect' },
      mapping = cmp.mapping.preset.insert {
        ['<CR>'] = cmp.mapping.confirm { select = true },
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-p>'] = cmp.mapping.scroll_docs(-4),
        ['<C-n>'] = cmp.mapping.scroll_docs(4),
        ['<C-b>'] = cmp.mapping.open_docs(),
        ['<C-f>'] = cmp.mapping.close_docs(),
      },
      sources = {
        {
          name = 'nvim_lsp',
          priority = 1000,
          entry_filter = function(entry)
            -- Filter text from lsp as we have the buffer source
            local kind = types.lsp.CompletionItemKind[entry:get_kind()]
            if kind == 'Text' then
              return false
            end
            return true
          end,
        },
        -- { name = 'nvim_lsp_signature_help', priority = 900 },
        { name = 'path', priority = 800 },
        { name = 'buffer', priority = 700, keyword_length = 3, max_item_count = 10 },
        -- { name = 'luasnip', priority = 1 },
      },
      ---@diagnostic disable-next-line: missing-fields
      formatting = {
        format = function(entry, vim_item)
          if entry.source.name == 'nvim_lsp_signature_help' and vim_item.kind == 'Text' then
            vim_item.kind = 'Parameter' -- Change "Text" to "Parameter"
          end
          return vim_item
        end,
      },
    }

    cmp.setup.cmdline({ '/', '?' }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = 'buffer' },
      },
    })

    cmp.setup.cmdline(':', {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = 'path' },
      }, {
        { name = 'cmdline' },
      }),
    })

    vim.keymap.set('i', '<C-e>', function()
      if cmp.visible() then
        cmp.close()
      else
        cmp.complete { reason = cmp.ContextReason.Manual }
      end
    end, { desc = 'Trigger cmp completion menu' })
  end,
}
