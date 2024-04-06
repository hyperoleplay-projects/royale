-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
local userlogin = {}

src = {}
Tunnel.bindInterface("core",src)
clientAPI = Tunnel.getInterface("core")

local UserBucket = {}
local RoutingBuckets = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetFreeRoutingBucket
-----------------------------------------------------------------------------------------------------------------------------------------
GetFreeRoutingBucket = function()
	for i=1, 250 do
		if not RoutingBuckets[i] then
			RoutingBuckets[i] = true

			return i
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetRoutingBucketAsFree
-----------------------------------------------------------------------------------------------------------------------------------------
SetRoutingBucketAsFree = function(routingBucket)
	if RoutingBuckets[routingBucket] then
		RoutingBuckets[routingBucket] = nil
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GENERATESTRINGNUMBER
-----------------------------------------------------------------------------------------------------------------------------------------
function generateStringNumber(format)
	local abyte = string.byte("A")
	local zbyte = string.byte("0")
	local number = ""

	for i = 1,#format do
		local char = string.sub(format,i,i)
    	if char == "D" then
    		number = number..string.char(zbyte + math.random(0,9))
		elseif char == "L" then
			number = number..string.char(abyte + math.random(0,25))
		else
			number = number..char
		end
	end

	return number
end
 

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		local data = vRP.getUData(user_id,"vRP:spawnController")
		local spawnStatus = json.decode(data) or 0
		-- SetTimeout(5000, function() -- tunnel/proxy delay
			processSpawnController(source, spawnStatus, user_id)
		-- end)
	end
end)

function processSpawnController(source,statusSent,user_id)
	local source = source
	if statusSent == 2 then
		if not userlogin[user_id] then
			userlogin[user_id] = true
			TriggerClientEvent("character:normalSpawn",source,firstspawn)
			-- TriggerEvent("barbershop:init",user_id)
		else
			TriggerClientEvent("character:normalSpawn",source,firstspawn)
			-- TriggerEvent("barbershop:init",user_id)
			end
	elseif statusSent == 1 or statusSent == 0 then
		userlogin[user_id] = true
		TriggerClientEvent("character:characterCreate", source)

		-- SetPlayerRoutingBucket(source, parseInt(user_id+1))
	end
end

RegisterServerEvent("Creation:CreateCharacter")
AddEventHandler("Creation:CreateCharacter", function(currentCharacterMode, characterNome, tipo, skinData)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		local player = vRP.getUserSource(user_id)
		vRP.setUData(user_id,"Clothings", json.encode(skinData))
		vRP.setUData(user_id,"Barbershop", json.encode(currentCharacterMode))
		vRP.setUData(user_id,"vRP:spawnController", json.encode(2))
		
		if tipo == "mp_m_freemode_01" then
			vRP.execute('vRP/giveItem', {
				user_id = user_id,
				inventory_itemName = "REMOVER_JAQUETA",
				inventory_itemStatus = "false",
				inventory_itemType = "clothe",
				inventory_generate = "shop",
			})
	
			vRP.execute('vRP/giveItem', {
				user_id = user_id,
				inventory_itemName = "REMOVER_CALCA",
				inventory_itemStatus = "false",
				inventory_itemType = "clothe",
				inventory_generate = "shop",
			})
		else
			vRP.execute('vRP/giveItem', {
				user_id = user_id,
				inventory_itemName = "REMOVER_JAQUETA_F",
				inventory_itemStatus = "false",
				inventory_itemType = "clothe",
				inventory_generate = "shop",
			})
	
			vRP.execute('vRP/giveItem', {
				user_id = user_id,
				inventory_itemName = "REMOVER_CALCA_F",
				inventory_itemStatus = "false",
				inventory_itemType = "clothe",
				inventory_generate = "shop",
			})
		end

		vRP.execute("vRP/updateIdentity",{ id = user_id, username = characterNome })
        local discordId = ""
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            if string.match(id, "discord:") then
                discordId = string.gsub(id, "discord:", "")
            end
        end
		
        SetTimeout(1000, function() -- tunnel/proxy delay
			local Clothes = vRP.getUData(user_id,"Clothings")
			vRPclient.setClothing(source, Clothes) 
			vRP.updateIdentity(user_id)
        	doSpawnPlayer(source,user_id,true)
			exports.oxmysql:query("INSERT INTO user_listset_codiguins (id,discord) VALUES (?,?)",{ user_id, discordId })
		end)

	end
end)

function doSpawnPlayer(source,user_id,firstspawn)
	TriggerClientEvent("character:normalSpawn",source,firstspawn)
	TriggerEvent("barbershop:init",user_id)
	SetPlayerRoutingBucket(source, parseInt(user_id+2))
end
