-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
GameController = {}
local Games = {}
local Reviving = {}
local usedIds = {}
local PickUps = {}
local Kills = {}
local RoutingBuckets = {}
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
clientAPI = Tunnel.getInterface(GetCurrentResourceName())
SafeZoneAPI = Tunnel.getInterface("safezone")
-----------------------------------------------------------------------------------------------------------------------------------------
--  AdminFunctions - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.AdminFunctions = function(data) 
    local user_id = vRP.getUserId(data.source)
    local identity = vRP.getIdentity(user_id)

    if data.type == "GetGames" then
        local items = {}
        for _, game in pairs(Games) do 
            if not game.finished then
                items[#items+1] = game
            end
        end
        return items
    end

    if data.type == "FinishGame" then
        local Game = Games[data.gameId]
        if Game == nil then return end

        Game.finished = true
        for _, playerInGame in pairs(Game.players) do 
            GameController.LeaveGame({
                source = playerInGame.source,
                user_id = playerInGame.user_id
            })
        end
    end

    if data.type == "InfoGame" then
        local Game = Games[data.gameId]
        if Game == nil then return end
        return Game
    end

    if data.type == "JoinSpec" then
        local Game = Games[data.gameId]
        if Game == nil then return end

        for _, playerInGame in pairs(Game.players) do
            if playerInGame.source == data.source then
                TriggerClientEvent("Notify", data.source,"negado","Você está como jogador dessa partida.", 6000)
                return
            end
        end
        
        Game.players[user_id] = {
            source = data.source,
            user_id = user_id,
            username = identity.username,
            team = Player(data.source).state.teamCode
        }
        
        SetPlayerRoutingBucket(data.source, Game.routing)
        Player(data.source).state.gameId = data.gameId
        Player(data.source).state.death = true
        Player(data.source).state.inGame = true
        Player(data.source).state.inDashboard = false
        Player(data.source).state.inQueue = false
        Player(data.source).state.PlaneStatus = false
        Player(data.source).state.Buttons = true
        Player(data.source).state.inLobbyPrincipal = false
        Player(data.source).state.inAimLab = false
        vRP.clearInventory(user_id)
        Player(data.source).state:set('inSpec', true, true)
    
        GameController.BuildGameUI(data.gameId, {
            status = true,
            players = GameController.GetPlayersCountGame(data.gameId),
            rich = true,
        })
    
        GameController.RequestSpectator({
            source = data.source
        }, true)

        Wait(800)

        GameController.sendPlayerEvent(data.source, "initSpectatorAdmin", { status = true })

        TriggerClientEvent("Notify", data.source,"inform","Você entrou com spectador da partida.", 6000)
    end

	clientAPI.clearInfoCache(data.source, 'partidas')
    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetPlayersCountGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetPlayersCountGame = function(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    local PlayersCount = 0
    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source and not Player(playerInGame.source).state.death and (Game.players[playerInGame.user_id] ~= nil) and not Player(playerInGame.source).state.inSpec and GetPlayerRoutingBucket(playerInGame.source) == Game.routing then
            PlayersCount = PlayersCount + 1
        end
    end

    return PlayersCount
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  createVehicle - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.createVehicle = function(gameId,model,x,y,z,heading,vehPlate,vehDoors,vehBody,single,stateName,routingBucket) 
    local Game = Games[gameId]

    if Game == nil then 
        return 
    end

    local mHash = GetHashKey(model)
	local vehObject = CreateVehicle(mHash,x,y,z,heading,true,true)

	while not DoesEntityExist(vehObject) do
		Citizen.Wait(1)
	end

	if routingBucket then
		SetEntityRoutingBucket(vehObject, parseInt(routingBucket))
	end

	local netVeh = NetworkGetNetworkIdFromEntity(vehObject)

    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source then
            clientAPI.createVehicle(playerInGame.source,mHash,netVeh,vehPlate,1000,1000,100,nil,false,false,false,{ 1.25,0.75,0.95 })
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItems - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.DropInventoryItems = function(gameId, inventory, Coords)
    local Game = Games[gameId]

    if Game == nil then 
        return 
    end

    for k,inventory in pairs(inventory) do 
        if itemDrop(inventory.item) then
            GameController.sendEventPlayersEvent(gameId, "DropInventoryItem", {
                name = inventory.item,
                coords = vector3(Coords["x"]+(math.random(-8000,8000)/1000),Coords["y"]+(math.random(-8000,8000)/1000),Coords["z"]),
                ammout = inventory.amount
            })
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.DropInventoryItem(Slot, Amount) 
    local source = source
    local Game = Games[Player(source).state.gameId]
    
    if Game == nil then 
        return 
    end

    if Player(source).state.inGame then
        local Slot = tostring(Slot)
        local Amount = parseInt(Amount)
        local user_id = vRP.getUserId(source)
        local inventory = vRP.userInventory(source, user_id)
        
        if not inventory[Slot] or inventory[Slot].item == nil then
            return
        end
        
        if not Amount or Amount <= 0 then 
            Amount = 1 
        end
        
        local Item = inventory[Slot].item

        if itemDrop(Item) then
            if vRP.tryGetInventoryItem(user_id, Item, Amount, true, Slot) then
                TriggerClientEvent('inventory:Update', source, 'updateMochila')

                local Ped = GetPlayerPed(source)
                local Coords = GetEntityCoords(Ped)

                GameController.sendEventPlayersEvent(Player(source).state.gameId, 'DropInventoryItem', {
                    name = Item, 
                    ammout = Amount, 
                    coords = vector3(Coords.x, Coords.y, Coords.z - 1.0)
                })
            end
        else
            TriggerClientEvent('Notify', source, 'negado', 'Não é possível dropar este item.', 15000, 'normal', 'Admin')
        end
    end

    Citizen.Wait(100)

    clientAPI.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetGameStatus - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetGameStatus = function(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end
    return Game.started
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetupSafe - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.SetupSafe = function(gameId) 
    local Game = Games[gameId]
    
    if Game == nil then 
        return 
    end

    -- for _, playerInGame in pairs(Game.players) do 
    --     if playerInGame.source then
    --         Player(playerInGame.source).state.gameId = gameId

    --         TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 3, {
    --             safeZone = VectorToTable(vector3(Config.Maps[Game.map].center.x, Config.Maps[Game.map].center.y, 50.0)),
    --             radius = Config.Maps[Game.map].radius,
    --         })
    --     end
    -- end
    
    TriggerEvent("battle-CreateSafe", Game, vector3(Config.Maps[Game.map].center.x, Config.Maps[Game.map].center.y, 50.0))
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetPlayersInPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetPlayersInPlane = function(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end
    local Count = 0

    for _, playerInGame in pairs(Game.players) do 
        if Player(playerInGame.source) and Player(playerInGame.source).state then
            if Player(playerInGame.source).state.inPlane then
                Count = Count + 1
            end
        end
        Wait(1)
    end

    return Count
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetPlayersInPlane - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.UpdatePlayersInPlane = function(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    for _, playerInGame in pairs(Game.players) do 
        if Player(playerInGame.source) and Player(playerInGame.source).state and GetPlayerRoutingBucket(playerInGame.source) == Game.routing then
            if Player(playerInGame.source).state.inPlane then
                local numPlayers = GameController.GetPlayersInPlane(gameId)
                local text

                if numPlayers == 1 then
                  text = "Ainda há <b>1</b> jogador na cabine do avião."
                else
                  text = "Ainda há <b>" .. numPlayers .. "</b> jogadores na cabine do avião."
                end

                TriggerClientEvent("NotifyAnnouncement", playerInGame.source, { status = true, timer = false, text = text })
            end
        end
        Wait(1)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  IsFollowingTeam - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.IsFollowingTeam = function(source, data) 
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end

    if data.type == "Get" then
        if Game.gameType == "duo" or Game.gameType == "squad" then
            if not Player(source).state.IsFollowingTeam and not isUserLeaderOfGroup(user_id, Player(source).state.teamCode) then
                Player(source).state.IsFollowingTeam = true
                Player(source).state.IsFollowingTeamLeaderName = ApiController.GetUserNamehasLeader(Player(source).state.teamCode)
            end
        end
    end

    if data.type == "Cancel" then
        Player(source).state.IsFollowingTeam = false
        Player(source).state.IsFollowingTeamLeaderName = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetPlayersInPlaneClient - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetPlayersInPlaneClient = function(source) 
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    local numPlayers = GameController.GetPlayersInPlane(Player(source).state.gameId)
    local text
    
    if numPlayers == 1 then
        text = "Ainda há <b>1</b> jogador na cabine do avião."
    else
        text = "Ainda há <b>" .. numPlayers .. "</b> jogadores na cabine do avião."
    end
            
    TriggerClientEvent("NotifyAnnouncement", source, { status = true, timer = false, text = text })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  AlterDimension - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.AlterDimension = function(source, data) 
    local user_id = vRP.getUserId(source)
    SetPlayerRoutingBucket(source, 1+user_id)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  StartGameNew - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.StartGameNew = function(source, data) 
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]

    Player(source).state.inGame = true
    Player(source).state.inDashboard = false
    Player(source).state.inQueue = false
    Player(source).state.PlaneStatus = false
    Player(source).state.Compass = true
    Player(source).state.Buttons = false
    Player(source).state.inLobbyPrincipal = false
    Player(source).state.inAimLab = false
    Player(source).state.inGameLobby = false
    Player(source).state.inSpec = false
    Player(source).state.inPlane = true
    
    if Game.gameType == "duo" or Game.gameType == "squad" then
        if not Player(source).state.IsFollowingTeam and not isUserLeaderOfGroup(user_id, Player(source).state.teamCode) then
            Player(source).state.IsFollowingTeam = true
            Player(source).state.IsFollowingTeamLeaderName = ApiController.GetUserNamehasLeader(Player(source).state.teamCode)
        end
    end
    
    TriggerClientEvent('events_controller', source, {
        event = "StartGameClient",
        data = {
            map = Game.map,
            planePos = Game.planePos  
        }
    })

    TriggerClientEvent('events_controller', source, { event = "ExitLobbyGame", data = {} })

    SetTimeout(60000, function()
        GameController.sendPlayerEvent(source, "StopPlane", { })
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  PreparesStartGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.PreparesStartGameNew = function(gameId, eventName, eventData)
    for playerId, player in pairs(Games[gameId].players) do
        Player(player.source).state.inGame = true
        Player(player.source).state.inDashboard = false
        Player(player.source).state.inQueue = false
        Player(player.source).state.PlaneStatus = false
        Player(player.source).state.Compass = true
        Player(player.source).state.Buttons = false
        Player(player.source).state.inLobbyPrincipal = false
        Player(player.source).state.inAimLab = false
        vRP.clearInventory(player.user_id)
        Player(player.source).state.inGameLobby = false
        Player(player.source).state.inSpec = false

        Player(player.source).state.inPlane = true
        TriggerClientEvent('events_controller', player.source, { event = "ExitLobbyGame", data = {} })

        if Games[gameId].gameType == "duo" or Games[gameId].gameType == "squad" then
            if not Player(player.source).state.IsFollowingTeam and not isUserLeaderOfGroup(player.user_id, Player(player.source).state.teamCode) then
                Player(player.source).state.IsFollowingTeam = true
                Player(player.source).state.IsFollowingTeamLeaderName = ApiController.GetUserNamehasLeader(Player(player.source).state.teamCode)
            end
        end

        TriggerClientEvent('events_controller', player.source, {
            event = eventName,
            data = eventData
        })
    
        Wait(1)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  SetupLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.SetupLoots = function(gameId) 
    local Game = Games[gameId]

    if Game == nil then 
        return 
    end

    local Coords = {}
    local timeExceded = 0
    local CarsCoords = {}
    local Cars = {}
    local Boats = {}
    local weapons = {}
    local index = 0

    Coords[gameId] = {}
    CarsCoords[gameId] = {}
    Cars[gameId] = {}
    Boats[gameId] = {}
    PickUps[gameId] = {}

    local shuffledCoordsCars = shuffle(Config.Maps[Game.map].Cars)

    Games[gameId].planePos = Config.Maps[Games[gameId].map].center - GenerateCenterPoint(Config.Maps[Games[gameId].map].radius or 3000.0, true)

    Citizen.CreateThread(function()
        local dimension = Game.routing

        for i = 1, Config.Maps[Game.map].MaxCars do
            table.insert(Cars[gameId], {
                model = Config.Cars[math.random(1, #Config.Cars)],
                x = shuffledCoordsCars[i]["x"],
                y = shuffledCoordsCars[i]["y"],
                z = shuffledCoordsCars[i]["z"]
            })
        end

        for key, coords in pairs(Cars[gameId]) do
            local plateFinal = math.random(10000,99999)
            local vehPlate = "VEH".. parseInt(plateFinal)
            
            GameController.createVehicle(gameId, coords.model,coords.x,coords.y,coords.z, 280.0, vehPlate,nil,nil,nil,"Battle",dimension)
        end
    end)

    if Config.Maps[Games[gameId].map].isBoats then
        local shuffledCoordsBoats = shuffle(Config.Maps[Game.map].Boats)

        Citizen.CreateThread(function()
            local dimension = Game.routing
    
            for i = 1, Config.Maps[Games[gameId].map].MaxBoats do
                table.insert(Boats[gameId], {
                    model = Config.Boats[math.random(1, #Config.Boats)],
                    x = shuffledCoordsBoats[i]["x"],
                    y = shuffledCoordsBoats[i]["y"],
                    z = shuffledCoordsBoats[i]["z"]
                })
            end
    
            for key, coords in pairs(Boats[gameId]) do
                local vehPlate = "BOAT"..parseInt(math.random(10000,99999))
                
                GameController.createVehicle(gameId, coords.model,coords.x,coords.y,coords.z, 280.0, vehPlate,nil,nil,nil,"Battle",dimension)
            end
        end)
    end

    local seed = math.random()

    for _, playerInGame in pairs(Game.players) do 
        local isPlayerValid = not not playerInGame.source 

        if isPlayerValid then
            TriggerClientEvent('brv:createPickups', playerInGame.source, seed, Game.map)
        end
    end
    
    SetTimeout((Config.StartTime - 2) * 1000, function() 
        GameController.PreparesStartGameNew(gameId, "StartGameClient", {
            map = Game.map,
            planePos = Game.planePos
        })

        Citizen.Wait(Config.StartSafe * 1000)

        GameController.SetupSafe(gameId)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  RandomMap - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.RandomMap = function()
    local totalChance = 0
    for _, map in ipairs(Config.MapsGame) do
      totalChance = totalChance + map.chance
    end
    
    local randomNumber = math.random(1, totalChance)
    
    local cumulativeChance = 0
    for _, map in ipairs(Config.MapsGame) do
      cumulativeChance = cumulativeChance + map.chance
      if randomNumber <= cumulativeChance then
        return map.name
      end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetFreeRoutingBucket - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetFreeRoutingBucket = function(startIndex, endIndex)
    startIndex = startIndex or 1000
    endIndex = endIndex or 50000
    for i=startIndex, endIndex do
        if not RoutingBuckets[i] then
            RoutingBuckets[i] = true
            return i
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendPlayerEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.sendPlayerEvent = function(src, eventName, eventData)
    TriggerClientEvent('events_controller', src, {
        event = eventName,
        data = eventData
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendEventPlayersEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.sendEventPlayersEvent = function(gameId, eventName, eventData)
    for playerId, player in pairs(Games[gameId].players) do
        TriggerClientEvent('events_controller', player.source, {
            event = eventName,
            data = eventData
        })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendEventPlayersLoot - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.sendEventPlayersLoot = function(gameId, eventName, eventData)
    for playerId, player in pairs(Games[gameId].players) do
        TriggerClientEvent('events_controller', player.source, {
            event = eventName,
            data = eventData
        })
        Wait(5)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  BuildGameUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.BuildGameUI = function(gameId, eventData)
    local game = Games[gameId]
    
    if not game then
        return
    end

    for playerId, player in pairs(game.players) do
        if player.source and (game.players[player.user_id] ~= nil) then
            local kills = Player(player.source).state.kills

            eventData.kills = kills

            TriggerClientEvent('events_controller', player.source, {
                event = "BuildGame",
                data = eventData
            })
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  PreparesStartGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.PreparesStartGame = function(gameId, eventName, eventData)
    for playerId, player in pairs(Games[gameId].players) do
        Player(player.source).state.inGame = true
        Player(player.source).state.inDashboard = false
        Player(player.source).state.inQueue = false
        Player(player.source).state.PlaneStatus = false
        Player(player.source).state.Compass = true
        Player(player.source).state.Buttons = true
        Player(player.source).state.inLobbyPrincipal = false
        Player(player.source).state.inAimLab = false
        vRP.clearInventory(player.user_id)
        Player(player.source).state.inGameLobby = true
        Player(player.source).state.inSpec = false
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  StartGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.StartGame = function(gameId)
    local Game = Games[gameId]
    if Game == nil then return end

    if not Game.started then
        Games[gameId].started = true

        GameController.PreparesStartGame(gameId, "StartGameClient", {
            map = Game.map,
            planePos = Game.planePos
        })

        Wait(500)

        for playerId, player in pairs(Game.players) do
            local isPlayerValid = player.source and (Game.players[player.user_id] ~= nil)  
            
            if isPlayerValid then
                TriggerClientEvent('events_controller', player.source, {
                    event = "JoinLobbyGame",
                    data = {}
                })
            else
                GameController.LeaveGame({
                    source = player.source,
                    user_id = playerId,
                })
            end
        end

        GameController.SetupLoots(gameId)

        GameController.BuildGameUI(gameId, {
            status = true,
            players = GameController.GetPlayersCountGame(gameId),
            rich = true,
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  game-players - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("game-players", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end
    if not args[1] then return; end

    Config.MinPlayers = parseInt(args[1])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  game-start - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("game-start", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)

	if source ~= 0 and not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

    if source > 0 and not Player(source).state.inQueue then
        local Game = Games[parseInt(args[1])]
        if Game == nil then return end
    
        GameController.StartGame(parseInt(args[1]))
    elseif args[1] then
        local Game = Games[parseInt(args[1])]
        if Game == nil then return end
    
        GameController.StartGame(parseInt(args[1]))
    elseif source > 0 then 
        local Game = Games[Player(source).state.gameId]
        if Game == nil then return end
        GameController.StartGame(Player(source).state.gameId)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  checkEndGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.checkEndGame = function(source, gameId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  processGamesEnd - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.processGamesEnd = function() 
    for _, game in pairs(Games) do 
        if game.started and GameController.GetPlayersCountGame(game.gameId) == 0 then
            Games[game.gameId] = nil
        end    
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  processEventTick - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local InTest = false

GameController.processEventTick = function(gameId) 
    if InTest then
        return
    end

    local game = Games[gameId]

    if game == nil then 
        return 
    end

    local teamsAlive = {}

    for _, playerInGame in pairs(game.players) do
        local player = Player(playerInGame.source)
        
        if not player.state.death and not player.state.inSpec and not player.state.inDashboard and not player.state.inGameLobby and not player.state.inLobbyPrincipal and GetPlayerRoutingBucket(playerInGame.source) == game.routing then
            local teamCode = playerInGame.team
            
            teamsAlive[teamCode] = (teamsAlive[teamCode] or 0) + 1
        end
    end

    if not game.finished then
        local numTeamsAlive = 0
        local winningTeam = nil

        for teamCode, numAlive in pairs(teamsAlive) do
            if numAlive > 0 then
                numTeamsAlive = numTeamsAlive + 1
                winningTeam = teamCode
            end
        end

        if numTeamsAlive == 1 then
            game.finished = true

            print("^2[ PARTIDAS ]^7 Partida: "..game.gameId.." finalizada com o ganhador: "..winningTeam..", modo: "..game.gameType.."")

            ApiController.OpenWinner({ code = winningTeam, gameId = game.gameId })

            return
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  desbugar - command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("desbugar", function(source, args, rawCmd) 
    GameController.checkEndGame(source, Player(source).state.gameId)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  endSpec - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.endSpec = function(source) 
    local user_id = vRP.getUserId(source)
    if source and Player(source) then
        if Player(source).state.inGame then
            if Player(source).state.inSpec then
                clientAPI.stopSpectatorMode(source)
                Player(source).state.inSpec = false
            end

            ApiController.sendPlayerEvent(source, "CheckOut", { 
                status = true,
                type = Player(source).state.typeCheckOut,
                pos = ApiController.GetPlayerPosition(source),
                maxPlayers = GameController.GetMaxPlayersGame(Player(source).state.gameId),
            })

            SetPlayerRoutingBucket(source, user_id+1)
            Player(source).state.finishGameUI = true
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  endSpec - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.endGame = function(source) 
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]

    if Game == nil then
        if Player(source).state.inSpec then
            clientAPI.stopSpectatorMode(source)
            Player(source).state.inSpec = false
        end

        if Player(source).state.finishGameUI then
            ApiController.sendPlayerEvent(source, "CheckOut", { status = false })
            Player(source).state.finishGameUI = false
        end

        TriggerClientEvent("favela-core:killPlayer", source)
        TriggerEvent("inventory:StopInventory", user_id)

        Player(source).state.positionGame = 0

        Player(source).state.inQueue = false
        Player(source).state.inGame = false
        Player(source).state.agonizing = false
        Player(source).state.death = false
        Player(source).state.isReviving = false

        SafeZoneAPI.StopSafezone(source)
        GameController.sendPlayerEvent(source, "StopLoots", {})
        
        GameController.sendPlayerEvent(source, "BuildGame", {
            status = false,
            rich = false,
        })

        if not Player(source).state.PlaneStatus then
            GameController.sendPlayerEvent(source, "StopPlane", {})
            
            Player(source).state.PlaneStatus = true
        end
        
        ApiController.JoinLobby(source)
    
        Player(source).state.gameId = 0
        deleteGroupFromOwnerSource(source)

        return;
    end

    if source and Player(source) then
        if Player(source).state.inGame then
            if Player(source).state.finishGameUI then
                ApiController.sendPlayerEvent(source, "CheckOut", { status = false })
                Player(source).state.finishGameUI = false
            end

            TriggerClientEvent("favela-core:killPlayer", source)
            
            TriggerEvent("inventory:StopInventory", user_id)
            
            local body = json.encode({
                user_id = user_id,
                pos = ApiController.GetPlayerPosition(source) or 64,
                kills = Player(source).state.kills or 0,
                type = Player(source).state.typeCheckOut or "Lose",
                gamemode = Game.gameType or 'solo',
                gameMap = Game.map or 'Cidade',
                premium = exports["core"]:Premium().isVipByUserId(user_id,"padrao")
            })
        
            PerformHttpRequest('http://localhost:3500/ComputePoints', function(status, text)
                if status == 0 then
                    TriggerClientEvent("Notify",source,"inform","Internal Server Error, computepoints.")
                end
                clientAPI.clearInfoCache(source, 'profile_ranking')
                clientAPI.clearInfoCache(source, 'profile_history')
                clientAPI.clearInfoCache(source, 'passe')
            end, 'POST', body, { ['Content-Type'] = 'application/json' })

            GameController.LeaveGame({
                source = source,
                user_id = user_id,
            })
            
            Wait(800)
            Player(source).state.positionGame = 0
            deleteGroupFromOwnerSource(source)
        end
    end
end

RegisterCommand("sairGame", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
    GameController.LeaveGame({
        source = source,
        user_id = user_id,
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendKillGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.SendKillGame = function(gameId, killData)
    local Game = Games[gameId]

    if Game == nil then 
        return 
    end

    local victimId = killData.victim
    local killerId = killData.killer

    local killfeedEntries = {
        killData.weapon_killer,
        victimId,
        killData.victim_name,
        getUserGuildTag(victimId), 
        killerId,
        killerId and killData.killer_name,
        killerId and getUserGuildTag(killerId)
    }

    for _, player in pairs(Game.players) do
        local isInGame = player.source and Player(player.source) and not Player(player.source).state.finishGameUI and GetPlayerRoutingBucket(player.source) == Game.routing

        if isInGame then
            TriggerClientEvent(
                "NotifyKill", 
                player.source, 
                killfeedEntries
            )
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FinishAllPlayers - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.FinishAllPlayers = function(source, players)
    local user_id = vRP.getUserId(source)
    local gameId = Player(source).state.gameId
    local Game = Games[gameId]
    if Game == nil then return end

    for _, player in pairs(players) do 
        if Kills[player.user_id] and Player(player.source).state.agonizing and not Player(player.source).state.death and player.user_id ~= user_id then
            local killData = {
                headshot = false,
                weapon_killer = GetHashKey("WEAPON_UNARMED"),
                killer_name = "Morte",
                killer = "",
                victim_name = "",
                victim = player.user_id,
                source = source,
                positionGame = GameController.GetPlayersCountGame(gameId),
                agonizing = false
            }

            killData.headshot = Kills[player.user_id].headshot or false
            killData.weapon_killer = Kills[player.user_id].weapon_killer or GetHashKey("WEAPON_UNARMED")
            killData.killer = Kills[player.user_id].killer or "Bug"
            killData.killer_name = Kills[player.user_id].killer_name or "Bug"
            killData.victim_name = Kills[player.user_id].victim_name or "Bug"
            
            if Kills[player.user_id] and Kills[player.user_id].nsource ~= source then
                local player = Player(Kills[player.user_id].nsource or source)
                if player and player.state.kills then
                    player.state.kills = player.state.kills + 1
                end
            end

            local killsData = Kills[player.user_id]
            local killsCount = 0

            if killsData and killsData.nsource then
                killsCount = Player(killsData.nsource).state.kills or 0
            end

            GameController.sendPlayerEvent(player.source, "FinishAgonizing", {})

            GameController.BuildGameUI(gameId, {
                status = true,
                kills = killsCount,
                players = GameController.GetPlayersCountGame(gameId),
                rich = true,
            })

            -- GameController.checkEndGame(Kills[player.user_id].nsource, gameId)

            GameController.SendKillGame(gameId, killData)

            Kills[player.user_id] = nil
        end
        Wait(1)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterKill - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.RegisterKill = function(source, data)
    local user_id = vRP.getUserId(source)
    local Game = Games[data.gameId]

    if Game == nil then return end
    if source == nil then return end
    if Game.finished then return end
	if not Player(source).state.inGame then return end

    if Player(source).state.isReviving then
        local nsource = tonumber(Reviving[source])
        Player(source).state.isReviving = false
        GameController.sendPlayerEvent(nsource, "ReviveAgonizingClient", { source = nsource, type = "Start" })
        ApiController.ReviveAgonizingStatus({ source = nsource, status = false })
        Reviving[source] = nil
    end

    if data.nsource == 0 then
        local identity = vRP.getIdentity(user_id)
        local inventory = vRP.userInventory(source, user_id)
        local Ped = GetPlayerPed(source)
        local Coords = GetEntityCoords(Ped)

        if not Kills[user_id] and Game.players[user_id] and identity then
            if source then
                Kills[user_id] = {
                    headshot = data.hs,
                    killer = user_id,
                    killer_name = identity.username,
                    nsource = source,
                    victim_name = identity.username,
                    weapon_killer = GetHashKey("WEAPON_UNARMED"),
                    positionGame = GameController.GetPlayersCountGame(data.gameId)
                }
            end
        end

        local killData = {
            headshot = false,
            weapon_killer = GetHashKey("WEAPON_UNARMED"),
            killer_name = identity and identity.username or "Unknown",
            killer = user_id,
            victim_name = identity and identity.username or "Unknown",
            victim = user_id,
            source = source or nil,
            positionGame = GameController.GetPlayersCountGame(data.gameId),
            agonizing = false
        }

        local Kill = ApiController.VerifyKillTeam(killData, GameController.GetPlayersCountGame(data.gameId), Game.Gamemode, data.gameId, Game.players, Game.gameType)

        killData.agonizing = Kill.agonizing

        if not Kill.agonizing and Kills[user_id] and Game.players[user_id] and source and user_id then
            if Kills[user_id].weapon_killer and Kills[user_id].killer and Kills[user_id].killer_name then
                killData.headshot = Kills[user_id].headshot or false
                killData.weapon_killer = Kills[user_id].weapon_killer or GetHashKey("WEAPON_UNARMED")
                killData.killer = Kills[user_id].killer or "Bug"
                killData.killer_name = Kills[user_id].killer_name or "Bug"
            end

            if Kills[user_id] and Kills[user_id].nsource ~= source then
                local player = Player(Kills[user_id].nsource or source)
                if player and player.state.kills then
                    player.state.kills = player.state.kills + 1
                end
            end
            
            ApiController.RegisterKillGame({
                source = source,
                gameId = data.gameId,
                gameType = Game.gameType,
                playersGameCount = GameController.GetPlayersCountGame(gameId),
                positionGame = Kills[user_id].positionGame
            })

            if Game.gameType == "duo" or Game.gameType == "squad" then
                ApiController.FinishAgonizing({ source = source })
            end

            Kills[user_id] = nil
        end

        GameController.SendKillGame(data.gameId, killData)

        GameController.BuildGameUI(data.gameId, {
            status = true,
            players = GameController.GetPlayersCountGame(data.gameId),
            rich = true,
        })

        GameController.DropInventoryItems(data.gameId, inventory, Coords)
    else
        local nuser_id = vRP.getUserId(data.nsource) 
        
        if nuser_id then 
            local identity = vRP.getIdentity(user_id)
            local inventory = vRP.userInventory(source, user_id)
            local Ped = GetPlayerPed(source)
            local Coords = GetEntityCoords(Ped)
            local identity_killer = vRP.getIdentity(nuser_id)
            local weapon = GetSelectedPedWeapon(GetPlayerPed(data.nsource))

            if not Kills[user_id] and Game.players[nuser_id] and Game.players[user_id] then
                Kills[user_id] = {
                    killer = nuser_id,
                    killer_name = identity_killer.username,
                    weapon_killer = weapon,
                    nsource = Game.players[nuser_id].source,
                    victim_name = identity.username,
                    headshot = data.hs,
                    positionGame = GameController.GetPlayersCountGame(data.gameId)
                }
            end

            local killData = {
                headshot = data.hs,
                weapon_killer = weapon,
                killer_name = identity_killer.username,
                killer = nuser_id,
                victim_name = identity.username,
                victim = user_id,
                source = source,
                positionGame = GameController.GetPlayersCountGame(data.gameId),
                agonizing = false
            }

            if weapon and identity then
                local Kill = ApiController.VerifyKillTeam(killData, GameController.GetPlayersCountGame(data.gameId), Game.Gamemode, data.gameId, Game.players, Game.gameType)

                killData.agonizing = Kill.agonizing

                if not Kill.agonizing and Kills[user_id] and Game.players[nuser_id] and Game.players[user_id] then

                    if Kills[user_id].weapon_killer and Kills[user_id].killer and Kills[user_id].killer_name then
                        killData.headshot = Kills[user_id].headshot or false
                        killData.weapon_killer = Kills[user_id].weapon_killer or GetHashKey("WEAPON_UNARMED")
                        killData.killer = Kills[user_id].killer or "Bug"
                        killData.killer_name = Kills[user_id].killer_name or "Bug"
                    end

                    -- Player(Kills[user_id].nsource or source).state.kills = Player(Kills[user_id].nsource or source).state.kills + 1

                    if Kills[user_id] and Kills[user_id].nsource ~= source then
                        local player = Player(Kills[user_id].nsource or source)
                        if player and player.state.kills then
                            player.state.kills = player.state.kills + 1
                        end
                    end

                    ApiController.RegisterKillGame({
                        source = source,
                        gameId = data.gameId,
                        gameType = Game.gameType,
                        playersGameCount = GameController.GetPlayersCountGame(gameId),
                        positionGame = Kills[user_id].positionGame
                    })
                    
                    if Game.gameType == "duo" or Game.gameType == "squad" then
                        ApiController.FinishAgonizing({ source = source })
                    end
                    
                    -- local killsData = Kills[user_id]
                    -- local killsCount = 0
                            
                    -- if killsData and killsData.nsource then
                    --     killsCount = Player(killsData.nsource).state.kills or 0
                    -- end
                    
                    -- GameController.BuildGameUI(data.gameId, {
                    --     status = true,
                    --     kills = killsCount,
                    --     players = GameController.GetPlayersCountGame(data.gameId),
                    --     rich = true,
                    -- })
                    -- GameController.checkEndGame(source, data.gameId)

                    Kills[user_id] = nil
                end

                GameController.SendKillGame(data.gameId, killData)

                GameController.BuildGameUI(data.gameId, {
                    status = true,
                    players = GameController.GetPlayersCountGame(data.gameId),
                    rich = true,
                })

                GameController.DropInventoryItems(data.gameId, inventory, Coords)
            end
        end
    end



    for _, player in pairs(Game.players) do
        if Game.gameType == "duo" or Game.gameType == "squad" then
            if Player(player.source).state.inSpec then
                ApiController.RequestSpectatorTeam({ source = player.source }, false)
            end
        end
    
        if Game.gameType == "solo" then
            if Player(player.source).state.inSpec then
                GameController.RequestSpectator({ source = player.source }, false)
            end
        end
        Wait(5)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterKillSafe - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.RegisterKillSafe(data)
    local source = source
    local Game = Games[data.gameId]
    if Game == nil then return end
	if not Player(source).state.inGame then return end
    GameController.RegisterKill(source, data)

    GameController.BuildGameUI(data.gameId, {
        status = true,
        players = GameController.GetPlayersCountGame(data.gameId),
        rich = true,
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetGamesForType - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetGamesForType = function(gameType)
    local matchingGameId = 0

    for k,v in pairs(Games) do 
        if v.gameType == gameType and GameController.GetPlayersCountGame(v.gameId) < v.maxPlayers and not v.started and not v.finished and v.mode == "Padrao" then
            matchingGameId = v.gameId
        end
    end

    if matchingGameId > 0 then
        return matchingGameId
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetGameForCode - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetGameForCode = function(code) 
    for _, game in pairs(Games) do 
        if game.code == code and game.mode ~= "Padrao" and GameController.GetPlayersCountGame(game.gameId) < game.maxPlayers and not game.started and not game.finished then
            return Games[game.gameId]
        end
    end

    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetGameFromId - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetGameFromId = function(gameId) 
    return Games[gameId]
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetGameForCode - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GenerateUniqueId = function()
    math.randomseed(GetGameTimer())
    local randomId = math.random(1, 80000)

    while usedIds[randomId] do
        randomId = math.random(1, 80000)
    end

    -- Marca o ID como utilizado e o retorna
    usedIds[randomId] = true
    return randomId
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  HostGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.HostGame = function(data, type)
    local routingBucket = GameController.GetFreeRoutingBucket()

    GameController.processGamesEnd()

    if routingBucket then
        -- local gameId = #Games + 1
        local gameId = GameController.GenerateUniqueId()
        
        if type == 'player' then
            if not Games[gameId] then
                local threadExists = false
                if Games[gameId] ~= nil then
                    threadExists = true
                end

                local game = {
                    gameId = gameId,
                    routing = routingBucket,
                    LobbyRouting = GameController.GetFreeRoutingBucket(),
                    map = GameController.RandomMap() or "Cidade",
                    -- map = "Ilha",
                    players = {},
                    maxPlayers = 64,
                    MinPlayers = Config.MinPlayers,
                    code = nil,
                    mode = "Padrao",
                    started = false,
                    finished = false,
                    Gamemode = gameMode or "ranked",
                    gameType = data or "default",
                    planePos = nil,
                    status = 0,
                    timeExceded = 0,
                    Loots = {}
                }
    
                Games[gameId] = game

                print("^2[ PARTIDAS ]^7 Partida: "..gameId.." criada com o tipo: "..data.."")

                if not threadExists then
                    Citizen.CreateThread(function()
                        while true do
                            if Games[gameId] ~= nil then
                                if Games[gameId].started and not Games[gameId].finished then
                                    GameController.processEventTick(gameId)
                                end
                            end
                            Wait(8000)
                        end
                    end)
                end

                return game
            end
        end

        if type == 'admin' then
            if not Games[gameId] then
                local threadExists = false
                if Games[gameId] ~= nil then
                    threadExists = true
                end

                local game = {
                    gameId = gameId,
                    routing = routingBucket,
                    -- LobbyRouting = GameController.GetFreeRoutingBucket(),
                    -- map = GameController.RandomMap() or "Cidade",
                    map = data.map,
                    players = {},
                    maxPlayers = data.totalPlayers,
                    MinPlayers = Config.MinPlayers,
                    code = data.code,
                    mode = data.modeType,
                    started = false,
                    finished = false,
                    Gamemode = data.typeGame,
                    gameType = data.gamemode,
                    planePos = nil,
                    status = 0,
                    timeExceded = 0,
                    Loots = {}
                }
    
                Games[gameId] = game
    
                print("^2[ PARTIDAS ]^7 Partida: "..gameId.." criada com o tipo: "..data.gamemode.." codigo: "..data.code.."")

                if not threadExists then
                    Citizen.CreateThread(function()
                        while true do
                            if Games[gameId] ~= nil then
                                if Games[gameId].started and not Games[gameId].finished then
                                    GameController.processEventTick(gameId)
                                end
                            end
                            Wait(8000)
                        end
                    end)
                end
                return game
            end
        end
    end


    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetMaxPlayersGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetMaxPlayersGame = function(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    return Game.maxPlayers
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendEventSpectatorsEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.sendEventSpectatorsEvent = function(gameId, eventName, eventData)
    for playerId, player in pairs(Games[gameId].players) do
        if Player(player.source).state.inSpec then
            TriggerClientEvent('events_controller', player.src, {
                event = eventName,
                data = eventData
            })
        end
        Wait(1)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  JoinGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.JoinGame = function(gameId, playerData)
    local Game = Games[gameId]
    if Game == nil then return end

    for _, player in ipairs(Game.players) do
        if player.source == playerData.source then
            return
        end
    end

    Game.players[playerData.user_id] = playerData

    SetPlayerRoutingBucket(playerData.source, Game.routing)
    Player(playerData.source).state.gameId = gameId
    Player(playerData.source).state.death = false

    Wait(500)

    if Player(playerData.source).state.inQueue then
        Wait(500)

        if GameController.GetPlayersCountGame(Game.gameId) >= Game.MinPlayers and not Game.started and not Game.finished then
            GameController.StartGame(Game.gameId)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  LeaveGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.LeaveGame = function(playerData) 
    local user_id = vRP.getUserId(playerData.source)
    local player_state = Player(playerData.source).state
    local gameId = player_state.gameId
    local Game = Games[gameId]

    if (gameId == nil or Game == nil) then
        return
    end

    if Game.players[playerData.user_id] ~= nil then
        Game.players[playerData.user_id] = nil
    end

    Player(playerData.source).state.typeCheckOut = "Lose"

    if Player(playerData.source).state.inSpec then
        clientAPI.stopSpectatorMode(playerData.source)
        
        Player(playerData.source).state.inSpec = false
    end

    Player(playerData.source).state.inQueue = false
    Player(playerData.source).state.inGame = false
    Player(playerData.source).state.agonizing = false

    if not Player(playerData.source).state.death and not Games[gameId].finished then
        Player(playerData.source).state.death = true
    end

    Player(playerData.source).state.isReviving = false

    if not Game.finished and Game.started then
        GameController.BuildGameUI(Player(playerData.source).state.gameId, {
            status = true,
            players = GameController.GetPlayersCountGame(Player(playerData.source).state.gameId),
            rich = true,
        })
        -- GameController.checkEndGame(playerData.source, Player(playerData.source).state.gameId)
    end

    TriggerEvent("inventory:StopInventory", playerData.user_id)

    if not Player(playerData.source).state.inDashboard then
        SafeZoneAPI.StopSafezone(playerData.source)
        GameController.sendPlayerEvent(playerData.source, "StopLoots", {})

        if not Player(playerData.source).state.PlaneStatus then
            GameController.sendPlayerEvent(playerData.source, "StopPlane", {})
            Player(playerData.source).state.PlaneStatus = true
        end

        GameController.sendPlayerEvent(playerData.source, "BuildGame", {
            status = false,
            rich = false,
        })

        ApiController.JoinLobby(playerData.source)
    end

    -- Atualiza os jogadores da safe

    TriggerEvent("battle-UpdatePlayersSafe", Games[gameId])

    Player(playerData.source).state.gameId = 0

    if GameController.GetPlayersCountGame(Game.gameId) >= Game.MinPlayers and not Game.started and not Game.finished then
        GameController.StartGame(Game.gameId)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  ExitPlaneDimension - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.ExitPlaneDimension = function() 
    local source = source
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end

    vRP.generateItem(user_id, "WEAPON_KNIFE",parseInt(1),false, 5)

    clientAPI.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))

    SetPlayerRoutingBucket(source, Game.routing)
    Player(source).state.inPlane = false
    
    TriggerClientEvent("NotifyAnnouncement", source, { status = false, timer = false })

    if Game.gameType == "duo" or Game.gameType == "squad" and isUserLeaderOfGroup(user_id, Player(source).state.teamCode) then
        ApiController.JumpPlayersFollowing(Player(source).state.teamCode)
    end
    GameController.UpdatePlayersInPlane(Player(source).state.gameId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  OpenBox - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.OpenBox = function(source, data) 
    local GameId = Player(source).state.gameId
    local Game = Games[GameId]

    if Game == nil then 
        return 
    end

    GameController.sendEventPlayersLoot(GameId, "GeneratePickup", data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetLoot - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.GetLoot = function(source, data) 
    local user_id = vRP.getUserId(source)

    local GameId = Player(source).state.gameId
    local Game = Games[GameId]

    if Game == nil then 
        return 
    end

    if data.drop and data.ammout > 0 then
        if (vRP.inventoryWeight(user_id) + itemWeight(data.item) * data.ammout) <= vRP.getWeight(user_id) then
            vRP.generateItem(user_id,data.item,data.ammout,true)

            TriggerClientEvent("inventory:Update", source,"updateMochila")

            clientAPI.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))

            GameController.sendEventPlayersLoot(GameId, "GetLootClient", { tabela = data.number, id = data.id })
        else
            TriggerClientEvent("Notify", source, "negado", "Inventário cheio.", 15000, "normal", "Admin")
        end
    else
        if (vRP.inventoryWeight(user_id) + itemWeight(data.item) * 1) <= vRP.getWeight(user_id) then
            vRP.generateItem(user_id,data.item,1,true)

            TriggerClientEvent("inventory:Update", source,"updateMochila")

            clientAPI.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))

            GameController.sendEventPlayersLoot(GameId, "GetLootClient", { tabela = data.number, id = data.id })
        else
            TriggerClientEvent("Notify", source, "negado", "Inventário cheio.", 15000, "normal", "Admin")
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RequestSpectator - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.RequestSpectator = function(data, status) 
    local Game = Games[Player(data.source).state.gameId]
    if Game == nil then return end
    local Players = {}
    local Kills = 0
    local PlayerKey = nil

    for playerId, player in pairs(Game.players) do
        if not Player(player.source).state.death and (Game.players[player.user_id] ~= nil) and GetPlayerRoutingBucket(player.source) == Game.routing then
            local identity = vRP.getIdentity(player.user_id)
            local plyKey = #Players + 1 -- getTableSize(Players)
            
            PlayerKey = plyKey

            Players[plyKey] = {
                source = player.source,
                user_id = player.user_id,
                username = identity.username,
                pos = plyKey,
            }
        end
    end

    if PlayerKey ~= nil and getTableSize(Players) > 0 then
        local Ped = GetPlayerPed(Players[PlayerKey].source)
        local Coords = GetEntityCoords(Ped)

		if status then
            GameController.sendPlayerEvent(data.source, "initSpectator", { 
                target = PlayerKey,
                players = Players,
                coords = vector3(Coords["x"],Coords["y"],Coords["z"]),
                endGame = true,
            })
		else
            GameController.sendPlayerEvent(data.source, "updateTableSpec", { 
				players = Players,
            })
		end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTargetServer - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.setSpectatorTargetServer = function(source, data) 
    local Game = Games[Player(source).state.gameId]

    if Game == nil then 
        return 
    end

    local Ped = GetPlayerPed(data.source_player)
    local Coords = GetEntityCoords(Ped)

    if Player(source).state.inSpec then
        GameController.sendPlayerEvent(source, "setSpectatorTarget", { 
            key = data.key,
            coords = vector3(Coords["x"],Coords["y"],Coords["z"])
        })
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RequestAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.RequestAgonizing = function(source, data)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    Player(source).state.agonizing = true
    
    GameController.sendPlayerEvent(source, "Agonizing", { 
        source = source,
        data = data
    })
end 
-----------------------------------------------------------------------------------------------------------------------------------------
-- ReviveAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.ReviveAgonizing = function(source, data)
    local Game = Games[Player(data.source).state.gameId]
    if Game == nil then return end
    local user_id = vRP.getUserId(data.source)

    if data.type == "Final" then
        Player(data.source).state.agonizing = false
        Player(data.source).state.death = false
    
        GameController.sendPlayerEvent(data.source, "StopAgonizing", { source = data.source })

        ApiController.ReviveAgonizing({ source = data.source })

        Kills[user_id] = nil
    elseif data.type == "Inicio" then
        Player(source).state.isReviving = true
        Reviving[source] = data.source
        ApiController.ReviveAgonizingStatus({ source = data.source, status = true })
        GameController.sendPlayerEvent(data.source, "ReviveAgonizingClient", { source = data.source, type = "Stop" })
    elseif data.type == "Adrenaline" then
        Player(data.source).state.agonizing = false
        Player(data.source).state.death = false
    
        GameController.sendPlayerEvent(data.source, "StopAgonizing", {  source = data.source })

        ApiController.ReviveAgonizing({ source = data.source })
        vRP.tryGetInventoryItem(user_id,'adrenaline',1,true,false)
        clientAPI.UpdateShortcuts(data.source, vRP.Shortcuts(data.source, user_id))

        Kills[user_id] = nil
    end
end 
-----------------------------------------------------------------------------------------------------------------------------------------
-- FinishAgonizing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
GameController.FinishAgonizingGame = function(source, data)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    local user_id = vRP.getUserId(source)

    Kills[user_id] = nil

    ApiController.FinishAgonizing({ source = source })
end 
-----------------------------------------------------------------------------------------------------------------------------------------
--  shuffle - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function shuffle(t)
    local n = #t
 
    while n > 2 do
        -- n is now the last pertinent index
        local k = math.random(n)
        -- Quick swap
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
 
    return t
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  getTableSize - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function getTableSize(t)
    local count = 0

    for _, __ in pairs(t) do
        count = count + 1
    end

    return count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- count - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function count(array)
	if type(array) ~= 'table' then return false end
  
	local count = 0
	for k, v in pairs(array) do
	  count = count + 1
	end
	return count
end  
-----------------------------------------------------------------------------------------------------------------------------------------
-- Game - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Game",function()
    return GameController
end)