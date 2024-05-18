local api = {}; Tunnel.bindInterface('core:lobbyApi', api); 

function api.getPlayerGuildTag()
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  return getUserGuildTag(playerId)
end 

local function getPlayerColor(playerSource, playerId)
  local teamCode = Player(playerSource).state.teamCode
  local group = Groups[teamCode]

  if not group then 
    return 
  end 

  local player = group.players[playerId] 

  if not player then 
    return 
  end 

  return player.pos
end 

function api.getPlayerProfile()
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  if not playerId then 
    return 
  end 

  local playerIdentity = vRP.getIdentity(playerId)

  if not playerIdentity then 
    return 
  end 

  local teamColor = getPlayerColor(playerSource, playerId)

  if not teamColor then 
    return 
  end 

  return {
    id = playerId,
    name = playerIdentity.username, 
    color = teamColor
  }
end 

function api.getPlayerGroupMembers()
  local playerSource = source 

  local teamCode = Player(playerSource).state.teamCode
  local group = Groups[teamCode]

  if not group then 
    return 
  end 

  local groupMemberEntries = {} 

  for _, playerObject in ipairs(group.players) do 
    local playerSource = playerObject.source

    local playerTag = getUserGuildTag(playerObject.user_id)

    local playerName = tostring(playerObject.username)
    local playerColor = playerObject.pos
    local isPlayerReady = playerObject.ready
    local isPlayerLeader = playerObject.isLeader and true or nil

    table.insert(groupMemberEntries, {
      playerSource,
      playerTag,
      playerName,
      playerColor,  
      isPlayerReady,
      isPlayerLeader
    })
  end 

  return groupMemberEntries
end 

function api.getPlayerQueue()
  local playerSource = source 

  local teamCode = Player(playerSource).state.teamCode

  local isInQueue = isGroupInQueue(teamCode)
  local groupQueue = getGroupQueue(teamCode)

  return isInQueue, groupQueue.mode, groupQueue.customCode
end 


local function isQueueDataValid(mode, code)
  if not mode then 
    return false
  end 

  if mode ~= 'SOLO' and mode ~= 'DUO' and mode ~= 'SQUAD' then 
    return false
  end 

  return true 
end

function api.updateGroupQueue(mode, code)
  local playerSource = source 

  if not isQueueDataValid(mode, code) then 
    return 
  end
  
  local teamCode = Player(playerSource).state.teamCode
  local playerId = vRP.getUserId(playerSource)
  
  if not isUserLeaderOfGroup(playerId, teamCode) then 
    return 
  end 
  
  local groupQueue = getGroupQueue(teamCode) 
  
  if not groupQueue then 
    return 
  end
  
  updateGroupQueue(teamCode, {
    mode = mode,
    customCode = code
  })
  
  syncGroupQueue(teamCode, false)
end 

function api.getPlayerGuild()
  local playerSource = source 

  local playerId = vRP.getUserId(playerSource)
  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return false 
  end 

  return true, getGuildEntriesByTag(playerGuildTag)
end 

local function isDataValidToCreateGuild(tag, name, imageURL)
  if not tag or #tag < 2 or #tag > 4 then 
    return 
  end 

  if not name or #name < 3 or #name > 32 then 
    return 
  end 

  if not imageURL then 
    return 
  end 

  return true 
end

function api.createGuild(tag, name, imageURL)
  local playerSource = source 

  if not isDataValidToCreateGuild(tag, name, imageURL) then 
    return false
  end

  local playerId = vRP.getUserId(playerSource)

  local isCreated = tryCreateGuild(tag, name, imageURL)

  if isCreated then 
    addGuildMember(tag, playerId, true)
  
    return tag
  end 
end 

function api.upgradeGuildMember(memberId)
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)
  
  if not playerGuildTag then 
    return 
  end 

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return 
  end

  local memberRoleIndex = getGuildMemberRoleIndex(playerGuildTag, memberId)

  if not memberRoleIndex or (memberRoleIndex - 1) == playerRoleIndex then 
    return
  end

  return tryUpgradeGuildMember(playerGuildTag, memberId) and getGuildMembersEntriesByTag(playerGuildTag) 
end 

function api.downgradeGuildMember(memberId)
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)
  
  if not playerGuildTag then 
    return 
  end 

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return 
  end

  local memberRoleIndex = getGuildMemberRoleIndex(playerGuildTag, memberId)

  if not memberRoleIndex then 
    return
  end

  return tryDowngradeGuildMember(playerGuildTag, memberId) and getGuildMembersEntriesByTag(playerGuildTag) 
end 

function api.kickGuildMember(memberId)
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return 
  end

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return 
  end

  removeGuildMember(playerGuildTag, memberId)

  return getGuildMembersEntriesByTag(playerGuildTag) 
end 

function api.leaveOfCurrentGuild()
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return 
  end

  removeGuildMember(playerGuildTag, playerId)
end 

function api.getUserAvailableToGuild(targetId)
  local targetGuildTag = getUserGuildTag(targetId)

  if targetGuildTag then 
    return false
  end

  local targetSource = vRP.getUserSource(targetId)

  if not targetSource then 
    return 
  end

  local targetIdentity = vRP.getIdentity(targetId)

  if not targetIdentity then 
    return 
  end 

  return {
    targetId, 
    targetIdentity.username, 
    0, -- TODO: Kills system
    0 -- TODO: Deaths system
  }
end 

function api.tryInviteUserToGuild(targetId)
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return false
  end

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex == ROLES_ENUM.MEMBER then 
    return false
  end

  local targetGuildTag = getUserGuildTag(targetId)

  if targetGuildTag then 
    return false
  end

  local targetSource = vRP.getUserSource(targetId)

  if not targetSource then 
    return false
  end

  Citizen.CreateThreadNow(function()
    inviteUserToGuild(playerGuildTag, targetId, targetSource)
  end)

  return true
end 

function api.tryChangeGuildName(newName)
  local playerSource = source 

  if not newName or #newName < 3 or #newName > 32 then 
    return false
  end

  local playerId = vRP.getUserId(playerSource)

  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return false
  end

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return false
  end

  updateGuildName(playerGuildTag, newName)
  
  return true
end 

function api.tryChangeGuildTag(newTag)
  local playerSource = source 

  if not newTag or #newTag < 2 or #newTag > 4 then 
    return false
  end

  local playerId = vRP.getUserId(playerSource)
  local playerGuildTag = getUserGuildTag(playerId)

  if not playerGuildTag then 
    return false
  end

  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)

  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return false
  end

  return tryUpdateGuildTag(playerGuildTag, newTag)
end 

function api.tryChangeGuildImage(imageURL)
  local playerSource = source 
  local playerId = vRP.getUserId(playerSource)
  
  local playerGuildTag = getUserGuildTag(playerId)
  
  if not playerGuildTag then 
    return false
  end
  
  local playerRoleIndex = getGuildMemberRoleIndex(playerGuildTag, playerId)
  
  if playerRoleIndex ~= ROLES_ENUM.OWNER then 
    return false
  end
  
  updateGuildImage(playerGuildTag, imageURL)
  
  return true
end 

local function removeOfQueueGame(source, userId)
  local teamCode = Player(source).state.teamCode
  local gameId = Player(source).state.gameId
  
  local hasManyPlayers = Groups[teamCode].playersCount > 1
  local isTeamReady = not hasManyPlayers or GameController.GetGameStatus(gameId)

  if hasManyPlayers and not isTeamReady then
      local teamPlayers = Groups[teamCode].players

      for _, player in pairs(teamPlayers) do
          GameController.LeaveGame({
              source = player.source,
              user_id = player.user_id,
          }, Player(player.source).state.gameId)

          Player(player.source).state.gameId = 0
          Player(player.source).state.inQueue = false
          Player(player.source).state.death = false
      end
  else
      local isGameStarted = GameController.GetGameStatus(gameId)

      if not isGameStarted then
          GameController.LeaveGame({
              source = source,
              user_id = userId,
          }, Player(source).state.gameId)

          Player(source).state.gameId = 0
          Player(source).state.inQueue = false
          Player(source).state.death = false
      end
  end

  syncGroupQueue(teamCode, false)
end

function api.tryJoinInEvent()
  local source = source
  local userId = vRP.getUserId(source)

  local isInQueue = Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane
  
  if isInQueue then
    removeOfQueueGame(source, userId)

    return 
  end

  local teamCode = Player(source).state.teamCode
  local isTeamReady = ApiController.GetPlayersReady(teamCode)

  if not isTeamReady then 
    return 
  end

  local isLeader = isUserLeaderOfGroup(userId, teamCode)

  if not isLeader then 
    return 
  end

  local canJoinInEvent = Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane and not Player(source).state.inAimLab

  if not canJoinInEvent then 
    return 
  end 

  local isSolo = Groups[teamCode].playerCount == 1
  local teamPlayers = Groups[teamCode].players

  for k,v in pairs(isSolo and teamPlayers or {}) do
    v.death = false
    v.agonizing = false
    v.isReviving = false

    Player(v.source).state.death = false
    Player(v.source).state.agonizing = false
    Player(v.source).state.isReviving = false
  end

  local groupQueue = getGroupQueue(teamCode)

  if not groupQueue or not groupQueue.customCode then
    return 
  end

  local game = GameController.GetGameForCode(groupQueue.customCode)

  if not game then
    TriggerClientEvent("Notify",source,"negado", "Não existe nenhum evento com esse codigo livre.")

    return 
  end

  local isValidGame = groupQueue.mode:lower() == game.gameType

  if not isValidGame then
    TriggerClientEvent("Notify",source,"negado", "Seu time não está qualificado para jogar o modo desse evento.")
    
    return 
  end

  local playerCount = Groups[teamCode].playersCount

  if groupQueue.mode == 'SOLO' then
    local isSolo = playerCount == 1

    if not isSolo then
      return
    end
  elseif groupQueue.mode == 'DUO' then
    local isValidPlayersAmount = playerCount <= 2

    if not isValidPlayersAmount then
      return
    end
  elseif groupQueue.mode ~= 'SQUAD' then
    return 
  end

  for k,v in pairs(teamPlayers) do
    local isInserted = Player(v.source).state.inQueue or Player(v.source).state.inGame

    if not isInserted then
        Player(v.source).state.inQueue = true
        Player(v.source).state.gameId = game.gameId

        GameController.JoinGame(game.gameId, {
          source = v.source,
          user_id = v.user_id,
          username = v.username,
          team = Player(v.source).state.teamCode,
        })
    end
  end

  syncGroupQueue(teamCode, true)
end 

function api.tryStartGame()
  local source = source
  local userId = vRP.getUserId(source)

  local isInQueue = Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane
  
  if isInQueue then
    removeOfQueueGame(source, userId)
    
    return 
  end
  
  local teamCode = Player(source).state.teamCode
  
  local isSolo = Groups[teamCode].playerCount == 1
  local teamPlayers = Groups[teamCode].players
  
  for k,v in pairs(isSolo and teamPlayers or {}) do
    v.death = false
    v.agonizing = false
    v.isReviving = false
    
    Player(v.source).state.death = false
    Player(v.source).state.agonizing = false
    Player(v.source).state.isReviving = false
  end
  
  local isTeamReady = ApiController.GetPlayersReady(teamCode)
  
  if not isTeamReady then
    TriggerClientEvent("Notify", source, "negado", "É necessário que todos os jogadores do grupo estejam prontos para começar!")
    
    return
  end

  local canStartGame = isTeamReady and isUserLeaderOfGroup(userId, teamCode) and not Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane and not Player(source).state.inAimLab
  
  if not canStartGame then
    return 
  end 
  
  local groupQueue = getGroupQueue(teamCode)
  local gameModeLower = groupQueue.mode:lower()
  
  if groupQueue.mode == 'SOLO' then
    local isSolo = Groups[teamCode].playersCount == 1

    if not isSolo then
      return
    end
  elseif groupQueue.mode == 'DUO' then
    local isValidPlayersAmount = Groups[teamCode].playersCount <= 2

    if not isValidPlayersAmount then
      return
    end
  elseif groupQueue.mode ~= 'SQUAD' then
    return 
  end
  
  local gameId = GameController.GetGamesForType(gameModeLower)
  
  if not gameId then
    gameId = GameController.HostGame(gameModeLower, 'player').gameId
    
    for _, player in pairs(teamPlayers) do
      local isInserted = Player(player.source).state.inQueue or Player(player.source).state.inGame
      
      if not isInserted then
        Player(player.source).state.inQueue = true
        Player(player.source).state.gameId = gameId

        GameController.JoinGame(gameId, {
          source = player.source,
          user_id = player.user_id,
          username = player.username,
          team = Player(player.source).state.teamCode,
        })
      end
    end

    syncGroupQueue(teamCode, true)
    
    return 
  end 
  
  for k,v in pairs(teamPlayers) do
    local isInserted = Player(v.source).state.inQueue or Player(v.source).state.inGame

    if not isInserted then
      Player(v.source).state.inQueue = true
      Player(v.source).state.gameId = gameId

      GameController.JoinGame(gameId, {
        source = v.source,
        user_id = v.user_id,
        username = v.username,
        team = Player(v.source).state.teamCode,
      })
    end

    syncGroupQueue(teamCode, true)
  end
end

function api.tryReadyToGame()
  local source = source
  local userId = vRP.getUserId(source)

  local isInQueue = Player(source).state.inQueue and not Player(source).state.inGameLobby and not Player(source).state.inGame and not Player(source).state.inPlane
  
  if isInQueue then
    removeOfQueueGame(source, userId)

    return 
  end
  
  local teamCode = Player(source).state.teamCode
  local isLeader = isUserLeaderOfGroup(userId, teamCode)

  if isLeader then 
    return 
  end 

  local teamPlayers = Groups[teamCode].players

  ApiController.SetReadyTeam(userId, teamCode)

  for _, player in pairs(teamPlayers) do
    TriggerClientEvent('core:updateGroupMember', player.source, userId, { isReady = true })
  end
end 

function api.inviteUserToGroup(targetId)
  local source = source

  local userId = vRP.getUserId(source)
  local teamCode = Player(source).state.teamCode

  if not isUserLeaderOfGroup(userId, teamCode) then 
    TriggerClientEvent("Notify", source, "negado", "Apenas o lider do grupo pode convidar jogadores.")

    return 
  end

  local targetSource = vRP.getUserSource(targetId)
  local targetIdentity = vRP.getIdentity(targetId)
  
  if not targetSource or not targetIdentity then 
    return 
  end

  TriggerClientEvent("Notify", source, "inform", "Você convidou o jogador ".. targetIdentity.username.. " para seu grupo.")
  
  Citizen.CreateThreadNow(function()
    inviteUserToGroup(
      teamCode, 
      {
        tag = getUserGuildTag(userId),
        name = vRP.getIdentity(userId).username,
      }, 
      {
        source = targetSource,
        userId = targetId,
        identity = targetIdentity,
      }
    )
  end)
end

function api.leaveOfCurrentGroup()
  local source = source
  local userId = vRP.getUserId(source)

  removePlayerOfGroup({
    source = source,
    user_id = userId,
  })
end