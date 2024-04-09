RegisterNUICallback("RecuseRequets", function(data, cb)
    local RecuseRequets = serverAPI.RecuseRequets(data.id)
    cb(RecuseRequets)
end)

RegisterNUICallback("AcceptRequets", function(data, cb)
    local AcceptRequets = serverAPI.AcceptRequets(data.id)
    cb(AcceptRequets)
end)