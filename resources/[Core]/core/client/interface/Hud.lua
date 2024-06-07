----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local LuizDev = moduleEE("client")
local Display = false
local Shortcuts = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- Hud - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function Hud(status) 
    Display = status
    
    if Display then 
        SendReactMessage('showHud', {})
    else 
        SendReactMessage('hideHud', {})
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Hud - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud", function() 
    if not Display then
        Display = true
        Hud(Display)
    else
        Display = false
        Hud(Display)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
local cacheMembers = { value = {}, updatedAt = 0 }

local function updatePedVest(ped, armourAmount)
    if armourAmount > 0 and not isWearingColete then
        local isMale = GetEntityModel(ped) == GetHashKey("mp_m_freemode_01")
        local isFemale = GetEntityModel(ped) == GetHashKey("mp_f_freemode_01")

        if isMale then
            SetPedComponentVariation(ped, 9, 16, 0, 1)
            SetPedComponentVariation(ped, 9, GetPedDrawableVariation(ped, 9), 2, 1)
        elseif isFemale then
            SetPedComponentVariation(ped, 9, 17, 0, 1)
            SetPedComponentVariation(ped, 9, GetPedDrawableVariation(ped, 9), 2, 1)
        end

        isWearingColete = true
    elseif armourAmount == 0 and isWearingColete then
        SetPedComponentVariation(ped, 9, 0, 0, 1)

        isWearingColete = false
    end
end

local function tryUpdateMembersCache()
    local timeNow = GetGameTimer()

    if timeNow - cacheMembers.updatedAt > 1000 then
        cacheMembers.value = {} 

        local groupMembers = getPlayerGroupCards()

        for i, member in ipairs(groupMembers) do
            local memberCache = cacheMembers.value[member.source] or {}
            local healthPercentage, armourPercentage = memberCache.health or 0, memberCache.armor or 0 

            local memberPlayer = GetPlayerFromServerId(member.source)

            if memberPlayer > -1 then 
                local memberPed = GetPlayerPed(memberPlayer)
    
                if DoesEntityExist(memberPed) then
                    healthPercentage = (GetEntityHealth(memberPed) - 100) / (GetPedMaxHealth(memberPed) - 100) * 100
                    armourPercentage = GetPedArmour(memberPed)
                end
            end 
    
            cacheMembers.value[member.source] = {
                color = member.color, 
                name = member.name, 
                armor = armourPercentage, 
                health = healthPercentage, 
                tag = member.tag
            }
        end

        cacheMembers.updatedAt = timeNow
    end
end

local function getMinimapAnchor()
    local defaultAspectRatio = 1920 / 1080 
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapXOffset, minimapYOffset = 0, 0
    
    if aspectRatio > defaultAspectRatio then
        local aspectDifference = defaultAspectRatio - aspectRatio

        minimapXOffset = aspectDifference / 3.6
    end

    SetMinimapComponentPosition("minimap", "L", "B", -0.0045 + minimapXOffset, 0.002 + minimapYOffset, 0.150, 0.188888)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.020 + minimapXOffset, 0.030 + minimapYOffset, 0.111, 0.159)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.03 + minimapXOffset, 0.022 + minimapYOffset, 0.266, 0.237)

    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()

    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y

    local Minimap = {}

    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    Minimap.res_x = res_x
    Minimap.res_y = res_y

    return Minimap
end

local mapAnchor = nil

LuizDev.Thread(function ()
    local delay = 200
    local ped = PlayerPedId()

    if not mapAnchor then 
        mapAnchor = getMinimapAnchor()

        SendReactMessage('updateMapPosition', { top = mapAnchor.y, left = mapAnchor.x })

        SetTimeout(5000, function()
            mapAnchor = nil
        end)
    end 

    if Display then
        tryUpdateMembersCache()

        local weaponHash = GetSelectedPedWeapon(ped)
        local unarmedHash = GetHashKey('WEAPON_UNARMED') 

        if weapon ~= unarmedHash and not LocalPlayer.state.inSpec then
            local _, weaponAmmoInClip = GetAmmoInClip(ped, weaponHash)
            local weaponAmmo = GetAmmoInPedWeapon(ped, weaponHash) - weaponAmmoInClip

            for k, v in pairs(Config.weapon_types) do
                local isWeaponEquipped = weaponHash == GetHashKey(v) 

                if isWeaponEquipped then
                    local weaponName = itemName(v) 

                    SendReactMessage('showWeaponHud', {
                        weaponIndex = indexByHash(weaponHash),
                        weaponName = weaponName,
                        ammoEquipped = weaponAmmoInClip, 
                        ammoInClip = weaponAmmo
                    })
                end 
            end
        else
            SendReactMessage('hideWeaponHud', {})
        end

        local membersFormatted = {} 
    
        for _, member in pairs(cacheMembers.value) do
            table.insert(membersFormatted, member)
        end

        if #membersFormatted > 1 then 
            SendReactMessage('showMembers', { members = membersFormatted })
        else 
            SendReactMessage('hideMembers', {})
        end 

        if LocalPlayer.state.inSpec then 
            SendReactMessage('hideInventoryItems', {})
            SendReactMessage('hideGameStatus', {})
        else 
            local maxHealthAmount = GetPedMaxHealth(ped) - 100
            local healthAmount = GetEntityHealth(ped) - 100
            
            local healthAmount = math.floor(healthAmount / maxHealthAmount * 100)
            local armourAmount = GetPedArmour(ped)
            
            SendReactMessage('showLifeStatus', {
                health = healthAmount,
                shield = armourAmount,
            })

            SendReactMessage('showInventoryItems', Shortcuts)
    
            updatePedVest(ped, armourAmount)
        end 
    end

    return delay
end, 500)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Radar - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	DisplayRadar(false)

	RequestStreamedTextureDict("circlemap",false)
    
	while not HasStreamedTextureDictLoaded("circlemap") do
		Citizen.Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics","radarmasksm","circlemap","radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition("minimap","L","B",0.009,-0.0125,0.16,0.28)
	SetMinimapComponentPosition("minimap_mask","L","B",0.155,0.12,0.080,0.15)
	SetMinimapComponentPosition("minimap_blur","L","B",0.0095,0.015,0.229,0.311)

    local minimap = RequestScaleformMovie("minimap")

    SetRadarBigmapEnabled(true, false)

    Wait(5)

    SetRadarBigmapEnabled(false, false)

    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UpdateShortcuts - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.UpdateShortcuts(Items) 
    Shortcuts = Items
end