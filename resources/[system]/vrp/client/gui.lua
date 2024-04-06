-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local object = nil
local menu_state = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENMENUDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.openMenuData(menudata)
	SendNUIMessage({ act = "open_menu", menudata = menudata })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CLOSEMENU
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.closeMenu()
	SendNUIMessage({ act = "close_menu" })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROMPT
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.prompt(title,default_text)
	SendNUIMessage({ act = "prompt", title = title, text = tostring(default_text) })
	SetNuiFocus(true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUEST
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.request(id,text,time)
	SendNUIMessage({ act = "request", id = id, text = tostring(text), time = time })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- MENUCALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("menu",function(data,cb)
	if data.act == "close" then
		vRPserver._closeMenu(data.id)
	elseif data.act == "valid" then
		vRPserver._validMenuChoice(data.id,data.choice,data.mod)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MENU_STATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("menu_state",function(data,cb)
	menu_state = data
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PROMPT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("prompt",function(data,cb)
	if data.act == "close" then
		SetNuiFocus(false)
		vRPserver._promptResult(data.result)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REQUEST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("request",function(data,cb)
	if data.act == "response" then
		vRPserver._requestResult(data.id,data.ok)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- INIT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("init",function(data,cb)
	SendNUIMessage({ act = "cfg", cfg = {} })
	TriggerEvent("vRP:NUIready")
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETDIV
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.setDiv(name,css,content)
	SendNUIMessage({ act = "set_div", name = name, css = css, content = content })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEDIV
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.removeDiv(name)
	SendNUIMessage({ act = "remove_div", name = name })
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- LOADANIMSET
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.loadAnimSet(dict)
	RequestAnimSet(dict)
	while not HasAnimSetLoaded(dict) do
		Citizen.Wait(10)
	end
	SetPedMovementClipset(PlayerPedId(),dict,0.25)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CARREGARANIM
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.CarregarAnim(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(10)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CARREGAROBJETO
-----------------------------------------------------------------------------------------------------------------------------------------
local objetos = {}
function tvRP.CarregarObjeto(dict,anim,prop,flag,hand,pos1,pos2,pos3,pos4,pos5,pos6)
	local ped = PlayerPedId()

	RequestModel(GetHashKey(prop))
	while not HasModelLoaded(GetHashKey(prop)) do
		Citizen.Wait(10)
	end

	local id = ''

	if objetos[id] then
		repeat
			id = string.sub(tostring(math.random()), 3)
		until not objetos[id]
	end

	if pos1 then
		local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
		objetos[id] = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
		SetEntityCollision(objetos[id],false,false)
		AttachEntityToEntity(objetos[id],ped,GetPedBoneIndex(ped,hand),pos1,pos2,pos3,pos4,pos5,pos6,true,true,false,true,1,true)
	else
		tvRP.CarregarAnim(dict)
		TaskPlayAnim(ped,dict,anim,8.0,8.0,-1,flag,0,0,0,0)
		local coords = GetOffsetFromEntityInWorldCoords(ped,0.0,0.0,-5.0)
		objetos[id] = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true)
		SetEntityCollision(objetos[id],false,false)
		AttachEntityToEntity(objetos[id],ped,GetPedBoneIndex(ped,hand),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
	end
	Citizen.InvokeNative(0xAD738C3085FE7E11,objetos[id],true,true)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DELETAROBJETO
-----------------------------------------------------------------------------------------------------------------------------------------
function tvRP.DeletarObjeto()
    tvRP.stopAnim(true)
	TriggerEvent("binoculos")
	for k, v in pairs(objetos) do
		if DoesEntityExist(v) then
			TriggerServerEvent("deleteObjects",ObjToNet(v))
			objetos[k] = nil
		end
	end
end
