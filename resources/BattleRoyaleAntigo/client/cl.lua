-----------------------------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------------------------
local LuizDev = moduleEE("client")
local groupType = "solo"
local camTime = nil
local planeModel = "titan"
local buggyModel = "outlaw"
local planeEntity
local pilotModel = "mp_m_freemode_01"
-----------------------------------------------------------------------------------------------------------------------------------------
-- toggleNuiFrame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function toggleNuiFrame(shouldShow)
    DeleteEnitys()
    if shouldShow then
        SetEntityCoords(PlayerPedId(), 1336.516, 3184.252, 39.91993)
        Wait(100)
        LuizDev.RequestAndWaitModel(planeModel)
        LuizDev.RequestAndWaitModel(buggyModel)
    
        local planeEntity = CreateVehicle(GetHashKey(planeModel), Config.LobbyPlanePos, false, 0)
    
        SetModelAsNoLongerNeeded(GetHashKey(planeModel))
        SetEntityInvincible(planeEntity, true)
        SetEntityCollision(planeEntity, 0, 1)
        SetEntityHeading(planeEntity, Config.LobbyPlanePos.w)
        FreezeEntityPosition(planeEntity, true)
        SetVehicleLandingGear(planeEntity, 1)
        Citizen.InvokeNative(0xCFC8BE9A5E1FE575, planeEntity, 0)
        SetVehicleDoorOpen(planeEntity,5,0,0)
    
    
        local buggyEntity = CreateVehicle(GetHashKey(buggyModel), Config.LobbyBuggyPos, false, 0)
    
        SetModelAsNoLongerNeeded(GetHashKey(buggyEntity))
        SetEntityInvincible(buggyEntity, true)
        SetEntityCollision(buggyEntity, 0, 1)
        SetEntityHeading(buggyEntity, Config.LobbyBuggyPos.w)
        FreezeEntityPosition(buggyEntity, true)
        SetVehicleLandingGear(buggyEntity, 1)
        Citizen.InvokeNative(0xCFC8BE9A5E1FE575, planeEntity, 0)
    
        LuizDev.LobbyEnitys[planeEntity] = planeEntity
        LuizDev.LobbyEnitys[buggyEntity] = buggyEntity

        TriggerEvent("duth:ChatStatus", true)
    end
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function remapGrupoCl(game_data)
	local cntRed = 0
	local _redList = game_data.players
	game_data.players = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data.players[cntRed] = v
	end
	return game_data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- OpenLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.OpenLobby(status) 
    DeleteEnitys()

    if status then
        cam.CreateLobby("CAM_BATTLEROYALE_DASHBOARD")
    end
    DisplayRadar(false)

    SendReactMessage('setClientInfos', LocalPlayer.state.userData)
    SendReactMessage('BuildFriends', LocalPlayer.state.userFriends)
    SendReactMessage('BuildButton', LocalPlayer.state.ready)

    toggleNuiFrame(status)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- battleNui:update - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("battleNui:update")
AddEventHandler("battleNui:update",function()
    SendReactMessage('setClientInfos', LocalPlayer.state.userData)
    SendReactMessage('setRequests', LocalPlayer.state.openedRequests)
    SendReactMessage('BuildFriends', LocalPlayer.state.userFriends)
    SendReactMessage('BuildButton', LocalPlayer.state.ready)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CloseLobby - Funciton
-----------------------------------------------------------------------------------------------------------------------------------------
function src.CloseLobby() 
    cam.delete("CAM_BATTLEROYALE_DASHBOARD")
    serverAPI.UpdateMenuStatus(false)
    toggleNuiFrame(false)
    
    SetNuiFocus(false,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CloseLobby - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("CloseLobby")
AddEventHandler("CloseLobby",function(type, data)
    cam.delete("CAM_BATTLEROYALE_DASHBOARD")
    serverAPI.UpdateMenuStatus(false)
    toggleNuiFrame(false)
    
    SetNuiFocus(false,false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- hideFrame - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('hideFrame', function(_, cb)
    if LocalPlayer.state.inDashboard and not LocalPlayer.state.inGame and not LocalPlayer.state.inGameLobby and not LocalPlayer.state.inQueue then
        cam.delete("CAM_BATTLEROYALE_DASHBOARD")
        TriggerEvent("BuildUI", "DuthMindlle", { status = true })

        toggleNuiFrame(false)
        serverAPI.JoinLobbyPrincipal()
        TriggerEvent("duth:ChatStatus", false)
    end
    cb({})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteEnitys - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DeleteEnitys() 
    for k,v in pairs(LuizDev.PedsLobby) do
        if DoesEntityExist(v) then
            DeleteEntity(v)
            LuizDev.PedsLobby = {}
        end
    end

    for k,v in pairs(LuizDev.LobbyEnitys) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
            LuizDev.LobbyEnitys = {}
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
-- onResourceStop - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        DeleteEnitys()
	end
end)
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
-- PlayButton - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("PlayButton", function(data, cb)
    serverAPI.ButtonJogar()
    cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PlayAimLab - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("PlayAimLab", function(data, cb)
    serverAPI.JoinAimLab()
    cb("ok")
end)
