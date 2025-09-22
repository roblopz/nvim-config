---@diagnostic disable: unused-function

---@class uv_timer_t
---@field start fun(self: uv_timer_t, timeout: integer, repeat_: integer, cb: fun())
---@field stop fun(self: uv_timer_t)
---@field close fun(self: uv_timer_t)

---@class uv
---@field new_timer fun(): uv_timer_t

---@alias Agent '"build"' | '"plan"' | '"unknown"'

---@class AgentModel
---@field provider_id string
---@field model_id string
---@field provider_name string
---@field model_name string

---@class OpencodeSyncState
---@field agent Agent
---@field agent_model AgentModel

---@class OpenCodeSyncPollOptions
---@field connection? integer
---@field state? integer

---@class OpenCodeSyncOptions
---@field poll? OpenCodeSyncPollOptions

---@class OpencodeSyncCache
---@field port number|nil
---@field state_path string|nil
---@field providers ProviderList|nil

---@class SyncStateControl
---@field cb_queue (fun(err: string|nil, state: OpencodeSyncState|nil))[]
---@field in_flight boolean

local uv = vim.loop
local initialized = false

---@type AgentModel
local unknown_model = {
  provider_id = 'unknown',
  model_id = 'unknown',
  provider_name = 'unknown',
  model_name = 'unknown',
}

---@type OpencodeSyncState
local unknown_state = {
  agent = 'unknown',
  agent_model = unknown_model,
}

---@type SyncStateControl
local sync_ctrl = {
  in_flight = false,
  cb_queue = {},
}

local M = {
  ---@type OpencodeSyncState
  state = unknown_state,
  ---@type OpencodeSyncCache
  cache = {},
}

---@param callback? fun(err: string|nil, state: OpencodeSyncState|nil)
---@param refresh_cache? boolean
M.refresh_state = function(callback, refresh_cache)
  refresh_cache = refresh_cache or false

  if sync_ctrl.in_flight then
    if callback then
      table.insert(sync_ctrl.cb_queue, callback)
    end

    return
  end

  local api = require 'opencode-sync.api'
  local util = require 'opencode-sync.util'

  local prev_state = M.state
  sync_ctrl.in_flight = true

  ---@param err string|nil
  ---@param state OpencodeSyncState|nil
  local function on_return(err, state)
    if callback then
      pcall(callback, err, state)
    end

    for _, waiter in ipairs(sync_ctrl.cb_queue) do
      pcall(waiter, err, state)
    end

    sync_ctrl.cb_queue = {}
    sync_ctrl.in_flight = false

    if err or not state then
      M.state = unknown_state
    else
      M.state = state
    end

    -- if not util.deep_eq(prev_state, M.state) then
    --   vim.api.nvim_exec_autocmds('User', {
    --     pattern = 'OpencodeSyncEvent',
    --     modeline = false,
    --     data = { old = prev_state, new = M.state },
    --   })
    -- end
  end

  if refresh_cache then
    M.cache.port = nil
    M.cache.state_path = nil
  end

  ---@param cb fun(port: number)
  local function with_port(cb)
    if M.cache.port then
      return cb(M.cache.port)
    end

    api.get_opencode_port(function(err, port)
      if err then
        M.cache.port = nil
        return on_return(err or 'failed to get port', nil)
      end

      ---@cast port number
      M.cache.port = port
      return cb(port)
    end)
  end

  ---@param port number
  ---@param cb fun(path: string)
  local function with_state_path(port, cb)
    if M.cache.state_path then
      return cb(M.cache.state_path)
    end

    api.get_opencode_state_path(port, function(err, path)
      if err then
        M.cache.state_path = nil
        return on_return(err or 'failed to get state path', nil)
      end

      ---@cast path string
      M.cache.state_path = path
      return cb(path)
    end)
  end

  ---@param port number
  ---@param cb fun(providers: ProviderList)
  local function with_providers(port, cb)
    if M.cache.providers then
      return cb(M.cache.providers)
    end

    api.get_opencode_providers(port, function(err, res)
      if err then
        M.cache.providers = nil
        return on_return(err or 'failed to get providers', nil)
      end

      ---@cast res ProviderList
      M.cache.providers = res
      return cb(res)
    end)
  end

  with_port(function(port)
    with_state_path(port, function(state_path)
      with_providers(port, function(providers)
        local err, state = util.parse_opencode_state(state_path, providers)
        if err then
          return on_return(err, nil)
        end

        return on_return(nil, state)
      end)
    end)
  end)
end

function M.switch_agent_mode()
  local api = require 'opencode-sync.api'

  ---@param port number
  local function exec_cmd(port)
    api.exec_opencode_cmd(port, 'agent_cycle', function(err)
      if err then
        return vim.notify(err, vim.log.levels.ERROR, { title = 'OpencodeSync' })
      end

      M.refresh_state()
    end)
  end

  if M.cache.port then
    return exec_cmd(M.cache.port)
  end

  api.get_opencode_port(function(err, port)
    if err then
      M.cache.port = nil
      vim.notify(err or 'failed to get opencode port', vim.log.levels.ERROR, { title = 'OpencodeSync' })
    end

    ---@cast port number
    M.cache.port = port
    return exec_cmd(port)
  end)
end

---@param backward boolean
function M.cycle_model(backward)
  local forward = not backward
  local api = require 'opencode-sync.api'

  ---@param port number
  local function exec_cmd(port)
    local cmd = forward and 'model_cycle_recent' or 'model_cycle_recent_reverse'

    api.exec_opencode_cmd(port, cmd, function(err)
      if err then
        return vim.notify(err, vim.log.levels.ERROR, { title = 'OpencodeSync' })
      end

      M.refresh_state()
    end)
  end

  if M.cache.port then
    return exec_cmd(M.cache.port)
  end

  api.get_opencode_port(function(err, port)
    if err then
      M.cache.port = nil
      vim.notify(err or 'failed to get opencode port', vim.log.levels.ERROR, { title = 'OpencodeSync' })
    end

    ---@cast port number
    M.cache.port = port
    return exec_cmd(port)
  end)
end

---@type uv_timer_t|nil
local state_timer = nil
local connection_timer = nil

---@param timer uv_timer_t|nil
local function stop_timer(timer)
  if timer then
    pcall(timer.stop, timer)
    pcall(timer.close, timer)
  end
end

---@param opts OpenCodeSyncPollOptions
local function start_timers(opts)
  stop_timer(state_timer)
  stop_timer(connection_timer)

  ---@type OpenCodeSyncPollOptions
  opts = vim.tbl_deep_extend('force', {}, {
    state = 2000,
    connection = 5000,
  }, opts or {})

  state_timer = uv.new_timer()
  connection_timer = uv.new_timer()

  local last_refresh_success = nil

  state_timer:start(
    opts.state,
    opts.state,
    vim.schedule_wrap(function()
      if vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0 then
        stop_timer(state_timer)
        state_timer = nil
        return
      end

      M.refresh_state(function(err)
        if err then
          if last_refresh_success ~= false then
            vim.notify(err, vim.log.levels.WARN, { title = 'OpencodeSync' })
          end

          last_refresh_success = false
        else
          if last_refresh_success ~= true then
            vim.notify(string.format('Opencode active at port %d', M.cache.port), vim.log.levels.INFO, { title = 'OpencodeSync' })
          end

          last_refresh_success = true
        end
      end)
    end)
  )

  connection_timer:start(
    opts.connection,
    opts.connection,
    vim.schedule_wrap(function()
      if vim.v.exiting ~= vim.NIL and vim.v.exiting ~= 0 then
        stop_timer(connection_timer)
        connection_timer = nil
        return
      end

      if M.cache.port or M.cache.state_path then
        M.cache.port = nil
        M.cache.state_path = nil
      end
    end)
  )
end

---@param options? OpenCodeSyncOptions
M.setup = function(options)
  if initialized then
    return
  end

  ---@type OpenCodeSyncOptions
  options = vim.tbl_deep_extend('force', {}, {
    poll = {
      state = 2000,
      connection = 10000,
    },
  }, options or {})

  M.refresh_state()

  start_timers(options.poll)
end

return M
