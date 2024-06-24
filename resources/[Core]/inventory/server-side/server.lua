-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("inventory",cRP)
vCLIENT = Tunnel.getInterface("inventory")
vServerBatlleRoyale = Tunnel.getInterface("core")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Drops = {}
local Carry = {}
local Ammos = {}
local AirDrop = {}
local Loots = {}
local Boxes = {}
local Active = {}
local Trashs = {}
local actived = {}
local selfReturn = {}
local Armors = {}
local Plates = {}
local Trunks = {}
local Inventory = {}
local Objects = {}
local Healths = {}
local Animals = {}
local Attachs = {}
local Scanners = {}
local Stockade = {}
local openIdentity = {}
local verifyObjects = {}
local verifyAnimals = {}
local cancelPressed = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUESTINVENTORY
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.requestInventory()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local myInventory = {}
		local inventory = vRP.userInventory(source, user_id)
		for k,v in pairs(inventory) do
			if (parseInt(v["amount"]) <= 0 or itemBody(v["item"]) == nil) then
				vRP.removeInventoryItem(user_id,v["item"],parseInt(v["amount"]),false)
			else
				v["amount"] = parseInt(v["amount"])
				v["name"] = itemName(v["item"])
				v["peso"] = itemWeight(v["item"])
				v["index"] = itemIndex(v["item"])
				v["max"] = itemMaxAmount(v["item"])
				v["type"] = itemType(v["item"])
				v["desc"] = itemDescription(v["item"])
				v["key"] = v["item"]
				v["slot"] = k
	
				local splitName = splitString(v["item"],"-")
				if splitName[2] ~= nil then
					if itemDurability(v["item"]) then
						v["durability"] = parseInt(os.time() - splitName[2])
						v["days"] = itemDurability(v["item"])
					else
						v["durability"] = 0
						v["days"] = 1
					end
				else
					v["durability"] = 0
					v["days"] = 1
				end

				myInventory[k] = v
			end
		end

		return myInventory,vRP.inventoryWeight(user_id),vRP.getWeight(user_id)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVUPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.invUpdateEE(Slot,Target,Amount)
	local source = source
	local Slot = tostring(Slot)
	local Target = tostring(Target)
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.invUpdate(user_id,Slot,Target,Amount) then
			TriggerClientEvent("inventory:Update",source,"updateMochila")
		end
	end
	vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
end
local WeaponPrimary = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GenerateItemWeapon
-----------------------------------------------------------------------------------------------------------------------------------------
function GenerateItemWeapon(user_id,nameItem,amount)
	vRP.generateItem(user_id,nameItem,amount,true)
	WeaponPrimary[user_id] = true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetMunicao
-----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterCommand('muni', function(source)
-- 	local user_id = vRP.getUserId(source)

-- 	vRP.generateItem(user_id,'WEAPON_AMMO',15,true)
-- end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:USEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:useItem")
AddEventHandler("inventory:useItem",function(Slot,Amount)
	local source = source
	local Slot = tostring(Slot)
	local Amount = parseInt(Amount)
	local user_id = vRP.getUserId(source)
	if user_id and Active[user_id] == nil then
		if Amount == 0 then Amount = 1 end
		local inventory = vRP.userInventory(source, user_id)
		if not inventory[Slot] or inventory[Slot]["item"] == nil then
			return
		end

		local splitName = splitString(inventory[Slot]['item'],"-")
		local totalName = inventory[Slot]["item"]
		local nameItem = splitName[1]

		if itemType(totalName) == "Throwing" then
			local checkWeapon = vCLIENT.returnWeapon(source)
			if checkWeapon then
			else
				local consultItem = vRP.getInventoryItemAmount(user_id,nameItem)
				if consultItem[1] <= 0 then
					return
				end

				if vCLIENT.putWeaponHands(source,nameItem,1) then
					TriggerClientEvent("inventory:throwableWeapons",source,nameItem)
				end
			end
		return end

		if itemType(totalName) == "Armamento" then
			if vCLIENT.returnWeapon(source) then
				local Check,Ammo,Hash = vCLIENT.storeWeaponHands(source)

				if Check then
					local wHash = itemAmmo(Hash)

					if wHash then
						if Ammo > 0 then
							if not Ammos[user_id] then
								Ammos[user_id] = {}
							end

							Ammos[user_id][wHash] = Ammo
						else
							if Ammos[user_id] and Ammos[user_id][wHash] then
								Ammos[user_id][wHash] = nil
							end
						end
					end
				end
			else
				Ammo = 0

				local wHash = itemAmmo(nameItem)

				if wHash then
					if not Ammos[user_id] then
						Ammos[user_id] = {}
					end

					if not Ammos[user_id][wHash] then
						Ammos[user_id][wHash] = 0
					else
						Ammo = Ammos[user_id][wHash]
					end
				end

				if not Attachs[user_id] then
					Attachs[user_id] = {}
				end
	
				if not Attachs[user_id][nameItem] then
					Attachs[user_id][nameItem] = {}
				end

				vCLIENT.putWeaponHands(source,nameItem,Ammo,Attachs[user_id][nameItem])
			end
			
			return 
		end

		if itemType(totalName) == "Munição" then
			local Weapon,Hash,Ammo = vCLIENT.rechargeCheck(source,nameItem)

			if Weapon then
				if Hash == "WEAPON_PETROLCAN" then
					if (Ammo + Amount) > 4500 then
						Amount = 4500 - Ammo
					end
				else
					if (Ammo + Amount) > 250 then
						Amount = 250 - Ammo
					end
				end

				if nameItem ~= itemAmmo(Hash) or Amount <= 0 then
					return
				end

				if vRP.tryGetInventoryItem(user_id,nameItem,Amount,false,Slot) then
					if not Ammos[user_id] then
						Ammos[user_id] = {}
					end

					Ammos[user_id][nameItem] = Ammo + Amount

					TriggerClientEvent("inventory:Update",source,"Backpack")

					vCLIENT.rechargeWeapon(source,Hash,Amount)
				end
			end

			return
		end

		if nameItem == "attachsFlashlight" or nameItem == "attachsCrosshair" or nameItem == "attachsSilencer" or nameItem == "attachsGrip" then
			local returnWeapon = vCLIENT.returnWeapon(source)
			if returnWeapon then
				if Attachs[user_id][returnWeapon] == nil then
					Attachs[user_id][returnWeapon] = {}
				end

				if Attachs[user_id][returnWeapon][nameItem] == nil then
					local checkAttachs = vCLIENT.checkAttachs(source,nameItem,returnWeapon)
					if checkAttachs then
						if vRP.tryGetInventoryItem(user_id,totalName,1,false,Slot) then
							-- TriggerClientEvent("itensNotify",source,{ "equipou",itemIndex(totalName),1,itemName(totalName) })
							TriggerClientEvent("inventory:Update",source,"updateMochila")
							vCLIENT.putAttachs(source,nameItem,returnWeapon)
							Attachs[user_id][returnWeapon][nameItem] = true
							vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
						end
					end
				else
					TriggerClientEvent("Notify", source, "negado", "O armamento já possui o componente equipado.", 15000, "normal", "Admin")
				end
			end
			
		return end

		if itemType(totalName) == "Usável" or itemType(totalName) == "Animal" then

			if nameItem == "ENERGETICO" then
				cancelPressed[source] = false
				vRPC.CarregarObjeto(source,"amb@world_human_drinking@beer@male@idle_a","idle_a","prop_energy_drink",49,28422)

				TriggerClientEvent("inventory:Close",source)
				TriggerClientEvent("inventory:Buttons",source,true)
				TriggerClientEvent("NotifyKeyboardInfo", source, {
					status = true,
					key = "E",
					text = "Cancelar"
				})

				CreateThread(function()
					while not cancelPressed[source] do
						Wait(100) -- aguarda 0,1 segundo para atualizar o valor de cancelPressed[source]
					end

					vRPC.DeletarObjeto(source)
					TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
					return -- encerra a thread
				end)

				-- Wait(2500)

				Citizen.SetTimeout(2500, function()
					TriggerClientEvent("inventory:Buttons", source, false)
					if not cancelPressed[source] then -- se a ação não foi cancelada
						if vRP.tryGetInventoryItem(user_id,totalName,1,true,Slot) then
							vCLIENT.activeEnergetic(source)
							vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
							vRPC.DeletarObjeto(source)
							TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
						end
					end
				end)
				
			end

			if nameItem == "ARMOUR_STANDARD" then
				if vCLIENT.getArmour(source) < 100 then
					cancelPressed[source] = false

					TriggerClientEvent("PlayAnim", source, "clothingtie", "try_tie_negative_a")
					TriggerClientEvent("inventory:Close",source)
					TriggerClientEvent("inventory:Buttons",source,true)
					TriggerClientEvent("NotifyKeyboardInfo", source, {
						status = true,
						key = "E",
						text = "Cancelar"
					})
	
					CreateThread(function()
						while not cancelPressed[source] do
							Wait(100) -- aguarda 0,1 segundo para atualizar o valor de cancelPressed[source]
						end

						TriggerClientEvent("StopAnim", source, "clothingtie", "try_tie_negative_a")
						TriggerClientEvent("inventory:Buttons", source, false)
						TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
						return -- encerra a thread
					end)
				
					Citizen.SetTimeout(6000, function()
						if not cancelPressed[source] then -- se a ação não foi cancelada
							if vRP.tryGetInventoryItem(user_id,totalName,1,true,Slot) then
								vCLIENT.setColete(source,100)
								TriggerClientEvent("inventory:Buttons",source,false)
								TriggerClientEvent("StopAnim", source, "clothingtie", "try_tie_negative_a")
								TriggerClientEvent("inventory:Buttons",source,false)
								TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
	
								vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
							end
						end
					end)
				end
			end

			if nameItem == "AIRDROP" then
				local itens = exports["duth"]:AirDrop().Players[user_id]
				if not AirDrop[user_id] then
					if itens then
						if vRP.tryGetInventoryItem(user_id,totalName,1,true,Slot) then
								AirDrop[user_id] = true
								TriggerClientEvent("inventory:Close",source)
								TriggerClientEvent("inventory:UseAirDrop",source,false)
								vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
							end
						else
						TriggerClientEvent("Notify", source, "negado", "Você ainda não montou seu <b>AirDrop</b> no lobby principal.")
					end
				else
					TriggerClientEvent("Notify", source, "negado", "Você já chamou um AirDrop.")
				end
			end

			if nameItem == "HEALTH_STANDARD" then
				if vCLIENT.getHealth(source) < 400 then
					cancelPressed[source] = false

					TriggerClientEvent("PlayAnim", source, "amb@world_human_clipboard@male@idle_a", "idle_c")
					TriggerClientEvent("inventory:Close",source)
					TriggerClientEvent("inventory:Buttons",source,true)
					TriggerClientEvent("NotifyKeyboardInfo", source, {
						status = true,
						key = "E",
						text = "Cancelar"
					})
	
					CreateThread(function()
						while not cancelPressed[source] do
							Wait(100) -- aguarda 0,1 segundo para atualizar o valor de cancelPressed[source]
						end
						
						TriggerClientEvent("StopAnim", source, "amb@world_human_clipboard@male@idle_a", "idle_c")
						TriggerClientEvent("inventory:Buttons", source, false)
						TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
						return -- encerra a thread
					end)
				
					Citizen.SetTimeout(5000, function()
						if not cancelPressed[source] then -- se a ação não foi cancelada
							if vRP.tryGetInventoryItem(user_id,totalName,1,true,Slot) then
								vRPC.UpgradeHealth(source,100)
								TriggerClientEvent("inventory:Buttons",source,false)
								TriggerClientEvent("StopAnim", source, "amb@world_human_clipboard@male@idle_a", "idle_c")
								TriggerClientEvent("inventory:Buttons",source,false)
								TriggerClientEvent("NotifyKeyboardInfo", source, { status = false })
								vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
							end
						end
					end)

				end
			return end


		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INVENTORY:CANCEL
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("inventory:Cancel")
AddEventHandler("inventory:Cancel",function()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if Active[user_id] ~= nil then
			Active[user_id] = nil
			vGARAGE.updateHotwired(source,false)
			TriggerClientEvent("Progress",source,1000)
			TriggerClientEvent("inventory:Buttons",source,false)

			if verifyObjects[user_id] then
				local model = verifyObjects[user_id][1]
				local hash = verifyObjects[user_id][2]

				Trashs[model][hash] = nil
				verifyObjects[user_id] = nil
			end

			if verifyAnimals[user_id] then
				local model = verifyAnimals[user_id][1]
				local netObjects = verifyAnimals[user_id][2]

				Animals[model][netObjects] = Animals[model][netObjects] - 1
				verifyAnimals[user_id] = nil
			end

			if Loots[user_id] then
				Boxes[Loots[user_id]][user_id] = nil
			end

			if dismantleProgress[user_id] then
				local vehName = dismantleProgress[user_id]
				dismantleList[vehName] = true
				dismantleProgress[user_id] = nil
			end
		end

		if openIdentity[user_id] then
			TriggerClientEvent("vRP:Identity",source)
			openIdentity[user_id] = nil
		end

		if Carry[user_id] then
			TriggerClientEvent("player:ropeCarry",Carry[user_id],source)
			TriggerClientEvent("player:Commands",Carry[user_id],false)
			vRPC.removeObjects(Carry[user_id])
			Carry[user_id] = nil
		end

		if Scanners[user_id] then
			TriggerClientEvent("inventory:updateScanner",source,false)
			TriggerClientEvent("inventory:Buttons",source,false)
			Scanners[user_id] = nil
		end

		vRPC.removeObjects(source)
	end
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- PREVENTWEAPON
-- -----------------------------------------------------------------------------------------------------------------------------------------
function cRP.preventWeapon(Item,Ammo)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local wHash = itemAmmo(Item)

		if wHash ~= nil then
			if Ammos[user_id][wHash] then
				if Ammo > 0 then
					Ammos[user_id][wHash] = Ammo
				else
					Ammos[user_id][wHash] = nil
				end
			end
		end
	end
end

function cRP.verifyWeapon(Item,Ammo)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local consultItem = vRP.getInventoryItemAmount(user_id,Item)
		if consultItem[1] <= 0 then
			local wHash = itemAmmo(Item)

			if wHash ~= nil then
				if Ammos[user_id] and Ammos[user_id][wHash] then
					Ammos[user_id][wHash] = parseInt(Ammo)

					if Attachs[user_id][Item] ~= nil then
						for nameAttachs,_ in pairs(Attachs[user_id][Item]) do
							vRP.generateItem(user_id,nameAttachs,1)
						end

						Attachs[user_id][Item] = nil
					end

					if Ammos[user_id][wHash] > 0 then
						vRP.generateItem(user_id,wHash,Ammos[user_id][wHash])
						Ammos[user_id][wHash] = nil
					end

					TriggerClientEvent("inventory:Update",source,"updateMochila")
				end
			end

			return false
		end
	end

	return true
end

function cRP.existWeapon(Item)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local consultItem = vRP.getInventoryItemAmount(user_id,Item)
		if consultItem[1] <= 0 then
			local wHash = itemAmmo(Item)

			if wHash ~= nil then
				if Ammos[user_id][wHash] then
					if Attachs[user_id][Item] ~= nil then
						for nameAttachs,_ in pairs(Attachs[user_id][Item]) do
							vRP.generateItem(user_id,nameAttachs,1)
						end

						Attachs[user_id][Item] = nil
					end

					if Ammos[user_id][wHash] > 0 then
						vRP.generateItem(user_id,wHash,Ammos[user_id][wHash])
						Ammos[user_id][wHash] = nil
					end

					TriggerClientEvent("inventory:Update",source,"updateMochila")
				end
			end
		end
	end
end

RegisterServerEvent("inventory:clearWeapons")
AddEventHandler("inventory:clearWeapons",function(user_id)
	if Ammos[user_id] then
		Ammos[user_id] = {}
		Attachs[user_id] = {}
	end
end)

RegisterNetEvent("inventory:clearAmmosAttachs")
AddEventHandler("inventory:clearAmmosAttachs", function(sourceRecebido) 
	local user_id = vRP.getUserId(sourceRecebido)
	if user_id then
		Ammos[user_id] = {}
		Attachs[user_id] = {}
	end
end)

RegisterNetEvent("inventory:GenerateItem")
AddEventHandler("inventory:GenerateItem", function(sourceRecebido, itemName) 
	local user_id = vRP.getUserId(sourceRecebido)
	if user_id then
		vRP.generateItem(user_id,itemName,1,true)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CLEANWEAPONS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("CleanWeapons",function(Passport,Clean)
	local source = vRP.getUserSource(Passport)
	if source then
		local Ped = GetPlayerPed(source)
		local Weapon = GetSelectedPedWeapon(Ped)

		RemoveWeaponFromPed(Ped,Weapon)
		RemoveAllPedWeapons(Ped,false)
		SetPedAmmo(Ped,Weapon,0)

		if Clean then
			Attachs[Passport] = {}
			Ammos[Passport] = {}
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopUso
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.StopUso() 
	local source = source
	if not cancelPressed[source] then
		cancelPressed[source] = true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StopInventory
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("inventory:StopInventory")
AddEventHandler("inventory:StopInventory", function(user_id) 
	if not WeaponPrimary[user_id] == nil then
		WeaponPrimary[user_id] = false
	end

	AirDrop[user_id] = false
	
	WeaponPrimary[user_id] = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("deleteObjects")
AddEventHandler("deleteObjects",function(entIndex)
	local source = source
	TriggerClientEvent("player:deleteObject",-1,entIndex)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OpenAirSuplement
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.OpenAirSuplement() 
	local source = source
	local user_id = vRP.getUserId(source)
	local itens = exports["duth"]:AirDrop().Players[user_id]

	if itens then
		for _, item in pairs(itens) do 
			vRP.generateItem(user_id,itemSpawnName(item.spawnName),1,true)

			TriggerClientEvent("inventory:Update", source,"updateMochila")

			exports["duth"]:AirDrop().ClearAirDrop(source)

			vServerBatlleRoyale.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
		end
	end
end