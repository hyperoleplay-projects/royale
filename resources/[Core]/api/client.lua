-----------------------------------------------------------------------------------------------------------------------------------------
-- 
-----------------------------------------------------------------------------------------------------------------------------------------
LuizDev = {}
LuizDev.LobbyEnitys = {}
LuizDev.PedsLobby = {}
LuizDev.PedsClient = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- reMapData
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.reMapData(game_data)
	-- print(dump(game_data))
	-- RED
	local cntRed = 0
	local _redList = game_data
	game_data = {}
	for k,v in pairs(_redList) do
		cntRed = cntRed + 1
		game_data[cntRed] = v
	end
	return game_data
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADPTFXASSET
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.LoadPtfxAsset(Library)
	while not HasNamedPtfxAssetLoaded(Library) do
		RequestNamedPtfxAsset(Library)
		Wait(1)
	end

	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getCustomization
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.getCustomization(peddd)
	local custom = {}
	custom.modelhash = GetEntityModel(peddd)

	for i = 0,20 do
		custom[i] = { GetPedDrawableVariation(peddd,i),GetPedTextureVariation(peddd,i),GetPedPaletteVariation(peddd,i) }
	end

	for i = 0,10 do
		custom["p"..i] = { GetPedPropIndex(peddd,i),math.max(GetPedPropTextureIndex(peddd,i),0) }
	end
	return custom
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Thread
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.Thread(callback, threadDelay)
	CreateThread(function()
		local delay = threadDelay or 0
		while true do
			delay = callback() or delay
			Wait(delay)
		end
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DrawText3Ds
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.DrawText3Ds(text, position, color, textScale, font)
    local _, screenX, screenY = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)

    if not textScale then
        textScale = 0.35
    end

    if not font then
        font = 4
    end

    SetTextScale(textScale, textScale)
    SetTextFont(font)
    SetTextProportional(true)
    SetTextColour(color[1],color[2],color[3],color[4])
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- createCBlip
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.createCBlip(vector3Pos, intSprite, intColor, stringText, boolRoad, floatScale, intDisplay, intAlpha)
	local blip = AddBlipForCoord(vector3Pos.x, vector3Pos.y, vector3Pos.z)
	SetBlipSprite(blip, intSprite)
	SetBlipAsShortRange(blip, true)
	if intColor then SetBlipColour(blip, intColor) end
	if floatScale then SetBlipScale(blip, floatScale) end
	if boolRoad then SetBlipRoute(blip, boolRoad) end
	if intDisplay then SetBlipDisplay(blip, intDisplay) end
	if intAlpha then SetBlipAlpha(blip, intAlpha) end
	if stringText and (not intDisplay or intDisplay ~= 8) then
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(stringText)
		EndTextCommandSetBlipName(blip)
	end
	return blip
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SecondsToClock
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.SecondsToClock(seconds)
	if seconds <= 0 then
		return "00:00";
	else
		mins = string.format("%02.f", math.floor(seconds / 60 - (math.floor(seconds / 3600) * 60)));
		secs = string.format("%02.f", math.floor(seconds - math.floor(seconds / 3600) * 3600 - mins * 60));
		return mins .. ":" .. secs
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- createCBlip
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.createCBlip(vector3Pos, intSprite, intColor, stringText, boolRoad, floatScale, intDisplay, intAlpha)
	local blip = AddBlipForCoord(vector3Pos.x, vector3Pos.y, vector3Pos.z)
	SetBlipSprite(blip, intSprite)
	SetBlipAsShortRange(blip, true)
	if intColor then SetBlipColour(blip, intColor) end
	if floatScale then SetBlipScale(blip, floatScale) end
	if boolRoad then SetBlipRoute(blip, boolRoad) end
	if intDisplay then SetBlipDisplay(blip, intDisplay) end
	if intAlpha then SetBlipAlpha(blip, intAlpha) end
	if stringText and (not intDisplay or intDisplay ~= 8) then
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(stringText)
		EndTextCommandSetBlipName(blip)
	end
	return blip
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- GenerateCenterPoint
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.GenerateCenterPoint(distance, notDIVIDED)
	local vec = vector3(0.0, 0.0, 0.0)

	local radius = math.floor(distance / 6)
	while Vmag(vec) < distance do
		vec = vec + vector3(math.random(-radius, radius), math.random(-radius, radius), 0.0)
		Citizen.Wait(0)
	end

	return notDIVIDED and vec or vec - vec / 2
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RequestAndWaitModel
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.RequestAndWaitModel(model)
	if IsModelInCdimage(model) and not HasModelLoaded(model) then
		RequestModel(model)
		while not HasModelLoaded(model) do
			Citizen.Wait(0)
		end

		return true
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RequestModel
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.RequestModel(model, callback)
    CreateThread(function()
        local modelHash
        
        if type(model) == "number" then
            modelHash = model
            model = false
        else
            modelHash = GetHashKey(model)
        end

        if not IsModelInCdimage(modelHash) then
            callback(false, model, modelHash)
            error("Model: " .. tostring(model or modelHash) .. " doesn't exist!")
        end

        RequestModel(modelHash)

        local timeOut = GetGameTimer()
        local breakOut = false

        while not HasModelLoaded(modelHash) and not breakOut do
            Wait(100)

            --RequestModel(modelHash)

            if GetGameTimer() - timeOut >= 10000 then
                callback(false, model, modelHash)
                error("Model: " .. tostring(model or modelHash) .. " request timed while loading!")
                breakOut = true
            end
        end

        callback(true, model, modelHash)
    end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Draw3DText
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
    local scale = (1/dist)*20
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov   
    SetTextScale(scaleX*scale, scaleY*scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextColour(250, 250, 250, 255)		-- You can change the text color here
    -- SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    -- SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x,y,z+2, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LoadPed
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.LoadPed(ped, data, model)
    -- SetClothing(ped, data.drawables, data.props, data.drawtextures, data.proptextures)
    Citizen.Wait(500)

    SetPedComponentVariation(ped, 2, data.hairModel, 0, 0)
	SetPedHairColor(ped, tonumber(data.firstHairColor), tonumber(data.secondHairColor))

	-- Sobracelha 
	SetPedHeadOverlay(ped, 2, data.eyebrowsModel, 0.99)
	SetPedHeadOverlayColor(ped, 2, 1, data.eyebrowsColor, data.eyebrowsColor)

	-- Barba
	SetPedHeadOverlay(ped, 1, data.beardModel, 0.99)
	SetPedHeadOverlayColor(ped, 1, 1, data.beardColor, data.beardColor)

    -- Pelo Corporal
    SetPedHeadOverlay(ped, 10, data.chestModel, 0.99)
    SetPedHeadOverlayColor(ped, 10, 1, data.chestColor, data.chestColor)

    -- Blush
    SetPedHeadOverlay(ped, 5, data.blushModel, 0.99)
    SetPedHeadOverlayColor(ped, 5, 2, data.blushColor, data.blushColor)

    -- Battom
    SetPedHeadOverlay(ped, 8, data.lipstickModel, 0.99)
    SetPedHeadOverlayColor(ped, 8, 2, data.lipstickColor, data.lipstickColor)

	-- Manchas
	SetPedHeadOverlay(ped, 0, data.blemishesModel, 0.99)
	SetPedHeadOverlayColor(ped, 0, 0, 0, 0)

	-- Envelhecimento
	SetPedHeadOverlay(ped, 3, data.ageingModel, 0.99)
	SetPedHeadOverlayColor(ped, 3, 0, 0, 0)

	-- Aspecto
	SetPedHeadOverlay(ped, 6, data.complexionModel, 0.99)
	SetPedHeadOverlayColor(ped, 6, 0, 0, 0)

	-- Pele
	SetPedHeadOverlay(ped, 7, data.sundamageModel, 0.99)
	SetPedHeadOverlayColor(ped, 7, 0, 0, 0)

	-- Sardas
	SetPedHeadOverlay(ped, 9, data.frecklesModel, 0.99)
	SetPedHeadOverlayColor(ped, 9, 0, 0, 0)

	-- Maquiagem
	SetPedHeadOverlay(ped, 4, data.makeupModel, 0.99)
	SetPedHeadOverlayColor(ped, 4, 0, 0, 0)
    
	-- Olhos
	SetPedEyeColor(ped, data.eyesColor)

	-- Sobrancelha
	SetPedFaceFeature(ped, 6, data.eyebrowsHeight)
	SetPedFaceFeature(ped, 7, data.eyebrowsWidth)
	-- Nariz
	SetPedFaceFeature(ped, 0, data.noseWidth)
	SetPedFaceFeature(ped, 1, data.noseHeight)
	SetPedFaceFeature(ped, 2, data.noseLength)
	SetPedFaceFeature(ped, 3, data.noseBridge)
	SetPedFaceFeature(ped, 4, data.noseTip)
	SetPedFaceFeature(ped, 5, data.noseShift)

	-- Bochechas
	SetPedFaceFeature(ped, 8, data.cheekboneHeight)
	SetPedFaceFeature(ped, 9, data.cheekboneWidth)
	SetPedFaceFeature(ped, 10, data.cheeksWidth)

	-- Boca/Mandibula
	SetPedFaceFeature(ped, 12, data.lips)
	SetPedFaceFeature(ped, 13, data.jawWidth)
	SetPedFaceFeature(ped, 14, data.jawHeight)
	-- Queixo
	SetPedFaceFeature(ped, 15, data.chinLength)
	SetPedFaceFeature(ped, 16, data.chinPosition)
	SetPedFaceFeature(ped, 17, data.chinWidth)
	SetPedFaceFeature(ped, 18, data.chinShape)
	-- Pescoço
	SetPedFaceFeature(ped, 19, data.neckWidth)
    return
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- parse_part
-----------------------------------------------------------------------------------------------------------------------------------------
local function parse_part(key)
	if type(key) == "string" and string.sub(key,1,1) == "p" then
		return true,tonumber(string.sub(key,2))
	else
		return false,tonumber(key)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- tablelength
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- formatTwoDigitNumbers
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.formatTwoDigitNumbers(string)
	string = tostring(string)
	return string.len(string) == 1 and "0" .. string or string
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DeleteAllVehicles
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.DeleteAllVehicles()
	local handle, veh = FindFirstVehicle()
	local success
	repeat
		success, veh = FindNextVehicle(handle)
		if DoesEntityExist(veh) then DeleteVehicle(veh) end
	until not success
		EndFindVehicle(handle)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- dump
-----------------------------------------------------------------------------------------------------------------------------------------
function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getWeaponsShop
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.getWeaponsShop() 
	return LuizDev.WeaponsShop	
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- f BODY
-----------------------------------------------------------------------------------------------------------------------------------------
function f(n)
	n = n + 0.00000
	return n
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC BODY
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.TaskUpdateSkinOptions(ped, custom)
	local data = custom
	SetPedHeadBlendData(ped,data.fathersID,data.mothersID,0,data.skinColor,0,0,f(data.shapeMix),0,0,false)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC FACE
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.TaskUpdateFaceOptions(peddd, custom)
	local ped = peddd
	local data = custom

	-- Olhos
	SetPedEyeColor(ped,data.eyesColor)
	-- Sobrancelha
	SetPedFaceFeature(ped,6,data.eyebrowsHeight)
	SetPedFaceFeature(ped,7,data.eyebrowsWidth)
	-- Nariz
	SetPedFaceFeature(ped,0,data.noseWidth)
	SetPedFaceFeature(ped,1,data.noseHeight)
	SetPedFaceFeature(ped,2,data.noseLength)
	SetPedFaceFeature(ped,3,data.noseBridge)
	SetPedFaceFeature(ped,4,data.noseTip)
	SetPedFaceFeature(ped,5,data.noseShift)
	-- Bochechas
	SetPedFaceFeature(ped,8,data.cheekboneHeight)
	SetPedFaceFeature(ped,9,data.cheekboneWidth)
	SetPedFaceFeature(ped,10,data.cheeksWidth)
	-- Boca/Mandibula
	SetPedFaceFeature(ped,12,data.lips)
	SetPedFaceFeature(ped,13,data.jawWidth)
	SetPedFaceFeature(ped,14,data.jawHeight)
	-- Queixo
	SetPedFaceFeature(ped,15,data.chinLength)
	SetPedFaceFeature(ped,16,data.chinPosition)
	SetPedFaceFeature(ped,17,data.chinWidth)
	SetPedFaceFeature(ped,18,data.chinShape)
	-- Pescoço
	SetPedFaceFeature(ped,19,data.neckWidth)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC HEAD
-----------------------------------------------------------------------------------------------------------------------------------------
function LuizDev.TaskUpdateHeadOptions(peddd, custom)
	local ped = peddd
	local data = custom
    
	-- Cabelo
	SetPedComponentVariation(ped,2,data.hairModel,0,0)
	SetPedHairColor(ped,data.firstHairColor,data.secondHairColor)
	-- Sobrancelha
	SetPedHeadOverlay(ped,2,data.eyebrowsModel, 0.99)
	SetPedHeadOverlayColor(ped,2,1,data.eyebrowsColor,data.eyebrowsColor)
	-- Barba
	SetPedHeadOverlay(ped,1,data.beardModel,0.99)
	SetPedHeadOverlayColor(ped,1,1,data.beardColor,data.beardColor)
	-- Pelo Corporal
	SetPedHeadOverlay(ped,10,data.chestModel,0.99)
	SetPedHeadOverlayColor(ped,10,1,data.chestColor,data.chestColor)
	-- Blush
	SetPedHeadOverlay(ped,5,data.blushModel,0.99)
	SetPedHeadOverlayColor(ped,5,2,data.blushColor,data.blushColor)
	-- Battom
	SetPedHeadOverlay(ped,8,data.lipstickModel,0.99)
	SetPedHeadOverlayColor(ped,8,2,data.lipstickColor,data.lipstickColor)
	
	-- Manchas
	SetPedHeadOverlay(ped,0,data.blemishesModel,0.99)
	SetPedHeadOverlayColor(ped,0,0,0,0)
	-- Envelhecimento
	SetPedHeadOverlay(ped,3,data.ageingModel,0.99)
	SetPedHeadOverlayColor(ped,3,0,0,0)
	-- Aspecto
	SetPedHeadOverlay(ped,6,data.complexionModel,0.99)
	SetPedHeadOverlayColor(ped,6,0,0,0)
	-- Pele
	SetPedHeadOverlay(ped,7,data.sundamageModel,0.99)
	SetPedHeadOverlayColor(ped,7,0,0,0)
	-- Sardas
	SetPedHeadOverlay(ped,9,data.frecklesModel,0.99)
	SetPedHeadOverlayColor(ped,9,0,0,0)
	-- Maquiagem
	SetPedHeadOverlay(ped,4,data.makeupModel,0.99)
	SetPedHeadOverlayColor(ped,4,0,data.makeupcolor,data.makeupcolor)
end

return LuizDev
