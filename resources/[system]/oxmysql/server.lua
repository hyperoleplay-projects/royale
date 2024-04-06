local json_header = {
  ['Content-Type'] = 'application/json'
}

function parse_response(mode, response)
  if mode == 'single' then
    return response[1]
  elseif mode == 'insert' then
    return response.insertId
  elseif mode == 'update' then
    return response.affectedRows
  elseif mode == 'scalar' then
    for k, v in pairs(response[1] or {}) do
      return v
    end
    return nil
  end
  return response
end

function query(sql, args, mode)
  local body = json.encode({
    sql = sql,
    args = args or {},
    resource = GetInvokingResource(),
  })

  local future = promise.new()

  PerformHttpRequest('http://localhost:8976/query', function(status, text)
    local data = json.decode(text)

    if data.error then
      future:reject(data.error)
    else
      future:resolve(parse_response(mode, data))
    end
  end, 'POST', body, { ['Content-Type'] = 'application/json' })

  return future
end

function ignore() end

for _, mode in ipairs({ 'query', 'single', 'scalar', 'update', 'insert', 'execute', 'fetch' }) do
  exports(mode, function(sql, args, cb)
    query(sql, args, mode):next(cb, ignore)
  end)

  local function awaitable(sql, args)
    return Citizen.Await(query(sql, args, mode))
  end

  exports(mode..'_async', awaitable)
  exports(mode..'Sync', awaitable)
end