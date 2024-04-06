local noclip = false

local canNoclip = true

RegisterNetEvent("vRP:updateNoclip")
AddEventHandler("vRP:updateNoclip",function()
	canNoclip = not canNoclip
end)

function tvRP.toggleNoclip()
	if canNoclip then
		noclip = not noclip
		local ped = PlayerPedId()
		if noclip then
			SetEntityVisible(ped,false,false)
		else
			SetEntityVisible(ped,true,false)
		end
	end
end

Citizen.CreateThread(function()
	while true do
		local idle = 500
		if noclip then
			idle = 4
			local ped = PlayerPedId()
			local player = PlayerId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local dx,dy,dz = tvRP.getCamDirection()
			local speed = 1.0

			DisablePlayerFiring(player,true)
			SetEntityVelocity(ped,0.0001,0.0001,0.0001)

			if IsControlPressed(0,21) then
                speed = 5.0
            end

            if IsControlPressed(0,22) then
                speed = 30.0
            end
            
            if IsControlPressed(0,19) then
                speed = 100.0
            end

            if IsControlPressed(0,210) then
                speed = 0.2
            end
            

            if IsControlPressed(1,32) then
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end

            if IsControlPressed(1,269) then
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end

            if IsControlPressed(1,10) then
                z = z + 1
            end

            if IsControlPressed(1,11) then
                z = z - 1
            end

			SetEntityCoordsNoOffset(ped,x,y,z,true,true,true)
		end
		Citizen.Wait(idle)
	end
end)