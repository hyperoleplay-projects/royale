----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local isResgating = false
local isBuyPasse = false
----------------------------------------------------------------------------------------------------------------------------------------
-- rewardBattlePass - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rewardBattlePass", function(data, cb)
    if not isResgating then
        isResgating = true
        serverAPI.rewardBattlePass()
            
        SetTimeout(5000, function() -- tunnel/proxy delay
            isResgating = false
        end)
    end
    cb("ok")
end)
----------------------------------------------------------------------------------------------------------------------------------------
-- BuyPasse - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("BuyPasse", function(data, cb)
    if not isBuyPasse then
        isBuyPasse = true
        serverAPI.BuyPasse()
            
        SetTimeout(5000, function() -- tunnel/proxy delay
            isBuyPasse = false
        end)
    end
    cb("ok")
end)