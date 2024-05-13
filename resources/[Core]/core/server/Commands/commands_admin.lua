
local players = {}
local sources = {}

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- add-vip
-- -----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("add-vip", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

    local vips_category = { "padrao" }

    local function checkNameVip(name) 
        for k,v in pairs(vips_category) do
            if v == name then
                return true 
            end
        end
        return false
    end

    local targetId = vRP.prompt(source, "Insira o passaporte:","")
    if targetId == "" or parseInt(targetId) <= 0 then 
        return TriggerClientEvent("Notify",source,"negado","Insira um passaporte válido.")
    end

    local categoryVip = vRP.prompt(source, "Insira a categoria do vip:",table.concat(vips_category, ', '))
    if categoryVip == "" or not checkNameVip(categoryVip) then 
        return TriggerClientEvent("Notify",source,"negado","Insira uma categoria válida.")
    end

    local daysVip = vRP.prompt(source, "Insira a quantidade de dias:","30")
    if daysVip == "" or parseInt(daysVip) <= 0 then 
        return TriggerClientEvent("Notify",source,"negado","Insira uma quantidade válida.")
    end

    if targetId then
        local nsource = vRP.getUserSource(targetId)
        exports["core"]:Premium().generateVipPerDays({ user_id = targetId, category = categoryVip, timeInDays = parseInt(daysVip) })
        TriggerClientEvent("Notify",source,"inform","Usuário <b>"..parseInt(targetId).."</b> recebeu <b>"..parseInt(daysVip).."</b> dias de VIP <b>"..categoryVip.."</b>.")
        if nsource then
            clientAPI.clearInfoCache(nsource, 'profile')
        end
    end
end)

-- -----------------------------------------------------------------------------------------------------------------------------------------
-- NC
-- -----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("nc",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end
    
    if not Player(source).state.inGame then
        vRPC.toggleNoclip(source)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPTOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tptome",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end
	if not args[1] then return; end
	
	local source2 = vRP.getUserSource(parseInt(args[1]))
	local x,y,z = vRPC.getPosition(source)
	
	if source2 then
        if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev")  then
            if not Player(source).state.inGame and not Player(source2).state.inGame and not Player(source).state.inGameLobby and not Player(source2).state.inGameLobby and not Player(source).state.inAimLab and not Player(source2).state.inAimLab then
                vRPC.teleport(source2,x,y,z) 
        
                local playerDimension = GetPlayerRoutingBucket(source)
                SetPlayerRoutingBucket(source2,parseInt(playerDimension))
            end
        else
            vRPC.teleport(source2,x,y,z) 
        
            local playerDimension = GetPlayerRoutingBucket(source)
            SetPlayerRoutingBucket(source2,parseInt(playerDimension))
        end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- forcejoin-player
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("forcejoin-player", function(sourceee, args, rawCmd) 
    local source = vRP.getUserSource(parseInt(args[1]))
    local identity = vRP.getIdentity(parseInt(args[1]))

    local user_id = vRP.getUserId(sourceee)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	if not args[1] then return; end

    if source then
        Player(source).state.ready = false
        Player(source).state.inTeam = false
        Player(source).state.inTeamNoLeader = true
        Player(source).state.isLeader = false
    
        local infos = ApiController.extractSteam(source)
        local steamHex = infos.steam:gsub("steam:", "")
    
        ApiController.JoinGroup({
            source = source,
            user_id = parseInt(args[1]),
            username = identity.username,
            avatar = identity.avatar, 
            isLeader = false,
            currentCharacterMode = vRP.getUData(parseInt(args[1]),"Barbershop"),
            Clothes = vRP.getUData(parseInt(args[1]),"Clothings"),
            Tatuagens = Player(source).state.userTatuagens,
            ready = false,
            pos = 0,
            state = true,
            hexlast = steamHex,
            death = false,
            agonizing = false,
            isReviving = false,
            color = nil,
            positionGame = 0,
        }, Player(sourceee).state.teamCode)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- forceJump
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("forceJump", function(sourceee, args, rawCmd) 
    local source = vRP.getUserSource(parseInt(args[1]))
    local user_id = vRP.getUserId(sourceee)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	if not args[1] then return; end

    if source then
        GameController.sendPlayerEvent(source, "StopPlane", {})
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- tpto
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tpto", function(source,args,rawCmd) 
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end
	if not args[1] then return; end

	local source2 = vRP.getUserSource(parseInt(args[1]))
	if source2 then

        if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev")  then
            if not Player(source).state.inGame and not Player(source2).state.inGame and not Player(source).state.inGameLobby and not Player(source2).state.inGameLobby and not Player(source).state.inAimLab and not Player(source2).state.inAimLab then
                vRPC.teleport(source,vRPC.getPosition(source2))
        
                local playerDimension = GetPlayerRoutingBucket(source2)
                SetPlayerRoutingBucket(source,parseInt(playerDimension))
            end
        else
            vRPC.teleport(source,vRPC.getPosition(source2))
        
            local playerDimension = GetPlayerRoutingBucket(source2)
            SetPlayerRoutingBucket(source,parseInt(playerDimension))
        end
	end
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- set-roupa
-- -----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("set-roupa", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	if not args[1] then return; end
	if not args[2] then return; end

	local source2 = vRP.getUserSource(parseInt(args[1]))
	local source3 = vRP.getUserSource(parseInt(args[2]))

	local Clothes = vRP.getUData(parseInt(args[1]),"Clothings")
	vRPC.setClothing(source3, Clothes) 
	vRP.setUData(parseInt(args[2]),"Clothings", Clothes)
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- set-roupa
-- -----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("set-duthCoins", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	if not args[1] then return; end
	if not args[2] then return; end
	
	local source2 = vRP.getUserSource(parseInt(args[1]))
	local identity = vRP.getIdentity(parseInt(args[1]))

	vRP.execute('vRP/GiveCoins', { id = args[1], duthCoins = parseInt(args[2]) })
	TriggerClientEvent("Notify",source,"sucess","Você adicionou <b>"..args[2].."</b> Duth Coins para o jogador <b>"..identity.username.."</b>.")

	PerformHttpRequest("https://discord.com/api/webhooks/1114255947569831936/_OoR0ZeTi6hJ2BqjzfkJDus55ohEmRjH5H5GFUsUlcg3c1l1Senb69IVwkxy-CFxSv63",function(err,text,headers)
	   end,"POST",json.encode({
	   embeds = { { color = 16099840, description = "STAFF: **"..user_id.."**\nQuantidade: **"..args[2].."**\nJogador(a): **"..args[1].."**" } }
	}),{ ["Content-Type"] = "application/json" })

	if source2 then
		clientAPI.clearInfoCache(source2, 'profile')
	end
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- NC
-- -----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("grupo",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end
	local source2 = vRP.getUserSource(parseInt(args[2]))

	if args[1] == "add" then
		exports["core"]:Group().add(args[2],args[3],user_id)

		PerformHttpRequest("https://discord.com/api/webhooks/1114255615213187092/nsVZyLVpuUvN7zYSa6P0IYwunfG89paEOXuWujmDY1IpsWJidJybpDmW6yX0wFP1ALZo",function(err,text,headers)
		   end,"POST",json.encode({
		   embeds = { { color = 16099840, description = "STAFF: **"..user_id.."**\nGrupo adicionado: **"..args[3].."**\nJogador(a): **"..args[2].."**" } }
		}),{ ["Content-Type"] = "application/json" })

        TriggerClientEvent("Notify",source,"sucess","Usuário <b>"..args[2].."</b> adicionado à <b>"..args[3].."</b>.")

	elseif args[1] == "rem" then
		exports["core"]:Group().remove(args[2],args[3],user_id)

		PerformHttpRequest("https://discord.com/api/webhooks/1114255615213187092/nsVZyLVpuUvN7zYSa6P0IYwunfG89paEOXuWujmDY1IpsWJidJybpDmW6yX0wFP1ALZo",function(err,text,headers)
		   end,"POST",json.encode({
		   embeds = { { color = 16099840, description = "STAFF: **"..user_id.."**\nGrupo removido: **"..args[3].."**\nJogador(a): **"..args[2].."**" } }
		}),{ ["Content-Type"] = "application/json" })
        TriggerClientEvent("Notify",source,"sucess","Usuário <b>"..args[2].."</b> removido de <b>"..args[3].."</b>.")
	end

	if source2 then
        Group.load(parseInt(args[2]), source2)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Anuncio
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("anuncio", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	local anuncio = vRP.prompt(source,"Anuncio:","")
	if anuncio == "" then
		return
	end

	TriggerClientEvent("Notify", -1,"inform", anuncio, 80000)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TPCDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tpcds",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	local fcoords = vRP.prompt(source,"Cordenadas:","")
	if fcoords == "" then
		return
	end

	local coords = {}
	for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
		table.insert(coords,parseInt(coord))
	end

	vRPC.teleport(source,coords[1] or 0,coords[2] or 0,coords[3] or 0)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CDS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("cds",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	local ped = GetPlayerPed(source)
	local coords = GetEntityCoords(ped)
	local heading = GetEntityHeading(ped)
	vRP.prompt(source,"Cordenadas:",mathLength(coords.x)..","..mathLength(coords.y)..","..mathLength(coords.z)..","..mathLength(heading))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GOD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("god",function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

    if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev")  then
        if not Player(source).state.inGame then
            if args[1] then
                local nplayer = vRP.getUserSource(parseInt(args[1]))
                if nplayer then
                    clientAPI.killGod(nplayer)
                    vRPC.setHealth(nplayer,400)
                    Player(nplayer).state.death = false
                    TriggerClientEvent("favela-core:killPlayer", nplayer)
                end
            else
                clientAPI.killGod(source)
                vRPC.setHealth(source,400)
                Player(source).state.death = false
                TriggerClientEvent("favela-core:killPlayer", source)
            end
        end
    else
        if args[1] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then
                clientAPI.killGod(nplayer)
                vRPC.setHealth(nplayer,400)
                Player(nplayer).state.death = false
                TriggerClientEvent("favela-core:killPlayer", nplayer)
            end
        else
            clientAPI.killGod(source)
            vRPC.setHealth(source,400)
            Player(source).state.death = false
            TriggerClientEvent("favela-core:killPlayer", source)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- remover-avatar
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("remover-avatar", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

    if not args[1] then return; end

    exports.oxmysql:query("UPDATE users SET avatar = ? WHERE id = ?",{ parseInt(args[1]), "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg" })
    TriggerClientEvent("Notify", source, "informe", "Avatar do <b>#"..args[1].."</b> removido.", 1500)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FinishSeason
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("finalizar-season",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	local rows = vRP.query("vRP/getPlayers",{ })

	for k,v in pairs(rows) do 
        exports.oxmysql:query("DELETE FROM ranking WHERE user_id = ?",{ parseInt(v.id) })
        exports.oxmysql:query("DELETE FROM history_games WHERE user_id = ?",{ parseInt(v.id) })
        exports.oxmysql:query("UPDATE users SET duthBattlePass = ? WHERE id = ?",{ parseInt(v.id), "false" })
        exports.oxmysql:query("UPDATE users SET duthBattleXp = ? WHERE id = ?",{ parseInt(v.id), 0 })
        exports.oxmysql:query("UPDATE users SET duthBattleLevel = ? WHERE id = ?",{ parseInt(v.id), 1 })
	end
    
    TriggerClientEvent("Notify", source, "negado", "A season foi finalizada com sucesso.", 1500)

    for _, src in ipairs(GetPlayers()) do
        vRP.kick(src,"A temporada do servidor foi concluída. Conecte-se novamente para participar da nossa emocionante nova temporada!")
    end

end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- item
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("item", function(source, args, rawCmd)
    local user_id = vRP.getUserId(source)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    if user_id then
        local function giveItem(category, spawnName)
            if args[2] and args[3] ~= nil then
                local target_id = tonumber(args[2])
                local nsource = vRP.getUserSource(target_id)
                if nsource then
                    Inventory.GiveItem(nsource, target_id, {
                        category = category,
                        spawnName = spawnName
                    })

					TriggerClientEvent("Notify", source, "negado", string.format("Você adicionou um <b>%s</b> no inventário do jogador(a).", spawnName), 1500)
					PerformHttpRequest("https://discord.com/api/webhooks/1114250614113845318/5jqzZOg-Jo4J09Np7LuoPbNiheLGRUTWJZWTKIn23twyvBXXJNNyUEK7dVoAsdIrBR0O",function(err,text,headers)
					end,"POST",json.encode({
						embeds = { { color = 16099840, description = "STAFF: **"..user_id.."**\nItem: **"..spawnName.."**\nCategoria: **"..category.."**\nJogador(a): **"..target_id.."**" } }
					}),{ ["Content-Type"] = "application/json" })
                end
            else
                TriggerClientEvent("Notify", source, "negado", string.format("Comando usado incorretamente. Forma correta: /item %s <b>id spawn_name</b>.", category), 1500)
            end
        end

        if args[1] == "padrao" then
            if args[2] and args[3] and itemBody(args[2]) ~= nil then
                vRP.generateItem(user_id, args[2], parseInt(args[3]), true)
            end
        elseif args[1] == "roupa" then
            giveItem("clothe", args[3])
        elseif args[1] == "tatuagem" then
            giveItem("tatuagem", args[3])
        elseif args[1] == "barbearia" then
            giveItem("barbearia", args[3])
        elseif args[1] == "skin" then
            giveItem("skin", args[3])
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- item-list
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("item-list", function(source, args, rawCmd)
    local user_id = vRP.getUserId(source)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    local items = {}

    if args[1] == "roupa" then
        for _, clothe in pairs(Config.Clothes) do
			items[#items+1] = clothe.clothe_spawnName
        end
	elseif args[1] == "tatuagem" then
		for _, tatuagem in pairs(Config.Tatuagens) do
			items[#items+1] = tatuagem.tatto_spawnName
        end
	elseif args[1] == "barbearia" then
		for _, barbearia in pairs(Config.Barbearia) do
			items[#items+1] = barbearia.barber_spawnName
        end
	elseif args[1] == "skin" then
		for _, skin in pairs(Config.Skins) do
			items[#items+1] = skin.skin_spawnName
        end
    end

    local columnCount = 4 
    local itemString = ""
    local itemCount = #items
    local rowCount = math.ceil(itemCount / columnCount)
    
    for row = 1, rowCount do
        for col = 1, columnCount do
            local index = col + (row - 1) * columnCount
            if index <= itemCount then
                itemString = itemString .. items[index] .. "\t"
            end
        end
        itemString = itemString .. "\n"
    end

    vRP.prompt(source, "Items:", "\n" .. itemString.."")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("ban",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

	if not args[1] then return end
    
    local banReason = vRP.prompt(source,"Motivo:","")
    if banReason == "" then return end

    local request = exports["core"]:permanentBan({
        user_id = parseInt(args[1]),
        staff_id = parseInt(user_id),
        reason = tostring(banReason)
    })

	PerformHttpRequest("https://discord.com/api/webhooks/1114255309280645160/NhNe_0UcRQIc_embVgE-Dp5lyGar-Mq74Wuoe8J0ycaw27LVydI4cCSIHYqVkWfKQ3Zm",function(err,text,headers)
   	end,"POST",json.encode({
	   embeds = { { color = 16099840, description = "STAFF: **"..user_id.."**\nMotivo: **"..tostring(banReason).."**\nJogador(a): **"..args[1].."**" } }
   	}),{ ["Content-Type"] = "application/json" })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONSOLE-BAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("console-ban",function(source,args,rawCmd)
    if source == 0 then
        if not args[1] then return end
        if not args[2] then return end
    
        local request = exports["core"]:permanentBan({
            user_id = parseInt(args[1]),
            staff_id = parseInt(user_id),
            reason = tostring(args[2])
        })
    
        PerformHttpRequest("https://discord.com/api/webhooks/1114255309280645160/NhNe_0UcRQIc_embVgE-Dp5lyGar-Mq74Wuoe8J0ycaw27LVydI4cCSIHYqVkWfKQ3Zm",function(err,text,headers)
           end,"POST",json.encode({
           embeds = { { color = 16099840, description = "STAFF: **CONSOLE**\nMotivo: **"..tostring(args[2]).."**\nJogador(a): **"..args[1].."**" } }
        }),{ ["Content-Type"] = "application/json" })
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESET-PERSONAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("reset-personagem",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

	if not args[1] then return end

	local identity = vRP.getIdentity(parseInt(args[1]))
	vRP.setUData(parseInt(args[1]),"vRP:spawnController",json.encode(0)) 
	
	local source2 = vRP.getUserSource(parseInt(args[1]))
	if source2 then
		vRP.kick(source2,"Sua aparência foi resetada por um administrador.")
	end
	TriggerClientEvent("Notify",source, "inform", "Aparência resetada de: "..args[1])
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UNBAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("unban",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

	if not args[1] then return end
    
    local request = exports.oxmysql:query_async("SELECT * FROM bans WHERE user_id = ?",{ parseInt(args[1]) })
    if request[1] then
		exports.oxmysql:query("DELETE FROM bans WHERE user_id = ?",{ parseInt(args[1]) })
		TriggerClientEvent("Notify",source,"sucess","Você desbaniu o jogador <b>"..args[1].."</b>")
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- whitelist 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("wl", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

	if not args[1] then return end
	
	TriggerClientEvent("Notify",source,"sucess","Você aprovou o ID <b>"..args[1].."</b>!")
	vRP.execute("vRP/set_whitelisted", { user_id = parseInt(args[1]), whitelisted = true })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMPBAN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tempban",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

	if not args[1] then return end
    
    local banReason = vRP.prompt(source,"Motivo:","")
    if banReason == "" then return end

    local timeBan = vRP.prompt(source,"Tempo de ban em dias: (1,2,3)","")
    if timeBan == "" then return end

    exports["core"]:temporaryBan({
        user_id = parseInt(args[1]),
        staff_id = parseInt(user_id),
        reason = tostring(banReason),
        timeBan = timeBan
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- rename - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("rename", function(source, args, rawCmd) 
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end

    local targetId = vRP.prompt(source, "Insira o passaporte:","")
    if targetId == "" or parseInt(targetId) <= 0 then 
        return TriggerClientEvent("Notify", source,"negado","Insira um passaporte válido.")
    end

    local otherIdentity = vRP.getIdentity(targetId)
    local newName = vRP.prompt(source, "Novo nome (Tab para não alterar):",""..otherIdentity.username)
    if newName == "" or #newName < 2 then 
        TriggerClientEvent("Notify",source,"negado","Formato invalido.",6000)
        return false
    end

    local formatted, amountChar = newName:gsub("%W", "" )
    if amountChar >= 1 then 
        TriggerClientEvent("Notify",source,"negado","Remova os caracteres especiais ou espaçamentos.",6000)
        return false
    end

	vRP.execute("vRP/updateIdentity", { id = targetId, username = newName == "" and otherIdentity.username or newName })
	Wait(500)
	vRP.updateIdentity(targetId)

    TriggerClientEvent("Notify",source,"sucesso","Identidade atualizada com sucesso.")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MATHLEGTH
-----------------------------------------------------------------------------------------------------------------------------------------
function mathLength(n)
	return math.ceil(n * 100) / 100
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER DROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerDropped",function(user_id,source,first_spawn)
    if players[source] then
        players[source] = {}
        for k,v in pairs(sources) do
            clientAPI.updateList(v,players)
        end
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVERSYNC
-----------------------------------------------------------------------------------------------------------------------------------------
function serverSync()
    local users = vRP.getUsers()
    
    for k,v in pairs(users) do
        local identity = vRP.getIdentity(k)
        local playerName = identity.username
        players[v] = { user_id = k, name = playerName, group = exports["core"]:Group().getUserGroups(k) }
    end

    for k,v in pairs(sources) do
        clientAPI.updateList(v,players)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESOURCESTART
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStart",function(resName)
    if resName ~= GetCurrentResourceName() then 
        return
    end

    serverSync()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMINCOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("am",function(source, args, rawCmd)
	local user_id = vRP.getUserId(source)
	if not exports["core"]:Group().hasPermission(user_id,"staff") then
        return
    end

    serverSync()

    if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev")  then
        if not Player(source).state.inGame then
            clientAPI.toggleAdmin(source,args[1])
        end
    else
        clientAPI.toggleAdmin(source,args[1])
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTAM
-----------------------------------------------------------------------------------------------------------------------------------------
function src.startAm()
    local source = source 
    local user_id = vRP.getUserId(source)

    sources[user_id] = source
    clientAPI.updateList(source,players)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOPAM
-----------------------------------------------------------------------------------------------------------------------------------------
function src.stopAm()
    local source = source 
    local user_id = vRP.getUserId(source)

    if sources[user_id] == source then
        sources[user_id] = nil
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADMINUPDATECOMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("am-update",function(source, args, rawCmd)
    local source = source
    local user_id = vRP.getUserId(source)

    serverSync()
end)