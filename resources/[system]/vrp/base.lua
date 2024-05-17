-----------------------------------------------------------------------------------------------------------------------------------------
-- IDS
-----------------------------------------------------------------------------------------------------------------------------------------
local sourcesIds = {}
local playerCount = 0 

AddEventHandler('playerJoining', function(oldSource)
    local source = source 

    source = tostring(source)
    oldSource = tostring(oldSource)

    if sourcesIds[oldSource] then
        sourcesIds[source] = sourcesIds[oldSource]
        sourcesIds[oldSource] = nil
    end
end)

local function GetPlayerIdentifiers(source)
    return sourcesIds[tostring(source)]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
vRP = {}
Proxy.addInterface("vRP", vRP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TUNNELS
-----------------------------------------------------------------------------------------------------------------------------------------
tvRP = {}
Tunnel.bindInterface("vRP", tvRP)
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local allowlistEvent = {}
local isDevMode = false
local isClosedBeta = true
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local passwordCard = {["type"]="AdaptiveCard",["minHeight"]="100px",["body"]={{["type"]="Container",["items"]={{["type"]="TextBlock",["horizontalAlignment"]="Left",["text"]="CODIGUIN",},{["type"]="Input.Text",["id"]="password",["placeholder"]="INFORME O CODIGUIN"},{["type"]="Container",["isVisible"]=false,["items"]={{["type"]="TextBlock",["weight"]="Bolder",["color"]="Attention",["text"]="ESSE CODIGUIN NÃO EXISTE OU JÁ FOI UTILIZADO."}}}}}},["actions"]={{["type"]="Action.Submit",["title"]="ENVIAR"}},["$schema"]="http://adaptivecards.io/schemas/adaptive-card.json",["version"]="1.2"}
-----------------------------------------------------------------------------------------------------------------------------------------
-- MYSQL
-----------------------------------------------------------------------------------------------------------------------------------------
local mysqlDriver
local userSql = {}
local mysqlInit = false
local maintenance = false
local usersLogin = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
-----------------------------------------------------------------------------------------------------------------------------------------
local cacheQuery = {}
local cachePrepare = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- REGISTERDBDRIVER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.registerDBDriver(name,on_init,on_prepare,on_query)
	if not userSql[name] then
		userSql[name] = { on_init,on_prepare,on_query }
		mysqlDriver = userSql[name]
		mysqlInit = true

		for _,prepare in pairs(cachePrepare) do
			on_prepare(table.unpack(prepare,1,table.maxn(prepare)))
		end

		for _,query in pairs(cacheQuery) do
			query[2](on_query(table.unpack(query[1],1,table.maxn(query[1]))))
		end

		cachePrepare = {}
		cacheQuery = {}
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATETXT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.updateTxt(archive,text)
	archive = io.open("resources/logsystem/"..archive,"a")
	if archive then
		archive:write(text.."\n")
	end

	archive:close()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.prepare(name,query)
	if mysqlInit then
		mysqlDriver[2](name,query)
	else
		table.insert(cachePrepare,{ name,query })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERY
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.query(name,params,mode)
	if not mode then mode = "query" end

	if mysqlInit then
		return mysqlDriver[3](name,params or {},mode)
	else
		local r = async()
		table.insert(cacheQuery,{{ name,params or {},mode },r })
		return r:wait()
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXECUTE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.execute(name,params)
	return vRP.query(name,params,"execute")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORMAT
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.format(n)
	local left,num,right = string.match(n,"^([^%d]*%d)(%d*)(.-)$")
	return left..(num:reverse():gsub("(%d%d%d)","%1."):reverse())..right
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERBYIDENTIFIER [MQCU]
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserIdByIdentifier(ids)
	local rows = vRP.query("vRP/userid_byidentifier",{ identifier = ids})
	if #rows > 0 then
		return rows[1].user_id
	else
		return -1
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERBYIDENTIFIERS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserByIdentifiers(ids)
    if ids and #ids then
        for i = 1, #ids do
            if (string.find(ids[i], "ip:") == nil) then
                local rows = vRP.query("vRP/userid_byidentifier", { identifier = ids[i] })
                if #rows > 0 then
                    return rows[1].user_id
                end
            end
        end     

        local rows = exports.oxmysql:query_async("INSERT INTO users(whitelisted) VALUES(@whitelisted)",{ whitelisted = false })
        local user_id = rows.insertId
        
        for l, w in pairs(ids) do
            if (string.find(w, "ip:") == nil) then
                vRP.execute("vRP/add_identifier", { user_id = user_id, identifier = w })
            end
        end
        return user_id
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETSDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setUData(user_id, key, value)
    vRP.execute("vRP/set_userdata", { user_id = user_id, key = key, value = value })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUData(user_id, key, cbr)
    local rows = vRP.query("vRP/get_userdata", { user_id = user_id, key = key })
    if #rows > 0 then
        return rows[1].dvalue
    else
        return ""
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETSDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.setSData(key, value)
    vRP.execute("vRP/set_srvdata", { key = key, value = value })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETSDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getSData(key, cbr)
    local rows = vRP.query("vRP/get_srvdata", { key = key })
    if #rows > 0 then
        return rows[1].dvalue
    else
        return ""
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERDATATABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserDataTable(user_id)
    return vRP.user_tables[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERTMPTABLE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserTmpTable(user_id)
    return vRP.user_tmp_tables[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERID
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserId(source)
    if source ~= nil then
        local ids = GetPlayerIdentifiers(source)
        if ids ~= nil and #ids > 0 then
            return vRP.users[ids[1]]
        end
    end
    return nil
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUsers()
    local users = {}
    for k, v in pairs(vRP.user_sources) do
        users[k] = v
    end
    return users
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GETUSERSOURCE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserSource(user_id)
    return vRP.user_sources[user_id]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- KICK
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.kick(source, reason)
    DropPlayer(source, reason)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DROPPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.dropPlayer(source)
    local source = source
    local user_id = vRP.getUserId(source)
    vRPclient._removePlayer(-1, source)
    if user_id then
        if user_id and source then
            TriggerEvent("vRP:playerLeave", user_id, source)
            local user_datatable = vRP.getUserDataTable(user_id)
        end

        vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.getUserDataTable(user_id)))
        vRP.users[vRP.rusers[user_id]] = nil
        vRP.rusers[user_id] = nil
        vRP.user_tables[user_id] = nil
        vRP.user_tmp_tables[user_id] = nil
        vRP.user_sources[user_id] = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped", function(reason)
    local source = source
    vRP.dropPlayer(source)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERSPAWNED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.user_sources[user_id] = source
        local tmp = vRP.getUserTmpTable(user_id)
        tmp.spawns = tmp.spawns + 1
        local first_spawn = (tmp.spawns == 1)

        if first_spawn then
            for k, v in pairs(vRP.user_sources) do
                vRPclient._addPlayer(source, v)
            end
            vRPclient._addPlayer(-1, source)
        end
        TriggerEvent("vRP:playerSpawn", user_id, source, first_spawn)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETEVENTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("set-dev",function(source,args,rawCmd)
    if source ~= 0 then 
        local user_id = vRP.getUserId(source)
    
        if not vRP.hasPermission(user_id) then 
            return 
        end

        if not isDevMode then
            TriggerClientEvent("Notify", source, "sucess", "Sistema de desenvolvedor ativado.", 15000)
        else
            TriggerClientEvent("Notify", source, "sucess", "Sistema de desenvolvedor desativado.", 15000)
        end
    else 
        if not isDevMode then
            print("^2[ DEV ] ^7Sistema de desenvolvedor ativado.")
        else
            print("^2[ DEV ] ^7Sistema de desenvolvedor desativado.")
        end
    end 

    isDevMode = not isDevMode
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDWHITELISTEVENTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("addwldev",function(source,args,rawCmd)
    if not args[1] then return end
    local user_id = vRP.getUserId(source)

    if not vRP.hasPermission(user_id) then 
        return 
    end

    allowlistEvent[parseInt(args[1])] = true
    TriggerClientEvent("Notify", source, "sucess", ""..parseInt(args[1]).." adicionado na Whitelist do modo desenvolvedor.", 15000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMWHITELISTEVENTO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("remwldev",function(source,args,rawCmd)
    if not args[1] then return end
    local user_id = vRP.getUserId(source)
    if not vRP.hasPermission(user_id) then 
        return 
    end

    allowlistEvent[parseInt(args[1])] = false
    TriggerClientEvent("Notify", source, "sucess", ""..parseInt(args[1]).." removido do modo desenvolvedor.", 15000)

end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- showPasswordCard
-----------------------------------------------------------------------------------------------------------------------------------------
function showPasswordCard(deferrals, callback, showError, numAttempts)
    local card = passwordCard
    card.body[1].items[3].isVisible = showError and true or false
    if showError then
        card.body[1].items[3].items[1].text = "ESSE CODIGUIN NÃO EXISTE OU JÁ FOI UTILIZADO."
        deferrals.done("ESSE CODIGUIN NÃO EXISTE OU JÁ FOI UTILIZADO.")
    end
    deferrals.presentCard(card, callback)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- QUEUECONNECTING
-----------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler("Queue:playerConnecting",function(source,ids,deferrals)
	deferrals.defer()

	local source = source
    local ids = ids

    if ids == nil or #ids <= 0 then
        deferrals.done("Você teve um problema de identidade (ids).")
		TriggerEvent("Queue:removeQueue",ids)
        
        return
    end

    if isDevMode then 
        playerCount = playerCount + 1 

        for i in pairs(ids) do 
            ids[i] = ids[i]:gsub(":", ":".. playerCount.. ":")
        end 
    end 

    sourcesIds[tostring(source)] = ids

    local user_id = vRP.getUserByIdentifiers(ids)

    if not user_id then
        deferrals.done("Você teve um problema de identidade (user_id).")
		TriggerEvent("Queue:removeQueue",ids)

        return
    end

    deferrals.defer()
    
    local bannedInfos = exports["core"]:checkBan({ user_id = user_id })
    if not bannedInfos.canJoin then
        if bannedInfos["request"]["reason"] then
            if bannedInfos["request"]["type"] == "temporary" then
                deferrals.done("\n\n[ ERRO DE CONEXÃO ]\n\nVocê foi banido temporariamente do servidor.\n\nData de expiração: "..formatTempBan(bannedInfos["request"].time).."\nSeu ID: "..user_id.."\nMotivo: "..bannedInfos["request"]["reason"].."\n\nAcha que seu banimento foi injusto? Abra um ticket para recorrer.")
            else
                deferrals.done("\n\n[ ERRO DE CONEXÃO ]\n\nVocê foi banido do servidor.\n\nSeu ID: "..user_id.."\nMotivo: "..bannedInfos["request"]["reason"].."\n\nAcha que seu banimento foi injusto? Abra um ticket para recorrer.")
            end
            TriggerEvent("Queue:removeQueue", ids)
        else
            deferrals.done("\n\n[ ERRO DE CONEXÃO ]\n\nVocê foi banido do servidor.\n\nSeu ID: "..user_id.."\n\nAcha que seu banimento foi injusto? Abra um ticket para recorrer.")
            TriggerEvent("Queue:removeQueue", ids)
        end
        
        deferrals.done("\n\n[ ERRO DE CONEXÃO ]\n\nVocê foi banido do servidor.\n\nSeu ID: "..user_id.."\nMotivo: "..bannedInfos["request"]["reason"].."\n\nAcha que seu banimento foi injusto? Abra um ticket para recorrer.")
        print("^1[ CONEXÃO ] ^7"..user_id.." tentou-se conectar estando banido ("..bannedInfos["request"]["reason"]..").")
        return
    end

    if isDevMode and user_id > 10 then
        deferrals.update("\n\n[ DEV MODE ]\n\nOlá, "..GetPlayerName(source).."! Informamos que nosso servidor está passando por uma atualização rápida para aprimorar a experiência de todos vocês. \nPedimos que fiquem atentos ao nosso Discord para serem notificados assim que a liberação ocorrer. \n\nPrometemos que o processo não irá demorar muito! \n\n\n\nAgradecemos a compreensão de todos e estamos ansiosos para apresentar as melhorias em breve.")
        
        return
    end
    
    -- Data verifys
    local dataRequest = exports.oxmysql:query_async("SELECT whitelisted FROM users WHERE id = ?",{ user_id })

    if not dataRequest[1] then
        return
    end

    if dataRequest[1].whitelisted == 0 then
        deferrals.done("\n\n[ ERRO DE CONEXÃO ]\n\n Você ainda não está liberado para entrar em nosso servidor, mas não se preocupe, para resolver isto basta seguir os passos abaixo.\n\n1: Entre em nosso servidor do discord (discord.gg/Xb3g62fZnC)\n2: Envie seu ID ("..user_id..") no canal de liberação\n3: E pronto! Basta reconectar ao servidor que sua conta já estará liberada =D\n")
        TriggerEvent("Queue:removeQueue", ids)

        return
    end

    -- Login
    print("^2[ CONEXÃO ] ^7"..user_id.." conectou-se ao servidor.")
    
    if vRP.rusers[user_id] == nil then
        local sdata = vRP.getUData(user_id,"vRP:datatable")

        vRP.users[ids[1]] = user_id
        vRP.rusers[user_id] = ids[1]
        vRP.user_tables[user_id] = {}
        vRP.user_tmp_tables[user_id] = {}
        vRP.user_sources[user_id] = source

        local data = json.decode(sdata)
        if type(data) == "table" then
            vRP.user_tables[user_id] = data
        end

        local tempTable = vRP.getUserTmpTable(user_id)
        tempTable.spawns = 0

        TriggerEvent("vRP:playerJoin", user_id, source)
        deferrals.done()
    else
        local tempTable = vRP.getUserTmpTable(user_id)
        tempTable.spawns = 0

        TriggerEvent("vRP:playerRejoin", user_id, source)
        deferrals.done()
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FORMATTEMPBAN
-----------------------------------------------------------------------------------------------------------------------------------------
function formatTempBan(seconds)
    local temp = os.date("*t", parseInt(seconds))
    local txt = temp.day .. "/" .. temp.month .. "/" .. temp.year .. " - " .. temp.hour .. ":" .. temp.min .. ":" .. temp.sec
    return txt
end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- TASKSAVE
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function task_save_datatables()
--     SetTimeout(200000, task_save_datatables)
--     for k, v in pairs(vRP.user_tables) do
--         vRP.setUData(k,"vRP:datatable",json.encode(v))
--     end
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- TASKSAVE
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- async(function()
--     task_save_datatables()
-- end)