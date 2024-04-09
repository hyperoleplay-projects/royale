
local NuiOpenDashboard = false
local LobbyTheard1 = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- randomSpawnPlayer - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function randomSpawnPlayer()
    local ped = PlayerPedId()
    local randomSpawn = math.random(#Config.Maps["LobbyPrincipal"].spawns)
    SetEntityCoordsNoOffset(ped, Config.Maps["LobbyPrincipal"].spawns[randomSpawn].x, Config.Maps["LobbyPrincipal"].spawns[randomSpawn].y, Config.Maps["LobbyPrincipal"].spawns[randomSpawn].z+1)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, Config.Maps["LobbyPrincipal"].spawns[randomSpawn].w)

	SetTimeout(200,function()
        FreezeEntityPosition(ped, false)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateBattlePass - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateBattlePass() 
    SendReactMessage('BuildDuthBattleXp', {
        duthBattleXp = LocalPlayer.state.duthBattleXp,
    })

    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        SendReactMessage('BuildBattlePass', {
            duthBattlePass = LocalPlayer.state.duthBattlePass,
            duthBattleXp = LocalPlayer.state.duthBattleXp,
            duthBattleLevel = LocalPlayer.state.duthBattleLevel,
            duthBattleItemsFree = Config.Passe["Free"]["mp_m_freemode_01"],
            duthBattleItemsPremium = Config.Passe["Premium"]["mp_m_freemode_01"],
            duthSex = "mp_m_freemode_01"
        })

    elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
        SendReactMessage('BuildBattlePass', {
            duthBattlePass = LocalPlayer.state.duthBattlePass,
            duthBattleXp = LocalPlayer.state.duthBattleXp,
            duthBattleLevel = LocalPlayer.state.duthBattleLevel,
            duthBattleItemsFree = Config.Passe["Free"]["mp_f_freemode_01"],
            duthBattleItemsPremium = Config.Passe["Premium"]["mp_f_freemode_01"],
            duthSex = "mp_f_freemode_01"
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobbyPrincipal - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.JoinLobbyPrincipal() 
    LocalPlayer.state.inLobbyPrincipal = true
    LocalPlayer.state.Buttons = true
    LocalPlayer.state.inDashboard = false 
    LocalPlayer.state.inGame = false 
    LocalPlayer.state.inGameLobby = false
    TriggerEvent("duth:ChatStatus", false)
    
    exports["ui"]:ResetCrouch()
    Citizen.CreateThread(function()
        randomSpawnPlayer()

        local ped = PlayerPedId()
        local pedId = PlayerId()
        SetEntityHealth(ped, 400)
        ClearPlayerWantedLevel(pedId)
        SetCurrentPedWeapon(ped,"WEAPON_UNARMED",true)
        RemoveAllPedWeapons(ped, true)
        ClearPedBloodDamage(ped)
        SetEntityInvincible(PlayerPedId(),false)
        SetEntityVisible(PlayerPedId(),true)
        SetEntityNoCollisionEntity(PlayerPedId(),true,true)
        ClearPedTasks(PlayerPedId())
        ClearPedBloodDamage(PlayerPedId())
        SetRunSprintMultiplierForPlayer(pedId,1.49)
        TriggerEvent("Compass", false)
        TriggerEvent("hideHud")
        TriggerEvent("BuildUI", "DuthMindlle", { status = true })
        SetPedComponentVariation(ped, 9, 0, 0, 1)
        SetGameplayCamRelativeHeading(15)
        NetworkSetTalkerProximity(0.0)
        NetworkClearVoiceChannel()
        NetworkSetVoiceActive(false)

        DisplayRadar(false)

        while LocalPlayer.state.inLobbyPrincipal do
            local wait = 1000
            local ped = PlayerPedId()
            local x,y,z = table.unpack(GetEntityCoords(ped))
            local coords = GetEntityCoords(ped)
            local distance = Vdist(x, y, z, Config.Maps["LobbyPrincipal"].center)
            if distance < Config.Maps["LobbyPrincipal"].radius then
                wait = 1
                if not NuiOpenDashboard then
                    TriggerEvent("BuildUI", "Lobby", { status = true })
                    NuiOpenDashboard = true
                end
                SetEntityHealth(PlayerPedId(), 400)
                DisablePlayerFiring(ped,true)      
                SetEntityInvincible(ped, true)
                SetPedCanSwitchWeapon(ped, false)

                DisableControlAction(2,37,true)
                DisableControlAction(1,45,true)
                DisableControlAction(2,80,true)
                DisableControlAction(2,140,true)
                DisableControlAction(2,250,true)
                DisableControlAction(2,263,true)
                DisableControlAction(2,310,true)
                DisableControlAction(1,140,true)
                DisableControlAction(1,141,true)
                DisableControlAction(1,142,true)
                DisableControlAction(1,143,true)
                DisableControlAction(0,24,true)
                DisableControlAction(0,25,true)
                DisableControlAction(0,58,true)
                DisableControlAction(0,106,true)      
            end
            for k,v in pairs(Config.peds) do
                local distance = #(coords - vector3(v["coords"][1],v["coords"][2],v["coords"][3]))
                if distance <= v["distance"] then
                    if not IsPedInAnyVehicle(ped) then
                        if LuizDev.PedsLobby[k] == nil then
                            local mHash = GetHashKey(v["model"][2])

                            RequestModel(mHash)
                            while not HasModelLoaded(mHash) do
                                Citizen.Wait(1)
                            end

                            if HasModelLoaded(mHash) then

                                LuizDev.PedsLobby[k] = CreatePed(4,v["model"][1],v["coords"][1],v["coords"][2],v["coords"][3] - 1,v["coords"][4],false,true)
                                SetPedArmour(LuizDev.PedsLobby[k],100)
                                SetEntityInvincible(LuizDev.PedsLobby[k],true)
                                FreezeEntityPosition(LuizDev.PedsLobby[k],true)
                                SetBlockingOfNonTemporaryEvents(LuizDev.PedsLobby[k],true)
    
                                if v["clothes"] and type(v["clothes"]) == "table" then
                                    setClothing(LuizDev.PedsLobby[k],v["clothes"])
                                end
    
                                if v["tattoos"] and type(v["tattoos"]) == "table" then
                                    setTattos(LuizDev.PedsLobby[k],v["tattoos"])
                                end
    
                                SetModelAsNoLongerNeeded(mHash)
    
                                if v["anim"] then
                                    if v["anim"][1] ~= nil then
                                        if v["anim"][1] == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then
                                            TaskStartScenarioAtPosition(LuizDev.PedsLobby[k],"PROP_HUMAN_SEAT_CHAIR_MP_PLAYER",v["coords"][1],v["coords"][2],v["coords"][3],v["coords"][4],-1,1,false)
                                        else
                                            RequestAnimDict(v["anim"][1])
                                            while not HasAnimDictLoaded(v["anim"][1]) do
                                                Citizen.Wait(1)
                                            end
    
                                            TaskPlayAnim(LuizDev.PedsLobby[k],v["anim"][1],v["anim"][2],8.0,0.0,-1,1,0,0,0,0)
                                        end
                                    end
                                end
                            end

                        end
                    end
                else
                    if LuizDev.PedsLobby[k] then
                        DeleteEntity(LuizDev.PedsLobby[k])
                        LuizDev.PedsLobby[k] = nil
                    end
                end
            end

            Citizen.Wait(wait)
        end
    end)

    Citizen.CreateThread(function()
        while LocalPlayer.state.inLobbyPrincipal do
            local idle = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for k,v in pairs(Config.peds) do
                local distance = #(coords - vec3(v["coords"][1],v["coords"][2],v["coords"][3]))
                if distance <= 3 then
                    idle = 4
                    if IsControlJustPressed(0,38) then
                        if v["tunnel"] == "server" then
                           serverAPI.OpenMenuNUI(v["type"])
                        end
                    end
                end
            end
            Citizen.Wait(idle)
        end
    end)
end
local idleGame = 1000
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobbyGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.JoinLobbyGame(gameMapName) 
    local ped = PlayerPedId()
    DoScreenFadeOut(1000)
    exports["ui"]:ResetCrouch()
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(600)
    local randomSpawn = math.random(#Config.LobbyGame)
    SetEntityCoordsNoOffset(ped, Config.LobbyGame[randomSpawn].x, Config.LobbyGame[randomSpawn].y, Config.LobbyGame[randomSpawn].z+1)
    LocalPlayer.state.inGameLobby = true
    TriggerEvent("Compass", true)
    TriggerEvent("hideHud")
    TriggerEvent("BuildUI", "DuthMindlle", { status = true })
    TriggerEvent("duth:ChatStatus", true)

    DisplayRadar(false)

    Wait(1500)

    SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    FreezeEntityPosition(PlayerPedId(),false)
    SetPedDiesInWater(PlayerPedId(), 1)

    DoScreenFadeIn(1000)

    for id = 0, 256 do
        if id ~= PlayerId() and NetworkIsPlayerActive(id) then
            NetworkFadeInEntity(GetPlayerPed(id), true)
        end
    end
    local ped = PlayerPedId()
    local pedId = PlayerId()
    SetEntityHealth(ped, 400)
    ClearPlayerWantedLevel(pedId)
    SetCurrentPedWeapon(ped,"WEAPON_UNARMED",true)
    RemoveAllPedWeapons(ped, true)
    ClearPedBloodDamage(ped)
    SetRunSprintMultiplierForPlayer(pedId,1.49)
    idleGame = 1
    
    if not LobbyTheard1 then
        LobbyTheard1 = true
        
        Citizen.CreateThread(function()
            while true do
                if LocalPlayer.state.inGameLobby then
                    idleGame = 1
                    SetEntityHealth(PlayerPedId(), 400)
                    DisablePlayerFiring(ped,true)            
                    DisableControlAction(2,37,true)
                    DisableControlAction(1,45,true)
                    DisableControlAction(2,80,true)
                    DisableControlAction(2,140,true)
                    DisableControlAction(2,250,true)
                    DisableControlAction(2,263,true)
                    DisableControlAction(2,310,true)
                    DisableControlAction(1,140,true)
                    DisableControlAction(1,141,true)
                    DisableControlAction(1,142,true)
                    DisableControlAction(1,143,true)
                    DisableControlAction(0,24,true)
                    DisableControlAction(0,25,true)
                    DisableControlAction(0,58,true)
                    DisableControlAction(0,106,true)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, false)
        
                    local timeValue = LocalPlayer.state.countStartGame
                    local isSeconds = true
                    
                    if timeValue >= 60 then
                        timeValue = timeValue / 60
                        isSeconds = false
                    end
            
                    setDiscordRich("DUTH", "Battle Royale - Jogo iniciando em "..LuizDev.SecondsToClock(timeValue).." segundos.")
                    TriggerEvent("BuildUI", "ContagemLobby", { status = true, time = LuizDev.SecondsToClock(timeValue), typeTime = "s" })
                else
                    idleGame = 5000
                end
        
                Citizen.Wait(idleGame)
            end
        end)
    end


    if #LocalPlayer.state.userTeam['players'] > 1 then
        TriggerEvent("BuildUI", "TeamStatus", { status = true })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitLobbyGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.ExitLobbyGame() 
    local ped = PlayerPedId()
    local pedId = PlayerId()
    SetRunSprintMultiplierForPlayer(pedId,1.0)
    DisablePlayerFiring(PlayerPedId(), false)
    exports["ui"]:ResetCrouch()
    Wait(1000)
    TriggerEvent("BuildUI", "ContagemLobby", { status = false })
    TriggerEvent("BuildUI", "Lobby", { status = false })
    LocalPlayer.state.inDashboard = false
    -- torna o jogador vulnerável novamente quando sair do lobby
    SetEntityInvincible(ped, false)
    SetPedCanSwitchWeapon(ped, true)

    NetworkClearVoiceChannel()
    NetworkSetVoiceActive(true)
    MumbleSetAudioInputIntent(GetHashKey('speech'))
    idleGame = 5000
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitLobbyGame - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ExitLobbyGame")
AddEventHandler("ExitLobbyGame",function(type, data)
    local ped = PlayerPedId()
    local pedId = PlayerId()
    SetRunSprintMultiplierForPlayer(pedId,1.0)
    DisablePlayerFiring(PlayerPedId(), false)
    exports["ui"]:ResetCrouch()
    Wait(1000)
    TriggerEvent("BuildUI", "ContagemLobby", { status = false })
    TriggerEvent("BuildUI", "Lobby", { status = false })
    LocalPlayer.state.inDashboard = false
    -- torna o jogador vulnerável novamente quando sair do lobby
    SetEntityInvincible(ped, false)
    SetPedCanSwitchWeapon(ped, true)

    NetworkClearVoiceChannel()
    NetworkSetVoiceActive(true)
    MumbleSetAudioInputIntent(GetHashKey('speech'))
    idleGame = 5000
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- +openDashboard - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+openDashboard", function() 
    local pedId = PlayerId()
    if LocalPlayer.state.inLobbyPrincipal then
        LocalPlayer.state.inLobbyPrincipal = false
        LocalPlayer.state.inDashboard = true

        DeleteEnitys()
        TriggerEvent("BuildUI", "DuthMindlle", { status = false })

        cam.CreateLobby("CAM_BATTLEROYALE_DASHBOARD")
        toggleNuiFrame(true)
        BuildTeam()

        SetRunSprintMultiplierForPlayer(pedId,1.0)
        DisablePlayerFiring(PlayerPedId(), false)
        exports["ui"]:ResetCrouch()

        TriggerEvent("BuildUI", "LobbyInfos", { status = false })
        NuiOpenDashboard = false
        serverAPI.ExitLobbyPrincipal()
    end
end)
RegisterKeyMapping("+openDashboard","Abrir dashboard principal.","keyboard","F1")
-----------------------------------------------------------------------------------------------------------------------------------------
-- generateSpawnSkinsCoords - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function generateSpawnSkinsCoords()
    local random = math.random(#Config.LobbySkinsPreviws)
    return Config.LobbySkinsPreviws[random]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- generateSpawnSkinsName - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function generateSpawnSkinsName()
    local skins = reMapData(Config.Skins)

    local random = math.random(#skins)
    return skins[random].skin_model
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function reMapData(game_data)
	-- print(dump(game_data))
	-- RED
	local cntRed = 0
	local _redList = game_data
	game_data = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data[cntRed] = v
	end
	return game_data
end
