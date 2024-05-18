local PlayerIdCooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- partida 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("partida", function(source, args, rawCmd) 
    TriggerClientEvent("Notify", source, "sucess", "Você está na partida com o id: <b>"..Player(source).state.gameId.."</b>.")
end)

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
