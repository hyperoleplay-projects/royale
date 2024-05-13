----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local LuizDev = moduleEE("client")
local fpsStats = false
local cache = {}
local cache_timeout = {}
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
cRP = {}
Tunnel.bindInterface("core",cRP)
vSERVER = Tunnel.getInterface("duth")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CloseLobby - Funciton
-----------------------------------------------------------------------------------------------------------------------------------------
function src.CloseLobby() 
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")
    
    updateMenuFrame(false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteEntities - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DeleteEntities() 
    for k,v in pairs(LuizDev.PedsLobby) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
            LuizDev.PedsLobby = {}
        end
    end

    for k,v in pairs(LuizDev.LobbyEntities) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
            LuizDev.LobbyEntities = {}
		end
	end

    for k,v in pairs(LuizDev.PedsClient) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
            LuizDev.PedsClient = {}
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- f - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function f(n)
	n = n + 0.00000
	return n
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DUMP - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- foto - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("foto", function() 
    local ped = PlayerPedId()
    if not travado then
        travado = true
        FreezeEntityPosition(PlayerPedId(), true)
        TriggerEvent("Notify","inform", "Você se travou com sucesso!")
    else
        travado = false
        FreezeEntityPosition(PlayerPedId(), false)
        local x,y,z = table.unpack(GetEntityCoords(ped))
        NetworkResurrectLocalPlayer(x,y,z,true,true,false)
        TriggerEvent("Notify","inform", "Você se destravou com sucesso!")
    end
    Citizen.CreateThread(function()
        while travado do 
            Citizen.Wait(0)
            TaskPlayAnim(PlayerPedId(), 'move_f@multiplayer', 'idle', 8.0, -8, -1, 16, 0, 0, 0, 0);
        end
    end)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- renewCacheInfoAndSendCB - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function renewCacheInfoAndSendCB(data, cb)
    local res = vSERVER.requestData(data.name, data)
    if (data.cacheTime) then
        cache_timeout[data.name] = GetGameTimer() + parseInt(data.cacheTime) -- Atualizar cache a cada X ms
        data.cacheTime = nil
    else
        cache_timeout[data.name] = GetGameTimer() + 30000 -- Atualizar cache a cada 30ss
    end
    if res._timeout ~= nil then res._timeout = nil end

    cache[data.name] = res
    cb(cache[data.name])
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- requestInfo - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestInfo", function(data, cb)
    if (cache[data.name]) then
        local res = cache[data.name]
        if cache_timeout[data.name] >= GetGameTimer() then
            return cb(res)
        else
            renewCacheInfoAndSendCB(data, cb)
        end
    else
        renewCacheInfoAndSendCB(data, cb)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- requestInfoNoCache - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestInfoNoCache", function(data, cb)
    local res = vSERVER.requestData(data.name, data)
    cb(res)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- executeEvent - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("executeEvent",function(data, cb)
    -- print('EXECUTE EVENT: '..json.encode(data))
    return cb(vSERVER.requestData(data.name, data))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- clearInfoCache - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.clearInfoCache(name)
    if (cache[name]) then
        cache[name] = nil
        cache_timeout[name] = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdatePayment - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.UpdatePayment(name, data) 
    SendReactMessage(name, data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- hideUI - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('hideUI', function(data, cb)
    if data.type == "Modal" then
        SetNuiFocus(false, false)
        
        SendReactMessage('setVisible', false)
    end

    cb({})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  fps - Function
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fps",function()
    if not fpsStats then
        SetTimecycleModifier("cinema")
        fpsStats = true
    else
        SetTimecycleModifier("default")
        fpsStats = false
    end
end)



-- -522.30877685547	269.26068115234	133.2211151123
-- 74.156677246094	-440.12521362305	91.433723449707
-- 7.5318646430969	-410.02325439453	114.1502532959
-- 186.49551391602	-955.59661865234	105.54113769531
-- -68.320793151855	-970.92401123047	63.869239807129
-- -1295.0617675781	-924.5205078125	33.763355255127
-- -1365.3435058594	-278.50375366211	67.598350524902
-- -793.80572509766	684.26202392578	232.93112182617
-- -130.74501037598	711.15631103516	244.9322052002
-- 187.43548583984	188.98638916016	164.95274353027
-- 257.41952514648	-176.85209655762	111.95938110352
-- 231.15147399902	-883.26196289063	44.360664367676

RegisterCommand("addSafe", function() 
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
    
    
    local blip = AddBlipForRadius(x,y,z, 2400.0)
    SetBlipSprite(blip, 10)
    SetBlipDisplay(blip, 8)
    SetBlipColour(blip, 75)
    SetBlipAlpha(blip, 75)

    print(x,y,z)
end)