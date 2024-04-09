Ranks = {}
local userRank = {}

src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
uiApi = Tunnel.getInterface("ui")
-----------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------
local rankingCache = {}
-----------------------------------------------------------------------------------------
-- getRankByLevel - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getRankByLevel(user_level)
    local resRank = nil

    for key, item in pairs(Config.ranking) do
        if (user_level >= item.level) then
            resRank = item.name
        end
    end

    return resRank
end
-----------------------------------------------------------------------------------------
-- getInformation - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getInformation(user_id)
    Ranks.loadRankData(user_id)
    return userRank[user_id]
end
-----------------------------------------------------------------------------------------
-- getNextRankInfo - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getNextRankInfo(user_level)
    local nextRankIndex = nil
    local nextRankPercentage = 0
    local rank = Ranks.getRankByLevel(user_level)

    for key, item in pairs(Config.ranking) do
        if user_level >= item.level then
            nextRankIndex = key + 1
        end
    end

    if nextRankIndex and nextRankIndex <= #Config.ranking then
        local currentRank = Config.ranking[nextRankIndex - 1]
        local nextRank = Config.ranking[nextRankIndex]

        local currentLevel = currentRank.level
        local nextLevel = nextRank.level

        local currentPercentage = (user_level - currentLevel) / (nextLevel - currentLevel) * 100
        nextRankPercentage = math.floor(currentPercentage)

        return rank, nextRankPercentage, nextRank.name
    else
        -- Caso não haja próximo rank disponível, você pode retornar valores padrão ou indicar a ausência.
        return rank, 100, "Sem próximo rank"
    end
end
-----------------------------------------------------------------------------------------
-- loadRankData - Funciton
-----------------------------------------------------------------------------------------
function Ranks.loadRankData(playerSource, user_id)
	local atualRank, nextRankPercentage, nextRankName = Ranks.getNextRankInfo(Player(playerSource).state["pontos"])
    if Player(playerSource).state["pontos"] ~= nil and tonumber(Player(playerSource).state["pontos"]) > 0 then
        uiApi.BuildUI(playerSource, "FinishGame", {
            open = false,
            setRank = true,
            RankSubTitle = ""..atualRank.." / "..nextRankName.."",
            RankProgressBar = nextRankPercentage
        })
    else
        uiApi.BuildUI(playerSource, "FinishGame", {
            open = false,
            setRank = true,
            RankSubTitle = "NEGATIVO",
            RankProgressBar = nextRankPercentage
        })
    end
	
    local rank = Ranks.getRankByLevel(Player(playerSource).state["pontos"])
    userRank[user_id] = { rank = rank }
end
-----------------------------------------------------------------------------------------
-- calculateFinalScore - Funciton
-----------------------------------------------------------------------------------------
function calculateFinalScore(playerId, playerSource, playerName, finalPosition, numKills, numDeaths)
    -- pontuação ganha por posição
    local positionScore = 8

    -- fator de ajuste baseado no número de abates
    local killAdjustmentFactor = 1 / math.max(1, math.sqrt(numKills))

    -- pontuação ganha por eliminação, com ajuste baseado no número de abates
    local killScore = numKills * (10 * killAdjustmentFactor)

    -- pontuação perdida por morte, aumentando a cada 10 posições
    local deathScore = numDeaths * (5 + (10 - finalPosition/10) * 5)

    -- ganho ou perda aleatória de pontos
    local randomScore = math.random(-50, 50)

    -- pontuação final com ganho ou perda aleatória de pontos
    local finalScore = 0
    local result = ""

    if finalPosition < Config.avgPosition then
        -- jogador está acima da posição média e deve ganhar pontos
        finalScore = positionScore + killScore - deathScore + randomScore
        result = "ganhou"
    elseif finalPosition > Config.avgPosition then
        -- jogador está abaixo da posição média e deve perder pontos
        finalScore = -positionScore + killScore - (deathScore * killAdjustmentFactor) + randomScore
        result = "perdeu"
    else
        -- jogador está na posição média e não ganha nem perde pontos
        finalScore = killScore - deathScore + randomScore
        result = "empatou"
    end

    if result == "perdeu" then
        if Player(playerSource) and Player(playerSource).state and Player(playerSource).state["pontos"] and Player(playerSource).state["pontos"] > 0 then
            local remainingPoints = Player(playerSource).state["pontos"] - math.abs(finalScore)
            Player(playerSource).state["pontos"] = math.max(0, remainingPoints)
        else
            result = "Sem pontos pra perder"
        end
    elseif result == "ganhou" then
        if Player(playerSource) and Player(playerSource).state then
            Player(playerSource).state["pontos"] = (Player(playerSource).state["pontos"] or 0) + finalScore
        end
    end

    local duthPoints = math.random(0, 25)
    Player(playerSource).state.duthPoints = (Player(playerSource).state.duthPoints or 0) + duthPoints
    
    return { result = result, points = finalScore }
end
-----------------------------------------------------------------------------------------
-- Ranks - Exports
-----------------------------------------------------------------------------------------
exports("Ranks",function()
    return Ranks
end)