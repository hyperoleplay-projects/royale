-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMLIST
-----------------------------------------------------------------------------------------------------------------------------------------
local itemlist = {
	["WEAPON_KNIFE"] = {
		["index"] = string.lower('WEAPON_KNIFE'),
		["name"] = "Faca",
		["type"] = "Armamento",
		["drop"] = true,
		["durability"] = 3,
		["weight"] = 0.75,
		["spawName"] = "WEAPON_KNIFE"
	},
	["WEAPON_PISTOL_MK2"] = {
		["index"] = string.lower('WEAPON_PISTOL_MK2'),
		["name"] = "FN Five Seven",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",

		["vehicle"] = true,
		["weight"] = 1.50,
		["spawName"] = "WEAPON_PISTOL_MK2"
	},
	["WEAPON_APPISTOL"] = {
		["index"] = string.lower('WEAPON_APPISTOL'),
		["name"] = "Koch Vp9",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_APPISTOL"
	},
	["WEAPON_MICROSMG"] = {
		["index"] = string.lower('WEAPON_MICROSMG'),
		["name"] = "Uzi",
		["type"] = "Armamento",
		["drop"] = true,
		["ammo"] = "WEAPON_AMMO",
		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_MICROSMG"
	},
	["WEAPON_MINISMG"] = {
		["index"] = string.lower('WEAPON_MINISMG'),
		["name"] = "Skorpion V61",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["vehicle"] = true,
		["weight"] = 1.75,
		["spawName"] = "WEAPON_MINISMG"
	},
	["WEAPON_COMBATPISTOL"] = {
		["index"] = string.lower('WEAPON_COMBATPISTOL'),
		["name"] = "Glock",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["vehicle"] = true,
		["weight"] = 1.25,
		["spawName"] = "WEAPON_COMBATPISTOL"
	},
	["WEAPON_CARBINERIFLE_MK2"] = {
		["index"] = string.lower('WEAPON_CARBINERIFLE_MK2'),
		["name"] = "M4A4",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["weight"] = 8.50,
		["spawName"] = "WEAPON_CARBINERIFLE_MK2"
	},
	["WEAPON_SPECIALCARBINE_MK2"] = {
		["index"] = string.lower('WEAPON_SPECIALCARBINE_MK2'),
		["name"] = "Sig Sauer 556",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["weight"] = 8.25,
		["spawName"] = "WEAPON_SPECIALCARBINE_MK2"
	},
	["WEAPON_ASSAULTRIFLE_MK2"] = {
		["index"] = string.lower('WEAPON_ASSAULTRIFLE_MK2'),
		["name"] = "AK-74",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["weight"] = 7.75,
		["spawName"] = "WEAPON_ASSAULTRIFLE_MK2"
	},
	["WEAPON_ASSAULTSMG"] = {
		["index"] = string.lower('WEAPON_ASSAULTSMG'),
		["name"] = "Steyr AUG",
		["drop"] = true,
		["type"] = "Armamento",
		["ammo"] = "WEAPON_AMMO",
		["weight"] = 5.75,
		["spawName"] = "WEAPON_ASSAULTSMG"
	},
	["GADGET_PARACHUTE"] = {
		["index"] = string.lower('GADGET_PARACHUTE'),
		["name"] = "Paraquedas",
		["type"] = "Usável",
		["weight"] = 2.25,
		["spawName"] = "GADGET_PARACHUTE"
	},
	["WEAPON_AMMO"] = {
		["index"] = "ammo",
		["drop"] = true,
		["name"] = "Munição de arma",
		["type"] = "Munição",
		["weight"] = 0.02,
		["spawName"] = "WEAPON_AMMO"
	},
	["ARMOUR_STANDARD"] = {
		["index"] = "vest",
		["name"] = "Colete",
		["type"] = "Usável",
		["weight"] = 2.25,
		["max"] = 1,
		["drop"] = true,
		["weight"] = 0.75,
		["spawName"] = "ARMOUR_STANDARD"
	},
	["HEALTH_STANDARD"] = {
		["index"] = "health",
		["name"] = "Bandagem",
		["type"] = "Usável",
		["drop"] = true,
		["weight"] = 0.10,
		["max"] = 3,
		["spawName"] = "HEALTH_STANDARD"
	},
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMBODY
-----------------------------------------------------------------------------------------------------------------------------------------
function itemBody(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMINDEX
-----------------------------------------------------------------------------------------------------------------------------------------
function itemIndex(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["index"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMNAME
-----------------------------------------------------------------------------------------------------------------------------------------
function itemName(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["name"]
	end

	return "Não existe"
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMTYPE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemType(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["type"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMMO
-----------------------------------------------------------------------------------------------------------------------------------------
function itemAmmo(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["ammo"]
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMVEHICLE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemVehicle(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["vehicle"] or false
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function itemWeight(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["weight"] or 0.0
	end

	return 0.0
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMMAXAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function itemMaxAmount(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["max"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMSCAPE
-----------------------------------------------------------------------------------------------------------------------------------------
function itemScape(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["scape"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDESCRIPTION
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDescription(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["desc"] or nil
	end

	return nil
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- itemDrop
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDrop(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["drop"] or false
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMDURABILITY
-----------------------------------------------------------------------------------------------------------------------------------------
function itemDurability(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["durability"] or false
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- itemSkins
-----------------------------------------------------------------------------------------------------------------------------------------
function itemSkins(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["skins"] or {}
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMCHARGES
-----------------------------------------------------------------------------------------------------------------------------------------
function itemCharges(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["charges"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMECONOMY
-----------------------------------------------------------------------------------------------------------------------------------------
-- function itemSpawnName(index)
-- 	for _, item in pairs(itemlist) do 
-- 		if index == item.index then
-- 			return item.spawName
-- 		end
-- 	end

-- 	return nil
-- end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMBLOCK
-----------------------------------------------------------------------------------------------------------------------------------------
function itemBlock(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["block"] or nil
	end

	return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMREPAIR
-----------------------------------------------------------------------------------------------------------------------------------------
function itemRepair(Item)
	local Split = splitString(Item,"-")
	local Item = Split[1]

	if itemlist[Item] then
		return itemlist[Item]["repair"] or false
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMSBYAMMO
-----------------------------------------------------------------------------------------------------------------------------------------
function itemsByAmmo(ammo)
	local items = {}

	for itemName, item in pairs(itemlist) do
		if item.ammo == ammo then
			table.insert(items, itemName)
		end
	end

	return items
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMSBYAMMO
-----------------------------------------------------------------------------------------------------------------------------------------
function indexByHash(hash)
	for itemName, item in pairs(itemlist) do
		if GetHashKey(item.spawName) == hash then
			return item.index
		end
	end

	return 'skull'
end