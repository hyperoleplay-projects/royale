local TesteInventory = {}
local WeaponPrimary = {}
local WeightInventory = {}
local actived = {}
local selfReturn = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkInventory()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if Active[user_id] ~= nil then
			return false
		end
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SHORTCUTS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.Shortcuts(source, user_id)
	if user_id then
		local Shortcuts = {}
		for i = 1, 5 do
			local Slot = tostring(i)
			Shortcuts[Slot] = vRP.userInventory(source, user_id)[Slot] and itemIndex(vRP.userInventory(source, user_id)[Slot]["item"]) or ""
		end
		return Shortcuts
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.dropWeapons(Item)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local consultItem = vRP.getInventoryItemAmount(user_id,Item)
		if consultItem[1] <= 0 then
			return true
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVETHROWABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.removeThrowable(nameItem)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.removeInventoryItem(user_id,nameItem,1,true)
		vRP.removeInventoryItem(user_id,nameItem,1,true)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.getWeight(user_id)
	-- local dataTable = vRP.getDatatable(user_id)
	-- if dataTable then
	-- 	if dataTable["weight"] == nil then
	-- 		dataTable["weight"] = 30
	-- 	end

	-- 	return dataTable["weight"]
	-- end

	if WeightInventory[user_id] == nil then
		WeightInventory[user_id] = 80
	end
	
	return WeightInventory[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.setWeight(user_id,amount)
	-- local dataTable = vRP.getDatatable(user_id)
	-- if dataTable then
		if WeightInventory[user_id] == nil then
			WeightInventory[user_id] = 80
		end

		WeightInventory[user_id] = WeightInventory[user_id] + parseInt(amount)
	-- end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SWAPSLOT	
-----------------------------------------------------------------------------------------------------------------------------------------	
function vRP.swapSlot(user_id,slot,target)
	local inventory = vRP.userInventory(source, user_id)
	if inventory then
		local temporary = inventory[tostring(slot)]
		inventory[tostring(slot)] = inventory[tostring(target)]
		inventory[tostring(target)] = temporary
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORYWEIGHT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.inventoryWeight(user_id)
	local totalWeight = 0
	local inventory = vRP.userInventory(source, user_id)

	for k,v in pairs(inventory) do
		if itemBody(v["item"]) then
			totalWeight = totalWeight + itemWeight(v["item"]) * parseInt(v["amount"])
		end
	end
	return totalWeight
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKBROKEN
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkBroken(nameItem)
	local splitName = splitString(nameItem,"-")
	if splitName[2] ~= nil then
		if itemDurability(nameItem) then
			local maxDurability = 86400 * itemDurability(nameItem)
			local actualDurability = parseInt(os.time() - splitName[2])
			local newDurability = (maxDurability - actualDurability) / maxDurability
			local actualPercent = parseInt(newDurability * 100)

			if actualPercent <= 1 then
				return true
			end
		end
	end

	return false
end


-----------------------------------------------------------------------------------------------------------------------------------------
-- GETINVENTORYITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventoryItemAmount(user_id,nameItem)
	local inventory = vRP.userInventory(source, user_id)

	for k,v in pairs(inventory) do
		local splitName01 = splitString(nameItem,"-")
		local splitName02 = splitString(v["item"],"-")
		if splitName01[1] == splitName02[1] then
			return { parseInt(v["amount"]),v["item"] }
		end
	end

	return { 0,"" }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ITEMAMOUNT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.itemAmount(user_id,nameItem)
	local totalAmount = 0
	local splitName = splitString(nameItem,"-")
	local inventory = vRP.userInventory(source, user_id)

	for k,v in pairs(inventory) do
		local splitItem = splitString(v["item"],"-")
		if splitItem[1] == splitName[1] then
			totalAmount = totalAmount + v["amount"]
		end
	end

	return parseInt(totalAmount)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GIVEINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.giveInventoryItem(user_id,nameItem,amount,notify,slot)
	if parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local source = vRP.getUserSource(user_id)
		local inventory = vRP.userInventory(source, user_id)

		if not slot then
			local initial = 0

			repeat
				initial = initial + 1
			until inventory[tostring(initial)] == nil or (inventory[tostring(initial)] and inventory[tostring(initial)]["item"] == nameItem) or initial > vRP.getWeight(user_id)

			if initial <= vRP.getWeight(user_id) then
				initial = tostring(initial)

				if inventory[initial] == nil then
					inventory[initial] = { item = nameItem, amount = amount }
				elseif inventory[initial] and inventory[initial]["item"] == nameItem then
					inventory[initial]["amount"] = parseInt(inventory[initial]["amount"]) + amount
				end

				if notify and itemBody(nameItem) then
					-- TriggerClientEvent("itensNotify",source,{ "recebeu",itemIndex(nameItem),amount,itemName(nameItem) })
				end
			end
		else
			local selectSlot = tostring(slot)

			if inventory[selectSlot] then
				if inventory[selectSlot]["item"] == nameItem then
					inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) + amount
				end
			else
				inventory[selectSlot] = { item = nameItem, amount = amount }
			end

			if notify and itemBody(nameItem) then
				-- TriggerClientEvent("itensNotify",source,{ "recebeu",itemIndex(nameItem),amount,itemName(nameItem) })
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DUMP
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.generateItem(user_id, nameItem, amount, notify, slot)
    if tonumber(amount) > 0 then
        local amount = tonumber(amount)
        local source = vRP.getUserSource(user_id)
        local nomeDoItem = ''
        local SkinsData = {}

        for k, v in pairs(itemSkins(nameItem)) do
            if not Player(source).state.userSkins then
                local userInventory = vRP.query('vRP/getInventory', {user_id = user_id})
                
				for k, v in pairs(userInventory) do
                    if v.inventory_itemType == 'skin' then
                        local item = exports.core:Config().Skins[v.inventory_itemName]
                        
						if item then
                            SkinsData[item.skin_spawnName] = {
                                skin_id = v.inventory_id, 
                                skin_spawnName = item.skin_spawnName, 
                                skin_name = item.skin_name, 
                                skin_category = item.skin_category, 
                                skin_model = item.skin_model, 
                                skin_image = item.skin_image, 
                                skin_status = v.inventory_itemStatus
                            }
                        end
                    end
                end
            end

            Player(source).state.userSkins = SkinsData

            Wait(300)

            if Player(source).state.userSkins then
                for kk, vv in pairs(Player(source).state.userSkins) do
                    if vv.skin_model == v.name then
                        if vv.skin_status == 'true' then
                            nomeDoItem = vv.skin_model
                        end
                    end
                end
            end
        end

        if nomeDoItem == '' then
            nomeDoItem = nameItem
        end

        local inventory = vRP.userInventory(source, user_id)

        if not slot then
            local initial = 0

            if itemType(nomeDoItem) ~= 'Munição' then
                repeat
                    initial = initial + 1
                until inventory[tostring(initial)] == nil or (inventory[tostring(initial)] and inventory[tostring(initial)].item == nomeDoItem) or initial > vRP.getWeight(user_id)
            else
                initial = 5

                repeat
                    initial = initial + 1
                until inventory[tostring(initial)] == nil or (inventory[tostring(initial)] and inventory[tostring(initial)].item == nomeDoItem) or initial > vRP.getWeight(user_id)
            end

            if initial <= vRP.getWeight(user_id) then
                initial = tostring(initial)

                if inventory[initial] == nil then
                    inventory[initial] = {
						item = nomeDoItem, 
						amount = amount
					}
                elseif inventory[initial] and inventory[initial].item == nomeDoItem then
                    inventory[initial].amount = tonumber(inventory[initial].amount) + amount
                end

                TesteInventory[user_id] = inventory
            end
        else
            local selectSlot = tostring(slot)

            if inventory[selectSlot] then
                if inventory[selectSlot].item == nomeDoItem then
                    inventory[selectSlot].amount = tonumber(inventory[selectSlot].amount) + amount
                end
            else
                inventory[selectSlot] = {item = nomeDoItem, amount = amount}
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKMAXITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.checkMaxItens(user_id,nameItem,amount)
	if itemBody(nameItem) then
		local amount = parseInt(amount)
		if itemMaxAmount(nameItem) ~= nil then
			if (vRP.itemAmount(user_id,nameItem) + amount) > itemMaxAmount(nameItem) then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DUMP
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKBACKPACK
-----------------------------------------------------------------------------------------------------------------------------------------
local checkBackpack = {
	["defibrillator"] = 100
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VERIFYITENS
-----------------------------------------------------------------------------------------------------------------------------------------
function verifyItens(user_id,nameItem)
	local source = vRP.getUserSource(user_id)
	local splitName = splitString(nameItem,"-")
	local midName = splitName[1]

	if itemType(nameItem) == "Armamento" then
		TriggerClientEvent("inventory:verifyWeapon",source,midName)
	elseif checkBackpack[midName] then
		local consultItem = vRP.getInventoryItemAmount(user_id,nameItem)
		
		if consultItem[1] <= 0 then
			TriggerClientEvent("skinshop:removeBackpack",source,checkBackpack[midName])
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetItem
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.GetItem(user_id, nameItem) 
	local inventory = vRP.userInventory(source, user_id)
	local source = vRP.getUserSource(user_id)
	selfReturn[user_id] = false

	for k,v in pairs(inventory) do
		if v["item"] == nameItem then
			selfReturn[user_id] = true
		end
	end
	return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYGETINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.tryGetInventoryItem(user_id, nameItem, amount, notify, slot)
    selfReturn[user_id] = false

    local amount = parseInt(amount)
    local source = vRP.getUserSource(user_id)
    local inventory = vRP.userInventory(source, user_id)

    if not slot then
        for k, v in pairs(inventory) do
            if v.item == nameItem and v.amount >= amount then
                v.amount = parseInt(v.amount) - amount

				if "Armamento" == itemType(nameItem) or "Throwing" ~= itemType(nameItem) then
					TriggerClientEvent("inventory:verifyWeapon", source, nameItem)
				end

                if parseInt(v.amount) <= 0 then
                    inventory[k] = nil
                end

                selfReturn[user_id] = true

                break
            end
        end
    else
        local selectSlot = tostring(slot)

        if inventory[selectSlot] and inventory[selectSlot].item == nameItem and parseInt(inventory[selectSlot].amount) >= amount then
            inventory[selectSlot].amount = parseInt(inventory[selectSlot].amount) - amount

			if "Armamento" == itemType(nameItem) or "Throwing" ~= itemType(nameItem) then
				TriggerClientEvent("inventory:verifyWeapon", source, nameItem)
			end

            if parseInt(inventory[selectSlot].amount) <= 0 then
                inventory[selectSlot] = nil
            end

            selfReturn[user_id] = true
        end
    end

    local splitName = splitString(nameItem, "-")
	
    if itemType(splitName[1]) == "Animal" then
        TriggerClientEvent("dynamic:animalFunctions", source, "deletar")
    end

    verifyItens(user_id, nameItem)

    return selfReturn[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEINVENTORYITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.removeInventoryItem(user_id,nameItem,amount,notify)
	local amount = parseInt(amount)
	local source = vRP.getUserSource(user_id)
	local inventory = vRP.userInventory(source, user_id)

	for k,v in pairs(inventory) do
		if v["item"] == nameItem and parseInt(v["amount"]) >= amount then
			v["amount"] = parseInt(v["amount"]) - amount

			if "Armamento" == itemType(nameItem) or "Throwing" ~= itemType(nameItem) then
				TriggerClientEvent("inventory:verifyWeapon", source, nameItem)
			end

			if parseInt(v["amount"]) <= 0 then
				inventory[k] = nil
			end
			break
		end
	end

	verifyItens(user_id,nameItem)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVUPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.invUpdate(user_id,slot,target,amount)
	selfReturn[user_id] = true

	if actived[user_id] == nil and parseInt(amount) > 0 then
		local amount = parseInt(amount)
		local selectSlot = tostring(slot)
		local targetSlot = tostring(target)
		local inventory = vRP.userInventory(source, user_id)

		if inventory[selectSlot] then
			actived[user_id] = true
			local nameItem = inventory[selectSlot]["item"]

			if inventory[targetSlot] then
				if inventory[selectSlot] and inventory[targetSlot] then
					local temporary = inventory[selectSlot]
					
					inventory[selectSlot] = inventory[targetSlot]
					inventory[targetSlot] = temporary
				end
			else
				if inventory[selectSlot] then
					if parseInt(inventory[selectSlot]["amount"]) >= amount then
						inventory[targetSlot] = { item = nameItem, amount = amount }
						inventory[selectSlot]["amount"] = parseInt(inventory[selectSlot]["amount"]) - amount

						if parseInt(inventory[selectSlot]["amount"]) <= 0 then
							inventory[selectSlot] = nil
						end
					end
				end
			end

			actived[user_id] = nil
		else 
			selfReturn[user_id] = false
		end
	end

	return selfReturn[user_id]
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- USERINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.userInventory(source, user_id)
	if TesteInventory[user_id] == nil then
		TesteInventory[user_id] = {}
		WeaponPrimary[user_id] = false
	end
	
	return TesteInventory[user_id]
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETARMOUR
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setArmour(source,amount)
	local ped = GetPlayerPed(source)
	local armour = GetPedArmour(ped)

	SetPedArmour(ped,parseInt(armour + amount))
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEAR INVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.clearInventory(user_id)
	TesteInventory[user_id] = {}
	WeaponPrimary[user_id] = false
end