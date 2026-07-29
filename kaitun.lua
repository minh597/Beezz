local Config = getgenv().Config or {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local function ClaimCode(code)
    ReplicatedStorage.Nodes.Network.NetworkEvents._updateNode:FireServer(
        {Type = "Post"},
        "CLAIM_CODE_RequestNODE",
        1,
        code
    )
end
local function RedeemCodes()
    local html = game:HttpGet(
        "https://www.eurogamer.net/anime-expeditions-codes"
    )

    local all = {}

    for code in html:gmatch("<strong>(.-)</strong>") do
        table.insert(all, code)
    end

    for i = 4, #all do
        ClaimCode(all[i])
        task.wait(1.5)
    end
end


if Config.RedeemCode then
    RedeemCodes()
end


local function ParseChallenge(value)
    local Type, Index = value:match("(%a+)(%d+)")

    if not Type or not Index then
        warn("Invalid challenge format:", value)
        return
    end

    return Type, tonumber(Index)
end


local function GetChallengeStatus(Type, Index)

    local ChallengeInfo = require(
        ReplicatedStorage.Shared.Information.ChallengeInfo
    )

    local Dependencies = require(
        ReplicatedStorage.FusionPackage.Dependencies
    )

    local Data = Dependencies.PlayerData
        ._EXTREMELY_DANGEROUS_usedAsValue
        .ChallengeData


    local attemptsTable =
        Data.DailyClearHistory[Type] or {}

    local clearTable =
        Data.ClearHistory[Type] or {}


    local attempts = ChallengeInfo:GetDailyAttemptsLeft(
        attemptsTable,
        Type,
        tostring(Index),
        ChallengeInfo
    )


    local ready = ChallengeInfo:IsChallengeAvailable(
        clearTable,
        attemptsTable,
        Type,
        tostring(Index),
        ChallengeInfo
    )


    return ready, attempts
end



local function getChallengeData()

    local Dependencies = require(
        ReplicatedStorage.FusionPackage.Dependencies
    )

    local raw = Dependencies.ChallengeData
        ._EXTREMELY_DANGEROUS_usedAsValue


    local result = {
        Daily = {},
        Weekly = {},
        Regular = {}
    }


    local function parse(list, target, addIndex)

        for i, data in ipairs(list or {}) do

            local item = {
                MapName = data.MapName,
                ActName = data.ActName
            }

            if addIndex then
                item.Index = i
            end

            table.insert(target, item)
        end
    end


    parse(raw.Daily, result.Daily)
    parse(raw.Weekly, result.Weekly)
    parse(raw.Regular, result.Regular, true)


    writefile(
        "ChallengeData.json",
        HttpService:JSONEncode(result)
    )


    return result
end



local function RequestMatchmaking(Type, Index)

    if not isfile("ChallengeData.json") then
        print("Creating ChallengeData.json...")
        getChallengeData()
    end


    local data = HttpService:JSONDecode(
        readfile("ChallengeData.json")
    )


    local challenge = data[Type][Index]


    if not challenge then
        warn(
            "Challenge data not found:",
            Type,
            Index
        )
        return
    end


    ReplicatedStorage.Nodes.Network.NetworkEvents._updateNode:FireServer(
        {
            Type = "Post"
        },
        "REQUEST_ENTER_MATCHMAKING_RequestNODE",
        1,
        {
            Difficulty = "Hard",
            ChallengeIndex = challenge.Index or Index,
            ActName = challenge.ActName,
            Gamemode = "Challenge",
            MapName = challenge.MapName,
            ChallengeType = Type
        }
    )
end



local function AutoChallenge()

    if not Config.AutoChallenge then
        return
    end


    for _, challenge in ipairs(Config.Challenge) do

        local Type, Index = ParseChallenge(challenge)

        if Type then

            local ready, attempts =
                GetChallengeStatus(Type, Index)


            print(
                Type,
                Index,
                "| Attempts:",
                attempts,
                "| Ready:",
                ready
            )


            if Config.MatchMaking
            and ready
            and attempts > 0 then

                print(
                    "Entering challenge:",
                    Type,
                    Index
                )


                RequestMatchmaking(
                    Type,
                    Index
                )


                task.wait(2)
            end
        end
    end
end



AutoChallenge()
