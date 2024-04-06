-----------------------------------------------------------------------------------------------------------------------------------------
-- LANG
-----------------------------------------------------------------------------------------------------------------------------------------
local Lang = {
	join = 'Entrando...',
	connecting = 'Conectando...',
	position = 'Você é o %d/%d da fila, aguarde sua conexão',
	error = 'Não encontramos uma conexão valida com sua steam.',
	steam = 'Não foi possível identificar sua conexão com a steam.',
	discord = 'Não foi possível identificar sua conexão com o discord.',
	connecterror = 'Não foi possível adiciona-lo na fila de conexão.',
	error2 = 'Não foi possível dar continuidade a sua conexão na fila.'
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Queue = {}
Queue.QueueList = {}
Queue.PlayerList = {}
Queue.PlayerCount = 0
Queue.Connecting = {}
Queue.ThreadCount = 0
local maxPlayers = 450
local priorityUsers = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- PREPARES
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare('vRP/priorityQueue','SELECT * FROM queue')
vRP.prepare('vRP/deletePriority','DELETE FROM queue WHERE user_id = @user_id')
vRP.prepare('vRP/insertPriority','INSERT INTO queue(user_id,steam,nickname,priority) VALUES(@user_id,@steam,@nickname,@priority)')
vRP.prepare('vRP/getIdentifiers','SELECT * FROM users_identifiers WHERE user_id = @user_id')
-----------------------------------------------------------------------------------------------------------------------------------------
-- ATUALIZARPRIORIDADES
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('atualizarprioridades',function(source,args,rawCmd)
	if source == 0 then
		local v = vRP.query('vRP/priorityQueue')
		for i = 1,#v do
			priorityUsers[v[i].steam] = v[i].priority
			print('^2[ FILA ] ^7Update '..v[i].steam..' w/ '..v[i].priority)
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FIXPRIORIDADE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('addPrioridade',function(source, args, rawCmd)
	local user_idS = vRP.getUserId(source)
	
	if not exports["core"]:Group().hasAccessOrHigher(user_idS,"dev") then
        return
    end

    local user_id = parseInt(args[1])
    local nickname = args[2]
    local percent = parseInt(args[3])
    
    vRP.execute('vRP/deletePriority',{ user_id = user_id })
    print('^2[ FIX : PRIORIDADE ] ^7Deletado prioridades registradas no usuário.')
    local identifiers = vRP.query('vRP/getIdentifiers',{ user_id = user_id })
    for k,v in pairs(identifiers) do
        if string.match(v.identifier,'steam:') then 
            vRP.execute('vRP/insertPriority',{
                user_id = user_id,
                steam = v.identifier,
                nickname = nickname,
                priority = percent                
            })
            print('^2[ FIX : PRIORIDADE ] ^7'..user_id..' inserido com a steam '..v.identifier..' nickname '..nickname..' com '..percent)
            return
        end
    end
	
    print('^1[ FIX : PRIORIDADE : FINAL ] ^7'..user_id..' steam hex não encontrada.')
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	local v = vRP.query('vRP/priorityQueue')
	for i = 1,#v do
		priorityUsers[v[i].steam] = v[i].priority
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STEAMRUNNING
-----------------------------------------------------------------------------------------------------------------------------------------
function steamRunning(source)
	local identifiers = GetPlayerIdentifiers(source)
	for k,v in ipairs(identifiers) do
		if string.sub(v,1,5) == 'steam' then
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- DiscordRunning
-----------------------------------------------------------------------------------------------------------------------------------------
function DiscordRunning(source)
	local identifiers = GetPlayerIdentifiers(source)
	for k,v in ipairs(identifiers) do
		if string.sub(v,1,5) == 'discord' then
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
function getQueue(ids,trouble,source,connect)
	for k,v in ipairs(connect and Queue.Connecting or Queue.QueueList) do
		local inQueue = false

		if not source then
			for _,i in ipairs(v.ids) do
				if inQueue then
					break
				end

				for _,o in ipairs(ids) do
					if o == i then
						inQueue = true
						break
					end
				end
			end
		else
			inQueue = ids == v.source
		end

		if inQueue then
			if trouble then
				return k,connect and Queue.Connecting[k] or Queue.QueueList[k]
			end

			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- INQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
function isPriority(ids)
	for k,v in ipairs(ids) do
		if string.sub(v,1,5) == 'steam' then
			if priorityUsers[v] then
				return priorityUsers[v]
			else
				priorityUsers[v] = 0
				return priorityUsers[v]
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
function addQueue(ids,connectTime,name,source,deferrals)
	if getQueue(ids) then
		return
	end

	local tmp = { source = source, ids = ids, name = name, firstconnect = connectTime, priority = isPriority(ids), timeout = 0, deferrals = deferrals }

	local _pos = false
	local queueCount = #Queue.QueueList + 1

	for k,v in ipairs(Queue.QueueList) do
		if tmp.priority then
			if not v.priority then
				_pos = k
			else
				if tmp.priority > v.priority then
					_pos = k
				end
			end

			if _pos then
				break
			end
		end
	end

	if not _pos then
		_pos = #Queue.QueueList + 1
	end

	table.insert(Queue.QueueList,_pos,tmp)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
function removeQueue(ids,source)
	if getQueue(ids,false,source) then
		local pos,data = getQueue(ids,true,source)
		table.remove(Queue.QueueList,pos)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ISCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function isConnect(ids,source,refresh)
	local k,v = getQueue(ids,refresh and true or false,source and true or false,true)

	if not k then
		return false
	end

	if refresh and k and v then
		Queue.Connecting[k].timeout = 0
	end
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVECONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function removeConnect(ids,source)
	for k,v in ipairs(Queue.Connecting) do
		local connect = false

		if not source then
			for _,i in ipairs(v.ids) do
				if connect then
					break
				end

				for _,o in ipairs(ids) do
					if o == i then
						connect = true
						break
					end
				end
			end
		else
			connect = ids == v.source
		end

		if connect then
			table.remove(Queue.Connecting,k)
			return true
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ADDCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
function addConnect(ids,ignorePos,autoRemove,done)
	local function removeFromQueue()
		if not autoRemove then
			return
		end

		done(Lang.connecterror)
		removeConnect(ids)
		removeQueue(ids)
	end

	if #Queue.Connecting >= 10 then
		removeFromQueue()
		return false
	end

	if isConnect(ids) then
		removeConnect(ids)
	end

	local pos,data = getQueue(ids,true)
	if not ignorePos and (not pos or pos > 1) then
		removeFromQueue()
		return false
	end

	table.insert(Queue.Connecting,data)
	removeQueue(ids)
	return true
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STEAMIDS
-----------------------------------------------------------------------------------------------------------------------------------------
function steamIds(source)
	return GetPlayerIdentifiers(source)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEDATA
-----------------------------------------------------------------------------------------------------------------------------------------
function updateData(source,ids,deferrals)
	local pos,data = getQueue(ids,true)
	Queue.QueueList[pos].ids = ids
	Queue.QueueList[pos].timeout = 0
	Queue.QueueList[pos].source = source
	Queue.QueueList[pos].deferrals = deferrals
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTFULL
-----------------------------------------------------------------------------------------------------------------------------------------
function notFull(firstJoin)
	local canJoin = Queue.PlayerCount + #Queue.Connecting < maxPlayers and #Queue.Connecting < 10
	if firstJoin and canJoin then
		canJoin = #Queue.QueueList <= 1
	end
	return canJoin
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SETPOSITION
-----------------------------------------------------------------------------------------------------------------------------------------
function setPosition(ids,newPos)
	local pos,data = getQueue(ids,true)
	table.remove(Queue.QueueList,pos)
	table.insert(Queue.QueueList,newPos,data)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSYSTEM
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	local function playerConnect(name,setKickReason,deferrals)
		local source = source
		local ids = steamIds(source)
		local connectTime = os.time()
		local connecting = true

		deferrals.defer()

		Citizen.CreateThread(function()
			while connecting do
				Citizen.Wait(500)
				if not connecting then
					return
				end
				deferrals.update(Lang.connecting)
			end
		end)

		Citizen.Wait(1000)

		local function done(message)
			connecting = false
			Citizen.CreateThread(function()
				if message then
					deferrals.update(tostring(message) and tostring(message) or '')
				end

				Citizen.Wait(1000)

				if message then
					deferrals.done(tostring(message) and tostring(message) or '')
					CancelEvent()
				end
			end)
		end

		local function update(message)
			connecting = false
			deferrals.update(tostring(message) and tostring(message) or '')
		end

		if not ids then
			done(Lang.error)
			CancelEvent()
			return
		end

		if not steamRunning(source) then
			done(Lang.steam)
			CancelEvent()
			return
		end

		local reason = 'Você foi removido da fila.'

		local function setReason(message)
			reason = tostring(message)
		end

		TriggerEvent('Queue:playerJoinQueue',source,setReason)

		if WasEventCanceled() then
			done(reason)

			removeQueue(ids)
			removeConnect(ids)

			CancelEvent()
			return
		end

		local rejoined = false

		if getQueue(ids) then
			rejoined = true
			updateData(source,ids,deferrals)
		else
			addQueue(ids,connectTime,name,source,deferrals)
		end

		if isConnect(ids,false,true) then
			removeConnect(ids)

			if notFull() then
				local added = addConnect(ids,true,true,done)
				if not added then
					CancelEvent()
					return
				end

				done()
				TriggerEvent('Queue:playerConnecting',source,ids,deferrals)

				return
			else
				addQueue(ids,connectTime,name,source,deferrals)
				setPosition(ids,1)
			end
		end

		local pos,data = getQueue(ids,true)

		if not pos or not data then
			done(Lang.error2)
			RemoveFromQueue(ids)
			RemoveFromConnecting(ids)
			CancelEvent()
			return
		end

		if notFull(true) then
			local added = addConnect(ids,true,true,done)
			if not added then
				CancelEvent()
				return
			end

			done()

			TriggerEvent('Queue:playerConnecting',source,ids,deferrals)

			return
		end

		update(string.format(Lang.position,pos,#Queue.QueueList))

		Citizen.CreateThread(function()
			if rejoined then
				return
			end

			Queue.ThreadCount = Queue.ThreadCount + 1
			local dotCount = 0

			while true do
				Citizen.Wait(1000)
				local dots = ''

				dotCount = dotCount + 1
				if dotCount > 3 then
					dotCount = 0
				end

				for i = 1,dotCount do
					dots = dots..'.'
				end

				local pos,data = getQueue(ids,true)

				if not pos or not data then
					if data and data.deferrals then
						data.deferrals.done(Lang.error2)
					end

					CancelEvent()
					removeQueue(ids)
					removeConnect(ids)
					Queue.ThreadCount = Queue.ThreadCount - 1
					return
				end

				if pos <= 1 and notFull() then
					local added = addConnect(ids)
					data.deferrals.update(Lang.join)
					Citizen.Wait(500)

					if not added then
						data.deferrals.done(Lang.connecterror)
						CancelEvent()
						Queue.ThreadCount = Queue.ThreadCount - 1
						return
					end

					data.deferrals.update('Carregando conexão com o servidor.')

					removeQueue(ids)
					Queue.ThreadCount = Queue.ThreadCount - 1

					TriggerEvent('Queue:playerConnecting',data.source,data.ids,data.deferrals)
					
					return
				end

				local message = string.format('DUTH GG\n\n'..Lang.position..'%s.',pos,#Queue.QueueList,dots)
				data.deferrals.update(message)
			end
		end)
	end

	AddEventHandler('playerConnecting',playerConnect)

	local function checkTimeOuts()
		local i = 1

		while i <= #Queue.QueueList do
			local data = Queue.QueueList[i]
			local lastMsg = GetPlayerLastMsg(data.source)

			if lastMsg == 0 or lastMsg >= 30000 then
				data.timeout = data.timeout + 1
			else
				data.timeout = 0
			end

			-- Observar

			if not data.ids or not data.name or not data.firstconnect or data.priority == nil or not data.source then
				data.deferrals.done(Lang.error2)
				table.remove(Queue.QueueList,i)
			elseif (data.timeout >= 120) and os.time() - data.firstconnect > 5 then
				data.deferrals.done(Lang.error2)
				removeQueue(data.source,true)
				removeConnect(data.source,true)
			else
				i = i + 1
			end
		end

		i = 1

		while i <= #Queue.Connecting do
			local data = Queue.Connecting[i]
			local lastMsg = GetPlayerLastMsg(data.source)
			removeQueue(data.source,true)
			removeConnect(data.source,true)
			-- data.timeout = data.timeout + 1

			-- if ((data.timeout >= 300 and lastMsg >= 35000) or data.timeout >= 340) and os.time() - data.firstconnect > 5 then
			-- 	print(data.source..' received timeout')
			-- 	removeQueue(data.source,true)
			-- 	removeConnect(data.source,true)
			-- else
			-- 	i = i + 1
			-- end
		end

		SetTimeout(1000,checkTimeOuts)
	end

	checkTimeOuts()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERCONNECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('Queue:playerConnect')
AddEventHandler('Queue:playerConnect',function()
	local source = source

	if not Queue.PlayerList[source] then
		local ids = steamIds(source)

		Queue.PlayerCount = Queue.PlayerCount + 1
		Queue.PlayerList[source] = true
		removeQueue(ids)
		removeConnect(ids)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERDROPPED
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('playerDropped',function()
	if Queue.PlayerList[source] then
		local ids = steamIds(source)

		Queue.PlayerCount = Queue.PlayerCount - 1
		Queue.PlayerList[source] = nil
		removeQueue(ids)
		removeConnect(ids)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVEQUEUE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('Queue:removeQueue',function(ids)
	removeQueue(ids)
	removeConnect(ids)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- getAllPlayersCount
-----------------------------------------------------------------------------------------------------------------------------------------
function getAllPlayersCount()
    local res = {
        total = 0,
        lobbyP = 0,
        lobbyG = 0,
        games = 0,
        aimLab = 0
    }

    for _, src in ipairs(GetPlayers()) do
        res.total = res.total + 1
        if Player(src) and Player(src).state then
            if Player(src).state.inAimLab then
                res.aimLab = res.aimLab + 1
            end
            if Player(src).state.inGameLobby then
                res.lobbyG = res.lobbyG + 1
            end
            if Player(src).state.inGame then
                res.games = res.games + 1
            end
            if Player(src).state.inLobbyPrincipal then
                res.lobbyP = res.lobbyP + 1
            end
        end
    end

    return res
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("players",function(source,args,rawCmd)
	local user_id = vRP.getUserId(source)

	if not exports["core"]:Group().hasPermission(user_id,"staff") then
		TriggerClientEvent("Notify", source, "inform", "Jogadores conectados: "..GetNumPlayerIndices(), 15000)
	else
        local resCount = getAllPlayersCount()

		if not args[1] then
			TriggerClientEvent("Notify",source,"inform","<b>Contador de Jogadores</b><br><br><b>Total: </b>"..resCount.total.."<br> <b>JOGADORES NA FILA: </b>"..#Queue.QueueList.."<br> <br><b>LOBBY PRINCIPAL: </b>"..resCount.lobbyP.."<br><b>LOBBY PARTIDA: </b>"..resCount.lobbyG.."<br><b>EM PARTIDA: </b>"..resCount.games.."")
		end

		if args[1] == 'ids' then
			local users = vRP.getUsers()
			local players = ""
			for k,v in pairs(users) do
				if k ~= #users then
					players = players.." "
				end
				players = players..k
			end
		
			TriggerClientEvent("Notify",source,"inform","<b>Jogadores conectados</b><br>"..players)
		end
	end
end)

