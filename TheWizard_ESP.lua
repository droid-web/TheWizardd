-- TheWizard - Blox Fruits AutoFarm
-- Compatible JJSploit
-- Clé: TheWizardBest

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Variables
local AutoFarm = false
local AutoQuest = false
local KillAura = false
local AutoStats = false
local BringMobs = false
local FastAttack = false
local SelectedStat = "Melee"
local SelectedQuest = nil

-- Système de clé
local keyOk = false
local keyGui = Instance.new("ScreenGui")
keyGui.Parent = game.CoreGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 280, 0, 130)
keyFrame.Position = UDim2.new(0.5, -140, 0.5, -65)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = keyGui

Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 8)

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 35)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🍊 TheWizard Blox Fruits"
keyTitle.TextColor3 = Color3.fromRGB(255, 150, 50)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 16
keyTitle.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.85, 0, 0, 32)
keyBox.Position = UDim2.new(0.075, 0, 0, 40)
keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "Entrez la clé..."
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.Parent = keyFrame
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.85, 0, 0, 32)
keyBtn.Position = UDim2.new(0.075, 0, 0, 82)
keyBtn.BackgroundColor3 = Color3.fromRGB(255, 130, 50)
keyBtn.BorderSizePixel = 0
keyBtn.Text = "Valider"
keyBtn.TextColor3 = Color3.new(1, 1, 1)
keyBtn.Font = Enum.Font.GothamBold
keyBtn.TextSize = 14
keyBtn.Parent = keyFrame
Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)

keyBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == "TheWizardBest" then
        keyOk = true
        keyGui:Destroy()
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "❌ Mauvaise clé!"
    end
end)

repeat wait() until keyOk

-- GUI Principal
local gui = Instance.new("ScreenGui")
gui.Name = "TheWizardBF"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 320, 0, 400)
main.Position = UDim2.new(0, 15, 0.5, -200)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 130, 50)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 15)
titleFix.Position = UDim2.new(0, 0, 1, -15)
titleFix.BackgroundColor3 = Color3.fromRGB(255, 130, 50)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🍊 TheWizard - Blox Fruits"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = titleBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Mini Button
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 30, 0, 30)
miniBtn.Position = UDim2.new(1, -70, 0, 5)
miniBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
miniBtn.BorderSizePixel = 0
miniBtn.Text = "-"
miniBtn.TextColor3 = Color3.new(1, 1, 1)
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 18
miniBtn.Parent = titleBar
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(main:GetChildren()) do
        if child.Name ~= "Frame" and child ~= titleBar then
            if child:IsA("GuiObject") then
                child.Visible = not minimized
            end
        end
    end
    main.Size = minimized and UDim2.new(0, 320, 0, 40) or UDim2.new(0, 320, 0, 400)
end)

-- Content Frame
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Size = UDim2.new(1, -20, 1, -50)
content.Position = UDim2.new(0, 10, 0, 45)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.CanvasSize = UDim2.new(0, 0, 0, 500)
content.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = content

-- Fonctions UI
local function CreateSection(name)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 25)
    section.BackgroundColor3 = Color3.fromRGB(255, 130, 50)
    section.BorderSizePixel = 0
    section.Parent = content
    Instance.new("UICorner", section).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = section
end

local function CreateToggle(name, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    frame.BorderSizePixel = 0
    frame.Parent = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 55, 0, 25)
    btn.Position = UDim2.new(1, -65, 0.5, -12.5)
    btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = enabled and "ON" or "OFF"
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
        callback(enabled)
    end)
    
    return function(state)
        enabled = state
        btn.Text = enabled and "ON" or "OFF"
        btn.BackgroundColor3 = enabled and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
    end
end

local function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseButton1Click:Connect(callback)
end

local function CreateDropdown(name, options, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    frame.BorderSizePixel = 0
    frame.Parent = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local dropdown = Instance.new("TextButton")
    dropdown.Size = UDim2.new(0.45, 0, 0, 25)
    dropdown.Position = UDim2.new(0.5, 0, 0.5, -12.5)
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dropdown.BorderSizePixel = 0
    dropdown.Text = options[1] or "Select"
    dropdown.TextColor3 = Color3.new(1, 1, 1)
    dropdown.Font = Enum.Font.Gotham
    dropdown.TextSize = 11
    dropdown.Parent = frame
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 6)
    
    local index = 1
    dropdown.MouseButton1Click:Connect(function()
        index = index + 1
        if index > #options then index = 1 end
        dropdown.Text = options[index]
        callback(options[index])
    end)
end

-- Fonctions Blox Fruits
local function GetMobs()
    local mobs = {}
    
    for _, folder in pairs(workspace:GetChildren()) do
        if folder:IsA("Folder") and (folder.Name == "Enemies" or folder.Name == "NPCs") then
            for _, mob in pairs(folder:GetChildren()) do
                if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.Humanoid.Health > 0 then
                        table.insert(mobs, mob)
                    end
                end
            end
        end
    end
    
    -- Alternative search
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            if obj.Humanoid.Health > 0 and obj ~= LocalPlayer.Character then
                local dominated = false
                for _, m in pairs(mobs) do
                    if m == obj then dominated = true break end
                end
                if not dominated and not Players:FindFirstChild(obj.Name) then
                    table.insert(mobs, obj)
                end
            end
        end
    end
    
    return mobs
end

local function GetClosestMob()
    local closest = nil
    local closestDist = math.huge
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = char.HumanoidRootPart.Position
    
    for _, mob in pairs(GetMobs()) do
        local dist = (mob.HumanoidRootPart.Position - myPos).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = mob
        end
    end
    
    return closest, closestDist
end

local function TeleportTo(pos)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function Attack()
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Click attack
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
    
    -- Virtual click
    local vum = game:GetService("VirtualInputManager")
    if vum then
        pcall(function()
            vum:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait()
            vum:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

local function GetQuests()
    local quests = {}
    
    for _, npc in pairs(workspace:GetDescendants()) do
        if npc:IsA("Model") and npc.Name:find("Quest") then
            table.insert(quests, npc.Name)
        end
    end
    
    -- Common quest givers
    local commonQuests = {
        "Bandit Quest", "Monkey Quest", "Gorilla Quest",
        "Pirate Quest", "Brute Quest", "Desert Quest",
        "Snow Quest", "Sky Quest", "Prison Quest"
    }
    
    for _, q in pairs(commonQuests) do
        table.insert(quests, q)
    end
    
    return quests
end

-- UI Creation
CreateSection("⚔️ COMBAT")

CreateToggle("Auto Farm", function(v)
    AutoFarm = v
end)

CreateToggle("Kill Aura", function(v)
    KillAura = v
end)

CreateToggle("Bring Mobs", function(v)
    BringMobs = v
end)

CreateToggle("Fast Attack", function(v)
    FastAttack = v
end)

CreateSection("📋 QUÊTES")

CreateToggle("Auto Quest", function(v)
    AutoQuest = v
end)

CreateButton("Get Quest", function()
    -- Simuler obtention de quête
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local questRemote = remotes:FindFirstChild("StartQuest") or remotes:FindFirstChild("AcceptQuest")
        if questRemote then
            pcall(function()
                questRemote:FireServer()
            end)
        end
    end
end)

CreateSection("📊 STATS")

CreateToggle("Auto Stats", function(v)
    AutoStats = v
end)

CreateDropdown("Stat Type", {"Melee", "Defense", "Sword", "Gun", "Blox Fruit"}, function(v)
    SelectedStat = v
end)

CreateSection("🌍 TÉLÉPORTATION")

local islands = {
    "Starter Island",
    "Jungle",
    "Pirate Village", 
    "Desert",
    "Frozen Village",
    "Marine Fortress",
    "Sky Island",
    "Prison",
    "Magma Village",
    "Underwater City"
}

CreateDropdown("Island", islands, function(v)
    -- Téléportation vers l'île
end)

CreateButton("Téléporter au Mob", function()
    local mob = GetClosestMob()
    if mob then
        TeleportTo(mob.HumanoidRootPart.Position + Vector3.new(0, 5, 0))
    end
end)

CreateButton("Téléporter au Spawn", function()
    TeleportTo(Vector3.new(0, 50, 0))
end)

CreateSection("🍎 FRUITS")

CreateButton("Collect Fruits", function()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or (obj:IsA("Model") and obj.Name:find("Fruit")) then
            local pos = obj:FindFirstChild("Handle") and obj.Handle.Position or obj:GetPivot().Position
            TeleportTo(pos)
            wait(0.5)
        end
    end
end)

CreateButton("Notifier Fruit Spawn", function()
    -- Check for fruits
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find("Fruit") then
            print("Fruit trouvé: " .. obj.Name)
        end
    end
end)

CreateSection("⚙️ AUTRES")

CreateButton("Rejouer", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton("Copier Position", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        print(string.format("Position: %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
    end
end)

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, 0, 0, 40)
info.BackgroundTransparency = 1
info.Text = "TheWizard Blox Fruits v1.0\nClé: TheWizardBest"
info.TextColor3 = Color3.fromRGB(150, 150, 150)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.Parent = content

-- Main Loop
spawn(function()
    while wait() do
        pcall(function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            
            -- Auto Farm
            if AutoFarm then
                local mob, dist = GetClosestMob()
                if mob then
                    -- Téléporter au mob
                    if dist > 15 then
                        char.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    end
                    
                    -- Regarder le mob
                    char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, mob.HumanoidRootPart.Position)
                    
                    -- Attaquer
                    Attack()
                end
            end
            
            -- Kill Aura
            if KillAura then
                for _, mob in pairs(GetMobs()) do
                    if mob:FindFirstChild("Humanoid") then
                        pcall(function()
                            mob.Humanoid.Health = 0
                        end)
                    end
                end
            end
            
            -- Bring Mobs
            if BringMobs then
                for _, mob in pairs(GetMobs()) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        mob.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                    end
                end
            end
            
            -- Fast Attack
            if FastAttack then
                for i = 1, 5 do
                    Attack()
                end
            end
            
            -- Auto Stats
            if AutoStats then
                local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                if remotes then
                    local addStat = remotes:FindFirstChild("AddPoint") or remotes:FindFirstChild("AddStat")
                    if addStat then
                        pcall(function()
                            addStat:FireServer(SelectedStat)
                        end)
                    end
                end
            end
        end)
    end
end)

print("✅ TheWizard Blox Fruits chargé!")
print("🍊 Bon farm!")
