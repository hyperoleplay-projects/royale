local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP')

src = {}
Tunnel.bindInterface('safezone', src)
clientAPI = Tunnel.getInterface('safezone')

SAFEZONE_ROUTES = {
    {
        -- Etapa de rota: { Centro (vector3), Radius (number), Duration (number) }
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 2000.0, DURATION = 200 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 1000.0, DURATION = 100 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 500.0, DURATION = 20 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 250.0, DURATION = 20 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 100.0, DURATION = 10 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 50.0, DURATION = 10 }, 
        { COORDINATES = vector3(-94.68, 881.03, 30.38), RADIUS = 0.0, DURATION = 0 } -- Essa etapa não move mais, ele finaliza o movimento, por isso não tem duração
    }
}

function BR:Safe(Game) 
    local gameId = Game.gameId

    if not BR.Zone[gameId] and os.time() >= BR.StartTime[gameId] + BR.StartZone[gameId] then
        print('PASSOU AQUI 1')

        BR.CurrentStage[gameId] = BR.CurrentStage[gameId] + 1

        local newSafezone = BR.SelectedRoute[BR.CurrentStage[gameId]]

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
    elseif BR.Zone[gameId] and not BR.ZoneTime[gameId] then
        print('PASSOU AQUI 2')

        BR.ZoneTime[gameId] = os.time()
        BR.ZoneTimer[gameId] = BR.IntervalZone[gameId]
        
        local SafeTeste = false
       
        Citizen.SetTimeout(60000, function()
            print('PASSOU AQUI 3')

            for _, playerObject in pairs(BR.Players[gameId]) do 
                if playerObject.source and not Player(playerObject.source).state.finishGameUI and (BR.Players[gameId][playerObject.user_id] ~= nil) then
                    if not SafeTeste then
                        SafeTeste = true

                        BR.ZoneTimer[gameId] = BR.IntervalZone[gameId]
                        BR.ZoneTime[gameId] = os.time()
                    end

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
        print('PASSOU AQUI 4')

        BR.CurrentStage[gameId] = BR.CurrentStage[gameId] + 1

        BR.ZoneTime[gameId] = false
        BR.ZoneTimer[gameId] = false
        
        local newSafezone = BR.SelectedRoute[BR.CurrentStage[gameId]]

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

        print('PASSOU AQUI 5')

        -- BR.ZoneCount[gameId] = BR.ZoneCount[gameId] + 1
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
    BR.Players[Game.gameId] = Game.players
    
    -- BR.ZoneCount[Game.gameId] = 0
    -- BR.MaxZones[Game.gameId] = 9
    -- BR.IntervalZone[Game.gameId] = 300
    -- BR.ZoneRadius[Game.gameId] = 2400.0
    -- BR.BaseZone[Game.gameId] = Center

    local routeIndex = math.random(#SAFEZONE_ROUTES)

    BR.CurrentStage[Game.gameId] = 0
    BR.SelectedRoute = SAFEZONE_ROUTES[routeIndex]
    BR.MaxZones[Game.gameId] = #BR.SelectedRoute

    BR:Safe(Game)

    for _, playerObject in pairs(Game.players) do 
        Player(playerObject.source).state.inGame = true
        Player(playerObject.source).state.gameId = Game.gameId

        TriggerClientEvent('battle-IniciarSafe', playerObject.source)
    end
end)

RegisterNetEvent('battle-FinishSafe')
AddEventHandler('battle-FinishSafe', function(GameRecebido)
    print('Finish safe', GameRecebido)
end)

RegisterNetEvent('battle-UpdatePlayersSafe')
AddEventHandler('battle-UpdatePlayersSafe', function(Game) 
    BR.Players[Game.gameId] = Game.players
end)