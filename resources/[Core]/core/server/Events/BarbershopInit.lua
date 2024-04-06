-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
clientAPI = Tunnel.getInterface(GetCurrentResourceName())
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('barbershop:init', function(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local value = vRP.getUData(user_id,'Barbershop')
		if value ~= nil then
			local custom = json.decode(value) or {}
			clientAPI.setCharacter(player,custom)
		end
	end
end)


RegisterCommand("load", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	local value = vRP.getUData(user_id,'Barbershop')
	if value ~= nil then
		local custom = json.decode(value) or {}
		clientAPI.setCharacter(source,custom)
	end
end)
