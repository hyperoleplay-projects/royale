Ranks = {}
local userRank = {}

src = {}
Tunnel.bindInterface(GetCurrentResourceName(),src)
-----------------------------------------------------------------------------------------
-- VARIBLES
-----------------------------------------------------------------------------------------
local rankingCache = {}
-----------------------------------------------------------------------------------------
-- getRankByLevel - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getRankByLevel(user_level)
    local resRank = nil

    for key, item in ipairs(Config.ranking) do
        if user_level < item.level then
            break
        end
        resRank = item.name
    end

    return resRank
end
-----------------------------------------------------------------------------------------
-- getNextRankXp - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getNextRankXp(user_level)
    local nextRankIndex = nil

    for key, item in pairs(Config.ranking) do
        if user_level >= item.level then
            nextRankIndex = key + 1
        end
    end

    if nextRankIndex then
        return Config.ranking[nextRankIndex].level
    else
        return 0
    end
end
-----------------------------------------------------------------------------------------
-- getInformation - Funciton
-----------------------------------------------------------------------------------------
function Ranks.getInformation(points)
    local rank = Ranks.getRankByLevel(points)
    return rank
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
-- giveXp - Function
-----------------------------------------------------------------------------------------
function Ranks.GivePoints(user_id, points, type)
    if userRank[user_id] then 
        if type == "ganhou" then
            userRank[user_id].pontos = parseInt(userRank[user_id].pontos + points)
        elseif type == "perdeu" then
            userRank[user_id].pontos = parseInt(userRank[user_id].pontos - points)
        end
    end
end
-----------------------------------------------------------------------------------------
-- Ranks - Exports
-----------------------------------------------------------------------------------------
exports("Ranks",function()
    return Ranks
end)