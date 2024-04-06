local planeModel = "titan"
local pilotModel = "mp_m_freemode_01"
local plane = nil
local inPlane = false
local inPlaneMessage = false
local GameTheard1 = nil
local GameTheard2 = nil
-----------------------------------------------------------------------------------------------------------------------------------------
-- SeatInPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SeatInPlane()
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
-- StartPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.StartPlane(gameMapName, planePos) 
    local ped = GetPlayerPed(-1)

    DoScreenFadeOut(1000)

    LuizDev.RequestAndWaitModel(planeModel)

    local centerVector = vector3(Config.Maps[gameMapName].center.x, Config.Maps[gameMapName].center.y, Config.Maps[gameMapName].radius)

    local destPos = centerVector + (centerVector - planePos)

    local heading = GetHeadingFromVector_2d(destPos.x - planePos.x, destPos.y - planePos.y)

    local planeEntity = CreateVehicle(GetHashKey(planeModel), planePos, heading, false, 0)

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

    if #LocalPlayer.state.userTeam['players'] > 1 then
        TriggerEvent("BuildUI", "TeamStatus", { status = true })
    end

    LuizDev.RequestAndWaitModel(pilotModel)
    driver = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planplaneEntitye), 0.0, false, 0)
    SetPedIntoVehicle(driver, planeEntity, -1)
    SetEntityInvincible(driver, true)
    SetBlockingOfNonTemporaryEvents(driver, true)

    driver2 = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planeEntity), 0.0, false, 0)
    
    SetPedIntoVehicle(driver2, planeEntity, -2)

    plane = planeEntity

    Wait(2500)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(plane, false)
    SeatInPlane(plane)
    SetNetworkIdCanMigrate(plane, false)
    SetNetworkIdCanMigrate(driver, false)
    DisplayRadar(true)
	SetPedArmour(PlayerPedId(), 0)
    TriggerEvent("showHud")
    exports["ui"]:ResetCrouch()
    TriggerEvent("BuildUI", "SafeZoneInfo", { status = true, title = "A zona segura aparecerá em 2 minutos" })

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
                        TriggerEvent("NotifyPularPegar", true, "F", "Pular do avião")
                        inPlaneMessage = true
                    end
    
                    if inPlane and IsControlPressed(0, 23) then
                        DoScreenFadeIn(1000)
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        ClearPedTasks(playerPed, true)
                        TaskLeaveVehicle(playerPed, vehicle, 64)
                        RemoveAllPedWeapons(playerPed, false)
    
                        local coords = GetEntityCoords(playerPed)
                        SetPedGadget(playerPed, GetHashKey("GADGET_PARACHUTE"), true)
                        GiveWeaponToPed(playerPed, "GADGET_PARACHUTE", 1, false, false)
                        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z-5.5, true, true, true) 
    
                        inPlane = false
                        serverAPI.ExitPlaneDimension()
                        TriggerEvent("NotifyPularPegar", false, "F", "Pular do avião")
                        inPlaneMessage = false
    
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
                else 
                    idle = 1000
                end
            end
        end)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StartPlane - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("StartPlane")
AddEventHandler("StartPlane",function(gameMapName, planePos)
    local ped = GetPlayerPed(-1)

    DoScreenFadeOut(1000)

    LuizDev.RequestAndWaitModel(planeModel)

    local centerVector = vector3(Config.Maps[gameMapName].center.x, Config.Maps[gameMapName].center.y, Config.Maps[gameMapName].radius)

    local destPos = centerVector + (centerVector - planePos)

    local heading = GetHeadingFromVector_2d(destPos.x - planePos.x, destPos.y - planePos.y)

    local planeEntity = CreateVehicle(GetHashKey(planeModel), planePos, heading, false, 0)

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

    if #LocalPlayer.state.userTeam['players'] > 1 then
        TriggerEvent("BuildUI", "TeamStatus", { status = true })
    end

    LuizDev.RequestAndWaitModel(pilotModel)
    driver = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planplaneEntitye), 0.0, false, 0)
    SetPedIntoVehicle(driver, planeEntity, -1)
    SetEntityInvincible(driver, true)
    SetBlockingOfNonTemporaryEvents(driver, true)

    driver2 = CreatePed(29, GetHashKey(pilotModel), GetEntityCoords(planeEntity), 0.0, false, 0)
    
    SetPedIntoVehicle(driver2, planeEntity, -2)

    plane = planeEntity

    Wait(2500)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(plane, false)
    SeatInPlane(plane)
    SetNetworkIdCanMigrate(plane, false)
    SetNetworkIdCanMigrate(driver, false)
    DisplayRadar(true)
	SetPedArmour(PlayerPedId(), 0)
    TriggerEvent("showHud")
    exports["ui"]:ResetCrouch()
    TriggerEvent("BuildUI", "SafeZoneInfo", { status = true, title = "A zona segura aparecerá em 2 minutos" })

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
                        TriggerEvent("NotifyPularPegar", true, "F", "Pular do avião")
                        inPlaneMessage = true
                    end
    
                    if inPlane and IsControlPressed(0, 23) then
                        DoScreenFadeIn(1000)
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        ClearPedTasks(playerPed, true)
                        TaskLeaveVehicle(playerPed, vehicle, 64)
                        RemoveAllPedWeapons(playerPed, false)
    
                        local coords = GetEntityCoords(playerPed)
                        SetPedGadget(playerPed, GetHashKey("GADGET_PARACHUTE"), true)
                        GiveWeaponToPed(playerPed, "GADGET_PARACHUTE", 1, false, false)
                        SetEntityCoordsNoOffset(playerPed, coords.x, coords.y, coords.z-5.5, true, true, true) 
    
                        inPlane = false
                        serverAPI.ExitPlaneDimension()
                        TriggerEvent("NotifyPularPegar", false, "F", "Pular do avião")
                        inPlaneMessage = false
    
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
                else 
                    idle = 1000
                end
            end
        end)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.StopPlane() 
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
    DeleteEntity(plane)
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
        serverAPI.ExitPlaneDimension()
        TriggerEvent("NotifyPularPegar", false, "F", "Pular do avião")
        inPlaneMessage = false

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
-- BuildGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.BuildGame(data) 
    if data.rich then
        setDiscordRich("DUTH", "Battle Royale - Jogo em andamento "..data.players.." restantes.")
    end
    TriggerEvent("BuildUI", "BuildGame", { status = data.status, safe = false, kills = LocalPlayer.state.kills, safeTime = "00:00", players = data.players, updatePlayers = true })
end
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
