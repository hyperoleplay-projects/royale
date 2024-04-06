----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local LuizDev = moduleEE("client")
local morto = false
local deadPlayer = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- Morrer - Thread
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local timeDistance = 500
        local ped = PlayerPedId()
        if GetEntityHealth(ped) <= 101 then
            timeDistance = 4

            if not LocalPlayer.state.death then
                serverAPI.RegisterKillSafe({ gameId = LocalPlayer.state.gameId, nsource = 0, hs = false }) -- Registro de morte por bug
                LocalPlayer.state.death = true
            end

            if not deadPlayer then
                local x,y,z = table.unpack(GetEntityCoords(ped))
                NetworkResurrectLocalPlayer(x,y,z,true,true,false)
                deadPlayer = true
                vRP.updateHealth(101)

                SetPedCanRagdoll(ped,true)
                SetPedToRagdoll(ped,2000,2000,0,0,0,0)
                SetEntityHealth(ped,101)
                SetEntityInvincible(ped,true)

                if IsPedInAnyVehicle(ped) then
                    local Vehicle = GetVehiclePedIsUsing(ped)
                    if GetPedInVehicleSeat(Vehicle,-1) == ped then
                        SetVehicleEngineOn(Vehicle,false,true,true)
                    end
                    ClearPedTasks(PlayerPedId())
                    TaskLeaveVehicle(ped,GetVehiclePedIsUsing(ped),4160)
                end
            else
                SetEntityHealth(ped,101)
                SetPedToRagdoll(ped,2000,2000,0,0,0,0)
            end
        end
    
        Citizen.Wait(timeDistance)
    end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- favela-core:killPlayer
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('favela-core:killPlayer')
AddEventHandler('favela-core:killPlayer', function()
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
    NetworkResurrectLocalPlayer(x,y,z,true,true,false)
	SetEntityHealth(PlayerPedId(), 400)
	SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    SetEntityNoCollisionEntity(PlayerPedId(),true,true)
    ClearPedTasks(PlayerPedId())
    ClearPedBloodDamage(PlayerPedId())

    LocalPlayer.state:set("death",false,false)
    morto = false
    deadPlayer = false
end)

