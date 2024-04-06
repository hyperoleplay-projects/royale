function table.maxn(t)
    local max = 0
    for k, v in pairs(t) do
        local n = tonumber(k)
        if n and n > max then
            max = n
        end
    end
    return max
end

local function wait(self)
    local rets = Citizen.Await(self.p)
    if not rets then
        rets = self.r
    end
    return table.unpack(rets, 1, table.maxn(rets))
end

local function areturn(self, ...)
    self.r = {...}
    self.p:resolve(self.r)
end

Citizen.CreateThread(function()
	while true do
		InvalidateIdleCam()
		N_0x9e4cfff989258472()
		Wait(28000)
	end 
end)

function Async(func)
    if func then
        Citizen.CreateThreadNow(func)
    else
        return setmetatable({
            wait = wait,
            p = promise.new()
        }, {
            __call = areturn
        })
    end
end

local random = math.random

function Guid()
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function Split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function ParseInt(v)
	local n = tonumber(v)
	if n == nil then 
		return 0
	else
		return math.floor(n)
	end
end

function ParseDouble(v)
	local n = tonumber(v)
	if n == nil then n = 0 end
	return n
end

local modules = {}

function moduleEE(rsc, path)
    if path == nil then
        path = rsc
        rsc = "api"
    end
    
    local key = rsc .. path
    local module = modules[key]
    if module then
        return module
    else
        local code = LoadResourceFile(rsc, path .. ".lua")
        if code then
            local f, err = load(code, rsc .. "/" .. path .. ".lua")
            if f then
                local ok, res = xpcall(f, debug.traceback)
                if ok then
                    modules[key] = res
                    return res
                else
                    error("error loading module " .. rsc .. "/" .. path .. ":" .. res)
                end
            else
                error("error parsing module " .. rsc .. "/" .. path .. ":" .. debug.traceback(err))
            end
        else
            error("resource file " .. rsc .. "/" .. path .. ".lua not found")
        end
    end
end

function ExtractVector(coords)
    local array = {}
    for word in string.gmatch(coords, '([^,]+)') do
        table.insert(array, tonumber(word))
    end
    
    return array
end

function IsNilOrEmpty(s)
    return s == nil or s == ''
end
  
function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

function table.empty(self)
    for _,_ in pairs(self) do
        return false
    end
    return true
end

function math.round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function string.lpad(str, len, char)
    if char == nil then char = ' ' end
    return string.rep(char, len - #str)..str
end

function ToPosition(points)
    return {
        Position = vector3(points[1], points[2], points[3]),
        Heading = points[4]
    }
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
 end