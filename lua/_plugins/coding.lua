return {
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring", "windwp/nvim-ts-autotag" },
    cmd = { "TSUpdateSync" },
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      autotag = { enable = true },
      context_commentstring = { enable = true, enable_autocmd = false },
      ensure_installed = {
        "html",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        "luadoc",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
        "sql",
        "graphql",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<tab>v",
          node_incremental = "<tab>v",
          scope_incremental = "<nop>",
          node_decremental = "<bs>",
        },
      },
    },
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "windwp/nvim-autopairs",
    opts = { check_ts = true }
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      local wk = require 'which-key'
      local illuminate = require 'illuminate'

      illuminate.configure({ delay = 200 })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()

          wk.register({
            ["]]"] = { function() illuminate["goto_next_reference"](false) end, "Next reference", mode = "n", buffer =
                buffer },
            ["[["] = { function() illuminate["goto_prev_reference"](false) end, "Prev reference", mode = "n", buffer =
                buffer },
          })
        end,
      })
    end
  },
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
  { "windwp/nvim-ts-autotag",                      lazy = true },
  {
    "numToStr/Comment.nvim",
    opts = {
      custom_commentstring = function()
        return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
      end,
    },
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = true
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      char = "│",
      filetype_exclude = {
        "help",
        "alpha",
        "dashboard",
        "neo-tree",
        "Trouble",
        "lazy",
        "mason",
        "notify",
        "toggleterm",
        "lazyterm",
      },
      show_trailing_blankline_indent = false,
      show_current_context = false,
    },
  },
  {
    "echasnovski/mini.indentscope",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      draw = {
        animation = function () return 5 end
      },
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "neo-tree",
          "Trouble",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })
    end,
  },
}
