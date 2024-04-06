-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local PickUps = {}
local allPickups = {}
local lastItem = "" -- armazena o nome do item do loot anterior
local closestPickups = {}
local Vehicles = {}
local Ped = PlayerPedId()
local lootsTheard1 = nil
local lootsTheard2 = nil
local LuizDev = moduleEE("client")
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetupLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetupLoots(Loots) 
    print("Setup loots", Loots)
    PickUps = Loots
    Pick()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetupCars - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetupCars(Cars) 
    for k,v in pairs(Cars) do
        LuizDev.RequestAndWaitModel(v.model)
        local veh = CreateVehicle(v.model, v.x, v.y, v.z, true, true)
        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleHasBeenOwnedByPlayer(veh, true)

        Vehicles[#Vehicles+1] = {
            handle = veh
        }
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.DropInventoryItem(data) 
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
                                if IsControlJustReleased(0, 38) and (currentTime - lastPickupTime) > pickupDelay then
                                    RemovePickup(v.handle)
                                    closestPickups[k] = nil
                                    lastPickupTime = currentTime
                                    serverAPI.GetLoot(v.tabela, v.item, v.drop, v.ammout)
                                    PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                                    break
                                end
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
function src.GetLoot(tabela) 
    for i, pickup in ipairs(PickUps) do
        if tabela == pickup.source then
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
-- StopLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.StopLoots() 
    for i, pickup in ipairs(PickUps) do
        if pickup.handle then
            RemovePickup(pickup.handle)
        end
    end

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