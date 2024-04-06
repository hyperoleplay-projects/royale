local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface("safezone",src)
clientAPI = Tunnel.getInterface("safezone")
local threadExists = false
local Games = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Safe
-----------------------------------------------------------------------------------------------------------------------------------------
-- function Safe() 
--     for _, Game in pairs(Games) do 
--         if BR.BaseZone[Game.gameId] and not BR.Zone[Game.gameId] and os.time() >= BR.StartTime[Game.gameId] + BR.StartZone[Game.gameId] then
--             BR.ZoneRadius[Game.gameId] = BR.ZoneRadius[Game.gameId] / 2
--             BR.Zone[Game.gameId] = BR.BaseZone[Game.gameId] - GenerateCenterPoint(BR.ZoneRadius[Game.gameId])

--             local teste = BR.Zone[Game.gameId]
--             local teste2 = BR.ZoneRadius[Game.gameId]
--             for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
--                 if playerInGame.source then
--                     TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 5, { Zone = VectorToTable(teste), ZoneRadius = teste2 })
--                 end
--             end
--         elseif BR.Zone[Game.gameId] and not BR.ZoneTime[Game.gameId] then
--             BR.ZoneTime[Game.gameId] = os.time()
--             BR.ZoneTimer[Game.gameId] = BR.IntervalZone[Game.gameId]
--             local teste3 = BR.IntervalZone[Game.gameId]

--             for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
--                 if playerInGame.source and not Player(playerInGame.source).state.finishGameUI then
--                     TriggerClientEvent("BuildUI", playerInGame.source, "SafeZoneInfo", { status = true, title = "A zona segura está diminuindo" })
--                     TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 6, BR.ZoneTimer[Game.gameId])
--                 end
--             end
--         elseif BR.ZoneCount[Game.gameId] < BR.MaxZones[Game.gameId] and BR.ZoneTime[Game.gameId] and BR.ZoneTime[Game.gameId] + BR.ZoneTimer[Game.gameId] <= os.time() then
--             BR.ZoneTime[Game.gameId] = false
--             BR.ZoneTimer[Game.gameId] = false
--             BR.ZoneRadius[Game.gameId] = BR.ZoneRadius[Game.gameId] / 2
--             BR.Zone[Game.gameId] = BR.Zone[Game.gameId] - GenerateCenterPoint(BR.ZoneRadius[Game.gameId])
--             local teste4 = BR.Zone[Game.gameId]
--             local teste5 = BR.ZoneRadius[Game.gameId]
--             for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
--                 if playerInGame.source and not Player(playerInGame.source).state.finishGameUI then
--                     TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 5, { Zone = teste4, ZoneRadius = teste5 })
--                 end
--             end
--             BR.ZoneCount[Game.gameId] = BR.ZoneCount[Game.gameId] + 1
--         end
--     end
-- end


function BR:Safe(Game) 
    local nextTimeout = 1500
    if BR.BaseZone[Game.gameId] and not BR.Zone[Game.gameId] and os.time() >= BR.StartTime[Game.gameId] + BR.StartZone[Game.gameId] then
        BR.ZoneRadius[Game.gameId] = BR.ZoneRadius[Game.gameId] / 2
        BR.Zone[Game.gameId] = BR.BaseZone[Game.gameId] - GenerateCenterPoint(BR.ZoneRadius[Game.gameId])
        local teste = BR.Zone[Game.gameId]
        local teste2 = BR.ZoneRadius[Game.gameId]
        
        for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
            if playerInGame.source and (BR.Players[Game.gameId][playerInGame.user_id] ~= nil) then
                if not Player(playerInGame.source).state.inSpec then
                    TriggerClientEvent("NotifyAnnouncement", playerInGame.source, { status = true, timer = true, text = "Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos." })
                end
                TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 5, { Zone = VectorToTable(teste), ZoneRadius = teste2 })
            end
        end
    elseif BR.Zone[Game.gameId] and not BR.ZoneTime[Game.gameId] then
        BR.ZoneTime[Game.gameId] = os.time()
        BR.ZoneTimer[Game.gameId] = BR.IntervalZone[Game.gameId]
        local teste3 = BR.IntervalZone[Game.gameId]
        local SafeTeste = false
        Citizen.SetTimeout(60000, function()
            for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
                if playerInGame.source and not Player(playerInGame.source).state.finishGameUI and (BR.Players[Game.gameId][playerInGame.user_id] ~= nil) then
                    if not SafeTeste then
                        SafeTeste = true
                        BR.ZoneTimer[Game.gameId] = BR.IntervalZone[Game.gameId]
                        BR.ZoneTime[Game.gameId] = os.time()
                    end
                    if not Player(playerInGame.source).state.inSpec then
                        TriggerClientEvent("NotifyAnnouncement", playerInGame.source, { status = true, timer = true, text = "<b>A zona segura</b> está diminuindo" })
                    end
                    TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 6, BR.ZoneTimer[Game.gameId])
                end
            end
        end)
    elseif BR.ZoneCount[Game.gameId] < BR.MaxZones[Game.gameId] and BR.ZoneTime[Game.gameId] and BR.ZoneTime[Game.gameId] + BR.ZoneTimer[Game.gameId] <= os.time() then
        BR.ZoneTime[Game.gameId] = false
        BR.ZoneTimer[Game.gameId] = false
        BR.ZoneRadius[Game.gameId] = BR.ZoneRadius[Game.gameId] / 2
        BR.Zone[Game.gameId] = BR.Zone[Game.gameId] - GenerateCenterPoint(BR.ZoneRadius[Game.gameId])
        local teste4 = BR.Zone[Game.gameId]
        local teste5 = BR.ZoneRadius[Game.gameId]
        BR.IntervalZone[Game.gameId] = 180
        
        for _, playerInGame in pairs(BR.Players[Game.gameId]) do 
            if playerInGame.source and not Player(playerInGame.source).state.finishGameUI and (BR.Players[Game.gameId][playerInGame.user_id] ~= nil) then
                if not Player(playerInGame.source).state.inSpec then
                    TriggerClientEvent("NotifyAnnouncement", playerInGame.source, { status = true, timer = true, text = "Uma nova <b>zona segura</b> foi gerada e começará a diminuir em 60 segundos." })
                end
                TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 5, { Zone = teste4, ZoneRadius = teste5 })
            end
        end
        BR.ZoneCount[Game.gameId] = BR.ZoneCount[Game.gameId] + 1
    end
    SetTimeout(nextTimeout, function() return BR:Safe(Game) end)
end
    
-----------------------------------------------------------------------------------------------------------------------------------------
-- battle-CreateSafe
-----------------------------------------------------------------------------------------------------------------------------------------
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
   
    for _, playerInGame in pairs(Game.players) do 
        Player(playerInGame.source).state.inGame = true
        Player(playerInGame.source).state.gameId = Game.gameId
        TriggerClientEvent("battle-IniciarSafe", playerInGame.source)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- battle-FinishSafe
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("battle-FinishSafe")
AddEventHandler("battle-FinishSafe", function(GameRecebido)
    print("Finish safe", GameRecebido)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- battle-UpdatePlayersSafe
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("battle-UpdatePlayersSafe")
AddEventHandler("battle-UpdatePlayersSafe", function(Game) 
    BR.Players[Game.gameId] = Game.players
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DUMP
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end


