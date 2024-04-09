-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
AntiCheat = {}
local AcInfo = {}
src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
AnticheatRecord = Tunnel.getInterface("anticheat")
-----------------------------------------------------------------------------------------------------------------------------------------
-- generateUUIDv4 - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local function generateUUIDv4()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
      local r = math.random(16) - 1
      local v = (c == 'x') and r or ((r & 0x3) | 0x8)
      return string.format('%x', v)
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GetVideoCurrentMinute - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function GetVideoCurrentTime(user_id)
    if AcInfo[user_id].videoStartTime then
        local elapsedTime = os.time() - AcInfo[user_id].videoStartTime
        
        local minutes = math.floor(elapsedTime / 60)
        local seconds = elapsedTime % 60
        
        -- Formatar o horário como "hh:mm"
        local currentTime = string.format("%02d:%02d", minutes, seconds)
        
        return currentTime
    end

    return nil 
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadUserReports - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function AntiCheat.StartAC(source, user_id)
    AcInfo[user_id] = {
        game_uuid = generateUUIDv4(),
        game_data = {},
        game_state = "rolling",
        videoStartTime = os.time()
    }

    AnticheatRecord.StartVideoRecording(source, {
        name = "Luiz",
        uid = AcInfo[user_id].game_uuid,
        reason = "AntiCheat",
        reportedBy = "AntiCheat",
    })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SetData - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function AntiCheat.SetData(data)
    local dataAc = AcInfo[data.user_id]

    dataAc.game_data[GetVideoCurrentTime(data.user_id)] = data.text

    Wait(500)
    print(dump(dataAc))
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AntiCheat - Exports
-----------------------------------------------------------------------------------------------------------------------------------------
exports("AntiCheat",function()
    return AntiCheat
end)