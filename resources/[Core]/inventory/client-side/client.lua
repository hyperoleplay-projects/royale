-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("inventory",cRP)
vSERVER = Tunnel.getInterface("inventory")
vSERVERBattleRoyale = Tunnel.getInterface("core")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Drops = {}
local Weapon = ""
local Backpack = false
local weaponActive = false
local putWeaponHands = false
local storeWeaponHands = false
local timeReload = GetGameTimer()
local playerModel = nil
LocalPlayer["state"]["Buttons"] = false
local blips = {}
local coords = nil
local x,y,z = nil
local crate = nil
local parachute = nil
local pickingAirDrop = false
local particleId = 0
local NuiAbrir = false
local dropNoChao = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:BUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Buttons")
AddEventHandler("inventory:Buttons",function(status)
	LocalPlayer["state"]["Buttons"] = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADBLOCKBUTTONS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 1
		if LocalPlayer["state"]["Buttons"] and not LocalPlayer.state.inAimLab then
			timeDistance = 1
			DisableControlAction(1,75,true)
			DisableControlAction(1,47,true)
			DisableControlAction(1,257,true)
			DisablePlayerFiring(PlayerPedId(),true)
		end

		if Backpack then
			SetPauseMenuActive(false)
			DisablePlayerFiring(PlayerPedId(),true)
		end
		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- throwableWeapons
-----------------------------------------------------------------------------------------------------------------------------------------
local currentWeapon = ""
RegisterNetEvent("inventory:throwableWeapons")
AddEventHandler("inventory:throwableWeapons",function(weaponName)
	currentWeapon = weaponName

	local ped = PlayerPedId()
	if GetSelectedPedWeapon(ped) == GetHashKey(currentWeapon) then
		while GetSelectedPedWeapon(ped) == GetHashKey(currentWeapon) do
			if IsPedShooting(ped) then
				vSERVER.removeThrowable(currentWeapon)
			end
			Wait(0)
		end
		currentWeapon = ""
	else
		cRP.storeWeaponHands()
		currentWeapon = ""
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Close")
AddEventHandler("inventory:Close",function()
	if Backpack then
		TriggerEvent("luiz:compassStatus", true)
		SetNuiFocusKeepInput(false)
		SetNuiFocus(false,false)
		SetCursorLocation(0.5,0.5)
		TriggerEvent("showHud")
		DisplayRadar(true)
		SendNUIMessage({ action = "hideMenu" })
		Wait(100)
		Backpack = false
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVCLOSE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("invClose",function()
	TriggerEvent("inventory:Close")
	TriggerEvent("luiz:compassStatus", true)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CRAFT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Craft",function()
	Backpack = false
	SetNuiFocus(false,false)
	TriggerEvent("hud:Active",true)
	SendNUIMessage({ action = "hideMenu" })

	TriggerEvent("crafting:openSource")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELIVER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("Deliver",function(data)
	TriggerServerEvent("inventory:Deliver",data["slot"],data["amount"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- USEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("useItem",function(data)
	TriggerServerEvent("inventory:useItem",data["slot"],data["amount"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SENDITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("sendItem",function(data)
	vSERVERBattleRoyale.DropInventoryItem(data["slot"],data["amount"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESLOT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("updateSlot",function(data)
	vSERVER.invUpdateEE(data["slot"],data["target"],data["amount"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:Update")
AddEventHandler("inventory:Update",function(action)
	SendNUIMessage({ action = action })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CLEARWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:clearWeapons")
AddEventHandler("inventory:clearWeapons",function()
	if Weapon ~= "" then
		Weapon = ""
		weaponActive = false
		RemoveAllPedWeapons(PlayerPedId(),true)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:VERIFYWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:verifyWeapon")
AddEventHandler("inventory:verifyWeapon",function(splitName)
	if Weapon == splitName then
		local ped = PlayerPedId()
		local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)
		if not vSERVER.verifyWeapon(Weapon,weaponAmmo) then
			RemoveAllPedWeapons(ped,true)
			weaponActive = false
			Weapon = ""
		end
	else
		if Weapon == "" then
			vSERVER.existWeapon(splitName)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:PREVENTWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:preventWeapon")
AddEventHandler("inventory:preventWeapon",function(storeWeapons)
	if Weapon ~= "" then
		local ped = PlayerPedId()
		local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)

		vSERVER.preventWeapon(Weapon,weaponAmmo)

		weaponActive = false
		Weapon = ""

		if storeWeapons then
			RemoveAllPedWeapons(ped,true)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- openBackpack
-----------------------------------------------------------------------------------------------------------------------------------------
local function openBackpack(source,args,rawCommand)
	if GetEntityHealth(PlayerPedId()) > 101 and not LocalPlayer["state"]["Buttons"] then
		if not LocalPlayer["state"]["Commands"] and not LocalPlayer["state"]["Handcuff"] and not IsPlayerFreeAiming(PlayerId()) then
			if not Backpack then
				Backpack = true
				TriggerEvent("luiz:compassStatus", false)
				SetNuiFocus(true,true)
				SetNuiFocusKeepInput(true)
				SetCursorLocation(0.5,0.5)
				TriggerEvent("hideHud")
				DisplayRadar(false)
				SendNUIMessage({ action = "showMenu" })
				DisablePlayerFiring(PlayerPedId(),false)
			else
				TriggerEvent("luiz:compassStatus", true)
				SetNuiFocusKeepInput(false)
				SetNuiFocus(false,false)
				SetCursorLocation(0.5,0.5)
				TriggerEvent("showHud")
				DisplayRadar(true)
				SendNUIMessage({ action = "hideMenu" })
				Backpack = false
			end
		end
	end
end

Citizen.CreateThread(function()
	while true do 
		if IsControlJustPressed(0, 37) or IsDisabledControlJustPressed(0, 37) then 
			openBackpack()
		end 

		Citizen.Wait(not Backpack and 0 or 500)
	end 
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PARACHUTECOLORS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.parachuteColors()
	local ped = PlayerPedId()
	GiveWeaponToPed(ped,"GADGET_PARACHUTE",1,false,true)
	SetPedParachuteTintIndex(ped,math.random(7))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.returnWeapon()
	if Weapon ~= "" then
		return Weapon
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkWeapon(Hash)
	if Weapon == Hash then
		return true
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- WEAPONATTACHS
-----------------------------------------------------------------------------------------------------------------------------------------
local weaponAttachs = {
	["attachsFlashlight"] = {
		["WEAPON_PISTOL"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_PISTOL_MK2"] = "COMPONENT_AT_PI_FLSH_02",
		["WEAPON_APPISTOL"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_HEAVYPISTOL"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_MICROSMG"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_SNSPISTOL_MK2"] = "COMPONENT_AT_PI_FLSH_03",
		["WEAPON_PISTOL50"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_COMBATPISTOL"] = "COMPONENT_AT_PI_FLSH",
		["WEAPON_CARBINERIFLE"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_CARBINERIFLE_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_BULLPUPRIFLE"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_BULLPUPRIFLE_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_SPECIALCARBINE"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_SPECIALCARBINE_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_PUMPSHOTGUN"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_PUMPSHOTGUN_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_SMG"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_SMG_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_ASSAULTRIFLE"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_ASSAULTRIFLE_MK2"] = "COMPONENT_AT_AR_FLSH",
		["WEAPON_ASSAULTSMG"] = "COMPONENT_AT_AR_FLSH"
	},
	["attachsCrosshair"] = {
		["WEAPON_PISTOL_MK2"] = "COMPONENT_AT_PI_RAIL",
		["WEAPON_SNSPISTOL_MK2"] = "COMPONENT_AT_PI_RAIL_02",
		["WEAPON_MICROSMG"] = "COMPONENT_AT_SCOPE_MACRO",
		["WEAPON_CARBINERIFLE"] = "COMPONENT_AT_SCOPE_MEDIUM",
		["WEAPON_CARBINERIFLE_MK2"] = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
		["WEAPON_BULLPUPRIFLE"] = "COMPONENT_AT_SCOPE_SMALL",
		["WEAPON_BULLPUPRIFLE_MK2"] = "COMPONENT_AT_SCOPE_MACRO_02_MK2",
		["WEAPON_SPECIALCARBINE"] = "COMPONENT_AT_SCOPE_MEDIUM",
		["WEAPON_SPECIALCARBINE_MK2"] = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
		["WEAPON_PUMPSHOTGUN_MK2"] = "COMPONENT_AT_SCOPE_SMALL_MK2",
		["WEAPON_SMG"] = "COMPONENT_AT_SCOPE_MACRO_02",
		["WEAPON_SMG_MK2"] = "COMPONENT_AT_SCOPE_SMALL_SMG_MK2",
		["WEAPON_ASSAULTRIFLE"] = "COMPONENT_AT_SCOPE_MACRO",
		["WEAPON_ASSAULTRIFLE_MK2"] = "COMPONENT_AT_SCOPE_MEDIUM_MK2",
		["WEAPON_ASSAULTSMG"] = "COMPONENT_AT_SCOPE_MACRO"
	},
	["attachsSilencer"] = {
		["WEAPON_PISTOL"] = "COMPONENT_AT_PI_SUPP_02",
		["WEAPON_APPISTOL"] = "COMPONENT_AT_PI_SUPP",
		["WEAPON_MACHINEPISTOL"] = "COMPONENT_AT_PI_SUPP",
		["WEAPON_BULLPUPRIFLE"] = "COMPONENT_AT_AR_SUPP",
		["WEAPON_PUMPSHOTGUN_MK2"] = "COMPONENT_AT_SR_SUPP_03",
		["WEAPON_SMG"] = "COMPONENT_AT_PI_SUPP",
		["WEAPON_SMG_MK2"] = "COMPONENT_AT_PI_SUPP",
		["WEAPON_ASSAULTSMG"] = "COMPONENT_AT_AR_SUPP_02",
		["WEAPON_SPECIALCARBINE"] = "COMPONENT_AT_AR_SUPP_02",
	},
	["attachsGrip"] = {
		["WEAPON_CARBINERIFLE"] = "COMPONENT_AT_AR_AFGRIP",
		["WEAPON_CARBINERIFLE_MK2"] = "COMPONENT_AT_AR_AFGRIP_02",
		["WEAPON_BULLPUPRIFLE_MK2"] = "COMPONENT_AT_MUZZLE_01",
		["WEAPON_SPECIALCARBINE"] = "COMPONENT_AT_AR_AFGRIP",
		["WEAPON_SPECIALCARBINE_MK2"] = "COMPONENT_AT_MUZZLE_01",
		["WEAPON_PUMPSHOTGUN_MK2"] = "COMPONENT_AT_MUZZLE_08",
		["WEAPON_SMG_MK2"] = "COMPONENT_AT_MUZZLE_01",
		["WEAPON_ASSAULTRIFLE"] = "COMPONENT_AT_AR_AFGRIP",
		["WEAPON_ASSAULTRIFLE_MK2"] = "COMPONENT_AT_AR_AFGRIP_02"
	}
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKATTACHS - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.checkAttachs(nameItem,nameWeapon)
	return weaponAttachs[nameItem][nameWeapon]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PUTATTACHS - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.putAttachs(nameItem,nameWeapon)
	GiveWeaponComponentToPed(PlayerPedId(),nameWeapon,weaponAttachs[nameItem][nameWeapon])
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PUTWEAPONHANDS - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.putWeaponHands(weaponName, weaponAmmo, attachs)
	if not putWeaponHands then
	  if weaponAmmo == nil then
		weaponAmmo = 0
	  elseif weaponAmmo > 250 then -- Limite máximo de munições
		weaponAmmo = 250
	  end
  
	  if weaponAmmo > 0 then
		weaponActive = true
	  end
  
	  putWeaponHands = true
  
	  local ped = PlayerPedId()
	  if HasPedGotWeapon(ped, GetHashKey("GADGET_PARACHUTE"), false) then
		RemoveAllPedWeapons(ped, true)
		cRP.parachuteColors()
	  else
		RemoveAllPedWeapons(ped, true)
	  end
  
	  GiveWeaponToPed(ped, weaponName, weaponAmmo, false, true)
	  ClearPedTasks(ped)
  
	  if attachs ~= nil then
		for nameItem, _ in pairs(attachs) do
		  cRP.putAttachs(nameItem, weaponName)
		end
	  end
  
	  putWeaponHands = false
	  Weapon = weaponName
  
	  if vSERVER.dropWeapons(Weapon) then
		weaponActive = false
		Weapon = ""
	  end
  
	  return true
	end
  
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setColete - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.setColete(amount)
	SetPedArmour(PlayerPedId(), 100)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREWEAPONHANDS
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.storeWeaponHands()
	if not storeWeaponHands then
		storeWeaponHands = true
		local ped = PlayerPedId()
		local lastWeapon = Weapon
		LocalPlayer["state"]["Cancel"] = true
		local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)


		LocalPlayer["state"]["Cancel"] = false
		RemoveAllPedWeapons(ped,true)

		storeWeaponHands = false
		weaponActive = false
		Weapon = ""

		return true,weaponAmmo,lastWeapon
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECHARGECHECK
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.rechargeCheck(ammoType)
	local weaponAmmo = 0
	local weaponHash = nil
	local Ped = PlayerPedId()
	local weaponStatus = false

	local weaponsByAmmoType = itemsByAmmo(ammoType)

	if weaponsByAmmoType then
		weaponAmmo = GetAmmoInPedWeapon(Ped,Weapon)

		for _, weaponName in pairs(weaponsByAmmoType) do
			if Weapon == v then
				weaponHash = Weapon
				weaponStatus = true
				break
			end
		end
	end

	return weaponStatus,weaponHash,weaponAmmo
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Energetico
-----------------------------------------------------------------------------------------------------------------------------------------
local enableEnergetic = false

function setEnergetic(status)
    enableEnergetic = status
    if enableEnergetic then
        SetRunSprintMultiplierForPlayer(PlayerId(),1.20)
    else
        SetRunSprintMultiplierForPlayer(PlayerId(),1.0)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Energetico
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.activeEnergetic() 
    setEnergetic(true)
	SetTimeout(20000,function()
			setEnergetic(false)
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RECHARGEWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.rechargeWeapon(weaponHash,ammoAmount)
	AddAmmoToPed(PlayerPedId(),weaponHash,ammoAmount)
	weaponActive = true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSTOREWEAPON
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)

	while true do
		local timeDistance = 999
		if weaponActive and Weapon ~= "" then
			timeDistance = 5
			local ped = PlayerPedId()
			local weaponAmmo = GetAmmoInPedWeapon(ped,Weapon)

			if GetGameTimer() >= timeReload and IsPedReloading(ped) then
				vSERVER.preventWeapon(Weapon,weaponAmmo)
				timeReload = GetGameTimer() + 1000
			end

			if weaponAmmo <= 0 or (Weapon == "WEAPON_PETROLCAN" and weaponAmmo <= 135 and IsPedShooting(ped)) or IsPedSwimming(ped) then
				vSERVER.preventWeapon(Weapon,weaponAmmo)
				RemoveAllPedWeapons(ped,true)
				weaponActive = false
				Weapon = ""
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIMDIC
-----------------------------------------------------------------------------------------------------------------------------------------
function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(1)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("requestInventory",function(data,cb)
	local Items = {}
	local ped = PlayerPedId()
	local coords = GetEntityCoords(ped)
	local _,cdz = GetGroundZFor_3dCoord(coords["x"],coords["y"],coords["z"])

	for k,v in pairs(Drops) do
		local distance = #(vector3(coords["x"],coords["y"],cdz) - vector3(v["coords"][1],v["coords"][2],v["coords"][3]))
		if distance <= 0.9 then
			local Number = #Items + 1

			Items[Number] = v
			Items[Number]["id"] = k
		end
	end

	local inventario,invPeso,invMaxpeso = vSERVER.requestInventory()
	if inventario then
		cb({ inventario = inventario, drop = Items, invPeso = invPeso, invMaxpeso = invMaxpeso })
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PICKUPITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("pickupItem",function(data)
	TriggerServerEvent("inventory:Pickup",data["id"],data["amount"],data["target"])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ONRESOURCESTOP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStop",function(resource)
	TriggerServerEvent("vRP:Print","pausou o resource "..resource)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local StealPeds = {}
local StealTimer = GetGameTimer()
-----------------------------------------------------------------------------------------------------------------------------------------
-- BIND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cRbindInventory",function(source,args,rawCommand)
	local ped = PlayerPedId()
	if GetEntityHealth(PlayerPedId()) > 101 and not LocalPlayer["state"]["Buttons"] and not IsPauseMenuActive() then
		if not IsPauseMenuActive() then
			local isInParachuteFreeFall = IsPedInParachuteFreeFall(ped)
			if parseInt(args[1]) >= 1 and parseInt(args[1]) <= 5 and not isInParachuteFreeFall then
				TriggerServerEvent("inventory:useItem",args[1],1)
			end
		end
	end
end)

RegisterKeyMapping("cRbindInventory 1","Interação do botão 1.","keyboard","1")
RegisterKeyMapping("cRbindInventory 2","Interação do botão 2.","keyboard","2")
RegisterKeyMapping("cRbindInventory 3","Interação do botão 3.","keyboard","3")
RegisterKeyMapping("cRbindInventory 4","Interação do botão 4.","keyboard","4")
RegisterKeyMapping("cRbindInventory 5","Interação do botão 5.","keyboard","5")

	
RegisterNetEvent("PlayAnim")
AddEventHandler("PlayAnim",function(name1, name2)
	while ( not HasAnimDictLoaded( name1 ) ) do
		RequestAnimDict( name1 )
		Citizen.Wait( 5 )
	end
	TaskPlayAnim(PlayerPedId(), name1, name2, 3.0,2.0,-1,48,10,0,0,0);
end)

RegisterNetEvent("StopAnim")
AddEventHandler("StopAnim",function(name1, name2)
	StopAnimTask(PlayerPedId(), name1, name2, -4.0);
end)


RegisterCommand("+StopUso", function() 
	vSERVER.StopUso()
end)

RegisterKeyMapping("+StopUso","Cancelar uso de items.","keyboard","E")

function cRP.getHealth()
	return GetEntityHealth(PlayerPedId())
end

function cRP.getArmour()
	return GetPedArmour(PlayerPedId())
end

-- Munição automatica
local isShooting = false

Citizen.CreateThread(function()
   while true do
      if IsPedShooting(PlayerPedId()) and LocalPlayer.state.inGame then -- Verificar se o jogador está atirando
         if not isShooting then
            isShooting = true
			local lastWeapon = Weapon

			Wait(3000)
			TriggerServerEvent("playerShot", lastWeapon)
         end
      else
         isShooting = false
      end
      Citizen.Wait(0)
   end
end)

--------------------------------------------------------------------------------------------------------------------------------
-- CREATEAIRSUPPLYBLIP
--------------------------------------------------------------------------------------------------------------------------------
local function createAirSupplyBlip(index, delete, x, y, z, sprite, colour, scale, text)
    if not delete then
        blips[index] = AddBlipForCoord(x, y, z)
        SetBlipSprite(blips[index],sprite)
        SetBlipColour(blips[index],colour)
        SetBlipScale(blips[index],scale)
        SetBlipAsShortRange(blips[index],true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(text)
        EndTextCommandSetBlipName(blips[index])
    else
        if DoesBlipExist(blips[index]) then
            RemoveBlip(blips[index])
        end
        blips[index] = nil
    end
end
--------------------------------------------------------------------------------------------------------------------------------
-- CHECKAREACLEAROFPLAYER
--------------------------------------------------------------------------------------------------------------------------------
local function checkAreaClearOfPlayer(radius)

    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    for k, v in pairs(GetActivePlayers()) do
        local nped = GetPlayerPed(v)
        local npedCoords = GetEntityCoords(nped)
        if ped ~= nped then
            if Vdist2(pedCoords,npedCoords) <= radius then
                if GetEntityHealth(nped) > 101 then
                    return false
                end
            end
        end
    end

    return true
end
--------------------------------------------------------------------------------------------------------------------------------
-- FINISHEVENT
--------------------------------------------------------------------------------------------------------------------------------
function finishEvent()
    if DoesEntityExist(crate) then
        DeleteEntity(crate)
    end

    if DoesEntityExist(dropNoChao) then
        DeleteEntity(dropNoChao)
    end

    if DoesEntityExist(parachute) then
        DeleteEntity(parachute)
    end

    DeleteObject(parachuteObj)
    DeleteObject(crateObj)

    coords = nil
    crate = nil
    parachute = nil
    dropNoChao = false
    createAirSupplyBlip('airSupplyArea', true)
    createAirSupplyBlip('airSupplyCenterFalling', true)
    createAirSupplyBlip('airSupplyCenterOnFloor', true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:UseAirDrop
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:UseAirDrop")
AddEventHandler("inventory:UseAirDrop",function()
	local xx,yy,zz = table.unpack(GetEntityCoords(PlayerPedId()))
	TriggerEvent("NotifyAnnouncement", { status = true, timer = true, text = "Seu <b>AirDrop</b> está a caminho! Por favor, esteja atento para evitar qualquer <b>morte</b> caso ele caia em cima de você." })
    local crateObj = GetHashKey('ex_prop_adv_case_sm_03')
    local parachuteObj = GetHashKey('p_parachute1_mp_dec')
	x, y, z = xx,yy,zz
	evento = true
    local sky = z + 200
    local floor = z - 1.0

    crate = CreateObject(crateObj, x, y, sky, false, true, false)
    SetEntityAsMissionEntity(crate,true,true)

    parachute = CreateObject(parachuteObj, x, y, sky, false, true, false)

    FreezeEntityPosition(crate, true)
    FreezeEntityPosition(parachute, true)

    AttachEntityToEntity(parachute, crate, 0, 0.0, 0.0, 3.4, 0.0, 0.0, 0.0, false, false, false, true, 2, true)

	createAirSupplyBlip('airSupplyCenterFalling', false, x, y, z, 94, 5, 1.0, 'Airdrop no ar')

    while sky > floor do
        sky = sky - 0.1
        SetEntityCoords(crate, x, y, sky)

        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        local _, _, pedZ = table.unpack(pedCoords)

        if #(pedCoords - vector3( x, y, sky)) <= 1.7 then
            SetEntityHealth(ped, 101)
        end

        if sky - floor <= 1 then
            if parachute then
                DeleteEntity(parachute)
            end

            createAirSupplyBlip('airSupplyCenterFalling', true)
            createAirSupplyBlip('airSupplyCenterOnFloor', false, x, y, z, 478, 5, 1.0, 'Seu airdrop')
            SetEntityCoords(crate,x,y,floor)
            PlaceObjectOnGroundProperly(crate)

            dropNoChao = true
            break
        end
        Citizen.Wait(15) 
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CreateThread -- AirDrop
-----------------------------------------------------------------------------------------------------------------------------------------
-- Citizen.CreateThread(function()
--     local isNear = false

--     while true do
-- 			local timeDistance = 2000
			
-- 			if evento ~= nil then
-- 				timeDistance = 5
-- 				local ped = PlayerPedId()
-- 				local pedCoords = GetEntityCoords(ped)
-- 				local dist = #(pedCoords - vector3(x, y, z))
				
-- 				if not IsPedInAnyVehicle(ped) and not LocalPlayer.state.death and not LocalPlayer.state.agonizing and not pickingAirDrop and dropNoChao == true then
-- 					if dist <= 1.5 then
-- 						if not isNear then
-- 							isNear = true
-- 							TriggerEvent("NotifyKeyboardInfo", {
-- 								status = true,
-- 								key = "E",
-- 								text = "Abrir airdrop"
-- 							})
-- 						end
			
-- 						if IsControlJustPressed(0, 38) then
-- 							if isNear then
-- 								isNear = false
-- 								TriggerEvent("NotifyKeyboardInfo", { status = false })
-- 							end
-- 							finishEvent()
-- 							vSERVER.OpenAirSuplement()
-- 						end
-- 					else
-- 							if isNear then
-- 								isNear = false
-- 								TriggerEvent("NotifyKeyboardInfo", { status = false })
-- 							end
-- 					end
-- 				end
-- 			end

-- 			Citizen.Wait(timeDistance)
--     end
-- end)