
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local animations = {
  "combatroll_bwd_p1_135",
  "combatroll_bwd_p1_180",
  "combatroll_bwd_p2_135",
  "combatroll_fwd_p1_00",
  "combatroll_fwd_p1_135",
  "combatroll_fwd_p1_45",
  "combatroll_fwd_p1_90"
}
local modes = {
    ['ped'] = {
      start = vec3(1950.24,4723.6,41.06),
      type = 'npcs',
      ped = 'g_m_y_famdnf_01',
      spawns = {
        vec3(1937.53,4708.66,41.11),
        vec3(1934.88,4715.15,41.1),
        vec3(1931.73,4720.66,41.13),
      }
    }
}
local trainingDelay = 0
local nuiOpen = false
local training = false
local pedInUse = nil
local settings = {
  movements = false,
  rolls = false,
  dificuty = 1500
}
local counter = {
  targets = 0,
  kills = 0
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- showNui - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function showNui(mode)
  if nuiOpen then return nil end
  nuiOpen = true
  TriggerEvent("BuildUI", "AimLabInfos", { status = true })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- hideNui - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function hideNui()
  if not nuiOpen then return nil end
  nuiOpen = false
  TriggerEvent("BuildUI", "AimLabInfos", { status = false })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- deleteTrainingEntity - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function deleteTrainingEntity(ped)
  if DoesEntityExist(ped) then
    DeleteEntity(ped)
  end
end

local lastSpawnCoords = nil -- Variável para armazenar a coordenada anterior

local function generateSpawnCoords(mode)
  local random = math.random(#mode.spawns)
  return mode.spawns[random]
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- createTrainingEntity - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function createTrainingEntity(mode)
  if (mode.type == "npcs") then
    local pedHash = GetHashKey(mode.ped)
    RequestModel(pedHash)
    while not HasModelLoaded(pedHash) do Wait(100) end
    local random = math.random(#mode.spawns)

    local clone = ClonePed(PlayerPedId(), false, false, true)
    counter.targets = counter.targets + 1
    SendNUIMessage({ action = "targets", targets = counter.targets, kills = counter.kills })
    local newSpawnCoords = generateSpawnCoords(mode)
    while lastSpawnCoords and newSpawnCoords.x == lastSpawnCoords.x and newSpawnCoords.y == lastSpawnCoords.y and newSpawnCoords.z == lastSpawnCoords.z do
      newSpawnCoords = generateSpawnCoords(mode)
    end
    lastSpawnCoords = newSpawnCoords
    SetPedAmmo(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL_MK2"),-1)

    SetEntityCoords(clone, newSpawnCoords.x, newSpawnCoords.y, newSpawnCoords.z-1)
    SetEntityHeading(clone, 303.31)

    SetBlockingOfNonTemporaryEvents(clone,true)

    if settings.rolls and settings.movements then
      animRunRoll(clone)
    elseif settings.rolls then
      local random = math.random(#animations)
      animRoll(clone,"move_strafe@roll_fps",animations[random],8.0,-8.0)
    elseif settings.movements then
      animRun(clone)
    end

    local time = 0
    while time < settings.dificuty do
      if GetEntityHealth(clone) == 0 then
        Wait(300)
        counter.kills = counter.kills + 1
        setDiscordRich("DUTH", "Aim Lab - Treino em andamento com "..counter.kills.." kills.")

        if training then
          deleteTrainingEntity(clone)
          createTrainingEntity(mode)
        else
          deleteTrainingEntity(clone)
        end
        return nil
      end
      time = time + 10
      Wait(8)
    end

    if DoesEntityExist(clone) then
      if training then
        deleteTrainingEntity(clone)
        createTrainingEntity(mode)
      else
        deleteTrainingEntity(clone)
      end
    end
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- switchTraining - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function switchTraining(mode)
  if training then
    training = false
  else
    training = true
    Citizen.CreateThread(function()
      createTrainingEntity(mode)
    end)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitAimLab - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.ExitAimLab() 
  if training then switchTraining() end
  hideNui()
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ExitAimLab - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("ExitAimLab")
AddEventHandler("ExitAimLab",function(type, data)
  if training then switchTraining() end
  hideNui()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- nuiButtons - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function nuiButtons(mode)
  if not nuiOpen then return nil end

  Citizen.CreateThread(function()
    while true do
      if not nuiOpen then return nil end
    
      if IsControlJustPressed(0, 47) then
        if training then switchTraining() end
        hideNui()
        serverAPI.JoinLobbyPrincipal()
        Wait(100)
      end 

      if IsControlJustPressed(0, 38) then
        if trainingDelay < GetGameTimer() then
          switchTraining(mode)
          trainingDelay = GetGameTimer() + 2000
        end
      end
      
      if IsControlJustPressed(0, 182) then
        if settings.dificuty == 1500 then
          settings.dificuty = 800
        elseif settings.dificuty == 800 then
          settings.dificuty = 500
        else
          settings.dificuty = 1500
        end
      end

      if IsControlJustPressed(0, 246) then
        settings.rolls = not settings.rolls
        Wait(100)
      end
      if IsControlJustPressed(0, 303) then
        settings.movements = not settings.movements
        Wait(100)
      end

      RefillAmmoInstantly(PlayerPedId())

      Wait(1)
    end
  end)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- JoinAimLab - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.JoinAimLab()
    local playerPed = GetPlayerPed(-1)
    local gmode = "ped"
    local mode = modes[gmode]
    settings = {
      movements = false,
      rolls = false,
      dificuty = 1500
    }
    counter = {
      targets = 0,
      kills = 0
    }

    GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL_MK2"),-1,true)
    SetPedAmmo(playerPed, GetHashKey("WEAPON_PISTOL_MK2"),-1)
    SetCurrentPedWeapon(PlayerPedId(),GetHashKey("WEAPON_PISTOL_MK2"),true)
    TriggerEvent("BuildUI", "DuthMindlle", { status = true })
    SetEntityCoords(PlayerPedId(), mode.start.x, mode.start.y, mode.start.z)
    SetEntityHeading(PlayerPedId(), 113.39)
    SetGameplayCamRelativeHeading(15)
    showNui(mode)
    nuiButtons(mode)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- animRoll - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function animRoll(ped,direct,name,v1,v2)
  local anim = direct
  RequestAnimDict(anim)
  while not HasAnimDictLoaded(anim) do Wait(10) end
  TaskPlayAnim(ped,anim,name,v1,v2,-1,0,0, nil,nil,nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- animRun - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function animRun(ped)
  local direcao = math.random(2)
  if direcao == 1 then
    SetEntityHeading(ped,303.31)
  else
    SetEntityHeading(ped,303.31)
  end
  local anim = "anim@heists@narcotics@trash"
  RequestAnimDict(anim)
  while not HasAnimDictLoaded(anim) do Wait(10) end
  TaskPlayAnim(ped,anim,"run",8.0,-8.0,-1,0,0, nil,nil,nil)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- animRunRoll - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function animRunRoll(ped)
  local direcao = math.random(2)
  if direcao == 1 then
    SetEntityHeading(ped,303.31)
  else
    SetEntityHeading(ped,303.31)
  end
  local anim = "anim@heists@narcotics@trash"
  RequestAnimDict(anim)
  while not HasAnimDictLoaded(anim) do Wait(10) end
  TaskPlayAnim(ped,anim,"run",8.0,-8.0,-1,0,0, nil,nil,nil)
  Wait(500)
  local anim_ = "move_strafe@roll_fps"
  RequestAnimDict(anim_)
  while not HasAnimDictLoaded(anim_) do Wait(10) end
  local random = math.random(#animations)
  TaskPlayAnim(ped,anim_,animations[random],8.0,-8.0,-1,0,0, nil,nil,nil)
end