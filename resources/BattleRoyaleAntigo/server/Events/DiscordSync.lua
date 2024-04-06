DiscordSync = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local secret = "MTEwOTU4OTYxNDU0MjQ1NDg5OA.G7tNSd.YN_3Q1Z8WWmOp9rwkmgoLUQSp2D4JqxXtHkcmg"
local guildId = "632657191366557707"
local server_token = "Bot "..secret
local discordTags = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- DiscordRequest - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function DiscordRequest(method,endpoint,jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = { data = resultData, code = errorCode, headers = resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = server_token })

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- HasDiscordRole - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DiscordSync.HasDiscordRole(user_id,role)
    local Query = vRP.query("vRP/requestUser",{ id = user_id })
    local discordId = Query[1].discord

    local theRole = nil
    if type(role) == "number" then
        theRole = tostring(role)
    else
        theRole = role
    end

    if discordId then
        local endpoint = ("guilds/%s/members/%s"):format(guildId,discordId)
        local member = DiscordRequest("GET",endpoint,{})

        if member["code"] == 200 then
            local data = json.decode(member["data"])
            local roles = data["roles"]
            local found = true 
            for i=1,#roles do
                discordTags[user_id] = roles
                if roles[i] == theRole then
                    return true
                end 
            end 
            return false 
        else
            return false
        end
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getDiscordBySource - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DiscordSync.getDiscordBySource(source)
    if source then
        local identifiers = GetPlayerIdentifiers(source)
        for k,v in ipairs(identifiers) do
            if string.match(v,"discord:") then
                return v:gsub("discord:","")
            end
        end
    end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateDiscord - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DiscordSync.UpdateDiscord(source)
	local user_id = vRP.getUserId(source)
    local currentDiscord = DiscordSync.getDiscordBySource(source)
    if currentDiscord == false then return nil end
    local update = false

    local Query = vRP.query("vRP/requestUser",{ id = user_id })
    if Query[1] then
        if Query[1].discord then
            if Query[1].discord ~= currentDiscord then
                update = true
            end
        else
            update = true
        end
    end
    
    if update then
        vRP.execute("vRP/UpdateDiscord", { id = user_id, discord = currentDiscord })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DiscordSync - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("DiscordSync",function()
    return DiscordSync
end)