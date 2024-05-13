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
    
    SendReactMessage('BuildHud', {
        type = "DisplayStatusPlayerStats",
        status = status
    })
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
    
    if Display then
        if not LocalPlayer.state.inSpec then
            local vida = (GetEntityHealth(ped) - 100 ) / 3
            -- local vida = (100*GetEntityHealth(ped)/GetEntityMaxHealth(ped))
            local armour = GetPedArmour(ped)

            SendReactMessage('BuildHud', {
                type = "StatusPlayerStats",
                armour = armour,
                health = vida,
                shorts = Shortcuts
            })

            if armour > 0 and not isWearingColete then
                if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
                    SetPedComponentVariation(ped, 9, 16, 0, 1)
                    SetPedComponentVariation(ped, 9, GetPedDrawableVariation(ped, 9), 2, 1)
                elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then
                    SetPedComponentVariation(ped, 9, 17, 0, 1)
                    SetPedComponentVariation(ped, 9, GetPedDrawableVariation(ped, 9), 2, 1)
                end
                isWearingColete = true
            elseif armour == 0 and isWearingColete then
                SetPedComponentVariation(ped, 9, 0, 0, 1)
                isWearingColete = false
            end
            
            local weapon = GetSelectedPedWeapon(ped)
    
            if weapon ~= -1569615261 then
                local _, weaponammoinclip = GetAmmoInClip(ped, weapon)
                local weaponammo = GetAmmoInPedWeapon(ped, weapon) - weaponammoinclip
                SendReactMessage('BuildHud', {
                    type = "DisplayWeapon",
                    status = true,
                })
                
                for k, v in pairs(Config.weapon_types) do
                  if weapon == GetHashKey(v) then

                    SendReactMessage('BuildHud', {
                        type = "WeaponHud",
                        ModelName = itemName(v),
                        WeaponAmmo = weaponammo,
                        WeaponAmmoClip = weaponammoinclip
                    })
                  end 
                end
            else
                SendReactMessage('BuildHud', {
                    type = "DisplayWeapon",
                    status = false,
                })
            end

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