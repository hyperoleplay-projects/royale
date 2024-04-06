AddEventHandler('vRP:playerSpawn',function(user_id,source,first_spawn)
	local src = source
	local user_id = vRP.getUserId(src)
	local data = vRP.getUserDataTable(user_id)
	local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
    local TatuagensData = {}

	vRPclient._setFriendlyFire(src,true)
	for k, v in pairs(userInventory) do
		if v.inventory_itemType == "tatuagem" then
            local item = exports["core"]:Config().Tatuagens[v.inventory_itemName]
            if item then
                TatuagensData[item.tatto_spawnName] = {
                    tatto_name = item.tatto_name,
                    tatto_type = item.tatto_type,
                    tatto_category = item.tatto_category,
                    tatto_model = item.tatto_model,
                    tatto_part = item.tatto_part,
                    tatto_image = item.tatto_image,
                    tatto_status = v.inventory_itemStatus,
                    tatto_inventoryId = v.inventory_id,
                    tatto_spawnName = item.tatto_spawnName
                }
            end
		end
	end

	vRPclient.setHealth(src, 400)
	if data['customization'] then
		vRPclient.setCustomization(src,data['customization']) 
		Wait(500)

		vRPclient.SetTattos(src, TatuagensData) 
		vRPclient.setClothing(src, vRP.getUData(user_id,"Clothings")) 
		TriggerEvent("barbershop:init",user_id)
		TriggerClientEvent("updateClothes", src, vRP.getUData(user_id,"Clothings"), false)
	end

	vRPclient._playerStateReady(source,true)
end)

function tvRP.updatePos(x,y,z)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		local tmp = vRP.getUserTmpTable(user_id)
		if data and (not tmp or not tmp.home_stype) then
			data.position = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
		end
	end
end

function tvRP.updateCustomization(customization)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data['customization'] = customization
		end
	end
end

function tvRP.updateHealth(health)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data['health'] = health
		end
	end
end

