local serverId = 99
local serverKey = '410fe242-bb57-4c0f-96a8-1b117f9a423c'

local function ShieldmReleaseOnWhenConnected(name, setKickReason, deferrals)
    userIp = tostring(GetPlayerEndpoint(source))

    PerformHttpRequest("https://shieldm.neep.com.br/api/v1/server/" .. serverId .. "/allow/" .. userIp, function(err, data, headers)
        local result = ''

        if data then 
            result = 'Liberado com sucesso'
        elseif err and err == 400 then 
            result = 'Liberado anteriormente'
        else 
            result = 'Erro: ' .. err
        end

        -- print(string.format("Jogador %s conectando - IP: %s - Status: %s", name, userIp, result))
    end, "GET", "", {["X-SHIELDM-APIKEY"] = serverKey })
end

AddEventHandler("playerConnecting", ShieldmReleaseOnWhenConnected)
