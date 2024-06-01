local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPC = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")
cRP = {}
Tunnel.bindInterface("duth",cRP)
vCLIENT = Tunnel.getInterface("duth")
vCLIENTBattle = Tunnel.getInterface("core")

events = {}
cache = {}
vRP._prepare("vRP/getItensShop","SELECT * FROM shop")
vRP._prepare("vRP/getItensPasse","SELECT * FROM passe")
vRP._prepare("vRP/getItensPasseWhere","SELECT * FROM passe WHERE type = @type AND sex = @sex")
vRP._prepare("vRP/getItensDuthDrop","SELECT * FROM duth_drop")

vRP._prepare("vRP/getItensShopForCategorie","SELECT * FROM shop WHERE item_category = @item_category")
vRP._prepare("vRP/getItensShopForCategorieClothes","SELECT * FROM shop WHERE item_category = @item_category AND item_sex = @item_sex")

vRP._prepare("vRP/getPlayerGlobalRanking","SELECT *, FIND_IN_SET( points, (SELECT GROUP_CONCAT( points ORDER BY points DESC) FROM ranking WHERE gamemode = @gamemode )) AS rank FROM ranking WHERE gamemode = @gamemode ORDER BY `rank` ASC LIMIT 120")
vRP._prepare("vRP/getPlayerRanking","SELECT *, FIND_IN_SET( points, (SELECT GROUP_CONCAT( points ORDER BY points DESC ) FROM ranking WHERE gamemode = @gamemode )) AS rank FROM ranking WHERE gamemode = @gamemode AND user_id = @user_id")
vRP._prepare("vRP/updateProfile","UPDATE users SET avatar = @avatar, username = @username WHERE id = @id")
vRP._prepare("vRP/updateProfileTitle","UPDATE users SET CustomTitle = @CustomTitle WHERE id = @id")
vRP._prepare("vRP/getHistoryGames","SELECT * FROM history_games WHERE user_id = @user_id AND gamemode = @gamemode")

vRP._prepare("vRP/GetPaymentsRequests","SELECT * FROM payments_requests")
vRP._prepare('vRP/deletePaymentRequest','DELETE FROM payments_requests WHERE id = @id')

local gamemodesList = {
    ["solo"] = {
        title = "solo"
    },

    ["duo"] = {
        title = "duo"
    },

    ["squad"] = {
        title = "squad"
    },
}

function cRP.requestData(name, data)
    local src = source
    if events[name] then
        return events[name](src, data.data)
    end
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end

RegisterServerEvent(GetCurrentResourceName())
AddEventHandler(GetCurrentResourceName(), function()
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id == 1 then
        return;
    end
    
    exports.oxmysql:query_async("INSERT INTO bans (user_id,reason,type,staff_id) VALUES (?,?,?,?)",{ parseInt(user_id),tostring("Tentou abrir o nui devtools"),tostring("permanent"),parseInt(0) })
    DropPlayer(source, "\n\nSeu acesso a comunidade foi revogado permanentemente.\nMotivo: Tentou abrir o nui devtools.\n\nPara mais informações entre em contato via ticket.")
end)


-- executeEvent("drop_create_item", { category: selectLojaItemType, spawnName: inpuSpawnName, name: inputName, image: inputUrlImage, percent: inputPercentDrop, badge: inputBadgeDrop }, (res) => {

events['drop'] = function(src, data)
    local user_id = vRP.getUserId(src)
    local drop = vRP.query("vRP/getItensDuthDrop",{ })

    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    return drop
end


events['drop_create_item'] = function(src, data)
    local user_id = vRP.getUserId(src)

    exports.oxmysql:query_async("INSERT INTO duth_drop (drop_name,drop_imagem,drop_spawName,drop_percent,drop_category,drop_sex,drop_badge) VALUES (?,?,?,?,?,?,?)",{ data.name, data.image, data.spawnName, data.percent, data.category, data.sex, data.badge })
    TriggerClientEvent("Notify", src, "inform", "Você adicionou o item <b>"..data.name.."</b> no caixa.")
    vCLIENTBattle.clearInfoCache(-1, 'drop')
    exports["duth_drop"]:Drop().BuildItems()

    return { status = true }
end

events['ROUPAS'] = function(src, data)
    local user_id = vRP.getUserId(src)

    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
    local PlayerState = Player(src).state
    local ClothesData = {}

    if not PlayerState.userClothes then
        for k, v in pairs(userInventory) do
            if v.inventory_itemType == "clothe" then
                local item = exports["core"]:Config().Clothes[v.inventory_itemName]
                if item then
                    ClothesData[item.clothe_spawnName] = {
                        name = item.clothe_name,
                        type = item.clothe_type,
                        number = item.clothe_number,
                        color = item.clothe_color,
                        category = item.clothe_category,
                        spawnName = item.clothe_spawnName,
                        image = item.clothe_image,
                        rare = item.clothe_rare
                    }
                end
            end
        end
    
        PlayerState.userClothes = ClothesData
    end

    return reMapData(PlayerState.userClothes)
end

events['BARBEARIA'] = function(src, data)
    local user_id = vRP.getUserId(src)

    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
    local PlayerState = Player(src).state
    local BarbeariaData = {}

    if not PlayerState.userBarbearia then
        for k, v in pairs(userInventory) do
            if v.inventory_itemType == "barbearia" then
                local item = exports["core"]:Config().Barbearia[v.inventory_itemName]
                if item then
                    BarbeariaData[item.barber_spawnName] = {
                        barber_spawnName = item.barber_spawnName,
                        barber_name = item.barber_name,
                        barber_type = item.barber_type,
                        barber_category = item.barber_category,
                        barber_model = item.barber_model,
                        barber_color = item.barber_color,
                        barber_image = item.barber_image,
                    }
                end
            end
        end
    
        PlayerState.userBarbearia = BarbeariaData
    end

    return reMapData(PlayerState.userBarbearia)
end

events['TATUAGEM'] = function(src, data)
    local user_id = vRP.getUserId(src)

    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
    local PlayerState = Player(src).state
    local TatuagensData = {}

    if not PlayerState.userTatuagens then
        for k, v in pairs(userInventory) do
            if v.inventory_itemType == "tatuagem" then
                local item = exports["core"]:Config().Tatuagens[v.inventory_itemName]
                if item then
                    TatuagensData[item.tatto_spawnName] = {
                        tatto_name = item.tatto_name,
                        tatto_type = item.tatto_type,
                        tatto_category = item.tatto_category,
                        tatto_model = item.tatto_model,
                        tatto_part = item.tatto_part,
                        tatto_image = item.tatto_image,
                        tatto_status = v.inventory_itemStatus,
                        tatto_inventoryId = v.inventory_id,
                        tatto_spawnName = item.tatto_spawnName
                    }
                end
            end
        end
    
        PlayerState.userTatuagens = TatuagensData
    end

    return reMapData(PlayerState.userTatuagens)
end

events['items'] = function(src, data)
    local items = {}
    local user_id = vRP.getUserId(src)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    local Tatuagens = exports["core"]:Config().Tatuagens
    local Barbearia = exports["core"]:Config().Barbearia
    local Skins = exports["core"]:Config().Skins
    local Clothes = exports["core"]:Config().Clothes
    local Titles = exports["core"]:Config().Titles

    for _, tatto in pairs(Tatuagens) do 
        table.insert(items, {
            itemSpawnName = tatto.tatto_spawnName,
            itemName = tatto.tatto_name,
            itemImage = tatto.tatto_image,
            itemSpawnCategory = "tatuagem"
        })
    end

    for _, barber in pairs(Barbearia) do 
        table.insert(items, {
            itemSpawnName = barber.barber_spawnName,
            itemName = barber.barber_name,
            itemImage = barber.barber_image,
            itemSpawnCategory = "barbearia"
        })
    end

    for _, skin in pairs(Skins) do 
        table.insert(items, {
            itemSpawnName = skin.skin_spawnName,
            itemName = skin.skin_name,
            itemImage = skin.skin_image,
            itemSpawnCategory = "skin"
        })
    end

    for _, roupa in pairs(Clothes) do 
        table.insert(items, {
            itemSpawnName = roupa.clothe_spawnName,
            itemName = roupa.clothe_name,
            itemImage = roupa.clothe_image,
            itemSpawnCategory = "clothe"
        })
    end

    for _, title in pairs(Titles) do 
        table.insert(items, {
            itemSpawnName = title.spawnName,
            itemName = title.name,
            itemImage = title.image,
            itemSpawnCategory = "title"
        })
    end

    return items
end


events['bau-items'] = function (src, data)
    local user_id = vRP.getUserId(src)

    if user_id then
        local items = {
            global = {},
            acessorios = {},
            suprimentos = {},
            armas = {},
        }
        
        local ConfigItems = exports["core"]:Config().additionalsupplements

        for k,v in pairs(ConfigItems) do 
            if v.category == "acessorios" then
                table.insert(items.acessorios, v)
            elseif v.category == "suprimentos" then
                table.insert(items.suprimentos, v)
            elseif v.category == "armas" then
                table.insert(items.armas, v)
            end
        
            table.insert(items.global, v)
        end
        
        return items
    end
end

AirDrop = {}
AirDrop.Players = {}

function AirDrop.ClearAirDrop(src) 
    local user_id = vRP.getUserId(src)
    if AirDrop.Players[user_id] then
        AirDrop.Players[user_id] = nil
    end
end

events['clear-bau'] = function(src, data) 
    local user_id = vRP.getUserId(src)
    AirDrop.Players[user_id] = nil
    TriggerClientEvent("Notify",src,"sucess","Você limpou os itens do seu <b>AirDrop</b>, agora você está liberado para montar outro.", 9000)
    return { status = true }
end


events['buy-bau'] = function(src, data) 
    local user_id = vRP.getUserId(src)

    if not AirDrop.Players[user_id] then
        if exports["core"]:Loja().consultPrice({ source = src, value = data.price, user_id = user_id, type = 'points' }) then
            TriggerClientEvent("Notify",src,"sucess","Parabéns! Você acaba de montar seu <b>AirDrop</b>. Agora você pode convocá-lo durante uma partida. Para fazer isso, procure o AirDrop como <b>loot e utilize o item para chama-lo</b>.", 9000)
            AirDrop.Players[user_id] = data.itens
            return { status = true }
        else
            TriggerClientEvent("Notify",src,"negado","Você não tem <b>Duth Points</b> necessário para montar seu airdrop.")
            return { status = false }
        end
    else
        TriggerClientEvent("Notify",src,"negado","Você já possui um <b>AirDrop</b> montado. Por favor, utilize-o antes de montar um novo.")
        return { status = false }
    end
end

local codigosGerados = {}

function gerarCodigo()
    local codigo = ""
    local caracteres = "abcgefadfssddsadsahhgi7ee"
    local tamanho = 5 

    repeat
        codigo = "DUTH-"
        for i = 1, tamanho do
            local indice = math.random(1, #caracteres)
            codigo = codigo .. caracteres:sub(indice, indice)
        end
    until not codigosGerados[codigo]

    codigosGerados[codigo] = true
    return codigo:upper()
end

events['partidas_function'] = function(src, data) 
	local user_id = vRP.getUserId(src)
    local Role = exports["core"]:Group().hasAccessOrHigher(user_id,"dev")

    if data.type == "FinishGame" and Role then
        exports["core"]:Game().AdminFunctions({ type = "FinishGame", gameId = data.gameId, source = src })
        TriggerClientEvent("Notify",src,"inform","Você finalizou a partida <b>"..data.gameId.."</b>, todos os jogadores voltaram ao lobby.", 6000)
        return { status = true }
    end

    if data.type == "InfoGame" then
        local Game = exports["core"]:Game().AdminFunctions({ type = "InfoGame", gameId = data.gameId, source = src })
        local PlayersCount = exports["core"]:Game().GetPlayersCountGame(data.gameId)  
        local GameStatus
        if Game.started then
            GameStatus = "Em andamento"
        else
            GameStatus = "Aguardando"
        end
        TriggerClientEvent("Notify",src,"inform","<b>Informações da partida<b><br><br><b>Modo: </b>"..Game.Gamemode.."</b><br> <b>Jogdores vivos na partida: </b>"..PlayersCount.."<br> <b>Status da partida: </b>"..GameStatus.."<br> <b>Tipo da partida: </b>"..Game.gameType.."", 9000)
        return { status = true }
    end

    if data.type == "JoinSpec" then
        exports["core"]:Game().AdminFunctions({ type = "JoinSpec", gameId = data.gameId, source = src })
        return { status = true }
    end

    if data.type == "partida_create" then
        if data.modeType == "evento" then
            local code = gerarCodigo()

            for _, src in ipairs(GetPlayers()) do
                if Player(src).state.inLobbyPrincipal then
                    TriggerClientEvent("Notify",src,"inform","<b>EVENTO ABERTO</b><br> <b>CODIGO: </b> "..code.."", 9000)
                end
            end
            data.code = code
        else
            local code = gerarCodigo()
            TriggerClientEvent("Notify",src,"inform","<b>EVENTO PRIVADO</b><br> <b>CODIGO: </b> "..code.."", 9000)
            data.code = code
        end
        
        exports["core"]:Game().HostGame(data, 'admin')
        return { status = true }
    end
end

events['collection'] = function(src, data) 
    local user_id = vRP.getUserId(src)
    local SkinsData = {}
    local items = {
        weapon = {},
        box = {},
        titles = {}
    }
    if (data.user_id) then
        user_id = tonumber(data.user_id)
    end
    
    if user_id then
        local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
        for k,v in pairs(userInventory) do 
            
            -- Skin
            if v.inventory_itemType == "skin" then
                local item = exports["core"]:Config().Skins[v.inventory_itemName] 
    
                if item then
                    SkinsData[item.skin_spawnName] = {
                        skin_id = v.inventory_id,
                        skin_spawnName = item.skin_spawnName,
                        skin_name = item.skin_name,
                        skin_category = item.skin_category,
                        skin_model = item.skin_model,
                        skin_image = item.skin_image,
                        skin_status = v.inventory_itemStatus,
                    }

                    table.insert(items.weapon, {
                        id = v.inventory_id,
                        spawnName = item.skin_spawnName,
                        name = item.skin_name,
                        category = v.inventory_itemType,
                        image = item.skin_image,
                        status = v.inventory_itemStatus,
                    })
                end
            end

            if v.inventory_itemType == "title" then
                local item = exports["core"]:Config().Titles[v.inventory_itemName] 
    
                if item then
                    table.insert(items.titles, {
                        id = v.inventory_id,
                        spawnName = item.spawnName,
                        name = item.name,
                        category = v.inventory_itemType,
                        image = item.image,
                        status = v.inventory_itemStatus,
                    })
                end
            end

        end
    end

    Player(src).state.userSkins = SkinsData

    return items
end

events['season'] = function(src, data) 
	local user_id = vRP.getUserId(src)
    local passe = vRP.query("vRP/getItensPasse",{ })
    return passe
end

events['passe_create_item'] = function(src, data) 
    local user_id = vRP.getUserId(src)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    if user_id then
        local passe = vRP.query("vRP/getItensPasse",{ })

        for k,v in pairs(passe) do 
            if v.level == data.level and v.type == data.type and v.sex == data.sex then
                TriggerClientEvent("Notify", src, "negado", "Já existe um item nesse level no passe de batalha <b>"..data.type.."</b>.")
                return
            end
        end

        exports.oxmysql:query_async("INSERT INTO passe (level,spawnName,name,category,image,type,sex) VALUES (?,?,?,?,?,?,?)",{ data.level, data.spawnName, data.name, data.category, data.image, data.type, data.sex })
        TriggerClientEvent("Notify", src, "inform", "Você adicionou o item <b>"..data.name.."</b> no passe de batalha <b>"..data.type.."</b>.")
        vCLIENTBattle.clearInfoCache(-1, 'season')
        vCLIENTBattle.clearInfoCache(-1, 'passe')
        exports["core"]:BattlePass().BuildPass()

        return { status = true }
    end
end


events['passe_delete_item'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end
    
    if user_id then
        exports.oxmysql:query("DELETE FROM passe WHERE id = ?",{ parseInt(data.id) })
        TriggerClientEvent("Notify", src, "inform", "Você deletou o item "..data.name.." do passe de batalha.")
        vCLIENTBattle.clearInfoCache(-1, 'season')
        return { status = true }
    end
end

events['partidas'] = function(src, data) 
	local user_id = vRP.getUserId(src)
    local Games = exports["core"]:Game().AdminFunctions({ type = "GetGames", source = src })
    local Role = exports["core"]:Group().hasAccessOrHigher(user_id,"dev")

    return {
        Games = Games,
        Role = Role
    }
end

events['shop'] = function (src, data)
    local user_id = vRP.getUserId(src)
    local playerModel = GetPlayerPed(src)
    local PlayerSex = ""
    
    if GetEntityModel(playerModel) == GetHashKey("mp_m_freemode_01") then
        PlayerSex = "mp_m_freemode_01"
    elseif GetEntityModel(playerModel) == GetHashKey("mp_f_freemode_01") then
        PlayerSex = "mp_f_freemode_01"
    end

    if user_id then
        local items = {
            home = {},
            weapon = {},
            box = {},
            clothes = {},
            apprence = {}
        }
        
        local shop = vRP.query("vRP/getItensShop",{ })
        local shopWeapons = vRP.query("vRP/getItensShopForCategorie",{ item_category = 'weapon' })
        local shoBbox = vRP.query("vRP/getItensShopForCategorie",{ item_category = 'box' })
        local shopClothes = vRP.query("vRP/getItensShopForCategorieClothes",{ item_category = 'clothes', item_sex = PlayerSex })
        local shopApprence = vRP.query("vRP/getItensShopForCategorie",{ item_category = 'apprence' })

        if shop[1] then
            for _, itemShop in pairs(shop) do
                table.insert(items.home, itemShop) 
            end

            for _, itemShop in pairs(shopWeapons) do
                table.insert(items.weapon, itemShop) 
            end

            for _, itemShop in pairs(shoBbox) do
                table.insert(items.box, itemShop) 
            end
            
            for _, itemShop in pairs(shopClothes) do
                table.insert(items.clothes, itemShop) 
            end

            for _, itemShop in pairs(shopApprence) do
                table.insert(items.apprence, itemShop) 
            end
        end

        return items
    end
end

events['shop_create_item'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end

    if user_id then
        exports.oxmysql:query_async("INSERT INTO shop (item_spawnName,item_name,spawn_category,item_sex,item_category,item_image,item_duthPoints,item_duthCoins,item_doublePayment) VALUES (?,?,?,?,?,?,?,?,?)",{ data.spawnName, data.name, data.spawnCategory, data.itemSex, data.type, data.image, data.duthPoints, data.duthCoins, data.doublePayment })
        TriggerClientEvent("Notify", src, "inform", "Você adicionou o item "..data.name.." na loja.")
        vCLIENTBattle.clearInfoCache(-1, 'shop')
        return { status = true }
    end
end

events['shop_buyCoins'] = function(src, data) 
    local user_id = vRP.getUserId(src)

    local body = json.encode({
        coins = data.coins,
        user_id = user_id
    })

    PerformHttpRequest('http://localhost:3000/PaymentCreator', function(status, text)
        local datad = json.decode(text)
        vCLIENTBattle.UpdatePayment(src, 'UpdatePaymentCreate', datad)
    end, 'POST', body, { ['Content-Type'] = 'application/json' })

    return {}
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllByServer
-----------------------------------------------------------------------------------------------------------------------------------------
function getAllByServer()
    local players = {}
    local count = 0
    for _, src in ipairs(GetPlayers()) do
        if Player(src).state.inLobbyPrincipal then
			local userId = vRP.getUserId(src)
            players[src] = userId
            count = count + 1
        end
    end

    return players, count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- emitPlayersEvent
-----------------------------------------------------------------------------------------------------------------------------------------
function emitPlayersEvent(eventName,...)
    local players, playerCount = getAllByServer()
    if playerCount > 0 then
        for src, uid in pairs(players) do
            TriggerClientEvent(eventName,src,...)
            Wait(1)
        end
    end
end

events['shop_buy_item'] = function(src, data) 
    local user_id = vRP.getUserId(src)
    local identity = vRP.getIdentity(user_id)

    if data.spawnName == "premium" then
        if not exports["core"]:Premium().isVipByUserId(user_id,"padrao") then
            if exports["core"]:Loja().consultPrice({ source = src, value = data.price, user_id = user_id, type = data.type }) then
                exports["core"]:Premium().generateVipPerDays({ user_id = user_id, category = "padrao", timeInDays = 30 })
                vCLIENTBattle.clearInfoCache(src, 'profile')
                vCLIENTBattle.clearInfoCache(src, 'shop')
                local icon = "fa-solid fa-basket-shopping"
                emitPlayersEvent("chatMessage2",icon,"LOJA","^*"..identity.username.."^r comprou o ^*premium^r do servidor.",{215, 193, 108})
                TriggerClientEvent("Notify",src,"sucess","Parabéns pela aquisição do <b>Premium</b> em nosso servidor! Agora você pode aproveitar ao máximo todos os benefícios exclusivos que ele oferece. Lembre-se de que o período de acesso ao Premium será válido por <b>30 dias a partir de hoje</b>. Aproveite ao máximo essa experiência aprimorada enquanto estiver ativo! Caso precise de qualquer suporte ou tenha alguma dúvida, nossa equipe estará pronta para ajudar. Aproveite!", 9000)
                
                return { status = true }
            else
                TriggerClientEvent("Notify",src,"negado","Você não tem "..data.type.." necessário para comprar esse item.")
                return { status = false }
            end
        else
            TriggerClientEvent("Notify",src,"negado","Você já tem o <b>premium</b> em nosso servidor.")
            return { status = false }
        end
    end

    if exports["core"]:Inventory().ConsultItem(src, user_id, data.spawnName) then
        if exports["core"]:Loja().consultPrice({ source = src, value = data.price, user_id = user_id, type = data.type }) then

            exports["core"]:Inventory().GiveItem(src, user_id, {
                spawnName = data.spawnName,
                category = data.itemCategory
            })
            TriggerClientEvent("Notify",src,"sucess","Você comprou esse item.")
            return { status = true }
        else
            TriggerClientEvent("Notify",src,"negado","Você não tem "..data.type.." necessário para comprar esse item.")
            return { status = false }
        end
    else
        TriggerClientEvent("Notify",src,"negado","Você já tem esse item.")
        return { status = false }
    end
end

events['shop_delete_item'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if not exports["core"]:Group().hasAccessOrHigher(user_id, "dev") then
        return
    end
    
    if user_id then
        exports.oxmysql:query("DELETE FROM shop WHERE id = ?",{ parseInt(data.id) })
        TriggerClientEvent("Notify", src, "inform", "Você deletou o item "..data.name.." da loja.")
        vCLIENTBattle.clearInfoCache(-1, 'shop')
        return { status = true }
    end
end

events['profile_ranking'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if (data.user_id) then
        user_id = tonumber(data.user_id)
    end
    if user_id then
        local result = {}
        for key, gamemode in pairs(gamemodesList) do
            local query_res = vRP.query("vRP/getPlayerRanking", { gamemode = key, user_id = user_id })
            if query_res[1] then
                result[key] = query_res[1]
                result[key]['played'] = true
                result[key]['rankName'] = exports["core"]:Ranks().getRankByLevel(query_res[1].points)
                result[key]['nextRankXP'] = exports["core"]:Ranks().getNextRankXp(query_res[1].points)
                local rank, percentage, rankName = exports["core"]:Ranks().getNextRankInfo(query_res[1].points)
                result[key]['nextRankPercentage'] = percentage
            else
                result[key] = {}
                result[key]['played'] = false
            end
            result[key]['title'] = gamemode.title
        end
        return result
    end
end


events['passe_execute'] = function(src, data) 
    local user_id = vRP.getUserId(src)
    local playerModel = GetPlayerPed(src)
    local PlayerSex = ""
    
    if GetEntityModel(playerModel) == GetHashKey("mp_m_freemode_01") then
        PlayerSex = "mp_m_freemode_01"
    elseif GetEntityModel(playerModel) == GetHashKey("mp_f_freemode_01") then
        PlayerSex = "mp_f_freemode_01"
    end

    if data.type == "ClaimReward" and user_id then
        local profile = vRP.query("vRP/requestUser",{ id = user_id })
        local level = profile[1].duthBattleLevel
        local itemBattlePassFree = exports["core"]:BattlePass().Passe["Free"][PlayerSex][level]
        local itemBattlePassPremium = exports["core"]:BattlePass().Passe["Premium"][PlayerSex][level]

        if profile[1].duthBattlePass == "true" then
            exports["core"]:Inventory().GiveItem(src, user_id, { spawnName = itemBattlePassFree.spawnName, category = itemBattlePassFree.category })
            exports["core"]:Inventory().GiveItem(src, user_id, { spawnName = itemBattlePassPremium.spawnName, category = itemBattlePassPremium.category })

            LevelUP(src, profile)
        else
            exports["core"]:Inventory().GiveItem(src, user_id, { spawnName = itemBattlePassFree.spawnName, category = itemBattlePassFree.category })
            LevelUP(src, profile)
        end

        vCLIENTBattle.clearInfoCache(src, 'passe')
        return { status = true }
    end

    if data.type == "Buy" and user_id then
        local profile = vRP.query("vRP/requestUser",{ id = user_id })

        if exports["core"]:Loja().consultPrice({ source = src, value = 1400, user_id = user_id, type = "coins" }) then
            if profile[1].duthBattlePass == "false" then
                vRP.execute("vRP/updatePasse", { duthBattlePass = "true", id = user_id })
                vCLIENTBattle.clearInfoCache(src, 'passe')
                TriggerClientEvent("Notify",src,"sucess","Parabéns! Você acaba de adquirir o <b>Passe de Batalha</b>! Agora é só jogar partidas e evoluí-lo, mas lembre-se de que ele será <b>redefinido ao final da temporada</b> :)!", 9000)
            end
        else
            TriggerClientEvent("Notify",src,"negado","Você não tem <b>Duth Coins</b> necessário para comprar o passe de batalha.")
        end
        return { status = true }
    end

    return { status = false }
end

function LevelUP(source, profile) 
    local user_id = vRP.getUserId(source)

    local prevLevel = profile[1].duthBattleLevel
    local prevXP = profile[1].duthBattleXp

    if prevXP >= 1500 then
        profile[1].duthBattleLevel = prevLevel + 1
        profile[1].duthBattleXp = prevXP - 1500
        vRP.execute("vRP/updateLevelPasse", { duthBattleLevel = profile[1].duthBattleLevel, id = user_id })
        vRP.execute("vRP/updateXpPasse", { duthBattleXp = profile[1].duthBattleXp, id = user_id })
    else
        profile[1].duthBattleLevel = prevLevel + 1
        profile[1].duthBattleXp = prevXP
        vRP.execute("vRP/updateLevelPasse", { duthBattleLevel = profile[1].duthBattleLevel, id = user_id })
        vRP.execute("vRP/updateXpPasse", { duthBattleXp = profile[1].duthBattleXp, id = user_id })
    end
end

events['passe'] = function (src, data)
    local user_id = vRP.getUserId(src)
    local playerModel = GetPlayerPed(src)
    local PlayerSex = ""
    
    if GetEntityModel(playerModel) == GetHashKey("mp_m_freemode_01") then
        PlayerSex = "mp_m_freemode_01"
    elseif GetEntityModel(playerModel) == GetHashKey("mp_f_freemode_01") then
        PlayerSex = "mp_f_freemode_01"
    end

    if (data.user_id) then
        user_id = tonumber(data.user_id)
    end

    if user_id then
        local profile = vRP.query("vRP/requestUser",{ id = user_id })
        if profile[1] then
            local identity = vRP.getIdentity(user_id)
            if identity then
                local default_user_id = vRP.getUserId(src)
                return {
                    user_id = default_user_id,
                    duthPoints = profile[1].duthPoints,
                    duthBattleXp = profile[1].duthBattleXp,
                    duthBattlePass = profile[1].duthBattlePass,
                    duthBattleLevel = profile[1].duthBattleLevel,
                    duthBattleItemsFree = exports["core"]:BattlePass().Passe["Free"][PlayerSex],
                    duthBattleItemsPremium = exports["core"]:BattlePass().Passe["Premium"][PlayerSex],
                    duthSex = PlayerSex
                }
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function reMapData(game_data)
	local cntRed = 0
	local _redList = game_data
	game_data = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data[cntRed] = v
	end
	return game_data
end


events['profile_history'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if (data.user_id) then
        user_id = tonumber(data.user_id)
    end
    if user_id then
        local items = {
            solo = {},
            duo = {},
            squad = {},
        }

        local solo = vRP.query("vRP/getHistoryGames",{ user_id = user_id, gamemode = "Solo" })
        local duo = vRP.query("vRP/getHistoryGames",{ user_id = user_id, gamemode = "Duo" })
        local squad = vRP.query("vRP/getHistoryGames",{ user_id = user_id, gamemode = "Squad" })

        for _, itemShop in pairs(solo) do
            table.insert(items.solo, itemShop) 
        end

        for _, itemShop in pairs(duo) do
            table.insert(items.duo, itemShop) 
        end

        for _, itemShop in pairs(squad) do
            table.insert(items.squad, itemShop) 
        end
        
        return items
    end
end

events['profile'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if (data.user_id) then
        user_id = tonumber(data.user_id)
    end
    if user_id then
        local profile = vRP.query("vRP/requestUser",{ id = user_id })
        if profile[1] then
            local identity = vRP.getIdentity(user_id)
            if identity then
                local default_user_id = vRP.getUserId(src)
                return {
                    user_id = default_user_id,
                    username = identity.username,
                    avatar = profile[1].avatar,
                    duthCoins = profile[1].duthCoins,
                    duthPoints = profile[1].duthPoints,
                    title = profile[1].CustomTitle or "Sem título",
                    premium = exports["core"]:Premium().isVipByUserId(user_id,"padrao")
                }
            end
        end
    end
end

events['profile_title'] = function (src, data)
    local user_id = vRP.getUserId(src)

    if user_id then
        if data.type == "Equipar" then
            vRP.execute("vRP/updateProfileTitle", { CustomTitle = data["titleData"].name, id = user_id })
            vRP.execute("vRP/updateSkin", { inventory_itemStatus = "true", inventory_id = data["titleData"].id })
        end
        
        if data.type == "Desequipar" then
            vRP.execute("vRP/updateProfileTitle", { CustomTitle = "Sem título", id = user_id })
            vRP.execute("vRP/updateSkin", { inventory_itemStatus = "false", inventory_id = data["titleData"].id })
        end
    end

    vCLIENTBattle.clearInfoCache(src, 'collection')

    return { status = true }
end

events['profile_edit'] = function (src, data)
    local user_id = vRP.getUserId(src)

    if user_id then
        vRP.execute("vRP/updateProfile", { avatar = data.avatar, username = data.username, id = user_id })

        vRP.updateIdentity(user_id)
        TriggerClientEvent("Notify", src, "inform", "Você editou seu perfil.")
        vCLIENTBattle.clearInfoCache(src, 'profile')
    end

    return { status = true }
end

events['global_ranking'] = function (src, data)
    local user_id = vRP.getUserId(src)
    if user_id then
        if cache['global_ranking'] then
            if cache['global_ranking']._timeout >= GetGameTimer() then
                local timeRemaining = math.floor((cache['global_ranking']._timeout - GetGameTimer()) / 1000)

                return { ranking = cache['global_ranking'], time = timeRemaining}
            else
                cache['global_ranking'] = nil
            end
        end

        local result = {}
        for gameName, gamemode in pairs(gamemodesList) do
            local gmResult = {}
            local tmpResult = {}
            local query_res = vRP.query("vRP/getPlayerGlobalRanking", { gamemode = gameName })

            for key2, score in pairs(query_res) do
                score.gamemode = gamemode.title
                score.username = "N/A"
                score.avatar = "https://i.pinimg.com/474x/5c/be/a6/5cbea638934c3a0181790c16a7832179.jpg"
                score.rankName = exports["core"]:Ranks().getRankByLevel(score.points)

                local identity = vRP.getIdentity(score.user_id)
                if identity then score.username = identity.username end
                if identity then score.avatar = identity.avatar end
                table.insert(tmpResult, score)

                if not exports["core"]:checkBan({ user_id = score.user_id }) then
                    table.insert(tmpResult, score)
                end
            end

            local rankPos = 1
            for key, item in pairs(tmpResult) do
                gmResult[rankPos] = item
                gmResult[rankPos].rank = rankPos
                rankPos = rankPos + 1
                if rankPos > 100 then break end
            end
            result[gamemode.title] = gmResult
        end
        
        result['geral'] = rankingCache
        cache['global_ranking'] = result
        cache['global_ranking']._timeout = GetGameTimer() + 1 * 60 * 60 * 1000 -- 1 hora

        local timeRemaining = math.floor((cache['global_ranking']._timeout - GetGameTimer()) / 1000)
        
        return { ranking = result, time = timeRemaining}

    end
end


local timeExec = 10000 --Tempo de execução dos comandos (Recomendado 10000 para que não pese no servidor)

Citizen.CreateThread(function()
    while true do
        local req = vRP.query('vRP/GetPaymentsRequests')
        for _,v in pairs(req) do
            if v.type == 'UpdateProfile' then
                local player_source = vRP.getUserSource(v.user_id)
                vRP.execute('vRP/deletePaymentRequest',{ id = v.id })
                if player_source then
                    vCLIENTBattle.clearInfoCache(player_source, 'profile')
                    TriggerClientEvent("Notify", player_source, "inform", "Obrigado por adquirir DUTH Coins em nosso servidor e por seu contínuo apoio ao projeto. Temos o prazer de informar que acabamos de depositar o valor correspondente à sua compra em sua carteira.", 8000)
                end
            end
        end
        Citizen.Wait(timeExec) 
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AirDrop - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("AirDrop",function()
    return AirDrop
end)