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

  return true 
end

function updateGuildName(tag, name)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  guildObject.name = name

  vRP._execute('vRP/UpdateGuildName', { tag = tag, name = name })
end

function updateGuildImage(tag, imageURL)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  guildObject.imageURL = imageURL

  vRP._execute('vRP/UpdateGuildImage', { tag = tag, imageURL = imageURL })
end

function removeGuild(tag)
  if not cacheGuilds[tag] then 
    return 
  end 

  cacheGuilds[tag] = nil 

  vRP._execute('vRP/RemoveGuild', { tag = tag })
end

local function updateGuildToUser(userId, tag)
  local userSource = vRP.getUserSource(userId)

  if userSource then 
    TriggerClientEvent('core:updateGuild', userSource, tag)
  end 
end 

function addGuildMember(tag, userId, isOwner)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  table.insert(guildObject.members, {
    userId = userId, 
    role = ROLES_ENUM[1]
  })

  vRP._execute('vRP/AddGuildMember', { tag = tag, userId = userId, role = ROLES_ENUM[isOwner and 1 or 3] })
  updateGuildToUser(userId, tag)
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
      vRP._execute('vRP/UpdateGuildMember', { role = newRole, userId = memberObject.userId, tag = tag })

      return true 
    end 
  end 

  return false 
end 

function removeGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  if not guildObject then 
    return 
  end 

  local isRemoved = false

  for memberIndex = #guildObject.members, -1, 1 do 
    local memberObject = guildObject.members[memberIndex]

    if memberObject.userId == userId then
      table.remove(memberIndex) 

      isRemoved = true
    end 
  end 

  if isRemoved then 
    vRP._execute('vRP/RemoveGuildMember', { tag = tag, userId = userId })
    updateGuildToUser(userId, nil)
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

  local isAccepted = lobbyApi.requestInvite('GUILD', guildObject.tag, guildObject.name)

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