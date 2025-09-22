---@class ProviderModelItem
---@field id string
---@field name string

---@class ProviderEntry
---@field id string
---@field name string
---@field models table<string, ProviderModelItem>

---@alias ProviderList table<string, ProviderEntry>

---@class CurlOptions
---@field body table|nil
---@field is_fire_and_forget boolean|nil
---@field timeout number|nil

local M = {
  locating_opencode = false,
}

local function handle_json(data)
  for _, line in ipairs(data) do
    if line == '' then
      return
    end
    local ok, response = pcall(vim.fn.json_decode, line)
    if ok then
      return response
    else
      vim.notify('JSON decode error: ' .. line, vim.log.levels.ERROR, { title = 'OpencodeSync' })
    end
  end
end

---@param url string
---@param method string
---@param options CurlOptions|nil
---@param callback fun(err: string|nil, response: table|nil)|nil
---@return number job_id
local function curl(url, method, options, callback)
  local opts = options or {}

  local command = {
    'curl',
    '-s',
    '-X',
    method,
    '-H',
    'Content-Type: application/json',
    '-H',
    'Accept: application/json',
    '-H',
    'Accept: text/event-stream',
    '-N', -- No buffering, for streaming SSEs
    opts.body and '-d' or nil,
    opts.body and vim.fn.json_encode(opts.body) or nil,
    url,
  }

  if opts.is_fire_and_forget and not opts.timeout then
    opts.timeout = 1
  end

  if opts.timeout then
    table.insert(command, '--max-time')
    table.insert(command, tostring(opts.timeout))
  end

  local returned = false
  local stderr_lines = {}

  return vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      local response = handle_json(data)

      if response and callback then
        returned = true
        callback(nil, response)
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          table.insert(stderr_lines, line)
        end
      end
    end,
    on_exit = function(_, code)
      -- 18 means connection closed while there was more data to read, which happens occasionally with SSEs when we quit opencode. nbd.
      if code ~= 0 and code ~= 18 then
        local error_message = 'curl command failed with exit code: '
          .. code
          .. '\nstderr:\n'
          .. (#stderr_lines > 0 and table.concat(stderr_lines, '\n') or '<none>')

        if not opts.is_fire_and_forget then
          if callback then
            return callback(error_message, nil)
          end
        end
      end

      if not returned and callback then
        callback(nil, nil)
      end
    end,
  })
end

---@param cb fun(err: string|nil, result: integer|nil)
function M.get_opencode_port(cb)
  local ok_srv, server = pcall(require, 'opencode.server')

  if not ok_srv or not server or type(server.get_port) ~= 'function' then
    return cb('opencode.server module not available', nil)
  end

  M.locating_opencode = true

  server.get_port(function(ok, port_or_err)
    M.locating_opencode = false

    if not ok then
      return cb(port_or_err or 'failed to get port')
    end

    return cb(nil, port_or_err)
  end)
end



---Call an opencode server endpoint.
---@param port number
---@param path string
---@param method string
---@param options CurlOptions|nil
---@param cb fun(err: string|nil, response: table|nil)
function M.call_opencode(port, path, method, options, cb)
  local url = 'http://localhost:' .. port .. path

  curl(url, method, options, function(err, res)
    return cb(err, res)
  end)
end

---@param port number
---@param cb fun(err: string|nil, result: string|nil)
function M.get_opencode_state_path(port, cb)
  M.call_opencode(port, '/path', 'GET', nil, function(err, path_data)
    if err then
      return cb(err, nil)
    elseif not path_data or not path_data.state then
      return cb('No opencode state data returned', nil)
    end

    return cb(nil, path_data.state .. '/tui')
  end)
end

---@param port number
---@param cb fun(err: string|nil, result: ProviderList|nil)
function M.get_opencode_providers(port, cb)
  M.call_opencode(port, '/config/providers', 'GET', nil, function(err, data)
    if err then
      return cb(err, nil)
    elseif not data or not data.providers then
      return cb('No opencode provider data returned', nil)
    elseif type(data.providers) ~= 'table' then
      return cb('Malformed opencode provider data returned', nil)
    end

    local providers = data.providers
    local res = {} ---@type ProviderList

    for _, p in pairs(providers) do
      if type(p) == 'table' and type(p.id) == 'string' and type(p.name) == 'string' and type(p.models) == 'table' then
        local models = {} ---@type table<string, ProviderModelItem>
        for _, m in pairs(p.models) do
          if type(m) == 'table' and type(m.id) == 'string' and type(m.name) == 'string' then
            models[m.id] = { id = m.id, name = m.name }
          end
        end
        res[p.id] = {
          id = p.id,
          name = p.name,
          models = models,
        }
      end
    end

    return cb(nil, res)
  end)
end

---@param port number
---@param cmd string
---@param cb fun(err: string|nil, result: any|nil)
function M.exec_opencode_cmd(port, cmd, cb)
  ---@type CurlOptions
  local opts = {
    body = { command = cmd },
    is_fire_and_forget = true,
  }

  M.call_opencode(port, '/tui/execute-command', 'POST', opts, function(err, data)
    if err then
      return cb(err, nil)
    end

    return cb(nil, data)
  end)
end

return M
