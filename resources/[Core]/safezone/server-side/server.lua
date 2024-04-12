local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("safezone",src)
clientAPI = Tunnel.getInterface("safezone")

local SAFEZONE_ROUTES = { -- Isso aqui é a rota de uma safezone
    {
        -- Etapa de rota: { Centro (vector2), Radius (number), Duration (number) }
        { vector2(0, 0), 2000.0, 200 },
        { vector2(0, 0), 1000.0, 100 },
        { vector2(0, 0), 500.0, 50 },
        { vector2(0, 0), 250.0, 20 },
        { vector2(0, 0), 100.0, 10 },
        { vector2(0, 0), 50.0, 10 },
        { vector2(0, 0), 0.0, nil } -- Essa etapa não move mais, ele finaliza o movimento, por isso não tem duração
    },
    {
        -- Etapa de rota: { Centro (vector2), Radius (number), Duration (number) }
        { vector2(0, 0), 2000.0, 200 },
        { vector2(0, 0), 1000.0, 100 },
        { vector2(0, 0), 500.0, 50 },
        { vector2(0, 0), 250.0, 20 },
        { vector2(0, 0), 100.0, 10 },
        { vector2(0, 0), 50.0, 10 },
        { vector2(0, 0), 0.0, nil } -- Essa etapa não move mais, ele finaliza o movimento, por isso não tem duração
    }
}

local threadExists = false
local Games = {}

function BR:Safe(Game) 
    local nextTimeout = 1500

    local gameId = Game.gameId

    if BR.BaseZone[gameId] and not BR.Zone[gameId] and os.time() >= BR.StartTime[gameId] + BR.StartZone[gameId] then
        print('PASSOU AQUI 1')

        BR.ZoneRadius[gameId] = BR.ZoneRadius[gameId] / 2
        BR.Zone[gameId] = BR.BaseZone[gameId] - GenerateCenterPoint(BR.ZoneRadius[gameId])
       
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
    elseif BR.ZoneCount[gameId] < BR.MaxZones[gameId] and BR.ZoneTime[gameId] and BR.ZoneTime[gameId] + BR.ZoneTimer[gameId] <= os.time() then
        print('PASSOU AQUI 4')

        BR.ZoneTime[gameId] = false
        BR.ZoneTimer[gameId] = false
        BR.ZoneRadius[gameId] = BR.ZoneRadius[gameId] / 2
        BR.Zone[gameId] = BR.Zone[gameId] - GenerateCenterPoint(BR.ZoneRadius[gameId])
        BR.IntervalZone[gameId] = 180
        
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

        print('PASSOU AQUI 5')

        BR.ZoneCount[gameId] = BR.ZoneCount[gameId] + 1
    end

    SetTimeout(nextTimeout, function() 
        return BR:Safe(Game) 
    end)
end

RegisterNetEvent("battle-CreateSafe")
AddEventHandler("battle-CreateSafe", function(Game, Center) 
    -- Games[Game.gameId] = {
    --     gameId = Game.gameId
    -- }

    -- Wait(100)

    BR.StartZone[Game.gameId] = 120
    BR.IntervalZone[Game.gameId] = 300
    BR.MaxZones[Game.gameId] = 9
    BR.ZoneCount[Game.gameId] = 0
    BR.StartTime[Game.gameId] = os.time()
    BR.ZoneRadius[Game.gameId] = 2400.0
    BR.BaseZone[Game.gameId] = Center
    BR.Zone[Game.gameId] = false
    BR.ZoneTime[Game.gameId] = false
    BR.ZoneTimer[Game.gameId] = false
    BR.Players[Game.gameId] = Game.players

    BR:Safe(Game)

    -- table.insert(Games, {
    --     gameId = Game.gameId
    -- })
    
    -- if not threadExists then
    --     threadExists = true
    --     print("Create thread safe")
    --     Citizen.CreateThread(function()
    --         while true do
    --             Safe()
    --             Wait(1000)
    --         end
    --     end)
    -- end
   
    for _, playerObject in pairs(Game.players) do 
        Player(playerObject.source).state.inGame = true
        Player(playerObject.source).state.gameId = Game.gameId

        TriggerClientEvent("battle-IniciarSafe", playerObject.source)
    end
end)

RegisterNetEvent("battle-FinishSafe")
AddEventHandler("battle-FinishSafe", function(GameRecebido)
    print("Finish safe", GameRecebido)
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