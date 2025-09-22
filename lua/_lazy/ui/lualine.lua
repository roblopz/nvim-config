return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    vim.cmd 'set cmdheight=0'
    vim.cmd 'set showtabline=0'

    -- component_separators = { left = '', right = ''},
    -- section_separators = { left = '', right = ''},

    local search_count = require 'lualine.components.searchcount' {}
    local selection_count = require 'lualine.components.selectioncount'
    local progress = require 'lualine.components.progress'

    vim.api.nvim_set_hl(0, 'LualineCustomTabIndicator', { fg = '#A2E57B', bg = '#3A4549', bold = true })
    vim.api.nvim_set_hl(0, 'LualineCustomAiIndicator_plan', { fg = '#78dce8', bg = '#3A4549', bold = true })
    vim.api.nvim_set_hl(0, 'LualineCustomAiIndicator_build', { fg = '#ab9df2', bg = '#3A4549', bold = true })
    vim.api.nvim_set_hl(0, 'LualineCustomAiIndicator_unknown', { fg = '#ffd866', bg = '#3A4549', bold = true })

    local function opencode_indicator()
      local state = require('opencode-sync').state
      local mode = state.agent

      local hi = mode == 'build' and 'LualineCustomAiIndicator_build' or 'LualineCustomAiIndicator_plan'
      if mode == 'unknown' then
        hi = 'LualineCustomAiIndicator_unknown'
      end

      local mode_text = ({
        ['build'] = 'Build Agent',
        ['plan'] = 'Plan Agent',
        ['unknown'] = 'Disconnected',
      })[mode]

      local model_str = ''
      if mode ~= 'unknown' then
        model_str = ' - ' .. state.agent_model.model_name
      end

      return '%#' .. hi .. '#' .. '󱙺 ' .. mode_text .. model_str
    end

    local function tabs_indicator()
      local tab_count = vim.fn.tabpagenr '$'
      if tab_count <= 1 then
        return ''
      end

      local curr_tab = vim.fn.tabpagenr()
      return '%#LualineCustomTabIndicator#' .. 'Tab ' .. curr_tab
    end

    local function custom_indicator()
      local mode = vim.fn.mode(true)
      local rec = vim.fn.reg_recording()

      if rec ~= '' then
        return 'Rec @ ' .. rec
      elseif vim.v.hlsearch > 0 then
        return search_count:update_status()
      elseif mode:match 'V' or mode:match 'v' then
        local line_start = vim.fn.line 'v'
        local line_end = vim.fn.line '.'
        local sel_count = selection_count()
        local suffix = ''

        if mode:match 'V' or line_start ~= line_end then
          suffix = ' lines'
        else
          suffix = ' chars'
        end

        return sel_count .. suffix
      end

      return progress()
    end

    local theme = require 'lualine.themes.monokai-pro'
    -- theme.normal.c = { fg = '#f2fffc', bg = '#273136' }
    -- theme.normal.x = { fg = '#f2fffc', bg = '#273136' }
    theme.normal.c = { fg = '#f2fffc', bg = 'None' }
    theme.normal.x = { fg = '#f2fffc', bg = 'None' }
    vim.api.nvim_set_hl(0, 'StatusLine', { bg = 'NONE' })

    require('lualine').setup {
      options = {
        theme = theme,
        globalstatus = true,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { opencode_indicator },
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = false,
            path = 1,
            -- 0: Just the filename
            -- 1: Relative path
            -- 2: Absolute path
            -- 3: Absolute path, with tilde as the home directory
            -- 4: Filename and parent dir, with tilde as the home directory
            symbols = {
              modified = '[+]', -- Text to show when the file is modified.
              readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
              unnamed = '[No Name]', -- Text to show for unnamed buffers.
              newfile = '[New]', -- Text to show for newly created file before first write
            },
          },
        },
        lualine_x = { 'branch' },
        lualine_y = { tabs_indicator, custom_indicator },
        lualine_z = { 'location' },
      },
      extensions = {
        'quickfix',
        'lazy',
        'mason',
        'neo-tree',
      },
    }
  end,
}
