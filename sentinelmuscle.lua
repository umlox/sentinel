-- Main loader and UI setup.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Advanced Combat Lab", "Ocean")

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

-- Variables
local player = game:GetService("Players").LocalPlayer
local selectedPlayer = nil
local tracking = false
local trackingConnection
local godModeEnabled = false
local autoAttackEnabled = false
local autoTargetEnabled = false
local connection
local followDistance = 3
local smoothness = 0.5
local targetSwitchDelay = 0.1
local attackDelay = 0.2
local tweenDuration = 0.8
local trackingUpdateRate = 0.1
local spoofEnabled = false
local spoofedName = ""
local originalName = player.Name
local nameLabels = {}

-- Letter bypass reference
local bypassLetters = {
    a = "а/ą/ᗩ/α",
    b = "в/в/Ᏼ/β",
    c = "с/ċ/ᑕ/¢",
    d = "ԁ/ď/ᗪ/∂",
    e = "е/ę/є/ε",
    f = "ғ/ƒ/Ƒ/ᖴ",
    g = "ɢ/ġ/Ԍ/ģ",
    h = "һ/ħ/ᕼ/н",
    i = "і/į/Ꭵ/ι",
    j = "ј/ĵ/ᒍ/נ",
    k = "к/ķ/ᛕ/к",
    l = "ʟ/ł/ᒪ/ℓ",
    m = "м/ᗰ/ᘻ/м",
    n = "п/ŋ/ᑎ/η",
    o = "о/ø/Ꮎ/σ",
    p = "р/ρ/ᑭ/ρ",
    q = "ԛ/գ/ᑫ/q",
    r = "г/ŗ/ᖇ/я",
    s = "ѕ/ş/Ꮥ/ѕ",
    t = "т/ț/丅/т",
    u = "ц/ų/ᑌ/υ",
    v = "ν/ṿ/ᐯ/ν",
    w = "ѡ/ŵ/ᗯ/ω",
    x = "х/ẋ/᙭/χ",
    y = "у/ỳ/Ꭹ/у",
    z = "ż/ž/Ꮓ/z"
}

-- Create tabs
local MainTab = Window:NewTab("Main Features")
local TargetTab = Window:NewTab("Target System")
local CombatTab = Window:NewTab("Combat")
local SpooferTab = Window:NewTab("Username Spoofer")
local ChatTab = Window:NewTab("Chat Bypass")

local MainSection = MainTab:NewSection("Character Modifications")
local TargetSection = TargetTab:NewSection("Player Targeting")
local CombatSection = CombatTab:NewSection("Attack Settings")
local SpooferSection = SpooferTab:NewSection("Spoof Settings")
local ChatSection = ChatTab:NewSection("Chat Settings")

-- Enhanced Name Spoofing Function
local function spoofDisplayName()
    local Players = game:GetService("Players")
    
    local function createFakeTag(character)
        local head = character:WaitForChild("Head")
        local existingTag = head:FindFirstChild("NameTag")
        if existingTag then existingTag:Destroy() end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NameTag"
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Adornee = head
        billboard.AlwaysOnTop = true
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Text = spoofedName
        nameLabel.Parent = billboard
        billboard.Parent = head
    end
    
    local function onCharacterAdded(char)
        if spoofEnabled then
            createFakeTag(char)
        end
    end
    
    if player.Character then
        createFakeTag(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)
    
    mt.__index = newcclosure(function(self, key)
        if spoofEnabled then
            if self == player then
                if key == "Name" or key == "DisplayName" then
                    return spoofedName
                end
            end
        end
        return oldIndex(self, key)
    end)
end

-- Bypass chat function
local function getRandomAlternative(letter)
    local options = bypassLetters[letter:lower()]
    if options then
        local choices = {}
        for choice in options:gmatch("[^/]+") do
            table.insert(choices, choice)
        end
        return choices[math.random(#choices)]
    end
    return letter
end

local function convertText(text)
    local result = ""
    for char in text:gmatch(".") do
        result = result .. getRandomAlternative(char)
    end
    return result
end

-- God Mode Function
local function enableGodMode()
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

-- Protection Loop
local function startProtectionLoop()
    connection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.Health = math.huge
        end
    end)
end

-- Auto Attack Function
local function autoAttack()
    spawn(function()
        while autoAttackEnabled do
            local character = player.Character
            local backpack = player:FindFirstChild("Backpack")
            
            if backpack and character then
                local punchInBackpack = backpack:FindFirstChild("Punch")
                if punchInBackpack then
                    punchInBackpack.Parent = character
                end
            end
            
            if character then
                local punchTool = character:FindFirstChild("Punch")
                if punchTool then
                    punchTool:Activate()
                    VirtualUser:Button1Down(Vector2.new())
                    wait(0.1)
                    VirtualUser:Button1Up(Vector2.new())
                end
            end
            
            wait(attackDelay)
        end
    end)
end

-- Move To Target Function
local function moveToTarget(target)
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local playerHumanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    
    if targetRoot and playerRoot and playerHumanoid then
        local startTime = tick()
        
        playerHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        playerHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        playerHumanoid:ChangeState(Enum.HumanoidStateType.Running)
        
        local trackConnection = RunService.Heartbeat:Connect(function()
            if targetRoot and playerRoot and target.Character.Humanoid.Health > 0 then
                playerRoot.Velocity = Vector3.new(0, 0, 0)
                playerRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                playerRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, followDistance))
                
                local playerHead = player.Character:FindFirstChild("Head")
                if playerHead then
                    playerHead.CFrame = CFrame.lookAt(playerHead.Position, targetRoot.Position)
                end
            end
        end)
        
        repeat 
            wait(0.1)
        until not autoTargetEnabled or 
              not target.Character or 
              target.Character.Humanoid.Health <= 0 or
              (tick() - startTime) >= 2
        
        trackConnection:Disconnect()
        wait(targetSwitchDelay)
    end
end

-- Auto Target Function
local function startAutoTarget()
    spawn(function()
        while autoTargetEnabled do
            local players = Players:GetPlayers()
            for _, target in pairs(players) do
                if autoTargetEnabled and target ~= player and 
                   target.Character and 
                   target.Character:FindFirstChild("Humanoid") and
                   target.Character.Humanoid.Health > 0 then
                    
                    selectedPlayer = target
                    moveToTarget(target)
                end
            end
            wait(0.1)
        end
    end)
end

-- UI Controls
MainSection:NewToggle("God Mode", "Toggles invincibility mode", function(state)
    godModeEnabled = state
    if state then
        enableGodMode()
        startProtectionLoop()
    else
        if connection then
            connection:Disconnect()
        end
    end
end)

TargetSection:NewToggle("Auto Target Switch", "Automatically switches targets", function(state)
    autoTargetEnabled = state
    if state then
        startAutoTarget()
    end
end)

CombatSection:NewToggle("Auto Attack", "Automatically uses equipped weapon", function(state)
    autoAttackEnabled = state
    if state then
        autoAttack()
    end
end)

SpooferSection:NewTextBox("Spoofed Name", "Enter the name you want to display", function(txt)
    spoofedName = txt
    if spoofEnabled then
        spoofDisplayName()
    end
end)

SpooferSection:NewToggle("Enable Name Spoofer", "Toggle username spoofing", function(state)
    spoofEnabled = state
    if state then
        if spoofedName == "" then
            spoofedName = "Player_" .. math.random(1000, 9999)
        end
        spoofDisplayName()
    else
        if player.Character then
            local head = player.Character:FindFirstChild("Head")
            if head and head:FindFirstChild("NameTag") then
                head.NameTag:Destroy()
            end
        end
    end
end)

ChatSection:NewTextBox("Convert Text", "Enter text to convert", function(txt)
    local converted = convertText(txt)
    setclipboard(converted)
end)

-- Handle respawning
player.CharacterAdded:Connect(function()
    if godModeEnabled then
        wait(0.5)
        enableGodMode()
        startProtectionLoop()
    end
    if spoofEnabled then
        wait(0.5)
        spoofDisplayName()
    end
end)
-- Add these UI controls to complete the functionality

TargetSection:NewSlider("Follow Distance", "Adjust distance from target", 10, 1, function(value)
    followDistance = value
end)

TargetSection:NewSlider("Movement Speed", "Adjust targeting speed", 20, 1, function(value)
    tweenDuration = 1.2 - (value/20)
end)

SpooferSection:NewButton("Random Name", "Generate random username", function()
    local randomName = "Player_" .. math.random(1000, 9999)
    spoofedName = randomName
    if spoofEnabled then
        spoofDisplayName()
    end
end)

ChatSection:NewButton("Copy Last Converted", "Copy last converted text", function()
    if lastConverted then
        setclipboard(lastConverted)
    end
end)

-- Add these notification functions
local function notify(title, text, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 2
    })
end

-- Add success notifications for each feature
MainSection:NewButton("Reset Character", "Respawn your character", function()
    if player.Character then
        player.Character:BreakJoints()
        notify("Character", "Successfully reset character")
    end
end)

CombatSection:NewSlider("Attack Delay", "Adjust auto attack speed", 20, 1, function(value)
    attackDelay = 0.1 - (value/20)
end)

-- Add these to make the script more robust
game:GetService("RunService").Heartbeat:Connect(function()
    if autoTargetEnabled and selectedPlayer then
        pcall(function()
            moveToTarget(selectedPlayer)
        end)
    end
end)
