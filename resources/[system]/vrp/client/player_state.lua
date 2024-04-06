local weapon_list = {}					  
local state_ready = false

function tvRP.playerStateReady(state)
	state_ready = state
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(15000)
		if IsPlayerPlaying(PlayerId()) and state_ready then
			local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
			vRPserver._updatePos(x,y,z)
			vRPserver._updateHealth(tvRP.getHealth())
			vRPserver._updateCustomization(tvRP.getCustomization())
		end
	end
end)

function tvRP.replaceWeapons(weapons)
	local old_weapons = tvRP.getWeapons()
	tvRP.giveWeapons(weapons,true)
	return old_weapons
end

function tvRP.giveWeapons(weapons,clear_before)
	local player = PlayerPedId()
	if clear_before then
		RemoveAllPedWeapons(player,true)
		weapon_list = {}	  
	end

	for k,weapon in pairs(weapons) do
		local hash = GetHashKey(k)
		local ammo = weapon.ammo or 0
		GiveWeaponToPed(player,hash,ammo,false)
		weapon_list[string.upper(k)] = weapon										   
	end
end

local function parse_part(key)
	if type(key) == "string" and string.sub(key,1,1) == "p" then
		return true,tonumber(string.sub(key,2))
	else
		return false,tonumber(key)
	end
end

function tvRP.getDrawables(part)
	local isprop, index = parse_part(part)
	if isprop then
		return GetNumberOfPedPropDrawableVariations(PlayerPedId(),index)
	else
		return GetNumberOfPedDrawableVariations(PlayerPedId(),index)
	end
end

function tvRP.getCustomization()
	local ped = PlayerPedId()
	local custom = {}
	custom.modelhash = GetEntityModel(ped)

	for i = 0,20 do
		custom[i] = { GetPedDrawableVariation(ped,i),GetPedTextureVariation(ped,i),GetPedPaletteVariation(ped,i) }
	end

	for i = 0,10 do
		custom["p"..i] = { GetPedPropIndex(ped,i),math.max(GetPedPropTextureIndex(ped,i),0) }
	end
	return custom
end

function tvRP.setCustomization(custom)
	local r = async()
	Citizen.CreateThread(function()
		if custom then
			local ped = GetPlayerPed(-1)
			local mhash = nil

			if custom.modelhash then
				mhash = custom.modelhash
			elseif custom.model then
				mhash = GetHashKey(custom.model)
			end

			if mhash then
                local i = 0
                while not HasModelLoaded(mhash) and i < 10000 do
                    i = i + 1
                    RequestModel(mhash)
                    Citizen.Wait(10)
                end

                if HasModelLoaded(mhash) then
                    local health = tvRP.getHealth() or 399

					SetPlayerModel(PlayerId(),mhash)
					Wait(500)
                    tvRP.setHealth(health)
					Wait(500)
                    SetModelAsNoLongerNeeded(mhash)
                end
            end

			ped = GetPlayerPed(-1)
			SetPedMaxHealth(ped,400)
		end
		r()
	end)
	return r:wait()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setTattos - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setTattos(ped, tattos) 
	if not tattos then
		return
	end
	
	ClearPedDecorations(ped)

	for k,v in pairs(tattos) do
		if v["tatto_status"] == "true" then
			SetPedDecoration(ped,GetHashKey(v["tatto_part"]),GetHashKey(v["tatto_model"]))
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setTattos - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.SetTattos(tattos) 
	local ped = PlayerPedId()
	ClearPedDecorations(PlayerPedId())

	for k,v in pairs(tattos) do
		if v["tatto_status"] == "true" then
			SetPedDecoration(ped,GetHashKey(v["tatto_part"]),GetHashKey(v["tatto_model"]))
		end
	end

	TriggerEvent("updateTatuagem", tattos)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setClothing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setClothing(custom)
	local data = json.decode(custom)
	local ped = PlayerPedId()
	if not data then
		return
	end
	
	SetPedComponentVariation(ped,4,data["pants"]["item"],data["pants"]["texture"],1)
	SetPedComponentVariation(ped,3,data["arms"]["item"],data["arms"]["texture"],1)
	SetPedComponentVariation(ped,5,data["backpack"]["item"],data["backpack"]["texture"],1)
	SetPedComponentVariation(ped,8,data["tshirt"]["item"],data["tshirt"]["texture"],1)
	SetPedComponentVariation(ped,9,data["vest"]["item"],data["vest"]["texture"],1)
	SetPedComponentVariation(ped,11,data["torso"]["item"],data["torso"]["texture"],1)
	SetPedComponentVariation(ped,6,data["shoes"]["item"],data["shoes"]["texture"],1)
	SetPedComponentVariation(ped,1,data["mask"]["item"],data["mask"]["texture"],1)
	SetPedComponentVariation(ped,10,data["decals"]["item"],data["decals"]["texture"],1)
	SetPedComponentVariation(ped,7,data["accessory"]["item"],data["accessory"]["texture"],1)

	if data["hat"]["item"] ~= -1 and data["hat"]["item"] ~= 0 then
		SetPedPropIndex(ped,0,data["hat"]["item"],data["hat"]["texture"],1)
	else
		ClearPedProp(ped,0)
	end

	if data["glass"]["item"] ~= -1 and data["glass"]["item"] ~= 0 then
		SetPedPropIndex(ped,1,data["glass"]["item"],data["glass"]["texture"],1)
	else
		ClearPedProp(ped,1)
	end

	if data["ear"]["item"] ~= -1 and data["ear"]["item"] ~= 0 then
		SetPedPropIndex(ped,2,data["ear"]["item"],data["ear"]["texture"],1)
	else
		ClearPedProp(ped,2)
	end

	if data["watch"]["item"] ~= -1 and data["watch"]["item"] ~= 0 then
		SetPedPropIndex(ped,6,data["watch"]["item"],data["watch"]["texture"],1)
	else
		ClearPedProp(ped,6)
	end

	if data["bracelet"]["item"] ~= -1 and data["bracelet"]["item"] ~= 0 then
		SetPedPropIndex(ped,7,data["bracelet"]["item"],data["bracelet"]["texture"],1)
	else
		ClearPedProp(ped,7)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setTattos - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setTattos(tattos)
	local data = json.decode(tattos)
	local ped = PlayerPedId()

	if not data then
		return
	end
	
	ClearPedDecorations(ped)
	for k,v in pairs(data) do
		SetPedDecoration(ped,GetHashKey(v[1]),GetHashKey(k))
	end
end
