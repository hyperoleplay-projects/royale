BattlePass = {}
----------------------------------------------------------------------------------------------------------------------------------------
-- rewardBattlePass - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.rewardBattlePass() 
    local source = source
    local user_id = vRP.getUserId(source)
    local playerModel = GetPlayerPed(source)
    local level = Player(source).state.duthBattleLevel
    local PlayerSex = ""

    if GetEntityModel(playerModel) == GetHashKey("mp_m_freemode_01") then
        PlayerSex = "mp_m_freemode_01"
    elseif GetEntityModel(playerModel) == GetHashKey("mp_f_freemode_01") then
        PlayerSex = "mp_f_freemode_01"
    end

    local itemBattlePassFree = Config.Passe["Free"][PlayerSex][level]
    local itemBattlePassPremium = Config.Passe["Premium"][PlayerSex][level]

    if Player(source).state.duthBattlePass == "true" then
        vRP.execute('vRP/giveItem', {
            user_id = user_id,
            inventory_itemName = itemBattlePassFree.spawnName,
            inventory_itemStatus = "false",
            inventory_itemType = itemBattlePassFree.category,
            inventory_generate = "shop",
        })

        vRP.execute('vRP/giveItem', {
            user_id = user_id,
            inventory_itemName = itemBattlePassPremium.spawnName,
            inventory_itemStatus = "false",
            inventory_itemType = itemBattlePassPremium.category,
            inventory_generate = "shop",
        })
        
        Player(source).state.userData = false
        Wait(500)
        loadUserData(source, user_id, false)

        Player(source).state.inDashboard = true

        BattlePass.LevelUP(source)
    else
        vRP.execute('vRP/giveItem', {
            user_id = user_id,
            inventory_itemName = itemBattlePassFree.spawnName,
            inventory_itemStatus = "false",
            inventory_itemType = itemBattlePassFree.category,
            inventory_generate = "shop",
        })

        Player(source).state.userData = false
        Wait(500)
        loadUserData(source, user_id, false)

        Player(source).state.inDashboard = true

        BattlePass.LevelUP(source)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------
-- BuyPasse - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.BuyPasse() 
    local source = source
    local user_id = vRP.getUserId(source)

    if Loja.consultDuthCoins({ source = source, value = 6000, user_id = user_id }) then
        if Player(source).state.duthBattlePass == "false" then
            vRP.execute("vRP/updatePasse", { duthBattlePass = "true", id = user_id })
            Player(source).state.duthBattlePass = "true"
        end

        Wait(50)
        clientAPI.UpdateBattlePass(source)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------
-- LevelUP - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function BattlePass.LevelUP(source) 
    local user_id = vRP.getUserId(source)

    local prevLevel = Player(source).state.duthBattleLevel
    local prevXP = Player(source).state.duthBattleXp

    if prevXP >= 1500 then
        Player(source).state.duthBattleLevel = prevLevel + 1
        Player(source).state.duthBattleXp =  prevXP - 1500
        vRP.execute("vRP/updateLevelPasse", { duthBattleLevel = Player(source).state.duthBattleLevel, id = user_id })
        vRP.execute("vRP/updateXpPasse", { duthBattleXp = Player(source).state.duthBattleXp, id = user_id })
    else
        Player(source).state.duthBattleLevel = prevLevel + 1
        Player(source).state.duthBattleXp = prevXP
        vRP.execute("vRP/updateLevelPasse", { duthBattleLevel = Player(source).state.duthBattleLevel, id = user_id })
        vRP.execute("vRP/updateXpPasse", { duthBattleXp = Player(source).state.duthBattleXp, id = user_id })
    end

    Wait(50)
    clientAPI.UpdateBattlePass(source)
end