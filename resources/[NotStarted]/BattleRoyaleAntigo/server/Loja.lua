Loja = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- consultDuthCoins - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Loja.consultDuthCoins(data)
    if Player(data.source).state.duthCoins >= tonumber(data.value) then
        vRP.execute('vRP/removeCoins', { id = data.user_id, duthCoins = data.value })
        local rows = vRP.query("vRP/requestUser", { id = data.user_id })
        Player(data.source).state.duthCoins = tonumber(rows[1]['duthCoins'])
        return true
    else
        return false
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuyItemShop - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.BuyItemShop(data)
    local source = source
    local user_id = vRP.getUserId(source)

    if Inventory.ConsultItem(source, user_id, data["shop"].spawnName) then
        if Loja.consultDuthCoins({ source = source, value = data["shop"].price, user_id = user_id }) then
            Inventory.GiveItem(source, user_id, data["shop"])
            TriggerClientEvent("Notify",source,"sucess","Você comprou <b>"..data["shop"].name.."</b> por <b>"..data["shop"].price.."</b> Duth Coins.")
        else
            TriggerClientEvent("Notify",source,"negado","Você não tem <b>Duth Coins</b> necessário para comprar esse item.")
        end
    else
        TriggerClientEvent("Notify",source,"negado","Você já tem esse item.")
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Loja - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Loja",function()
    return Loja
end)
