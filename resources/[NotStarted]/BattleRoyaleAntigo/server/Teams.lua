-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
TeamsOrg = {}
local TeamsActives = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- prepareTeams - Functions
-----------------------------------------------------------------------------------------------------------------------------------------
function TeamsOrg.prepareTeams() 
    local rows = vRP.query("vRP/GetTeams",{ })

    for _, team in pairs(rows) do 
        TeamsActives[team.roleId] = {
            roleId = team.roleId,
            roleItems = json.decode(team.roleItems),
            roleNameTag = team.roleNameTag
        }
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadTeamUser - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function TeamsOrg.LoadTeamUser(source, user_id, callback)
    local identity = vRP.getIdentity(user_id)
    local hasOrgRole = false
    local hasMessage = false
    local hasMessage2 = false
    local tagToAdd = ""
    local tagToRemove = ""
    
    Citizen.SetTimeout(2000, function()
        for k, role in pairs(TeamsActives) do
            if DiscordSync.HasDiscordRole(user_id, role.roleId) then
                for itemS, itemArray in pairs(role.roleItems) do
                    for _, item in ipairs(itemArray) do
                        if not Inventory.ConsultItemDiscord(source, user_id, item.name, "team") then
                            vRP.execute('vRP/giveItem', {
                                user_id = user_id,
                                inventory_itemName = item.name,
                                inventory_itemStatus = "false",
                                inventory_itemType = item.category,
                                inventory_generate = "team",
                            })
                        end
                    end
                end
                hasOrgRole = true
                tagToAdd = role.roleNameTag
            else
                tagToRemove = role.roleNameTag
            end
            Citizen.Wait(50)
        end

        local username = identity.username
        local newUsername = username

        for k, role in pairs(TeamsActives) do
            if role.roleNameTag ~= tagToAdd then
                local tagToRemovePattern = "%[%s*" .. role.roleNameTag .. "%s*%]"
                newUsername = string.gsub(newUsername, tagToRemovePattern, "")
            end
        end

        newUsername = string.gsub(newUsername, "^%s*%[(.-)%]%s*$", "%1")
        newUsername = string.gsub(newUsername, "^%s*(.-)%s*$", "%1")
        newUsername = string.gsub(newUsername, "%s+", " ")

        if hasOrgRole and tagToAdd ~= "" and not string.find(newUsername, tagToAdd, 1, true) then
            newUsername = "[" .. tagToAdd .. "] " .. newUsername
            if not hasMessage2 then
                hasMessage2 = true
            end
            TriggerClientEvent("Notify",source,"inform", "Olá, <b>"..newUsername.."</b>! Seja muito bem-vindo ao DUTH! Acabamos de adicionar a NameTag <b>[" .. tagToAdd .. "]</b> em você. Parabéns!", 18000)
        end

        vRP.execute("vRP/updateIdentity", { id = user_id, username = newUsername })
        vRP.updateIdentity(user_id)

        if callback then
            callback()
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- team - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("team", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
    if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end
    
    if not args[1] then return; end
	if not args[2] then return; end

    if args[1] == "add" then
        if not args[3] then return; end
        vRP.execute('vRP/AddTeam', {
            roleId = args[2],
            roleNameTag = args[3],
        })
        Teams.prepareTeams()
        TriggerClientEvent("Notify",source,"inform", "Equipe "..args[3].." criada.", 18000)
    end

    if args[1] == "addItem" then
        if not args[3] then return; end
        if not args[4] then return; end

        table.insert(TeamsActives[args[2]].roleItems, {
            { name = args[3], category = args[4] }
        })

        vRP.execute('vRP/UpdateTeam', {
            roleId = args[2],
            roleItems = json.encode(TeamsActives[args[2]].roleItems),
        })
        TriggerClientEvent("Notify",source,"inform", "Você adicionou "..args[3].." na equipe "..args[2]..".", 18000)
        Teams.prepareTeams()
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateThread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    TeamsOrg.prepareTeams()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Teams - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Teams",function()
    return TeamsOrg
end)