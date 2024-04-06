-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPC = Tunnel.getInterface("vRP","vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local chatCooldown = {}
local chatStatus = true
local Anuncios = {
	"Acesse nosso instagram: ^*instagram.com/duth.gg^r",
	"Acesse nosso discord: ^*discord.gg/duthgg^r",
	"Acesse nossa ^*LOJA^r e apoie o projeto ^*loja.duthgg.com.br^r"
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllByServer
-----------------------------------------------------------------------------------------------------------------------------------------
function getAllByServer()
    local players = {}
    local count = 0
    for _, src in ipairs(GetPlayers()) do
        if Player(src).state.inLobbyPrincipal then
			local userId = vRP.getUserId(src)
            players[src] = userId
            count = count + 1
        end
    end

    return players, count
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- emitPlayersEvent
-----------------------------------------------------------------------------------------------------------------------------------------
function emitPlayersEvent(eventName,...)
    local players, playerCount = getAllByServer()
    if playerCount > 0 then
        for src, uid in pairs(players) do
            TriggerClientEvent(eventName,src,...)
        end
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- _chat:messageEntered
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('_chat:messageEntered')
AddEventHandler('_chat:messageEntered',function(author,color,message)
	local source = source
	local user_id = vRP.getUserId(source)
    local identity = vRP.getIdentity(user_id)
	local globe = "fa-solid fa-globe"
	local location = "fa-solid fa-location-arrow"
	local dev = "fa-solid fa-code"
	local name = identity.username
	
	if not message or not author or not identity then
		return
    end

	
	if chatStatus then
		if not WasEventCanceled() then
			
		if not Player(source).state.ChatCooldown or os.time() >= Player(source).state.ChatCooldown + 5 then
			Player(source).state.ChatCooldown = os.time()
	
				async(function()
					if exports["core"]:Group().hasPermission(user_id,"dev") then
						emitPlayersEvent("chatMessage",globe,"CEO",identity.username,message,{215, 193, 108})
					elseif exports["core"]:Group().hasPermission(user_id,"mng") then
						emitPlayersEvent("chatMessage",globe,"MANAGER",identity.username,message,{215, 193, 108})
					elseif exports["core"]:Group().hasPermission(user_id,"staff") then
						emitPlayersEvent("chatMessage",globe,user_id,name,message,{215, 193, 108})
					elseif exports["core"]:Premium().isVipByUserId(user_id,"padrao") then
						emitPlayersEvent("chatMessage",globe,"PREMIUM",identity.username,message,{215, 193, 108})
					elseif exports["core"]:Group().hasPermission(user_id,"Boosterr") then
						emitPlayersEvent("chatMessage",globe,"BOOSTER",identity.username,message,{215, 193, 108})
					elseif exports["core"]:Group().hasPermission(user_id,"Betaa") then
						emitPlayersEvent("chatMessage",globe,"BETA",identity.username,message,{215, 193, 108})
					else
						emitPlayersEvent("chatMessage",globe,user_id,identity.username,message,{215, 193, 108})
					end
				end)
	
	
			else
				TriggerClientEvent("Notify",source,"negado", "Aguarde " .. (5 - (os.time() - Player(source).state.ChatCooldown)) .. " segundos.")
			end
		end
	else
		TriggerClientEvent("Notify",source,"negado","O chat global está fechado.")
	end
end)
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- -- THREAD GLOBAL
-- -----------------------------------------------------------------------------------------------------------------------------------------
local icon = "fa-solid fa-hashtag"
Citizen.CreateThread(function()
	while true do
		local random = math.random(#Anuncios)
		local text = Anuncios[random]

		emitPlayersEvent("chatMessage2",icon,"DUTH",text,{215, 193, 108})
		Citizen.Wait(8*60000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FALLBACK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('__cfx_internal:commandFallback')
AddEventHandler('__cfx_internal:commandFallback',function(command)
	local name = GetPlayerName(source)
	if not command or not name then
		return
	end

	if not WasEventCanceled() then
		TriggerEvent("chatMessage",source,name,'/'..command)
	end
	CancelEvent()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FECHARCHAT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fecharchat",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)
	if exports["core"]:Group().hasPermission(user_id,"dev") then
		if chatStatus then
			TriggerClientEvent("Notify",source,"sucess","Você travou o chat para todos.")
			chatStatus = false
		else
			TriggerClientEvent("Notify",source,"sucess","Você liberou o chat para todos novamente.")
			chatStatus = true
		end
	end
end)