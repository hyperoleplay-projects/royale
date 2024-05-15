Groups = {}

function createGroup(ownerSource, ownerUserId, teamCode) 
  Groups[teamCode] = { 
    TeamId = ApiController.GenerateRandomNumber(), 
    playersCount = 0, 
    players = {}, 
    ownerId = ownerUserId, 
    ownerSource = ownerSource, 
    deleted = false, 
    position = 0,
    queue = { 
      mode = "SOLO", 
      customCode = nil, 
    }, 
  }
end

function deleteGroupFromOwnerSource(source) 
  local userId = vRP.getUserId(source)
  local teamCode = Player(source).state.teamCode

  if Groups[teamCode] == nil then 
    return 
  end

  local isLeader = isUserLeaderOfGroup(userId, teamCode)

  if isLeader then
    local teamPlayers = Groups[teamCode].players

    for _, player in pairs(teamPlayers) do 
      removePlayerOfGroup({
        source = player.source,
        user_id = player.user_id,
      })
      
      createGroupToExpelledPlayer(player)
    end
  end
end

function createGroupToExpelledPlayer(player)
  Player(player.source).state.inTeam = false
  Player(player.source).state.inTeamNoLeader = false
  Player(player.source).state.ready = true
  Player(player.source).state.isLeader = true

  local teamCode = generateStringNumber("LLLD")

  Player(player.source).state.teamCode = teamCode
  Player(player.source).state.ready = true

  createGroup(player.source, player.user_id, teamCode)

  local infos = ApiController.extractSteam(player.source)
  local steamHex = infos.steam:gsub("steam:", "")
  
  addPlayerOnGroup({
    source = player.source,
    user_id = player.user_id,
    username = player.username,
    avatar = player.avatar, 
    isLeader = true,
    currentCharacterMode = vRP.getUData(player.user_id,"Barbershop"),
    Clothes = vRP.getUData(player.user_id,"Clothings"),
    Tatuagens = Player(player.source).state.userTatuagens,
    ready = true,
    pos = 0,
    state = true,
    hexlast = steamHex,
    death = false,
    agonizing = false,
    color = nil,
    positionGame = 0,
    Coords = vec3(0,0,0),
  }, teamCode)
end 


function createInitialGroupToUser(source, userId) 
  local identity = vRP.getIdentity(userId)
  local teamCode = generateStringNumber("LLLD")

  Player(source).state.teamCode = teamCode
  Player(source).state.ready = true
  Player(source).state.isLeader = true
  Player(source).state.positionGame = 0

  createGroup(source, userId, teamCode)

  local infos = ApiController.extractSteam(source)
  local steamHex = infos.steam:gsub("steam:", "")
  
  addPlayerOnGroup({
      source = source,
      user_id = userId,
      username = identity.username,
      avatar = identity.avatar, 
      isLeader = true,
      currentCharacterMode = vRP.getUData(userId,"Barbershop"),
      Clothes = vRP.getUData(userId,"Clothings"),
      Tatuagens = Player(source).state.userTatuagens,
      ready = true,
      pos = 0,
      state = true,
      hexlast = steamHex,
      death = false,
      agonizing = false,
      isReviving = false,
      color = nil,
      positionGame = 0,
      Coords = vec3(0,0,0),
  }, teamCode)
end

function addPlayerOnGroup(playerData, teamCode) 
	if Groups[teamCode] == nil then 
    return 
  end

	if not Player(playerData.source).state.inTeam then
		if Groups[teamCode].playersCount < Config.TeamMaxPlayers then
			if Groups[teamCode].playersCount + 1 <= Config.TeamMaxPlayers then
        Groups[teamCode].players[playerData.user_id] = playerData

				Groups[teamCode].playersCount = Groups[teamCode].playersCount + 1
				playerData.pos = Groups[teamCode].playersCount
				playerData.color = Config.ColorsTeam[playerData.pos]
                
				Player(playerData.source).state.inTeam = true
        Player(playerData.source).state.IsFollowingTeam = false
				Player(playerData.source).state.teamCode = teamCode
                
        ApiController.sendEventPlayersEvent(teamCode, "BuildPeds", { tabela = Groups[teamCode], status = true })
			end
		else
      TriggerClientEvent("Notify",playerData.source,"negado", "Esse grupo já está cheio!")
		end
	end

  syncGroupMembers(teamCode)
  syncGroupQueue(teamCode, false)
end

function removePlayerOfGroup(playerData)
  if not playerData.user_id then 
    return 
  end 

  local teamCode = Player(playerData.source).state.teamCode

  if Groups[teamCode] == nil then return end

  local Group = Groups[teamCode]

  if isUserLeaderOfGroup(playerData.user_id, teamCode) then
    local groupPlayers = {}

    for playerId, _ in pairs(Group.players) do
      if playerId ~= playerData.user_id then
        table.insert(groupPlayers, playerId)
      end
    end

    if #groupPlayers > 0 then
      local randomIndex = math.random(1, #groupPlayers)

      local newLeaderId = groupPlayers[randomIndex]
      Group.players[newLeaderId].isLeader = true
      Player(Group.players[newLeaderId].source).state.isLeader = true

      Group.players[newLeaderId].pos = 1
      TriggerClientEvent("Notify", Group.players[newLeaderId].source, "inform", "Você é o novo líder desse grupo!")
      
      ApiController.SetReadyTeam(Group.players[newLeaderId].user_id, teamCode)
    end
  end

  if Group.players[playerData.user_id] ~= nil then
    Group.players[playerData.user_id].death = true
    Group.players[playerData.user_id].agonizing = true

    Group.players[playerData.user_id] = nil
    Group.playersCount = Group.playersCount - 1

    ApiController.sendEventPlayersEventNotGame(Player(playerData.source).state.teamCode, "BuildPeds", { tabela = Groups[Player(playerData.source).state.teamCode], status = true })
  end

  syncGroupMembers(teamCode)
  syncGroupQueue(teamCode)
end

function isGroupInQueue(teamCode)
  if Groups[teamCode] == nil then
    return false
  end 

  for k,v in pairs(Groups[teamCode].players) do
    if v.isLeader then 
      local isInQueue = Player(v.source).state.inQueue

      return isInQueue
    end
  end

  return false
end

function isUserLeaderOfGroup(userId, teamCode)
  if Groups[teamCode] == nil then
    return false
  end 

  for k,v in pairs(Groups[teamCode].players) do
    if v.user_id == userId then
      return v.isLeader
    end
  end

  return false
end

function getGroupQueue(teamCode) 
  if Groups[teamCode] == nil then
    return 
  end 

  return Groups[teamCode].queue 
end

function updateGroupQueue(teamCode, payload) 
  if Groups[teamCode] == nil then
    return 
  end 

  Groups[teamCode].queue = payload
end

function syncGroupMembers(teamCode)
  local groupObject = Groups[teamCode]

  if groupObject == nil then
    return
  end 

  local membersEntries = {}

  for _, player in pairs(groupObject.players) do
    local playerId = player.user_id
    local playerTag = getUserGuildTag(playerId)
    local playerName = player.username
    local playerColor = player.pos
    local isReady = player.ready
    local isOwner = player.isLeader

    table.insert(membersEntries, {
      playerId, 
      playerTag, 
      playerName, 
      playerColor, 
      isReady, 
      isOwner
    })
  end

  for _, player in pairs(groupObject.players) do
    TriggerClientEvent('core:updateGroup', player.source, membersEntries)
  end
end

function syncGroupQueue(teamCode, status)
  local groupObject = Groups[teamCode]

  if groupObject == nil then
    return
  end 
  
  local groupQueue = getGroupQueue(teamCode)

  if not groupQueue then
      return
  end

  for _, player in pairs(groupObject.players) do
    TriggerClientEvent('core:updateQueue', player.source, false, groupQueue.mode, groupQueue.customCode)
  end
end