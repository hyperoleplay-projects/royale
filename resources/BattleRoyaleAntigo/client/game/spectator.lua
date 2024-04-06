local spectatingPlayer = nil
local spectatingPlayers = nil
local isReturnLobby = false
local SpecTheard = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- prevSpectator
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+prevSpectator","A","keyboard","A")
RegisterCommand("+prevSpectator",function(source,args,rawCommand)
	if spectatingPlayers ~= nil and spectatingPlayer ~= nil and LocalPlayer.state.inSpec then
        local newKey = spectatingPlayer.pos-1
        if spectatingPlayers[newKey] == nil then
            newKey = #spectatingPlayers-1
        end
        serverAPI.setSpectatorTarget(newKey, spectatingPlayers[newKey].source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- nextSpectator
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+nextSpectator","D","keyboard","D")
RegisterCommand("+nextSpectator",function(source,args,rawCommand)
	if spectatingPlayers ~= nil and spectatingPlayer ~= nil and LocalPlayer.state.inSpec then
        local newKey = spectatingPlayer.pos+1
        if spectatingPlayers[newKey] == nil then
            newKey = 0
            newKey = #spectatingPlayers-1
        end
        serverAPI.setSpectatorTarget(newKey, spectatingPlayers[newKey].source)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- initSpectator - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.initSpectator(data) 
    if getTableSize(data.players) > 0 and data.target ~= nil then
        spectatingPlayers = data.players
        LocalPlayer.state.inSpec = true
        setSpectatorTarget(data.target, data.coords)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- updateTableSpec - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.updateTableSpec(data) 
    spectatingPlayers = data.players
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTarget - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.setSpectatorTarget(key, coords)
    setSpectatorTarget(key, coords)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTarget - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setSpectatorTarget(key, coords)
    local targetPlayer = spectatingPlayers[key]
    if targetPlayer == nil then return nil end

    local pid = GetPlayerFromServerId(targetPlayer.source)
    local targetEntity = GetPlayerPed(pid)

    local newSpectateCoords = calculateSpectatorCoords(coords)
    SetEntityCoords(PlayerPedId(), newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, 0, 0, 0, false)

    if DoesEntityExist(targetEntity) then
        local ped = PlayerPedId()
        NetworkSetInSpectatorMode(true, targetEntity)
        SetPlayerInvincible(ped, true)
        SetEntityNoCollisionEntity(ped, targetEntity, false) -- DESATIVAR COLISÕES ENTRE OS JOGADORES
        NetworkOverrideSendRestrictions(targetEntity, false) -- DESATIVAR VOIP ENTRE OS JOGADORES
        TriggerEvent("BuildUI", "Spectador", { status = true, username = targetPlayer.username })
        TriggerEvent("BuildUI", "DuthMindlle", { status = true })
        TriggerEvent("showHud")
        TriggerEvent("Compass", false)
        spectatingPlayer = targetPlayer
    end


    if not SpecTheard then
        SpecTheard = true
        CreateThread(function()
            while true do
                Wait(50)
                if spectatingPlayer ~= nil and LocalPlayer.state.inSpec then
                    local pid = GetPlayerFromServerId(spectatingPlayer.source)
                    local targetEntity = GetPlayerPed(pid)
                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))
                    SetEntityCoords(PlayerPedId(), newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, 0, 0, 0, false)
        
                    local nowhp = parseInt((100*GetEntityHealth(targetEntity)/GetEntityMaxHealth(targetEntity)))
                    local nowarmour = GetPedArmour(targetEntity)
                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))
                    NetworkSetInSpectatorMode(true, targetEntity)
        
                    TriggerEvent("BuildUI", "setVida", { vida = nowhp })
                    TriggerEvent("BuildUI", "setColete", { colete = nowarmour })
                end
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- stopSpectatorMode - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.stopSpectatorMode()
    local pid = GetPlayerFromServerId(spectatingPlayer.source)
    local targetEntity = GetPlayerPed(pid)
    local ped = PlayerPedId()
    spectatingPlayer = nil
	NetworkSetInSpectatorMode(false, targetEntity)
    SetPlayerInvincible(ped, false)
    SetEntityNoCollisionEntity(ped, targetEntity, false) -- ATIVAR COLISÕES ENTRE OS JOGADORES
    NetworkOverrideSendRestrictions(targetEntity, true) -- ATIVAR VOIP ENTRE OS JOGADORES
    NetworkSetOverrideSpectatorMode(false)
    SetEntityVisible(ped, true)
    LocalPlayer.state.inSpec = false
    
    spectatingPlayers = nil
    TriggerEvent("BuildUI", "Spectador", { status = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- calculateSpectatorCoords - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function calculateSpectatorCoords(coords)
    return vec3(coords[1], coords[2], coords[3] - 30.0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- endGameSpec - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+endGameSpec", function() 
    if not isReturnLobby and LocalPlayer.state.inSpec then
        isReturnLobby = true
        serverAPI.endGame()
        SetTimeout(5000, function()
            isReturnLobby = false
        end)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- endGameSpec - Key
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+endGameSpec","Sair da partida.","keyboard","F7")
-----------------------------------------------------------------------------------------------------------------------------------------
-- returnLobby - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("returnLobby", function(data, cb)
    if not isReturnLobby then
        isReturnLobby = true
        serverAPI.endGame()
        SetTimeout(5000, function()
            isReturnLobby = false
        end)
    end
    cb("ok")
end)