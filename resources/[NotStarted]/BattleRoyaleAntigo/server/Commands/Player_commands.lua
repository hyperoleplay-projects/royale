-----------------------------------------------------------------------------------------------------------------------------------------
-- partida - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("partida", function(source, args, rawCmd) 
    TriggerClientEvent("Notify", source, "sucess", "Você está na partida com o id: <b>"..Player(source).state.gameId.."</b>.")
end)