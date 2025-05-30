--!Type(UI)

--!Bind
local _button : VisualElement = nil

--!Bind
local _armWrestling : UISlider = nil

--!Bind
local _leaderboardHeader : VisualElement = nil

--!Bind
local _minigameScore : Label = nil

local MinDotRange = 0
local MaxDotRange = 100
local direction = 1
local speed = 75

local placeTargets = false

local targets = {}

score = 0

wins = 0

local PlayerManagerScript = require("PlayerManager")

function Initialize()
    score = 0

    -- Set slider range max value and min value
    _armWrestling.highValue = MaxDotRange
    _armWrestling.lowValue = MinDotRange

    -- Starting knob value
    _armWrestling.value = MinDotRange
    _minigameScore.text = "Score: 0"

    -- Set slider range to variable
    Timer.After(0.1, function() -- Makes sure doesn't skip over setting _armWrestling width first
        sliderWidth = _armWrestling.layout.width
        print("Slider set to: " .. sliderWidth)
    end)
end

function UpdateScoreLabel()
    _minigameScore.text = "First to 12 wins! Score: " .. tostring(score) -- Updates score text

    if score >= 12 then -- Checks for win and lists winner counter on leaderboard
        wins = wins + 1
        local playerLabel = Label.new()
        playerLabel.text = client.localPlayer.name .. ": " .. wins .. " wins"
        print(client.localPlayer.name .. ": " .. wins .. " wins")
        playerLabel:AddToClassList("leaderboard-entry")
        _leaderboardHeader:Add(playerLabel)

        PlayerManagerScript.WinCheck(client.localPlayer)
    end
end

function CreateTarget()
    local _target = VisualElement.new()

    local targetType = math.random(1, 2) -- Depending on number, generates target with variation in width and score value

    local randomValue = math.random(MinDotRange, MaxDotRange) -- Generate a random target position

    local targetData = {
        visual = _target,
        hit = false,
        value = randomValue
    }

    if targetType == 1 then
        _target:AddToClassList("target-red")
        targetData.score = 1
    else
        _target:AddToClassList("target-green")
        targetData.score = 3
    end

    return targetData
end

function PlaceTarget()
    local _targetData = CreateTarget()

    local percentage = _targetData.value / MaxDotRange

    _targetData.visual.style.left = sliderWidth * percentage -- Randomly places target along slider range
    _armWrestling:Add(_targetData.visual)

    table.insert(targets, _targetData)
end

function self:OnEnable()
    speed = 75
    Initialize()
    UpdateScoreLabel()
end


function self:Update()
    _armWrestling.value = _armWrestling.value + direction * speed * Time.deltaTime -- Automatically move knob speed

    -- If knob reaches max or min range of slider range, knob moves other direction
    if _armWrestling.value >= MaxDotRange then
        _armWrestling.value = MaxDotRange
        direction = -1
    elseif _armWrestling.value <= MinDotRange then
        _armWrestling.value = MinDotRange
        direction = 1
    end

    _armWrestling:RegisterCallback(IntChangeEvent, OnSliderChanged)

    if not placeTargets then -- Initial set of targets on slider range
        Timer.After(0.1, function() -- Timer checks for potential skips
            PlaceTarget()
            PlaceTarget()
        placeTargets = true
        end)
    end
end

function OnSliderChanged(event) -- Makes sure that knob's movement is tracked by DotPosition
    DotPosition = _armWrestling.value
end

_button:RegisterPressCallback(function()
    local targetHit = false
    
    -- Compares slider dot value with target position value and checks if they are close enough to warrant a hit
    for _, target in ipairs(targets) do
        if not target.hit and math.abs(target.value - _armWrestling.value) < 4 then
            target.hit = true

            score = score + target.score
            UpdateScoreLabel()

            print("Target hit and removed at value: " .. target.value)
            _armWrestling:Remove(target.visual)
            targetHit = true
            break
        end
    end

    if targetHit then -- Removes all other existing targets and places 2 new targets
        for _, target in ipairs(targets) do
            _armWrestling:Remove(target.visual)
        end
        targets = {}

        PlaceTarget()
        PlaceTarget()
    end 
end)

