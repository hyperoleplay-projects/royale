-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local userGroupsCache = {}
Group = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupLoad - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.load(userId,source)
    userGroupsCache[userId] = {}
    local query = vRP.query("vRP/GetUserGroups",{ user_id = userId })
    if #query > 0 then
        for _,v in pairs(query) do
            if Config.groupsList[v.group] then
                userGroupsCache[userId][v.group] = true
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupHas - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.has(userId,group)
    local source = vRP.getUserSource(userId)
    if source then
        if not userGroupsCache[userId] then
            userGroupsCache[userId] = {}
        end

        if userGroupsCache[userId][group] then
            return true
        end
    else
        local query = vRP.query("vRP/GetUserGroupHas",{ group = group, user_id = userId })
        if #query > 0 then
            return true
        end
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupAdd - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.add(userId,group,staffId)
    local source = vRP.getUserSource(userId)
    local staffSource = vRP.getUserSource(staffId)

    if not Config.groupsList[group] then
        if staffSource then
            TriggerClientEvent("Notify",staffSource,"negado","Grupo <b>"..group.."</b> não existe.")
        end
        return
    end

    if Group.has(userId,group) then
        if staffSource then
            TriggerClientEvent("Notify",staffSource,"negado","Usuário <b>"..userId.."</b> já possui o grupo <b>"..group.."</b>.")
        end
        return
    end

    if source then
        if not userGroupsCache[userId] then
            userGroupsCache[userId] = {}
        end

        userGroupsCache[userId][group] = true
    end

    vRP.execute("vRP/AddGroup", { user_id = userId, group = group })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupRemove - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.remove(userId,group,staffId)
    local source = vRP.getUserSource(userId)
    local staffSource = vRP.getUserSource(staffId)
    if not Config.groupsList[group] then
        if staffSource then
            TriggerClientEvent("Notify",staffSource,"sucess","Grupo <b>"..group.."</b> não existe.")
        end
        return
    end
    
    if userGroupsCache[userId] then
        if userGroupsCache[userId][group] then
            userGroupsCache[userId][group] = nil
        end
    end
    
    vRP.execute("vRP/RemoveGroup", { user_id = userId, group = group })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupHasPermission - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.hasPermission(userId,group)
    
    if not userGroupsCache[userId] then
        return false,group
    end

    if Config.groupsList[group] then
        if userGroupsCache[userId][group] then
            return true,group
        end
        return false,group
    end

    for k,v in pairs(userGroupsCache[userId]) do
        if Config.groupsList[k].role then
            if Config.groupsList[k].role == group then
                return true,k
            end
        end
    end
    return false,group
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupHasAccessOrHigher - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.hasAccessOrHigher(userId,group,search)
    if not userGroupsCache[userId] then
        return false
    end

    if not Config.groupsList[group] then
        return false
    end

    if not Config.groupsList[group].role or not Config.groupsList[group].access then
        return false
    end

    local role = Config.groupsList[group].role
    local access = Config.groupsList[group].access

    if userGroupsCache[userId] then
        for k,v in pairs(userGroupsCache[userId]) do
            if Config.groupsList[k].role then
                if Config.groupsList[k].role == role then
                    if ((search and access < Config.groupsList[k].access) or (not search and access <= Config.groupsList[k].access)) then
                        return true
                    end
                end
            end
        end

        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetAllByPermission - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.getAllByPermission(group,onlyId)
    local returnList = Group.getUsersByPermission(group)
    for k,v in pairs(returnList) do 
        local src = vRP.getUserSource(v)
        if src then 
            if not onlyId then 
                returnList[k] = src
            else
                returnList[k] = v
            end
        end
    end

    return returnList
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetUsersByPermission - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.getUsersByPermission(group)
    local returnList = {}
    if Config.groupsList[group] then
        for k,v in pairs(userGroupsCache) do
            for l,w in pairs(v) do
                if l == group then
                    returnList[#returnList+1] = k
                end
            end
        end
    else
        for k,v in pairs(userGroupsCache) do
            for l,w in pairs(v) do
                if Config.groupsList[l].role then
                    if Config.groupsList[l].role == group then
                        returnList[#returnList+1] = k
                    end
                end
            end
        end
    end

    return returnList
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetUsersByDimension - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.getUsersByDimension(dimension)
    local users_in_dimension = {}

    local users = vRP.getUsers()
    for id,src in pairs(users) do
        if GetPlayerRoutingBucket(src) == dimension then
            table.insert(users_in_dimension,tonumber(id))
        end
    end
    return users_in_dimension
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetHigher - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.getHigher(userId)
    local template = userId
    local higher = template

    if userGroupsCache[userId] then
        for k,v in pairs(userGroupsCache[userId]) do
            if Config.groupsList[k].role then
                if higher == template then
                    higher = k
                end
                    
                if Config.groupsList[higher] == nil or Config.groupsList[higher].access == nil then
                    return k, Group.getSquadName(k)
                end
                
                if Config.groupsList[k] == nil or Config.groupsList[k].access == nil then
                    return higher, Group.getSquadName(k)
                end

                if Config.groupsList[higher].access < Config.groupsList[k].access then
                    return higher
                end
            end
        end
    end
    return higher
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupVerifyOverrideRoles - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function verifyOverrideRoles()
    for k,v in pairs(Config.groupsList) do
        if k == v.role then
            print("^1[ERRO CRUCIAL] ^7Foi encontrado um grupo com o mesmo nome de uma role "..v.role)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- vGrupos - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("vgroups",function(source,args,rawCmd)
    local userId = vRP.getUserId(source)
    if userId then
        if not Group.hasPermission(userId,"staff") then
            return
        end

        if not args[1] then return end
        local targetId = parseInt(args[1])
        local messageStr = ""

        if userGroupsCache[targetId] then
            for k,v in pairs(userGroupsCache[targetId]) do
                messageStr = messageStr.." "..k
            end
            TriggerClientEvent("Notify",source,"importante","Grupos de Usuário <b>"..targetId.."</b> (online):<br>"..messageStr)
        else
            local query = vRP.query("vRP/GetUserGroups",{ user_id = targetId })
            if #query > 0 then
                for _,v in pairs(query) do
                    messageStr = messageStr.." "..v.group
                end
            end
            TriggerClientEvent("Notify",source,"importante","Grupos de Usuário <b>"..targetId.."</b> (offline):<br>"..messageStr)
        end

    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupUserGroups - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.userGroups(targetId)
    if userGroupsCache[targetId] then 
        return userGroupsCache[targetId]
    end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetUserGroups - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Group.getUserGroups(targetId)
    local messageStr = ""
    if not userGroupsCache[targetId] then 
        Group.load(targetId)
    end
    if userGroupsCache[targetId] then
        for k,v in pairs(userGroupsCache[targetId]) do
            messageStr = messageStr.." "..k
        end
    end
    return messageStr
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupGetStaffGroups - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function getStaffGroups()
    local list = {}
    for k,v in pairs(Config.groupsList) do
        if v.role == "WaitStaff" or v.role == "staff" then 
            list[#list+1] = k
        end
    end
    return list
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GroupCreateWaitingGroups - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function createWaitingGroups()
    for k,v in pairs(Config.groupsList) do
        if v.role == "staff" then 
            Config.groupsList["wait"..k] = {
                ["name"] = "Staff",
                ["role"] = "WaitStaff",
            }
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- createWaitingGroups - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    createWaitingGroups()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- tooglestaff - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tooglestaff",function(source,args,rawCmd)
    local userId = vRP.getUserId(source)
    if userId then
        local staffGroups = getStaffGroups()
        for k,v in pairs(staffGroups) do
            if Group.hasPermission(userId, v) then
                if string.find(v, "wait") then
                    Group.alterSquadService(userId,v,splitString(v,"wait")[1],true)
                else
                    Group.alterSquadService(userId,v,"wait"..v,true)
                end
                break
            end
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStart - Event
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStart",function(resourceName)
    Citizen.Wait(300)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    verifyOverrideRoles()

    local users = vRP.getUsers()
    for id,src in pairs(users) do
        Group.load(id)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Group - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Group",function()
    return Group
end)