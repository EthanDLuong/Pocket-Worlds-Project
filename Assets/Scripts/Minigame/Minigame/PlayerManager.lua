--!Type(Module)

--!SerializeField
local MinigameUI : GameObject = nil

addWinsRequest = Event.new("AddWinsRequest")
addTableRequest = Event.new("AddTableRequest")
startMinigame = Event.new("StartMinigame")
stopMinigame = Event.new("StopMinigame")
checkWinRequest = Event.new("CheckWinRequest")
updateLeaderboard = Event.new("UpdateLeaderboard")

players = {}
local tableCounter = 0

local seatedPlayers = {}

local leaderboardData = {}

function AddWins(seatedPlayers)
    addWinsRequest:FireServer()
end

function TableCounter()
    addTableRequest:FireServer()
end

function WinCheck(winner)
    checkWinRequest:FireServer()
end

function GetPlayerInfo(player)
    return players[player]
end

local function TrackPlayers(game, characterCallback)
    scene.PlayerJoined:Connect(function(scene, player)
        players[player] = { -- Tracks player stats
            player = player,
            winsCounter = IntValue.new("Total Wins: " .. tostring(player.id), 0),
            won = BoolValue.new("HasWon", false)
        }
    
        player.CharacterChanged:Connect(function(player, character)
            local playerinfo = players[player]
            if (character == nil) then
                return
            end

            if characterCallback then
                characterCallback(playerinfo)
            end
        end)
    end)

    scene.PlayerLeft:Connect(function(player)
        players[player] = nil
    end)
end

function self:ClientAwake()
    
    function OnCharacterInstantiate(playerinfo)
        local player = playerinfo.player
        local character = player.character -- could be good for adjusting the player character to pose

        playerinfo.winsCounter.Changed:Connect(function(newVal, oldVal)
            print(player.name .. "Total Wins: " .. tostring(newVal))
            character.renderScale = Vector3.new(newVal, newVal, 1)
        end)
    end

    startMinigame:Connect(function(seatedPlayers)
        for _, player in pairs(seatedPlayers) do 
            playerInfo = players[player]
            playerInfo.won.value = false -- Resets win check so game doesn't automatically end
            MinigameUI:SetActive(true)
            print(player.name .. " is now arm wrestling!")
        end
    end)

    stopMinigame:Connect(function(seatedPlayers)
        for _, player in pairs(seatedPlayers) do
            MinigameUI:SetActive(false)
        end
    end)

    TrackPlayers(OnCharacterInstantiate)

end

function self:ServerAwake()
    TrackPlayers()

    addTableRequest:Connect(function(player) -- Adds players to chair array. Makes sure that players and chairs are unique before staring game
        for _, p in pairs(seatedPlayers) do
            if p == player then
                return
            end
        end

        table.insert(seatedPlayers, player)

        print(player.name .. " has sat down and is " .. tostring(#seatedPlayers))

        if #seatedPlayers >= 2 then
            startMinigame:FireAllClients(seatedPlayers)
        end
    end)

    checkWinRequest:Connect(function(winner)
        for _, player in pairs(seatedPlayers) do
            playerInfo = players[player]
            if winner == player then
                playerInfo.won.value = true
                playerInfo.winsCounter.value = playerInfo.winsCounter.value + 1
                print(player.name .. " now has " .. playerInfo.winsCounter.value  .. " total wins.")
            else
                playerInfo.won.value = false
                print(player.name .. " has lost.")
            end
        end

        for player, playerInfo in pairs(players) do
            table.insert(leaderboardData, {
                name = player.name,
                wins = playerInfo.winsCounter.value
            })
        end

        updateLeaderboard:FireAllClients(leaderboardData) 

        stopMinigame:FireAllClients(seatedPlayers)

        Timer.After(0.1, function() -- Makes sure seatedPlayers is fully used before resetting
            seatedPlayers = {}
        end)
    end)
end