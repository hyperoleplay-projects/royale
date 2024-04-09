-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
Inventory = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadInventory - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Inventory.LoadInventory(source, user_id) 
    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })
    local ClothesData = {}
    local TatuagensData = {}
    local BarbeariaData = {}
    local SkinsData = {}
    local hasMessageSkin = false

    Player(source).state.userClothes = {}
    Player(source).state.userTatuagens = {}
    Player(source).state.userBarbearia = {}
    Player(source).state.userSkins = {}
    Player(source).state.userAirDrop = {}

    for k,v in pairs(userInventory) do 
        if v.inventory_itemType == "clothe" then
            local item = Config.Clothes[v.inventory_itemName] 

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

                Player(source).state.userClothes = ClothesData
            end

        end

        if v.inventory_itemType == "tatuagem" then
            local item = Config.Tatuagens[v.inventory_itemName] 

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

                Player(source).state.userTatuagens = TatuagensData
            end
        end


        if v.inventory_itemType == "barbearia" then
            local item = Config.Barbearia[v.inventory_itemName] 

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

                Player(source).state.userBarbearia = BarbeariaData
            end
        end


        if v.inventory_itemType == "skin" then
            local item = Config.Skins[v.inventory_itemName] 

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

                Player(source).state.userSkins = SkinsData
            end
        end
        
        for _, InventorySkins in pairs(Player(source).state.userSkins) do 
            if InventorySkins.skin_status == "false" then
                if not hasMessageSkin then
                    hasMessageSkin = true
                    TriggerClientEvent("Notify",source,"inform", "Você possui <b>skins de armas não equipadas</b>. Caso queira equipá-las, dirija-se ao NPC de <b>skins no lobby principal</b>.", 28000)
                end
            end
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ConsultItemDiscord - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Inventory.ConsultItemDiscord(source, user_id, itemName, type)
    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })

    if #userInventory > 0 then
        for k, v in pairs(userInventory) do
            if v.inventory_itemName == itemName and v.inventory_generate == type then
                return true
            end
        end
    end

    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ConsultItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Inventory.ConsultItem(source, user_id, itemName)
    local userInventory = vRP.query("vRP/getInventory", { user_id = user_id })

    for k, v in pairs(userInventory) do
        if v.inventory_itemName == itemName then
            return false
        end
    end

    return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SyncRoleItems - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Inventory.SyncRoleItems(source, user_id, callback)
    local identity = vRP.getIdentity(user_id)
    local hasMessage = false
    local hasMessage2 = false

    Citizen.SetTimeout(2000, function()
        for k, role in pairs(Config.DiscordItemsRoles) do
            if DiscordSync.HasDiscordRole(user_id, role.roleId) then
                if role.roleType == "benefits" then
                    for itemS, item in pairs(role.items) do
                        if not Inventory.ConsultItemDiscord(source, user_id, item.name, "discord") then
                            vRP.execute('vRP/giveItem', {
                                user_id = user_id,
                                inventory_itemName = item.name,
                                inventory_itemStatus = "false",
                                inventory_itemType = item.category,
                                inventory_generate = "discord",
                            })
                        end
                    end

                    if not hasMessage then
                        hasMessage = true
                        TriggerClientEvent("Notify",source,"inform", "Olá, <b>"..identity.username.."</b>! Seja muito bem-vindo ao DUTH! Acabamos de autenticar você como <b>"..role.roleName.."</b> no servidor. Parabéns!", 18000)
                    end
                end
            else
                if role.roleType == "benefits" then
                    for itemS, item in pairs(role.items) do
                        if Inventory.ConsultItemDiscord(source, user_id, item.name, "discord") then
                            vRP.execute('vRP/RemoveItem', {
                                user_id = user_id,
                                inventory_itemName = item.name,
                            })
                        end
                    end
                end
            end
            Citizen.Wait(50)
        end

        if callback then
            callback()
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GiveItem - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Inventory.GiveItem(source, user_id, data)
    local item = nil
    local itemName = nil

    if data.category == "clothe" then
        item = Config.Clothes[data.spawnName]
        itemName = item and item.clothe_spawnName
    elseif data.category == "tatuagem" then
        item = Config.Tatuagens[data.spawnName]
        itemName = item and item.tatto_spawnName
    elseif data.category == "barbearia" then
        item = Config.Barbearia[data.spawnName]
        itemName = item and item.barber_spawnName
    elseif data.category == "skin" then
        item = Config.Skins[data.spawnName]
        itemName = item and item.skin_spawnName
    end

    if item then
        vRP.execute('vRP/giveItem', {
            user_id = user_id,
            inventory_itemName = itemName,
            inventory_itemStatus = "false",
            inventory_itemType = data.category,
            inventory_generate = "shop",
        })
    end

    if not Player(source).state.inGame and not Player(source).state.inAimLab and not Player(source).state.inQueue then
        Player(source).state.userData = false
        Wait(500)
        loadUserData(source, user_id, false)
        TriggerClientEvent("battleNui:update", source)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Inventory - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Inventory",function()
    return Inventory
end)