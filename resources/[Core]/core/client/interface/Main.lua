----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local itens = {}
local ProfileCard = false
local itemsInfos = {
	["Safezone"] = {
		type = "Safezone",
		id = 3,
		icon = 'fa-solid fa-cloud',
		status = false,
		text = nil
	},

	["Plane"] = {
		type = "Plane",
		id = 4,
		icon = 'fa-solid fa-plane',
		status = false,
		text = nil
	},

	["Players"] = {
		type = "Players",
		id = 2,
		icon = 'fa-solid fa-users',
		status = true,
		text = nil
	},

	["Kills"] = {
		type = "Kills",
		id = 1,
		icon = 'fa-solid fa-crosshairs',
		status = true,
		text = 0,
	},
}

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
-- ResetHud - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function ResetHud()
	itemsInfos["Safezone"].status = false
	itemsInfos["Safezone"].text = nil
	itemsInfos["Plane"].text = nil
	itemsInfos["Plane"].status = false
	itemsInfos["Players"].status = true
	itemsInfos["Players"].text = nil
	itemsInfos["Kills"].status = true
	itemsInfos["Kills"].text = nil

	SendReactMessage('BuildHud', { type = "DisplayWeapon", status = false })
	SendReactMessage('BuildHud', { type = "ItemDrop", status = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildGame - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('BuildGame')
AddEventHandler('BuildGame', function(data)
	if data.updatePlayers then
		itemsInfos["Players"].text = data.players
	end

	if data.safe then
		itemsInfos["Safezone"].text = data.safeTime
		itemsInfos["Safezone"].status = data.safe
	end


	if data.updateKills then
		itemsInfos["Kills"].text = data.kills
	end


    SendReactMessage('BuildHud', {
        type = "ItensInfos",
        status = data.status,
		items = LuizDev.reMapData(itemsInfos)
    })
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
RegisterNetEvent("NotifyKill")
AddEventHandler("NotifyKill",function(dataNotify)
	local weaponImage = 'skull'
	if dataNotify.weapon_killer then
		if weaponList[dataNotify.weapon_killer] ~= nil then
			weaponImage = weaponList[dataNotify.weapon_killer]
		end
	end

    SendReactMessage('NotifyKill', {
        action = "NotifyKill",
        notifyBody = {
            open = true,
            weapon = weaponImage,
            headshot = dataNotify.headshot and dataNotify.headshot or false, 
            agonizing = dataNotify.agonizing,
            timer = 1000
        },
        notify = {
            killer = { 
                name = dataNotify.killer_name,
                user_id = dataNotify.killer,
            }, 
            victim = { 
                name = dataNotify.victim_name,
                user_id = dataNotify.victim,
            }, 
        }
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
	SendReactMessage('BuildHud', {
		type = "Announcement",
		status = data.status,
		text = data.text,
		timer = data.timer
	})
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
-----------------------------------------------------------------------------------------------------------------------------------------
-- SendNUI - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SendNUI(data) 
	if LocalPlayer.state.inLobbyPrincipal and data.dashboard then
		LocalPlayer.state.inDashboard = true
        DeleteEnitys()

        cam.CreateCamLobby1("CAM_LOBBY1")
        cam.CreateCamLobby("CAM_LOBBY2")
		clientApiEvents.BuildPeds({}, false)
        clientApiEvents.BuildGroup({}, false)
        toggleNuiFrame(true, data.page)
        
        SendReactMessage('buildLogoMidle', false)
        AddKeyHelp({ status = false })
		return
	end
	
    SetNuiFocus(data.status, data.status)
    SendReactMessage('setVisible', data.status)
    SendNUIMessage({
        action = "dashBoard",
        data = {
            open = data.status,
            page = data.page
        },
    })
end