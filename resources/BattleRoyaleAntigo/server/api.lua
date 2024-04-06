-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
clientAPI = Tunnel.getInterface(GetCurrentResourceName())
local Requests = {}
local Teams = {}
local GamesStatus = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- loadUserData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function loadUserData(source, user_id, lobby)
	if not Player(source).state.userData then
		local rows = vRP.query("vRP/requestUser",{ id = user_id })
		if rows[1] then
			vRP.updateIdentity(user_id)
			if lobby then
				Player(source).state.inLobbyPrincipal = false
				Player(source).state.inTeam = false
				Player(source).state.userTeam = {}
			end
			Player(source).state.inDashboard = false
			Player(source).state.inAimLab = false
			Player(source).state.inQueue = false
			Player(source).state.inGame = false
			Player(source).state.inGameLobby = false
			Player(source).state.countStartGame = 0
			Player(source).state.inPlane = false
			Player(source).state.oldDimension = 0
			Player(source).state.user_id = user_id
			Player(source).state.death = false
			Player(source).state.agonizing = false
			Player(source).state.clothesNUI = false
			Player(source).state.Compass = false
			Player(source).state.gameId = 0
			Player(source).state.kills = 0
			Player(source).state.PlayCooldown = 0
			Player(source).state.ChatCooldown = 0

			Player(source).state.inSpec = false
			Player(source).state.pointsGame = 0
			Player(source).state.pontos = rows[1]['points']
			Player(source).state.fpsSettings = rows[1]['fpsSettings']
			Player(source).state.finishGameUI = false
			Player(source).state.autoOpenDashboard = rows[1]['dashboardAutoOpen']
			Player(source).state.duthCoins = rows[1]['duthCoins']
			Player(source).state.duthPoints = rows[1]['duthPoints']
			Player(source).state.duthBattlePass = rows[1]['duthBattlePass']
			Player(source).state.duthBattleXp = rows[1]['duthBattleXp']
			Player(source).state.duthBattleLevel = rows[1]['duthBattleLevel']
			
			Player(source).state.userData = {
				user_id = user_id,
				username = rows[1]['username'], 
				avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
			}

			Player(source).state.userClothes = {}
			Player(source).state.userTatuagens = {}
			Player(source).state.userBarbearia = {}
			Player(source).state.userSkins = {}

			Player(source).state.openedRequests = undefined

			Group.load(user_id, source)
			Ranks.loadRankData(source, user_id)
			 -- AntiCheat.LoadUserReports(source, user_id)
			clientAPI.LoadConfigs(source)
			Inventory.LoadInventory(source, user_id)

			Requests[user_id] = {}

			clientAPI.SetTattos(source, Player(source).state.userTatuagens)
			return Player(source).state.userData
			

		else
			DropPlayer(source, "Você está bugado, entre novamente!")
		end
	else
		return Player(source).state.userData
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadAvatar - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadAvatar(source) 
    local user_id = vRP.getUserId(source)
	local identifiers = GetPlayerIdentifiers(source)
    local steamHex = 0
    
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "steam:") then
            local steamId = string.gsub(identifier, "steam:", "")
            local steamIdNum = tonumber(steamId, 16)
            steamHex = steamIdNum
            break  -- interrompe o loop após encontrar o identificador Steam
        end
    end
    Wait(100)
    if string.len(steamHex) >= 30 then return "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg" end
	
    local link = "http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=4792290131184C753679600CAA9EE073&steamids=" .. steamHex

    local p = promise:new()
    PerformHttpRequest(link, function(errorCode, resultData, resultHeaders)
        a = json.decode(resultData)
        if not a then
            print('A API do Steam está temporariamente indisponível ou muito ocupada para responder')
            p:resolve("https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg")
        else
            for k,v in pairs(a["response"].players) do
                p:resolve(v.avatarfull)
            end
        end
    end)

    return Citizen.Await(p)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadDiscordItems - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function LoadDiscordItems(source, user_id)
	if source then
		DiscordSync.UpdateDiscord(source)

		TeamsOrg.LoadTeamUser(source, user_id, function()
		end)

		Inventory.SyncRoleItems(source, user_id, function()
			Inventory.LoadInventory(source, user_id)
		end)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FinishTeam - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function FinishTeam(source) 
	local user_id = vRP.getUserId(source)
	if Teams[Player(source).state.teamCode] == nil then return end

	for k,v in pairs(Teams[Player(source).state.teamCode].players) do 
		if (v.source ~= nil and v.state ~= nil) and v.source and v.state and Player(v.source) then
			v.death = false

			if #Teams[Player(source).state.teamCode].players > 1 then
				v.ready = false
				Player(v.source).state.ready = false
			end
			
			Wait(100)
			TriggerClientEvent("battleNui:update", v.source)
			BuildTeam(Player(v.source).state.teamCode)
			TriggerClientEvent("BuildTeam", v.source)
			-- clientAPI.BuildTeam(v.source)
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobby - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function JoinLobby(source) 
	local user_id = vRP.getUserId(source)
	local random = math.random(#Config.Maps["LobbyPrincipal"].possibleDimensionsLobby)
	local lobbyRouting = Config.Maps["LobbyPrincipal"].possibleDimensionsLobby[random]
	SetPlayerRoutingBucket(source, lobbyRouting)
	clientAPI.JoinLobbyPrincipal(source)
	clientAPI.setDiscordRich(source, "DUTH", "No lobby")
	Player(source).state.inGame = false
	Player(source).state.inLobbyPrincipal = true
	Player(source).state.inDashboard = false
	Player(source).state.inQueue = false
	Player(source).state.inGameLobby = false
	Player(source).state.countStartGame = 0
	Player(source).state.inPlane = false
	Player(source).state.oldDimension = 0
	Player(source).state.death = false
	Player(source).state.agonizing = false
	Player(source).state.clothesNUI = false
	Player(source).state.Compass = false
	Player(source).state.gameId = 0
	Player(source).state.kills = 0
	Player(source).state.inSpec = false
	Player(source).state.pointsGame = 0
	Player(source).state.Buttons = true
	Wait(500)
	clientAPI.UpdateBattlePass(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetFpsConfig - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetFpsConfig(status) 
	local source = source
	local user_id = vRP.getUserId(source)
	Player(source).state.fpsSettings = status
	vRP.execute("vRP/updateConfig", { id = user_id, fpsSettings = Player(source).state.fpsSettings })
end
-----------------------------------------------------------------------------------------
-- extractSteam - Funciton
-----------------------------------------------------------------------------------------
local function extractSteam(src)
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
-- AddNotify - Funciton
-----------------------------------------------------------------------------------------
function AddNotify(source, user_id, title, description, timer) 
	if not Requests[user_id] then
		Requests[user_id] = {}
		Player(source).state.openedRequests = undefined
	end

	Wait(50)
	table.insert(Requests[user_id], { type = "notify", title = title, description = description, timer = timer })
	Player(source).state.openedRequests = Requests[user_id]

	TriggerClientEvent("battleNui:update", source)

	SetTimeout(timer, function() 
		Requests[user_id] = {}
		Player(source).state.openedRequests = undefined
		TriggerClientEvent("battleNui:update", source)
	end)
end
-----------------------------------------------------------------------------------------
-- GenerateRandomNumber - Funciton
-----------------------------------------------------------------------------------------
function GenerateRandomNumber()
    math.randomseed(GetGameTimer())
    local random = math.random(1, 2048)
    return random
end
-----------------------------------------------------------------------------------------
-- CreateTeam - Funciton
-----------------------------------------------------------------------------------------
function CreateTeam(source, user_id, teamCode) 
	Teams[teamCode] = { TeamId = GenerateRandomNumber(), playersCount = 0, players = {}, ownerId = user_id, ownerSource = source, deleted = false, position = 0 }
end
-----------------------------------------------------------------------------------------
-- BuildTeam - Funciton
-----------------------------------------------------------------------------------------
function BuildTeam(teamCode)
    if Teams[teamCode] == nil then return end

    for k,v in pairs(Teams[teamCode].players) do
        if (v.source ~= nil and v.state ~= nil) and v.state and Player(v.source) then
            local player = Player(v.source)
            if player.state then
                player.state.userTeam = Teams[teamCode]
                Wait(300)
                -- clientAPI.BuildTeam(v.source)
				TriggerClientEvent("BuildTeam", v.source)
            end
        end
    end
end
-----------------------------------------------------------------------------------------
-- RequestSpectatorTeam - Funciton
-----------------------------------------------------------------------------------------
function RequestSpectatorTeam(data, status)
	if Teams[Player(data.source).state.teamCode] == nil then return end
	local Team = Teams[Player(data.source).state.teamCode]

    local Players = {}
    local Kills = 0
    local PlayerKey = nil

    for playerId, player in pairs(Team.players) do
        if (v.source ~= nil and v.state ~= nil) and not Player(player.source).state.death then
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
-----------------------------------------------------------------------------------------
-- RegisterKilTeam - Funciton
-----------------------------------------------------------------------------------------
function RegisterKilTeam(data, playersGameCount, Gamemode, gameId, Players)
	local allPlayersDead = true 
	if Teams[Player(data.source).state.teamCode] == nil then return end
	local Team = Teams[Player(data.source).state.teamCode]
	local user_id = vRP.getUserId(data.source)

	-- Registra o jogador como morto e caucula os pontos
	for k,v in pairs(Team.players) do
		if (v.source ~= nil and v.state ~= nil) and v.user_id == user_id and v.source and v.state and Player(v.source) then
			v.death = true
			v.positionGame = data.positionGame
			Player(v.source).state.death = true
			if Gamemode == "ranked" then
				Player(v.source).state.pointsGame = calculateFinalScore(user_id, v.source, v.username, data.positionGame, Player(v.source).state.kills, 0)
				Wait(50)
			end
		end

		BuildTeam(Player(v.source).state.teamCode)
	end

	-- Verifica se tem mais de 1 jogador no time, caso de Duo, Trio e Squad
	if #Team.players > 1 then
		for k,v in pairs(Team.players) do
			-- Se um jogador não estiver morto
			if not v.death then
				allPlayersDead = false -- altera variável de controle para false
			end
		end

		if allPlayersDead then
			Team.position = data.positionGame

			for k,v in pairs(Team.players) do
				if (v.source ~= nil and v.state ~= nil) and v.source and v.state and Player(v.source) then
					if Player(v.source).state.inSpec then
						clientAPI.stopSpectatorMode(v.source)
						Player(v.source).state.inSpec = false
					end
					OpenUIFinishMatch(Player(v.source).state.teamCode, "death", false)
				end
			end
			return
		end
	end

	-- Verifica o status da partida com base no número de jogadores vivos
	if #Team.players > 1 and not allPlayersDead then
		if playersGameCount > 1 then
			Player(data.source).state.inSpec = true
			RequestSpectatorTeam(data, true)
		end
	elseif allPlayersDead then -- Se ficar dando como perca o problema está aqui.
		if Player(data.source).state.death then
			OpenUIFinishMatch(Player(data.source).state.teamCode, "death", GetPlayersCountGame(gameId) > 1)

			Wait(3000)
	
			if GetPlayersCountGame(gameId) > 1 then
				uiApi.SetNuiFocus(data.source, false)
				Player(data.source).state.finishGameUI = false
	
				uiApi.BuildUI(data.source, "FinishGame", {
					open = false,
					setRank = false,
					GamePosition = 0,
					type = "death",
					RankSubTitle = "",
					RankProgressBar = 0,
					buttonReturnStatus = false
				})
	
				Player(data.source).state.inSpec = true
				RequestSpectator(data, true)
			end
		end

	end

	for _, player in pairs(Players) do 
		if (player.source ~= nil) and player.source and Player(player.source) then
            clientAPI.BuildGame(player.source, {
                status = true,
                players = GetPlayersCountGame(gameId),
                rich = true,
            })
        end

		if #Team.players > 1 and not allPlayersDead then
			if Player(player.source).state.inSpec then
				RequestSpectatorTeam({
					source = player.source
				}, false)
			end
		elseif allPlayersDead then
			if Player(player.source).state.inSpec then
				RequestSpectator({
					source = player.source
				}, false)
			end
		end
	end
end
-----------------------------------------------------------------------------------------
-- GetPlayersTeam - Funciton
-----------------------------------------------------------------------------------------
function GetPlayersTeam(TeamCode) 
	if Teams[TeamCode] == nil then return end

	local players = ""
	for k, v in pairs(Teams[TeamCode].players) do
		if k ~= #Teams[TeamCode].players then
			players = players .. v.username .. " "
		else
			players = players .. v.username
		end
	end
	
	return players
end
-----------------------------------------------------------------------------------------
-- JoinTeam - Funciton
-----------------------------------------------------------------------------------------
function JoinTeam(playerData, teamCode) 
	if Teams[teamCode] == nil then return end

	if not Player(playerData.source).state.inTeam then
		if Teams[teamCode].playersCount < Config.TeamMaxPlayers then
			if Teams[teamCode].playersCount + 1 <= Config.TeamMaxPlayers then
				table.insert(Teams[teamCode].players, playerData)

				Teams[teamCode].playersCount = #Teams[teamCode].players
				Wait(50)
				playerData.pos = Teams[teamCode].playersCount
				playerData.color = Config.ColorsTeam[playerData.pos]

				Player(playerData.source).state.inTeam = true

				Player(playerData.source).state.teamCode = teamCode

				BuildTeam(teamCode)
			end
		else
			if Player(playerData.source).state.inDashboard then
				if Player(playerData.source).state.openedRequests then
					Player(playerData.source).state.openedRequests = undefined
					Wait(50)
					TriggerClientEvent("battleNui:update", playerData.source)
				end
				TriggerClientEvent("Notify",source,"negado", "Esse grupo já está cheio!")
			end
		end
	else
		LeaveTeam(playerData, teamCode)
		Player(playerData.source).state.inTeam = false
		Wait(20)
		JoinTeam(playerData, teamCode)
	end

end
-----------------------------------------------------------------------------------------
-- hasLeader - Funciton
-----------------------------------------------------------------------------------------
function hasLeader(user_id, teamCode)
    if Teams[teamCode] == nil then
        return false
    else
        for k,v in pairs(Teams[teamCode].players) do
            if v.user_id == user_id then
                if v.isLeader then 
                    return true
                else
                    return false
                end
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------
-- OpenUIFinishMatch - Funciton
-----------------------------------------------------------------------------------------
function OpenUIFinishMatch(teamCode, typeFinish, playersCount) 
	local source = source
	if Teams[teamCode] == nil then return end
	for k,v in pairs(Teams[teamCode].players) do	
		if (v.source ~= nil and v.state ~= nil) then
			if typeFinish == "winner" then
				-- local rows = vRP.query("vRP/requestUser",{ id = v.user_id })
				-- Player(v.source).state["pontos"] = rows[1]['points']
				Wait(500)
				Player(v.source).state.pointsGame = calculateFinalScore(v.user_id, v.source, v.username, 1, Player(v.source).state.kills, 0)
				local atualRankWinner, nextRankPercentageWinner, nextRankNameWinner = Ranks.getNextRankInfo(Player(v.source).state["pontos"])
				Wait(50)
	
				uiApi.SetNuiFocus(v.source, true)
				uiApi.FinishUiGame(v.source, false)
	
				if Player(v.source).state["pontos"] ~= nil and tonumber(Player(v.source).state["pontos"]) > 0 then
					uiApi.BuildUI(v.source, "FinishGame", {
						open = true,
						setRank = true,
						GamePosition = 1,
						type = typeFinish,
						RankSubTitle = ""..atualRankWinner.." / "..nextRankNameWinner.."",
						RankProgressBar = nextRankPercentageWinner,
						buttonReturnStatus = true
					})
				else
					uiApi.BuildUI(v.source, "FinishGame", {
						open = true,
						setRank = true,
						GamePosition = 1,
						type = typeFinish,
						RankSubTitle = "VOCÊ ESTÁ COM OS PONTOS NEGATIVOS, JOGUE MAIS PARTIDAS PARA SAIR DO NEGATIVO.",
						RankProgressBar = 0,
						buttonReturnStatus = true
					})
				end
	
				Player(v.source).state.finishGameUI = true
			end
	
			if typeFinish == "death" then
				local atualRank, nextRankPercentage, nextRankName = Ranks.getNextRankInfo(Player(v.source).state["pontos"])
				uiApi.SetNuiFocus(v.source, true)
				uiApi.FinishUiGame(v.source, false)
	
				if Player(v.source).state["pontos"] ~= nil and tonumber(Player(v.source).state["pontos"]) > 0 then
					uiApi.BuildUI(v.source, "FinishGame", {
						open = true,
						setRank = true,
						GamePosition = v.positionGame,
						type = typeFinish,
						RankSubTitle = ""..atualRank.." / "..nextRankName.."",
						RankProgressBar = nextRankPercentage,
						buttonReturnStatus = playersCount
					})
				else
					uiApi.BuildUI(v.source, "FinishGame", {
						open = true,
						setRank = true,
						GamePosition = v.positionGame,
						type = typeFinish,
						RankSubTitle = "VOCÊ ESTÁ COM OS PONTOS NEGATIVOS, JOGUE MAIS PARTIDAS PARA SAIR DO NEGATIVO.",
						RankProgressBar = 0,
						buttonReturnStatus = playersCount
					})
				end
	
				Player(v.source).state.finishGameUI = true
			end
		end
	end	
end
-----------------------------------------------------------------------------------------
-- SetReadyTeam - Funciton
-----------------------------------------------------------------------------------------
function SetReadyTeam(user_id, teamCode) 
	if Teams[teamCode] == nil then return end
    for k,v in pairs(Teams[teamCode].players) do
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
-----------------------------------------------------------------------------------------
-- GetPlayersReady - Funciton
-----------------------------------------------------------------------------------------
function GetPlayersReady(teamCode)
    if Teams[teamCode] == nil then return end
    
    local allPlayersReady = true -- variável de controle
    for k,v in pairs(Teams[teamCode].players) do
        if (v.source ~= nil and v.state ~= nil) and not Player(v.source).state.ready then
			-- print("a")
            allPlayersReady = false -- altera variável de controle para false se um jogador não estiver pronto
        end
    end

    return allPlayersReady -- retorna o resultado final da verificação
end
-----------------------------------------------------------------------------------------
-- LeaveTeam - Funciton
-----------------------------------------------------------------------------------------
function LeaveTeam(playerData, teamCode) 
	local team = Teams[teamCode]
	if not team then
	  return
	end

	for k, v in pairs(team.players) do
	  if (v.source ~= nil and v.state ~= nil) and v.user_id == playerData.user_id then 
	    v.state = false
	    v.source = nil
		Player(playerData.source).state.inTeam = false
		table.remove(team.players, k)
	  end
	end

	Wait(500)

	team.playersCount = #Teams[teamCode].players
	BuildTeam(teamCode)

	if Player(playerData.source).state.inQueue and not Player(playerData.source).state.inGameLobby and not Player(playerData.source).state.inGame and not Player(playerData.source).state.inPlane then
		local playerCount = #Teams[Player(playerData.source).state.teamCode].players
		if playerCount > 1 then
			for k,v in pairs(Teams[Player(playerData.source).state.teamCode].players) do
				clientAPI.setLabelNUI(v.source, false, "a")

				LeaveGame({
					source = v.source,
					user_id = v.user_id,
				}, Player(v.source).state.gameId)
				Player(v.source).state.gameId = 0
				Player(v.source).state.inQueue = false
				Player(v.source).state.death = false
			end
		else
			clientAPI.setLabelNUI(playerData.source, false, "a")
			LeaveGame({
				source = playerData.source,
				user_id = playerData.user_id,
			}, Player(playerData.source).state.gameId)
			Player(playerData.source).state.gameId = 0
			Player(playerData.source).state.inQueue = false
			Player(playerData.source).state.death = false
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateClothes
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateClothes(custom) 
    local source = source
    local user_id = vRP.getUserId(source)
	if Teams[Player(source).state.teamCode] == nil then return end
	local Team = Teams[Player(source).state.teamCode]
	vRP.setUData(user_id,"Clothings", json.encode(custom))

	if Player(source).state.inTeam then
		for k,v in pairs(Team.players) do 
			if v.user_id == user_id then
				v.Clothes = json.encode(custom)
			end
		end
	end

	BuildTeam(Player(source).state.teamCode)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateBarbearia
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateBarbearia(custom) 
    local source = source
    local user_id = vRP.getUserId(source)
	if Teams[Player(source).state.teamCode] == nil then return end
	local Team = Teams[Player(source).state.teamCode]
	vRP.setUData(user_id,"Barbershop", custom)

	if Player(source).state.inTeam then
		for k,v in pairs(Team.players) do 
			if v.user_id == user_id then
				v.currentCharacterMode = custom
			end
		end
	end

	BuildTeam(Player(source).state.teamCode)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateTatuagem
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateTatuagem(tattos) 
    local source = source
    local user_id = vRP.getUserId(source)
	if Teams[Player(source).state.teamCode] == nil then return end
	local Team = Teams[Player(source).state.teamCode]
	local TatuagensData = {}

	for k,v in pairs(tattos) do 
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
		for k,v in pairs(Team.players) do 
			if v.user_id == user_id then
				v.Tatuagens = TatuagensData
			end
		end
	end

	BuildTeam(Player(source).state.teamCode)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function(reason)
    local source = source
    local user_id = vRP.getUserId(source)
	vRP.execute("vRP/updateXpPasse", { duthBattleXp = Player(source).state.duthBattleXp, id = user_id })
    vRP.execute("vRP/updateDuthPoints", { duthPoints = Player(source).state.duthPoints, id = user_id })
	vRP.execute("vRP/updatePoints", { id = user_id, points = Player(source).state.pontos })

	if Teams[Player(source).state.teamCode] == nil then return end
	
	if Player(source).state.inTeam then
		local identity = vRP.getIdentity(user_id)
		LeaveTeam({
			source = source,
			user_id = user_id,
			username = identity.username,
			isLeader = false,
			ready = false,
			pos = 0,
			state = false,
		}, Player(source).state.teamCode)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitTeam - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.exitTeam() 
	local source = source
	local user_id = vRP.getUserId(source)
	local player = Player(source)
	if Teams[Player(source).state.teamCode] == nil then return end
	
	if not player.state.ExitCooldown or os.time() >= player.state.ExitCooldown + 15 and player.state.inTeam then
		local identity = vRP.getIdentity(user_id)
		player.state.ExitCooldown = os.time()
	
		local leaveData = {
			source = source,
			user_id = user_id,
			username = identity.username,
			avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
			isLeader = true,
			currentCharacterMode = vRP.getUData(user_id, "Barbershop"),
			Clothes = vRP.getUData(user_id, "Clothings"),
			Tatuagens = Player(source).state.userTatuagens,
			ready = false,
			pos = 0,
			state = false,
		}
		LeaveTeam(leaveData, Player(source).state.teamCode)
	
		
		if Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane then
			local playerCount = #Teams[Player(source).state.teamCode].players
			if playerCount > 1 then
				for k,v in pairs(Teams[Player(source).state.teamCode].players) do
					clientAPI.setLabelNUI(v.source, false, "a")
	
					LeaveGame({
						source = v.source,
						user_id = v.user_id,
						username = v.username,
						isLeader = false,
						ready = false,
						pos = 0,
						state = false,
					}, Player(v.source).state.gameId)
					Player(v.source).state.gameId = 0
					Player(v.source).state.inQueue = false
					Player(v.source).state.death = false
				end
			else
				clientAPI.setLabelNUI(source, false, "a")
				LeaveGame({
					source = source,
					user_id = user_id,
					username = identity.username,
					isLeader = false,
					ready = false,
					pos = 0,
					state = false,
				}, Player(source).state.gameId)
				Player(source).state.gameId = 0
				Player(source).state.inQueue = false
				Player(source).state.death = false
			end
		end

		player.state.inTeam = false
	
		Wait(50)
	
		local newTeamCode = generateStringNumber("LLLD")
		CreateTeam(source, user_id, newTeamCode)
		player.state.ready = true
		
		local infos = extractSteam(source)
		local steamHex = infos.steam:gsub("steam:", "")

		local joinData = {
			source = source,
			user_id = user_id,
			username = identity.username,
			avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
			isLeader = true,
			currentCharacterMode = vRP.getUData(user_id, "Barbershop"),
			Clothes = vRP.getUData(user_id, "Clothings"),
			Tatuagens = Player(source).state.userTatuagens,
			ready = true,
			pos = 0,
			state = true,
			hexlast = steamHex,
			death = false,
			agonizing = false,
			color = nil,
			positionGame = 0,
		}
		JoinTeam(joinData, newTeamCode)
		clientAPI.setLabelNUI(source, false, "a")
	else
		TriggerClientEvent("Notify",source,"negado", "Aguarde " .. (15 - (os.time() - player.state.ExitCooldown)) .. " segundos.")
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Lobby - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("lobby", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	
	-- if not Player(source).state.UpdateCooldown or os.time() >= Player(source).state.UpdateCooldown+30 then
	if not Player(source).state.inGame and not Player(source).state.inAimLab and not Player(source).state.inQueue then
		if not Player(source).state.inDashboard then
				local identity = vRP.getIdentity(user_id)
				Player(source).state.inDashboard = true
		
				local teamCode = generateStringNumber("LLLD")
				Player(source).state.teamCode = teamCode
				Player(source).state.ready = true
		
				CreateTeam(source, user_id, teamCode)
				local infos = extractSteam(source)
				local steamHex = infos.steam:gsub("steam:", "")
		
				
				if Player(source).state.autoOpenDashboard == "true" then
					clientAPI.OpenLobby(source, true)
					Player(source).state.inDashboard = true
				else
					clientAPI.OpenLobby(source, false)
					local random = math.random(#Config.Maps["LobbyPrincipal"].possibleDimensionsLobby)
					local lobbyRouting = Config.Maps["LobbyPrincipal"].possibleDimensionsLobby[random]
					SetPlayerRoutingBucket(source, lobbyRouting)
					clientAPI.JoinLobbyPrincipal(source)
					clientAPI.setDiscordRich(source, "DUTH", "#"..user_id.." "..identity.username.."")
					Player(source).state.inLobbyPrincipal = true
					Player(source).state.inDashboard = false
				end
		
				JoinTeam({
					source = source,
					user_id = user_id,
					username = identity.username,
					avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
					isLeader = true,
					currentCharacterMode = vRP.getUData(user_id,"Barbershop"),
					Clothes = vRP.getUData(user_id,"Clothings"),
					Tatuagens = Player(source).state.userTatuagens,
					ready = true,
					pos = 0,
					state = true,
					hexlast = steamHex,
					death = false,
					agonizing = false,
					color = nil,
					positionGame = 0,
				}, teamCode)
		
				TriggerClientEvent("battleNui:update", source)
			end
		end

		Wait(500)
		clientAPI.UpdateBattlePass(source)
	-- else
		-- TriggerClientEvent("Notify", source, "negado", "Aguarde "..(30-(os.time()-Player(source).state.UpdateCooldown)).." segundos.", 15000, "normal", "Admin")
	-- end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("att", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
	local identity = vRP.getIdentity(user_id)

	-- if not Player(source).state.UpdateCooldown or os.time() >= Player(source).state.UpdateCooldown+30 then
		Player(source).state.userData = false
		Wait(500)
		Player(source).state.UpdateCooldown = os.time()
		loadUserData(source, user_id, false)
		
		TriggerClientEvent("battleNui:update", source)
		LoadDiscordItems(source, user_id)
		TriggerClientEvent("Notify", source, "sucess", "Suas <b>Informações e Inventário</b> foram atualizados.")
	-- else
		-- TriggerClientEvent("Notify", source, "negado", "Aguarde "..(30-(os.time()-Player(source).state.UpdateCooldown)).." segundos.", 15000, "normal", "Admin")
	-- end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitLobbyPrincipal - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.ExitLobbyPrincipal() 
	local source = source
	local user_id = vRP.getUserId(source)
	Player(source).state.inDashboard = true
	Player(source).state.inLobbyPrincipal = false
	SetPlayerRoutingBucket(source, user_id+1)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinLobbyPrincipal - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.JoinLobbyPrincipal() 
	local source = source
	local user_id = vRP.getUserId(source)
	Player(source).state.inDashboard = false
	Player(source).state.inAimLab = false
	Player(source).state.inLobbyPrincipal = true
	local random = math.random(#Config.Maps["LobbyPrincipal"].possibleDimensionsLobby)
	local lobbyRouting = Config.Maps["LobbyPrincipal"].possibleDimensionsLobby[random]
	SetPlayerRoutingBucket(source, lobbyRouting)
	clientAPI.setDiscordRich(source, "DUTH", "No lobby")
	clientAPI.JoinLobbyPrincipal(source)
	Wait(500)
	clientAPI.UpdateBattlePass(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- sendInviteTeam - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.sendInviteTeam(friend_id) 
	local source = source
	local user_id = vRP.getUserId(source)
	local nsource = vRP.getUserSource(parseInt(friend_id))
	TriggerClientEvent("Notify",source,"negado", "Esse modo está desativado!")

	-- if hasLeader(user_id, Player(source).state.teamCode) then
	-- 	if friend_id and nsource and Player(nsource).state.inDashboard and not Player(nsource).state.inQueue and not Player(nsource).state.inGameLobby and not Player(nsource).state.inGame and not Player(nsource).state.inPlane and not Player(nsource).state.inAimLab then
	-- 		local identity = vRP.getIdentity(user_id)
	-- 		if not Requests[parseInt(friend_id)] then
	-- 			Requests[parseInt(friend_id)] = {}
	-- 		end
	-- 		Wait(50)

	-- 		table.insert(Requests[parseInt(friend_id)], { id = GenerateRandomNumber(), type = "request", requestedBy = user_id, user_id = parseInt(friend_id), title = "Convite de grupo", description = "Você foi convidado para entrar no grupo do jogador(a) "..identity.username.." deseja aceitar ?", timer = 120 })
			
	-- 		Player(nsource).state.openedRequests = Requests[parseInt(friend_id)]
			
	-- 		TriggerClientEvent("battleNui:update", nsource)
	-- 		TriggerClientEvent("Notify",source,"negado", "Você convidou o jogador com sucesso!")
	-- 	end
	-- else
	-- 	TriggerClientEvent("Notify",source,"negado", "Apenas o lider do grupo pode convidar jogadores!")
	-- end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RecuseRequets - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.RecuseRequets() 
	local source = source
	local user_id = vRP.getUserId(source)
	Requests[user_id] = {}
	Player(source).state.openedRequests = undefined
	Wait(50)
	TriggerClientEvent("battleNui:update", source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AcceptRequets - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.AcceptRequets(requestId) 
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getIdentity(user_id)
	local nsource = vRP.getUserSource(requestId)

	if Requests[user_id] then
		Requests[user_id] = {}
	
		Player(source).state.ready = false
		Player(source).state.openedRequests = undefined
		Wait(50)
		TriggerClientEvent("battleNui:update", source)
	
		Player(source).state.teamCode = Player(nsource).state.teamCode
		local infos = extractSteam(source)
		local steamHex = infos.steam:gsub("steam:", "")
	
		JoinTeam({
			source = source,
			user_id = user_id,
			username = identity.username,
			avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
			isLeader = false,
			currentCharacterMode = vRP.getUData(user_id,"Barbershop"),
			Clothes = vRP.getUData(user_id,"Clothings"),
			Tatuagens = Player(source).state.userTatuagens,
			ready = false,
			pos = 0,
			state = true,
			hexlast = steamHex,
			death = false,
			agonizing = false,
			color = nil,
			positionGame = 0,
		}, Player(nsource).state.teamCode)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PlayMatchTeam - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.PlayMatchTeam() 
    local source = source
    local userId = vRP.getUserId(source)

	if not Player(source).state.PlayCooldown or os.time() >= Player(source).state.PlayCooldown+15 then
		Player(source).state.PlayCooldown = os.time()
		if not GamesStatus then
			if Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane and not Player(source).state.inAimLab then
				local playerCount = #Teams[Player(source).state.teamCode].players
				if playerCount > 1 then
					for k,v in pairs(Teams[Player(source).state.teamCode].players) do
						clientAPI.setLabelNUI(v.source, false, "a")
		
						LeaveGame({
							source = v.source,
							user_id = v.user_id,
						}, Player(v.source).state.gameId)
						Player(v.source).state.gameId = 0
						Player(v.source).state.inQueue = false
						Player(v.source).state.death = false
					end
					return
				else
					clientAPI.setLabelNUI(source, false, "a")
					LeaveGame({
						source = source,
						user_id = userId,
					}, Player(source).state.gameId)
					Player(source).state.gameId = 0
					Player(source).state.inQueue = false
					Player(source).state.death = false
					return
				end
			end
		
			if GetPlayersReady(Player(source).state.teamCode) and hasLeader(userId, Player(source).state.teamCode) and not Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane and not Player(source).state.inAimLab then
				local gameMode = ""
				local playerCount = #Teams[Player(source).state.teamCode].players
		
				if playerCount == 1 then
					gameMode = "solo"
				elseif playerCount == 2 then
					gameMode = "duo"
				elseif playerCount >= 3 and playerCount <= 4 then
					gameMode = "squad"
				end
				
				if not GetGamesForType(gameMode) then
					local gameId = HostGame(gameMode).gameId
		
					for k,v in pairs(Teams[Player(source).state.teamCode].players) do
						if not Player(v.source).state.inQueue and not Player(v.source).state.inGame then
							Player(v.source).state.inQueue = true
							Player(v.source).state.gameId = gameId
							JoinGame(gameId, {
								source = v.source,
								user_id = v.user_id,
								username = v.username,
								team = Player(v.source).state.teamCode,
							})
						end
					end
		
				else
					local gameId = GetGamesForType(gameMode)
		
					for k,v in pairs(Teams[Player(source).state.teamCode].players) do
						if not Player(v.source).state.inQueue and not Player(v.source).state.inGame then
							Player(v.source).state.inQueue = true
							Player(v.source).state.gameId = gameId
							JoinGame(gameId, {
								source = v.source,
								user_id = v.user_id,
								username = v.username,
								team = Player(v.source).state.teamCode,
							})
						end
					end
				end
			else
				if not Player(source).state.inQueue and not Player(source).state.inAimLab then
					SetReadyTeam(userId, Player(source).state.teamCode)
					BuildTeam(Player(source).state.teamCode)
					Wait(50)
					TriggerClientEvent("battleNui:update", source)
				end
			end
		else
			TriggerClientEvent("Notify",source,"negado", "A fila de partidas desse modo está fechada.")
		end
	else
		TriggerClientEvent("Notify",source,"negado", "Aguarde " .. (15 - (os.time() - Player(source).state.PlayCooldown)) .. " segundos.")
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetStatusGames - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function SetStatusGames(source) 
    local user_id = vRP.getUserId(source)
	if GamesStatus then
		GamesStatus = false
		if Player(source).state.inDashboard then
			AddNotify(source, user_id, "Aviso", "Você liberou a fila de partidas!", 1800)
		else
			TriggerClientEvent("Notify", source, "sucess", "Você liberou a fila de partidas!")
		end
	else
		GamesStatus = true

		if Player(source).state.inDashboard then
			AddNotify(source, user_id, "Aviso", "Você fechou a fila de partidas!", 1800)
		else
			TriggerClientEvent("Notify", source, "sucess", "Você fechou a fila de partidas!")
		end
	end

	return GamesStatus
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE CREATE ACCOUNT - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("UpdateCreateAccount")
AddEventHandler("UpdateCreateAccount", function(typee)
	local source = source
    local user_id = vRP.getUserId(source)
	local identity = vRP.getIdentity(user_id)

	Player(source).state.userData = false
	loadUserData(source, user_id, true)
	Wait(500)
	if not Player(source).state.inDashboard then
		Player(source).state.inDashboard = true

		local teamCode = generateStringNumber("LLLD")
		Player(source).state.teamCode = teamCode
		Player(source).state.ready = true

		CreateTeam(source, user_id, teamCode)
		local infos = extractSteam(source)
		local steamHex = infos.steam:gsub("steam:", "")

		
		if Player(source).state.autoOpenDashboard == "true" then
			clientAPI.OpenLobby(source, true)
			Player(source).state.inDashboard = true
		else
			clientAPI.OpenLobby(source, false)
			local random = math.random(#Config.Maps["LobbyPrincipal"].possibleDimensionsLobby)
			local lobbyRouting = Config.Maps["LobbyPrincipal"].possibleDimensionsLobby[random]
			SetPlayerRoutingBucket(source, lobbyRouting)
			clientAPI.JoinLobbyPrincipal(source)
			clientAPI.setDiscordRich(source, "DUTH", "#"..user_id.." "..identity.username.."")
			Player(source).state.inLobbyPrincipal = true
			Player(source).state.inDashboard = false
		end
		

		JoinTeam({
			source = source,
			user_id = user_id,
			username = identity.username,
			avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg", 
			isLeader = true,
			currentCharacterMode = vRP.getUData(user_id,"Barbershop"),
			Clothes = vRP.getUData(user_id,"Clothings"),
			Tatuagens = Player(source).state.userTatuagens,
			ready = true,
			pos = 0,
			state = true,
			hexlast = steamHex,
			death = false,
			agonizing = false,
			color = nil,
			positionGame = 0,
		}, teamCode)

		TriggerClientEvent("battleNui:update", source)
	end
	LoadDiscordItems(source, user_id)

	Wait(500)
	clientAPI.UpdateBattlePass(source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Debug - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("debug", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	local Clothes = vRP.getUData(user_id,"Clothings")
	vRPC.setClothing(source, Clothes) 
	clientAPI.SetTattos(source, Player(source).state.userTatuagens)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function reMapData(game_data)
	-- print(dump(game_data))
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
-----------------------------------------------------------------------------------------------------------------------------------------
-- Shortcuts - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.ShortcutsSpec(sourceRecebido) 
	local user_id = vRP.getUserId(sourceRecebido)
	return vRP.Shortcuts(sourceRecebido, user_id)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateSkin - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateSkin(data)
	local source = source
	local user_id = vRP.getUserId(source)
	vRP.execute("vRP/updateSkin", { inventory_itemStatus = data.status, inventory_id = data.id })
	Inventory.LoadInventory(source, user_id)
end