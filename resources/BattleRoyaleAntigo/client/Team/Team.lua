local playerstats = {}
local blips = {}
local mysquad = {}
local playertags = {}
local textThreadTick = 0
local update = false
LocalPlayer.state.userTeam = {}
-----------------------------------------------------------------------------------------
-- BuildTeam - Funciton
-----------------------------------------------------------------------------------------
function src.BuildTeam() 
	local Team = LocalPlayer.state.userTeam['players'] or {}
	if Team == nil then return end

    for k,v in pairs(LuizDev.PedsClient) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end

	mysquad = LocalPlayer.state.userTeam

    for k,v in pairs(mysquad.players) do
        if v.state then
            local data = json.decode(v.currentCharacterMode)
            local cModelHash = data.skin
    
            RequestModel(cModelHash)
            while not HasModelLoaded(cModelHash) do
                Citizen.Wait(1)
            end
    
            if HasModelLoaded(cModelHash) then
                LuizDev.PedsClient[v.user_id] = CreatePed(4,cModelHash, Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, Config.spawnLoc[v.pos].z-1, Config.spawnLoc[v.pos].w,false,false)
                SetEntityInvincible(LuizDev.PedsClient[v.user_id], true)
                FreezeEntityPosition(LuizDev.PedsClient[v.user_id], true)
                SetBlockingOfNonTemporaryEvents(LuizDev.PedsClient[v.user_id], true)
                SetModelAsNoLongerNeeded(cModelHash)
    
                LuizDev.TaskUpdateSkinOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateFaceOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateHeadOptions(LuizDev.PedsClient[v.user_id], data)
                setClothing(LuizDev.PedsClient[v.user_id], json.decode(v.Clothes))
                setTattos(LuizDev.PedsClient[v.user_id], v.Tatuagens)
            end
    
            
            cam.setActive("CAM_BATTLEROYALE_DASHBOARD")
            cam.render("CAM_BATTLEROYALE_DASHBOARD", true, false, 0)
        end
    end

    mysquad = LocalPlayer.state.userTeam
    SendReactMessage('BuildTeamPlayers', LuizDev.reMapData(LocalPlayer.state.userTeam['players']))
    SendReactMessage('BuildTeam', LocalPlayer.state.userTeam)

	TriggerEvent("BuildUI", "BuildTeam", { dataPrincipal = mysquad, user_id = LocalPlayer.state.user_id })

    handleText()
    
	if mysquad.playersCount > 1 then
        updateBlips(true)
        updateTags(true)
        noDamage()

        CreateThread(function()
            while true do
                local sleep = 3 * 1000
                updateBlips(true)
    
                if not update then
                    updateTags(false)
                end
                Wait(sleep)
            end
        end)

		CreateThread(function()
            while true do
                local sleep = 2000
                sleep = 500
                sendstat()
                if IsPauseMenuActive() then
        			RemoveTagAndBlips(true, false)
        		end
                Wait(sleep)
            end
        end)
    else
        activeDamage()
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- BuildTeam - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("BuildTeam")
AddEventHandler("BuildTeam",function()
	local Team = LocalPlayer.state.userTeam['players'] or {}
	if Team == nil then return end

    for k,v in pairs(LuizDev.PedsClient) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end

	mysquad = LocalPlayer.state.userTeam

    for k,v in pairs(mysquad.players) do
        if v.state then
            local data = json.decode(v.currentCharacterMode)
            local cModelHash = data.skin
    
            RequestModel(cModelHash)
            while not HasModelLoaded(cModelHash) do
                Citizen.Wait(1)
            end
    
            if HasModelLoaded(cModelHash) then
                LuizDev.PedsClient[v.user_id] = CreatePed(4,cModelHash, Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, Config.spawnLoc[v.pos].z-1, Config.spawnLoc[v.pos].w,false,false)
                SetEntityInvincible(LuizDev.PedsClient[v.user_id], true)
                FreezeEntityPosition(LuizDev.PedsClient[v.user_id], true)
                SetBlockingOfNonTemporaryEvents(LuizDev.PedsClient[v.user_id], true)
                SetModelAsNoLongerNeeded(cModelHash)
    
                LuizDev.TaskUpdateSkinOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateFaceOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateHeadOptions(LuizDev.PedsClient[v.user_id], data)
                setClothing(LuizDev.PedsClient[v.user_id], json.decode(v.Clothes))
                setTattos(LuizDev.PedsClient[v.user_id], v.Tatuagens)
            end
    
            
            cam.setActive("CAM_BATTLEROYALE_DASHBOARD")
            cam.render("CAM_BATTLEROYALE_DASHBOARD", true, false, 0)
        end
    end

    mysquad = LocalPlayer.state.userTeam
    SendReactMessage('BuildTeamPlayers', LuizDev.reMapData(LocalPlayer.state.userTeam['players']))
    SendReactMessage('BuildTeam', LocalPlayer.state.userTeam)

	TriggerEvent("BuildUI", "BuildTeam", { dataPrincipal = mysquad, user_id = LocalPlayer.state.user_id })

    handleText()
    
	if mysquad.playersCount > 1 then
        updateBlips(true)
        updateTags(true)
        noDamage()

        CreateThread(function()
            while true do
                local sleep = 3 * 1000
                updateBlips(true)
    
                if not update then
                    updateTags(false)
                end
                Wait(sleep)
            end
        end)

		CreateThread(function()
            while true do
                local sleep = 2000
                sleep = 500
                sendstat()
                if IsPauseMenuActive() then
        			RemoveTagAndBlips(true, false)
        		end
                Wait(sleep)
            end
        end)
    else
        activeDamage()
    end
end)
-----------------------------------------------------------------------------------------
-- BuildTeam 2 - Funciton
-----------------------------------------------------------------------------------------
function BuildTeam() 
	local Team = LocalPlayer.state.userTeam['players'] or {}
	if Team == nil then return end

    for k,v in pairs(LuizDev.PedsClient) do
		if DoesEntityExist(v) then
			DeleteEntity(v)
		end
	end

    mysquad = LocalPlayer.state.userTeam

    for k,v in pairs(mysquad.players) do
        if v.state then
            local data = json.decode(v.currentCharacterMode)
            local cModelHash = data.skin
    
            RequestModel(cModelHash)
            while not HasModelLoaded(cModelHash) do
                Citizen.Wait(1)
            end
    
            if HasModelLoaded(cModelHash) then
                LuizDev.PedsClient[v.user_id] = CreatePed(4,cModelHash, Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, Config.spawnLoc[v.pos].z-1, Config.spawnLoc[v.pos].w,false,false)
                SetEntityInvincible(LuizDev.PedsClient[v.user_id], true)
                FreezeEntityPosition(LuizDev.PedsClient[v.user_id], true)
                SetBlockingOfNonTemporaryEvents(LuizDev.PedsClient[v.user_id], true)
                SetModelAsNoLongerNeeded(cModelHash)
    
                LuizDev.TaskUpdateSkinOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateFaceOptions(LuizDev.PedsClient[v.user_id], data)
                LuizDev.TaskUpdateHeadOptions(LuizDev.PedsClient[v.user_id], data)
                setClothing(LuizDev.PedsClient[v.user_id], json.decode(v.Clothes))
                setTattos(LuizDev.PedsClient[v.user_id], v.Tatuagens)
            end
    
            
            cam.setActive("CAM_BATTLEROYALE_DASHBOARD")
            cam.render("CAM_BATTLEROYALE_DASHBOARD", true, false, 0)
        end
    end

    SendReactMessage('BuildTeamPlayers', LuizDev.reMapData(LocalPlayer.state.userTeam['players']))
    SendReactMessage('BuildTeam', LocalPlayer.state.userTeam)

	TriggerEvent("BuildUI", "BuildTeam", { dataPrincipal = mysquad, user_id = LocalPlayer.state.user_id })
    handleText()

	if mysquad.playersCount > 1 then
        updateBlips(true)
        updateTags(true)
        noDamage()

        CreateThread(function()
            while true do
                local sleep = 3 * 1000
                updateBlips(true)
    
                if not update then
                    updateTags(false)
                end
                Wait(sleep)
            end
        end)


		CreateThread(function()
            while true do
                local sleep = 2000
                sleep = 500
                sendstat()
                if IsPauseMenuActive() then
        			RemoveTagAndBlips(true, false)
        		end
                Wait(sleep)
            end
        end)
    else
        activeDamage()
    end
end
-----------------------------------------------------------------------------------------
-- exitTeam - NUI
-----------------------------------------------------------------------------------------
RegisterNUICallback("exitTeam", function(data, cb)
    local exitTeam = serverAPI.exitTeam()
    activeDamage()
    cb(exitTeam)
end)
-----------------------------------------------------------------------------------------
-- sendInviteTeam - NUI
-----------------------------------------------------------------------------------------
RegisterNUICallback("sendInviteTeam", function(data, cb)
    local sendInviteTeam = serverAPI.sendInviteTeam(data.friend_id)
    cb(sendInviteTeam)
end)
-----------------------------------------------------------------------------------------
-- Play - NUI
-----------------------------------------------------------------------------------------
RegisterNUICallback("Play", function(data, cb)
    local Play = serverAPI.PlayMatchTeam()
    cb(Play)
end)
-----------------------------------------------------------------------------------------
-- noDamage - Function
-----------------------------------------------------------------------------------------
function noDamage()
	if LocalPlayer.state.inTeam then
		local playerPed = PlayerPedId()
		local group = "squad"..LocalPlayer.state.userTeam.TeamId
		local _, hash = AddRelationshipGroup(group)
		SetPedRelationshipGroupHash(playerPed, hash)
		SetEntityCanBeDamagedByRelationshipGroup(playerPed, false, hash)
	end
end
-----------------------------------------------------------------------------------------
-- activeDamage - Function
-----------------------------------------------------------------------------------------
function activeDamage()
	local playerPed = PlayerPedId()
	SetPedRelationshipGroupHash(playerPed, "PLAYER")
	SetEntityCanBeDamagedByRelationshipGroup(playerPed, true, "PLAYER")
end
-----------------------------------------------------------------------------------------
-- sendstat - Function
-----------------------------------------------------------------------------------------
function sendstat()
    if LocalPlayer.state.inGame then
        for i = 1, #mysquad.players do
            ::try::
            if not mysquad.players then break end
            if mysquad.players[i] == nil then goto try return end
    
            local player = GetPlayerFromServerId(mysquad.players[i].source)
            local ped = GetPlayerPed(player)
            if playerstats[mysquad.players[i].hexlast] == nil then
                playerstats[mysquad.players[i].hexlast] = { hp = 0, armour = 0, username = "Not load", avatar = "[]", user_id = 0, color = 0 }
            else
                playerstats[mysquad.players[i].hexlast] = { hp = playerstats[mysquad.players[i].hexlast].hp, armour = playerstats[mysquad.players[i].hexlast].armour, username = playerstats[mysquad.players[i].hexlast].username, avatar = playerstats[mysquad.players[i].hexlast].avatar, user_id = playerstats[mysquad.players[i].hexlast].user_id, color = playerstats[mysquad.players[i].hexlast].color }
            end
            local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
            local nowhp = parseInt((100*GetEntityHealth(ped)/GetEntityMaxHealth(ped)))
            local nowarmour = GetPedArmour(ped)
            local armour = nowarmour
            playerstats[mysquad.players[i].hexlast].user_id = mysquad.players[i].user_id
            playerstats[mysquad.players[i].hexlast].username = mysquad.players[i].username
            playerstats[mysquad.players[i].hexlast].avatar = mysquad.players[i].avatar
            playerstats[mysquad.players[i].hexlast].color = mysquad.players[i].color
            playerstats[mysquad.players[i].hexlast].hp = nowhp
            playerstats[mysquad.players[i].hexlast].armour = armour
        end
    
        TriggerEvent("BuildUI", "buildStats", playerstats)
    end
end
-----------------------------------------------------------------------------------------
-- updateBlips - Function
-----------------------------------------------------------------------------------------
function updateBlips(remove)
    if LocalPlayer.state.inGame then
        if remove then
            RemoveTagAndBlips(false, true)
        end
        if not mysquad.players then return end
        for i = 1, #mysquad.players do
            ::try::
            if not mysquad.players then break end
            if mysquad.players[i] == nil then goto try return end
            local player = GetPlayerFromServerId(mysquad.players[i].source)
            local ped = GetPlayerPed(player)
            local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
            if _distance < 4000 and _distance > 1 then
                local blip = AddBlipForEntity(ped)
                SetBlipColour(blip, mysquad.players[i].color["colorBlip"])
                SetBlipCategory(blip, 2)
                SetBlipScale(blip, 0.7)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(mysquad.players[i].username)
                EndTextCommandSetBlipName(blip)
                blips[mysquad.players[i].hexlast] = blip
            end
        end
    end
end
-----------------------------------------------------------------------------------------
-- updateTags - Function
-----------------------------------------------------------------------------------------
function updateTags(remove)
    if LocalPlayer.state.inGame then
        if remove then
            RemoveTagAndBlips(true, false)
            Wait(1000)
        end
        if not mysquad.players then return end
        for i = 1, #mysquad.players do
            if not mysquad.players then break end
            if mysquad.players[i] == nil then return end
            local player = GetPlayerFromServerId(mysquad.players[i].source)
            local ped = GetPlayerPed(player)
    
            local _distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
            if _distance < 4000 and _distance > 1 then
                if playertags[mysquad.players[i].hexlast] == nil then
                    local tag = CreateFakeMpGamerTag(ped, mysquad.players[i].username, 0, 0, "", 0)
                            
                    SetMpGamerTagVisibility(tag, 0, true)
                    SetMpGamerTagVisibility(tag, 10, true)
                    SetMpGamerTagColour(tag, 10, mysquad.players[i].color["colorTag"])
    
                    playertags[mysquad.players[i].hexlast] = tag
                end
            else
                if playertags[mysquad.players[i].hexlast] then
                    RemoveMpGamerTag(playertags[mysquad.players[i].hexlast])
                    playertags[mysquad.players[i].hexlast] = nil
                end
            end
            Wait(100)
        end
        update = false
    end
end
-----------------------------------------------------------------------------------------
-- RemoveTagAndBlips - Function
-----------------------------------------------------------------------------------------
function RemoveTagAndBlips(dtag, dblips)
    if dtag then
		for k,v in pairs(playertags) do
			RemoveMpGamerTag(v)
		end
		playertags = {}
	end

	if dblips then
		for k, v in pairs(blips) do
			RemoveBlip(v)
		end
		blips = {}
	end
end
-----------------------------------------------------------------------------------------
-- handleText - Function
-----------------------------------------------------------------------------------------
function handleText()
    CreateThread(function()
      while LocalPlayer.state.inDashboard do
        Wait(textThreadTick or 0)

        for k,v in pairs(mysquad.players) do
            local readyState = v.ready and 'PRONTO' or 'NÃO ESTÁ PRONTO'
            local z = Config.spawnLoc[v.pos].z + 0.985
  
            DrawSquadText(Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, z + 0.12, v.username)
            DrawReadyText(Config.spawnLoc[v.pos].x, Config.spawnLoc[v.pos].y, z - 0.01, readyState)
        end
      end
    end)
end
  