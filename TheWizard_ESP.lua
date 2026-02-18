local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local conns = {}
local espCache = {}

local cfg = {
    aimbotOn = false,
    espOn = false,
    fovSize = 120,
    smooth = 0.15,
    prediction = 0.165,
    aimPart = "Head",
    teamCheck = true,
    visCheck = true,
    showFov = true,
    showLine = true,
    fovCol = Color3.new(1, 1, 1),
    targetCol = Color3.new(0, 1, 0),
    espCol = Color3.new(1, 0, 0),
    boxOn = true,
    nameOn = true,
    healthOn = true,
    distOn = true,
}

local function GetLocalCharacter()
    local client = LocalPlayer
    if not client then return nil end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == client.Name then
            if obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") then
                return obj
            end
        end
    end
    
    return client.Character
end

local function GetLocalRoot()
    local char = GetLocalCharacter()
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function GetEnemies()
    local enemies = {}
    local myName = LocalPlayer.Name
    local myTeam = LocalPlayer.Team
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name ~= myName then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            local head = obj:FindFirstChild("Head")
            
            if hum and root and head and hum.Health > 0 then
                local plr = Players:FindFirstChild(obj.Name)
                
                if cfg.teamCheck and plr and myTeam then
                    if plr.Team == myTeam then continue end
                end
                
                table.insert(enemies, {
                    model = obj,
                    hum = hum,
                    root = root,
                    head = head,
                    name = obj.Name,
                    player = plr
                })
            end
        end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if cfg.teamCheck and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local dominated = false
        for _, e in pairs(enemies) do
            if e.name == plr.Name then dominated = true break end
        end
        
        if not dominated then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
            local head = char:FindFirstChild("Head")
            
            if hum and root and head and hum.Health > 0 then
                table.insert(enemies, {
                    model = char,
                    hum = hum,
                    root = root,
                    head = head,
                    name = plr.Name,
                    player = plr
                })
            end
        end
    end
    
    return enemies
end

local function IsVisible(origin, target)
    if not cfg.visCheck then return true end
    
    local myChar = GetLocalCharacter()
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {myChar, Camera}
    
    local dir = (target - origin).Unit * 2000
    local result = workspace:Raycast(origin, dir, params)
    
    if result then
        local hit = result.Instance
        if hit:IsDescendantOf(target.Parent) then return true end
        
        for _, e in pairs(GetEnemies()) do
            if hit:IsDescendantOf(e.model) then return true end
        end
        return false
    end
    
    return true
end

local function GetAimTarget(part)
    if part == "Head" then return "Head"
    elseif part == "Torso" then return "HumanoidRootPart"
    else return "HumanoidRootPart" end
end

local function Predict(pos, vel)
    return pos + (vel * cfg.prediction)
end

local function FindBestTarget()
    local best = nil
    local bestDist = cfg.fovSize
    local cx, cy = Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2
    local center = Vector2.new(cx, cy)
    
    for _, enemy in pairs(GetEnemies()) do
        local partName = GetAimTarget(cfg.aimPart)
        local part = enemy.model:FindFirstChild(partName) or enemy.head
        
        if not part then continue end
        
        local vel = enemy.root.Velocity
        local predicted = Predict(part.Position, vel)
        local screen, vis = Camera:WorldToViewportPoint(predicted)
        
        if not vis then continue end
        if not IsVisible(Camera.CFrame.Position, part.Position) then continue end
        
        local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
        
        if dist < bestDist then
            bestDist = dist
            best = {
                enemy = enemy,
                part = part,
                predicted = predicted,
                screen = Vector2.new(screen.X, screen.Y),
                dist = dist
            }
        end
    end
    
    return best
end

local Window = Rayfield:CreateWindow({
    Name = "TheWizard PF",
    LoadingTitle = "TheWizard",
    LoadingSubtitle = "Phantom Forces",
    Theme = "Amethyst",
    ConfigurationSaving = {Enabled = true, FolderName = "TheWizardPF", FileName = "config"},
    KeySystem = true,
    KeySettings = {
        Title = "TheWizard",
        Subtitle = "Clé requise",
        Note = "TheWizardBest",
        FileName = "twkey",
        SaveKey = true,
        Key = {"TheWizardBest"}
    }
})

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "twpf"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 9999
pcall(function() fovGui.Parent = CoreGui end)
if not fovGui.Parent then fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local fovCircle = Instance.new("ImageLabel")
fovCircle.Name = "fov"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://3570695787"
fovCircle.ImageTransparency = 0.5
fovCircle.Parent = fovGui

local targetLine = Instance.new("Frame")
targetLine.Name = "line"
targetLine.AnchorPoint = Vector2.new(0, 0.5)
targetLine.BorderSizePixel = 0
targetLine.Visible = false
targetLine.Parent = fovGui

local targetDot = Instance.new("Frame")
targetDot.Name = "dot"
targetDot.AnchorPoint = Vector2.new(0.5, 0.5)
targetDot.Size = UDim2.new(0, 8, 0, 8)
targetDot.BorderSizePixel = 0
targetDot.Visible = false
targetDot.Parent = fovGui
Instance.new("UICorner", targetDot).CornerRadius = UDim.new(1, 0)

local tab1 = Window:CreateTab("Aimbot", 4483362458)

tab1:CreateToggle({
    Name = "Activer",
    CurrentValue = false,
    Callback = function(v) cfg.aimbotOn = v end,
})

tab1:CreateDropdown({
    Name = "Viser",
    Options = {"Head", "Torso"},
    CurrentOption = {"Head"},
    Callback = function(o) cfg.aimPart = o[1] end,
})

tab1:CreateSlider({
    Name = "FOV",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 120,
    Callback = function(v) cfg.fovSize = v end,
})

tab1:CreateSlider({
    Name = "Vitesse",
    Range = {0.05, 0.5},
    Increment = 0.01,
    CurrentValue = 0.15,
    Callback = function(v) cfg.smooth = v end,
})

tab1:CreateSlider({
    Name = "Prédiction",
    Range = {0.1, 0.3},
    Increment = 0.005,
    CurrentValue = 0.165,
    Callback = function(v) cfg.prediction = v end,
})

tab1:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) cfg.teamCheck = v end,
})

tab1:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Callback = function(v) cfg.visCheck = v end,
})

tab1:CreateToggle({
    Name = "Afficher FOV",
    CurrentValue = true,
    Callback = function(v) cfg.showFov = v end,
})

tab1:CreateToggle({
    Name = "Ligne vers cible",
    CurrentValue = true,
    Callback = function(v) cfg.showLine = v end,
})

tab1:CreateColorPicker({
    Name = "Couleur FOV",
    Color = Color3.new(1, 1, 1),
    Callback = function(c) cfg.fovCol = c end,
})

tab1:CreateColorPicker({
    Name = "Couleur cible",
    Color = Color3.new(0, 1, 0),
    Callback = function(c) cfg.targetCol = c end,
})

local tab2 = Window:CreateTab("ESP", 4483362458)

tab2:CreateToggle({
    Name = "Activer",
    CurrentValue = false,
    Callback = function(v) cfg.espOn = v end,
})

tab2:CreateToggle({
    Name = "Box",
    CurrentValue = true,
    Callback = function(v) cfg.boxOn = v end,
})

tab2:CreateToggle({
    Name = "Nom",
    CurrentValue = true,
    Callback = function(v) cfg.nameOn = v end,
})

tab2:CreateToggle({
    Name = "Santé",
    CurrentValue = true,
    Callback = function(v) cfg.healthOn = v end,
})

tab2:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Callback = function(v) cfg.distOn = v end,
})

tab2:CreateColorPicker({
    Name = "Couleur",
    Color = Color3.new(1, 0, 0),
    Callback = function(c) cfg.espCol = c end,
})

local tab3 = Window:CreateTab("Info", 4483362458)

tab3:CreateParagraph({
    Title = "Comment utiliser",
    Content = "1. Active l'Aimbot\n2. Maintiens CLIC DROIT pour viser\n3. Active l'ESP pour voir les ennemis\n\nConfig recommandée PF:\n- FOV: 100-150\n- Vitesse: 0.12-0.18\n- Prédiction: 0.15-0.18"
})

tab3:CreateButton({
    Name = "Config Sniper",
    Callback = function()
        cfg.fovSize = 80
        cfg.smooth = 0.2
        cfg.prediction = 0.2
        cfg.aimPart = "Head"
        Rayfield:Notify({Title = "Config", Content = "Sniper appliquée", Duration = 2})
    end,
})

tab3:CreateButton({
    Name = "Config Rush",
    Callback = function()
        cfg.fovSize = 150
        cfg.smooth = 0.1
        cfg.prediction = 0.14
        cfg.aimPart = "Torso"
        Rayfield:Notify({Title = "Config", Content = "Rush appliquée", Duration = 2})
    end,
})

tab3:CreateButton({
    Name = "Config Équilibrée",
    Callback = function()
        cfg.fovSize = 120
        cfg.smooth = 0.15
        cfg.prediction = 0.165
        cfg.aimPart = "Head"
        Rayfield:Notify({Title = "Config", Content = "Équilibrée appliquée", Duration = 2})
    end,
})

tab3:CreateButton({
    Name = "Fermer",
    Callback = function()
        for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
        for _, e in pairs(espCache) do pcall(function() e:Destroy() end) end
        pcall(function() fovGui:Destroy() end)
        pcall(function() Rayfield:Destroy() end)
    end,
})

local function UpdateESP()
    for _, e in pairs(espCache) do
        pcall(function() e.Enabled = false end)
    end
    
    if not cfg.espOn then return end
    
    local myRoot = GetLocalRoot()
    
    for _, enemy in pairs(GetEnemies()) do
        local name = enemy.name
        
        if not espCache[name] then
            local bb = Instance.new("BillboardGui")
            bb.Name = name
            bb.Size = UDim2.new(0, 150, 0, 50)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent = CoreGui
            
            local f = Instance.new("Frame")
            f.Size = UDim2.new(1, 0, 1, 0)
            f.BackgroundTransparency = 1
            f.Parent = bb
            
            local n = Instance.new("TextLabel")
            n.Name = "n"
            n.Size = UDim2.new(1, 0, 0, 14)
            n.BackgroundTransparency = 1
            n.TextStrokeTransparency = 0
            n.Font = Enum.Font.GothamBold
            n.TextSize = 13
            n.Parent = f
            
            local hpbg = Instance.new("Frame")
            hpbg.Name = "hpbg"
            hpbg.Size = UDim2.new(0.7, 0, 0, 4)
            hpbg.Position = UDim2.new(0.15, 0, 0, 16)
            hpbg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            hpbg.BorderSizePixel = 0
            hpbg.Parent = f
            
            local hp = Instance.new("Frame")
            hp.Name = "hp"
            hp.Size = UDim2.new(1, 0, 1, 0)
            hp.BorderSizePixel = 0
            hp.Parent = hpbg
            
            local d = Instance.new("TextLabel")
            d.Name = "d"
            d.Size = UDim2.new(1, 0, 0, 12)
            d.Position = UDim2.new(0, 0, 0, 22)
            d.BackgroundTransparency = 1
            d.TextStrokeTransparency = 0
            d.Font = Enum.Font.Gotham
            d.TextSize = 11
            d.TextColor3 = Color3.fromRGB(200, 200, 200)
            d.Parent = f
            
            local hl = Instance.new("Highlight")
            hl.Name = "hl"
            hl.FillTransparency = 0.75
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = bb
            
            espCache[name] = bb
        end
        
        local bb = espCache[name]
        bb.Adornee = enemy.root
        bb.Enabled = true
        
        local f = bb:FindFirstChild("Frame")
        local hl = bb:FindFirstChild("hl")
        
        if hl then
            hl.Adornee = enemy.model
            hl.Enabled = cfg.boxOn
            hl.FillColor = cfg.espCol
            hl.OutlineColor = cfg.espCol
        end
        
        if f then
            local n = f:FindFirstChild("n")
            local hpbg = f:FindFirstChild("hpbg")
            local d = f:FindFirstChild("d")
            
            if n then
                n.Text = cfg.nameOn and name or ""
                n.TextColor3 = cfg.espCol
                n.Visible = cfg.nameOn
            end
            
            if hpbg then
                local hp = hpbg:FindFirstChild("hp")
                local pct = math.clamp(enemy.hum.Health / enemy.hum.MaxHealth, 0, 1)
                
                if hp then
                    hp.Size = UDim2.new(pct, 0, 1, 0)
                    if pct > 0.6 then hp.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    elseif pct > 0.3 then hp.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    else hp.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end
                end
                
                hpbg.Visible = cfg.healthOn
            end
            
            if d and myRoot then
                local dist = (myRoot.Position - enemy.root.Position).Magnitude
                d.Text = cfg.distOn and string.format("[%dm]", math.floor(dist)) or ""
                d.Visible = cfg.distOn
            end
        end
    end
end

conns["main"] = RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    
    fovCircle.Position = UDim2.new(0, cx, 0, cy)
    fovCircle.Size = UDim2.new(0, cfg.fovSize * 2, 0, cfg.fovSize * 2)
    fovCircle.ImageColor3 = cfg.fovCol
    fovCircle.Visible = cfg.aimbotOn and cfg.showFov
    
    targetLine.Visible = false
    targetDot.Visible = false
    
    if cfg.aimbotOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = FindBestTarget()
        
        if target then
            fovCircle.ImageColor3 = cfg.targetCol
            
            local screen = target.screen
            local dx = screen.X - cx
            local dy = screen.Y - cy
            
            if cfg.showLine then
                local len = math.sqrt(dx * dx + dy * dy)
                local ang = math.deg(math.atan2(dy, dx))
                
                targetLine.Position = UDim2.new(0, cx, 0, cy)
                targetLine.Size = UDim2.new(0, len, 0, 2)
                targetLine.Rotation = ang
                targetLine.BackgroundColor3 = cfg.targetCol
                targetLine.Visible = true
                
                targetDot.Position = UDim2.new(0, screen.X, 0, screen.Y)
                targetDot.BackgroundColor3 = cfg.targetCol
                targetDot.Visible = true
            end
            
            local moveX = dx * cfg.smooth
            local moveY = dy * cfg.smooth
            
            Camera.CFrame = Camera.CFrame * CFrame.Angles(
                math.rad(-moveY * 0.1),
                math.rad(-moveX * 0.1),
                0
            )
        end
    end
    
    UpdateESP()
end)

Rayfield:Notify({
    Title = "TheWizard PF",
    Content = "Chargé! Clic droit = Aim",
    Duration = 5,
})

pcall(function() Rayfield:LoadConfiguration() end)
