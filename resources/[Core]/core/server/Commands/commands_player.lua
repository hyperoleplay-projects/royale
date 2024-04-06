local PlayerIdCooldown = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ID
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('id',function(source, args,rawCommand)	
	local nplayer = vRPC.getNearestPlayer(source,2)
	local nuser_id = vRP.getUserId(nplayer)

    if not PlayerIdCooldown[source] or os.time() >= PlayerIdCooldown[source] + 5 then
        PlayerIdCooldown[source] = os.time()

        if not args[1] and nuser_id then 
            local profile = vRP.query("vRP/requestUser",{ id = nuser_id })
    
            local identity = vRP.getIdentity(nuser_id)
            if identity then
                clientAPI.BuildProfileCard(source, {
                    user_id = nuser_id,
                    username = identity.username,
                    avatar = profile[1].avatar,
                    duthCoins = profile[1].duthCoins,
                    duthPoints = profile[1].duthPoints,
                    title = profile[1].CustomTitle or "Sem título",
                    status = false,
                    statusPlayer = true
                })
            end
        else
            local profile = vRP.query("vRP/requestUser",{ id = parseInt(args[1]) })
            local nsource = vRP.getUserSource(parseInt(args[1]))
            local PlayerKills = 0
            local PlayerDeaths = 0
            local PlayerKd = PlayerKills / PlayerDeaths
    
            for key, gamemode in pairs(Config.gamemodesList) do
                local query_res = vRP.query("vRP/getPlayerRanking", { gamemode = key, user_id = parseInt(args[1]) })
                
                if query_res[1] then
                    PlayerKills = PlayerKills + query_res[1].kills
                    PlayerDeaths = PlayerDeaths + query_res[1].deaths
                end
                Wait(1)
            end
    
            if PlayerKills == 0 then
                PlayerKills = 4000 
            end
    
            if PlayerDeaths == 0 then
                PlayerDeaths = 4000
            end
    
            clientAPI.BuildProfileCard(source, {
                user_id = parseInt(args[1]),
                username = profile[1].username,
                avatar = profile[1].avatar,
                duthCoins = profile[1].duthCoins,
                duthPoints = profile[1].duthPoints,
                title = profile[1].CustomTitle or "Sem título",
                status = true,
                statusPlayer = nsource,
                kills = PlayerKills,
                deaths = PlayerDeaths,
                kd = round(PlayerKills / PlayerDeaths,2),
                premium = exports["core"]:Premium().isVipByUserId(parseInt(args[1]),"padrao")
            })
        end
    else
        TriggerClientEvent("Notify",source,"negado", "Aguarde " .. (5 - (os.time() - PlayerIdCooldown[source])) .. " segundos.")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- partida 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("partida", function(source, args, rawCmd) 
    TriggerClientEvent("Notify", source, "sucess", "Você está na partida com o id: <b>"..Player(source).state.gameId.."</b>.")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- dnotify 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("dnotify", function(source, args, rawCmd)
    if not Player(source).state.isNotifyKill then
        Player(source).state.isNotifyKill = true
        TriggerClientEvent("Notify", source, "sucess", "Você ativou as notificações de kills.")
    else
        Player(source).state.isNotifyKill = false
        TriggerClientEvent("Notify", source, "sucess", "Você desativou as notificações de kills.")
    end
end)

function round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end
