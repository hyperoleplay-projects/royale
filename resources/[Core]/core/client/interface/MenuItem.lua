----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local cam = nil
local camType = "head"
-----------------------------------------------------------------------------------------------------------------------------------------
-- CreateMenuNUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.CreateMenuNUI(data) 
    local colors = {
        hair = {},
        makeUp = {}
      }
    
    for i = 0, GetNumHairColors() - 1 do
      local hairColor = { GetPedHairRgbColor(i) }
      table.insert(colors.hair, hairColor)
    end

    for i = 0, GetNumMakeupColors() - 1 do
      local makeupColor = { GetMakeupRgbColor(i) }
      table.insert(colors.makeUp, makeupColor)
    end

    SendReactMessage('BuildColorsHair', colors.hair)
    SendReactMessage('BuildMakeup', colors.makeUp)


    data.ColorsHairData = colors.hair
    data.ColorsMakeUp = colors.makeU
    SendReactMessage('BuildDataMenuItems', data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- StatusMenuUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.StatusMenuUI(status, camStatus, type) 
	TriggerEvent("duth:ChatStatus", status)
    
    SetNuiFocus(status, status)
    SendReactMessage('setVisible', status)

    vRP._playAnim(false,{{"mp_sleep","bind_pose_180"}},true)
	SetCursorLocation(0.9,0.25)

    SendNUIMessage({
        action = "dashBoard",
        data = {
            open = true,
            page = '/modalitems'
        },
    })

    if type == "ROUPAS" then
        LocalPlayer.state.clothesNUI = true
    elseif type == "BARBEARIA" then
        LocalPlayer.state.barbeariaNUI = true
    elseif type == 'TATUAGEM' then
        LocalPlayer.state.TatuagemNUI = true
    end

    setCameraCoords(camStatus)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setCameraCoords - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setCameraCoords(status)
	if not status then
		RenderScriptCams(false,true,250,1,0)
		DestroyCam(cam,false)
		cam = nil
		MenuNUIStatus = false

		return;
	end

	cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
	SetCamActive(cam,true)
	RenderScriptCams(true,true,500,true,true)
	pos = GetEntityCoords(PlayerPedId())
	camPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(),0.0,2.0,0.0)
	SetCamCoord(cam,camPos["x"],camPos["y"],camPos["z"] + 0.75)
	PointCamAtCoord(cam,pos["x"],pos["y"],pos["z"] + 0.15)
    SetCamFov(cam, 45.0)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETUPCAM
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("setupCam",function(data, cb)
	local value = data["value"]
    
	if value == 1 then
        local coords, point = table.unpack(Config.CAMERAS['head'])
        local reverseFactor = reverseCamera and -1 or 1
        local camCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), coords.x * reverseFactor, coords.y * reverseFactor, coords.z * reverseFactor)
        local camPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), point.x, point.y, point.z)
		SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(cam, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(cam, cameraHandle, 1000, 1, 1)
        camType = "head"
	elseif value == 2 then
        local coords, point = table.unpack(Config.CAMERAS['body'])
        local reverseFactor = reverseCamera and -1 or 1
        local camCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), coords.x * reverseFactor, coords.y * reverseFactor, coords.z * reverseFactor)
        local camPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), point.x, point.y, point.z)
		SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(cam, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(cam, cameraHandle, 1000, 1, 1)
        camType = "body"
	elseif value == 3 then
        local coords, point = table.unpack(Config.CAMERAS['bottom'])
        local reverseFactor = reverseCamera and -1 or 1
        local camCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), coords.x * reverseFactor, coords.y * reverseFactor, coords.z * reverseFactor)
        local camPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), point.x, point.y, point.z)
		SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(cam, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(cam, cameraHandle, 1000, 1, 1)
        camType = "bottom"
    elseif value == 4 then
        local direction = "left"
        local coords, point = table.unpack(Config.CAMERAS[camType])
        local offset = Config.OFFSETS[camType]
        local sideFactor = direction == "left" and 1 or -1
        local reverseFactor = reverseCamera and -1 or 1

        local camCoords = GetOffsetFromEntityInWorldCoords(
            PlayerPedId(),
            (coords.x + offset.x) * sideFactor * reverseFactor,
            (coords.y + offset.y) * reverseFactor,
            coords.z
        )

        local camPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), point.x, point.y, point.z)
		SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(cam, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(cam, cameraHandle, 1000, 1, 1)
    elseif value == 5 then
        local direction = "right"
        local coords, point = table.unpack(Config.CAMERAS[camType])
        local offset = Config.OFFSETS[camType]
        local sideFactor = direction == "left" and 1 or -1
        local reverseFactor = reverseCamera and -1 or 1

        local camCoords = GetOffsetFromEntityInWorldCoords(
            PlayerPedId(),
            (coords.x + offset.x) * sideFactor * reverseFactor,
            (coords.y + offset.y) * reverseFactor,
            coords.z
        )

        local camPoint = GetOffsetFromEntityInWorldCoords(PlayerPedId(), point.x, point.y, point.z)
		SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
        PointCamAtCoord(cam, camPoint.x, camPoint.y, camPoint.z)
        SetCamActiveWithInterp(cam, cameraHandle, 1000, 1, 1)
	end

    cb({})
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local currentCharacterMode = { fathersID = 0, mothersID = 0, skinColor = 0, shapeMix = 0.0, eyesColor = 0, eyebrowsHeight = 0, eyebrowsWidth = 0, noseWidth = 0, noseHeight = 0, noseLength = 0, noseBridge = 0, noseTip = 0, noseShift = 0, cheekboneHeight = 0, cheekboneWidth = 0, cheeksWidth = 0, lips = 0, jawWidth = 0, jawHeight = 0, chinLength = 0, chinPosition = 0, chinWidth = 0, chinShape = 0, neckWidth = 0, hairModel = 4, firstHairColor = 0, secondHairColor = 0, eyebrowsModel = 0, eyebrowsColor = 0, beardModel = -1, beardColor = 0, chestModel = -1, chestColor = 0, blushModel = -1, blushColor = 0, lipstickModel = -1, lipstickColor = 0, blemishesModel = -1, ageingModel = -1, complexionModel = -1, sundamageModel = -1, frecklesModel = -1, makeupModel = -1 }
local oldTattos = {}
local atualTattos = {}
local skinData = {
	["pants"] = { item = 0, texture = 0 },
	["arms"] = { item = 0, texture = 0 },
	["tshirt"] = { item = 1, texture = 0 },
	["torso"] = { item = 0, texture = 0 },
	["vest"] = { item = 0, texture = 0 },
	["backpack"] = { item = 0, texture = 0 },
	["shoes"] = { item = 1, texture = 0 },
	["mask"] = { item = 0, texture = 0 },
	["hat"] = { item = -1, texture = 0 },
	["glass"] = { item = 0, texture = 0 },
	["ear"] = { item = -1, texture = 0 },
	["watch"] = { item = -1, texture = 0 },
	["bracelet"] = { item = -1, texture = 0 },
	["accessory"] = { item = 0, texture = 0 },
	["decals"] = { item = 0, texture = 0 }
}

local oldCustom = {
	["pants"] = { item = 0, texture = 0 },
	["arms"] = { item = 0, texture = 0 },
	["tshirt"] = { item = 1, texture = 0 },
	["torso"] = { item = 0, texture = 0 },
	["vest"] = { item = 0, texture = 0 },
	["backpack"] = { item = 0, texture = 0 },
	["shoes"] = { item = 1, texture = 0 },
	["mask"] = { item = 0, texture = 0 },
	["hat"] = { item = -1, texture = 0 },
	["glass"] = { item = 0, texture = 0 },
	["ear"] = { item = -1, texture = 0 },
	["watch"] = { item = -1, texture = 0 },
	["bracelet"] = { item = -1, texture = 0 },
	["accessory"] = { item = 0, texture = 0 },
	["decals"] = { item = 0, texture = 0 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEROUPAS - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateClothes(custom, updating) 
	skinData = json.decode(custom)
    oldCustom = json.decode(custom)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("updateClothes")
AddEventHandler("updateClothes",function(custom, updating)
	skinData = json.decode(custom)
    oldCustom = json.decode(custom)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ClothesClick
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("ClothesClick", function(data, cb)
    ChangeVariation(data)
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ChangeVariation
-----------------------------------------------------------------------------------------------------------------------------------------
function ChangeVariation(data)
	local ped = PlayerPedId()
    local types = "item" --Tipo se é item ou cor
	local item = parseInt(data.number) -- Numero da roupa
	local category = data.category-- Categoria da onde é a roupa
    local cor = parseInt(data.color)
    local sex = data.sex

    local tipo = ""
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		tipo = "mp_m_freemode_01"
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
		tipo = "mp_f_freemode_01"
    end

    -- if tipo == sex then
        if category == "pants" then
            if types == "item" then
                SetPedComponentVariation(ped,4,item,0,1)
                skinData["pants"]["item"] = item
            
                SetPedComponentVariation(ped,4,GetPedDrawableVariation(ped,4),cor,1)
                skinData["pants"]["texture"] = cor
            end
        elseif category == "arms" then
            if types == "item" then
                SetPedComponentVariation(ped,3,item,0,1)
                skinData["arms"]["item"] = item
            
                SetPedComponentVariation(ped,3,GetPedDrawableVariation(ped,3),cor,1)
                skinData["arms"]["texture"] = cor
            end
        elseif category == "tshirt" then
            if types == "item" then
                SetPedComponentVariation(ped,8,item,0,1)
                skinData["tshirt"]["item"] = item
            
                SetPedComponentVariation(ped,8,GetPedDrawableVariation(ped,8),cor,1)
                skinData["tshirt"]["texture"] = cor
            end
        elseif category == "vest" then
            if types == "item" then
                SetPedComponentVariation(ped,9,item,0,1)
                skinData["vest"]["item"] = item
            
                SetPedComponentVariation(ped,9,skinData["vest"]["item"],cor,1)
                skinData["vest"]["texture"] = cor
            end
        elseif category == "backpack" then
            if types == "item" then
                SetPedComponentVariation(ped,5,item,0,1)
                skinData["backpack"]["item"] = item
            
                SetPedComponentVariation(ped,5,skinData["backpack"]["item"],cor,1)
                skinData["backpack"]["texture"] = cor
            end
        elseif category == "decals" then
            if types == "item" then
                SetPedComponentVariation(ped,10,item,0,1)
                skinData["decals"]["item"] = item
            
                SetPedComponentVariation(ped,10,skinData["decals"]["item"],cor,1)
                skinData["decals"]["texture"] = cor
            end
        elseif category == "accessory" then
            if types == "item" then
                SetPedComponentVariation(ped,7,item,0,1)
                skinData["accessory"]["item"] = item
            
                SetPedComponentVariation(ped,7,skinData["accessory"]["item"],cor,1)
                skinData["accessory"]["texture"] = cor
            end
        elseif category == "torso" then
            if types == "item" then
                SetPedComponentVariation(ped,11,item,0,1)
                skinData["torso"]["item"] = item
            
                SetPedComponentVariation(ped,11,GetPedDrawableVariation(ped,11),cor,1)
                skinData["torso"]["texture"] = cor
            end
        elseif category == "shoes" then
            if types == "item" then
                SetPedComponentVariation(ped,6,item,0,1)
                skinData["shoes"]["item"] = item
            
                SetPedComponentVariation(ped,6,GetPedDrawableVariation(ped,6),cor,1)
                skinData["shoes"]["texture"] = cor
            end
        elseif category == "mask" then
            if types == "item" then
                SetPedComponentVariation(ped,1,item,0,1)
                skinData["mask"]["item"] = item
            
                SetPedComponentVariation(ped,1,GetPedDrawableVariation(ped,1),cor,1)
                skinData["mask"]["texture"] = cor
            end
        elseif category == "hat" then
            if types == "item" then
                if item ~= -1 then
                    SetPedPropIndex(ped,0,item,cor,1)
                else
                    ClearPedProp(ped,0)
                end
    
                skinData["hat"]["item"] = item
            
                SetPedPropIndex(ped,0,item,item,1)
                skinData["hat"]["texture"] = cor
            end
        elseif category == "glass" then
            if types == "item" then
                if item ~= -1 then
                    SetPedPropIndex(ped,1,item,cor,1)
                    skinData["glass"]["item"] = item
                else
                    ClearPedProp(ped,1)
                end
            
                SetPedPropIndex(ped,1,skinData["glass"]["item"],cor,1)
                skinData["glass"]["texture"] = cor
            end
        elseif category == "ear" then
            if types == "item" then
                if item ~= -1 then
                    SetPedPropIndex(ped,2,item,cor,1)
                else
                    ClearPedProp(ped,2)
                end
    
                skinData["ear"]["item"] = item
            
                SetPedPropIndex(ped,2,skinData["ear"]["item"],cor,1)
                skinData["ear"]["texture"] = cor
            end
        elseif category == "watch" then
            if types == "item" then
                if item ~= -1 then
                    SetPedPropIndex(ped,6,item,cor,1)
                else
                    ClearPedProp(ped,6)
                end
    
                skinData["watch"]["item"] = item
            
                SetPedPropIndex(ped,6,skinData["watch"]["item"],item,1)
                skinData["watch"]["texture"] = cor
            end
        elseif category == "bracelet" then
            if types == "item" then
                if item ~= -1 then
                    SetPedPropIndex(ped,7,item,cor,1)
                else
                    ClearPedProp(ped,7)
                end
    
                skinData["bracelet"]["item"] = item
            
                SetPedPropIndex(ped,7,skinData["bracelet"]["item"],item,1)
                skinData["bracelet"]["texture"] = cor
            end
        end













    -- elseif sex == "double" then
    --     if category == "pants" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,4,item,0,1)
    --             skinData["pants"]["item"] = item
            
    --             SetPedComponentVariation(ped,4,GetPedDrawableVariation(ped,4),cor,1)
    --             skinData["pants"]["texture"] = cor
    --         end
    --     elseif category == "arms" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,3,item,0,1)
    --             skinData["arms"]["item"] = item
            
    --             SetPedComponentVariation(ped,3,GetPedDrawableVariation(ped,3),cor,1)
    --             skinData["arms"]["texture"] = cor
    --         end
    --     elseif category == "tshirt" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,8,item,0,1)
    --             skinData["tshirt"]["item"] = item
            
    --             SetPedComponentVariation(ped,8,GetPedDrawableVariation(ped,8),cor,1)
    --             skinData["tshirt"]["texture"] = cor
    --         end
    --     elseif category == "vest" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,9,item,0,1)
    --             skinData["vest"]["item"] = item
            
    --             SetPedComponentVariation(ped,9,skinData["vest"]["item"],cor,1)
    --             skinData["vest"]["texture"] = cor
    --         end
    --     elseif category == "backpack" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,5,item,0,1)
    --             skinData["backpack"]["item"] = item
            
    --             SetPedComponentVariation(ped,5,skinData["backpack"]["item"],cor,1)
    --             skinData["backpack"]["texture"] = cor
    --         end
    --     elseif category == "decals" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,10,item,0,1)
    --             skinData["decals"]["item"] = item
            
    --             SetPedComponentVariation(ped,10,skinData["decals"]["item"],cor,1)
    --             skinData["decals"]["texture"] = cor
    --         end
    --     elseif category == "accessory" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,7,item,0,1)
    --             skinData["accessory"]["item"] = item
            
    --             SetPedComponentVariation(ped,7,skinData["accessory"]["item"],cor,1)
    --             skinData["accessory"]["texture"] = cor
    --         end
    --     elseif category == "torso" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,11,item,0,1)
    --             skinData["torso"]["item"] = item
            
    --             SetPedComponentVariation(ped,11,GetPedDrawableVariation(ped,11),cor,1)
    --             skinData["torso"]["texture"] = cor
    --         end
    --     elseif category == "shoes" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,6,item,0,1)
    --             skinData["shoes"]["item"] = item
            
    --             SetPedComponentVariation(ped,6,GetPedDrawableVariation(ped,6),cor,1)
    --             skinData["shoes"]["texture"] = cor
    --         end
    --     elseif category == "mask" then
    --         if types == "item" then
    --             SetPedComponentVariation(ped,1,item,0,1)
    --             skinData["mask"]["item"] = item
            
    --             SetPedComponentVariation(ped,1,GetPedDrawableVariation(ped,1),cor,1)
    --             skinData["mask"]["texture"] = cor
    --         end
    --     elseif category == "hat" then
    --         if types == "item" then
    --             if item ~= -1 then
    --                 SetPedPropIndex(ped,0,item,cor,1)
    --             else
    --                 ClearPedProp(ped,0)
    --             end
    
    --             skinData["hat"]["item"] = item
            
    --             SetPedPropIndex(ped,0,item,item,1)
    --             skinData["hat"]["texture"] = cor
    --         end
    --     elseif category == "glass" then
    --         if types == "item" then
    --             if item ~= -1 then
    --                 SetPedPropIndex(ped,1,item,cor,1)
    --                 skinData["glass"]["item"] = item
    --             else
    --                 ClearPedProp(ped,1)
    --             end
            
    --             SetPedPropIndex(ped,1,skinData["glass"]["item"],cor,1)
    --             skinData["glass"]["texture"] = cor
    --         end
    --     elseif category == "ear" then
    --         if types == "item" then
    --             if item ~= -1 then
    --                 SetPedPropIndex(ped,2,item,cor,1)
    --             else
    --                 ClearPedProp(ped,2)
    --             end
    
    --             skinData["ear"]["item"] = item
            
    --             SetPedPropIndex(ped,2,skinData["ear"]["item"],cor,1)
    --             skinData["ear"]["texture"] = cor
    --         end
    --     elseif category == "watch" then
    --         if types == "item" then
    --             if item ~= -1 then
    --                 SetPedPropIndex(ped,6,item,cor,1)
    --             else
    --                 ClearPedProp(ped,6)
    --             end
    
    --             skinData["watch"]["item"] = item
            
    --             SetPedPropIndex(ped,6,skinData["watch"]["item"],item,1)
    --             skinData["watch"]["texture"] = cor
    --         end
    --     elseif category == "bracelet" then
    --         if types == "item" then
    --             if item ~= -1 then
    --                 SetPedPropIndex(ped,7,item,cor,1)
    --             else
    --                 ClearPedProp(ped,7)
    --             end
    
    --             skinData["bracelet"]["item"] = item
            
    --             SetPedPropIndex(ped,7,skinData["bracelet"]["item"],item,1)
    --             skinData["bracelet"]["texture"] = cor
    --         end
    --     end

    -- else
    --     print("Essa roupa é para mulher")
    --     return
    -- end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TATTOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("updateTatuagem")
AddEventHandler("updateTatuagem",function(tattos)
    oldTattos = tattos
    atualTattos = tattos
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TatuagemClick
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("TatuagemClick", function(data, cb)
    AplicarTatuagem(data)
	cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AplicarTatuagem
-----------------------------------------------------------------------------------------------------------------------------------------
function AplicarTatuagem(data) 
    local ped = PlayerPedId()
	ClearPedDecorations(PlayerPedId())

    if atualTattos[data.tatto_spawnName].tatto_status == "true" then
        atualTattos[data.tatto_spawnName].tatto_status = "false"
    else
        atualTattos[data.tatto_spawnName].tatto_status = "true"
    end

    for k,v in pairs(atualTattos) do
        if v["tatto_status"] == "true" then
            SetPedDecoration(ped,GetHashKey(v["tatto_part"]),GetHashKey(v["tatto_model"]))
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETCHAR
-----------------------------------------------------------------------------------------------------------------------------------------
custom = currentCharacterMode
function src.setCharacter(data)
	if data then 
		custom = data
        Wait(500)
        LocalPlayer.state.pedCustom = custom
        LocalPlayer.state.pedCustomOld = data
        setBarbershop('default')    
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BarbeariaClick - NUI
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('BarbeariaClick', function(dataR, cb)
    if dataR["item"].barber_category == "cabelo" then
        custom.hairModel = dataR["item"].barber_model
        custom.firstHairColor = dataR["item"].barber_color
    elseif dataR["item"].barber_category == "blush" then
        custom.blushModel = dataR["item"].barber_model
        custom.blushColor = dataR["item"].barber_color
    elseif dataR["item"].barber_category == "maquiagem" then
        custom.makeupModel = dataR["item"].barber_model
        custom.makeupcolor = dataR["item"].barber_color
    elseif dataR["item"].barber_category == "sobrancelha" then
        custom.eyebrowsModel = dataR["item"].barber_model
        custom.eyebrowsColor = dataR["item"].barber_color
    elseif dataR["item"].barber_category == "barba" then
        custom.beardModel = dataR["item"].barber_model
        custom.beardColor = dataR["item"].barber_color
    elseif dataR["item"].barber_category == "batom" then
        custom.lipstickModel = dataR["item"].barber_model
        custom.lipstickColor = dataR["item"].barber_color
    end

    local ped = PlayerPedId()
    local skin = 'mp_m_freemode_01'
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
		skin = "mp_m_freemode_01"
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
		skin = "mp_f_freemode_01"
    end
    
    custom.skin = skin
    LocalPlayer.state.pedCustom = custom
    setBarbershop('default')    

    cb("ok")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNC BODY
-----------------------------------------------------------------------------------------------------------------------------------------
function setBarbershop(type)
    local ped = PlayerPedId()
    
    if type == "cancel" then
        local data = LocalPlayer.state.pedCustomOld

        SetPedHeadBlendData(ped, data.fathersID, data.mothersID, 0, data.skinColor, 0, 0, data.shapeMix and (data.shapeMix + 0.0) or 0.99, 0, 0.0, false)

        SetPedEyeColor(ped, data.eyesColor)
        SetPedFaceFeature(ped, 6, data.eyebrowsHeight)
        SetPedFaceFeature(ped, 7, data.eyebrowsWidth)
        SetPedFaceFeature(ped, 0, data.noseWidth)
        SetPedFaceFeature(ped, 1, data.noseHeight)
        SetPedFaceFeature(ped, 2, data.noseLength)
        SetPedFaceFeature(ped, 3, data.noseBridge)
        SetPedFaceFeature(ped, 4, data.noseTip)
        SetPedFaceFeature(ped, 5, data.noseShift)
        SetPedFaceFeature(ped, 8, data.cheekboneHeight)
        SetPedFaceFeature(ped, 9, data.cheekboneWidth)
        SetPedFaceFeature(ped, 10, data.cheeksWidth)
        SetPedFaceFeature(ped, 12, data.lips)
        SetPedFaceFeature(ped, 13, data.jawWidth)
        SetPedFaceFeature(ped, 14, data.jawHeight)
        SetPedFaceFeature(ped, 15, data.chinLength)
        SetPedFaceFeature(ped, 16, data.chinPosition)
        SetPedFaceFeature(ped, 17, data.chinWidth)
        SetPedFaceFeature(ped, 18, data.chinShape)
        SetPedFaceFeature(ped, 19, data.neckWidth)
    
        SetPedComponentVariation(ped, 2, data.hairModel, 0, 0)
        SetPedHairColor(ped, data.firstHairColor, data.secondHairColor)
    
        -- Overlay: Eyebrows
        SetPedHeadOverlay(ped, 2, data.eyebrowsModel, 0.99)
        SetPedHeadOverlayColor(ped, 2, 1, data.eyebrowsColor, data.eyebrowsColor)
    
        -- Overlay: Beard
        SetPedHeadOverlay(ped, 1, data.beardModel, 0.99)
        SetPedHeadOverlayColor(ped, 1, 1, data.beardColor, data.beardColor)
    
        -- Overlay: Chest hair
        SetPedHeadOverlay(ped, 10, data.chestModel, 0.99)
        SetPedHeadOverlayColor(ped, 10, 1, data.chestColor, data.chestColor)
    
        -- Overlay: Blush
        SetPedHeadOverlay(ped, 5, data.blushModel, 0.99)
        SetPedHeadOverlayColor(ped, 5, 2, data.blushColor, data.blushColor)
    
        -- Overlay: Lipstick
        SetPedHeadOverlay(ped, 8, data.lipstickModel, 0.99)
        SetPedHeadOverlayColor(ped, 8, 2, data.lipstickColor, data.lipstickColor)
    
        -- Overlay: Blemishes
        SetPedHeadOverlay(ped, 0, data.blemishesModel, 0.99)
        SetPedHeadOverlayColor(ped, 0, 0, 0, 0)
    
        -- Overlay: Ageing
        SetPedHeadOverlay(ped, 3, data.ageingModel, 0.99)
        SetPedHeadOverlayColor(ped, 3, 0, 0, 0)
    
        -- Overlay: Complexion
        SetPedHeadOverlay(ped, 6, data.complexionModel, 0.99)
        SetPedHeadOverlayColor(ped, 6, 0, 0, 0)
    
        -- Overlay: Sundamage
        SetPedHeadOverlay(ped, 7, data.sundamageModel, 0.99)
        SetPedHeadOverlayColor(ped, 7, 0, 0, 0)
    
        -- Overlay: Freckles
        SetPedHeadOverlay(ped, 9, data.frecklesModel, 0.99)
        SetPedHeadOverlayColor(ped, 9, 0, 0, 0)
    
        -- Overlay: Makeup
        SetPedHeadOverlay(ped, 4, data.makeupModel, 0.99)
        SetPedHeadOverlayColor(ped, 4, 0, data.makeupcolor, data.makeupcolor)

    else
        local data = LocalPlayer.state.pedCustom
        SetPedHeadBlendData(ped, data.fathersID, data.mothersID, 0, data.skinColor, 0, 0, data.shapeMix and (data.shapeMix + 0.0) or 0.99, 0, 0.0, false)

        SetPedEyeColor(ped, data.eyesColor)
        SetPedFaceFeature(ped, 6, data.eyebrowsHeight)
        SetPedFaceFeature(ped, 7, data.eyebrowsWidth)
        SetPedFaceFeature(ped, 0, data.noseWidth)
        SetPedFaceFeature(ped, 1, data.noseHeight)
        SetPedFaceFeature(ped, 2, data.noseLength)
        SetPedFaceFeature(ped, 3, data.noseBridge)
        SetPedFaceFeature(ped, 4, data.noseTip)
        SetPedFaceFeature(ped, 5, data.noseShift)
        SetPedFaceFeature(ped, 8, data.cheekboneHeight)
        SetPedFaceFeature(ped, 9, data.cheekboneWidth)
        SetPedFaceFeature(ped, 10, data.cheeksWidth)
        SetPedFaceFeature(ped, 12, data.lips)
        SetPedFaceFeature(ped, 13, data.jawWidth)
        SetPedFaceFeature(ped, 14, data.jawHeight)
        SetPedFaceFeature(ped, 15, data.chinLength)
        SetPedFaceFeature(ped, 16, data.chinPosition)
        SetPedFaceFeature(ped, 17, data.chinWidth)
        SetPedFaceFeature(ped, 18, data.chinShape)
        SetPedFaceFeature(ped, 19, data.neckWidth)
    
        SetPedComponentVariation(ped, 2, data.hairModel, 0, 0)
        SetPedHairColor(ped, data.firstHairColor, data.secondHairColor)
    
        -- Overlay: Eyebrows
        SetPedHeadOverlay(ped, 2, data.eyebrowsModel, 0.99)
        SetPedHeadOverlayColor(ped, 2, 1, data.eyebrowsColor, data.eyebrowsColor)
    
        -- Overlay: Beard
        SetPedHeadOverlay(ped, 1, data.beardModel, 0.99)
        SetPedHeadOverlayColor(ped, 1, 1, data.beardColor, data.beardColor)
    
        -- Overlay: Chest hair
        SetPedHeadOverlay(ped, 10, data.chestModel, 0.99)
        SetPedHeadOverlayColor(ped, 10, 1, data.chestColor, data.chestColor)
    
        -- Overlay: Blush
        SetPedHeadOverlay(ped, 5, data.blushModel, 0.99)
        SetPedHeadOverlayColor(ped, 5, 2, data.blushColor, data.blushColor)
    
        -- Overlay: Lipstick
        SetPedHeadOverlay(ped, 8, data.lipstickModel, 0.99)
        SetPedHeadOverlayColor(ped, 8, 2, data.lipstickColor, data.lipstickColor)
    
        -- Overlay: Blemishes
        SetPedHeadOverlay(ped, 0, data.blemishesModel, 0.99)
        SetPedHeadOverlayColor(ped, 0, 0, 0, 0)
    
        -- Overlay: Ageing
        SetPedHeadOverlay(ped, 3, data.ageingModel, 0.99)
        SetPedHeadOverlayColor(ped, 3, 0, 0, 0)
    
        -- Overlay: Complexion
        SetPedHeadOverlay(ped, 6, data.complexionModel, 0.99)
        SetPedHeadOverlayColor(ped, 6, 0, 0, 0)
    
        -- Overlay: Sundamage
        SetPedHeadOverlay(ped, 7, data.sundamageModel, 0.99)
        SetPedHeadOverlayColor(ped, 7, 0, 0, 0)
    
        -- Overlay: Freckles
        SetPedHeadOverlay(ped, 9, data.frecklesModel, 0.99)
        SetPedHeadOverlayColor(ped, 9, 0, 0, 0)
    
        -- Overlay: Makeup
        SetPedHeadOverlay(ped, 4, data.makeupModel, 0.99)
        SetPedHeadOverlayColor(ped, 4, 0, data.makeupcolor, data.makeupcolor)
    end


end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ButtonClick
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('ButtonClick', function(data, cb) 
    if data.type == "salvar" then
        if LocalPlayer.state.clothesNUI then
            controllerApi.sendServerEvent('UpdatePed', { type = "Clothes", custom = skinData })
        end

        if LocalPlayer.state.barbeariaNUI then
            controllerApi.sendServerEvent('UpdatePed', { type = "Barber", custom = json.encode(LocalPlayer.state.pedCustom) })
            LocalPlayer.state.pedCustomOld = LocalPlayer.state.pedCustom
        end

        if LocalPlayer.state.TatuagemNUI then
            controllerApi.sendServerEvent('UpdatePed', { type = "Tattos", custom = atualTattos })
        end
    end

    if data.type == "cancelar" then
        if LocalPlayer.state.clothesNUI then
            setClothing(PlayerPedId(), oldCustom)
        end

        if LocalPlayer.state.barbeariaNUI then
            setBarbershop("cancel")
        end

        if LocalPlayer.state.TatuagemNUI then
            setTattos(PlayerPedId(), oldTattos)
        end
    end

    SetNuiFocus(false, false)
    SendReactMessage('setVisible', false)
    setCameraCoords(false)
    TriggerEvent("duth:ChatStatus", false)
    ClearPedSecondaryTask(PlayerPedId())
    ClearPedTasks(PlayerPedId())
    LocalPlayer.state.clothesNUI = false
    LocalPlayer.state.barbeariaNUI = false
    LocalPlayer.state.TatuagemNUI = false
    cb({})
end)