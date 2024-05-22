local api = {}; Tunnel.bindInterface('core:gameApi', api); 

function api.getPlayerToSpectate(playerSource)
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

  local playerTag = getUserGuildTag(playerId)

  return {
    playerTag,
    playerIdentity.username, 
    teamColor,
    0, 
    0
  }
end 
