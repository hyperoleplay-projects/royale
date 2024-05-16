local cacheGuilds = {}
local lobbyApi = Tunnel.getInterface('core:lobbyApi')

ROLES_ENUM = {
  OWNER = 1, 
  MANAGER = 2, 
  MEMBER = 3, 

  [1] = 'OWNER',
  [2] = 'MANAGER', 
  [3] = 'MEMBER'
}

local function getTeamCodeByUserId(userId)
  local userSource = vRP.getUserSource(userId)

  if not userSource then 
    return 
  end

  return Player(userSource).state.teamCode
end 

local function syncGroupOfGuildMemberId(userId)
  local teamCode = getTeamCodeByUserId(userId)

  if teamCode then 
    syncGroupMembers(teamCode)
  end
end

local function updateGuildToUser(userId, tag)
  local userSource = vRP.getUserSource(userId)

  if userSource then 
    TriggerClientEvent('core:updateGuild', userSource, tag)
  end 
end 

local function syncGuildTagToMembers(tag)
  local guildObject = cacheGuilds[tag]  

  if not guildObject then 
    return 
  end  

  local groupsToSync = {}

  for _, memberObject in ipairs(guildObject.members) do 
    local teamCode = getTeamCodeByUserId(userId)

    if teamCode then 
      groupsToSync[teamCode] = true 
    end

    updateGuildToUser(memberObject.userId, tag)
  end

  for teamCode in pairs(groupsToSync) do 
    syncGroupMembers(teamCode)
  end
end

local function resetGuildMemberCaches(tag)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  for _, memberObject in ipairs(guildObject.members) do 
    local userSource = vRP.getUserSource(memberObject.userId)

    if userSource then 
      TriggerClientEvent('core:resetGuildCache', userSource)
    end
  end
end 

function tryCreateGuild(tag, name, imageURL)
  if cacheGuilds[tag] then 
    return false 
  end 

  cacheGuilds[tag] = {
    tag = tag, 
    name = name, 
    imageURL = imageURL, 
    members = {}
  }

  vRP._execute('vRP/AddGuild', { tag = tag, name = name, imageURL = imageURL })

  return true
end

function tryUpdateGuildTag(oldTag, newTag)
  if cacheGuilds[newTag] then 
    return false
  end 

  local guildObject = cacheGuilds[oldTag]

  if not guildObject then 
    return false
  end 

  guildObject.tag = newTag

  cacheGuilds[newTag] = guildObject
  cacheGuilds[oldTag] = nil 

  vRP._execute('vRP/UpdateGuildTag', { oldTag = oldTag, newTag = newTag })
  syncGuildTagToMembers(newTag)
  
  return true 
end

function updateGuildName(tag, name)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  guildObject.name = name

  resetGuildMemberCaches(tag)
  vRP._execute('vRP/UpdateGuildName', { tag = tag, name = name })
end

function updateGuildImage(tag, imageURL)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  guildObject.imageURL = imageURL

  resetGuildMemberCaches(tag)
  vRP._execute('vRP/UpdateGuildImage', { tag = tag, imageURL = imageURL })
end

function removeGuild(tag)
  if not cacheGuilds[tag] then 
    return 
  end 

  cacheGuilds[tag] = nil 

  vRP._execute('vRP/RemoveGuild', { tag = tag })
end

function addGuildMember(tag, userId, isOwner)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  table.insert(guildObject.members, {
    userId = userId, 
    role = ROLES_ENUM[ROLES_ENUM.MEMBER]
  })

  vRP._execute('vRP/AddGuildMember', { tag = tag, userId = userId, role = ROLES_ENUM[isOwner and 1 or 3] })

  if not isOwner then 
    updateGuildToUser(userId, tag)
  end 

  syncGroupOfGuildMemberId(userId)
  resetGuildMemberCaches(tag)
end 

function getGuildMemberRoleIndex(tag, userId)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  for _, memberObject in ipairs(guildObject.members) do 
    if memberObject.userId == userId then 
      return ROLES_ENUM[memberObject.role]
    end 
  end 
end 

function tryUpgradeGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 
  
  for _, memberObject in ipairs(guildObject.members) do 
    local currentRoleIndex = ROLES_ENUM[memberObject.role] or 3
    local newRoleIndex = currentRoleIndex - 1

    local newRole = ROLES_ENUM[newRoleIndex]

    if newRole then 
      memberObject.role = newRole

      resetGuildMemberCaches(tag)
      vRP._execute('vRP/UpdateGuildMember', { role = newRole, userId = memberObject.userId, tag = tag })

      return true 
    end 
  end 

  return false 
end 

function tryDowngradeGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 
  
  for _, memberObject in ipairs(guildObject.members) do 
    local currentRoleIndex = ROLES_ENUM[memberObject.role] or 3
    local newRoleIndex = currentRoleIndex + 1

    local newRole = ROLES_ENUM[newRoleIndex]

    if newRole then 
      memberObject.role = newRole
      resetGuildMemberCaches(tag)

      vRP._execute('vRP/UpdateGuildMember', { role = newRole, userId = memberObject.userId, tag = tag })

      return true 
    end 
  end 

  return false 
end 

local function tryFinishGuild(tag)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  if #guildObject.members == 0 then 
    removeGuild(tag)

    return true 
  end

  return false
end 

local function transferOwnerToNextPlayer(tag)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  local firstMajorPlayer = nil 

  for _, memberObject in ipairs(guildObject.members) do 
    local memberRoleIndex = ROLES_ENUM[memberObject.role]

    if not firstMajorPlayer or memberRoleIndex < firstMajorPlayer.roleIndex then 
      firstMajorPlayer = { object = memberObject, roleIndex = memberRoleIndex }
    end
  end 

  if firstMajorPlayer and firstMajorPlayer.roleIndex > ROLES_ENUM.OWNER then 
    local newRole = ROLES_ENUM[ROLES_ENUM.OWNER]

    firstMajorPlayer.object.role = newRole

    vRP._execute('vRP/UpdateGuildMember', { role = newRole, userId = firstMajorPlayer.object.userId, tag = tag })
  end
end 

function removeGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  for memberIndex = #guildObject.members, 1, -1 do 
    local memberObject = guildObject.members[memberIndex]

    if memberObject.userId == userId then
      table.remove(guildObject.members, memberIndex) 
      
      updateGuildToUser(userId, nil)
      syncGroupOfGuildMemberId(userId)

      local wasFinished = tryFinishGuild(tag)

      if not wasFinished then 
        local isMemberOwner = memberObject.role == ROLES_ENUM[ROLES_ENUM.OWNER]
        
        if isMemberOwner then
          transferOwnerToNextPlayer(tag)
        end 

        resetGuildMemberCaches(tag)
        vRP._execute('vRP/RemoveGuildMember', { tag = tag, userId = userId })
      end

      return 
    end 
  end 
end 

function getGuildMembersEntriesByTag(tag)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  local membersEntries = {} 

  for _, guildMember in ipairs(guildObject.members) do 
    local userIdentity = vRP.getIdentity(guildMember.userId)

    table.insert(membersEntries, {
      guildMember.userId, 
      userIdentity.username, 
      ROLES_ENUM[guildMember.role],
      0, -- TODO: Kills system
      0 -- TODO: Deaths system
    })
  end 

  return membersEntries
end 

function getGuildEntriesByTag(tag)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  return {
    guildObject.tag, 
    guildObject.name,
    guildObject.imageURL,
    getGuildMembersEntriesByTag(tag),
  }
end

function getUserGuildTag(userId)
  for _, guildObject in pairs(cacheGuilds) do 
    for _, memberObject in ipairs(guildObject.members) do 
      if memberObject.userId == userId then 
        return guildObject.tag
      end 
    end 
  end 
end

function inviteUserToGuild(tag, userId, userSource)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  local isAccepted = lobbyApi.requestInvite(userSource, 'GUILD', guildObject.tag, guildObject.name)

  if isAccepted then 
    addGuildMember(tag, userId, false)
  end
end

Citizen.CreateThread(function()
  local guildsConsult = vRP.query('vRP/GetGuilds')

  for _, guild in ipairs(guildsConsult) do 
    guild.members = vRP.query('vRP/GetGuildMembers', { tag = guild.tag })

    table.sort(guild.members, function(a, b)
      return a.role < b.role
    end)

    cacheGuilds[guild.tag] = guild
  end 
end)