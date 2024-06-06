----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local itens = {}
local ProfileCard = false
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
	if data.updateKills or data.updatePlayers then
		local informations = {}

		if data.players ~= cacheHud.players then 
			cacheHud.players = data.players

			informations.alives = cacheHud.players
		end

		if data.kills ~= cacheHud.kills then
			cacheHud.kills = data.kills

			informations.killed = cacheHud.kills
		end

		if not LocalPlayer.state.inSpec and informations.alives or informations.killed then 
			SendReactMessage('showGameStatus', informations)
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
	local weaponHash, victimId, victimName, victimGuildTag, killerId, killerName, killerGuildTag = table.unpack(dataEntries)
	local weaponImage = indexByHash(weaponHash)

	SendReactMessage('showKillfeed', {
		killerName = killerName or victimName, 
		victimName = victimName or 'Indefinido', 
		victimTag = victimGuildTag,
		killerTag = killerGuildTag or victimGuildTag,
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
