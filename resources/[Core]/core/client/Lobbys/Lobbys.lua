
-- ----------------------------------------------------------------------------------------------------------------------------------------
-- -- VARIBLES
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- local NuiOpenDashboard = false
-- local LobbyTheard1 = nil
-- local StartGame = false
-- local cooldown = 0

-- local idleGame = 1000
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(1000)
--         if LocalPlayer.state.inGameLobby then
--             if cooldown > 0 then
--                 cooldown = cooldown - 1
--             end
--         end
--     end
-- end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if LocalPlayer.state.inGameLobby then
--             if cooldown then
--                 if cooldown == 0 then
--                     vRP.playSound("Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
--                     local time = 100
--                     while time > 0 do
--                         LocalPlayer.state.inGameLobby = false
--                         time = time-1
--                     end
--                     cooldown = -1
--                 end
--             end
--         end
--     end
-- end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- JoinLobbyGame - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function src.JoinLobbyGame() 
--     local ped = PlayerPedId()
--     DoScreenFadeOut(1000)
--     cooldown = Config.StartTime
--     LocalPlayer.state.inDashboard = false
--     -- Fechar o lobby
--     cam.delete("CAM_LOBBY1")
--     cam.delete("CAM_LOBBY2")
--     toggleNuiFrame(false)
--     SetNuiFocus(false,false)

--     NetworkSetTalkerProximity(0.0)
--     NetworkClearVoiceChannel()
--     NetworkSetVoiceActive(false)
--     noDamage()
--     clientApiEvents.BuildPeds({}, false)
--     clientApiEvents.BuildGroup({}, false)
--     SendReactMessage('buildStatsStatus', true)
--     SendReactMessage('buildLogoMidle', true)
--     AddKeyHelp({ status = false })


--     exports["vrp"]:ResetCrouch()
--     FreezeEntityPosition(PlayerPedId(), true)
--     Wait(600)
--     local randomSpawn = math.random(#Config.LobbyGame)
--     SetEntityCoordsNoOffset(ped, Config.LobbyGame[randomSpawn].x, Config.LobbyGame[randomSpawn].y, Config.LobbyGame[randomSpawn].z+1)
--     LocalPlayer.state.inGameLobby = true
--     TriggerEvent("duth:ChatStatus", true)

--     DisplayRadar(false)

--     Wait(1500)

--     SetEntityInvincible(PlayerPedId(),false)
--     SetEntityVisible(PlayerPedId(),true)
--     FreezeEntityPosition(PlayerPedId(),false)
--     SetPedDiesInWater(PlayerPedId(), 1)

--     DoScreenFadeIn(1000)

--     local ped = PlayerPedId()
--     local pedId = PlayerId()
--     SetEntityHealth(ped, 400)
--     ClearPlayerWantedLevel(pedId)
--     SetCurrentPedWeapon(ped,"WEAPON_UNARMED",true)
--     RemoveAllPedWeapons(ped, true)
--     ClearPedBloodDamage(ped)
--     idleGame = 1
    
--     if not LobbyTheard1 then
--         LobbyTheard1 = true
        
--         Citizen.CreateThread(function()
--             while true do
--                 if LocalPlayer.state.inGameLobby then
--                     idleGame = 1
--                     SetEntityHealth(PlayerPedId(), 400)
--                     DisablePlayerFiring(ped,true)            
--                     DisableControlAction(2,37,true)
--                     DisableControlAction(1,45,true)
--                     DisableControlAction(2,80,true)
--                     DisableControlAction(2,140,true)
--                     DisableControlAction(2,250,true)
--                     DisableControlAction(2,263,true)
--                     DisableControlAction(2,310,true)
--                     DisableControlAction(1,140,true)
--                     DisableControlAction(1,141,true)
--                     DisableControlAction(1,142,true)
--                     DisableControlAction(1,143,true)
--                     DisableControlAction(0,24,true)
--                     DisableControlAction(0,25,true)
--                     DisableControlAction(0,58,true)
--                     DisableControlAction(0,106,true)
--                     SetEntityInvincible(ped, true)
--                     SetPedCanSwitchWeapon(ped, false)
        
--                     local timeValue = cooldown
--                     local isSeconds = true
                    
--                     if timeValue >= 60 then
--                         timeValue = timeValue / 60
--                         isSeconds = false
--                     end

--                     if isSeconds then
--                         AddAnnouncement({
--                             status = true,
--                             text = "A partida começará em <b>".. LuizDev.SecondsToClock(timeValue).."</b> segundos",
--                             timer = false,
--                         })
--                     else
--                         AddAnnouncement({
--                             status = true,
--                             text = "A partida começará em <b>instantes</b> aguarde...",
--                             timer = false,
--                         })
--                     end

--                     if cooldown == 1 then
--                         if not StartGame then
--                             StartGame = true
--                             controller.sendServerEvent('StartGameNew', {})
--                         end
--                     end
--                 else
--                     idleGame = 5000
--                 end
        
--                 Citizen.Wait(idleGame)
--             end
--         end)
--     end
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- ExitLobbyGame - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function src.ExitLobbyGame() 
--     local ped = PlayerPedId()
--     local pedId = PlayerId()
--     DisablePlayerFiring(PlayerPedId(), false)
--     exports["vrp"]:ResetCrouch()
--     Wait(1000)
--     LocalPlayer.state.inGameLobby = false
--     LocalPlayer.state.inDashboard = false
--     LocalPlayer.state.Buttons = false

--     AddAnnouncement({ status = false })
--     -- torna o jogador vulnerável novamente quando sair do lobby
--     SetEntityInvincible(ped, false)
--     SetPedCanSwitchWeapon(ped, true)

--     idleGame = 5000
--     StartGame = false
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- ExitLobbyGame - Event
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- RegisterNetEvent("ExitLobbyGame")
-- AddEventHandler("ExitLobbyGame",function(type, data)
--     local ped = PlayerPedId()
--     local pedId = PlayerId()
--     DisablePlayerFiring(PlayerPedId(), false)
--     exports["vrp"]:ResetCrouch()
--     Wait(1000)
--     AddAnnouncement({ status = false })
--     LocalPlayer.state.inDashboard = false
--     -- torna o jogador vulnerável novamente quando sair do lobby
--     SetEntityInvincible(ped, false)
--     SetPedCanSwitchWeapon(ped, true)

--     idleGame = 5000
-- end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- generateSpawnSkinsCoords - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function generateSpawnSkinsCoords()
--     local random = math.random(#Config.LobbySkinsPreviws)
--     return Config.LobbySkinsPreviws[random]
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- generateSpawnSkinsName - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function generateSpawnSkinsName()
--     local skins = reMapData(Config.Skins)

--     local random = math.random(#skins)
--     return skins[random].skin_model
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- reMapData - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function reMapData(game_data)
-- 	-- print(dump(game_data))
-- 	-- RED
-- 	local cntRed = 0
-- 	local _redList = game_data
-- 	game_data = {}
-- 	for k,v in pairs(_redList) do
-- 		cntRed = cntRed + 1
-- 		game_data[cntRed] = v
-- 	end
-- 	return game_data
-- end
