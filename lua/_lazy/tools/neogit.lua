return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'sindrets/diffview.nvim',
    'ibhagwan/fzf-lua',
    -- 'folke/snacks.nvim',
  },
  config = function()
    require('neogit').setup {
      graph_style = 'kitty',
      process_spinner = true,
      signs = {
        hunk = { '', '' },
        item = { '', '' },
        section = { '', '' },
      },
      integrations = {
        snacks = true,
      },
      _ignore = {
        -- Text styles (toggle if you like Monokai-Pro's subtle italics)
        italic = true,
        bold = false,
        underline = false,

        -- Core Monokai Pro "Pro" palette
        -- Source (Monokai-Pro plugin README palette mapping):
        -- dark="#19181a", black="#221f22", text="#fcfcfa"
        -- accent1="#ff6188", accent2="#fc9867", accent3="#ffd866",
        -- accent4="#a9dc76", accent5="#78dce8", accent6="#ab9df2",
        -- dimmed1="#c1c0c0", dimmed2="#939293", dimmed3="#727072",
        -- dimmed4="#5b595c", dimmed5="#403e41"
        bg0 = '#19181a', -- darkest background
        bg1 = '#221f22', -- second darkest
        bg2 = '#403e41', -- second lightest
        bg3 = '#5b595c', -- lightest (used for subtle fills / headers)

        grey = '#939293',
        white = '#fcfcfa',

        red = '#ff6188',
        bg_red = '#2d1f25', -- gentle red-ish background for deletions
        line_red = '#3a242c', -- cursor line over red context

        orange = '#fc9867',
        bg_orange = '#2f2621', -- used by some headers/hunks
        yellow = '#ffd866',
        bg_yellow = '#3a341f',

        green = '#a9dc76',
        bg_green = '#2a2e1e',
        line_green = '#333a27',

        cyan = '#78dce8',
        bg_cyan = '#1f2d30',

        -- Neogit expects a "blue" slot; Monokai Pro doesn't have a pure blue in Pro filter.
        -- Neogit mainly uses this for accents; Monokai-Pro often uses the orange as “warm accent”.
        -- We map 'blue' -> accent2 (orange) for cohesive Monokai-Pro look.
        blue = '#fc9867',
        bg_blue = '#2f2621',

        purple = '#ab9df2',
        bg_purple = '#2b2433',
        md_purple = '#7e6bc4', -- a medium purple that fits between bg_purple and purple
      },
    }
  end,
}
