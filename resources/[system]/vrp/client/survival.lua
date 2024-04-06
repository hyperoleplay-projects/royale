local agachar = false
local movimento = false
local segundos = 0
local ctrl = 0

function tvRP.varyHealth(variation)
	local ped = PlayerPedId()
	local n = math.floor(GetEntityHealth(ped)+variation)
	SetEntityHealth(ped,n)
end

function tvRP.getHealth()
	return GetEntityHealth(PlayerPedId())
end

function tvRP.setHealth(health)
	SetEntityHealth(PlayerPedId(),parseInt(health))
end

function tvRP.setFriendlyFire(flag)
	NetworkSetFriendlyFireOption(flag)
	SetCanAttackFriendly(PlayerPedId(),flag,flag)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPGRADEHEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.UpgradeHealth(Number)
	local Ped = PlayerPedId()
	local Health = GetEntityHealth(Ped)
	if Health > 100 then
		SetEntityHealth(Ped,Health + Number)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AGACHAR - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do 
		local timeDistance = 500
        local ped = PlayerPedId()
		if DoesEntityExist(ped) and not IsEntityDead(ped) then 
			timeDistance = 4
            if not IsPauseMenuActive() then 
                if IsPedJumping(ped) then
                    movimento = false
                end
            end
        end
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
			timeDistance = 4 
            DisableControlAction(0,36,true)
            if not IsPauseMenuActive() then 
				timeDistance = 4
				if IsDisabledControlJustPressed(0,36) and not IsPedInAnyVehicle(ped) and ctrl == 0 then
					timeDistance = 4
					ctrl = 1
                    RequestAnimSet("move_ped_crouched")
                    RequestAnimSet("move_ped_crouched_strafing")
                    if agachar == true then 
                        ResetPedMovementClipset(ped,0.30)
                        ResetPedStrafeClipset(ped)
                        movimento = false
                        agachar = false 
                    elseif agachar == false then
                        SetPedMovementClipset(ped,"move_ped_crouched",0.30)
                        SetPedStrafeClipset(ped,"move_ped_crouched_strafing")
                        agachar = true 
                    end 
                end
            end 
		end 
		if agachar == true then 
			timeDistance = 4
			DisablePlayerFiring(PlayerId(),true)
			if IsPedArmed(ped, 7) and not IsPedInAnyVehicle(ped) and not IsPedJumping(ped) and not IsPedFalling(ped) and not IsPedSwimming(ped) and IsControlJustPressed(0,25) then
				ctrl = 1
				ResetPedMovementClipset(ped,0.30)
				ResetPedStrafeClipset(ped)
				movimento = false
				agachar = false 
			end
		end

		Citizen.Wait(timeDistance)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- ResetCrouch - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function ResetCrouch() 
	local ped = PlayerPedId()
	if agachar then
		movimento = false
		agachar = false 
		ResetPedMovementClipset(ped,0.30)
		ResetPedStrafeClipset(ped)
	end
end
exports("ResetCrouch",ResetCrouch)


-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if segundos > 0 then
			segundos = segundos - 1
		end
		if ctrl > 0 then
			ctrl = ctrl - 1
		end
	end
end)