local api = {}; Tunnel.bindInterface('core:lobbyApi', api); 

function api.getPlayerGuildTag()
  local playerSource = source 
  local playerId = vRP.getplayerId(playerSource)

  -- TODO: Guild system

  return 'HYPE'
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
    table.insert(groupMemberEntries, {
      playerObject.user_id,
      nil, -- TODO: Guild system
      tostring(playerObject.username),
      playerObject.pos, 
      playerObject.ready,
      playerObject.isLeader and true or nil
    })
  end 

  return groupMemberEntries
end 

function api.getPlayerQueue()
  local playerSource = source 
  local playerId = vRP.getplayerId(playerSource)

  return false, 'SOLO'
end 