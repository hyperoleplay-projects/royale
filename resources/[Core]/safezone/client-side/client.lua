local Tunnel = module("vrp","lib/Tunnel")

SafeZone = {}
Tunnel.bindInterface("safezone", SafeZone)
vSERVER = Tunnel.getInterface("safezone")
vSERVERBattle = Tunnel.getInterface("core")

local Blips = {}
local GameId = 0
local LuizDev = moduleEE("client")
local multiDano = 0
local morto = false
local killRegistrada = false
local safeZoneThread = nil
local safeZoneThread2 = nil
local ped = GetPlayerPed(-1)

function BR:ResetGame()
	BR.Zone[LocalPlayer.state.gameId] = false
	BR.ZoneRadius[LocalPlayer.state.gameId] = false
	BR.ZoneTime[LocalPlayer.state.gameId] = false
	BR.FormerZone[LocalPlayer.state.gameId] = false
	BR.FormerZoneRadius[LocalPlayer.state.gameId] = false
	BR.ZoneTimer[LocalPlayer.state.gameId] = false
end

RegisterNetEvent("SafeZone:StartEvent")
AddEventHandler("SafeZone:StartEvent", function(eventID, tabela)
	if eventID == 3 then
		BR:ResetGame()

		tabela.safeZone = vector3(tabela.safeZone.x, tabela.safeZone.y, tabela.safeZone.z)

		BR:CreateZone(tabela.safeZone, tabela.radius)
	elseif eventID == 5 then
		-- create next zone
		tabela.Zone = vector3(tabela.Zone.x, tabela.Zone.y, tabela.Zone.z)

		BR:CreateZone(tabela.Zone, tabela.ZoneRadius)
	elseif eventID == 6 then
		-- start zone timer
		
		PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		
		multiDano = multiDano + 1

		BR:StartZoneTimer(tabela)
	end
end)

RegisterCommand("safe", function()
	local zonePos = vector3(-693.54, -113.53, 800.0) 
	local blip = AddBlipForRadius(zonePos, 2400.0)

	SetBlipSprite(blip, 10)
	SetBlipDisplay(blip, 8)
	SetBlipColour(blip, 75)
end)

function BR:CreateZone(zonePos, zoneRadius)
	RemoveBlip(Blips["zone"])

	if BR.ZoneRadius[LocalPlayer.state.gameId] or BR.Zone[LocalPlayer.state.gameId] then
		BR.FormerZoneRadius[LocalPlayer.state.gameId] = BR.ZoneRadius[LocalPlayer.state.gameId] or zoneRadius
		BR.FormerZone[LocalPlayer.state.gameId] = BR.Zone[LocalPlayer.state.gameId]
	end

	if not Blips["safezone"] then
		local blip = AddBlipForRadius(zonePos, BR.FormerZoneRadius[LocalPlayer.state.gameId] or zoneRadius)

		SetBlipSprite(blip, 10)
		SetBlipDisplay(blip, 8)
		SetBlipColour(blip, 75)
		SetBlipAlpha(blip, 75)

		Blips["safezone"] = blip
	end

	local blip2 = AddBlipForRadius(zonePos, zoneRadius)

	SetBlipSprite(blip2, 10)
	SetBlipDisplay(blip2, 8)

	BR.ZoneTime[LocalPlayer.state.gameId] = false
	BR.ZoneTimer[LocalPlayer.state.gameId] = false

	BR.Zone[LocalPlayer.state.gameId] = zonePos
	BR.ZoneRadius[LocalPlayer.state.gameId] = zoneRadius

	Blips["zone"] = blip2

	return zonePos
end

function BR:StartZoneTimer(zoneTime)
	BR.ZoneTimer[LocalPlayer.state.gameId] = zoneTime
	BR.ZoneTime[LocalPlayer.state.gameId] = GetGameTimer() + BR.ZoneTimer[LocalPlayer.state.gameId] * 1000

	local remainingPercent = math.max(0, BR.ZoneTime[LocalPlayer.state.gameId] - GetGameTimer()) / (BR.ZoneTimer[LocalPlayer.state.gameId] * 1000)
	TriggerEvent("BuildGame", { safe = true, safeRemaining = remainingPercent, safeTime = math.floor(remainingPercent * BR.ZoneTimer[LocalPlayer.state.gameId]), players = 0, updatePlayers = false })
end

function BR:GameTick(ped)
	if not safeZoneThread then
		safeZoneThread = true
		
		Citizen.CreateThread(function()
			while true do
				if LocalPlayer.state.inGame then
					local zoneRadius, remaining = BR.FormerZoneRadius[LocalPlayer.state.gameId]
					
					if BR.ZoneTime[LocalPlayer.state.gameId] and BR.ZoneTime[LocalPlayer.state.gameId] ~= 0 and BR.Zone[LocalPlayer.state.gameId] then
						remaining = math.max(0, BR.ZoneTime[LocalPlayer.state.gameId] - GetGameTimer()) / (BR.ZoneTimer[LocalPlayer.state.gameId] * 1000)
						zoneRadius = math.max(BR.ZoneRadius[LocalPlayer.state.gameId], BR.ZoneRadius[LocalPlayer.state.gameId] + (BR.FormerZoneRadius[LocalPlayer.state.gameId] - BR.ZoneRadius[LocalPlayer.state.gameId]) * remaining)
						
						if remaining > 0 and not LocalPlayer.state.finishGameUI then
							TriggerEvent("BuildGame", { status = true, safe = true, kills = LocalPlayer.state.kills, updateKills = false, safeRemaining = remaining, safeTime = math.floor(remaining * BR.ZoneTimer[LocalPlayer.state.gameId]), players = 0, updatePlayers = false })
						end
		
						if Blips["safezone"] and DoesBlipExist(Blips["safezone"]) then
							SetBlipScale(Blips["safezone"], zoneRadius)
				
							if GetDistanceBetweenCoords(GetBlipCoords(Blips["safezone"]), GetBlipCoords(Blips["zone"])) > 0 then
								local diff = VecLerp(BR.FormerZone[LocalPlayer.state.gameId], GetBlipCoords(Blips["zone"]), 1.0 )
								
								SetBlipCoords(Blips["safezone"], BR.FormerZone[LocalPlayer.state.gameId] + (diff - BR.FormerZone[LocalPlayer.state.gameId]) * ((BR.FormerZoneRadius[LocalPlayer.state.gameId] - zoneRadius) / BR.ZoneRadius[LocalPlayer.state.gameId]))
							end
						end
					end
				
					if zoneRadius then
						DrawMarker(28, GetBlipCoords(Blips["safezone"]), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, zoneRadius, zoneRadius, 1000.0, 255, 0, 0, 155, 0, 0, 0, 0, 0, 0, 0)
					end
				end

				Wait(0)
			end
		end)
	end
end

function BR:GameTimer(ped)
    if LocalPlayer.state.inGame then
        local plyPos = GetEntityCoords(ped)
        local zoneRadius = BR.FormerZoneRadius[LocalPlayer.state.gameId]
       
		if BR.ZoneTime[LocalPlayer.state.gameId] and BR.ZoneTime[LocalPlayer.state.gameId] ~= 0 and BR.Zone[LocalPlayer.state.gameId] then
            local remaining = math.max(0, BR.ZoneTime[LocalPlayer.state.gameId] - GetGameTimer()) / (BR.ZoneTimer[LocalPlayer.state.gameId] * 1000)
            
			zoneRadius = math.max(BR.ZoneRadius[LocalPlayer.state.gameId], BR.ZoneRadius[LocalPlayer.state.gameId] + (BR.FormerZoneRadius[LocalPlayer.state.gameId] - BR.ZoneRadius[LocalPlayer.state.gameId]) * remaining)
        end

		local coords = GetEntityCoords(GetPlayerPed(PlayerId()))
		local safe = GetBlipCoords(Blips["safezone"])
		local distance = #(coords - vector3(safe.x, safe.y,coords.z))
    
        -- local playerPos = GetEntityCoords(GetPlayerPed(PlayerId()))
        -- local distance = math.abs(GetDistanceBetweenCoords(playerPos.x, playerPos.y, 0, safe.x, safe.y, 0, false))

        if zoneRadius and distance > zoneRadius and not LocalPlayer.state.death then
            local peddd = GetPlayerPed(-1)
            local vida = GetEntityHealth(peddd)

            -- SetEntityHealth(peddd, vida - 1)
			ApplyDamageToPed(peddd,2)
        else
            morto = false
        end
	end
end

Citizen.CreateThread(function()
	while true do
		ped = GetPlayerPed(-1)

		Citizen.Wait(5000)
	end
end)

RegisterNetEvent('battle-IniciarSafe')
AddEventHandler('battle-IniciarSafe', function(status)
	BR.StartTime[LocalPlayer.state.gameId] = GetGameTimer()

	LocalPlayer.state.inGame = true

	BR:GameTick(ped)
	
	if not safeZoneThread2 then
		safeZoneThread2 = true

		Citizen.CreateThread(function()
			while true do
				BR:GameTimer(ped)

				Citizen.Wait(250)
			end
		end)
	end
end)

function SafeZone.StopSafezone() 
	RemoveBlip(Blips["zone"])
	RemoveBlip(Blips["safezone"])
	
	morto = false
	multiDano = 0
	killRegistrada = false
	Blips = {}
end