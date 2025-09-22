local notify = require 'notify'

local M = {}

-- Braille spinner frames (smooth animation)
local FRAMES = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

---@class PxSpinner
---@field _timer uv_timer_t|nil
---@field _frame integer
---@field _notif table|nil
---@field title string
---@field message string
---@field level integer
---@field interval integer
---@field auto boolean
local Spinner = {}
Spinner.__index = Spinner

---@param opts { title?:string, message?:string, level?:integer, interval?:integer, auto?:boolean }
function Spinner.new(opts)
  opts = opts or {}
  local self = setmetatable({}, Spinner)
  self.title = opts.title or 'Working…'
  self.message = opts.message or ''
  self.level = opts.level or vim.log.levels.INFO
  self.interval = opts.interval or 80
  self.auto = opts.auto or false
  self._frame = 1
  self._timer = nil
  return self
end

function Spinner:_render(text)
  local msg = text or (FRAMES[self._frame] .. ' ' .. self.message)
  if self._notif == nil then
    self._notif = notify(msg, self.level, {
      title = self.title,
      timeout = false,
      hide_from_history = true,
    })
  else
    self._notif = notify(msg, self.level, {
      title = self.title,
      replace = self._notif,
      timeout = false,
      hide_from_history = true,
    })
  end
end

---Start the spinner animation
function Spinner:start()
  self:_render()
  if self.auto then
    self._timer = vim.loop.new_timer()
    self._timer:start(0, self.interval, function()
      vim.schedule(function()
        self._frame = (self._frame % #FRAMES) + 1
        self:_render()
      end)
    end)
  end
  return self
end

---Manually advance one frame (useful if auto=false)
function Spinner:tick()
  self._frame = (self._frame % #FRAMES) + 1
  self:_render()
end

function Spinner:update(message)
  self.message = message or self.message
  self:_render()
end

function Spinner:progress(pct, message)
  local txt = string.format('%s %s', message or self.message, pct and ('(' .. math.floor(pct) .. '%%)') or '')
  self:_render(FRAMES[self._frame] .. ' ' .. txt)
end

function Spinner:_finish(final_text, final_level, opts)
  if self._timer and not self._timer:is_closing() then
    self._timer:stop()
    self._timer:close()
  end
  self._timer = nil
  self._notif = notify(
    final_text,
    final_level,
    vim.tbl_extend('force', {
      title = self.title,
      replace = self._notif,
      timeout = 3000,
      hide_from_history = false,
    }, opts or {})
  )
end

function Spinner:success(message)
  self:_finish('✔ ' .. (message or self.message), vim.log.levels.INFO)
end
function Spinner:warn(message)
  self:_finish(' ' .. (message or self.message), vim.log.levels.WARN)
end
function Spinner:error(message)
  self:_finish('✖ ' .. (message or self.message), vim.log.levels.ERROR)
end

function M.spinner(opts)
  return Spinner.new(opts)
end

return M
