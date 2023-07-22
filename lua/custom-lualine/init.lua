local M = {}

local function makeHighlight(name, fg, bg)
  vim.cmd(string.format('hi %s guifg=%s guibg=%s gui=bold', name, fg, bg))
  return name
end

local function filename_and_parent(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return vim.fn.fnamemodify(' xx ' .. fname, ':p:h:t') .. '/' .. vim.fn.fnamemodify(fname, ':t')
end

M.setup = function()
  local colors = {
    graybg         = '#606060',
    whiteText      = '#F7F9FC',
    darkDragonBlue = '#3E525B'
  }

  local palette_colors = require("kanagawa.colors").setup().palette
  local b_section = { fg = colors.whiteText, bg = colors.graybg }
  local c_section = { fg = palette_colors.fujiWhite, bg = "None" }

  local theme = {
    normal = {
      a = { fg = palette_colors.winterGreen, bg = palette_colors.springGreen, gui = 'bold' },
      b = b_section,
      c = c_section,
    },
    insert = {
      a = { fg = palette_colors.winterBlue, bg = palette_colors.springBlue, gui = 'bold' },
      b = b_section,
      c = c_section,
    },
    visual = {
      a = { fg = palette_colors.winterYellow, bg = palette_colors.roninYellow, gui = 'bold' },
      b = b_section,
      c = c_section,
    },
    replace = {
      a = { fg = palette_colors.winterRed, bg = palette_colors.waveRed, gui = 'bold' },
      b = b_section,
      c = c_section,
    },
    command = {
      a = { fg = palette_colors.winterRed, bg = palette_colors.oniViolet, gui = 'bold' },
      b = b_section,
      c = c_section,
    },
    inactive = {
      a = { fg = palette_colors.oldWhite, bg = colors.graybg },
      b = b_section,
      c = c_section,
    },
  };

  local buffer_active_hl = makeHighlight("Status_Buffer_Active", colors.whiteText, palette_colors.crystalBlue)
  local buffer_inactive_hl = makeHighlight("Status_Buffer_Inactive", palette_colors.oldWhite, palette_colors.sumiInk3)
  local tab_active_hl = makeHighlight("Status_Tab_Active", colors.whiteText, colors.graybg)
  local tab_inactive_hl = makeHighlight("Status_Tab_Inactive", palette_colors.oldWhite, colors.graybg)
  local winbar_active_hl = makeHighlight("Status_Winbar_Active", palette_colors.fujiWhite, colors.darkDragonBlue)
  local winbar_inactive_hl = makeHighlight("Status_Winbar_Inactive", palette_colors.oldWhite, "None")
  local winbar_decoration_hl = makeHighlight("Status_Winbar_Decoration", colors.darkDragonBlue, "None")

  local diagnostic_err_hl = makeHighlight("Status_Diagnostic_Error", palette_colors.peachRed, colors.darkDragonBlue)
  local diagnostic_warn_hl = makeHighlight("Status_Diagnostic_Warn", palette_colors.carpYellow, colors.darkDragonBlue)
  local diagnostic_info_hl = makeHighlight("Status_Diagnostic_Info", palette_colors.waveAqua2, colors.darkDragonBlue)
  local diagnostic_hint_hl = makeHighlight("Status_Diagnostic_Hint", colors.autumnGreen, colors.darkDragonBlue)

  local diagnostic_inactive_err_hl = makeHighlight("Status_Diagnostic_Inactive_Error", palette_colors.peachRed, "None")
  local diagnostic_inactive_warn_hl = makeHighlight("Status_Diagnostic_Inactive_Warn", palette_colors.carpYellow, "None")
  local diagnostic_inactive_info_hl = makeHighlight("Status_Diagnostic_Inactive_Info", palette_colors.waveAqua2, "None")
  local diagnostic_inactive_hint_hl = makeHighlight("Status_Diagnostic_Inactive_Hint", colors.autumnGreen, "None")

  -- local function buffer_fmt(str, ctx)
  --   if str:match('[jt]sx?$') then
  --     str = 2
  --   end
  -- end

  require 'lualine'.setup {
    options = {
      globalstatus = true,
      theme = theme
    },
    extensions = { 'neo-tree', 'quickfix', 'nvim-dap-ui' },
    tabline = {
      lualine_b = {
        {
          'buffers',
          buffers_color = {
            active = buffer_active_hl,
            inactive = buffer_inactive_hl,
          },
          icons_enabled = false,
          fmt = function(str, ctx)
            if str:match('index%.[jt]sx?$') ~= nil then
              str = filename_and_parent(ctx.bufnr)
            end

            if ctx.beforecurrent then
              return str .. '%#' .. buffer_inactive_hl .. '#'
            else
              return str;
            end
          end
        }
      }
    },
    sections = {
      lualine_a = {
        {
          'mode',
        }
      },
      lualine_b = { 'branch' },
      lualine_c = { { 'filename', path = 3 } },
      lualine_x = { 'filetype' },
      lualine_y = {
        {
          'tabs',
          mode = 1,
          tabs_color = {
            active = tab_active_hl,
            inactive = tab_inactive_hl,
          },

        },
        'progress'
      },
      lualine_z = { 'location' }
    },
    winbar = {
      lualine_a = {
        {
          function()
            local active_hl  = '%#' .. winbar_active_hl .. '#'
            local decoration = '%#' .. winbar_decoration_hl .. '#%*'
            return active_hl .. '%f' .. decoration
          end,
          color = { bg = 'none' },
        }
      },
      lualine_z = {
        {
          'diagnostics',
          diagnostics_color = {
            error = diagnostic_err_hl,
            warn  = diagnostic_warn_hl,
            info  = diagnostic_info_hl,
            hint  = diagnostic_hint_hl,
          },
        }
      }
    },
    inactive_winbar = {
      lualine_a = {
        {
          function()
            return '%#' .. winbar_inactive_hl .. '#%f%*'
          end,
          color = { bg = 'none' },
        }
      },
      lualine_z = {
        {
          'diagnostics',
          diagnostics_color = {
            error = diagnostic_inactive_err_hl,
            warn  = diagnostic_inactive_warn_hl,
            info  = diagnostic_inactive_info_hl,
            hint  = diagnostic_inactive_hint_hl,
          },
        }
      }
    }
  }
end

return M;
