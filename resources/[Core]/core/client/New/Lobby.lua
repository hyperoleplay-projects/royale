local lobbyApi = Tunnel.getInterface('core:lobbyApi')

local lobbyCache = {}
local guildCache = { value = nil, updatedAt = 0 }

local PLAYER_ID = PlayerId()
local PLAYER_SOURCE = GetPlayerServerId(PLAYER_ID)

local function RegisterNUICallback(name, callback)
  _G.RegisterNUICallback(name, function(data, responseTrigger)
    print('Request '.. name.. ':', json.encode(data))
    return callback(data, function(responseData)
      print('Response '.. name.. ':', json.encode(responseData))
      responseTrigger(responseData)
    end)
  end)
end

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
    print('State bag change', json.encode({ isReady = bagValue }))
    updateMenuFrame(nil, { isReady = bagValue })
  end
)

local function tryResetGuildCache(newTag)
  local guildCache = getGuildOfCache()
  local canResetCache = guildCache and guildCache.page.tag ~= newTag

  if canResetCache then 
    setGuildOfCache(nil)

    return true 
  end

  return false
end 

function getPlayerGuildTag()
  if not lobbyCache.guild then 
    lobbyCache.guild = {
      tag = lobbyApi.getPlayerGuildTag()
    }

    tryResetGuildCache(lobbyCache.guild.tag)
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
  if not lobbyCache.profile then 
    lobbyCache.profile = lobbyApi.getPlayerProfile()
  end 
  
  return lobbyCache.profile
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
    queue = queueStatus and 'Aguardando',
    mode = modeSelected, 
    custom = customCode and { code = customCode }
  }

  updateMenuFrame(nil, { 
    match = getPlayerQueue()
  })
end)

function getGuildOfCache()
  local timeNow = GetGameTimer() 
  local isValueValid = (guildCache.updatedAt - timeNow) > 1 * 60 * 1000

  if isValueValid then 
    return 
  end

  return guildCache.value
end 

function setGuildOfCache(guildObject)
  local timeNow = GetGameTimer() 

  guildCache =  {
    value = guildObject, 
    updatedAt = timeNow
  }
end 

function getGuildMemberObjectByEntries(guildMemberEntries)
  local memberId, memberName, memberRoleIndex, memberKills, memberDeaths = table.unpack(guildMemberEntries)

  return {
    id = memberId,
    name = memberName,
    role = memberRoleIndex,
    kills = memberKills, 
    deaths = memberDeaths
  }
end 

function getGuildObjectByEntries(guildEntries)
  local playerProfile = getPlayerProfile()
  local selfPlayer = nil 

  local guildTag, guildName, guildImageURL, guildMembers = table.unpack(guildEntries)

  for index, memberEntries in ipairs(guildMembers) do 
    guildMembers[index] = getGuildMemberObjectByEntries(memberEntries)

    if guildMembers[index].id == playerProfile.id then 
      selfPlayer = guildMembers[index]
    end 
  end

  return {
    self = {
      id = selfPlayer.id,
      role = selfPlayer.role,
    }, 

    page = {
      tag = guildTag,
      name = guildName,
      imageURL = guildImageURL
    },

    members = guildMembers
  }
end 

RegisterNUICallback('showGuild', function(data, responseTrigger)
  local guildObject = getGuildOfCache()

  if not guildObject then 
    local hasGuild, guildEntries = lobbyApi.getPlayerGuild()

    if hasGuild then 
      guildObject = getGuildObjectByEntries(guildEntries)
      
      setGuildOfCache(guildObject)
    end 
  end 

  responseTrigger({ status = not not guildObject, data = guildObject  })
end)

RegisterNUICallback('createGuild', function(data, responseTrigger)
  lobbyApi._tryCreateGuild(data.tag, data.name, data.imageURL)

  responseTrigger({ })
end)

local function tryUpdateGuildMembersEntries(guildMembers)
  if not guildMembers then 
    return 
  end

  for index, memberEntries in ipairs(guildMembers) do 
    guildMembers[index] = getGuildMemberObjectByEntries(memberEntries)
  end

  local guildObject = getGuildOfCache()

  if guildObject then 
    guildObject.members = guildMembers
  end 

  return guildMembers
end

RegisterNUICallback('upgradeGuildMemberRole', function(data, responseTrigger)
  local guildMembersEntries = lobbyApi.upgradeGuildMember(data.id)
  local guildMembers = tryUpdateGuildMembersEntries(guildMembersEntries)

  responseTrigger({
    status = not not guildMembers,
    data = guildMembers
  })
end)

RegisterNUICallback('downgradeGuildMemberRole', function(data, responseTrigger)
  local guildMembersEntries = lobbyApi.downgradeGuildMember(data.id)
  local guildMembers = tryUpdateGuildMembersEntries(guildMembersEntries)

  responseTrigger({
    status = not not guildMembers,
    data = guildMembers
  })
end)

RegisterNUICallback('kickGuildMember', function(data, responseTrigger)
  local guildMembersEntries = lobbyApi.kickGuildMember(data.id)
  local guildMembers = tryUpdateGuildMembersEntries(guildMembersEntries)

  responseTrigger({
    status = not not guildMembers,
    data = guildMembers
  })
end)

RegisterNUICallback('searchUserToGuildInvite', function(data, responseTrigger)
  local userEntriesToCard = lobbyApi.getUserAvailableToGuild(data.id)

  if userEntriesToCard then 
    local userId, userName, userKills, userDeaths = table.unpack(userEntriesToCard)

    responseTrigger({
      status = true,
      data = {
        id = userId, 
        name = userName, 
        kills = userKills, 
        deaths = userDeaths
      }
    })
  else 
    responseTrigger({
      status = false
    })
  end 
end)

RegisterNUICallback('inviteUserToGuild', function(data, responseTrigger)
  local isInvited = lobbyApi.tryInviteUserToGuild(data.id)

  responseTrigger({ status = isInvited })
end)

RegisterNUICallback('changeGuildName', function(data, responseTrigger)
  responseTrigger({ status = lobbyApi.tryChangeGuildName(data.value) })
end)

RegisterNUICallback('changeGuildTag', function(data, responseTrigger)
  responseTrigger({ status = lobbyApi.tryChangeGuildTag(data.value) })
end)

RegisterNUICallback('changeGuildLogo', function(data, responseTrigger)
  responseTrigger({ status = lobbyApi.tryChangeGuildImage(data.value) })
end)

RegisterNUICallback('changeMatchMode', function(data, responseTrigger)
  lobbyApi._updateGroupQueue(data.mode, data.code)

  responseTrigger({ status = true })
end)

RegisterNUICallback('inviteUserToGroup', function(data, responseTrigger)
  -- TODO: Implement this function
  -- data.id - number

  responseTrigger({ status = true })
end)

RegisterNUICallback('leftOfGroup', function(data, responseTrigger)
  lobbyApi._leaveOfCurrentGroup()

  responseTrigger({ status = true })
end)

RegisterNUICallback('toggleReadyToMatch', function(data, responseTrigger)
  if LocalPlayer.state.isLeader then 
    local queue = getPlayerQueue()

    if queue and queue.custom then 
      lobbyApi._tryJoinInEvent()
    else 
      lobbyApi._tryStartGame()
    end 
  else 
    lobbyApi._tryReadyToGame()
  end 

  responseTrigger({ })
end)