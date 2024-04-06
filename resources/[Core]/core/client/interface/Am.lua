-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local players = {}
local staffList = {}
local inStaffMode = false
local adminMode = false
local newAm = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('am-reset',function(source, args, rawCmd)
    players = {}
    adminMode = false 
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AM : THREAD
-----------------------------------------------------------------------------------------------------------------------------------------
function StartThread(params)
    newAm = params
    Citizen.CreateThread(function()
        while adminMode do
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            
            for k,v in pairs(GetActivePlayers()) do 
                local nsource = GetPlayerServerId(v)
                local nped = GetPlayerPed(v)
                local ncoords = GetEntityCoords(nped)
                if ped ~= nped then
                    if players[nsource] and players[nsource] ~= nil and nped and nped ~= nil then
                        if Vdist(coords,ncoords) <= 300 then
                            local data = players[nsource]
                            local veh = GetVehiclePedIsIn(ped)
                            
                            
                            if newAm == "box" then
                                local display_text = (data.group ~= "") and data.group or data.user_id
                                DrawText3D(ncoords.x, ncoords.y, ncoords.z + 0.85, "~w~[~r~" .. display_text .. "~w~] " .. data.name .. "~w~")

                                LineOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)
                                LineOneEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)
                                LineTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)
                                LineTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                LineThreeBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                LineThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, -0.9)
                                LineFourBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)

                                TLineOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)
                                TLineOneEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                TLineTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                TLineTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                TLineThreeBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                TLineThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, 0.8)
                                TLineFourBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)

                                ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, 0.8)
                                ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, -0.9)
                                ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)
                                ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)
                                ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)

                                DrawLine(
                                    LineOneBegin.x,
                                    LineOneBegin.y,
                                    LineOneBegin.z,
                                    LineOneEnd.x,
                                    LineOneEnd.y,
                                    LineOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineTwoBegin.x,
                                    LineTwoBegin.y,
                                    LineTwoBegin.z,
                                    LineTwoEnd.x,
                                    LineTwoEnd.y,
                                    LineTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineThreeBegin.x,
                                    LineThreeBegin.y,
                                    LineThreeBegin.z,
                                    LineThreeEnd.x,
                                    LineThreeEnd.y,
                                    LineThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineThreeEnd.x,
                                    LineThreeEnd.y,
                                    LineThreeEnd.z,
                                    LineFourBegin.x,
                                    LineFourBegin.y,
                                    LineFourBegin.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineOneBegin.x,
                                    TLineOneBegin.y,
                                    TLineOneBegin.z,
                                    TLineOneEnd.x,
                                    TLineOneEnd.y,
                                    TLineOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineTwoBegin.x,
                                    TLineTwoBegin.y,
                                    TLineTwoBegin.z,
                                    TLineTwoEnd.x,
                                    TLineTwoEnd.y,
                                    TLineTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineThreeBegin.x,
                                    TLineThreeBegin.y,
                                    TLineThreeBegin.z,
                                    TLineThreeEnd.x,
                                    TLineThreeEnd.y,
                                    TLineThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineThreeEnd.x,
                                    TLineThreeEnd.y,
                                    TLineThreeEnd.z,
                                    TLineFourBegin.x,
                                    TLineFourBegin.y,
                                    TLineFourBegin.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorOneBegin.x,
                                    ConnectorOneBegin.y,
                                    ConnectorOneBegin.z,
                                    ConnectorOneEnd.x,
                                    ConnectorOneEnd.y,
                                    ConnectorOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorTwoBegin.x,
                                    ConnectorTwoBegin.y,
                                    ConnectorTwoBegin.z,
                                    ConnectorTwoEnd.x,
                                    ConnectorTwoEnd.y,
                                    ConnectorTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorThreeBegin.x,
                                    ConnectorThreeBegin.y,
                                    ConnectorThreeBegin.z,
                                    ConnectorThreeEnd.x,
                                    ConnectorThreeEnd.y,
                                    ConnectorThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorFourBegin.x,
                                    ConnectorFourBegin.y,
                                    ConnectorFourBegin.z,
                                    ConnectorFourEnd.x,
                                    ConnectorFourEnd.y,
                                    ConnectorFourEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )

                                DrawLine(coords.x,coords.y,coords.z,ncoords.x,ncoords.y,ncoords.z,255,255,255, 255)
                            elseif newAm == "special" then
                                LineOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)
                                LineOneEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)
                                LineTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)
                                LineTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                LineThreeBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                LineThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, -0.9)
                                LineFourBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)

                                TLineOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)
                                TLineOneEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                TLineTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                TLineTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                TLineThreeBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                TLineThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, 0.8)
                                TLineFourBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)

                                ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, 0.8)
                                ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, 0.3, -0.9)
                                ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, 0.8)
                                ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, 0.3, -0.9)
                                ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, 0.8)
                                ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(nped, -0.3, -0.3, -0.9)
                                ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, 0.8)
                                ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(nped, 0.3, -0.3, -0.9)

                                DrawLine(
                                    LineOneBegin.x,
                                    LineOneBegin.y,
                                    LineOneBegin.z,
                                    LineOneEnd.x,
                                    LineOneEnd.y,
                                    LineOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineTwoBegin.x,
                                    LineTwoBegin.y,
                                    LineTwoBegin.z,
                                    LineTwoEnd.x,
                                    LineTwoEnd.y,
                                    LineTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineThreeBegin.x,
                                    LineThreeBegin.y,
                                    LineThreeBegin.z,
                                    LineThreeEnd.x,
                                    LineThreeEnd.y,
                                    LineThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    LineThreeEnd.x,
                                    LineThreeEnd.y,
                                    LineThreeEnd.z,
                                    LineFourBegin.x,
                                    LineFourBegin.y,
                                    LineFourBegin.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineOneBegin.x,
                                    TLineOneBegin.y,
                                    TLineOneBegin.z,
                                    TLineOneEnd.x,
                                    TLineOneEnd.y,
                                    TLineOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineTwoBegin.x,
                                    TLineTwoBegin.y,
                                    TLineTwoBegin.z,
                                    TLineTwoEnd.x,
                                    TLineTwoEnd.y,
                                    TLineTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineThreeBegin.x,
                                    TLineThreeBegin.y,
                                    TLineThreeBegin.z,
                                    TLineThreeEnd.x,
                                    TLineThreeEnd.y,
                                    TLineThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    TLineThreeEnd.x,
                                    TLineThreeEnd.y,
                                    TLineThreeEnd.z,
                                    TLineFourBegin.x,
                                    TLineFourBegin.y,
                                    TLineFourBegin.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorOneBegin.x,
                                    ConnectorOneBegin.y,
                                    ConnectorOneBegin.z,
                                    ConnectorOneEnd.x,
                                    ConnectorOneEnd.y,
                                    ConnectorOneEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorTwoBegin.x,
                                    ConnectorTwoBegin.y,
                                    ConnectorTwoBegin.z,
                                    ConnectorTwoEnd.x,
                                    ConnectorTwoEnd.y,
                                    ConnectorTwoEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorThreeBegin.x,
                                    ConnectorThreeBegin.y,
                                    ConnectorThreeBegin.z,
                                    ConnectorThreeEnd.x,
                                    ConnectorThreeEnd.y,
                                    ConnectorThreeEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )
                                DrawLine(
                                    ConnectorFourBegin.x,
                                    ConnectorFourBegin.y,
                                    ConnectorFourBegin.z,
                                    ConnectorFourEnd.x,
                                    ConnectorFourEnd.y,
                                    ConnectorFourEnd.z,
                                    255,
                                    255,
                                    255,
                                    255
                                )

                                DrawLine(coords.x,coords.y,coords.z,ncoords.x,ncoords.y,ncoords.z,255,255,255, 255)
                            else
                                local display_text = (data.group ~= "") and data.group or data.user_id
                                DrawText3D(ncoords.x, ncoords.y, ncoords.z + 0.85, "~w~[~r~" .. display_text .. "~w~] " .. data.name .. "~w~")
                            end
                        end
                    end
                end
            end

           
            Citizen.Wait(0) 
        end
    end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATELIST
-----------------------------------------------------------------------------------------------------------------------------------------
function src.updateList(status)
    players = status
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOGGLEAM
-----------------------------------------------------------------------------------------------------------------------------------------
function src.toggleAdmin(params)
    if adminMode then
        serverAPI.stopAm()
        adminMode = false
    else
        adminMode = true

        StartThread(params)
        serverAPI.startAm()
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAWTEXT3D
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.0, 0.32)
        SetTextColour(r, g, b, 255)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end