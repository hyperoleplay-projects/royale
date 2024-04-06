-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
clientAPI = Tunnel.getInterface(GetCurrentResourceName())
UIApi = Tunnel.getInterface("ui")

SafeZoneAPI = Tunnel.getInterface("safezone")
local Games = {}
local RoutingBuckets = {}
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetFreeRoutingBucket - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetFreeRoutingBucket(startIndex, endIndex)
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
--  GetPlayersCountGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetPlayersCountGame(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    local PlayersCount = 0
    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source and not Player(playerInGame.source).state.death then
            PlayersCount = PlayersCount + 1
        end
    end

    return PlayersCount
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  createVehicle - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function createVehicleGame(gameId,model,x,y,z,heading,vehPlate,vehDoors,vehBody,single,stateName,routingBucket) 
    local Game = Games[gameId]
    if Game == nil then return end
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
            Wait(80)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  SetupLoots - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SetupLoots(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end
    local Coords = {}
    local CarsCoords = {}
    local Cars = {}
    local PickUps = {}
    local weapons = {}
    local index = 0
    Coords[gameId] = {}
    CarsCoords[gameId] = {}
    Cars[gameId] = {}
    PickUps[gameId] = {}

    local shuffledCoords = shuffle(Config.Maps[Game.map].Loots)

    for i = 1, 4400 do
        table.insert(Coords[gameId], shuffledCoords[i])
    end

    for i = 1, 64 do
        table.insert(CarsCoords[gameId], shuffledCoords[i])
    end
   
    for k, v in pairs(Coords[gameId]) do
        local loot = math.random(#Config.lootsCount)
        for ii = 1, Config.lootsCount [loot], 1 do
            weapons = {
                getRandomWeapon('favela'),
                getRandomWeapon('municoes'),
                getRandomWeapon('municoes2'),
                getRandomWeapon('municoes3'),
                getRandomWeapon('municoes4'),
                getRandomWeapon('municoes5'),
                getRandomWeapon('municoes6'),
            }
            index = tonumber(round(math.random())+1)

            table.insert(PickUps[gameId], {                            
                source = #PickUps[gameId]+1,
                name = weapons[index],
                x = v["x"]+(math.random(-8000,8000)/1000),
                y = v["y"]+(math.random(-8000,8000)/1000),
                z = v["z"],
                created = false,
                handle = nil,
                drop = false,
                ammout = false,
                coleted = false
            })
        end
    end

    for k, v in pairs(CarsCoords[gameId]) do
        table.insert(Cars[gameId], {
            model = Config.Cars[math.random(1, #Config.Cars)],
            x = v["x"],
            y = v["y"],
            z = v["z"]
        })
    end

    
    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source then
            SetPlayerRoutingBucket(playerInGame.source, Game.routing)
        end
    end

    Citizen.CreateThread(function()
        local dimension = Game.routing
        for key, coords in pairs(Cars[gameId]) do
            local vehPlate = "VEH"..parseInt(math.random(10000,99999))
            createVehicleGame(gameId, coords.model,coords.x,coords.y,coords.z, 280.0, vehPlate,nil,nil,nil,"Battle",dimension)
            Wait(1)
        end
    end)

    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source then
            Wait(80)
            clientAPI.SetupLoots(playerInGame.source, PickUps[gameId])
        end
    end

end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetupSafe - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SetupSafe(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source then
            Player(playerInGame.source).state.gameId = gameId
            TriggerClientEvent("SafeZone:StartEvent", playerInGame.source, 3, {
                safeZone = VectorToTable(vector3(Config.Maps[Game.map].center.x, Config.Maps[Game.map].center.y, 50.0)),
                radius = Config.Maps[Game.map].radius,
                Game = Game
            })
        end
    end
    
    TriggerEvent("battle-CreateSafe", Game, vector3(Config.Maps[Game.map].center.x, Config.Maps[Game.map].center.y, 50.0))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItems - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function DropInventoryItems(gameId, inventory, Coords)
    local Game = Games[gameId]
    if Game == nil then return end

    for _, player in pairs(Game.players) do
        for k,inventory in pairs(inventory) do 
            if itemDrop(inventory.item) then
                if player.source then
                    clientAPI.DropInventoryItem(player.source, {
                        name = inventory.item,
                        coords = vector3(Coords["x"]+(math.random(-8000,8000)/1000),Coords["y"]+(math.random(-8000,8000)/1000),Coords["z"]),
                        ammout = inventory.amount
                    })
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RequestSpectator - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function RequestSpectator(data, status) 
    local Game = Games[Player(data.source).state.gameId]
    if Game == nil then return end
    local Players = {}
    local Kills = 0
    local PlayerKey = nil

    for playerId, player in pairs(Game.players) do
        if not Player(player.source).state.death then
            local identity = vRP.getIdentity(player.user_id)
            local plyKey = getTableSize(Players)
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
			clientAPI.initSpectator(data.source, {
				target = PlayerKey,
				players = Players,
				coords = vector3(Coords["x"],Coords["y"],Coords["z"])
			})
		else
			clientAPI.updateTableSpec(data.source, {
				players = Players,
			})
		end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setSpectatorTarget - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.setSpectatorTarget(key, source_player) 
    local source = source
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    local Ped = GetPlayerPed(source_player)
    local Coords = GetEntityCoords(Ped)

    if Player(source).state.inSpec then
        clientAPI.setSpectatorTarget(source, key, vector3(Coords["x"],Coords["y"],Coords["z"]))
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendKillGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SendKillGame(gameId, killData)
    local Game = Games[gameId]
    if Game == nil then return end

    for _, player in pairs(Game.players) do
        if player.source and Player(player.source) then
            TriggerClientEvent("NotifyKill", player.source, killData)
        end
    end

    RegisterKilTeam(killData, GetPlayersCountGame(gameId), Game.Gamemode, gameId, Game.players)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DropInventoryItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.DropInventoryItem(Slot, Amount) 
    local source = source
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    local user_id = vRP.getUserId(source)
    local Slot = tostring(Slot)
    local Amount = parseInt(Amount)
    local Ped = GetPlayerPed(source)
    local Coords = GetEntityCoords(Ped)

    if Player(source).state.inGame then
        local inventory = vRP.userInventory(source, user_id)
        if not inventory[Slot] or inventory[Slot]["item"] == nil then
            return
        end

        if Amount == 0 then Amount = 1 end
        local Item = inventory[Slot]["item"]

        if itemDrop(Item) then

            if vRP.tryGetInventoryItem(user_id,Item,Amount,true,Slot) then
                TriggerClientEvent("inventory:Update", source,"updateMochila")

                for _, player in pairs(Game.players) do
                    if player.source then
                        clientAPI.DropInventoryItem(player.source, {
                            name = Item,
                            coords = vector3(Coords["x"],Coords["y"],Coords["z"]),
                            ammout = Amount
                        })
                    end
                end
            end

        else
            TriggerClientEvent("Notify", source, "negado", "Não é possível dropar este item.", 15000, "normal", "Admin")
        end
    end
    Wait(100)
    UIApi.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterKill - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.RegisterKill(data)
    local source = source 
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
	if not Player(source).state.inGame then return end

    if data.nsource == 0 then
        local identity = vRP.getIdentity(user_id)
        local inventory = vRP.userInventory(source, user_id) -- Pega os itens do inventario
        local Ped = GetPlayerPed(source)
        local Coords = GetEntityCoords(Ped)

        DropInventoryItems(Player(source).state.gameId, inventory, Coords)

        SendKillGame(Player(source).state.gameId, {
            headshot = false,
            weapon_killer = GetHashKey("WEAPON_PISTOL_MK2"),
            killer_name = "Morte",
            killer = "",
            victim_name = identity.username,
            victim = user_id,
            source = source,
            positionGame = GetPlayersCountGame(Player(source).state.gameId),
        })
    else
        local nuser_id = vRP.getUserId(data.nsource) 
        if nuser_id then 
            local identity = vRP.getIdentity(user_id)
            local inventory = vRP.userInventory(source, user_id) -- Pega os itens do inventario
            local Ped = GetPlayerPed(source)
            local Coords = GetEntityCoords(Ped)
            local identity_killer = vRP.getIdentity(nuser_id)
            local weapon = GetSelectedPedWeapon(GetPlayerPed(data.nsource))
            -- source && user_id = Quem morreu
            -- data.nsource && nuser_id = Quem matou

            if weapon and weapon ~= -1569615261 and identity then
                DropInventoryItems(Player(data.nsource).state.gameId, inventory, Coords)
                Player(data.nsource).state.kills = Player(data.nsource).state.kills + 1

                SendKillGame(Player(data.nsource).state.gameId, {
                    headshot = data.hs,
                    weapon_killer = weapon,
                    killer_name = identity_killer.username,
                    killer = nuser_id,
                    victim_name = identity.username,
                    victim = user_id,
                    source = source,
                    positionGame = GetPlayersCountGame(Player(data.nsource).state.gameId),
                })
            end
        end
    end

    checkEndGame(source, Player(source).state.gameId)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- IsPlayerInGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function IsPlayerInGame(gameId, playerSource)
    local Game = Games[gameId]
    if Game == nil then return end

    for _, playerInGame in pairs(Game.players) do
        if playerInGame.source == playerSource then
            return true
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StartGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function StartGame(gameId) 
    local Game = Games[gameId]
    local count = 65
    local startTime = GetGameTimer() / 1000
    if Game == nil then return end

    if not Game.started then
        Games[gameId].started = true
        SetupLoots(gameId)
        for _, playerInGame in pairs(Game.players) do 
            if playerInGame.source and Player(playerInGame.source) then
                Player(playerInGame.source).state.inGame = true
                Player(playerInGame.source).state.inDashboard = false
                -- clientAPI.CloseLobby(playerInGame.source)
                TriggerClientEvent("CloseLobby", playerInGame.source)
                Player(playerInGame.source).state.inQueue = false
                Player(playerInGame.source).state.PlaneStatus = false
                Player(playerInGame.source).state.Compass = true
                Player(playerInGame.source).state.Buttons = true
                Player(playerInGame.source).state.inLobbyPrincipal = false
                -- clientAPI.ExitLobbyGame(playerInGame.source)
                TriggerClientEvent("ExitLobbyGame", playerInGame.source)

                if Player(playerInGame.source).state.inAimLab then
                    -- clientAPI.ExitAimLab(playerInGame.source)
                    TriggerClientEvent("ExitAimLab", playerInGame.source)
                end
                Player(playerInGame.source).state.inAimLab = false
                vRP.clearInventory(playerInGame.user_id)
                TriggerClientEvent("killGod", playerInGame.source)
                -- clientAPI.killGod(playerInGame.source)
                vRPC.setHealth(playerInGame.source,400)
                Player(playerInGame.source).state.inGameLobby = false
                Player(playerInGame.source).state.inSpec = false
                SetPlayerRoutingBucket(playerInGame.source, 100+playerInGame.user_id)
                TriggerClientEvent("StartPlane", playerInGame.source, Game.map, Game.planePos)
                -- clientAPI.StartPlane(playerInGame.source, Game.map, Game.planePos)
                TriggerClientEvent("Compass", playerInGame.source, true)
                Wait(20)
                TriggerClientEvent("showHud", playerInGame.source)
                TriggerClientEvent("BuildUI", playerInGame.source, "DuthMindlle", { status = true })
                TriggerClientEvent("duth:ChatStatus", playerInGame.source, true)
                Player(playerInGame.source).state.Buttons = false
                Player(playerInGame.source).state.inPlane = true
    
                UIApi.UpdateShortcuts(playerInGame.source, vRP.Shortcuts(playerInGame.source, playerInGame.user_id))

                SetTimeout(60000, function()
                    if playerInGame.source then
                        Player(playerInGame.source).state.PlaneStatus = true
                        clientAPI.StopPlane(playerInGame.source)
                    end
                end)
                
                clientAPI.BuildGame(playerInGame.source, {
                    status = true,
                    players = GetPlayersCountGame(gameId),
                    rich = true,
                })     

            end
        end

                        
        SetTimeout(1000, function()
            SetupSafe(gameId)
        end)

        print("^2[ PARTIDAS ]^7 Partida: "..gameId.." iniciada, com: "..GetPlayersCountGame(gameId).." jogadores, com o tipo: "..Game.gameType.."")
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  FinishGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function FinishGame(gameId) 
    local Game = Games[gameId]
    if Game == nil then return end

    if Game.finished then
        for _, playerInGame in pairs(Game.players) do

            if playerInGame.source then
                if Player(playerInGame.source).state.inGame then
                    -- Verifica se o jogador está no modo spectador, se estiver retira.
                    if Player(playerInGame.source).state.inSpec then
                        clientAPI.stopSpectatorMode(playerInGame.source)
                        Player(playerInGame.source).state.inSpec = false
                    end

                    TriggerEvent("inventory:StopInventory", playerInGame.user_id)

                    if playerInGame.source and Player(playerInGame.source) then
                        -- Verifica se o jogador está o menu de finalização ainda aberto, se sim fecha ele.
                        if Player(playerInGame.source).state.finishGameUI then
                            uiApi.SetNuiFocus(playerInGame.source, false)
                            uiApi.FinishUiGame(playerInGame.source, false)
        
                            uiApi.BuildUI(playerInGame.source, "FinishGame", {
                                open = false,
                                setRank = false,
                            })
    
                            Player(playerInGame.source).state.finishGameUI = false
                        end
        
                        TriggerClientEvent("favela-core:killPlayer", playerInGame.source) -- Da god no jogador.
                        FinishTeam(playerInGame.source) -- Finaliza as informações do grupo.
                    end
    
                    -- Retira o jogador da partida.
                    LeaveGame({
                        source = playerInGame.source,
                        user_id = playerInGame.user_id,
                    }, gameId)
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  endGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.endGame() 
    local source = source
    local user_id = vRP.getUserId(source)
    if Player(source).state.inGame then
        -- Verifica se o jogador está no modo spectador, se estiver retira.
        if Player(source).state.inSpec then
            clientAPI.stopSpectatorMode(source)
            Player(source).state.inSpec = false
        end
        vRP.updateIdentity(user_id)

        if source and Player(source) then
            -- Verifica se o jogador está o menu de finalização ainda aberto, se sim fecha ele.
            if Player(source).state.finishGameUI then
                uiApi.SetNuiFocus(source, false)
                uiApi.FinishUiGame(source, false)
    
                uiApi.BuildUI(source, "FinishGame", {
                    open = false,
                    setRank = false,
                })
                Player(source).state.finishGameUI = false
            end
            
    
            TriggerClientEvent("favela-core:killPlayer", source) -- Da god no jogador.
            FinishTeam(source) -- Finaliza as informações do grupo.
        end

        TriggerEvent("inventory:StopInventory", user_id)

        -- Retira o jogador da partida.
        LeaveGame({
            source = source,
            user_id = user_id,
        }, Player(source).state.gameId)

        if Player(source).state.duthBattleXp == nil or Player(source).state.duthBattleXp < 1500 then
            local battleXp = math.random(0, 120)
            local newBattleXp = (Player(source).state.duthBattleXp or 0) + battleXp
            if newBattleXp > 1500 then
                newBattleXp = 1500
            end
            Player(source).state.duthBattleXp = newBattleXp
            clientAPI.UpdateBattlePass(source)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  checkEndGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function checkEndGame(source, gameId)
    local game = Games[gameId]
    if game == nil then return end
    local myTeam = Player(source).state.teamCode
    local myTeamAlive = 0
    local otherTeamsAlive = {}
    local lastPlayerTeam = nil
    local totalPlayers = GetPlayersCountGame(game.gameId)
  
    -- Verificar o status dos jogadores no jogo
    for _, playerInGame in pairs(game.players) do
      local player = Player(playerInGame.source)
      if not player.state.death then
        if playerInGame.team == myTeam then
          myTeamAlive = myTeamAlive + 1
        else
          otherTeamsAlive[playerInGame.team] = (otherTeamsAlive[playerInGame.team] or 0) + 1
        end
        lastPlayerTeam = playerInGame.team
      end
    end
  
    -- Verificar as condições de encerramento do jogo
    if totalPlayers == 1 then
      game.finished = true
      print("^2[ PARTIDAS ]^7 Partida: "..game.gameId.." finalizada com o ganhador: "..lastPlayerTeam.."")
      OpenUIFinishMatch(lastPlayerTeam, "winner", false)
    --   FinishGame(game.gameId)
      return
    end
  
    if myTeamAlive == totalPlayers then
      game.finished = true
      print("^2[ PARTIDAS ]^7 Partida: "..game.gameId.." finalizada com o ganhador: "..myTeam.."")
      OpenUIFinishMatch(myTeam, "winner", false)
    --   FinishGame(game.gameId)
      return
    end
  
    local otherTeamsAliveCount = next(otherTeamsAlive) and 1 or 0
  
    if otherTeamsAliveCount == 0 and myTeamAlive > 0 then
      game.finished = true
      print("^2[ PARTIDAS ]^7 Partida: "..game.gameId.." finalizada com o ganhador: "..myTeam.."")
      OpenUIFinishMatch(myTeam, "winner", false)
    --   FinishGame(game.gameId)
      return
    end
  
    if otherTeamsAliveCount == 0 and myTeamAlive == 0 then
      game.finished = true
      print("^2[ PARTIDAS ]^7 Partida: "..game.gameId.." finalizada empatada")
      return
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetGamesForType - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetGamesForType(gameType) 
    local matchingGameId = 0

    for k,v in pairs(Games) do 
        if v.gameType == gameType and GetPlayersCountGame(v.gameId) < v.maxPlayers and not v.started and not v.finished then
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
--  RandomMap - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function RandomMap()
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
--  HostGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function HostGame(gameType)
    local routingBucket = GetFreeRoutingBucket()
    if routingBucket then
        local gameId = #Games + 1
        
        if not Games[gameId] then
            local game = {
                gameId = gameId,
                routing = routingBucket,
                map = RandomMap() or "Cidade",
                -- map = "Cidade",
                players = {},
                playersGameCount = 0,
                maxPlayers = 64,
                MinPlayers = Config.MinPlayers,
                started = false,
                finished = false,
                Gamemode = gameMode or "ranked",
                gameType = gameType or "default",
                planePos = nil,
                status = 0,
                Lobby = {
                    routing = GetFreeRoutingBucket()
                },
                Loots = {}
            }

            Games[gameId] = game
            Games[gameId].planePos = Config.Maps[Games[gameId].map].center - GenerateCenterPoint(Config.Maps[Games[gameId].map].radius or 3000.0, true)

            print("^2[ PARTIDAS ]^7 Partida: "..gameId.." criada com o tipo: "..gameType.."")
            return game
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  SetPlayersGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SetPlayersGame(gamId, players) 
    local Game = Games[gamId]
    if Game == nil then return end
    Game.MinPlayers = parseInt(players)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  JoinGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function JoinGame(gameId, playerData)
    local Game = Games[gameId]
    if Game == nil then return end

    for _, player in ipairs(Game.players) do
        if player.source == playerData.source then
            return
        end
    end
    table.insert(Game.players, playerData)
    SetPlayerRoutingBucket(playerData.source, Game.routing)

    if Player(playerData.source).state.inQueue then
        for _, playerInGame in pairs(Game.players) do 
            if playerInGame.source then
                clientAPI.setLabelNUI(playerInGame.source, true, "Na fila", ""..#Game.players.."/"..Game.MinPlayers.."...")
            end
        end

        Wait(500)
        if #Game.players >= Game.MinPlayers and not Game.started and not Game.finished then
            StartGame(Game.gameId)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  startGame - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("StartGame", function(source, args, rawCmd) 
    local source = source
    local user_id = vRP.getUserId(source)
    local Game = Games[parseInt(args[1])]
    if Game == nil then return end
    StartGame(parseInt(args[1]))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  playerDropped - Function
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end
    local oldGameId = 0

    if Player(source).state.inQueue or Player(source).state.inGame or Player(source).state.inGameLobby then
        local identity = vRP.getIdentity(user_id)
        if Game.started then
            for k,v in pairs(Games[Player(source).state.gameId].players) do 
                if v.source and not Player(v.source).state.death and not Player(v.source).state.inDashboard and not Player(v.source).state.finishGameUI then
                    TriggerClientEvent("NotifyKill", v.source,
                    { 
                        headshot = hs,
                        weapon_killer = GetHashKey("WEAPON_PISTOL_MK2"),
                        killer_name = "disconnect",
                        killer = "",
                        victim_name = identity.username,
                        victim = user_id,
                    })

                end
            end
            oldGameId = Player(source).state.gameId
        end

        LeaveGame({
            source = source,
            user_id = user_id
        }, Player(source).state.gameId)
        Wait(1000)
        checkEndGame(source, oldGameId)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  LeaveGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function LeaveGame(playerData, gameId) 
    if Games[gameId] == nil then return end

	for k, v in pairs(Games[gameId].players) do
        if v.source == playerData.source then 
            -- Seta as informações do jogador como padrões
            Player(v.source).state.gameId = 0
            Player(v.source).state.inQueue = false
            Player(v.source).state.inGame = false

            -- Verifica se o jogador não está morto e se a partida não foi finalizada, se não for os dois seta ele como morto
            if not Player(v.source).state.death and not Games[gameId].finished then
                Player(v.source).state.death = true
            end

            -- Seta o jogador como false na tabela
            v.state = false
	        v.source = nil

            -- Remove o jogador da tabela da partida
            table.remove(Games[gameId].players, k)
	    end
        
	end

    Wait(80)
    for k, v in pairs(Games[gameId].players) do
        if v.source and not Player(v.source).state.inDashboard and not Player(v.source).state.finishGameUI then
            clientAPI.BuildGame(v.source, {
                status = true,
                players = GetPlayersCountGame(gameId),
                rich = true,
            })
        end
    end

    -- Atualiza os jogadores da safe
    TriggerEvent("battle-UpdatePlayersSafe", Games[gameId])

    -- Verifica se o jogador está online, se sim coloca ele no lobby principal
    if playerData.source then
        if not Player(playerData.source).state.inDashboard then
            Player(playerData.source).state.Loots = {}
            SafeZoneAPI.StopSafezone(playerData.source)
            clientAPI.StopLoots(playerData.source)
    
            if not Player(playerData.source).state.PlaneStatus then
                clientAPI.StopPlane(playerData.source)
                Player(playerData.source).state.PlaneStatus = true
            end
    
            clientAPI.BuildGame(playerData.source, {
                status = false,
                rich = false,
            })

            JoinLobby(playerData.source)
        end

        clientAPI.setLabelNUI(playerData.source, false, "a")
    end

    local Game = Games[gameId]
    Wait(500)
    for _, playerInGame in pairs(Game.players) do 
        if playerInGame.source then
            clientAPI.setLabelNUI(playerInGame.source, true, "Na fila", ""..#Game.players.."/"..Game.MinPlayers.."...")
        end
    end
    
    if #Game.players >= Game.MinPlayers and not Game.started and not Game.finished then
        StartGame(Game.gameId)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  ExitPlaneDimension - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.ExitPlaneDimension() 
    local source = source
    local user_id = vRP.getUserId(source)
    local Game = Games[Player(source).state.gameId]
    if Game == nil then return end

    SetPlayerRoutingBucket(source, Games[Player(source).state.gameId].routing)
    vRP.generateItem(user_id, "WEAPON_KNIFE",parseInt(1),false, 5)
    UIApi.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  GetLoot - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.GetLoot(number, item, drop, ammoutReceived) 
    local source = source
    local user_id = vRP.getUserId(source)
    local GameId = Player(source).state.gameId
    local Game = Games[GameId]
    if Game == nil then return end

    local ammoCounts = {
        ["AMMO_PISTOL"] = {min=20, max=250},
        ["AMMO_RIFLE"] = {min=30, max=250},
        ["AMMO_SMG"] = {min=40, max=250},
        ["AMMO_SHOTGUN"] = {min=10, max=250},
    }

    if drop and ammoutReceived > 0 then
        if (vRP.inventoryWeight(user_id) + itemWeight(item) * ammoutReceived) <= vRP.getWeight(user_id) then
            for _, playerInGame in pairs(Game.players) do 
                if playerInGame.source then
                    clientAPI.GetLoot(playerInGame.source, number)
                end
            end
            vRP.generateItem(user_id,item,ammoutReceived,true)
            TriggerClientEvent("inventory:Update", source,"updateMochila")
            UIApi.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
            return 
        else
            return TriggerClientEvent("Notify", source, "negado", "Inventário cheio.", 15000, "normal", "Admin")
        end
    else
        if ammoCounts[item] then
            local ammout = math.random(ammoCounts[item].min, ammoCounts[item].max)
            if (vRP.inventoryWeight(user_id) + itemWeight(item) * ammout) <= vRP.getWeight(user_id) then
                for _, playerInGame in pairs(Game.players) do 
                    if playerInGame.source then
                        clientAPI.GetLoot(playerInGame.source, number)
                    end
                end
                vRP.generateItem(user_id,item,ammout,true)
                TriggerClientEvent("inventory:Update", source,"updateMochila")
                UIApi.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
                return 
            else
                return TriggerClientEvent("Notify", source, "negado", "Inventário cheio.", 15000, "normal", "Admin")
            end
        else
            if (vRP.inventoryWeight(user_id) + itemWeight(item) * 1) <= vRP.getWeight(user_id) then
                for _, playerInGame in pairs(Game.players) do 
                    if playerInGame.source then
                        clientAPI.GetLoot(playerInGame.source, number)
                    end
                end
                vRP.generateItem(user_id,item,1,true)
                TriggerClientEvent("inventory:Update", source,"updateMochila")
                UIApi.UpdateShortcuts(source, vRP.Shortcuts(source, user_id))
                return 
            else
                return TriggerClientEvent("Notify", source, "negado", "Inventário cheio.", 15000, "normal", "Admin")
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getRandomWeapon - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function getRandomWeapon(type)
	if Config.weapons[type] == nil then return false end
  
	local nbWeapons = count(Config.weapons[type])
	local randWeaponIndex = math.random(nbWeapons)
	return Config.weapons[type][randWeaponIndex]
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