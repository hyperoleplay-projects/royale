Premium = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- generateVipPerDays - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Premium.generateVipPerDays(params)
    local timeConverted = params.timeInDays * 86400 + os.time()
    local identity = vRP.getIdentity(params.user_id)

    local alreadyHasVipQuery = exports.oxmysql:query_async("SELECT `id`, `expire_time` FROM `vips` WHERE `category` = @category AND `is_active` = true AND `user_id` = @user_id",{ category = params.category, user_id = params.user_id })
    if #alreadyHasVipQuery > 0 then
        local newExpire = alreadyHasVipQuery[1].expire_time + (params.timeInDays * 86400)
        exports.oxmysql:query("UPDATE `vips` SET `expire_time` = @expireTime WHERE `id` = @id",{ id = alreadyHasVipQuery[1].id, expireTime = newExpire })
        return
    end

    local insertId = exports.oxmysql:query_async("INSERT INTO `vips` (`user_id`,`category`,`expire_time`) VALUES (@user_id,@category,@expire_time)",{ user_id = params.user_id, category = params.category, expire_time = timeConverted }).insertId
    
    vRP.execute('vRP/deletePriority',{ user_id = params.user_id })
    local identifiers = vRP.query('vRP/getIdentifiers',{ user_id = params.user_id })
    for k,v in pairs(identifiers) do
        if string.match(v.identifier,'steam:') then 
            vRP.execute('vRP/insertPriority',{
                user_id = params.user_id,
                steam = v.identifier,
                nickname = identity.username,
                priority = 100                
            })
            return
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- isVipByUserId - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Premium.isVipByUserId(user_id,category)
    -- local query = exports.oxmysql:query_async("SELECT `category` FROM `vips` WHERE `user_id` = @user_id AND `is_active` = true",{ user_id = user_id })
    -- if #query > 0 then
    --     if not category then
    --         return true, query[#query].category
    --     else
    --         for k,v in pairs(query) do
    --             if v.category == category then
    --                 return true
    --             end
    --         end
    --     end
    -- end
    return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- checkExpired - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Premium.checkExpired()
    -- local query = exports.oxmysql:query_async("SELECT * FROM vips WHERE `is_active` = true AND `expire_time` IS NOT NULL")
    -- for k,v in pairs(query) do
    --     if os.time() >= v.expire_time then
    --         exports.oxmysql:query("UPDATE `vips` SET `is_active` = false, `expire_time` = NULL, `expired_at` = NOW() WHERE `id` = @id",{ id = v.id })
    --         vRP.execute('vRP/deletePriority',{ user_id = v.id })
    --     end
    -- end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- onResourceStart - Function
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("onResourceStart",function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    Premium.checkExpired()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Premium - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Premium",function()
    return Premium
end)