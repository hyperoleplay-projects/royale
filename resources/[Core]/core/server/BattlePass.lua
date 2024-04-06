BattlePass = {}
BattlePass.Passe = {
    ["Free"] = {
        ["mp_m_freemode_01"] = {},

        ["mp_f_freemode_01"] = {},
    },

    ["Premium"] = {
        ["mp_m_freemode_01"] = {},

        ["mp_f_freemode_01"] = {},
    }
}


function BattlePass.BuildPass() 
    local passeMasculinoFree = vRP.query("vRP/getItensPasseWhere",{ type = "Free", sex = "mp_m_freemode_01" })
    local passeMasculinoPremium = vRP.query("vRP/getItensPasseWhere",{ type = "Premium", sex = "mp_m_freemode_01" })
    local passeFemininoFree = vRP.query("vRP/getItensPasseWhere",{ type = "Free", sex = "mp_f_freemode_01" })
    local passeFemininoPremium = vRP.query("vRP/getItensPasseWhere",{ type = "Premium", sex = "mp_f_freemode_01" })

    BattlePass.Passe["Free"]["mp_m_freemode_01"] = {}
    BattlePass.Passe["Premium"]["mp_m_freemode_01"] = {}
    
    BattlePass.Passe["Free"]["mp_f_freemode_01"] = {}
    BattlePass.Passe["Premium"]["mp_f_freemode_01"] = {}

    for _, masculinoFree in pairs(passeMasculinoFree) do 
        BattlePass.Passe["Free"]["mp_m_freemode_01"][masculinoFree.level] = {
            title = masculinoFree.name,
            spawnName = masculinoFree.spawnName,
            amount = 1,
            category = masculinoFree.category,
            image = masculinoFree.image
        }
    end

    for _, masculinoPremium in pairs(passeMasculinoPremium) do 
        BattlePass.Passe["Premium"]["mp_m_freemode_01"][masculinoPremium.level] = {
            title = masculinoPremium.name,
            spawnName = masculinoPremium.spawnName,
            amount = 1,
            category = masculinoPremium.category,
            image = masculinoPremium.image
        }
    end

    for _, femininoFree in pairs(passeFemininoFree) do 
        BattlePass.Passe["Free"]["mp_f_freemode_01"][femininoFree.level] = {
            title = femininoFree.name,
            spawnName = femininoFree.spawnName,
            amount = 1,
            category = femininoFree.category,
            image = femininoFree.image
        }
    end

    for _, femininoPremium in pairs(passeFemininoPremium) do 
        BattlePass.Passe["Premium"]["mp_f_freemode_01"][femininoPremium.level] = {
            title = femininoPremium.name,
            spawnName = femininoPremium.spawnName,
            amount = 1,
            category = femininoPremium.category,
            image = femininoPremium.image
        }
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateThread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    BattlePass.BuildPass()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BattlePass - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("BattlePass",function()
    return BattlePass
end)
