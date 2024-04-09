-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
ClientMenuNUI = Tunnel.getInterface("MenuNUI")
-----------------------------------------------------------------------------------------------------------------------------------------
-- SPAWNCHARACTER
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('barbershop:init', function(user_id)
	local player = vRP.getUserSource(user_id)
	if player then
		local value = vRP.getUData(user_id,'Barbershop')
		if value ~= nil then
			local custom = json.decode(value) or {}
			ClientMenuNUI.setCharacter(player,custom)
		end
	end
end)
