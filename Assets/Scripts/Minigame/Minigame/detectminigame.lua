--!Type(Client)

--!SerializeField
local MinigameUI : GameObject = nil

local PlayerManagerScript = require("PlayerManager")


local seatedPlayers = {}

function self:Awake()
    self.gameObject:GetComponent(TapHandler).Tapped:Connect(function()
        PlayerManagerScript.TableCounter()
    end)
end