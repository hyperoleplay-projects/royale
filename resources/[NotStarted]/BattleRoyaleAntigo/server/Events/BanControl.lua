-----------------------------------------------------------------------------------------------------------------------------------------
-- PERMANENTBAN
-----------------------------------------------------------------------------------------------------------------------------------------
function permanentBan(data)
    local request = exports.oxmysql:query_async("SELECT * FROM bans WHERE user_id = ?",{ parseInt(data.user_id) })
    if request[1] then
        TriggerClientEvent("Notify", vRP.getUserSource(parseInt(data.staff_id)), "sucess", "Este jogador já está banido.", 15000)
        return  
    end

    exports.oxmysql:query("INSERT INTO bans (user_id,reason,type,staff_id) VALUES (?,?,?,?)",{ parseInt(data.user_id),tostring(data.reason),tostring("permanent"),parseInt(data.staff_id) })
    TriggerClientEvent("Notify", vRP.getUserSource(parseInt(data.staff_id)), "sucess", "Banimento aplicado com sucesso.", 15000)

    if vRP.getUserSource(data.user_id) then
        vRP.kick(vRP.getUserSource(data.user_id),"\n\nSeu acesso a comunidade foi revogado permanentemente.\nMotivo: "..data.reason.."\n\nPara mais informações entre em contato via ticket.") 
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TEMPORARYBAN
-----------------------------------------------------------------------------------------------------------------------------------------
function temporaryBan(data)
    local request = exports.oxmysql:query_async("SELECT * FROM bans WHERE user_id = ?",{ parseInt(data.user_id) })
    if request[1] then
        -- TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),{ type = "error", text = "Este jogador já está banido." })
        TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),"negado","Este jogador já está banido." )	
        return  
    end

    if parseInt(data.timeBan) then
        local timeBan = data.timeBan * 86400 + os.time()
        
        exports.oxmysql:query("INSERT INTO bans (user_id,reason,type,time,staff_id) VALUES (?,?,?,?,?)",{ parseInt(data.user_id),tostring(data.reason),tostring("temporary"),timeBan,parseInt(data.staff_id) })
        -- TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),{ type = "sucess", text = "Banimento aplicado com sucesso." })
        TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),"sucess","Banimento aplicado com sucesso." )	
        
        if vRP.getUserSource(data.user_id) then
            vRP.kick(vRP.getUserSource(data.user_id),"\n\nSeu acesso a comunidade foi revogado por "..data.timeBan.." dia(s).\nMotivo: "..data.reason.."\n\nPara mais informações entre em contato via ticket.") 
        end
    else
        -- TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),{ type = "error", text = "O tempo de ban está no formato incorreto." })
        TriggerClientEvent("Notify",vRP.getUserSource(parseInt(data.staff_id)),"sucess","O tempo de ban está no formato incorreto." )
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKBAN
-----------------------------------------------------------------------------------------------------------------------------------------
function checkBan(data)
    local request = exports.oxmysql:query_async("SELECT * FROM bans WHERE user_id = ?",{ parseInt(data.user_id) })
    if request[1] then
        if tostring(request[1].type) == "temporary" then
            if os.time() >= parseInt(request[1].time) then
                exports.oxmysql:query("DELETE FROM bans WHERE user_id = ?",{ parseInt(data.user_id) })
                return { canJoin = true, request = nil }
            end
        end
        return { canJoin = false, request = request[1] }
    end
    return { canJoin = true, request = nil }
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- EXPORTS
-----------------------------------------------------------------------------------------------------------------------------------------
exports("permanentBan",permanentBan)
exports("temporaryBan",temporaryBan)
exports("checkBan",checkBan)