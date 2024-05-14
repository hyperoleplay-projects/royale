local cacheGuilds = {}

ROLES_ENUM = {
  OWNER = 1, 
  MANAGER = 2, 
  MEMBER = 3, 

  1 = 'OWNER',
  2 = 'MANAGER', 
  3 = 'MEMBER'
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
end

function updateGuildName(tag, name)
end

function updateGuildImage(tag, imageURL)
end

function removeGuild(tag)
end

function addGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  table.insert(guildObject.members, {
    userId = userId, 
    role = ROLES_ENUM[1]
  })

  vRP._execute('vRP/AddGuildMember', { tag = tag, userId = userId })
end 

function upgradeGuildMember(tag, userId)
end 

function downgradeGuildMember(tag, userId)
end 

function removeGuildMember(tag, userId)
  local guildObject = cacheGuilds[tag]

  for memberIndex = #guildObject.members, -1, 1 do 
    local memberObject = guildObject.members[memberIndex]

    if memberObject.userId == userId then
      table.remove(memberIndex) 
    end 
  end 

  vRP._execute('vRP/RemoveGuildMember', { tag = tag, userId = userId })
end 

function getGuildEntriesByTag(tag)
  local guildObject = cacheGuilds[tag]
  local membersComplete = {} 

  for _, guildMember in ipairs(guildObject.members) do 
    local userIdentity = vRP.getIdentity(guildMember.userId)

    table.insert(membersComplete, {
      guildMember.userId, 
      userIdentity.username, 
      ROLES_ENUM[guildMember.role],
      0, 
      0
    })
  end 

  return {
    guildObject.tag, 
    guildObject.name,
    guildObject.imageURL,
    membersComplete,
  }
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