-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")

Drop = {}
Drop.DropItems = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildItems
-----------------------------------------------------------------------------------------------------------------------------------------
function Drop.BuildItems() 
    local drop = vRP.query("vRP/getItensDuthDrop",{ })

    for _, item in pairs(drop) do 
        -- Drop.DropItems[item.id] = item
        table.insert(Drop.DropItems, item)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateThread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    Drop.BuildItems()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REWARDS
-----------------------------------------------------------------------------------------------------------------------------------------
local function givePlayerReward(src,userId,spinResult)
	local source = src
	local loot = Drop.DropItems[spinResult]

    exports["core"]:Inventory().GiveItem(source, userId, { spawnName = loot.drop_spawName, category = loot.drop_category })

	TriggerClientEvent("Notify",src,"inform","Você recebeu seu premio!")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESULT
-----------------------------------------------------------------------------------------------------------------------------------------
local function genSpinResult()

	local sum = 0
	for key, loot in pairs(Drop.DropItems) do
		sum = sum + loot.drop_percent
	end

	local index = math.random() * sum
	local res

	for key, loot in pairs(Drop.DropItems) do
		index = index - loot.drop_percent
		if index <= 0 then
			res = key
			break
		end
	end

	return res
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOOTDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function server.getLootData()
    local source = source
    local playerModel = GetPlayerPed(source)
    local PlayerSex = ""
    
    if GetEntityModel(playerModel) == GetHashKey("mp_m_freemode_01") then
        PlayerSex = "mp_m_freemode_01"
    elseif GetEntityModel(playerModel) == GetHashKey("mp_f_freemode_01") then
        PlayerSex = "mp_f_freemode_01"
    end

	local res = {}
	for k,loot in pairs(Drop.DropItems) do
        if loot.drop_sex == PlayerSex or loot.drop_sex == "double" then
             res[k] = {
                name = loot.drop_name,
                img = loot.drop_imagem,
                badge = loot.drop_badge
            }
        end
	end

	return res
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- USESPIN
-----------------------------------------------------------------------------------------------------------------------------------------
function server.useSpin()
	local src = source
	local userId = vRP.getUserId(src)
	local spinResult = genSpinResult()
    
	SetTimeout(8000, function()
		givePlayerReward(src, userId, spinResult)
		client.closeNui(src)
	end)

	return spinResult
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Drop - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Drop",function()
    return Drop
end)