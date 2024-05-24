----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local itens = {}
local ProfileCard = false

local weaponList = {
	[GetHashKey("WEAPON_ASSAULTSMG")] = "assaultsmg",
	[GetHashKey("WEAPON_HEAVYSNIPER_MK2")] = "heavysnipermk2",
	[GetHashKey("WEAPON_PUMPSHOTGUN_MK2")] = "pumpshotgunmk2",
	[GetHashKey("WEAPON_MG")] = "mg",
	[GetHashKey("WEAPON_MARKSMANRIFLE_MK2")] = "marksmanrifle",
	[GetHashKey("WEAPON_SAWNOFFSHOTGUN")] = "sawnoffshotgun",
	[GetHashKey("WEAPON_COMBATMG_MK2")] = "combatmgmk2",
	[GetHashKey("WEAPON_MICROSMG")] = "microsmg",
	[GetHashKey("WEAPON_HEAVYSNIPER")] = "heavysniper",
	[GetHashKey("WEAPON_PUMPSHOTGUN")] = "pumpshotgun",
	[GetHashKey("WEAPON_COMBATMG")] = "combatmg",
	[GetHashKey("WEAPON_DOUBLEACTION")] = "doubleaction",
	[GetHashKey("WEAPON_APPISTOL")] = "appistol",
	[GetHashKey("WEAPON_SNSPISTOL_MK2")] = "snspistolmk2",
	[GetHashKey("WEAPON_MINIGUN")] = "minigun",

	[GetHashKey("WEAPON_UNARMED")] = "soco",
	[GetHashKey("WEAPON_KNUCKLE")] = "soco2",
	[GetHashKey("WEAPON_BOTTLE")] = "garrafa",
	[GetHashKey("WEAPON_POOLCUE")] = "taco",
	[GetHashKey("WEAPON_BAT")] = "taco2",
	[GetHashKey("WEAPON_STONE_HATCHET")] = "machado",
	[GetHashKey("WEAPON_PISTOL_MK2")] = "fiveseven",
	[GetHashKey("WEAPON_REVOLVER_MK2")] = "revolver",
	[GetHashKey("WEAPON_CROWBAR")] = "pecabra",
	
	[GetHashKey("WEAPON_COMBATPISTOL")] = "glock",
	[GetHashKey("WEAPON_SNSPISTOL")] = "snspistol",
	[GetHashKey("WEAPON_HEAVYPISTOL")] = "heavypistol",
	[GetHashKey("WEAPON_SWITCHBLADE")] = "switchblade",
	[GetHashKey("WEAPON_KNIFE")] = "knife",
	[GetHashKey("WEAPON_MACHETE")] = "machete",
	[GetHashKey("WEAPON_DAGGER")] = "dagger",

	[GetHashKey("WEAPON_COMBATPDW")] = "combatpdw",
	[GetHashKey("WEAPON_MACHINEPISTOL")] = "machinepistol",
	[GetHashKey("WEAPON_SMG_MK2")] = "smgmk2",

	[GetHashKey("WEAPON_ADVANCEDRIFLE")] = "carbineriflemk2",
	[GetHashKey("WEAPON_CARBINERIFLE")] = "carbineriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLE")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLE_MK2")] = "assaultriflemk2",
	-- Skins
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN1")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN2")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN3")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN4")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN5")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN6")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN7")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN8")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN9")] = "assaultriflemk2",
	[GetHashKey("WEAPON_ASSAULTRIFLESKIN10")] = "assaultriflemk2",
	[GetHashKey("WEAPON_CARBINERIFLE_MK2")] = "carbineriflemk2",

	[GetHashKey("WEAPON_SPECIALCARBINE")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN1")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN2")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN3")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN4")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN5")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN6")] = "sigsauer556",
	[GetHashKey("WEAPON_SPECIALCARBINESKIN7")] = "sigsauer556",
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildGame - Event
-----------------------------------------------------------------------------------------------------------------------------------------
local cacheHud = {}

function ResetHud()
	cacheHud = {}

	SendReactMessage('hideGameStatus', {})

	SendReactMessage('updateCloud', {
		timeInSeconds = 0, 
		safeProgress = 0
	})
end

RegisterNetEvent('BuildGame', function(data)
	local hasGameStatus = tonumber(data.players) and tonumber(data.kills)

	if hasGameStatus then 
		local newPlayers = data.players or 0
		local newKills = data.kills or 0

		if newPlayers ~= cacheHud.players or newKills ~= cacheHud.kills then 
			cacheHud.players = newPlayers
			cacheHud.kills = newKills

			if not LocalPlayer.state.inSpec then 
				SendReactMessage('showGameStatus', {
					alives = cacheHud.players,
					killed = cacheHud.kills
				})
			end 
		end
	end 

	local hasSafe = data.safeRemaining and data.safeTime
	
	if hasSafe then 
		local newSafeRemaining = math.floor(data.safeRemaining * 100) or 0
		local newSafeTime = data.safeTime or 0

		if newSafeRemaining ~= cacheHud.safeRemaining or newSafeTime ~= cacheHud.safeTime then 
			cacheHud.safeRemaining = newSafeRemaining
			cacheHud.safeTime = newSafeTime

			SendReactMessage('updateCloud', {
				timeInSeconds = data.safeTime,
				safeProgress = cacheHud.safeRemaining,
			})
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Notify - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Notify")
AddEventHandler("Notify",function(css,mensagem,timer)
	if not timer or timer == "" then
		timer = 3000
	end

    SendNUIMessage({
        action = "Notify",
        data = {
            open = true,
            type = css,
            text = mensagem,
            timer =timer
        },
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- Request - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Request")
AddEventHandler("Request",function(mensagem,timer)
	if not timer or timer == "" then
		timer = 8000
	end

    SendNUIMessage({
        action = "Request",
        data = {
            open = true,
            text = mensagem,
            timer = timer
        },
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NotifyItem - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("NotifyItem")
AddEventHandler("NotifyItem",function(mensagem,image,timer)
	if not timer or timer == "" then
		timer = 3500
	end

    SendNUIMessage({
        action = "NotifyItem",
        data = {
            open = true,
            text = mensagem,
            image = image,
            timer = timer
        },
    })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddKeyHelp - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function AddKeyHelp(data) 
    if data.status then
        itens[data.key] = {
			id = data.id,
            key = data.key,
            text = data.text
        }
    
        SendReactMessage('BuildKeysHelp', {
            status = data.status,
            type = data.type,
            itens = LuizDev.reMapData(itens)
        })
    else
        SendReactMessage('BuildKeysHelp', {
            status = data.status,
            itens = {}
        })
        itens = {}
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NotifyKill - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('NotifyKill')
AddEventHandler('NotifyKill', function(dataEntries)
	local weaponImage = 'skull'
	local weaponIndex, victimId, victimName, victimGuildTag, killerId, killerName, killerGuildTag = table.unpack(dataEntries)

	if weaponIndex and weaponList[weaponIndex] then
		weaponImage = weaponList[weaponIndex]
	end

	SendReactMessage('showKillfeed', {
		killerName = killerName or 'Indefinido', 
		victimName = victimName or 'Indefinido', 
		victimTag = victimGuildTag,
		killerTag = killerGuildTag,
		weapon = weaponImage
	})
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildProfileCard - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.BuildProfileCard(data) 
	SendReactMessage('BuildHud', {
		type = "ProfileCard",
		status = true,
	})
	
	SendReactMessage('Profile-Card', data)
	
	SetTimeout(3000, function() 
		SendReactMessage('BuildHud', {
			type = "ProfileCard",
			status = false,
		})
	end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddAnnouncement - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function AddAnnouncement(data) 
	if data.status then 
		SendReactMessage('showAnnounceMessage', {
			text = data.text,
		})

		if data.timer then 
			data.time = data.time or 8000 
	
			SetTimeout(data.time, function() 
				AddAnnouncement({ status = false }) 
			end)
		end 
	else
		SendReactMessage('hideAnnounceMessage', {})
	end 
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- AddKeyboardInfo - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function AddKeyboardInfo(data) 
	SendReactMessage('BuildHud', {
		type = "Keyboard",
		status = data.status,
		key = data.key,
		text = data.text,
	})
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NotifyAnnouncement - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("NotifyAnnouncement")
AddEventHandler("NotifyAnnouncement", function(data) 
	AddAnnouncement(data)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- NotifyKeyboardInfo - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("NotifyKeyboardInfo")
AddEventHandler("NotifyKeyboardInfo", function(data) 
	AddKeyboardInfo(data)
end)
