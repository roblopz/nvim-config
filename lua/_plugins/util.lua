return {
  's1n7ax/nvim-window-picker',
  name = 'window-picker',
  event = 'VeryLazy',
  version = '2.*',
  opts = {
    selection_chars = 'ABCDEFGHIJKLMNOPQRSTUVXYZ',
    filter_rules = {
      bo = {
        filetype = {
          'NvimTree',
          "neo-tree",
          "notify",
          "TelescopePrompt",
          "qf",
          "dap-repl",
          "quickfix"
        }
      }
    },
    highlights = {
      statusline = {
        focused = {
          fg = '#ededed',
          bg = '#44cc41',
          bold = true,
        },
        unfocused = {
          fg = '#ededed',
          bg = '#44cc41',
          bold = true,
        },
      },
      winbar = {
        focused = {
          fg = '#ededed',
          bg = '#44cc41',
          bold = true,
        },
        unfocused = {
          fg = '#ededed',
          bg = '#44cc41',
          bold = true,
        },
      },
    }
  },
  config = function(_, opts)
    require 'window-picker'.setup(opts)
  end,

}
