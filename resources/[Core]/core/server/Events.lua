
local events = {
    GetPlayersCountGame = true,
    RandomMap = true,
    GetFreeRoutingBucket = true,
    sendPlayerEvent = true,
    sendEventPlayersEvent = true,
    StartGame = true,
    GetGamesForType = true,
    HostGame = true,
    sendEventSpectatorsEvent = true,
    JoinGame = true,
    LeaveGame = true,
    BuildGameUI = true,
    SetupLoots = true,
    ExitPlaneDimension = true,
    GetLoot = true,
    GetPlayersInPlaneClient = true,
    RegisterKill = true,
    SendKillGame = true,
    endGame = true,
    endSpec = true,
    setSpectatorTargetServer = true,
    RequestSpectator = true,
    PreparesStartGameNew = true,
    ReviveAgonizing = true,
    FinishAgonizingGame = true,
    AlterDimension = true,
    StartGameNew = true,
}

local eventsApi = {
    InviteGroup = true,
    ExitLobby = true,
    JoinLobby = true,
    Play = true,
    SetLocationMarkerServer = true,
    RemoveLocationMarkerServer = true,
    UpdatePed = true,
    playerGroupList = true,
}

RegisterNetEvent('events_controller')
AddEventHandler('events_controller', function(cl_content)
    local src = source
    local eventName = cl_content.event
    local data = cl_content.data

    if GameController[eventName] ~= nil and events[eventName] == true then
        return GameController[eventName](src, data)
    end
end)

RegisterNetEvent('events_api')
AddEventHandler('events_api', function(cl_content)
    local src = source
    local eventName = cl_content.event
    local data = cl_content.data

    if ApiController[eventName] ~= nil and eventsApi[eventName] == true then
        return ApiController[eventName](src, data)
    end
end)

AddEventHandler("playerDropped",function()
	local src = source
    local user_id = vRP.getUserId(src)

    if Player(src).state.inQueue or Player(src).state.inGame or Player(src).state.inGameLobby then
        if user_id then
            GameController.LeaveGame({
                source = src,
                user_id = user_id
            })
        end
    end
end)