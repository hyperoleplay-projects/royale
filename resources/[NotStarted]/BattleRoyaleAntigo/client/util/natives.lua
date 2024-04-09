
local Information = false
local weaponList = {
	"AMMO_PISTOLLUIZ",
	"AMMO_RIFLELUIZ",
	"AMMO_SHOTGUNLUIZ",
	"AMMO_SMGLUIZ",
	"AMMO_SNIPERLUIZ",
	"ARMOUR_STANDARD",
	"HEALTH_STANDARD",
	"WEAPON_ADVANCEDRIFLE",
	"WEAPON_APPISTOL",
	"WEAPON_ASSAULTRIFLE",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_ASSAULTSHOTGUN",
	"WEAPON_ASSAULTSMG",
	"WEAPON_AUTOSHOTGUN",
	"WEAPON_BAT",
	"WEAPON_BATTLEAXE",
	"WEAPON_BOTTLE",
	"WEAPON_BULLPUPRIFLE",
	"WEAPON_BULLPUPRIFLE_MK2",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_CARBINERIFLE_MK2",
	"WEAPON_COMBATMG",
	"WEAPON_COMBATMG_MK2",
	"WEAPON_COMBATPDW",
	"WEAPON_COMBATPISTOL",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_COMPACTRIFLE",
	"WEAPON_CROWBAR",
	"WEAPON_DAGGER",
	"WEAPON_DBSHOTGUN",
	"WEAPON_DOUBLEACTION",
	"WEAPON_FLAREGUN",
	"WEAPON_FLASHLIGHT",
	"WEAPON_GRENADE",
	"WEAPON_GUSENBERG",
	"WEAPON_GOLFCLUB",
	"WEAPON_HAMMER",
	"WEAPON_HATCHET",
	"WEAPON_HEAVYPISTOL",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_HEAVYSNIPER",
	"WEAPON_HEAVYSNIPER_MK2",
	"WEAPON_KNIFE",
	"WEAPON_KNUCKLE",
	"WEAPON_MACHETE",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_MARKSMANPISTOL",
	"WEAPON_MARKSMANRIFLE",
	"WEAPON_MARKSMANRIFLE_MK2",
	"WEAPON_MG",
	"WEAPON_MICROSMG",
	"WEAPON_MINISMG",
	"WEAPON_MOLOTOV",
	"WEAPON_MUSKET",
	"WEAPON_NIGHTSTICK",
	"WEAPON_PETROLCAN",
	"WEAPON_PIPEBOMB",
	"WEAPON_PISTOL",
	"WEAPON_PISTOL50",
	"WEAPON_PISTOL_MK2",
	"WEAPON_POOLCUE",
	"WEAPON_PROXMINE",
	"WEAPON_PUMPSHOTGUN",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_REVOLVER",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_SMG",
	"WEAPON_SMG_MK2",
	"WEAPON_SMOKEGRENADE",
	"WEAPON_SNIPERRIFLE",
	"WEAPON_SNSPISTOL",
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_STICKYBOMB",
	"WEAPON_STONE_HATCHET",
	"WEAPON_STUNGUN",
	"WEAPON_SWITCHBLADE",
	"WEAPON_VINTAGEPISTOL",
	"WEAPON_WRENCH",
}

DisableVehicleDistantlights(true)
SetPedPopulationBudget(0)
SetVehiclePopulationBudget(0)
SetRandomEventFlag(false)
local scenarios = {
    'WORLD_VEHICLE_ATTRACTOR',
    'WORLD_VEHICLE_AMBULANCE',
    'WORLD_VEHICLE_BICYCLE_BMX',
    'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
    'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
    'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
    'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
    'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
    'WORLD_VEHICLE_BICYCLE_ROAD',
    'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
    'WORLD_VEHICLE_BIKER',
    'WORLD_VEHICLE_BOAT_IDLE',
    'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
    'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
    'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
    'WORLD_VEHICLE_BROKEN_DOWN',
    'WORLD_VEHICLE_BUSINESSMEN',
    'WORLD_VEHICLE_HELI_LIFEGUARD',
    'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
    'WORLD_VEHICLE_CONSTRUCTION_SOLO',
    'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
    'WORLD_VEHICLE_DRIVE_PASSENGERS',
    'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
    'WORLD_VEHICLE_DRIVE_SOLO',
    'WORLD_VEHICLE_FIRE_TRUCK',
    'WORLD_VEHICLE_EMPTY',
    'WORLD_VEHICLE_MARIACHI',
    'WORLD_VEHICLE_MECHANIC',
    'WORLD_VEHICLE_MILITARY_PLANES_BIG',
    'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
    'WORLD_VEHICLE_PARK_PARALLEL',
    'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
    'WORLD_VEHICLE_PASSENGER_EXIT',
    'WORLD_VEHICLE_POLICE_BIKE',
    'WORLD_VEHICLE_POLICE_CAR',
    'WORLD_VEHICLE_POLICE',
    'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
    'WORLD_VEHICLE_QUARRY',
    'WORLD_VEHICLE_SALTON',
    'WORLD_VEHICLE_SALTON_DIRT_BIKE',
    'WORLD_VEHICLE_SECURITY_CAR',
    'WORLD_VEHICLE_STREETRACE',
    'WORLD_VEHICLE_TOURBUS',
    'WORLD_VEHICLE_TOURIST',
    'WORLD_VEHICLE_TANDL',
    'WORLD_VEHICLE_TRACTOR',
    'WORLD_VEHICLE_TRACTOR_BEACH',
    'WORLD_VEHICLE_TRUCK_LOGS',
    'WORLD_VEHICLE_TRUCKS_TRAILERS',
    'WORLD_VEHICLE_DISTANT_EMPTY_GROUND'
}
for i, v in pairs(scenarios) do
    SetScenarioTypeEnabled(v, false)
end

Citizen.CreateThread(function()
	for a = 1, #weaponList do
		N_0x616093ec6b139dd9(PlayerId(), GetHashKey("PICKUP_"..weaponList[a]), false)
	end
	while true do
		Citizen.Wait(5)
	end
end)

CreateThread(function()
	while true do
		for Number = 1,22 do
			if Number ~= 14 and Number ~= 16 then
				HideHudComponentThisFrame(Number)
			end
		end
		
		BlockWeaponWheelThisFrame()
		DisableControlAction(0,37,true)
		RestorePlayerStamina(PlayerId(), 1.0)

		DisableControlAction(0,204,true)
		DisableControlAction(0,211,true)
		DisableControlAction(0,349,true)
		DisableControlAction(0,192,true)
		DisableControlAction(0,157,true)
		DisableControlAction(0,158,true)
		DisableControlAction(0,159,true)
		DisableControlAction(0,160,true)
		DisableControlAction(0,161,true)
		DisableControlAction(0,162,true)
		DisableControlAction(0,163,true)
		DisableControlAction(0,164,true)
		DisableControlAction(0,165,true)

		SetPlayerCanUseCover(PlayerId(),false) -- Voltar isso depois de gravar SIMBA
		ForceAmbientSiren(false)
		SetCreateRandomCops(false)
		SetCreateRandomCopsOnScenarios(false)
		SetCreateRandomCopsNotOnScenarios(false)
		SetDispatchCopsForPlayer(GetPlayerPed(-1),true)


		if IsPedArmed(PlayerPedId(),6) then
			DisableControlAction(0,140,true)
			DisableControlAction(0,141,true)
			DisableControlAction(0,142,true)
		end

		DisablePlayerVehicleRewards(PlayerId())

		if GetFirstBlipInfoId( 8 ) ~= 0 then
	
			local waypointBlip = GetFirstBlipInfoId( 8 ) 
			local coord = Citizen.InvokeNative( 0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector( ) ) 
			local x  = coord.x
			local y = coord.y
			local z = coord.z

			DrawMarker(1, x, y, z, 0, 0, 0, 0, 0, 0, 8.98103, 8.98103, 1000.0, 0, 62, 96, 179, 0, 0, 0, 0, 0, 0, 0)
		end

		if GetFirstBlipInfoId( 162 ) ~= 0 then

			local waypointBlip = GetFirstBlipInfoId( 162 ) 
			local coord = Citizen.InvokeNative( 0xFA7C7F0AADF25D09, waypointBlip, Citizen.ResultAsVector( ) ) 
			local x  = coord.x
			local y = coord.y
			local z = coord.z

			DrawMarker(1, x, y, z, 0, 0, 0, 0, 0, 0, 8.98103, 8.98103, 1000.0, 0, 62, 96, 179, 0, 0, 0, 0, 0, 0, 0)
		end
		
		if IsControlJustPressed(0, 244) then
			if not isRadarExtended then
			  SetRadarBigmapEnabled(true, false)
			  isRadarExtended = true
			else
			  SetRadarBigmapEnabled(false, false)
			  isRadarExtended = false
			end
		end

		Wait(0)
	end
end)

--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = GetConvarInt(('%s-debugMode'):format(currentResourceName), 0) == 1

--- A simple debug print function that is dependent on a convar
--- will output a nice prettfied message if debugMode is on
function debugPrint(...)
  if not debugIsEnabled then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^3[%s]^0%s'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end


Citizen.CreateThread(function()
	SetTextChatEnabled(false)
end)
  

function DeleteAllVehicles()
	local handle, veh = FindFirstVehicle()
	local success
	repeat
		success, veh = FindNextVehicle(handle)
		if DoesEntityExist(veh) then DeleteVehicle(veh) end
	until not success
		EndFindVehicle(handle)
end

function formatTwoDigitNumbers(string)
	string = tostring(string)
	return string.len(string) == 1 and "0" .. string or string
end

Citizen.CreateThread(function()
	StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- GETPLAYERS
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function GetPlayers()
-- 	local Selected = {}
-- 	local GamePool = GetGamePool("CPed")

-- 	for _,Entity in pairs(GamePool) do
-- 		local Index = NetworkGetPlayerIndexFromPed(Entity)

-- 		if Index and IsPedAPlayer(Entity) and NetworkIsPlayerConnected(Index) then
-- 			Selected[Entity] = GetPlayerServerId(Index)
-- 		end
-- 	end

-- 	return Selected
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- PASSPORTENALBLE
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function PassportEnable()
-- 	if not Information and not IsPauseMenuActive() then
-- 		Information = true
-- 		while Information do
-- 			local Ped = PlayerPedId()
-- 			local Coords = GetEntityCoords(Ped)
-- 			for Entitys,_ in pairs(GetPlayers()) do
-- 				local OtherCoords = GetEntityCoords(Entitys)
-- 				if HasEntityClearLosToEntity(Ped,Entitys,17) and #(Coords - OtherCoords) <= 5 then
-- 					DrawText3D(OtherCoords,"~w~"..Entity(Entitys)["state"]["Passport"],0.45)
-- 				end
-- 			end
-- 			Wait(0)
-- 		end
-- 	end
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- PASSPORTDISABLE
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function PassportDisable()
-- 	Information = false
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- REGISTERCOMMAND
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterCommand("+Information",PassportEnable)
-- RegisterCommand("-Information",PassportDisable)
-- RegisterKeyMapping("+Information","Visualizar passaportes.","keyboard","F7")
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- DRAWTEXT3D
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function DrawText3D(Coords,Text,Weight)
-- 	local onScreen,x,y = World3dToScreen2d(Coords["x"],Coords["y"],Coords["z"] + 1.10)

-- 	if onScreen then
-- 		SetTextFont(4)
-- 		SetTextCentre(true)
-- 		SetTextProportional(1)
-- 		SetTextScale(0.35,0.35)
-- 		SetTextColour(255,255,255,150)

-- 		SetTextEntry("STRING")
-- 		AddTextComponentString(Text)
-- 		EndTextCommandDisplayText(x,y)

-- 		local Width = string.len(Text) / 160 * Weight
-- 		DrawRect(x,y + 0.0125,Width,0.03,0, 0, 0,175)
-- 	end
-- end