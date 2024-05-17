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
LuizDev.Thread(function ()
    local delay = 200
    local ped = PlayerPedId()
    
    if Display and not LocalPlayer.state.inSpec then
        local maxHealthAmount = GetPedMaxHealth(ped) - 100
        local healthAmount = GetEntityHealth(ped) - 100

        local healthAmount = math.floor(healthAmount / maxHealthAmount * 100)
        local armourAmount = GetPedArmour(ped)

        SendReactMessage('showLifeStatus', {
            health = healthAmount,
            shield = armourAmount,
        })

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
        
        local weaponHash = GetSelectedPedWeapon(ped)
        local unarmedHash = GetHashKey('WEAPON_UNARMED') 

        if weapon ~= unarmedHash then
            local _, weaponAmmoInClip = GetAmmoInClip(ped, weaponHash)
            local weaponAmmo = GetAmmoInPedWeapon(ped, weaponHash) - weaponAmmoInClip

            for k, v in pairs(Config.weapon_types) do
                local isWeaponEquipped = weaponHash == GetHashKey(v) 

                if isWeaponEquipped then
                    local weaponName = itemName(v) 

                    SendReactMessage('showWeaponHud', {
                        weaponIndex = weaponName,
                        weaponName = weaponName,
                        ammoEquipped = weaponAmmoInClip, 
                        ammoInClip = weaponAmmo
                    })
                end 
            end
        else
            SendReactMessage('hideWeaponHud', {})
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