-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController = {}
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
clientAPI = Tunnel.getInterface(GetCurrentResourceName())
SafeZoneAPI = Tunnel.getInterface("safezone")

-----------------------------------------------------------------------------------------------------------------------------------------
--  sendPlayerEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.sendPlayerEvent = function(src, eventName, eventData)
    TriggerClientEvent('events_controllerApi', src, {
        event = eventName,
        data = eventData
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  playerGroupList - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.playerGroupList = function(source)
    local Group = Groups[Player(source).state.teamCode]
    if Group == nil then
        return
    end

    for playerId,playerData in pairs(Group.players) do
		local Ped = GetPlayerPed(playerData.source)
        
		if DoesEntityExist(Ped) then
			playerData["Coords"] = GetEntityCoords(Ped)
		end

        Wait(5)
	end

    ApiController.sendPlayerEvent(source, "UpdateBlips", { players = Group.players })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendEventPlayersEvent - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.sendEventPlayersEvent = function(teamCode, eventName, eventData)
    local Group = Groups[teamCode]
    if Group == nil then
        return
    end
    
    for playerId, playerr in pairs(Groups[teamCode].players) do
        TriggerClientEvent('events_controllerApi', playerr.source, {
            event = eventName,
            data = eventData
        })
        Wait(5)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  sendEventPlayersEventNotGame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.sendEventPlayersEventNotGame = function(teamCode, eventName, eventData)
    local Group = Groups[teamCode]
    if Group == nil then
        return
    end
    
    for playerId, playerr in pairs(Groups[teamCode].players) do
        if not Player(playerr.source).state.inGame then 
            TriggerClientEvent('events_controllerApi', playerr.source, {
                event = eventName,
                data = eventData
            })
        end
        Wait(1)
	end
end
-----------------------------------------------------------------------------------------
-- extractSteam - Funciton
-----------------------------------------------------------------------------------------
ApiController.extractSteam = function(src)
    local identifiers = {
        steam = "",
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id,"steam") then
            identifiers.steam = id
        end
    end
    return identifiers
end
-----------------------------------------------------------------------------------------
-- GenerateRandomNumber - Funciton
-----------------------------------------------------------------------------------------
ApiController.GenerateRandomNumber = function()
    math.randomseed(GetGameTimer())
    local random = math.random(1, 80000)
    return random
end
-----------------------------------------------------------------------------------------
-- GetUserNamehasLeader - Funciton
-----------------------------------------------------------------------------------------
ApiController.GetUserNamehasLeader = function(teamCode)
    if Groups[teamCode] == nil then
        return false
    else
        for k,v in pairs(Groups[teamCode].players) do
            if v.isLeader then 
                return v.username
            end
        end
    end
end
-----------------------------------------------------------------------------------------
-- JumpPlayersFollowing - Funciton
-----------------------------------------------------------------------------------------
ApiController.JumpPlayersFollowing = function(teamCode) 
	if Groups[teamCode] == nil then return end
    for k,v in pairs(Groups[teamCode].players) do
        if Player(v.source).state.IsFollowingTeam and Player(v.source).state.inPlane then
            TriggerClientEvent('events_controllerApi', v.source, {
                event = "JumpPlayerFolloWing",
                data = {}
            })
        end

        Wait(1)
    end
end

-----------------------------------------------------------------------------------------
-- ReviveAgonizing - Funciton
-----------------------------------------------------------------------------------------
ApiController.ReviveAgonizing = function(data) 
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]
    local user_id = vRP.getUserId(data.source)

    Groups[Player(data.source).state.teamCode].players[user_id].agonizing = false
    Groups[Player(data.source).state.teamCode].players[user_id].isReviving = false
    Player(data.source).state.agonizing = false

    ApiController.sendEventPlayersEvent(Player(data.source).state.teamCode, "BuildGroup", { tabela = Groups[Player(data.source).state.teamCode], status = true })
end
-----------------------------------------------------------------------------------------
-- ReviveAgonizingStatus - Funciton
-----------------------------------------------------------------------------------------
ApiController.ReviveAgonizingStatus = function(data) 
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]
    local user_id = vRP.getUserId(data.source)

    Groups[Player(data.source).state.teamCode].players[user_id].isReviving = data.status
    
    ApiController.sendEventPlayersEvent(Player(data.source).state.teamCode, "BuildGroup", { tabela = Groups[Player(data.source).state.teamCode], status = true })
end
-----------------------------------------------------------------------------------------
-- ReviveAgonizing - Funciton
-----------------------------------------------------------------------------------------
ApiController.FinishAgonizing = function(data) 
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]
    local user_id = vRP.getUserId(data.source)

    Groups[Player(data.source).state.teamCode].players[user_id].agonizing = true
    Groups[Player(data.source).state.teamCode].players[user_id].isReviving = true
    Player(data.source).state.agonizing = true
    Groups[Player(data.source).state.teamCode].players[user_id].death = true
    Player(data.source).state.death = true

    ApiController.sendEventPlayersEvent(Player(data.source).state.teamCode, "BuildGroup", { tabela = Groups[Player(data.source).state.teamCode], status = true })
end
-----------------------------------------------------------------------------------------
-- RequestSpectatorTeam - Funciton
-----------------------------------------------------------------------------------------
ApiController.RequestSpectatorTeam = function(data, status)
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]

    local Players = {}
    local Kills = 0
    local PlayerKey = nil

    for playerId, player in pairs(Group.players) do
        if not Player(player.source).state.death then
            local identity = vRP.getIdentity(player.user_id)
            local plyKey = getTableSize(Players)
			PlayerKey = plyKey

            Players[plyKey] = {
                source = player.source,
                user_id = player.user_id,
                username = identity.username,
                avatar = player.avatar,
                pos = plyKey,
            }
        end
        Wait(1)
    end

    if PlayerKey ~= nil and getTableSize(Players) > 0 then
        local Ped = GetPlayerPed(Players[PlayerKey].source)
        local Coords = GetEntityCoords(Ped)

		if status then
            GameController.sendPlayerEvent(data.source, "initSpectator", { 
                target = PlayerKey,
                players = Players,
                coords = vector3(Coords["x"],Coords["y"],Coords["z"]),
                endGame = false,
            })
		else
            GameController.sendPlayerEvent(data.source, "updateTableSpec", { 
				players = Players,
            })
		end
    end
end
-----------------------------------------------------------------------------------------
-- GetPlayerPosition - Funciton
-----------------------------------------------------------------------------------------
ApiController.GetPlayerPosition = function(source) 
	if Groups[Player(source).state.teamCode] == nil then return end
	local Group = Groups[Player(source).state.teamCode]
    local user_id = vRP.getUserId(source)

    for k,v in pairs(Group.players) do
		if v.user_id == user_id then
            return Player(v.source).state.positionGame
		end
	end

    return 64
end
-----------------------------------------------------------------------------------------
-- GetPlayerPositionGroup - Funciton
-----------------------------------------------------------------------------------------
ApiController.GetPlayerPositionGroup = function(source) 
	if Groups[Player(source).state.teamCode] == nil then return end
	local Group = Groups[Player(source).state.teamCode]
    local user_id = vRP.getUserId(source)

    for k,v in pairs(Group.players) do
		if v.user_id == user_id then
            return v.pos
		end
	end

    return 1
end
-----------------------------------------------------------------------------------------
-- SetPlayerPosition - Funciton
-----------------------------------------------------------------------------------------
ApiController.SetPlayerPosition = function(source, postion) 
	if Groups[Player(source).state.teamCode] == nil then return end
	local Group = Groups[Player(source).state.teamCode]
    local user_id = vRP.getUserId(source)

    for k,v in pairs(Group.players) do
		if v.user_id == user_id then
            Player(v.source).state.positionGame = postion
            v.positionGame = postion
		end
	end
end
-----------------------------------------------------------------------------------------
-- OpenWinner - Funciton
-----------------------------------------------------------------------------------------
ApiController.OpenWinner = function(data) 
    if Groups[data.code] == nil then return end
	local Group = Groups[data.code]
    local source = 0
    
    for k,v in pairs(Group.players) do
        if v.source and v.state and Player(v.source) then
            source = v.source
            ApiController.SetPlayerPosition(v.source, 1)

            if Player(v.source).state.inSpec then
                clientAPI.stopSpectatorMode(v.source)

                Player(v.source).state.inSpec = false
            end

            ApiController.sendPlayerEvent(v.source, "CheckOut", { 
                status = true,
                type = "Win",
                pos = 1,
                maxPlayers = GameController.GetMaxPlayersGame(data.gameId),
            })

            SetPlayerRoutingBucket(v.source, v.user_id+1)

            Player(v.source).state.typeCheckOut = "Win"
            Player(v.source).state.finishGameUI = true
        end
        Wait(1)
	end
end
-----------------------------------------------------------------------------------------
-- RegisterKillGame - Funciton
-----------------------------------------------------------------------------------------
ApiController.RegisterKillGame = function(data) 
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]
    local user_id = vRP.getUserId(data.source)
    local allPlayersDead = true 

    for k,v in pairs(Group.players) do
		if v.user_id == user_id then
			v.death = true
			v.positionGame = data.positionGame
            Player(v.source).state.positionGame = data.positionGame
			Player(v.source).state.death = true
		end
	end

    if data.gameType == "duo" or data.gameType == "squad" then
		for k,v in pairs(Group.players) do
			if v.source ~= data.source and not v.death and not v.agonizing then
				allPlayersDead = false
			end
            Wait(1)
		end

        if allPlayersDead then
			Group.position = data.positionGame
            
            -- Finaliza todos os jogadores de uma vez
            if Group.playersCount > 1 then
                GameController.FinishAllPlayers(data.source, Group.players)
            end

			for k,v in pairs(Group.players) do
				if v.source and v.state and Player(v.source) then
                    ApiController.SetPlayerPosition(v.source, data.positionGame)

                    if Player(v.source).state.inSpec then
						clientAPI.stopSpectatorMode(v.source)

						Player(v.source).state.inSpec = false
					end

                    ApiController.sendPlayerEvent(v.source, "CheckOut", { 
                        status = true,
                        type = "Lose",
                        pos = data.positionGame,
                        maxPlayers = GameController.GetMaxPlayersGame(data.gameId),
                    })

                    SetPlayerRoutingBucket(v.source, v.user_id+1)
                    Player(v.source).state.typeCheckOut = "Lose"
                    Player(v.source).state.finishGameUI = true
				end
                Wait(1)
			end
		end
	end

    if Group.playersCount > 1 and not allPlayersDead then
        if GameController.GetPlayersCountGame(data.gameId) > 1 then
            Player(data.source).state.inSpec = true
            ApiController.RequestSpectatorTeam(data, true)
        end
        -- Atualiza a tabela do spec
        -- for _,player in pairs(Group.players) do
        --     if Player(player.source).state.inSpec then
        --         ApiController.RequestSpectatorTeam({ source = player.source }, false)
        --     end
        --     Wait(1)
        -- end
    elseif allPlayersDead and data.gameType == "solo" then
		if Player(data.source).state.death then
            if GameController.GetPlayersCountGame(data.gameId) > 1 then
                Player(data.source).state.inSpec = true

                GameController.RequestSpectator(data, true)
            else
                if Player(data.source).state.inSpec then
                    clientAPI.stopSpectatorMode(data.source)

                    Player(data.source).state.inSpec = false
                end
    
                ApiController.sendPlayerEvent(data.source, "CheckOut", { 
                    status = true,
                    type = "Lose",
                    pos = ApiController.GetPlayerPosition(data.source),
                    maxPlayers = GameController.GetMaxPlayersGame(data.gameId),
                })
    
                SetPlayerRoutingBucket(data.source, user_id+1)

                Player(data.source).state.typeCheckOut = "Lose"
                Player(data.source).state.finishGameUI = true
            end
		end
    end
end
-----------------------------------------------------------------------------------------
-- VerifyKillTeam - Funciton
-----------------------------------------------------------------------------------------
ApiController.VerifyKillTeam = function(data, playersGameCount, Gamemode, gameId, Players, gameType)
	local allPlayersDead = true 
	if Groups[Player(data.source).state.teamCode] == nil then return end
	local Group = Groups[Player(data.source).state.teamCode]
	local user_id = vRP.getUserId(data.source)
    local PlayerData = {}

	if gameType == "duo" or gameType == "squad" then
		for k,v in pairs(Group.players) do
			if v.source ~= data.source and not v.death and not v.agonizing then
				allPlayersDead = false
			end
            Wait(1)
		end
	end

	if Group.playersCount > 1 and not allPlayersDead then
        if not Groups[Player(data.source).state.teamCode].players[user_id].agonizing then
            Groups[Player(data.source).state.teamCode].players[user_id].agonizing = true

            Player(data.source).state.agonizing = true

            ApiController.sendEventPlayersEvent(Player(data.source).state.teamCode, "BuildGroup", { tabela = Groups[Player(data.source).state.teamCode], status = true })
            
            local item = vRP.GetItem(user_id, 'adrenaline')
            GameController.RequestAgonizing(data.source, { adrenaline = item })

            PlayerData = {
                agonizing = true,
                data = data
            }
        else
            PlayerData = {
                agonizing = false,
                data = data
            }
        end
	elseif allPlayersDead then
        PlayerData = {
            agonizing = false,
            data = data
        }
	end

    return PlayerData
end

RegisterCommand("sairgg", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
    removePlayerOfGroup({
        source = source,
        user_id = user_id,
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--  playerDropped - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function()
	local src = source
    local user_id = vRP.getUserId(src)

    if user_id then
        removePlayerOfGroup({
            source = src,
            user_id = user_id
        })
    end
end)
-----------------------------------------------------------------------------------------
-- GetPlayersReady - Funciton
-----------------------------------------------------------------------------------------
ApiController.GetPlayersReady = function(teamCode)
    if Groups[teamCode] == nil then return end

    local allPlayersReady = true
    for k,v in pairs(Groups[teamCode].players) do
        if not Player(v.source).state.ready then
            allPlayersReady = false
        end
    end

    return allPlayersReady
end
-----------------------------------------------------------------------------------------
-- SetReadyTeam - Funciton
-----------------------------------------------------------------------------------------
ApiController.SetReadyTeam = function(user_id, teamCode) 
	if Groups[teamCode] == nil then return end
    for k,v in pairs(Groups[teamCode].players) do
        if v.user_id == user_id then
            if v.ready then 
				v.ready = false
				Player(v.source).state.ready = false
            else
				v.ready = true
				Player(v.source).state.ready = true
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  SetLocationMarkerServer - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.RemoveLocationMarkerServer = function(source, data) 
    local user_id = vRP.getUserId(source)
    local identity = vRP.getIdentity(user_id)
    local Group = Groups[Player(source).state.teamCode]
    if Group == nil then return end

    ApiController.sendEventPlayersEvent(Player(source).state.teamCode, "RemoveLocationMarker", { id = data.id })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  SetLocationMarkerServer - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.SetLocationMarkerServer = function(source, data) 
    local user_id = vRP.getUserId(source)
    local identity = vRP.getIdentity(user_id)
    local Group = Groups[Player(source).state.teamCode]
    if Group == nil then return end

    data.r = Config.ColorsTeam[ApiController.GetPlayerPositionGroup(source)].r
    data.g = Config.ColorsTeam[ApiController.GetPlayerPositionGroup(source)].g
    data.b = Config.ColorsTeam[ApiController.GetPlayerPositionGroup(source)].b
    ApiController.sendEventPlayersEvent(Player(source).state.teamCode, "SetLocationMarker", { location = data })
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  loadUserData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.loadUserData = function(source) 
    local user_id = vRP.getUserId(source)
	local identity = vRP.getIdentity(user_id)
    
    -- States
    Player(source).state.inDashboard = true -- Alterado para true
    Player(source).state.inAimLab = false
    Player(source).state.inQueue = false
    Player(source).state.inGame = false
    Player(source).state.inGameLobby = false
    Player(source).state.inPlane = false
    Player(source).state.user_id = user_id
    Player(source).state.death = false
    Player(source).state.inTeam = false
    Player(source).state.inTeamNoLeader = false
    Player(source).state.finishGameUI = false

    Player(source).state.agonizing = false
    Player(source).state.Compass = false
    Player(source).state.gameId = 0
    Player(source).state.kills = 0
    Player(source).state.ChatCooldown = 0
    Player(source).state.inSpec = false
    Player(source).state.pointsGame = 0
    Player(source).state.userClothes = nil
    Player(source).state.userTatuagens = nil
    Player(source).state.userBarbearia = nil
    Player(source).state.userSkins = nil
    Player(source).state.isReviving = false
    
    SetPlayerRoutingBucket(source, user_id+1)

    Player(source).state.inLobbyPrincipal = false -- Alterado para false
    
    ApiController.sendPlayerEvent(source, "setDiscordRich", {
        title = "HYPE",
        description = "#"..user_id.." "..identity.username.."",
    })
    
    ApiController.sendPlayerEvent(source, "JoinLobby", {})

    createInitialGroupToUser(source, user_id)

    -- Setup player

    Group.load(user_id, source)

    DiscordSync.addGroupBasedRole(user_id, source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  ExitLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.ExitLobby = function(source) 
	local user_id = vRP.getUserId(source)
	Player(source).state.inDashboard = true
	Player(source).state.inLobbyPrincipal = false
	SetPlayerRoutingBucket(source, user_id+1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  JoinLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.JoinLobby = function(source) 
	local user_id = vRP.getUserId(source)
    
	Player(source).state.inDashboard = false
	Player(source).state.inAimLab = false
	Player(source).state.inLobbyPrincipal = true
    Player(source).state.inDashboard = false
    Player(source).state.inAimLab = false
    Player(source).state.inQueue = false
    Player(source).state.inGame = false
    Player(source).state.inGameLobby = false
    Player(source).state.inPlane = false
    Player(source).state.user_id = user_id
    Player(source).state.death = false
    Player(source).state.inTeam = false
    Player(source).state.inTeamNoLeader = false

    Player(source).state.agonizing = false
    Player(source).state.Compass = false
    Player(source).state.gameId = 0
    Player(source).state.kills = 0
    Player(source).state.ChatCooldown = 0
    Player(source).state.inSpec = false
    Player(source).state.pointsGame = 0
    Player(source).state.typeCheckOut = "Lose"
    Player(source).state.finishGameUI = false
    Player(source).state.isReviving = false
    
    ApiController.sendPlayerEvent(source, "setDiscordRich", {
        title = "HYPE",
        description = "No lobby",
    })

    ApiController.sendPlayerEvent(source, "JoinLobby", {})
end
-----------------------------------------------------------------------------------------------------------------------------------------
--  Play - Function
-----------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand('game-play', function(source)
    local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

    TriggerClientEvent('test:startGameForced', -1)
end)

RegisterNetEvent('test:startGameForced', function(data)
    local source = source
    local user_id = vRP.getUserId(source)

    local gameMode = ""
    local playerCount = Groups[Player(source).state.teamCode].playersCount
    
    if data.Gamemode == "SOLO" then
        if playerCount == 1 then
            gameMode = "solo"
        else
            return
        end
    elseif data.Gamemode == "DUO" then
        if playerCount == 2 or playerCount == 1 then
            gameMode = "duo"
        else
            return
        end
    elseif data.Gamemode == "SQUAD" then
        if playerCount >= 3 and playerCount <= 4 or playerCount == 1 or playerCount == 2 then
            gameMode = "squad"
        else
            return
        end
    end
    
    if not GameController.GetGamesForType(gameMode) then
        local gameId = GameController.HostGame(gameMode, 'player').gameId
        
        for k,v in pairs(Groups[Player(source).state.teamCode].players) do
            if not Player(v.source).state.inQueue and not Player(v.source).state.inGame then
                Player(v.source).state.inQueue = true
                Player(v.source).state.gameId = gameId
                GameController.JoinGame(gameId, {
                    source = v.source,
                    user_id = v.user_id,
                    username = v.username,
                    team = Player(v.source).state.teamCode,
                })
            end
            Wait(1)
        end
    else
        local gameId = GameController.GetGamesForType(gameMode)

        for k,v in pairs(Groups[Player(source).state.teamCode].players) do
            if not Player(v.source).state.inQueue and not Player(v.source).state.inGame then
                Player(v.source).state.inQueue = true
                Player(v.source).state.gameId = gameId

                GameController.JoinGame(gameId, {
                    source = v.source,
                    user_id = v.user_id,
                    username = v.username,
                    team = Player(v.source).state.teamCode,
                })
            end
            Wait(1)
        end
    end
end)

RegisterServerEvent("UpdateCreateAccount")
AddEventHandler("UpdateCreateAccount", function(typee)
    local source = source

    ApiController.loadUserData(source)
end)

function src.loadUserData() 
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getIdentity(user_id)

    ApiController.loadUserData(source)
end

RegisterCommand("new", function(source, args ,rawCmd) 
    local user_id = vRP.getUserId(source)
    if user_id ~= 1 and user_id ~= 2 and user_id ~= 3 and user_id ~= 4 and user_id ~= 1920 then
        return
    end

    ApiController.loadUserData(source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdatePed
-----------------------------------------------------------------------------------------------------------------------------------------
ApiController.UpdatePed = function(source, data)
    local user_id = vRP.getUserId(source)
	if Groups[Player(source).state.teamCode] == nil then return end
	local Group = Groups[Player(source).state.teamCode]

    if data.type == "Clothes" then
        vRP.setUData(user_id,"Clothings", json.encode(data.custom))
    
        if Player(source).state.inTeam then
            for k,v in pairs(Group.players) do 
                if v.user_id == user_id then
                    v.Clothes = json.encode(data.custom)
                end
            end
        end
    end

    if data.type == "Barber" then
        vRP.setUData(user_id,"Barbershop", data.custom)

        if Player(source).state.inTeam then
            for k,v in pairs(Group.players) do 
                if v.user_id == user_id then
                    v.currentCharacterMode = data.custom
                end
            end
        end
    end

    if data.type == "Tattos" then
        local TatuagensData = {}

        for k,v in pairs(data.custom) do 
            local item = Config.Tatuagens[v.tatto_spawnName] 
            TatuagensData[v.tatto_spawnName] = {
                tatto_name = item.tatto_name,
                tatto_type = item.tatto_type,
                tatto_category = item.tatto_category,
                tatto_model = item.tatto_model,
                tatto_part = item.tatto_part,
                tatto_image = item.tatto_image,
                tatto_status = v.tatto_status,
                tatto_inventoryId = v.tatto_inventoryId,
                tatto_spawnName = item.tatto_spawnName
            }
        end
        
        for k,v in pairs(TatuagensData) do 
            vRP.execute("vRP/updateInventory", { user_id = user_id, inventory_itemStatus = v.tatto_status, inventory_id = v.tatto_inventoryId })
            Citizen.Wait(200)
        end
        
        Player(source).state.userTatuagens = TatuagensData
    
    
        if Player(source).state.inTeam then
            for k,v in pairs(Group.players) do 
                if v.user_id == user_id then
                    v.Tatuagens = TatuagensData
                end
            end
        end
    end

    if data.type == "Skin" then
        vRP.execute("vRP/updateSkin", { inventory_itemStatus = data.status, inventory_id = data.id })
        clientAPI.clearInfoCache(source, 'collection')
        Player(source).state.userSkins = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function reMapData(game_data)
	-- RED
	local cntRed = 0
	local _redList = game_data
	game_data = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data[cntRed] = v
	end
	return game_data
end
