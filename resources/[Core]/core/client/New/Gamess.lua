local gameApi = Tunnel.getInterface('core:gameApi')

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

local LOOTS_COLORS = {
    PURPLE = { R = 160, G = 32, B = 240 },
    BLUE = { R = 0, G = 166, B = 255 },
    ORANGE = { R = 255, G = 109, B = 10 },
    YELLOW = { R = 255, G = 255, B = 0 },
    GREEN = { R = 0, G = 128, B = 0 },
}

local CHEST_MODELS = {
    PURPLE = 'hype_pvpbox02',
    BLUE = 'hype_pvpbox04',
    ORANGE = 'hype_pvpbox03',
    YELLOW = 'hype_pvpbox01',
    GREEN = 'hype_pvpbox01',
}

local AVAILABLE_LOOTS = {
    'Rifles',
    'Submachines',
    'Pistols',
    'Ammo', 
    'Life', 
}

local LOOTS_COLORS_NAMES = {
    ['Rifles'] = 'PURPLE',
    ['Submachines'] = 'BLUE',
    ['Pistols'] = 'ORANGE',
    ['Ammo'] = 'YELLOW', 
    ['Life'] = 'GREEN', 
}

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
        setDiscordRich("HYPE", "Battle Royale - Jogo em andamento ".. data.players.. " restantes.")
    end

    TriggerEvent("BuildGame", { status = data.status, safe = false, kills = data.kills or 0, safeTime = 0, players = data.players, updatePlayers = true, updateKills = true })
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

    while not NetworkHasControlOfDoor(plane) do 
        print("wait") 

        Citizen.Wait(0)
    end

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
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")

    updateMenuFrame(false)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- JumpPlayerFolloWing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientApiEvents.JumpPlayerFolloWing = function(data) 
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
    
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")

    updateMenuFrame(false)
    
    DisablePlayerFiring(PlayerPedId(), false)

    exports["vrp"]:ResetCrouch()
    SendReactMessage('buildLogoMidle', true)
    
    SetEntityInvincible(pedPlayer, false)
    SetPedCanSwitchWeapon(pedPlayer, true)

    LocalPlayer.state.inDashboard = false
    LocalPlayer.state.inGameLobby = false
    LocalPlayer.state.inLobbyPrincipal = false

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

                            SetEntityAsMissionEntity(plane, true, true)

                            while DoesEntityExist(plane) do 
                                DeleteEntity(plane)
                            end 

                            while DoesBlipExist(planeBlip) do 
                                RemoveBlip(planeBlip)
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

RegisterNetEvent('brv:createPickups', function(seed, mapId)
    local rand = math.random() * 50000 -- Saves a client sided rand

    math.randomseed(math.floor(seed * 50000))

    for i, location in pairs(Config.Maps[mapId].Loots) do
        if coordinatesProcessed >= Config.Maps[mapId].MaxLoots then
            break 
        end

        local randomIndex = math.random(#AVAILABLE_LOOTS)

        local lootType = AVAILABLE_LOOTS[randomIndex]
        local lootColor = LOOTS_COLORS_NAMES[lootType]

        PickUps[#PickUps + 1] = {
            source = #PickUps + 1,
            color = lootColor, 
            lootName = lootType, 
            name = getRandomWeapon(lootType),
            x = location.x,
            y = location.y,
            z = location.z,
            created = false,
            chestHandle = nil,
            handle = nil,
            drop = false,
            ammout = false,
            coleted = false
        }

        coordinatesProcessed = coordinatesProcessed + 1
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- count - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function count(array)
	if type(array) ~= 'table' then 
        return false 
    end
  
	local count = 0

	for k, v in pairs(array) do
	  count = count + 1
	end

	return count
end 

function getRandomWeapon(type) -- Returns a random weapon model from a predefined list
    if Config.weapons[type] == nil then 
        return false 
    end

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
		chestHandle = nil,
		handle = nil,
		drop = true,
		ammout = data.ammout,
		coleted = false
	}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pick - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
function toggleChestAnim(inProgress)
    local ped = PlayerPedId()
    local player = PlayerId()

    local dict = 'amb@medic@standing@kneel@base'
    local anim = 'base'

    local hasAnim = IsEntityPlayingAnim(ped, dict, anim, 1)

    if inProgress and not hasAnim then 
        while not HasAnimDictLoaded(dict) do
            RequestAnimDict(dict)

            Citizen.Wait(10)
        end

        TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
        FreezeEntityPosition(ped, true)

        exports.progressbar:createProgressBar(2000, "Abrindo baú")
    elseif not inProgress and hasAnim then 
        ClearPedTasks(ped)
        ClearPedSecondaryTask(ped)
        ClearPedTasksImmediately(ped)

        FreezeEntityPosition(ped, false)

        exports.progressbar:removeProgressBar()
    end 
end

CreateThread(function()
    local lastPickupTime = 0
    local pickupDelay = 1
    local lastCheckTime = 0
    local checkInterval = 500

    local isEPressed = false
    local pressTime = 0

    local isKeyboardChestActive = false

    while true do
        local sleepTime = 1000

        if LocalPlayer.state.inGame then
            sleepTime = 0

            local currentTime = GetGameTimer()
            local pedCoordinates = GetEntityCoords(Ped)

            if currentTime >= lastCheckTime + checkInterval then
                for i = 1, #PickUps do
                    local pickup = PickUps[i]
                    
                    if not pickup.coleted then
                        local pickupCoords = vector3(pickup.x, pickup.y, pickup.z)
                        local distance = #(pedCoordinates - pickupCoords)
                        
                        if distance <= 100.0 then
                            if not closestPickups[i] then
                                closestPickups[i] = {
                                    handle = pickup.handle,
                                    chestHandle = pickup.chestHandle,
                                    timeout = 0,
                                    pos = vector3(pickup.x, pickup.y, pickup.z),
                                    item = pickup.name,
                                    color = pickup.color,
                                    lootName = pickup.lootName,
                                    name = itemName(pickup.name),
                                    index = itemIndex(pickup.name),
                                    drop = pickup.drop,
                                    ammout = pickup.ammout,
                                    tabela = pickup.source,
                                    status = pickup.coleted
                                }
                            end
                        else
                            if closestPickups[i] then
                                closestPickups[i] = nil
                            end
                        end
                    end
                end
                
                lastCheckTime = GetGameTimer()
            end
            
            local isNearOfChest = false 

            for k,v in pairs(closestPickups) do
                if not v.status and not LocalPlayer.state.death and not LocalPlayer.state.agonizing then
                    local distance = #(pedCoordinates - v.pos)
                    
                    local color = LOOTS_COLORS[v.color]

                    if color then 
                        DrawLightWithRange(v.pos.x, v.pos.y, v.pos.z, color.R, color.G, color.B, 1.0, 300.0)
                    end 

                    if distance <= 1.9 and not IsPedInAnyVehicle(Ped) then
                        if not PickUps[k].handle then
                            isNearOfChest = true 

                            if IsControlJustPressed(0, 38) then
                                isEPressed = true
                                pressTime = GetGameTimer()
                            end
                            
                            if IsControlJustReleased(0, 38) then
                                isEPressed = false
                                pressTime = 0
                            end
                            
                            if isEPressed and GetGameTimer() - pressTime >= 2000 then
                                controller.sendServerEvent('OpenBox', {
                                    id = k,
                                    item = v.item,
                                    pos = v.pos,
                                    number = v.tabela,
                                })

                                v.timeout = GetGameTimer() + 550

                                PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                
                                isEPressed = false
                                pressTime = 0
    
                                break
                            end
                        else
                            local currentTime = GetGameTimer()
                    
                            if (currentTime - lastPickupTime) > pickupDelay then
                                AddItemToTable(v.name, v.index)
                            end
                
                            if GetGameTimer() > v.timeout then 
                                if IsControlJustReleased(0, 38) and (currentTime - lastPickupTime) > pickupDelay then
                                    lastPickupTime = currentTime

                                    controller.sendServerEvent('GetLoot', {
                                        id = k,
                                        number = v.tabela,
                                        item = v.item,
                                        drop = v.drop,
                                        ammout = v.ammout
                                    })

                                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    
                                    break
                                end
                            end
                        end
                    else
                        if PickUps[k].handle then
                            RemoveItemFromTable(v.item)
                        end
                    end
                end
            end

            if isNearOfChest ~= isKeyboardChestActive then 
                isKeyboardChestActive = isNearOfChest 

                AddKeyboardInfo({
                    status = isNearOfChest,
                    key = isNearOfChest and "E" or nil,
                    text = isNearOfChest and "Abrir baú" or nil
                })
            end 

            if not isEPressed or GetGameTimer() - pressTime >= 2000 then
                toggleChestAnim(false)
            else 
                toggleChestAnim(true)
            end
        end

        Wait(sleepTime)
    end
end)

clientEvents.GeneratePickup = function(data)
    print('GeneratePickup', json.encode(data))
    local closestObject = closestPickups[data.id]

    if closestObject then
        deleteObject(closestObject.chestHandle)
    end

    local pickupObject = PickUps[data.id]

    if not pickupObject then
        for i, pickup in ipairs(PickUps) do
            if data.tabela == pickup.source then
                pickupObject = PickUps[i]
            end
        end
    end

    if pickupObject then
        deleteObject(pickupObject.chestHandle)

        local pickupHash = GetHashKey('PICKUP_'..data.item)

        if data.item:find('AMMO_') then
            pickupHash = GetHashKey('PICKUP_AMMO_BULLET_MP')
        end

        local pickupHandle = CreatePickupRotate(pickupHash, data.pos, vector3(-72.0, 0.0, 42.0), 512, -1, 2, 1)
        
        SetPickupRegenerationTime(pickupHandle, -1)

        pickupObject.handle = pickupHandle
        pickupObject.chestHandle = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Create Object - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function createObject(modelName, coordinates)
    local modelHash = GetHashKey(modelName)

    if IsModelValid(modelHash) then
        RequestModel(modelHash)

        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
        
        local object = CreateObjectNoOffset(modelHash, coordinates, false, false, false)

        SetEntityAsMissionEntity(object, true, true)
        SetModelAsNoLongerNeeded(modelHash)

        return object
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Delete Object - Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function deleteObject(entity)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
        SetEntityAsMissionEntity(entity, true, true)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pick - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local sleepTime = 1000

        if LocalPlayer.state.inGame then
            sleepTime = 0

            local pedCoordinates = GetEntityCoords(Ped)
            
            for i, pickup in ipairs(PickUps) do
                local distance = #(pedCoordinates - vector3(pickup.x, pickup.y, pickup.z))
                
                if not pickup.created and not pickup.coleted then
                    if distance <= 100 then
                        local foundZ, cdz = GetGroundZFor_3dCoord(pickup.x, pickup.y, 99990.0, true)

                        if foundZ then
                            local chestHandle = createObject(CHEST_MODELS[pickup.color], vector3(pickup.x, pickup.y, cdz))

                            if chestHandle then
                                pickup.chestHandle = chestHandle
                                pickup.z = cdz + 0.5
                                pickup.created = true
                            end
                        end
                    end
                else
                    if distance > 100 or pickup.coleted then
                        if DoesEntityExist(pickup.chestHandle) then
                            deleteObject(pickup.chestHandle)

                            pickup.chestHandle = nil
                            pickup.created = false
                        end
                    end
                end
            end
        end

        Citizen.Wait(sleepTime)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetLoot - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.GetLootClient = function(data)
    local pickupObject = PickUps[data.id]

    if pickupObject then
        RemovePickup(pickupObject.handle)
        
        pickupObject.coleted = true
    end

    if closestPickups[data.id] then
        closestPickups[data.id] = nil
    end
    
    RemoveItemFromTable(data.item)

    for i, pickup in ipairs(PickUps) do
        if data.tabela == pickup.source then
            RemovePickup(pickup.handle)

            pickup.coleted = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Otimização - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Ped = PlayerPedId()

		Citizen.Wait(5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStop - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
	if resourceName == GetCurrentResourceName() then
        DeleteEntities()

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
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStart - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then
        return
	end

    serverAPI.loadUserData()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
clientEvents.StopLoots = function()
    for i, pickup in ipairs(PickUps) do
        if pickup.chestHandle then
            if DoesEntityExist(pickup.chestHandle) then
                deleteObject(pickup.chestHandle)
            end
        end

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
RegisterNUICallback("returnToLobby", function(data, cb)
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

    cb({ status = true })
end)

AddEventHandler('gameEventTriggered',function(event,args)
    if event == 'CEventNetworkEntityDamage' then
        local ped = PlayerPedId()

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
        LocalPlayer.state:set('inSpec', true, true)
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
local cardCache = {}

function setSpectatorTarget(key, coords)
    local targetPlayer = spectatingPlayers[key]

    if targetPlayer == nil then 
        return nil 
    end

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

        spectatingPlayer = targetPlayer
    end

    Wait(1500)
    DoScreenFadeIn(1000)

    if not SpecTheard then
        SpecTheard = true

        local playerSpectateEntries = gameApi.getPlayerToSpectate(targetPlayer.source)
        local spectatingSource = spectatingPlayer.source

        CreateThread(function()
            while spectatingPlayer and spectatingSource == spectatingPlayer.source do
                local inSpec = LocalPlayer.state.inSpec 

                if inSpec then
                    local pid = GetPlayerFromServerId(spectatingPlayer.source)
                    local targetEntity = GetPlayerPed(pid)
                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))

                    SetEntityCoords(PlayerPedId(), newSpectateCoords.x, newSpectateCoords.y, newSpectateCoords.z, 0, 0, 0, false)
        
                    local nowhp = (GetEntityHealth(targetEntity) - 100) / (GetPedMaxHealth(targetEntity) - 100) * 100
                    local nowarmour = GetPedArmour(targetEntity)

                    local newSpectateCoords = calculateSpectatorCoords(GetEntityCoords(targetEntity))

                    NetworkSetInSpectatorMode(true, targetEntity)

                    if playerSpectateEntries then 
                        local playerTag, playerName, playerColor, playerKills, playerTeamKills = table.unpack(playerSpectateEntries)

                        SendReactMessage('showSpectator', {
                            tag = playerTag,
                            name = playerName,
                            color = playerColor, 
                            health = nowhp,
                            armour = nowarmour,
                            kills = playerKills,
                            teamKills = playerTeamKills
                        })
                    end 
                end

                Wait(100)
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

        SendReactMessage('hideSpectator', {})

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
    
    print('events_controller', eventName, json.encode(data))

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

                AddAnnouncement({
                    status = true,
                    text = "A partida começará em <b>".. LuizDev.SecondsToClock(cooldown).."</b> segundos",
                    timer = false,
                })
            else 
                AddAnnouncement({
                    status = true,
                    text = "A partida começará em <b>instantes</b> aguarde...",
                    timer = false,
                })
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
                        time = time - 1
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
    
    cam.delete("CAM_LOBBY1")
    cam.delete("CAM_LOBBY2")

    updateMenuFrame(false)
    
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

    Wait(500)

    local randomSpawn = math.random(#Config.LobbyGame)

    SetEntityCoordsNoOffset(ped, Config.LobbyGame[randomSpawn].x, Config.LobbyGame[randomSpawn].y, Config.LobbyGame[randomSpawn].z+1)
    
    LocalPlayer.state.inGameLobby = true
    TriggerEvent("duth:ChatStatus", true)
    
    Hud(true)
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

    SetEntityInvincible(ped, false)
    SetPedCanSwitchWeapon(ped, true)

    idleGame = 5000
    StartGame = false
end