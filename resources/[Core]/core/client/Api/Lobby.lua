local api = {}
Tunnel.bindInterface('core:lobbyApi', api)

local GUILD_INVITE_MESSAGE = 'Você foi convidado para fazer parte do clã <b>%s | %s</b>, deseja aceitar?'
local GROUP_INVITE_MESSAGE = 'Você foi convidado para fazer parte do grupo do(a) <b>%s | %s</b>, deseja aceitar?'

local currentRequestPromise = nil

local function awaitCurrentRequest()
    while currentRequestPromise do
        local timeToWait = math.random(50, 500)

        Citizen.Await(currentRequestPromise)
        Citizen.Wait(timeToWait)
    end
end

function api.requestInvite(requestType, tag, name)
    awaitCurrentRequest()

    tag = tag or 'N/A'
    name = name or 'N/A'

    local message = ''

    currentRequestPromise = promise.new()

    if requestType == 'GUILD' then
        message = GUILD_INVITE_MESSAGE:format(tag, name)
    elseif requestType == 'GROUP' then
        message = GROUP_INVITE_MESSAGE:format(tag, name)
    end

    SendNUIMessage({
        action = 'inviteRequest', 
        data = {
            text = message, 
            timeInSeconds = 10
        }
    })

    return Citizen.Await(currentRequestPromise)
end

RegisterNUICallback('requestResponse', function(data, responseTrigger)
    if currentRequestPromise then
        currentRequestPromise:resolve(data.status)

        currentRequestPromise = nil
    end

    responseTrigger({})
end)