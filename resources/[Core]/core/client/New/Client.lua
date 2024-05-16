----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents = {}
controllerApi = {}
local PlayersBlips = {}
local playerstats = {}
local blips = {}
local Pause = true
local mysquad = {}
local playertags = {}
local textThreadTick = 0
local update = false
local isBeingRevived = false
local NuiRevivePlayer = false
local AnimationRevive = false
local Ped
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildPlayerState - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.BuildPlayerState = function(data) 
    SendReactMessage('BuildPlayerState', {
        Ready = data.ready,
        Leader = data.Leader,
        Match = data.Match,
        Text = data.Text
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateBlips - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.UpdateBlips = function(data) 
    PlayersBlips = data.players
end
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
-- sendServerEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
controllerApi.sendServerEvent = function(eventName, eventData)
    TriggerServerEvent('events_api', {
        event = eventName,
        data = eventData
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CheckOut - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        if LocalPlayer.state.finishGameUI then
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
        end

        Citizen.Wait(1)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CheckOut - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.CheckOut = function(data) 
    local ped = PlayerPedId()
    
    if data.status then
        Hud(false)
        SendReactMessage('buildStatsStatus', false)
        SendReactMessage('buildLogoMidle', false)
        AddKeyHelp({ status = false })
        DisplayRadar(false)
        DoScreenFadeOut(1000)
        SetEntityVisible(PlayerPedId(),false)
        SetEntityNoCollisionEntity(PlayerPedId(),false,false)
        SetEntityCoords(PlayerPedId(), 119.02,-748.49,253.81,65.2)
        SetEntityHealth(PlayerPedId(), 400)
        ClearPedTasks(PlayerPedId())
        ClearPedBloodDamage(PlayerPedId())
        
        Wait(2500)
        DoScreenFadeIn(1000)
        cam.CreateCamCheckout("CAM_CHECKOUT")
    
        cam.setActive("CAM_CHECKOUT")
        cam.render("CAM_CHECKOUT", true, false, 0)

        if Ped then
            DeleteEntity(Ped)
            Ped = nil
        end

        Wait(100)
        if not Ped then
            Ped = ClonePed(PlayerPedId(), GetEntityHeading(PlayerPedId(-1)), true, false)
            SetEntityCoords(Ped, 122.89,-741.15,254.15-1,65.2)
            SetEntityHeading(Ped, 65.2)
            FreezeEntityPosition(Ped, true)
        end
        
        SetNuiFocus(true, true)
        
        if data.type == "Lose" then
            SendReactMessage('BuildHud', {
                type = "Checkout",
                status = true,
                title = "MAIS SORTE DA PRÓXIMA VEZ!",
                pos = data.pos,
                maxPlayers = data.maxPlayers,
                showButtons = true
            })
            playAnim(false,{ "random@car_thief@agitated@idle_a", "agitated_idle_a" },true,Ped)
        else
            SendReactMessage('BuildHud', {
                type = "Checkout",
                status = true,
                title = "VITÓRIA!",
                pos = data.pos,
                maxPlayers = data.maxPlayers,
                showButtons = true
            })
            playAnim(false,{ "rcm_barry2", "clown_idle_6" },true,Ped)
        end
    else
        if Ped then
            DeleteEntity(Ped)
        end
        SetNuiFocus(false, false)
        SendReactMessage('BuildHud', { type = "Checkout", status = false })
        cam.delete("CAM_CHECKOUT")
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.setDiscordRich = function(data)
    SetDiscordAppId(957851467786645554)
	SetDiscordRichPresenceAsset("logo")
	SetRichPresence(data.description)
	SetDiscordRichPresenceAssetText(data.title)
	SetDiscordRichPresenceAction(0,"Jogar","https://discord.com/servers/duth-632657191366557707")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.JoinLobby = function() 
    LocalPlayer.state.inGame = false 
    LocalPlayer.state.inGameLobby = false

    Hud(false)

    TriggerEvent("duth:ChatStatus", false)
    SendReactMessage('buildStatsStatus', false)

    ResetHud()

    exports["vrp"]:ResetCrouch()

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
        SetPedComponentVariation(ped, 9, 0, 0, 1)
        SetGameplayCamRelativeHeading(15)

        DisplayRadar(false)
    end)

    Wait(1000)

    LocalPlayer.state.inDashboard = true

    DeleteEntities()
    
    cam.CreateCamLobby1("CAM_LOBBY1")
    cam.CreateCamLobby("CAM_LOBBY2")
    
    clientApiEvents.BuildPeds({}, false)
    clientApiEvents.BuildGroup({}, false)

    print('Initial', json.encode({ isReady = isPlayerReady() }))

    updateMenuFrame(true, {
        isReady = isPlayerReady(), 
        profile = getPlayerProfile(),
        guild = getPlayerGuildTag(),
        groupMembers = getPlayerGroupMembers(),
        match = getPlayerQueue(),
    })
    
    SendReactMessage('buildLogoMidle', false)

    AddKeyHelp({ status = false })
    DisablePlayerFiring(PlayerPedId(), false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildPeds - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.BuildPeds = function(data) 
    for k,v in pairs(LuizDev.PedsClient) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end
    
    if data.status then
        mysquad = data.tabela
    end

    if mysquad.playersCount > 1 then
        Config.spawnLoc[1] = Config.spawnLoc[5]
    else
        Config.spawnLoc[1] = Config.spawnLoc[6]
    end
    
    for k,v in pairs(mysquad.players) do
        if v.state then
            local data = json.decode(v.currentCharacterMode)
            local cModelHash = data.skin
    
            RequestModel(cModelHash)
            
            while not HasModelLoaded(cModelHash) do
                Citizen.Wait(1)
            end
    
            if HasModelLoaded(cModelHash) then
                LuizDev.PedsClient[v.user_id] = CreatePed(4,cModelHash, Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, Config.spawnLoc[v.pos].z, Config.spawnLoc[v.pos].w,false,false)
                
                SetEntityInvincible(LuizDev.PedsClient[v.user_id], true)
                FreezeEntityPosition(LuizDev.PedsClient[v.user_id], true)
                SetBlockingOfNonTemporaryEvents(LuizDev.PedsClient[v.user_id], true)
                SetModelAsNoLongerNeeded(cModelHash)
    
                LuizDev.TaskUpdateSkinOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateFaceOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateHeadOptions(LuizDev.PedsClient[v.user_id], data)

                setClothing(LuizDev.PedsClient[v.user_id], json.decode(v.Clothes))
                setTattos(LuizDev.PedsClient[v.user_id], v.Tatuagens)

                playAnim(false,{ Config.AnimationsPed[v.pos][1], Config.AnimationsPed[v.pos][2] },Config.AnimationsPed[v.pos][3],LuizDev.PedsClient[v.user_id])
            end
            
            cam.setActive("CAM_LOBBY1")
            cam.render("CAM_LOBBY1", true, false, 0)
            cam.setActive("CAM_LOBBY2")
            cam.switchToCam("CAM_LOBBY2", "CAM_LOBBY1", 1850)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildGroup - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.BuildGroup = function(data) 
    if data.status then
        mysquad = data.tabela
    end

    SendReactMessage('setPlayersGroup', LuizDev.reMapData(mysquad.players))

    if mysquad.playersCount > 1 then
        UpdateNames()
        CreatePlayerBlips()
        noDamage()

		CreateThread(function()
            while true do
                local sleep = 2000
                sleep = 500
                sendstat()
                Wait(sleep)
            end
        end)
    else
        activeDamage()  
    end

    SendReactMessage('BuildGroup', {
        players = LuizDev.reMapData(mysquad.players),
        global = mysquad
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- sendInviteGroup - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('sendGroup', function(data, cb)
    controllerApi.sendServerEvent('InviteGroup', { id = data.id, type = data.type })
    cb({})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- sendInviteGroup - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('PlayButton', function(data, cb)
    controllerApi.sendServerEvent('Play', { type = data.type, Gamemode = data.Gamemode, code = data.code })
    cb({})
end)

RegisterNetEvent('test:startGameForced', function()
    TriggerServerEvent('test:startGameForced', { type = "Start", Gamemode = "SOLO" })
end)
-----------------------------------------------------------------------------------------
-- noDamage - Function
-----------------------------------------------------------------------------------------
function noDamage()
	if mysquad.playersCount > 1 then
		local playerPed = PlayerPedId()
		local group = "squad"..mysquad.TeamId
		local _, hash = AddRelationshipGroup(group)
		SetPedRelationshipGroupHash(playerPed, hash)
		SetEntityCanBeDamagedByRelationshipGroup(playerPed, false, hash)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetPlayers - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetAgonizing(source)
    local players = LuizDev.reMapData(mysquad.players or {})

    for _, player in pairs(players) do 
        if player.source == source then
            if not player.death then
                return player.agonizing
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetAgonizingStatus(source)
    local players = LuizDev.reMapData(mysquad.players or {})

    for _, player in pairs(players) do 
        if player.source == source then
            if not player.death then
                return player.isReviving
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetClosestPlayer - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for index, value in ipairs(players) do
        local targetPed = GetPlayerPed(value)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = GetDistanceBetweenCoords(playerCoords, targetCoords, true)

            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer
end
-----------------------------------------------------------------------------------------
-- Thread 2 - Function
-----------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        if not IsEntityDead(PlayerPedId()) and not reviving then
            local closestPlayer = GetClosestPlayer()
            if closestPlayer ~= -1 then
                local playerPedCoords = GetEntityCoords(playerPed)
                local targetPedCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
                local distance = #(playerPedCoords - targetPedCoords)
                if distance <= 2.0 then
                    isBeingRevived = true
                end
            end
        end
    end
end)
-----------------------------------------------------------------------------------------
-- Thread 1 - Function
-----------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local closestPlayer = GetClosestPlayer()
        if closestPlayer ~= -1 then
            local playerPedCoords = GetEntityCoords(playerPed)
            local targetPedCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
            local distance = #(playerPedCoords - targetPedCoords)
            local statusAgonizing = GetAgonizing(GetPlayerServerId(closestPlayer))

            if distance <= 1.0 and statusAgonizing and not LocalPlayer.state.death and not LocalPlayer.state.agonizing and not LocalPlayer.state.inPlane and not LocalPlayer.state.inSpec and not GetAgonizingStatus(GetPlayerServerId(closestPlayer)) and not LocalPlayer.state.inLobbyPrincipal and not LocalPlayer.state.inGameLobby then
                if not NuiRevivePlayer then
                    AddKeyboardInfo({
                        status = true,
                        key = "F",
                        text = "Reviver jogador"
                    })
                    NuiRevivePlayer = true
                end

                if IsControlJustPressed(0, 49) and not AnimationRevive then
                    AnimationRevive = true
                    local animName = "mini@cpr@char_a@cpr_str"
                    local animName2 = "cpr_pumpchest"
                    while ( not HasAnimDictLoaded( animName ) ) do
                        RequestAnimDict( animName )
                        Citizen.Wait( 5 )
                    end
    
                    TaskPlayAnim(PlayerPedId(), animName, animName2, 8.0, 1.0, -1, 1, 0, false, false, false)
                    controller.sendServerEvent('ReviveAgonizing', {
                        source = GetPlayerServerId(closestPlayer),
                        type = "Inicio"
                    })

                    local playerPedTeam = GetPedRelationshipGroupHash(playerPed)
                    local closestPlayerTeam = GetPedRelationshipGroupHash(GetPlayerPed(closestPlayer))
            
                    if playerPedTeam == closestPlayerTeam and statusAgonizing then
                        SetTimeout(7000,function()
                            if LocalPlayer.state.isReviving then
                                controller.sendServerEvent('ReviveAgonizing', {
                                    source = GetPlayerServerId(closestPlayer),
                                    type = "Final"
                                })
                                ClearPedSecondaryTask(PlayerPedId())
                                ClearPedTasks(PlayerPedId())

                                Wait(500)
                                AddKeyboardInfo({ status = false })
                                NuiRevivePlayer = false
                                AnimationRevive = false
                            end
                        end)
                    end
                end
            else
                if NuiRevivePlayer then
                    AddKeyboardInfo({ status = false })
                    NuiRevivePlayer = false
                    AnimationRevive = false
                end
            end
        end
    end
end)
-----------------------------------------------------------------------------------------
-- activeDamage - Function
-----------------------------------------------------------------------------------------
function activeDamage()
	local playerPed = PlayerPedId()
	SetPedRelationshipGroupHash(playerPed, "PLAYER")
	SetEntityCanBeDamagedByRelationshipGroup(playerPed, true, "PLAYER")
end
-----------------------------------------------------------------------------------------
-- sendstat - Function
-----------------------------------------------------------------------------------------
function sendstat()
    if LocalPlayer.state.inGame then
        local players = LuizDev.reMapData(mysquad.players)
        for i = 1, #players do
            ::try::
            if players[i] == nil then goto try return end
    
            local player = GetPlayerFromServerId(players[i].source)
            local ped = GetPlayerPed(player)
            local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
            if playerstats[players[i].hexlast] == nil then
                playerstats[players[i].hexlast] = { hp = 0, armour = 0, username = "Not load", avatar = "[]", user_id = 0, color = 0 }
            else
                playerstats[players[i].hexlast] = { hp = playerstats[players[i].hexlast].hp, armour = playerstats[players[i].hexlast].armour, username = playerstats[players[i].hexlast].username, avatar = playerstats[players[i].hexlast].avatar, user_id = playerstats[players[i].hexlast].user_id, color = playerstats[players[i].hexlast].color }
            end

            if not players[i].death then
                local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
                local nowhp = (GetEntityHealth(ped) - 100 ) / 3

                -- local nowhp = parseInt((100*GetEntityHealth(ped)/GetEntityMaxHealth(ped)))
                local nowarmour = GetPedArmour(ped)
                local armour = nowarmour
                playerstats[players[i].hexlast].user_id = players[i].user_id
                playerstats[players[i].hexlast].username = players[i].username
                playerstats[players[i].hexlast].avatar = players[i].avatar
                playerstats[players[i].hexlast].color = players[i].color
                playerstats[players[i].hexlast].hp = nowhp
                playerstats[players[i].hexlast].armour = armour
            end
            
            if _distance > 1 then
                SendReactMessage('buildStats', playerstats)
            end
        end
    
    end
end
-----------------------------------------------------------------------------------------
-- UpdateNames - Function
-----------------------------------------------------------------------------------------
function UpdateNames() 
    CreateThread(function()
        while true do
            if LocalPlayer.state.inGame and not LocalPlayer.state.inPlane and not LocalPlayer.state.inSpec then
                local players = LuizDev.reMapData(mysquad.players)

                for k,v in pairs(playertags) do
                    RemoveMpGamerTag(v)
                end
                playertags = {}

                Wait(100)

                for i = 1, #players do
                    if players[i] == nil then return end
                    local player = GetPlayerFromServerId(players[i].source)
                    local ped = GetPlayerPed(player)
                
                    local isLocalPlayer = players[i].source == GetPlayerServerId(PlayerId())
                
                    local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
                    if _distance > 1 and not players[i].death and not isLocalPlayer and not LocalPlayer.state.inPlane then
                        if playertags[players[i].hexlast] == nil then
                            local tag = CreateFakeMpGamerTag(ped, players[i].username, 0, 0, "", 0)
                                                
                            SetMpGamerTagVisibility(tag, 0, true)
                            SetMpGamerTagVisibility(tag, 10, true)
                            SetMpGamerTagColour(tag, 10, players[i].color["colorTag"])
                
                            playertags[players[i].hexlast] = tag
                        end
                    else
                        if playertags[players[i].hexlast] then
                            RemoveMpGamerTag(playertags[players[i].hexlast])
                            playertags[players[i].hexlast] = nil
                        end
                    end
                    -- Wait(100)
                end
            end
            Wait(3 * 2000)
        end
    end)
end
-----------------------------------------------------------------------------------------
-- CreatePlayerBlips - Function
-----------------------------------------------------------------------------------------
function CreatePlayerBlips() 
    CreateThread(function()
        while true do
            if LocalPlayer.state.inGame and not LocalPlayer.state.inPlane and not LocalPlayer.state.inSpec then
                if IsPauseMenuActive() then
                    if not Pause then
                        Pause = true

                        for _,bli in pairs(blips) do
                            RemoveBlip(bli)
                        end

                        blips = {}
                    end

                    controllerApi.sendServerEvent('playerGroupList', { })

                    Wait(100)
                    local listPlayers = LuizDev.reMapData(PlayersBlips)


                    for Number,v in pairs(listPlayers) do
                        local isLocalPlayer = listPlayers[Number].source == GetPlayerServerId(PlayerId())

						if blips[Number] then
							SetBlipCoords(blips[Number],v["Coords"])
                        elseif not isLocalPlayer then
							blips[Number] = AddBlipForCoord(v["Coords"])
							SetBlipSprite(blips[Number],1)
							SetBlipDisplay(blips[Number],4)
							SetBlipAsShortRange(blips[Number],true)
                            SetBlipColour(blips[Number], listPlayers[Number].color["colorBlip"])
							SetBlipScale(blips[Number],0.7)
							BeginTextCommandSetBlipName("STRING")
                            AddTextComponentString(listPlayers[Number].username)
							EndTextCommandSetBlipName(blips[Number])
						end
					end
                else
                    if Pause then
                        Pause = false

                        for _,bli in pairs(blips) do
                            RemoveBlip(bli)
                        end

                        blips = {}
                    end

                    local players = LuizDev.reMapData(mysquad.players)

                    for Number,v in pairs(players) do
						if players[Number] then
							if not blips[Number] then
                                local player = GetPlayerFromServerId(players[Number].source)
                                local ped = GetPlayerPed(player)
                                local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
                                if _distance > 1 and not players[Number].death then
                                    local blip = AddBlipForEntity(ped)
                                    SetBlipSprite(blip,1)
                                    SetBlipDisplay(blip,4)
                                    SetBlipShowCone(blip,true)
                                    SetBlipAsShortRange(blip,true)
                                    SetBlipScale(blip,0.7)
                                    SetBlipColour(blip, players[Number].color["colorBlip"])
                                    BeginTextCommandSetBlipName("STRING")
                                    AddTextComponentString(players[Number].username)
                                    EndTextCommandSetBlipName(blip)
                    
                                    blips[Number] = blip
                                end
                                
							end
						else
							if blips[Number] then
								RemoveBlip(blips[Number])
								blips[Number] = nil
							end
						end
					end
                end
            end
    
            Wait(5000)
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- hideFrame - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('hideFrame', function(_, cb)
    cb({ })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- events_controllerApi - Function
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('events_controllerApi')
AddEventHandler('events_controllerApi', function(sv_content)
    local eventName = sv_content.event
    local data = sv_content.data

    print('EVENTO RECEBIDO: ' .. eventName, clientApiEvents[eventName] ~= nil , json.encode(data))
    if clientApiEvents[eventName] ~= nil then
        clientApiEvents[eventName](data)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC : THREADTIMERS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
		SetWeatherTypeNow("CLEAR")
		SetWeatherTypePersist("CLEAR")
		SetWeatherTypeNowPersist("CLEAR")
		NetworkOverrideClockTime(12,00,00)
        Citizen.Wait(0)
    end
end)
