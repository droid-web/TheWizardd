local RayfieldLibrary = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not RayfieldLibrary then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local conns = {}
local espObjs = {}

local settings = {
    aimbot = false,
    esp = false,
    fov = 120,
    smooth = 4,
    prediction = 0.14,
    aimPart = "Head",
    teamCheck = true,
    wallCheck = true,
    showFov = true,
    fovColor = Color3.fromRGB(255, 255, 255),
    targetColor = Color3.fromRGB(0, 255, 0),
    espColor = Color3.fromRGB(255, 50, 50),
    espBox = true,
    espName = true,
    espHealth = true,
    espDist = true,
}

local currentTarget = nil

local function getChar() return LocalPlayer.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function getCharacters()
    local chars = {}
    
    if workspace:FindFirstChild("Characters") then
        for _, char in pairs(workspace.Characters:GetChildren()) do
            if char:FindFirstChild("HumanoidRootPart") then
                table.insert(chars, char)
            end
        end
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dominated = false
            for _, c in pairs(chars) do
                if c.Name == plr.Name then dominated = true break end
            end
            if not dominated then table.insert(chars, plr.Character) end
        end
    end
    
    return chars
end

local function isEnemy(char)
    if not settings.teamCheck then return true end
    
    local plr = Players:FindFirstChild(char.Name)
    if not plr then return true end
    
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    
    return true
end

local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isVisible(part)
    if not settings.wallCheck then return true end
    if not part then return false end
    
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local result = workspace:Raycast(origin, (part.Position - origin).Unit * 2000, params)
    
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function getAimPart(char)
    local parts = {settings.aimPart, "Head", "HumanoidRootPart", "Torso", "UpperTorso"}
    for _, name in ipairs(parts) do
        local part = char:FindFirstChild(name)
        if part then return part end
    end
    return nil
end

local function getPredictedPos(part, char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return part.Position end
    
    local vel = root.Velocity
    return part.Position + (vel * settings.prediction)
end

local function findTarget()
    local best = settings.fov
    local target = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, char in pairs(getCharacters()) do
        if char == getChar() then continue end
        if not isEnemy(char) then continue end
        if not isAlive(char) then continue end
        
        local part = getAimPart(char)
        if not part then continue end
        if not isVisible(part) then continue end
        
        local predicted = getPredictedPos(part, char)
        local pos, onScreen = Camera:WorldToViewportPoint(predicted)
        if not onScreen then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < best then
            best = dist
            target = {part = part, char = char, screenPos = Vector2.new(pos.X, pos.Y)}
        end
    end
    
    return target
end

local Window = RayfieldLibrary:CreateWindow({
    Name = "TheWizard - Phantom Forces",
    Icon = 0,
    LoadingTitle = "TheWizard",
    LoadingSubtitle = "Phantom Forces Edition",
    Theme = "Amethyst",
    ConfigurationSaving = {Enabled = true, FolderName = "TheWizard", FileName = "pf_config"},
    KeySystem = true,
    KeySettings = {
        Title = "TheWizard",
        Subtitle = "Entrez la clé",
        Note = "Clé : TheWizardBest",
        FileName = "TheWizardKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"TheWizardBest"}
    }
})

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "twfov"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
pcall(function() fovGui.Parent = CoreGui end)
if not fovGui.Parent then fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local fovCircle = Instance.new("ImageLabel")
fovCircle.Name = "circle"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Image = "rbxassetid://3570695787"
fovCircle.ImageTransparency = 0.6
fovCircle.Parent = fovGui

local targetLine = Instance.new("Frame")
targetLine.Name = "line"
targetLine.AnchorPoint = Vector2.new(0, 0.5)
targetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
targetLine.BorderSizePixel = 0
targetLine.Visible = false
targetLine.Parent = fovGui

local targetDot = Instance.new("Frame")
targetDot.Name = "dot"
targetDot.AnchorPoint = Vector2.new(0.5, 0.5)
targetDot.Size = UDim2.new(0, 10, 0, 10)
targetDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
targetDot.BorderSizePixel = 0
targetDot.Visible = false
targetDot.Parent = fovGui
Instance.new("UICorner", targetDot).CornerRadius = UDim.new(1, 0)

local tab1 = Window:CreateTab("AimBot", 4483362458)

tab1:CreateSection("Principal")

tab1:CreateToggle({
    Name = "Activer AimBot",
    CurrentValue = false,
    Flag = "aimbot",
    Callback = function(v) settings.aimbot = v end,
})

tab1:CreateDropdown({
    Name = "Partie visée",
    Options = {"Head", "HumanoidRootPart", "Torso"},
    CurrentOption = {"Head"},
    Flag = "aimpart",
    Callback = function(o) settings.aimPart = o[1] end,
})

tab1:CreateSection("FOV")

tab1:CreateSlider({
    Name = "Taille FOV",
    Range = {50, 400},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 120,
    Flag = "fov",
    Callback = function(v) settings.fov = v end,
})

tab1:CreateToggle({
    Name = "Afficher FOV",
    CurrentValue = true,
    Flag = "showfov",
    Callback = function(v) settings.showFov = v end,
})

tab1:CreateColorPicker({
    Name = "Couleur FOV",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "fovcolor",
    Callback = function(c) settings.fovColor = c end,
})

tab1:CreateColorPicker({
    Name = "Couleur Cible",
    Color = Color3.fromRGB(0, 255, 0),
    Flag = "targetcolor",
    Callback = function(c) settings.targetColor = c end,
})

tab1:CreateSection("Précision")

tab1:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 4,
    Flag = "smooth",
    Callback = function(v) settings.smooth = v end,
})

tab1:CreateSlider({
    Name = "Prédiction",
    Range = {0, 0.25},
    Increment = 0.01,
    CurrentValue = 0.14,
    Flag = "prediction",
    Callback = function(v) settings.prediction = v end,
})

tab1:CreateSection("Filtres")

tab1:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "teamcheck",
    Callback = function(v) settings.teamCheck = v end,
})

tab1:CreateToggle({
    Name = "Wall Check",
    CurrentValue = true,
    Flag = "wallcheck",
    Callback = function(v) settings.wallCheck = v end,
})

local tab2 = Window:CreateTab("ESP", 4483362458)

tab2:CreateSection("Principal")

tab2:CreateToggle({
    Name = "Activer ESP",
    CurrentValue = false,
    Flag = "esp",
    Callback = function(v) settings.esp = v end,
})

tab2:CreateColorPicker({
    Name = "Couleur ESP",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "espcolor",
    Callback = function(c) settings.espColor = c end,
})

tab2:CreateSection("Affichage")

tab2:CreateToggle({
    Name = "Box",
    CurrentValue = true,
    Flag = "espbox",
    Callback = function(v) settings.espBox = v end,
})

tab2:CreateToggle({
    Name = "Nom",
    CurrentValue = true,
    Flag = "espname",
    Callback = function(v) settings.espName = v end,
})

tab2:CreateToggle({
    Name = "Santé",
    CurrentValue = true,
    Flag = "esphealth",
    Callback = function(v) settings.espHealth = v end,
})

tab2:CreateToggle({
    Name = "Distance",
    CurrentValue = true,
    Flag = "espdist",
    Callback = function(v) settings.espDist = v end,
})

local tab3 = Window:CreateTab("Paramètres", 4483362458)

tab3:CreateSection("Info")

tab3:CreateParagraph({
    Title = "TheWizard",
    Content = "Version: PF Edition\nClé: TheWizardBest\n\nMaintiens CLIC DROIT pour activer l'aimbot"
})

tab3:CreateButton({
    Name = "Fermer le script",
    Callback = function()
        for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
        for _, o in pairs(espObjs) do pcall(function() if o.bb then o.bb:Destroy() end if o.hl then o.hl:Destroy() end end) end
        pcall(function() fovGui:Destroy() end)
        pcall(function() RayfieldLibrary:Destroy() end)
    end,
})

local function getHealthColor(pct)
    if pct > 70 then return Color3.fromRGB(0, 255, 0)
    elseif pct > 40 then return Color3.fromRGB(255, 255, 0)
    else return Color3.fromRGB(255, 0, 0) end
end

local function updateESP()
    for name, obj in pairs(espObjs) do
        if obj.bb then obj.bb.Enabled = false end
        if obj.hl then obj.hl.Enabled = false end
    end
    
    if not settings.esp then return end
    
    local myRoot = getRoot()
    
    for _, char in pairs(getCharacters()) do
        if char == getChar() then continue end
        if not isEnemy(char) then continue end
        if not isAlive(char) then continue end
        
        local name = char.Name
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if not root or not hum then continue end
        
        if not espObjs[name] then
            local bb = Instance.new("BillboardGui")
            bb.Name = "twesp"
            bb.Size = UDim2.new(0, 150, 0, 50)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = root
            bb.Parent = CoreGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = bb
            
            local nm = Instance.new("TextLabel")
            nm.Name = "name"
            nm.Size = UDim2.new(1, 0, 0, 16)
            nm.BackgroundTransparency = 1
            nm.TextColor3 = settings.espColor
            nm.TextStrokeTransparency = 0
            nm.Font = Enum.Font.GothamBold
            nm.TextSize = 13
            nm.Parent = frame
            
            local hpBg = Instance.new("Frame")
            hpBg.Name = "hpbg"
            hpBg.Size = UDim2.new(0.7, 0, 0, 5)
            hpBg.Position = UDim2.new(0.15, 0, 0, 18)
            hpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            hpBg.BorderSizePixel = 0
            hpBg.Parent = frame
            Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)
            
            local hpBar = Instance.new("Frame")
            hpBar.Name = "hp"
            hpBar.Size = UDim2.new(1, 0, 1, 0)
            hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            hpBar.BorderSizePixel = 0
            hpBar.Parent = hpBg
            Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 2)
            
            local dist = Instance.new("TextLabel")
            dist.Name = "dist"
            dist.Size = UDim2.new(1, 0, 0, 14)
            dist.Position = UDim2.new(0, 0, 0, 26)
            dist.BackgroundTransparency = 1
            dist.TextColor3 = Color3.fromRGB(200, 200, 200)
            dist.TextStrokeTransparency = 0
            dist.Font = Enum.Font.Gotham
            dist.TextSize = 11
            dist.Parent = frame
            
            local hl = Instance.new("Highlight")
            hl.Name = "twhl"
            hl.FillTransparency = 0.75
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            hl.Parent = CoreGui
            
            espObjs[name] = {bb = bb, hl = hl, nm = nm, hpBar = hpBar, dist = dist, frame = frame}
        end
        
        local obj = espObjs[name]
        obj.bb.Adornee = root
        obj.hl.Adornee = char
        obj.bb.Enabled = true
        obj.hl.Enabled = settings.espBox
        
        obj.hl.FillColor = settings.espColor
        obj.hl.OutlineColor = settings.espColor
        
        local pct = math.clamp((hum.Health / hum.MaxHealth) * 100, 0, 100)
        
        if obj.nm then
            obj.nm.Text = settings.espName and name or ""
            obj.nm.TextColor3 = settings.espColor
            obj.nm.Visible = settings.espName
        end
        
        if obj.hpBar then
            obj.hpBar.Size = UDim2.new(pct / 100, 0, 1, 0)
            obj.hpBar.BackgroundColor3 = getHealthColor(pct)
            obj.hpBar.Parent.Visible = settings.espHealth
        end
        
        if obj.dist and myRoot then
            local d = (myRoot.Position - root.Position).Magnitude
            obj.dist.Text = settings.espDist and ("[" .. math.floor(d) .. "m]") or ""
            obj.dist.Visible = settings.espDist
        end
    end
end

conns["main"] = RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    
    fovCircle.Position = UDim2.new(0, cx, 0, cy)
    fovCircle.Size = UDim2.new(0, settings.fov * 2, 0, settings.fov * 2)
    fovCircle.ImageColor3 = settings.fovColor
    fovCircle.Visible = settings.aimbot and settings.showFov
    
    targetLine.Visible = false
    targetDot.Visible = false
    
    if settings.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = findTarget()
        
        if target then
            currentTarget = target
            
            fovCircle.ImageColor3 = settings.targetColor
            
            local predicted = getPredictedPos(target.part, target.char)
            local pos = Camera:WorldToViewportPoint(predicted)
            
            local dx = pos.X - cx
            local dy = pos.Y - cy
            local len = math.sqrt(dx * dx + dy * dy)
            local angle = math.deg(math.atan2(dy, dx))
            
            targetLine.Position = UDim2.new(0, cx, 0, cy)
            targetLine.Size = UDim2.new(0, len, 0, 2)
            targetLine.Rotation = angle
            targetLine.BackgroundColor3 = settings.targetColor
            targetLine.Visible = true
            
            targetDot.Position = UDim2.new(0, pos.X, 0, pos.Y)
            targetDot.BackgroundColor3 = settings.targetColor
            targetDot.Visible = true
            
            local smoothFactor = 11 - settings.smooth
            local aimX = dx / (smoothFactor * 6)
            local aimY = dy / (smoothFactor * 6)
            
            Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-aimY), math.rad(-aimX), 0)
        else
            currentTarget = nil
        end
    else
        currentTarget = nil
    end
    
    updateESP()
end)

RayfieldLibrary:Notify({
    Title = "TheWizard",
    Content = "Phantom Forces Edition chargé!\nClic droit = AimBot",
    Duration = 5,
})

pcall(function() RayfieldLibrary:LoadConfiguration() end)
