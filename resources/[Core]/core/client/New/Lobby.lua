local lobbyApi = Tunnel.getInterface('core:lobbyApi')
local lobbyCache = {}

local PLAYER_ID = PlayerId()
local PLAYER_SOURCE = GetPlayerServerId(PLAYER_ID)

function updateMenuFrame(canShow, dataToUpdate)
  dataToUpdate = dataToUpdate or {}

  if type(canShow) == 'boolean' then 
    dataToUpdate.isVisible = canShow

    TriggerEvent("duth:ChatStatus", canShow)
    SetNuiFocus(canShow, canShow)
  end 

  if canShow then 
    setPlayerToLobby()
  end 

  SendReactMessage('updateMainMenu', dataToUpdate)
end 

function isPlayerReady()
  return LocalPlayer.state.ready
end 

AddStateBagChangeHandler(
  'ready', 
  'player:'.. PLAYER_SOURCE, 
  function(bagName, keyName, bagValue)
    updateMenuFrame(nil, { isReady = bagValue })
  end
)

function getPlayerGuildTag()
  if not lobbyCache.guild then 
    lobbyCache.guild = {
      tag = lobbyApi.getPlayerGuildTag()
    }
  end 

  return lobbyCache.guild.tag and lobbyCache.guild or nil
end 

RegisterNetEvent('core:updateGuild', function(guildTag)
  lobbyCache.guild = {
    tag = guildTag
  } 

  updateMenuFrame(nil, { 
    guild = getPlayerGuildTag()
  })
end)

function getPlayerProfile()
  return lobbyApi.getPlayerProfile()
end 

local function replaceGroupMembersEntries(membersEntries)
  lobbyCache.group = {} 

  for index, entries in ipairs(membersEntries) do 
    local playerId, playerTag, playerName, playerColor, isReady, isOwner = table.unpack(entries)

    lobbyCache.group[index] = {
      id = playerId,
      tag = playerTag,
      name = playerName,
      color = playerColor, 
      isReady = isReady,
      isOwner = not not isOwner
    }
  end 

  table.sort(lobbyCache.group, function(a, b)
    return a.color < b.color
  end)
end 

function getPlayerGroupMembers()
  local resultGroupMembers = {} 

  if not lobbyCache.group then 
    local membersEntries = lobbyApi.getPlayerGroupMembers()

    replaceGroupMembersEntries(membersEntries)
  end 

  for memberIndex, member in ipairs(lobbyCache.group) do 
    table.insert(resultGroupMembers, {
      tag = member.tag,
      name = member.name,
      color = member.color,
      isReady = member.isReady, 
      isOwner = member.isOwner
    })
  end 

  return resultGroupMembers
end 

RegisterNetEvent('core:updateGroup', function(membersEntries)
  replaceGroupMembersEntries(membersEntries)

  updateMenuFrame(nil, { 
    groupMembers = getPlayerGroupMembers()
  })
end)

RegisterNetEvent('core:addGroupMember', function(playerId, entries)
  local playerTag, playerName, playerColor, isReady, isOwner = table.unpack(entries)

  lobbyCache.group = lobbyCache.group or {}

  table.insert(lobbyCache.group, {
    id = playerId,
    tag = playerTag,
    name = playerName,
    color = playerColor, 
    isReady = isReady,
    isOwner = not not isOwner
  })

  table.sort(lobbyCache.group, function(a, b)
    return a.color < b.color
  end)

  updateMenuFrame(nil, { 
    groupMembers = getPlayerGroupMembers()
  })
end)

RegisterNetEvent('core:removeGroupMember', function(playerId)
  for playerIndex = #lobbyCache.group, -1, 1 do 
    local playerObject = lobbyCache.group[playerIndex]

    if playerObject.id == playerId then 
      table.remove(lobbyCache.group, playerIndex)
    else 
      playerObject.color = playerObject.color - 1
    end 
  end 

  updateMenuFrame(nil, { 
    groupMembers = getPlayerGroupMembers()
  })
end)

RegisterNetEvent('core:updateGroupMember', function(playerId, payload)
  for _, playerObject in ipairs(lobbyCache.group) do 
    if playerObject.id == playerId then 
      for key, value in pairs(payload) do
        playerObject[key] = value
      end 
    end 
  end 

  updateMenuFrame(nil, { 
    groupMembers = getPlayerGroupMembers()
  })
end)

function getPlayerQueue()
  if not lobbyCache.queue then 
    local queueStatus, modeSelected, customCode = lobbyApi.getPlayerQueue()

    lobbyCache.queue = {
      queue = queueStatus and 'Buscando partida...',
      mode = modeSelected, 
      custom = customCode and { code = customCode }
    }
  end 

  return lobbyCache.queue
end 

RegisterNetEvent('core:updateQueue', function(queueStatus, modeSelected, customCode)
  lobbyCache.queue = {
    queue = queueStatus and 'Buscando partida...',
    mode = modeSelected, 
    custom = customCode and { code = customCode }
  }

  updateMenuFrame(nil, { 
    queue = getPlayerQueue()
  })
end)