local function set_mappings(event)
  -- NOTE: Remember that Lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  -- Jump to the definition of the word under your cursor.
  --  This is where a variable was first declared, or where a function is defined, etc.
  --  To jump back, press <C-t>.
  map('gdd', vim.lsp.buf.definition, 'Goto Definition')

  map('gdv', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('custom.open-window').split(item.filename, {
            mode = 'split',
            horizontal = false,
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - vertical split')

  map('gdx', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('custom.open-window').open(item.filename, {
            mode = 'split',
            horizontal = true,
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - window pick')

  map('gds', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]
          require('custom.open-window').open(item.filename, {
            on_open_set_cursor = { item.lnum, item.col },
          })
        end
      end,
    }
  end, 'Goto Definition - window pick')

  map('gdp', function()
    vim.lsp.buf.definition {
      reuse_win = false,
      on_list = function(locations)
        if #locations > 1 then
          vim.fn.setqflist({}, ' ', { title = 'LSP Definitions', items = locations })
          vim.cmd 'copen'
        else
          local item = locations.items[1]

          local bufnr = vim.fn.bufnr(item.filename, true)
          if not vim.api.nvim_buf_is_loaded(bufnr) then
            vim.fn.bufload(bufnr)
          end

          local editor_width = vim.o.columns
          local editor_height = vim.o.lines
          local win_width = math.max(math.floor(editor_width / 3), 160)
          local win_height = math.max(math.floor(editor_height / 3), 30)

          local floating_win_id = vim.api.nvim_open_win(bufnr, true, {
            relative = 'cursor',
            width = math.min(win_width, editor_width),
            height = math.min(win_height, win_height),
            row = 1,
            col = -1,
            style = 'minimal',
            border = 'rounded',
          })

          vim.api.nvim_win_set_cursor(floating_win_id, { item.lnum, item.col })
          if not vim.wo.number then
            vim.cmd 'set number'
          end

          if not vim.wo.relativenumber then
            vim.cmd 'set relativenumber'
          end

          vim.cmd 'norm! zz'
        end
      end,
    }
  end, 'Goto Definition - floating window')

  -- This is not Goto Definition, this is Goto Declaration.
  --  For example, in C this would take you to the header.
  map('gdD', vim.lsp.buf.declaration, 'Goto Declaration')

  -- Find references for the word under your cursor.
  map('gdr', function()
    vim.cmd 'Telescope lsp_references show_line=false'
  end, 'Goto References')

  -- Jump to the implementation of the word under your cursor.
  --  Useful when your language has ways of declaring types without an actual implementation.
  map('gdi', vim.lsp.buf.implementation, 'Goto Implementation')

  -- Jump to the type of the word under your cursor.
  --  Useful when you're not sure what type a variable is and you want to see
  --  the definition of its *type*, not where it was *defined*.
  map('gdt', vim.lsp.buf.type_definition, 'Type Definition')

  -- Fuzzy find all the symbols in your current document.
  --  Symbols are things like variables, functions, types, etc.
  map('gdw', require('telescope.builtin').lsp_document_symbols, 'Document Symbols')

  -- Fuzzy find all the symbols in your current workspace.
  --  Similar to document symbols, except searches over your entire project.
  map('gdW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace Symbols')

  -- Rename the variable under your cursor --> Terminal mapped to (F2)
  --  Most Language Servers support renaming across files, etc.
  map('<C-space>', vim.lsp.buf.hover, 'Hover Docs')

  -- Signature help
  map('<C-h>', vim.lsp.buf.signature_help, 'Signature Help')
  vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = event.buf })

  -- Execute a code action, usually your cursor needs to be on top of an error
  -- or a suggestion from your LSP for this to activate.
  map('ã-5', vim.lsp.buf.code_action, 'Code Action')

  -- Rename the variable under your cursor --> Terminal mapped to (F2)
  --  Most Language Servers support renaming across files, etc.
  map('ã-6', vim.lsp.buf.rename, 'Rename')
end

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    { 'williamboman/mason.nvim', config = true },
    'hrsh7th/cmp-nvim-lsp',
  },
  config = function()
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = set_mappings,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    local servers = {
      jsonls = {},
      tsserver = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = { callSnippet = 'Replace' },
          },
        },
      },
      eslint = {
        settings = {
          -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
          workingDirectories = { mode = 'auto' },
        },
      },
    }

    require('mason').setup()

    require('mason-lspconfig').setup {
      ensure_installed = { 'jsonls', 'lua_ls', 'eslint' },
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
