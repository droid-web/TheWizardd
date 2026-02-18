-- TheWizard PF - JJSploit Compatible
-- Clé: TheWizardBest

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Config
local AimbotEnabled = false
local ESPEnabled = false
local FOVSize = 150
local Smoothness = 0.08
local Prediction = 0.15
local AimPart = "Head"
local TeamCheck = true

-- Cache
localPts = {}

-- Clé simple
local keyOk = false
local keyGui = Instance.new("ScreenGui")
keyGui.Parent = game.CoreGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 300, 0, 150)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
keyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = keyGui

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 40)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "TheWizard PF"
keyTitle.TextColor3 = Color3.new(1, 1, 1)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 20
keyTitle.Parent = keyFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 35)
keyBox.Position = UDim2.new(0.1, 0, 0, 50)
keyBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "Entrez la clé..."
keyBox.TextColor3 = Color3.new(1, 1, 1)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.Parent = keyFrame

local keyBtn = Instance.new("TextButton")
keyBtn.Size = UDim2.new(0.8, 0, 0, 35)
keyBtn.Position = UDim2.new(0.1, 0, 0, 95)
keyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
keyBtn.BorderSizePixel = 0
keyBtn.Text = "Valider"
keyBtn.TextColor3 = Color3.new(1, 1, 1)
keyBtn.Font = Enum.Font.GothamBold
keyBtn.TextSize = 14
keyBtn.Parent = keyFrame

keyBtn.MouseButton1Click:Connect(function()
    if keyBox.Text == "TheWizardBest" then
        keyOk = true
        keyGui:Destroy()
    else
        keyBox.Text = ""
        keyBox.PlaceholderText = "Mauvaise clé!"
    end
end)

repeat wait() until keyOk

-- GUI Principal
local gui = Instance.new("ScreenGui")
gui.Name = "TheWizardPF"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 250, 0, 320)
main.Position = UDim2.new(0, 20, 0.5, -160)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
title.BorderSizePixel = 0
title.Text = "TheWizard PF"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local function CreateToggle(name, y, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 30)
    frame.Position = UDim2.new(0.05, 0, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = main
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(1, -55, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    btn.BorderSizePixel = 0
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        callback(state)
    end)
    
    return btn
end

local function CreateSlider(name, y, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 45)
    frame.Position = UDim2.new(0.05, 0, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = main
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = "  " .. name .. ": " .. default
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0.9, 0, 0, 8)
    bar.Position = UDim2.new(0.05, 0, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    
    local dragging = false
    
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouse = UserInputService:GetMouseLocation()
            local rel = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            label.Text = "  " .. name .. ": " .. val
            callback(val)
        end
    end)
end

-- Toggles
CreateToggle("Aimbot [CLIC DROIT]", 45, false, function(v) AimbotEnabled = v end)
CreateToggle("ESP", 80, false, function(v) ESPEnabled = v end)
CreateToggle("Team Check", 115, true, function(v) TeamCheck = v end)

-- Sliders
CreateSlider("FOV", 150, 50, 300, 150, function(v) FOVSize = v end)
CreateSlider("Vitesse", 200, 1, 20, 8, function(v) Smoothness = v / 100 end)
CreateSlider("Prédiction", 250, 10, 25, 15, function(v) Prediction = v / 100 end)

-- Info
local info = Instance.new("TextLabel")
info.Size = UDim2.new(0.9, 0, 0, 20)
info.Position = UDim2.new(0.05, 0, 0, 295)
info.BackgroundTransparency = 1
info.Text = "Clic droit = Aimbot"
info.TextColor3 = Color3.fromRGB(150, 150, 150)
info.Font = Enum.Font.Gotham
info.TextSize = 11
info.Parent = main

-- FOV Circle
local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOV"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Parent = gui

local fovImage = Instance.new("ImageLabel")
fovImage.Size = UDim2.new(1, 0, 1, 0)
fovImage.BackgroundTransparency = 1
fovImage.Image = "rbxassetid://3570695787"
fovImage.ImageColor3 = Color3.new(1, 1, 1)
fovImage.ImageTransparency = 0.5
fovImage.Parent = fovCircle

-- Functions
local function GetAllEnemies()
    local enemies = {}
    
    -- Méthode 1: Players directs
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                continue
            end
            
            local char = plr.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                local head = char:FindFirstChild("Head")
                
                if hum and root and head and hum.Health > 0 then
                    table.insert(enemies, {
                        name = plr.Name,
                        char = char,
                        hum = hum,
                        root = root,
                        head = head
                    })
                end
            end
        end
    end
    
    -- Méthode 2: Workspace Characters (PF specific)
    if workspace:FindFirstChild("Characters") then
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char.Name ~= LocalPlayer.Name then
                local dominated = false
                for _, e in pairs(enemies) do
                    if e.name == char.Name then dominated = true break end
                end
                
                if not dominated then
                    local plr = Players:FindFirstChild(char.Name)
                    if TeamCheck and plr and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                        continue
                    end
                    
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                    local head = char:FindFirstChild("Head")
                    
                    if hum and root and head and hum.Health > 0 then
                        table.insert(enemies, {
                            name = char.Name,
                            char = char,
                            hum = hum,
                            root = root,
                            head = head
                        })
                    end
                end
            end
        end
    end
    
    -- Méthode 3: Scan workspace pour modèles avec Humanoid
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name ~= LocalPlayer.Name then
            local dominated = false
            for _, e in pairs(enemies) do
                if e.name == obj.Name then dominated = true break end
            end
            
            if not dominated then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
                local head = obj:FindFirstChild("Head")
                
                if hum and root and head and hum.Health > 0 then
                    local plr = Players:FindFirstChild(obj.Name)
                    if TeamCheck and plr and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
                        continue
                    end
                    
                    table.insert(enemies, {
                        name = obj.Name,
                        char = obj,
                        hum = hum,
                        root = root,
                        head = head
                    })
                end
            end
        end
    end
    
    return enemies
end

local function GetClosestEnemy()
    local closest = nil
    local closestDist = FOVSize
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    
    for _, enemy in pairs(GetAllEnemies()) do
        local part = AimPart == "Head" and enemy.head or enemy.root
        
        -- Prédiction
        local vel = enemy.root.Velocity
        local predicted = part.Position + (vel * Prediction)
        
        local screen, onScreen = Camera:WorldToViewportPoint(predicted)
        
        if onScreen then
            local dist = math.sqrt((screen.X - cx)^2 + (screen.Y - cy)^2)
            
            if dist < closestDist then
                closestDist = dist
                closest = {
                    enemy = enemy,
                    screen = Vector2.new(screen.X, screen.Y),
                    predicted = predicted
                }
            end
        end
    end
    
    return closest
end

local function UpdateESP()
    -- Supprimer anciens ESP
    for name, bb in pairs(Pts) do
        if bb and bb.Parent then
            bb.Enabled = false
        end
    end
    
    if not ESPEnabled then return end
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar:FindFirstChild("Torso"))
    
    for _, enemy in pairs(GetAllEnemies()) do
        local name = enemy.name
        
        -- Créer ESP si inexistant
        if not Pts[name] or not Pts[name].Parent then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 120, 0, 45)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = game.CoreGui
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "Name"
            nameLabel.Size = UDim2.new(1, 0, 0, 15)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.Parent = bb
            
            local hpBg = Instance.new("Frame")
            hpBg.Name = "HpBg"
            hpBg.Size = UDim2.new(0.8, 0, 0, 5)
            hpBg.Position = UDim2.new(0.1, 0, 0, 17)
            hpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            hpBg.BorderSizePixel = 0
            hpBg.Parent = bb
            
            local hpFill = Instance.new("Frame")
            hpFill.Name = "HpFill"
            hpFill.Size = UDim2.new(1, 0, 1, 0)
            hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            hpFill.BorderSizePixel = 0
            hpFill.Parent = hpBg
            
            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "Dist"
            distLabel.Size = UDim2.new(1, 0, 0, 12)
            distLabel.Position = UDim2.new(0, 0, 0, 25)
            distLabel.BackgroundTransparency = 1
            distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            distLabel.TextStrokeTransparency = 0
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextSize = 10
            distLabel.Parent = bb
            
            Pts[name] = bb
        end
        
        local bb = Pts[name]
        bb.Adornee = enemy.root
        bb.Enabled = true
        
        -- Update nom
        local nameLabel = bb:FindFirstChild("Name")
        if nameLabel then
            nameLabel.Text = name
        end
        
        -- Update HP
        local hpBg = bb:FindFirstChild("HpBg")
        if hpBg then
            local hpFill = hpBg:FindFirstChild("HpFill")
            if hpFill then
                local pct = enemy.hum.Health / enemy.hum.MaxHealth
                hpFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
                
                if pct > 0.6 then
                    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif pct > 0.3 then
                    hpFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    hpFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end
        
        -- Update distance
        local distLabel = bb:FindFirstChild("Dist")
        if distLabel and myRoot then
            local dist = (myRoot.Position - enemy.root.Position).Magnitude
            distLabel.Text = math.floor(dist) .. "m"
        end
    end
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    
    -- Update FOV circle
    fovCircle.Position = UDim2.new(0, cx, 0, cy)
    fovCircle.Size = UDim2.new(0, FOVSize * 2, 0, FOVSize * 2)
    fovCircle.Visible = AimbotEnabled
    fovImage.ImageColor3 = Color3.new(1, 1, 1)
    
    -- Aimbot
    if AimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestEnemy()
        
        if target then
            fovImage.ImageColor3 = Color3.fromRGB(0, 255, 0)
            
            local dx = target.screen.X - cx
            local dy = target.screen.Y - cy
            
            -- Smooth aim
            local aimX = dx * Smoothness
            local aimY = dy * Smoothness
            
            Camera.CFrame = Camera.CFrame * CFrame.Angles(
                math.rad(-aimY),
                math.rad(-aimX),
                0
            )
        end
    end
    
    -- ESP
    UpdateESP()
end)

print("TheWizard PF chargé! Clic droit = Aimbot")
