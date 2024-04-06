function Commands.addCoins(user_id, coins)
    SQL('UPDATE users SET duthCoins = duthCoins + ? WHERE id = ?', { coins, user_id })
    SQL("INSERT INTO payments_requests(user_id, type) VALUES(?,?)", { user_id, "UpdateProfile" })
end

function Commands.addPrioridadeShop(user_id)
    local identifiers = SQL("SELECT * FROM users_identifiers WHERE user_id = ?", {user_id})
    for k,v in pairs(identifiers) do
        if string.match(v.identifier,'steam:') then 
            SQL("INSERT INTO queue(user_id,steam,nickname,priority) VALUES(?,?,?,?)", {user_id, v.identifier, "Loja", 80})
            return
        end
    end
end

