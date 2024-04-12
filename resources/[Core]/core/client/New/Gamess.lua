----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local planeModel = "titan"
local pilotModel = "mp_m_freemode_01"
local plane = nil
local inPlane = false
local AdminSpec = false
local Cursor = false
local NuiOpenDashboard = false
local LobbyTheard1 = nil
local StartGame = false
local cooldown = 0
local idleGame = 1000
local coordinatesProcessed = 0
clientEvents = {}
controller = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PickUps = {}
local reviving = false
local EndGame = false
local GameTheard1 = false
local GameTheard2 = false
local GameTheard3 = false
local SpecTheard = false
local adrenaline = false
local adrenalineItem = false
local allPickups = {}
local lastItem = ""
local closestPickups = {}
local Vehicles = {}
local Ped = PlayerPedId()
local lootsTheard1 = nil
local spectatingPlayer = nil
local spectatingPlayers = nil
local isReturnLobby = false
local SpecTheard = nil
local lootsTheard2 = nil
local LuizDev = moduleEE("client")
local nearbyItems = {}
local isHudBuilt = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- ItemExists - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function ItemExists(itemName)
    for _, item in pairs(nearbyItems) do
        if item.name == itemName then
            return true
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddItemToTable - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function AddItemToTable(itemName, itemIndex)
    if not ItemExists(itemName) then
        table.insert(nearbyItems, {
            name = itemName,
            index = itemIndex
        })

        if not isHudBuilt then
            isHudBuilt = true
            SendReactMessage('BuildHud', {
                type = "ItemDrop",
                status = true,
            })
        end

        SendReactMessage('BuildHud', {
            type = "ItemDropData",
            items = LuizDev.reMapData(nearbyItems),
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RemoveItemFromTable - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function RemoveItemFromTable(itemName)
    local indicesToRemove = {}
    local shouldUpdateHud = false

    for i, item in ipairs(nearbyItems) do
        table.remove(nearbyItems, i)
    end

    if #nearbyItems == 0 then
        isHudBuilt = false
        shouldUpdateHud = true
    end

    if shouldUpdateHud then
        SendReactMessage('BuildHud', {
            type = "ItemDrop",
            status = isHudBuilt,
        })
    end

    SendReactMessage('BuildHud', {
        type = "ItemDropData",
        items = LuizDev.reMapData(nearbyItems),
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setLabelNUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.setLabelNUI = function(data) 
    SendReactMessage('BuildPlayerState', {
        Ready = data.ready,
        Leader = data.Leader,
        Match = data.Match,
        Text = data.Text
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SeatInPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
controller.SeatInPlane = function()
    local planeModel = GetEntityModel(plane)
    local totSeat = GetVehicleModelNumberOfSeats(planeModel)
    local freeSeat = nil
    
    for i = -1, totSeat - 2 do
        local ped = GetPedInVehicleSeat(plane, i)
        if ped == 0 then
            freeSeat = i
            break
        end
    end
    
    if freeSeat ~= nil then
        SetPedIntoVehicle(PlayerPedId(), plane, freeSeat)
        inPlane = true
        return true
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- sendServerEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
controller.sendServerEvent = function(eventName, eventData)
    TriggerServerEvent('events_controller', {
        event = eventName,
        data = eventData
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.BuildGame = function(data)
    if data.rich then
        setDiscordRich("DUTH", "Battle Royale - Jogo em andamento "..data.players.." restantes.")
    end


    TriggerEvent("BuildGame", { status = data.status, safe = false, kills = data.kills or 0, safeTime = "00:00", players = data.players, updatePlayers = true, updateKills = true })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.StopPlane = function() 
    local ped = PlayerPedId()
    local playerPed = GetPlayerPed(-1)

    SetEntityAsMissionEntity(driver, 1, 1)
    SetEntityAsMissionEntity(driver2, 1, 1)
    SetEntityAsMissionEntity(plane, 1, 1)
    NetworkRequestControlOfEntity(plane)
    NetworkRequestControlOfEntity(driver)
    NetworkRequestControlOfEntity(driver2)
    while not NetworkHasControlOfDoor(plane) do print("wait") Citizen.Wait(0) end
    DeleteEntity(driver)
    DeleteEntity(driver2)
    if plane then
        DeleteEntity(plane)
    end
    plane = false

    if inPlane then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        ClearPedTasks(playerPed, true)
        TaskLeaveVehicle(playerPed, vehicle, 64)
        RemoveAllPedWeapons(playerPed, false)
        
        local coords = GetEntityCoords(playerPed)
        SetPedGadget(playerPed, GetHashKey("GADGET_PARACHUTE"), true)
        GiveWeaponToPed(playerPed, "GADGET_PARACHUTE", 1, false, false)
        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z-5.5, true, true, true) 
        
        SetPlayerHasReserveParachute(PlayerId())
        SetPedReserveParachuteTintIndex(math.random(0,7))
                
        SetPlayerCanLeaveParachuteSmokeTrail(PlayerId(), true)
        ForcePedToOpenParachute(PlayerPedId())

        inPlane = false
        controller.sendServerEvent('ExitPlaneDimension', {})
        AddKeyboardInfo({ status = false })
        AddAnnouncement({ status = false })
        inPlaneMessage = false


        NetworkSetTalkerProximity(2.0)
        NetworkClearVoiceChannel()
        NetworkSetVoiceActive(true)
    
        local ped = PlayerPedId()
        local height = GetEntityHeightAboveGround(ped)
        local waitingFall = true
        while waitingFall do
            height = GetEntityHeightAboveGround(ped)
            if height < 80 then
                ForcePedToOpenParachute(ped)
                if GetPedParachuteState(ped) == -1 and not IsPedInParachuteFreeFall(ped) then
                    waitingFall = false
                end
            end
    
            Wait(20)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- debug - Function
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("debug", function() 
    -- Fechar o lobby
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")
    toggleNuiFrame(false)
    SetNuiFocus(false,false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JumpPlayerFolloWing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.JumpPlayerFolloWing = function(data) 
    print("Pulou")
    if inPlane and LocalPlayer.state.IsFollowingTeam then
        local ped = PlayerPedId()
        local playerPed = GetPlayerPed(-1)

        if IsPedInAnyVehicle(ped) then
            if iCarry then
                iCarry = false
                DetachEntity(GetPlayerPed(GetPlayerFromServerId(uCarry)),false,false)
            end
    
            TaskLeaveVehicle(ped,GetVehiclePedIsUsing(ped),4160)
        end

        SetEntityVisible(PlayerPedId(),true)
        SetEntityNoCollisionEntity(PlayerPedId(),true,true)
        DisplayRadar(true)
        Hud(true)

        local vehicle = GetVehiclePedIsIn(playerPed, false)
        ClearPedTasks(playerPed, true)
        TaskLeaveVehicle(playerPed, vehicle, 64)
        RemoveAllPedWeapons(playerPed, false)

        local coords = GetEntityCoords(playerPed)
        SetPedGadget(playerPed, GetHashKey("GADGET_PARACHUTE"), true)
        GiveWeaponToPed(playerPed, "GADGET_PARACHUTE", 1, false, false)
        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z-5.5, true, true, true) 

        inPlane = false
        controller.sendServerEvent('ExitPlaneDimension', {})
        NetworkSetTalkerProximity(2.0)
        NetworkClearVoiceChannel()
        NetworkSetVoiceActive(true)

        AddKeyboardInfo({ status = false })
        inPlaneMessage = false

        -- Bota o ped visivel denovo
        NetworkFadeInEntity(ped, true)

        local height = GetEntityHeightAboveGround(ped)
        local waitingFall = true
        while waitingFall do
            height = GetEntityHeightAboveGround(ped)
            if height < 80 then
                ForcePedToOpenParachute(ped)
                if GetPedParachuteState(ped) == -1 and not IsPedInParachuteFreeFall(ped) then
                    waitingFall = false
                end
            end
    
            Wait(20)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StartGameClient - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.StartGameClient = function(data)
    local ped = GetPlayerPed(-1)
    local pedPlayer = PlayerPedId()
    local pedId = PlayerId()
    
    
    -- Fechar o lobby
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")
    toggleNuiFrame(false)
    SetNuiFocus(false,false)
    
    -- Volta as estações do jogador pro padrão
    DisablePlayerFiring(PlayerPedId(), false)
    exports["vrp"]:ResetCrouch()
    SendReactMessage('buildLogoMidle', true)
    
    SetEntityInvincible(pedPlayer, false)
    SetPedCanSwitchWeapon(pedPlayer, true)

    LocalPlayer.state.inDashboard = false
    LocalPlayer.state.inGameLobby = false
    print('SETADO COMO FALSE')
    LocalPlayer.state.inLobbyPrincipal = false

    -- Da god no jogador
	FreezeEntityPosition(PlayerPedId(), false)
	SetEntityHealth(PlayerPedId(),400);
    SetEntityMaxHealth(PlayerPedId(),400)
    SetPedMaxHealth(PlayerPedId(),400)
    
	SetTimeout(10000,function()
		SetEntityHealth(PlayerPedId(),400);
	end)
	SetEntityInvincible(PlayerPedId(),false)

    SetEntityVisible(PlayerPedId(),true,false)
    SetEntityNoCollisionEntity(PlayerPedId(),false,false)
    SetRadarBigmapEnabled(true, false)
    Wait(5)
    SetRadarBigmapEnabled(false, false)

	LocalPlayer.state.death = false
	LocalPlayer.state.agonizing = false

    NetworkFadeOutEntity(ped, true)

    DoScreenFadeOut(1000)

    TriggerEvent("duth:ChatStatus", true)

    LuizDev.RequestAndWaitModel(planeModel)

    local centerVector = vector3(Config.Maps[data.map].center.x, Config.Maps[data.map].center.y, Config.Maps[data.map].radius)

    local destPos = centerVector + (centerVector - data.planePos)

    local heading = GetHeadingFromVector_2d(destPos.x - data.planePos.x, destPos.y - data.planePos.y)

    local planeEntity = CreateVehicle(GetHashKey(planeModel), data.planePos, heading, false, 0)

    SetModelAsNoLongerNeeded(GetHashKey(planeModel))
    SetEntityInvincible(planeEntity, true)
    SetVehicleEngineOn(planeEntity, 1, 1, 0)
    SetVehicleForwardSpeed(planeEntity, 100.0)
    SetHeliBladesSpeed(planeEntity, 100.0)
    SetEntityCollision(planeEntity, 0, 1)
    SetEntityHeading(planeEntity, heading)
    FreezeEntityPosition(planeEntity, true)
    SetVehicleLandingGear(planeEntity, 1)
    Citizen.InvokeNative(0xCFC8BE9A5E1FE575, planeEntity, 0)
    DisablePlayerFiring(PlayerPedId(), false)
    
    local planeBlip = AddBlipForEntity(planeEntity)
    SetBlipSprite(planeBlip, 307)
    SetBlipScale(planeBlip, 0.9)
    SetBlipRotation(planeBlip, math.floor(GetEntityHeading(planeEntity)))
    SetBlipDisplay(planeBlip, 8)

    LuizDev.RequestAndWaitModel(pilotModel)
    driver = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planeEntity), 0.0, false, 0)
    SetPedIntoVehicle(driver, planeEntity, -1)
    SetEntityInvincible(driver, true)
    SetBlockingOfNonTemporaryEvents(driver, true)

    driver2 = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planeEntity), 0.0, false, 0)
    
    SetPedIntoVehicle(driver2, planeEntity, -2)

    plane = planeEntity

    Wait(2500)
    DoScreenFadeIn(1000)
    DisplayRadar(true)
    FreezeEntityPosition(plane, false)
    controller.SeatInPlane(plane)
    SetNetworkIdCanMigrate(plane, false)
    SetNetworkIdCanMigrate(driver, false)
	SetPedArmour(PlayerPedId(), 0)
    exports["vrp"]:ResetCrouch()

    if not GameTheard1 then
        GameTheard1 = true
        Citizen.CreateThread(function()
            while true do
                local idle = 10
                Citizen.Wait(idle)
                local inGame = LocalPlayer.state.inGame
        
                if inGame and plane then
                    TaskVehicleDriveToCoordLongrange(driver, plane, destPos.x, destPos.y, destPos.z, 70.0, 1.0, plane, 1074528293, 1.0, 1)
                    SetVehicleForwardSpeed(GetVehiclePedIsIn(driver, 0), 100.0)
                    idle = 10
                else
                    idle = 1000
                end
            end
        end)
    end
    
    if not GameTheard2 then
        GameTheard2 = true
        Citizen.CreateThread(function()
            while true do
                local idle = 1
                Citizen.Wait(idle)
                local playerPed = GetPlayerPed(-1)
        
                if inPlane then
                    idle = 1
                    if not inPlaneMessage then
                        -- controller.sendServerEvent('IsFollowingTeam', { type = "Get" })
                        
                        -- Wait(300)
                        if LocalPlayer.state.IsFollowingTeam then
                            AddKeyboardInfo({
                                status = true,
                                key = "F",
                                text = "Seguindo <b>"..LocalPlayer.state.IsFollowingTeamLeaderName.."</b>"
                            })
                        else
                            AddKeyboardInfo({
                                status = true,
                                key = "F",
                                text = "Pular do avião"
                            })
                        end

                        inPlaneMessage = true

                        controller.sendServerEvent('GetPlayersInPlaneClient', {})
                    end
    
                    if inPlane and IsControlPressed(0, 23) then
                        if not LocalPlayer.state.IsFollowingTeam then
                            DoScreenFadeIn(1000)
                            SetEntityVisible(PlayerPedId(),true)
                            SetEntityNoCollisionEntity(PlayerPedId(),true,true)
                            DisplayRadar(true)
                            Hud(true)
    
                            local vehicle = GetVehiclePedIsIn(playerPed, false)
                            ClearPedTasks(playerPed, true)
                            TaskLeaveVehicle(playerPed, vehicle, 64)
                            RemoveAllPedWeapons(playerPed, false)
        
                            local coords = GetEntityCoords(playerPed)
                            SetPedGadget(playerPed, GetHashKey("GADGET_PARACHUTE"), true)
                            GiveWeaponToPed(playerPed, "GADGET_PARACHUTE", 1, false, false)
                            SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z-5.5, true, true, true) 
        
                            inPlane = false
                            controller.sendServerEvent('ExitPlaneDimension', {})
                            AddKeyboardInfo({ status = false })
                            NetworkSetTalkerProximity(2.0)
                            NetworkClearVoiceChannel()
                            NetworkSetVoiceActive(true)
                            
                            inPlaneMessage = false
    
                            -- Bota o ped visivel denovo
                            NetworkFadeInEntity(ped, true)
    
                            local ped = PlayerPedId()
                            local height = GetEntityHeightAboveGround(ped)
                            local waitingFall = true
                            while waitingFall do
                                height = GetEntityHeightAboveGround(ped)
                                if height < 80 then
                                    ForcePedToOpenParachute(ped)
                                    if GetPedParachuteState(ped) == -1 and not IsPedInParachuteFreeFall(ped) then
                                        waitingFall = false
                                    end
                                end
                        
                                Wait(20)
                            end
                        end
                    end
                else 
                    idle = 1000
                end
            end
        end)
    end
end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- SetupLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetupLoots(Loots) 
    PickUps = Loots

    print("Quantidade de loots: "..#PickUps.."")
    Pick()
end

RegisterNetEvent('brv:createPickups')
AddEventHandler('brv:createPickups', function(seed, map)
  Citizen.CreateThread(function()
    local weapons = {}
    local weaponModel = ''
    local index = 0
    local rand = math.random() * 50000 -- Saves a client sided rand
    print(seed)

    math.randomseed(math.floor(seed * 50000))
    print("Chegou aqui")
    for i, location in pairs(Config.Maps[map].Loots) do
        local loot = math.random(#Config.lootsCount)
        for ii = 1, Config.lootsCount[loot] do
            if coordinatesProcessed >= Config.Maps[map].MaxLoots then
                break 
            end
    
            weapons = {
                getRandomWeapon('favela'),
                getRandomWeapon('municoes'),
                getRandomWeapon('municoes2'),
                getRandomWeapon('municoes3'),
                getRandomWeapon('municoes4'),
                -- getRandomWeapon('municoes5'),
                -- getRandomWeapon('municoes6'),
            }
            index = tonumber(round(math.random()) + 1)
    
            PickUps[#PickUps + 1] = {
                source = #PickUps + 1,
                name = weapons[index],
                x = location["x"] + (math.random(-8000, 8000) / 1000),
                y = location["y"] + (math.random(-8000, 8000) / 1000),
                z = location["z"],
                created = false,
                handle = nil,
                drop = false,
                ammout = false,
                coleted = false
            }
    
            coordinatesProcessed = coordinatesProcessed + 1
        end
    
        if coordinatesProcessed >= Config.Maps[map].MaxLoots then
            break 
        end
    
        Wait(1)
    end
    math.randomseed(math.floor(rand))
    
    print("Quantidade de loots: "..#PickUps.."")
    Pick()
  end)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- count - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function count(array)
	if type(array) ~= 'table' then return false end
  
	local count = 0
	for k, v in pairs(array) do
	  count = count + 1
	end
	return count
end 

-- Returns a random weapon model from a predefined list
function getRandomWeapon(type)
    if Config.weapons[type] == nil then return false end
  
    local nbWeapons = count(Config.weapons[type])
    local randWeaponIndex = math.random(nbWeapons)
    return Config.weapons[type][randWeaponIndex]
  end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.DropInventoryItem = function(data) 
	PickUps[#PickUps+1] = {
        source = #PickUps+1,
		name = data.name,
		x = data.coords["x"],
		y = data.coords["y"],
		z = data.coords["z"],
		created = false,
		handle = nil,
		drop = true,
		ammout = data.ammout,
		coleted = false
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- pick3 - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function pick3()
    local lastPickupTime = 0
    -- local pickupDelay = 200
    local pickupDelay = 1
    local lastCheckTime = 0
    local checkInterval = 500

    if not lootsTheard1 then
        lootsTheard1 = true
        CreateThread(function()
            while true do
                if LocalPlayer.state.inGame then
                    local currentTime = GetGameTimer()
                    local Coords = GetEntityCoords(Ped)
        
                    if currentTime >= lastCheckTime + checkInterval then
        
                        for i = 1, #PickUps do
                            local pickup = PickUps[i]
                            if not pickup.coleted then
                                local pickupCoords = vector3(pickup.x, pickup.y, pickup.z)
                                local distance = #(Coords - pickupCoords)
                                if distance <= 1.9 then
                                    if not closestPickups[i] then
                                        closestPickups[i] = {
                                            handle = pickup.handle,
                                            pos = vector3(pickup.x, pickup.y, pickup.z),
                                            item = pickup.name,
                                            name = itemName(pickup.name),
                                            index = itemIndex(pickup.name),
                                            drop = pickup.drop,
                                            ammout = pickup.ammout,
                                            tabela = pickup.source,
                                            status = pickup.coleted
                                        }
                                    end
                                end
                            end
                        end
                        
                        lastCheckTime = GetGameTimer()
                    end
                    
                    for k,v in pairs(closestPickups) do
                        if not v.status and not LocalPlayer.state.death and not LocalPlayer.state.agonizing then
                            local distance = #(Coords - v.pos)
                            if distance <= 1.9 and not IsPedInAnyVehicle(Ped) then
                                local currentTime = GetGameTimer()
                    
                                if (currentTime - lastPickupTime) > pickupDelay then
                                    AddItemToTable(v.name, v.index)
                                end
                    
                                if IsControlJustReleased(0, 38) and (currentTime - lastPickupTime) > pickupDelay then
                                    lastPickupTime = currentTime
                                    controller.sendServerEvent('GetLoot', {
                                        number = v.tabela,
                                        item = v.item,
                                        drop = v.drop,
                                        ammout = v.ammout
                                    })
                                    RemovePickup(v.handle)
                                    PickUps[k].coleted = true
                                    closestPickups[k] = nil
                                    
                                    RemoveItemFromTable(v.item)
                    
                                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    break
                                end
                            else
                                RemoveItemFromTable(v.item)
                                closestPickups[k] = nil
                            end
                        end
                    end
                end
    
                Wait(0)
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pick - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Pick()  
    if not lootsTheard2 then
        lootsTheard2 = true
        CreateThread(function()
            while true do
                if LocalPlayer.state.inGame then
                    local PlayerCoords = GetEntityCoords(Ped)
                    for i, pickup in ipairs(PickUps) do
                        local distance = #(PlayerCoords - vector3(pickup.x, pickup.y, pickup.z))
                        if not pickup.created and not pickup.coleted then
                            if distance <= 50 then
                                local _, cdz = GetGroundZFor_3dCoord(pickup.x, pickup.y, 99990.0, 1)
                                local pickupHash = GetHashKey('PICKUP_' .. pickup.name .. (pickup.name:find('AMMO_') and 'LUIZ' or ''))
        
                                local pickupHandle = CreatePickupRotate(pickupHash, pickup.x, pickup.y, cdz + 0.5, vector3(-72.0, 0.0, 42.0), 512, -1, 2, 1)
                                SetPickupRegenerationTime(pickupHandle, -1)
        
                                pickup.handle = pickupHandle
                                pickup.z = cdz + 0.5
                                pickup.created = true
                            end
                        else
                            if distance > 50 then
                                RemovePickup(pickup.handle)
                                pickup.created = false
                            end
                        end
                    end
                end
        
                Wait(700)
            end
        end)
    end
	pick3()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetLoot - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.GetLootClient = function(data)
    for i, pickup in ipairs(PickUps) do
        if data.tabela == pickup.source then
            if pickup.handle then
                RemovePickup(pickup.handle)
            end

            pickup.coleted = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Otimização - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		Ped = PlayerPedId()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStop - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        DeleteEnitys()

        for k, v in pairs(Vehicles) do 
            if v["handle"] then
                local veh = VehToNet(v["handle"])
                if NetworkDoesNetworkIdExist(veh) then
                    local vv = NetToEnt(veh)
                    SetEntityAsMissionEntity(vv,false,false)
                    DeleteEntity(veh)
                end
            end
        end

        for vehicle in EnumerateVehicles() do
            SetVehicleHasBeenOwnedByPlayer(vehicle, false) 
            SetEntityAsMissionEntity(vehicle, false, false) 
            DeleteVehicle(vehicle)
            if (DoesEntityExist(vehicle)) then 
                DeleteVehicle(vehicle) 
            end
        end

        serverAPI.loadUserData()
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.StopLoots = function()
    for i, pickup in ipairs(PickUps) do
        if pickup.handle then
            RemovePickup(pickup.handle)
        end
    end

    PickUps = {}
    allPickups = {}
    closestPickups = {}
    
	for k, v in pairs(Vehicles) do 
		if v["handle"] then
			local veh = VehToNet(v["handle"])
			if NetworkDoesNetworkIdExist(veh) then
				local vv = NetToEnt(veh)
				SetEntityAsMissionEntity(vv,false,false)
				DeleteEntity(veh)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- endGameSpec - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+endGameSpec", function() 
    -- and LocalPlayer.state.inSpec and EndGame
    if not isReturnLobby and LocalPlayer.state.inSpec and EndGame then
        DoScreenFadeOut(1000)
        isReturnLobby = true
        adrenaline = false
        reviving = false
        LocalPlayer.state.Buttons = false
        LocalPlayer.state.agonizing = false
        LocalPlayer.state.isReviving = false
        coordinatesProcessed = 0
        PickUps = {}
        allPickups = {}
        closestPickups = {}

        if AdminSpec then
            SendReactMessage('BuildAdminSpec', { status = false, players = {} })
            AdminSpec = false
            Cursor = false
        end

        SetTimeout(5000, function()
            isReturnLobby = false
        end)
        Wait(1000)
        controller.sendServerEvent('endSpec', { })
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
    if not isReturnLobby and LocalPlayer.state.finishGameUI and LocalPlayer.state.inGame then
        isReturnLobby = true
        adrenaline = false
        reviving = false
        LocalPlayer.state.Buttons = false
        LocalPlayer.state.agonizing = false
        LocalPlayer.state.isReviving = false
        coordinatesProcessed = 0
        PickUps = {}
        allPickups = {}
        closestPickups = {}

        controller.sendServerEvent('endGame', { })
        SetTimeout(5000, function()
            isReturnLobby = false
        end)
    end
    cb("ok")
end)

AddEventHandler('gameEventTriggered',function(event,args)
    if event == 'CEventNetworkEntityDamage' then
        local ped = PlayerPedId()
        -- print(GetEntityHealth(args[1]))
        if ped == args[1] and GetEntityHealth(args[1]) <= 101 and (not LocalPlayer.state.death) and not LocalPlayer.state.inSpec and not LocalPlayer.state.finishGameUI then
            local index = NetworkGetPlayerIndexFromPed(args[2])
            local killer = GetPlayerServerId(index)
            local success, weapon_model = GetCurrentPedWeapon(args[2])
            local cause,cause2 = GetPedLastDamageBone(ped)
            SetEntityVisible(ped,false)
            SetEntityNoCollisionEntity(ped,false,false)
            LocalPlayer.state:set("death",true,false)

            controller.sendServerEvent('RegisterKill', {
                nsource = killer, 
                hs = cause2 == 31086 and true or false,
                gameId = LocalPlayer.state.gameId
            })

            if LocalPlayer.state.agonizing then
                LocalPlayer.state:set("death",true,false)

                controller.sendServerEvent('RegisterKill', {
                    nsource = 0, 
                    hs = cause2 == 31086 and true or false,
                    gameId = LocalPlayer.state.gameId
                })

                -- controller.sendServerEvent('FinishAgonizingGame', {})
            end
        elseif ped == args[1] and GetEntityHealth(args[1]) <= 101 and LocalPlayer.state.agonizing and not LocalPlayer.state.inSpec and not LocalPlayer.state.finishGameUI then
            LocalPlayer.state:set("death",true,false)
            LocalPlayer.state:set("agonizing",true,false)

            SetEntityVisible(ped,false)
            SetEntityNoCollisionEntity(ped,false,false)

            controller.sendServerEvent('RegisterKill', {
                nsource = 0, 
                hs = cause2 == 31086 and true or false,
                gameId = LocalPlayer.state.gameId
            })
            
            -- controller.sendServerEvent('FinishAgonizingGame', {})
        end 
    end
end)

AddEventHandler("entityDamaged", function(victim, culprit, weapon, baseDamage)
    if victim == PlayerPedId() then
        local _, hitBone = GetPedLastDamageBone(victim)
        if hitBone == 31086 then
            local weaponType = GetWeapontypeGroup(weapon)
            if weaponType ~= 2685387236 then
                ApplyDamageToPed(victim,400)
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- prevSpectator
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+prevSpectator","A","keyboard","A")
RegisterCommand("+prevSpectator",function(source,args,rawCommand)
	if spectatingPlayers ~= nil and spectatingPlayer ~= nil and LocalPlayer.state.inSpec and getTableSize(spectatingPlayers) > 1 then
        local newKey = spectatingPlayer.pos-1
        if spectatingPlayers[newKey] == nil then
            newKey = #spectatingPlayers-1
        end

        controller.sendServerEvent('setSpectatorTargetServer', {
            key = newKey, 
            source_player = spectatingPlayers[newKey].source
        })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- initSpectator - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.initSpectatorAdmin = function(data) 
    if not AdminSpec and spectatingPlayers ~= nil then
        print("initSpectatorAdmin", data, spectatingPlayers)
        AdminSpec = data.status
        AddKeyHelp({
            id = 2,
            status = data.status,
            type = 'center',
            key = 'G',
            text = 'Ativar cursor'
        })

        SendReactMessage('BuildAdminSpec', {
            status = data.status,
            players = LuizDev.reMapData(spectatingPlayers),
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- activeCursor - Key
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("+activeCursor", function() 
    if AdminSpec then
        if Cursor then
            Cursor = false
        else
            Cursor = true
        end

        SetNuiFocus(Cursor, Cursor)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Cursor - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Cursor", function(data, cb)
    if AdminSpec then
        if Cursor then
            Cursor = false
        else
            Cursor = true
        end

        SetNuiFocus(Cursor, Cursor)
    end
    cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- activeCursor - Key
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+activeCursor","Ativar cursor.","keyboard","G")
-----------------------------------------------------------------------------------------------------------------------------------------
-- sendSpectadorAdmin - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendSpectadorAdmin", function(data, cb)
    print("sendSpectadorAdmin / "..data.key.."")
    controller.sendServerEvent('setSpectatorTargetServer', {
        key = data.key, 
        source_player = spectatingPlayers[data.key].source
    })
    cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- nextSpectator
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterKeyMapping("+nextSpectator","D","keyboard","D")
RegisterCommand("+nextSpectator",function(source,args,rawCommand)
	if spectatingPlayers ~= nil and spectatingPlayer ~= nil and LocalPlayer.state.inSpec and getTableSize(spectatingPlayers) > 1 then
        local newKey = spectatingPlayer.pos+1
        if spectatingPlayers[newKey] == nil then
            newKey = 0
            newKey = #spectatingPlayers-1
        end
        controller.sendServerEvent('setSpectatorTargetServer', {
            key = newKey, 
            source_player = spectatingPlayers[newKey].source
        })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- initSpectator - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.initSpectator = function(data) 
    if getTableSize(data.players) > 0 and data.target ~= nil then
        spectatingPlayers = data.players
        LocalPlayer.state.inSpec = true
        EndGame = data.endGame
        setSpectatorTarget(data.target, data.coords)

        Hud(true)
        AddKeyHelp({ status = false })

        if data.endGame then
            AddKeyHelp({
                id = 1,
                status = true,
                type = 'center',
                key = 'F7',
                text = 'Sair'
            })

            if AdminSpec then
                AddKeyHelp({
                    id = 2,
                    status = true,
                    type = 'center',
                    key = 'G',
                    text = 'Ativar cursor'
                })
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- updateTableSpec - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.updateTableSpec = function(data) 
    spectatingPlayers = data.players
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTarget - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.setSpectatorTarget = function(data)
    setSpectatorTarget(data.key, data.coords)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTarget - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setSpectatorTarget(key, coords)
    local targetPlayer = spectatingPlayers[key]
    if targetPlayer == nil then return nil end

    DoScreenFadeOut(1000)
    local newSpectateCoords = calculateSpectatorCoords(coords)
    SetEntityCoords(PlayerPedId(), newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, 0, 0, 0, false)

    local pid = GetPlayerFromServerId(targetPlayer.source)
    local targetEntity = GetPlayerPed(pid)

    if DoesEntityExist(targetEntity) then
        local ped = PlayerPedId()
        NetworkSetInSpectatorMode(true, targetEntity)
        SetPlayerInvincible(ped, true)
        SetEntityNoCollisionEntity(ped, targetEntity, false) -- DESATIVAR COLISÕES ENTRE OS JOGADORES
        NetworkOverrideSendRestrictions(targetEntity, false) -- DESATIVAR VOIP ENTRE OS JOGADORES
        AddAnnouncement({
            status = true,
            text = "Assistindo <b>"..targetPlayer.username.."</b> <b2>#"..targetPlayer.user_id.."</b2>",
            timer = false,
        })

        spectatingPlayer = targetPlayer
    end

    Wait(1500)
    DoScreenFadeIn(1000)
    if not SpecTheard then
        SpecTheard = true
        CreateThread(function()
            while true do
                Wait(100)
                if spectatingPlayer ~= nil and LocalPlayer.state.inSpec then
                    local pid = GetPlayerFromServerId(spectatingPlayer.source)
                    local targetEntity = GetPlayerPed(pid)
                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))
                    SetEntityCoords(PlayerPedId(), newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, 0, 0, 0, false)
        
                    local nowhp = parseInt((100*GetEntityHealth(targetEntity)/GetEntityMaxHealth(targetEntity)))
                    local nowarmour = GetPedArmour(targetEntity)
                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))
                    NetworkSetInSpectatorMode(true, targetEntity)

                    SendReactMessage('BuildHud', {
                        type = "StatusPlayerStats",
                        armour = nowarmour,
                        health = nowhp,
                        shorts = {}
                    })
                end
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- stopSpectatorMode - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.stopSpectatorMode()
    if spectatingPlayer then 
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
        AdminSpec = false
        Cursor = false

        spectatingPlayers = nil
        AddAnnouncement({ status = false})
        AddKeyHelp({ status = false })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- calculateSpectatorCoords - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function calculateSpectatorCoords(coords)
    return vec3(coords[1], coords[2], coords[3] - 30.0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Agonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.Agonizing = function(dataServer) 
    local ped = PlayerPedId()
	SetEntityHealth(PlayerPedId(), 400)
	SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    SetEntityNoCollisionEntity(PlayerPedId(),true,true)
    ClearPedTasks(PlayerPedId())
    ClearPedBloodDamage(PlayerPedId())
    LocalPlayer.state.Buttons = true
    LocalPlayer.state.agonizing = true

    local x,y,z = table.unpack(GetEntityCoords(ped))
    NetworkResurrectLocalPlayer(x,y,z,true,true,false)

    local animName = "combat@death@from_writhe"
    local animName2 = "death_c"
    while ( not HasAnimDictLoaded( animName ) ) do
        RequestAnimDict( animName )
        Citizen.Wait( 5 )
    end
    
    adrenalineItem = dataServer.data.adrenaline
    if adrenalineItem then
        AddKeyboardInfo({
            status = true,
            key = "F",
            text = "Usar adrenalina"
        })
    end

    if not GameTheard3 then
        GameTheard3 = true

        Citizen.CreateThread(function()
            
            while true do
                if not reviving and LocalPlayer.state.agonizing then
                    TaskPlayAnim(PlayerPedId(), animName, animName2, 8.0, 1.0, -1, 1, 0, false, false, false)
                end
    
                if not IsEntityDead(PlayerPedId()) and not reviving and LocalPlayer.state.agonizing then
          
                SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 1)
          
                if GetEntityHealth(PlayerPedId()) == 101 then
                    print("Morreu agonizando")
    
                    if LocalPlayer.state.agonizing and not LocalPlayer.state.inSpec and not LocalPlayer.state.finishGameUI then
                        SetEntityVisible(ped,false)
                        SetEntityNoCollisionEntity(ped,false,false)
                        vRP.updateHealth(101)
                        SetPedCanRagdoll(ped,true)
                        SetPedToRagdoll(ped,2000,2000,0,0,0,0)
                        SetEntityHealth(ped,101)
                        SetEntityInvincible(ped,true)
                        SetEntityVisible(ped,false)
                        SetEntityNoCollisionEntity(ped,false,false)

                        LocalPlayer.state:set("death",true,false)
                        LocalPlayer.state:set("agonizing",true,false)
    
                        controller.sendServerEvent('RegisterKill', {
                            nsource = 0, 
                            hs = cause2 == 31086 and true or false,
                            gameId = LocalPlayer.state.gameId
                        })
                        
                        -- controller.sendServerEvent('FinishAgonizingGame', {})

                        if adrenaline then
                            AddKeyboardInfo({
                                status = false,
                                key = "F",
                                text = "Usando"
                            })
                            adrenaline = false
                        end
                    end 
    
                    reviving = true
                end
          
              end
              Citizen.Wait(150)
            end
        end)
    
        Citizen.CreateThread(function()
            while true do
                local idle = 1
                Citizen.Wait(idle)
                local playerPed = GetPlayerPed(-1)
                
                if adrenalineItem and not IsEntityDead(PlayerPedId()) and not reviving and LocalPlayer.state.agonizing then
                    idle = 1
        
                    if IsControlPressed(0, 23) and not adrenaline and not LocalPlayer.state.death then
                        AddKeyboardInfo({
                            status = true,
                            key = "F",
                            text = "Utilizando..."
                        })
                        reviving = true

                        adrenaline = true
                        SetTimeout(7000, function()
                            if adrenaline then
                                AddKeyboardInfo({
                                    status = false,
                                    key = "F",
                                    text = "Utilizando..."
                                })

                                controller.sendServerEvent('ReviveAgonizing', {
                                    source = GetPlayerServerId(PlayerId()),
                                    type = "Adrenaline"
                                })
        
                                adrenaline = false
                            end
                        end)
        
                        SetTimeout(5000, function()
                            PlaySoundFrontend(-1,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET",false)
                        end)
        
                        SetTimeout(2000, function()
                            PlaySoundFrontend(-1,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET",false)
                        end)
                    end
                else 
                    idle = 1000
                end
            end
        end)
    end
    
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.ReviveAgonizingClient = function(data) 
    if data.type == "Stop" then
        reviving = true
    else
        reviving = false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FinishAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.FinishAgonizing = function(data) 
    local ped = PlayerPedId()
    reviving = true

    vRP.updateHealth(101)
    SetPedCanRagdoll(ped,true)
    SetPedToRagdoll(ped,2000,2000,0,0,0,0)
    SetEntityHealth(ped,101)
    SetEntityInvincible(ped,true)
    -- SetEntityVisible(ped,false)
    SetEntityNoCollisionEntity(ped,false,false)

    LocalPlayer.state:set("death",true,false)
    LocalPlayer.state:set("agonizing",false,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.StopAgonizing = function(data) 
    local ped = PlayerPedId()

    SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()))
	SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    SetEntityNoCollisionEntity(PlayerPedId(),true,true)
    ClearPedTasks(PlayerPedId())
    ClearPedBloodDamage(PlayerPedId())
    LocalPlayer.state.agonizing = false
    LocalPlayer.state.death = false

    local x,y,z = table.unpack(GetEntityCoords(ped))
    NetworkResurrectLocalPlayer(x,y,z,true,true,false)
    reviving = false
    LocalPlayer.state.Buttons = false
end

RegisterNetEvent('events_controller')
AddEventHandler('events_controller', function(sv_content)
    local eventName = sv_content.event
    local data = sv_content.data

    if clientEvents[eventName] ~= nil then
        clientEvents[eventName](data)
    end
end)



----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if LocalPlayer.state.inGameLobby then
            if cooldown > 0 then
                cooldown = cooldown - 1
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if LocalPlayer.state.inGameLobby then
            if cooldown then
                if cooldown == 0 then
                    vRP.playSound("Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
                    local time = 100
                    while time > 0 do
                        LocalPlayer.state.inGameLobby = false
                        time = time-1
                    end
                    cooldown = -1
                end
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobbyGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.JoinLobbyGame = function()
    local ped = PlayerPedId()
    DoScreenFadeOut(1000)
    cooldown = Config.StartTime
    LocalPlayer.state.inDashboard = false
    
    -- Fechar o lobby
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")
    toggleNuiFrame(false)
    SetNuiFocus(false,false)
    
    NetworkSetTalkerProximity(0.0)
    NetworkClearVoiceChannel()
    NetworkSetVoiceActive(false)
    noDamage()
    clientApiEvents.BuildPeds({}, false)
    clientApiEvents.BuildGroup({}, false)
    SendReactMessage('buildStatsStatus', true)
    SendReactMessage('buildLogoMidle', true)
    AddKeyHelp({ status = false })


    exports["vrp"]:ResetCrouch()
    FreezeEntityPosition(PlayerPedId(), true)
    Wait(600)
    local randomSpawn = math.random(#Config.LobbyGame)
    SetEntityCoordsNoOffset(ped, Config.LobbyGame[randomSpawn].x, Config.LobbyGame[randomSpawn].y, Config.LobbyGame[randomSpawn].z+1)
    LocalPlayer.state.inGameLobby = true
    TriggerEvent("duth:ChatStatus", true)

    DisplayRadar(false)

    Wait(1500)

    SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    FreezeEntityPosition(PlayerPedId(),false)
    SetPedDiesInWater(PlayerPedId(), 1)

    DoScreenFadeIn(1000)

    local ped = PlayerPedId()
    local pedId = PlayerId()
    SetEntityHealth(ped, 400)
    ClearPlayerWantedLevel(pedId)
    SetCurrentPedWeapon(ped,"WEAPON_UNARMED",true)
    RemoveAllPedWeapons(ped, true)
    ClearPedBloodDamage(ped)
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
        
                    local timeValue = cooldown
                    local isSeconds = true
                    
                    if timeValue >= 60 then
                        timeValue = timeValue / 60
                        isSeconds = false
                    end

                    if isSeconds then
                        AddAnnouncement({
                            status = true,
                            text = "A partida começará em <b>".. LuizDev.SecondsToClock(timeValue).."</b> segundos",
                            timer = false,
                        })
                    else
                        AddAnnouncement({
                            status = true,
                            text = "A partida começará em <b>instantes</b> aguarde...",
                            timer = false,
                        })
                    end

                    -- if cooldown == 1 then
                    --     if not StartGame then
                    --         StartGame = true
                    --         -- controller.sendServerEvent('StartGameNew', {})
                    --         -- Wait(500)
                    --         -- clientEvents.StartGameClient()
                    --     end
                    -- end
                else
                    idleGame = 5000
                end
        
                Citizen.Wait(idleGame)
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitLobbyGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.ExitLobbyGame = function()
    local ped = PlayerPedId()
    local pedId = PlayerId()
    DisablePlayerFiring(PlayerPedId(), false)
    exports["vrp"]:ResetCrouch()
    Wait(1000)
    LocalPlayer.state.inGameLobby = false
    LocalPlayer.state.inDashboard = false
    LocalPlayer.state.Buttons = false

    AddAnnouncement({ status = false })
    -- torna o jogador vulnerável novamente quando sair do lobby
    SetEntityInvincible(ped, false)
    SetPedCanSwitchWeapon(ped, true)

    idleGame = 5000
    StartGame = false
end