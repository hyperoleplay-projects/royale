-----------------------------------------------------------------------------------------
-- extractSteam - Funciton
-----------------------------------------------------------------------------------------
local function extractSteam(src)
    local identifiers = {
        steam = "",
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id,"steam") then
            identifiers.steam = id
        end
    end
    return identifiers
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- Pvp - Command
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("pvp", function(source, args, rawCmd) 
    local user_id = vRP.getUserId(source)
    if not exports["core"]:Group().hasAccessOrHigher(user_id,"dev") then
        return
    end
    
    local nsource = vRP.getUserSource(parseInt(args[2]))
    local nidentity = vRP.getIdentity(parseInt(args[2]))
    
    if args[1] == "remove" then
        if args[3] == "game" then
            if nsource then
                local gameId = parseInt(args[4])
                LeaveGame({
                    source = nsource,
                    user_id = parseInt(args[2]),
                    username = nidentity.username,
                    isLeader = false,
                    ready = false,
                    pos = 0,
                    state = false,
                }, gameId)
            end
        end
    end

    if args[1] == "status" then
        if args[2] == "game" then
            SetStatusGames(source)
        end
    end

    if args[1] == "remove" then
        if args[3] == "team" then
            if nsource then
                local player = Player(nsource)
                local leaveData = {
                    source = nsource,
                    user_id = parseInt(args[2]),
                    username = nidentity.username,
                    avatar = player.state.userData['avatar'],
                    isLeader = true,
                    currentCharacterMode = vRP.getUData(parseInt(args[2]), "Barbershop"),
                    Clothes = vRP.getUData(parseInt(args[2]), "Clothings"),
                    Tatuagens = Player(nsource).state.userTatuagens,
                    ready = false,
                    pos = 0,
                    state = false,
                }
                LeaveTeam(leaveData, Player(nsource).state.teamCode)

                local newTeamCode = generateStringNumber("LLLD")
                CreateTeam(nsource, parseInt(args[2]), newTeamCode)
                player.state.ready = true
                
                local infos = extractSteam(nsource)
                local steamHex = infos.steam:gsub("steam:", "")
        
                local joinData = {
                    source = nsource,
                    user_id = parseInt(args[2]),
                    username = nidentity.username,
                    avatar = player.state.userData['avatar'],
                    isLeader = true,
                    currentCharacterMode = vRP.getUData(parseInt(args[2]), "Barbershop"),
                    Clothes = vRP.getUData(parseInt(args[2]), "Clothings"),
                    Tatuagens = Player(nsource).state.userTatuagens,
                    ready = true,
                    pos = 0,
                    state = true,
                    hexlast = steamHex,
                    death = false,
                    agonizing = false,
                    color = nil,
                    positionGame = 0,
                }

                JoinTeam(joinData, newTeamCode)
            end
        end
    end

    if args[1] == "players" then
        if args[3] == "game" then
            local gameId = parseInt(args[4])
            SetPlayersGame(gameId, parseInt(args[5]))
        end
    end
    
    if args[1] == "team" then
        if args[3] == "id" then
            TriggerClientEvent("Notify", source, "sucesso", "Codigo do time do jogador informado: <b>"..Player(nsource).state.teamCode.."</b>", 15000, "normal", "Admin")
        end
    end
    if args[1] == "team" then
        if args[3] == "players" then
            if nsource then
                local players = GetPlayersTeam(Player(nsource).state.teamCode)
                TriggerClientEvent("Notify", source, "sucesso", "Jogadores do time do jogador informado: <b>"..players.."</b>", 15000, "normal", "Admin")
            end
        end
    end
end)


-- pvp add 1 game 1
-- pvp remove 1 game 1
-- pvp remove 1 team
-- pvp players 1 game 1 1
-- pvp team 1 id
-- pvp team 1 players
-- pvp status game