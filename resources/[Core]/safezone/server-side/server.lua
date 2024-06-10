local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

src = {}
Tunnel.bindInterface('safezone', src)
clientAPI = Tunnel.getInterface('safezone')

INITIAL_SAFEZONE = { COORDINATES = vector3(0, 0, 0), RADIUS = 5000.0 }

SAFEZONE_ROUTES = {
    {
        -- Etapa de rota: { Centro (vector3), Radius (number), Duration (number) }
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 2000.0, DURATION = 360 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 1000.0, DURATION = 120 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 500.0, DURATION = 70 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 250.0, DURATION = 45 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 100.0, DURATION = 30 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 50.0, DURATION = 20 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 1.0, DURATION = 15 }, 
    }
}

function BR:Safe(Game) 
    local gameId = Game.gameId

    if not BR.Zone[gameId] and os.time() >= BR.StartTime[gameId] + BR.StartZone[gameId] then
        BR.CurrentStage[gameId] = BR.CurrentStage[gameId] + 1

        local newSafezone = BR.SelectedRoute[gameId][BR.CurrentStage[gameId]]

        BR.ZoneRadius[gameId] = newSafezone.RADIUS
        BR.Zone[gameId] = newSafezone.COORDINATES
        BR.IntervalZone[gameId] = newSafezone.DURATION

        for _, playerObject in pairs(BR.Players[gameId]) do 
            if playerObject.source and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                if not Player(playerObject.source).state.inSpec then
                    TriggerClientEvent('NotifyAnnouncement', playerObject.source, { 
                        status = true, 
                        timer = true, 
                        text = 'Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos.' 
                    })
                end

                TriggerClientEvent('SafeZone:StartEvent', playerObject.source, 5, { 
                    Zone = VectorToTable(BR.Zone[gameId]), 
                    ZoneRadius = BR.ZoneRadius[gameId] 
                })
            end
        end
    elseif BR.Zone[gameId] and not BR.ZoneTime[gameId] and not BR.IsWaiting[gameId] then
        BR.IsWaiting[gameId] = true

        Citizen.SetTimeout(60000, function()
            BR.ZoneTimer[gameId] = BR.IntervalZone[gameId]
            BR.ZoneTime[gameId] = os.time()
            BR.IsWaiting[gameId] = false

            for _, playerObject in pairs(BR.Players[gameId]) do 
                if playerObject.source and not Player(playerObject.source).state.finishGameUI and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                    if not Player(playerObject.source).state.inSpec then
                        TriggerClientEvent('NotifyAnnouncement', playerObject.source, { 
                            status = true, 
                            timer = true, 
                            text = '<b>A zona segura</b> está diminuindo' 
                        })
                    end

                    TriggerClientEvent('SafeZone:StartEvent', playerObject.source, 6, BR.ZoneTimer[gameId])
                end
            end
        end)
    elseif BR.CurrentStage[gameId] < BR.MaxZones[gameId] and BR.ZoneTime[gameId] and BR.ZoneTime[gameId] + BR.ZoneTimer[gameId] <= os.time() then
        BR.CurrentStage[gameId] = BR.CurrentStage[gameId] + 1

        BR.ZoneTime[gameId] = false
        BR.ZoneTimer[gameId] = false
        
        local newSafezone = BR.SelectedRoute[gameId][BR.CurrentStage[gameId]]

        BR.ZoneRadius[gameId] = newSafezone.RADIUS
        BR.Zone[gameId] = newSafezone.COORDINATES
        BR.IntervalZone[gameId] = newSafezone.DURATION

        for _, playerObject in pairs(BR.Players[gameId]) do 
            if playerObject.source and not Player(playerObject.source).state.finishGameUI and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                if not Player(playerObject.source).state.inSpec then
                    TriggerClientEvent('NotifyAnnouncement', playerObject.source, { 
                        status = true, 
                        timer = true, 
                        text = 'Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos.' 
                    })
                end

                TriggerClientEvent('SafeZone:StartEvent', playerObject.source, 5, { 
                    Zone = BR.Zone[gameId], 
                    ZoneRadius = BR.ZoneRadius[gameId] 
                })
            end
        end
    end

    SetTimeout(1500, function() 
        return BR:Safe(Game) 
    end)
end

RegisterNetEvent('battle-CreateSafe')
AddEventHandler('battle-CreateSafe', function(Game, Center) 
    BR.StartZone[Game.gameId] = 120
    BR.StartTime[Game.gameId] = os.time()
    BR.Zone[Game.gameId] = false
    BR.ZoneTime[Game.gameId] = false
    BR.ZoneTimer[Game.gameId] = false
    BR.IsWaiting[Game.gameId] = false
    BR.Players[Game.gameId] = Game.players
    
    local routeIndex = math.random(#SAFEZONE_ROUTES)

    BR.CurrentStage[Game.gameId] = 0
    BR.SelectedRoute[Game.gameId] = SAFEZONE_ROUTES[routeIndex]
    BR.MaxZones[Game.gameId] = #BR.SelectedRoute[Game.gameId]

    for _, playerObject in pairs(Game.players) do 
        Player(playerObject.source).state.inGame = true
        Player(playerObject.source).state.gameId = Game.gameId

        TriggerClientEvent("SafeZone:StartEvent", playerObject.source, 3, {
            safeZone = VectorToTable(vector3(INITIAL_SAFEZONE.COORDINATES.x, INITIAL_SAFEZONE.COORDINATES.y, 50.0)),
            radius = INITIAL_SAFEZONE.RADIUS
        })
    end

    Citizen.Wait(2000)

    for _, playerObject in pairs(Game.players) do 
        TriggerClientEvent('battle-IniciarSafe', playerObject.source)
    end

    BR:Safe(Game)
end)

RegisterNetEvent('battle-FinishSafe')
AddEventHandler('battle-FinishSafe', function(GameRecebido)
end)

RegisterNetEvent('battle-UpdatePlayersSafe')
AddEventHandler('battle-UpdatePlayersSafe', function(Game) 
    BR.Players[Game.gameId] = Game.players
end)