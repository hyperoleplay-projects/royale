
----------------------------------------------------------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------------------------------------------------------
local planeModel = "cargoplane"
local planeEntity

local buggyModel = "outlaw"
local travado = false
local pilotModel = "mp_m_freemode_01"
local animFlags = 0
local animDict = nil
local animName = nil
local animActived = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- toggleNuiFrame - Function
-----------------------------------------------------------------------------------------------------------------------------------------
local PLAYER_SPAWN_COORDS = vector3(-3020.49, -851.22, 4.92)
local PLANE_SPAWN_COORDS = vector3(-3319.8, -943.97, 609.74)

function setPlayerToLobby()
  local ped = PlayerPedId()

  SetEntityCoords(ped, PLAYER_SPAWN_COORDS, 120.0)
  FreezeEntityPosition(ped, true)

  LuizDev.RequestAndWaitModel(planeModel)

  local planeModel = GetHashKey(planeModel)
  local planeEntity = CreateVehicle(planeModel, PLANE_SPAWN_COORDS, false, 0)

  SetModelAsNoLongerNeeded(planeModel)
  SetEntityHeading(planeEntity, 104.89)
  FreezeEntityPosition(planeEntity, true)
  SetVehicleLandingGear(planeEntity, 1)
  ControlLandingGear(planeEntity, 0)
  SetVehicleDoorOpen(planeEntity,2,0,  0)

  LuizDev.LobbyEntities[planeEntity] = planeEntity
end 

-----------------------------------------------------------------------------------------------------------------------------------------
-- playAnim
-----------------------------------------------------------------------------------------------------------------------------------------
function playAnim(animUpper,animSequency,animLoop,ped)
  local playFlags = 0

  if animSequency["task"] then
    stopAnim(true)

    if animSequency["task"] == "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER" then
      local coords = GetEntityCoords(ped)
      TaskStartScenarioAtPosition(ped,animSequency["task"],coords["x"],coords["y"],coords["z"] - 1,GetEntityHeading(ped),0,0,false)
    else
      TaskStartScenarioInPlace(ped,animSequency["task"],0,false)
    end
  else
    stopAnim(animUpper)

    if animUpper then
      playFlags = playFlags + 48
    end

    if animLoop then
      playFlags = playFlags + 1
    end

    Citizen.CreateThread(function()
      RequestAnimDict(animSequency[1])
      while not HasAnimDictLoaded(animSequency[1]) do
        Citizen.Wait(1)
      end

      if HasAnimDictLoaded(animSequency[1]) then
        animDict = animSequency[1]
        animName = animSequency[2]
        animFlags = playFlags

        if playFlags == 49 then
          animActived = true
        end

        TaskPlayAnim(ped,animSequency[1],animSequency[2],3.0,3.0,-1,playFlags,0,0,0,0)
      end
    end)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- stopAnim
-----------------------------------------------------------------------------------------------------------------------------------------
function stopAnim(animUpper)
  animActived = false
  local ped = PlayerPedId()

  if animUpper then
    ClearPedSecondaryTask(ped)
  else
    ClearPedTasks(ped)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RETURNHEADING
-----------------------------------------------------------------------------------------------------------------------------------------
function src.getHeading()
    return GetEntityHeading(PlayerPedId())
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- KILLGOD
-----------------------------------------------------------------------------------------------------------------------------------------
function src.killGod()
  local ped = PlayerPedId()
  SetEntityHealth(PlayerPedId(), 400)
  SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    SetEntityNoCollisionEntity(PlayerPedId(),true,true)
    ClearPedTasks(PlayerPedId())
    ClearPedBloodDamage(PlayerPedId())

  LocalPlayer.state.death = false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- killGod - Event
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("killGod")
AddEventHandler("killGod",function(type, data)
  local ped = PlayerPedId()
  SetEntityHealth(PlayerPedId(), 400)
  SetEntityInvincible(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(),true)
    SetEntityNoCollisionEntity(PlayerPedId(),true,true)
    ClearPedTasks(PlayerPedId())
    ClearPedBloodDamage(PlayerPedId())

  LocalPlayer.state.death = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- f - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function f(n)
  n = n + 0.00000
  return n
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setClothing - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setClothing(ped,data)
  if not data then
    return
  end
  
  SetPedComponentVariation(ped,4,data["pants"]["item"],data["pants"]["texture"],1)
  SetPedComponentVariation(ped,3,data["arms"]["item"],data["arms"]["texture"],1)
  SetPedComponentVariation(ped,5,data["backpack"]["item"],data["backpack"]["texture"],1)
  SetPedComponentVariation(ped,8,data["tshirt"]["item"],data["tshirt"]["texture"],1)
  SetPedComponentVariation(ped,9,data["vest"]["item"],data["vest"]["texture"],1)
  SetPedComponentVariation(ped,11,data["torso"]["item"],data["torso"]["texture"],1)
  SetPedComponentVariation(ped,6,data["shoes"]["item"],data["shoes"]["texture"],1)
  SetPedComponentVariation(ped,1,data["mask"]["item"],data["mask"]["texture"],1)
  SetPedComponentVariation(ped,10,data["decals"]["item"],data["decals"]["texture"],1)
  SetPedComponentVariation(ped,7,data["accessory"]["item"],data["accessory"]["texture"],1)

  if data["hat"]["item"] ~= -1 and data["hat"]["item"] ~= 0 then
    SetPedPropIndex(ped,0,data["hat"]["item"],data["hat"]["texture"],1)
  else
    ClearPedProp(ped,0)
  end

  if data["glass"]["item"] ~= -1 and data["glass"]["item"] ~= 0 then
    SetPedPropIndex(ped,1,data["glass"]["item"],data["glass"]["texture"],1)
  else
    ClearPedProp(ped,1)
  end

  if data["ear"]["item"] ~= -1 and data["ear"]["item"] ~= 0 then
    SetPedPropIndex(ped,2,data["ear"]["item"],data["ear"]["texture"],1)
  else
    ClearPedProp(ped,2)
  end

  if data["watch"]["item"] ~= -1 and data["watch"]["item"] ~= 0 then
    SetPedPropIndex(ped,6,data["watch"]["item"],data["watch"]["texture"],1)
  else
    ClearPedProp(ped,6)
  end

  if data["bracelet"]["item"] ~= -1 and data["bracelet"]["item"] ~= 0 then
    SetPedPropIndex(ped,7,data["bracelet"]["item"],data["bracelet"]["texture"],1)
  else
    ClearPedProp(ped,7)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setTattos - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function setTattos(ped, tattos) 
  if not tattos then
    return
  end
  
  ClearPedDecorations(ped)

  for k,v in pairs(tattos) do
    if v["tatto_status"] == "true" then
      SetPedDecoration(ped,GetHashKey(v["tatto_part"]),GetHashKey(v["tatto_model"]))
    end
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setTattos - Function
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetTattos(tattos) 
  local ped = PlayerPedId()
  ClearPedDecorations(PlayerPedId())

  for k,v in pairs(tattos) do
    if v["tatto_status"] == "true" then
      SetPedDecoration(ped,GetHashKey(v["tatto_part"]),GetHashKey(v["tatto_model"]))
    end
  end

  TriggerEvent("updateTatuagem", tattos)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DrawName
-----------------------------------------------------------------------------------------------------------------------------------------
local function DrawName(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextFont(4)
        SetTextProportional(1)
        SetTextScale(0.3, 0.3)
        SetTextColour(255,255,255,255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 150)
        SetTextDropshadow()
        SetTextOutline()
        SetTextEntry('STRING')
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- getTableSize
-----------------------------------------------------------------------------------------------------------------------------------------
function getTableSize(t)
    local count = 0
    for _, __ in pairs(t) do
        count = count + 1
    end
    return count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DrawSquadText
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawSquadText(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  
  if onScreen then
    SetTextScale(0.3, 0.3)
    SetTextFont(Inter)
    -- SetTextProportional(1)
    -- SetTextDropshadow(0, 0, 0, 0, 55)
    -- SetTextEdge(2, 0, 0, 0, 150)
    -- SetTextDropShadow()
    SetTextColour(255, 255, 255, 255)
    -- SetTextOutline()
  
    -- SetTextColour(253, 255, 133, 255)
  
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DrawReadyText
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawReadyText(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  
  if onScreen then
    SetTextScale(0.2, 0.2)
    SetTextFont(Inter)
  
    if text == 'PRONTO' then
    SetTextColour(245, 175, 0, 255)
    else
    SetTextColour(212, 212, 212, 255)
    end
  
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- setDiscordRich
-----------------------------------------------------------------------------------------------------------------------------------------
function setDiscordRich(title, description)
  SetDiscordAppId(957851467786645554)
  SetDiscordRichPresenceAsset("logo")
  SetRichPresence(description)
  SetDiscordRichPresenceAssetText(title)
  SetDiscordRichPresenceAction(0, "Jogar", "https://discord.gg/hyperoleplay")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- src.setDiscordRich
-----------------------------------------------------------------------------------------------------------------------------------------
function src.setDiscordRich(title, description)
  SetDiscordAppId(957851467786645554)
  SetDiscordRichPresenceAsset("logo")
  SetRichPresence(description)
  SetDiscordRichPresenceAssetText(title)
  SetDiscordRichPresenceAction(0, "Jogar", "https://discord.gg/hyperoleplay")
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- src.SetBlipsUsers
-----------------------------------------------------------------------------------------------------------------------------------------
function src.SetBlipsUsers(user_id) 
  local Ped = PlayerPedId()
  Entity(Ped)["state"]:set("Passport",user_id,true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- createVehicle
-----------------------------------------------------------------------------------------------------------------------------------------
function src.createVehicle(vehHash,vehNet,vehPlate,vehEngine,vehBody,vehFuel,vehCustom,vehWindows,vehDoors,vehTyres,vehBrakes)
  if NetworkDoesNetworkIdExist(vehNet) then
    local nveh = NetToEnt(vehNet)

    if DoesEntityExist(nveh) then
      NetworkRegisterEntityAsNetworked(nveh)

      while not NetworkGetEntityIsNetworked(nveh) do
        NetworkRegisterEntityAsNetworked(nveh)
        Citizen.Wait(1)
      end

      SetNetworkIdCanMigrate(vehNet,true)
      NetworkSetNetworkIdDynamic(vehNet,false)
      SetNetworkIdExistsOnAllMachines(vehNet,true)
      SetVehicleDirtLevel(nveh,0.0)

      SetVehicleNumberPlateText(nveh,vehPlate)
      SetEntityAsMissionEntity(nveh,true,true)
      SetVehicleHasBeenOwnedByPlayer(nveh,true)
      SetVehicleNeedsToBeHotwired(nveh,false)
      SetVehRadioStation(nveh,"OFF")

      local state = GetResourceState("nation_bennys")

      if state == "started" or state == "starting" then
        TriggerEvent("nation:applymods",nveh,json.decode(vehCustom))
      end

      SetVehicleHandlingFloat(nveh,"CHandlingData","fBrakeForce",0.90)
      SetVehicleHandlingFloat(nveh,"CHandlingData","fBrakeBiasFront",0.55)
      SetVehicleHandlingFloat(nveh,"CHandlingData","fHandBrakeForce",0.75)

      SetVehicleEngineHealth(nveh,vehEngine + 0.0)
      SetVehicleBodyHealth(nveh,vehBody + 0.0)
      SetVehicleFuelLevel(nveh,vehFuel + 0.0)
      
      if vehWindows then
        if json.decode(vehWindows) ~= nil then
          for k,v in pairs(json.decode(vehWindows)) do
            if not v then
              SmashVehicleWindow(nveh,parseInt(k))
            end
          end
        end
      end

      if vehTyres then
        if json.decode(vehTyres) ~= nil then
          for k,v in pairs(json.decode(vehTyres)) do
            if v < 2 then
              SetVehicleTyreBurst(nveh,parseInt(k),(v == 1),1000.01)
            end
          end
        end
      end

      if vehDoors then
        if json.decode(vehDoors) ~= nil then
          for k,v in pairs(json.decode(vehDoors)) do
            if v then
              SetVehicleDoorBroken(nveh,parseInt(k),parseInt(v))
            end
          end
        end
      end
    end
  end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETEOBJECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("player:deleteObject")
AddEventHandler("player:deleteObject",function(entIndex)
  if NetworkDoesNetworkIdExist(entIndex) then
        local v = NetToPed(entIndex)
        if DoesEntityExist(v) and IsEntityAnObject(v) then
            Citizen.InvokeNative(0xAD738C3085FE7E11,v,true,true)
            SetEntityAsMissionEntity(v,true,true)
            NetworkRequestControlOfEntity(v)
            Citizen.InvokeNative(0x539E0AE3E6634B9F,Citizen.PointerValueIntInitialized(v))
            DeleteEntity(v)
            DeleteObject(v)
            SetObjectAsNoLongerNeeded(v)
        end
    end
end)

local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
}
  
function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end