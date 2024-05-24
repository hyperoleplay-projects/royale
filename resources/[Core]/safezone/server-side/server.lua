local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("safezone",src)
clientAPI = Tunnel.getInterface("safezone")

SAFEZONE_ROUTES = {
    {
        -- Etapa de rota: { Centro (vector3), Radius (number), Duration (number) }
        { vector3(-94.68, 881.03, 30.38), 2000.0, 200 },
        { vector3(-94.68, 881.03, 30.38), 1000.0, 100 },
        { vector3(-94.68, 881.03, 30.38), 500.0, 20 },
        { vector3(-94.68, 881.03, 30.38), 250.0, 20 },
        { vector3(-94.68, 881.03, 30.38), 100.0, 10 },
        { vector3(-94.68, 881.03, 30.38), 50.0, 10 },
        { vector3(-94.68, 881.03, 30.38), 0.0, 0 } -- Essa etapa não move mais, ele finaliza o movimento, por isso não tem duração
    }
}

function BR:Safe(Game) 
    local nextTimeout = 1500
    local gameId = Game.gameId

    if BR.BaseZone[gameId] and not BR.Zone[gameId] and os.time() >= BR.StartTime[gameId] + BR.StartZone[gameId] then
        BR.ZoneRadius[gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[gameId]][BR.CurrentStage[gameId]][2]
        BR.Zone[gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[gameId]][BR.CurrentStage[gameId]][1]
       
        for _, playerObject in pairs(BR.Players[gameId]) do 
            if playerObject.source and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                if not Player(playerObject.source).state.inSpec then
                    TriggerClientEvent("NotifyAnnouncement", playerObject.source, { 
                        status = true, 
                        timer = true, 
                        text = "Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos." 
                    })
                end

                TriggerClientEvent("SafeZone:StartEvent", playerObject.source, 5, { 
                    Zone = VectorToTable(BR.Zone[gameId]), 
                    ZoneRadius = BR.ZoneRadius[gameId] 
                })
            end
        end
    elseif BR.Zone[gameId] and not BR.ZoneTime[gameId] then
        BR.ZoneTime[gameId] = os.time()
        BR.ZoneTimer[gameId] = BR.IntervalZone[gameId]
        
        local SafeTeste = false
       
        Citizen.SetTimeout(60000, function()
            for _, playerObject in pairs(BR.Players[gameId]) do 
                if playerObject.source and not Player(playerObject.source).state.finishGameUI and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                    if not SafeTeste then
                        SafeTeste = true

                        BR.ZoneTimer[gameId] = BR.IntervalZone[gameId]
                        BR.ZoneTime[gameId] = os.time()
                    end

                    if not Player(playerObject.source).state.inSpec then
                        TriggerClientEvent("NotifyAnnouncement", playerObject.source, { 
                            status = true, 
                            timer = true, 
                            text = "<b>A zona segura</b> está diminuindo" 
                        })
                    end

                    TriggerClientEvent("SafeZone:StartEvent", playerObject.source, 6, BR.ZoneTimer[gameId])
                end
            end
        end)
    elseif BR.ZoneCount[gameId] < BR.MaxZones[gameId] and BR.ZoneTimer[gameId] and BR.ZoneTimer[gameId] > 0 and BR.ZoneTime[gameId] and BR.ZoneTime[gameId] + BR.ZoneTimer[gameId] <= os.time() then
        BR.ZoneTime[gameId] = false
        BR.ZoneTimer[gameId] = false

        BR.CurrentStage[gameId] = BR.CurrentStage[gameId] + 1
        BR.ZoneRadius[gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[gameId]][BR.CurrentStage[gameId]][2]
        BR.Zone[gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[gameId]][BR.CurrentStage[gameId]][1]
        BR.IntervalZone[gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[gameId]][BR.CurrentStage[gameId]][3] or 0
        
        for _, playerObject in pairs(BR.Players[gameId]) do 
            if playerObject.source and not Player(playerObject.source).state.finishGameUI and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                if not Player(playerObject.source).state.inSpec then
                    TriggerClientEvent("NotifyAnnouncement", playerObject.source, { 
                        status = true, 
                        timer = true, 
                        text = "Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos." 
                    })
                end

                TriggerClientEvent("SafeZone:StartEvent", playerObject.source, 5, { 
                    Zone = BR.Zone[gameId], 
                    ZoneRadius = BR.ZoneRadius[gameId] 
                })
            end
        end

        BR.ZoneCount[gameId] = BR.ZoneCount[gameId] + 1
    end

    SetTimeout(nextTimeout, function() 
        return BR:Safe(Game) 
    end)
end

RegisterNetEvent("battle-CreateSafe")
AddEventHandler("battle-CreateSafe", function(Game, Center) 
    BR.StartZone[Game.gameId] = 120
    BR.ZoneCount[Game.gameId] = 0
    BR.StartTime[Game.gameId] = os.time()
    BR.Zone[Game.gameId] = false
    BR.ZoneTime[Game.gameId] = false
    BR.ZoneTimer[Game.gameId] = false
    BR.Players[Game.gameId] = Game.players
    
    BR.CurrentStage[Game.gameId] = 1
    BR.ZoneConfigIndex[Game.gameId] = math.random(#SAFEZONE_ROUTES)
    BR.MaxZones[Game.gameId] = #SAFEZONE_ROUTES[BR.ZoneConfigIndex[Game.gameId]]
    BR.BaseZone[Game.gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[Game.gameId]][1][1]
    BR.ZoneRadius[Game.gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[Game.gameId]][1][2]
    BR.IntervalZone[Game.gameId] = SAFEZONE_ROUTES[BR.ZoneConfigIndex[Game.gameId]][1][3]

    BR:Safe(Game)

    for _, playerObject in pairs(Game.players) do 
        Player(playerObject.source).state.inGame = true
        Player(playerObject.source).state.gameId = Game.gameId

        TriggerClientEvent("battle-IniciarSafe", playerObject.source)
    end
end)

RegisterNetEvent("battle-FinishSafe")
AddEventHandler("battle-FinishSafe", function(GameRecebido)
end)

RegisterNetEvent("battle-UpdatePlayersSafe")
AddEventHandler("battle-UpdatePlayersSafe", function(Game) 
    BR.Players[Game.gameId] = Game.players
end)

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
       
        for k,v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"'..k..'"' 
            end

            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end

        return s .. '} '
    else
        return tostring(o)
    end
end