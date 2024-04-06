Loja = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- consultPrice - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Loja.consultPrice(data)
    local rows = vRP.query("vRP/requestUser",{ id = data.user_id })

    if data.type == "coins" then
        if rows[1].duthCoins >= tonumber(data.value) then
            vRP.execute('vRP/removeCoins', { id = data.user_id, duthCoins = data.value })
            local rows = vRP.query("vRP/requestUser", { id = data.user_id })
            clientAPI.clearInfoCache(data.source, 'profile')
            return true
        else
            return false
        end
    end

    if data.type == "points" then
        if rows[1].duthPoints >= tonumber(data.value) then
            vRP.execute('vRP/removePoints', { id = data.user_id, duthPoints = data.value })
            local rows = vRP.query("vRP/requestUser", { id = data.user_id })
            clientAPI.clearInfoCache(data.source, 'profile')
            return true
        else
            return false
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Loja - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Loja",function()
    return Loja
end)
