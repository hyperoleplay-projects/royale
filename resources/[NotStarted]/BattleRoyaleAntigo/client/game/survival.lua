-- local deadPlayer = false
-- local canDie = true
-- local reviving = false
-- local isBeingRevived = false
-- local NuiRevivePlayer = false
-- local AnimationRevive = false
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- --  GetClosestPlayer - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function GetClosestPlayer()
--     local players = GetPlayers()
--     local closestDistance = -1
--     local closestPlayer = -1
--     local playerPed = PlayerPedId()
--     local playerCoords = GetEntityCoords(playerPed)

--     for index, value in ipairs(players) do
--         local targetPed = GetPlayerPed(value)
--         if targetPed ~= playerPed then
--             local targetCoords = GetEntityCoords(targetPed)
--             local distance = GetDistanceBetweenCoords(playerCoords, targetCoords, true)

--             if closestDistance == -1 or distance < closestDistance then
--                 closestPlayer = value
--                 closestDistance = distance
--             end
--         end
--     end

--     return closestPlayer
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- --  GetPlayers - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function GetPlayers()
--     local players = {}

--     for i = 0, 255 do
--         if NetworkIsPlayerActive(i) then
--             table.insert(players, i)
--         end
--     end

--     return players
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- --  ReviveAgonizingClient - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function src.ReviveAgonizingClient() 
--     local ped = PlayerPedId()
--     vRP.updateHealth(400)
--     SetEntityHealth(ped,400)
--     deadPlayer = false
    
--     local x,y,z = table.unpack(GetEntityCoords(ped))
--     NetworkResurrectLocalPlayer(x,y,z,true,true,false)
--     reviving = false
-- end
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- --  StartThreads - Function
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- function src.StartThreads() 

--     Citizen.CreateThread(function()
--         while true do
--             local timeDistance = 500
--             local ped = PlayerPedId()
--             if GetEntityHealth(ped) <= 101 and (LocalPlayer.state.inGame or false) then
--                 timeDistance = 4
--                 if not deadPlayer then
--                     local x,y,z = table.unpack(GetEntityCoords(ped))
--                     NetworkResurrectLocalPlayer(x,y,z,true,true,false)
    
--                     local Game = serverAPI.GetPlayersTeamDeath()
--                     if #LocalPlayer.state.userTeam['players'] > 1 and not Game then
--                         deadPlayer = true
--                         vRP.updateHealth(400)
--                         SetEntityHealth(ped,400)
--                         serverAPI.RegisterAgonizing(true)
        
--                         if IsPedInAnyVehicle(ped) then
--                             TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
--                         end
        
--                         local animName = "combat@death@from_writhe"
--                         local animName2 = "death_c"
--                         while ( not HasAnimDictLoaded( animName ) ) do
--                             RequestAnimDict( animName )
--                             Citizen.Wait( 5 )
--                         end
        
--                         TaskPlayAnim(PlayerPedId(), animName, animName2, 8.0, 1.0, -1, 1, 0, false, false, false)
--                     end
    
--                 else
--                     SetEntityHealth(ped,101)
--                     BlockWeaponWheelThisFrame()
--                     SetPedToRagdoll(ped,2000,2000,0,0,0,0)
--                 end
--             end
        
--             Citizen.Wait(timeDistance)
--         end
--     end)
    
--     Citizen.CreateThread(function()
    
--         -- Verifique se o jogador está agonizando e se ele ainda não foi revivido
--         while true do
--           if deadPlayer and not IsEntityDead(PlayerPedId()) and not reviving then
      
--             -- Diminua a saúde do jogador gradualmente
--             SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 12)
      
--             -- Verifique se a saúde do jogador chegou a zero e, se for esse o caso, reviva o jogador
--             if GetEntityHealth(PlayerPedId()) <= 0 then
--                 local ped = PlayerPedId()
                
--                 -- SetPlayerInvincible(PlayerId(), false)
--                 serverAPI.RegisterDeath(true)
--                 serverAPI.RegisterAgonizing(false)
                
--                 vRP.updateHealth(400)
--                 SetEntityHealth(ped,400)
--                 deadPlayer = false
                
--                 local x,y,z = table.unpack(GetEntityCoords(ped))
--                 NetworkResurrectLocalPlayer(x,y,z,true,true,false)
--                 reviving = false
--                 serverAPI.GetPlayersTeamDeath()
--             end
      
--           end
--           Citizen.Wait(1000)
--         end
      
--     end)
    
--     Citizen.CreateThread(function()
--         while true do
--             Citizen.Wait(1000)
--             local playerPed = PlayerPedId()
--             if deadPlayer and not IsEntityDead(PlayerPedId()) and not reviving  then
--                 local closestPlayer = GetClosestPlayer()
--                 if closestPlayer ~= -1 then
--                     local playerPedCoords = GetEntityCoords(playerPed)
--                     local targetPedCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
--                     local distance = #(playerPedCoords - targetPedCoords)
--                     if distance <= 2.0 then
--                         -- reviving = true
--                         isBeingRevived = true
--                     end
--                 end
--             end
--         end
--     end)
    
    
    

-- -- Citizen.CreateThread(function()
-- --     while true do
-- --         Citizen.Wait(0)
-- --         local playerPed = PlayerPedId()
-- --         local closestPlayer = GetClosestPlayer()
-- --         if closestPlayer ~= -1 then
-- --             local playerPedCoords = GetEntityCoords(playerPed)
-- --             local targetPedCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
-- --             local distance = #(playerPedCoords - targetPedCoords)
-- --             local status = serverAPI.GetAgonizing(GetPlayerServerId(closestPlayer))

-- --             if distance <= 5.0 and status then
-- --                 if not NuiRevivePlayer then
-- --                     TriggerEvent("NotifyPularPegar", true, "F", "Reviver jogador")
-- --                     NuiRevivePlayer = true
-- --                 end
-- --                 print('tá perto')


-- --                 if IsControlJustPressed(0, 49) then
-- --                     print("Apertou F")
-- --                     if not AnimationRevive then
-- --                         AnimationRevive = true
-- --                         local animName = "mini@cpr@char_a@cpr_str"
-- --                         local animName2 = "cpr_pumpchest"
-- --                         while ( not HasAnimDictLoaded( animName ) ) do
-- --                             RequestAnimDict( animName )
-- --                             Citizen.Wait( 5 )
-- --                         end
        
-- --                         TaskPlayAnim(PlayerPedId(), animName, animName2, 8.0, 1.0, -1, 1, 0, false, false, false)
-- --                     end

-- --                     local playerPedTeam = GetPedRelationshipGroupHash(playerPed)
-- --                     local closestPlayerTeam = GetPedRelationshipGroupHash(GetPlayerPed(closestPlayer))
            
-- --                     if playerPedTeam == closestPlayerTeam and status then
-- --                         SetTimeout(10000,function()
-- --                             serverAPI.ReviveAgonizing(GetPlayerServerId(closestPlayer))
                                    
-- --                             ClearPedSecondaryTask(PlayerPedId())
-- --                             ClearPedTasks(PlayerPedId())
                
-- --                             TriggerEvent("NotifyPularPegar", false, "F", "Reviver jogador")
-- --                             NuiRevivePlayer = false
-- --                             AnimationRevive = false
-- --                         end)
-- --                     end

-- --                 end

-- --             end



-- --         end

-- --     end
-- -- end)

--     -- Citizen.CreateThread(function()
--     --     local isFPressed = false
--     --     local timer = 0
    
--     --     while true do
--     --         Citizen.Wait(5)
            
    
--     --         if timer >= 80 and not isFPressed then -- 500 frames = 10 segundos (assuming 50fps)
--     --             isFPressed = true
--     --         end
    
--     --         -- if #LocalPlayer.state.userTeam['players'] > 1 then
--     --             local playerPed = PlayerPedId()
--     --             local closestPlayer = GetClosestPlayer()
        
--     --             if closestPlayer ~= -1 then
--     --                 local playerPedCoords = GetEntityCoords(playerPed)
--     --                 local targetPedCoords = GetEntityCoords(GetPlayerPed(closestPlayer))
--     --                 local distance = #(playerPedCoords - targetPedCoords)
--     --                 local status = serverAPI.GetAgonizing(GetPlayerServerId(closestPlayer))
    
--     --                 if distance <= 2.0 and status then
    
--     --                     local fAxis = GetControlNormal(0, 23) -- obter o valor do eixo F
--     --                     if fAxis >= 0.9 then -- se o valor do eixo F for maior ou igual a 0,9, a tecla F está sendo pressionada
--     --                         timer = timer + 1
--     --                         if NuiRevivePlayer then
--     --                             TriggerEvent("BuildUI", "ProgressTeste", { progresso = timer })
--     --                         end
                
--     --                         if not AnimationRevive then
--     --                             AnimationRevive = true
--     --                             local animName = "mini@cpr@char_a@cpr_str"
--     --                             local animName2 = "cpr_pumpchest"
--     --                             while ( not HasAnimDictLoaded( animName ) ) do
--     --                                 RequestAnimDict( animName )
--     --                                 Citizen.Wait( 5 )
--     --                             end
                
--     --                             TaskPlayAnim(PlayerPedId(), animName, animName2, 8.0, 1.0, -1, 1, 0, false, false, false)
--     --                         end
--     --                     else
--     --                         if AnimationRevive then
--     --                             ClearPedSecondaryTask(PlayerPedId())
--     --                         else
--     --                             ClearPedTasks(PlayerPedId())
--     --                         end
                
--     --                         isFPressed = false
--     --                         timer = 0
--     --                     end
                
--     --                     if not NuiRevivePlayer then
--     --                         TriggerEvent("NotifyPularPegar", true, "F", "Reviver jogador")
--     --                         NuiRevivePlayer = true
--     --                     end
        
--     --                     if isFPressed and not deadPlayer then
--     --                         local playerPedTeam = GetPedRelationshipGroupHash(playerPed)
--     --                         local closestPlayerTeam = GetPedRelationshipGroupHash(GetPlayerPed(closestPlayer))
                    
--     --                         if playerPedTeam == closestPlayerTeam and status then
--     --                             serverAPI.ReviveAgonizing(GetPlayerServerId(closestPlayer))
                                
--     --                             ClearPedSecondaryTask(PlayerPedId())
--     --                             ClearPedTasks(PlayerPedId())
                    
--     --                             TriggerEvent("NotifyPularPegar", false, "F", "Reviver jogador")
--     --                             NuiRevivePlayer = false
--     --                             AnimationRevive = false
--     --                             isFPressed = false -- resetar para permitir outro revive
--     --                             timer = 0 -- resetar o timer para permitir um novo pressionamento da tecla F
--     --                         end
--     --                     end
--     --                 end
--     --             end
--     --         -- end
    
--     --     end
--     -- end)

    


-- end    