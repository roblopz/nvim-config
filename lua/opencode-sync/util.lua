local M = {}

---@type AgentModel
local unknown_model = {
  provider_id = 'unknown',
  model_id = 'unknown',
  provider_name = 'unknown',
  model_name = 'unknown',
}

---@param item table
---@param opencode_providers ProviderList
---@return AgentModel
local function parse_model(item, opencode_providers)
  if type(item) ~= 'table' then
    return unknown_model
  end

  local pid = (item.provider_id ~= nil) and tostring(item.provider_id) or 'unknown'
  local mid = (item.model_id ~= nil) and tostring(item.model_id) or 'unknown'

  ---@type AgentModel
  local res = {
    provider_id = pid,
    model_id = mid,
    provider_name = pid,
    model_name = mid,
  }

  if opencode_providers and next(opencode_providers) ~= nil then
    if opencode_providers[pid] and opencode_providers[pid].name then
      local provider = opencode_providers[pid]
      local models = provider.models

      if models[mid] and models[mid].name then
        res.provider_name = provider.name
        res.model_name = models[mid].name
      end
    end
  end

  return res
end

---@param state_path string
---@param opencode_providers ProviderList
---@return string|nil, OpencodeSyncState|nil
function M.parse_opencode_state(state_path, opencode_providers)
  local cut_pattern = '%[%[message_history%]%]'
  local chunk_size = 4096

  local f, open_err = io.open(state_path, 'rb')
  if not f then
    return ('open failed: %s'):format(open_err or 'unknown'), nil
  end

  local pieces = {}
  while true do
    local piece = f:read(chunk_size)
    if not piece then
      break
    end
    table.insert(pieces, piece)

    -- Check for the cut marker in the accumulated buffer
    local joined = table.concat(pieces)
    local s = joined:find(cut_pattern)
    if s then
      pieces = { joined:sub(1, s - 1) } -- keep header only
      break
    end
  end

  f:close()

  local content = table.concat(pieces)

  local ok_req, toml = pcall(require, 'toml')
  if not ok_req or not toml then
    return 'toml module not found', nil
  end

  local ok_parse, parsed = pcall(toml.parse, content)
  if not ok_parse then
    return ('toml parse error: %s'):format(parsed), nil
  end

  local state = parsed

  ---@type Agent
  local agent = (state.agent == 'build' or state.agent == 'plan') and state.agent or 'unknown'

  ---@type AgentModel
  local agent_model = unknown_model
  if agent ~= 'unknown' and type(state.agent_model) == 'table' then
    agent_model = parse_model(state.agent_model[agent], opencode_providers)
  end
  if agent_model.provider_id == 'unknown' or agent_model.model_id == 'unknown' then
    if state.provider or state.model then
      agent_model = parse_model({
        provider_id = state.provider,
        model_id = state.model,
      }, opencode_providers)
    end
  end

  return nil, {
    agent = agent,
    agent_model = agent_model,
  }
end

function M.deep_eq(a, b)
  if a == b then
    return true
  end
  if type(a) ~= 'table' or type(b) ~= 'table' then
    return false
  end
  for k, va in pairs(a) do
    local vb = b[k]
    if not M.deep_eq(va, vb) then
      return false
    end
  end
  for k in pairs(b) do
    if a[k] == nil then
      return false
    end
  end
  return true
end

return M
