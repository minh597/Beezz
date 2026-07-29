local Config = getgenv().Config or {}

local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Remote = RS.Nodes.Network.NetworkEvents._updateNode


function getChallengeData()
    local Dependencies = require(
        RS.FusionPackage.Dependencies
    )

    local raw = Dependencies.ChallengeData
        ._EXTREMELY_DANGEROUS_usedAsValue

    local result = {
        Daily = {},
        Weekly = {},
        Regular = {}
    }

    for _, typeName in ipairs({"Daily","Weekly","Regular"}) do
        for i, v in ipairs(raw[typeName] or {}) do
            table.insert(result[typeName], {
                MapName = v.MapName,
                ActName = v.ActName,
                Index = i
            })
        end
    end

    writefile(
        "ChallengeData.json",
        HttpService:JSONEncode(result)
    )

    return result
end


function RequestMatchmaking(data, typeName, index)
    local challenge = data[typeName][index]

    if not challenge then return end

    Remote:FireServer(
        {Type = "Post"},
        "REQUEST_ENTER_MATCHMAKING_RequestNODE",
        1,
        {
            Difficulty = "Hard",
            ChallengeIndex = challenge.Index,
            ActName = challenge.ActName,
            Gamemode = "Challenge",
            MapName = challenge.MapName,
            ChallengeType = typeName
        }
    )
end


function AutoChallenge()
    local data = getChallengeData()

    local choose = Config.Challenge

    if choose == "All" then
        for typeName, list in pairs(data) do
            for i = 1, #list do
                RequestMatchmaking(data, typeName, i)
                task.wait(1)
            end
        end
        return
    end


    if choose == "Daily" or choose == "Weekly" then
        RequestMatchmaking(data, choose, 1)
        return
    end


    local index = tonumber(
        choose:match("%d+")
    )

    if choose:find("Regular") and index then
        RequestMatchmaking(data, "Regular", index)
    end
end


if Config.AutoChallenge and Config.Matchmaking then
    AutoChallenge()
end
