local function await(self)
    return table.unpack(Citizen.Await(self))
end

function http_request(url, method, data, headers)
    data = data or ''
    headers = headers or {}

    if type(data) == 'table' then -- serialize input
        data = json.encode(data)
        headers['content-type'] = 'application/json'
    end

    local p = promise.new()

    PerformHttpRequest(url, function(status, data, headers, errorData)
        local parsed = json.decode(data or errorData or '')
        p:resolve({ status, parsed or data, errorData })
    end, method, data, headers)

    p.await = await

    return p
end

local function mix_path(base, path)
    local ends,starts = base:match('/$'),path:match('^/')

    if ends == starts then
        if ends then
            return base .. path:sub(2)
        end
        return base .. '/' .. path
    end
    return base .. path
end

local function mix_headers(...)
    local o = {}
    for _, t in ipairs({...}) do
        for k,v in pairs(t) do o[k] = v end
    end
    return o
end

function API(base_url, base_headers)
    return function(method, url, data, headers)
        local path = mix_path(base_url, url)
        local mixed = mix_headers(base_headers, headers)

        local is_async = method:match('async:')
        local res = http_request(path, method:gsub('async:', ''):upper(), data, mixed)

        if is_async then
            return res
        end
        return res:await()
    end
end