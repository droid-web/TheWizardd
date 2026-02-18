local RayfieldLibrary = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not RayfieldLibrary then
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = "TheWizard", Text = "Erreur", Duration = 5})
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local noclip, godmode, esp, crosshair = false, false, false, false
local espColor = Color3.fromRGB(255, 0, 0)
local espBox, espName, espHealth, espDist = true, true, true, true
local chSize, chColor = 10, Color3.fromRGB(255, 255, 255)
local flying, flyspeed = false, 50

local aim = {
    enabled = false,
    fov = 150,
    innerFov = 50,
    smooth = 5,
    prediction = 0.13,
    part = "Head",
    key = Enum.UserInputType.MouseButton2,
    wallCheck = true,
    teamCheck = false,
    showFov = true,
    showInnerFov = true,
    showTargetLine = true,
    fovColor = Color3.fromRGB(255, 255, 255),
    fovColorTarget = Color3.fromRGB(0, 255, 0),
    innerFovColor = Color3.fromRGB(255, 100, 100),
    fovThickness = 1,
    fovSegments = 64,
    fovFilled = false,
    fovFilledAlpha = 0.9,
    targetLock = false,
    stickyAim = false,
    stickyStrength = 0.3,
    aimAssist = false,
    assistStrength = 0.5,
    silentAim = false,
    triggerBot = false,
    triggerDelay = 0.05,
    humanize = false,
    humanizeStrength = 0.5,
    snapSpeed = 1,
    priority = "Distance",
    autoPrediction = true,
    maxPrediction = 0.25,
    nearbySlowdown = true,
    nearbyRadius = 30,
    nearbySmooth = 8,
    currentTarget = nil,
    resolver = false,
    antiAimDetect = false,
    flickMode = false,
    flickSpeed = 15,
    hitChance = 100,
}

local conns = {}
local espObjs = {}
local origLight = {
    Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function notify(t, c, d) pcall(function() RayfieldLibrary:Notify({Title = t, Content = c, Duration = d or 3}) end) end
local function getChar() return LocalPlayer and LocalPlayer.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function disconn(n) if conns[n] then pcall(function() conns[n]:Disconnect() end) conns[n] = nil end end

local function isTeammate(plr)
    if not aim.teamCheck then return false end
    return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
end

local function isVisible(part)
    if not aim.wallCheck then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(origin, (part.Position - origin), params)
    return result == nil or result.Instance:IsDescendantOf(part.Parent)
end

local function lerp(a, b, t) return a + (b - a) * t end
local function clamp(v, min, max) return math.max(min, math.min(max, v)) end

local Window = RayfieldLibrary:CreateWindow({
    Name = "TheWizard",
    Icon = 0,
    LoadingTitle = "TheWizard",
    LoadingSubtitle = "v4.0 Ultimate",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {Enabled = true, FolderName = "TheWizard", FileName = "config"},
    Discord = {Enabled = false, Invite = "noinvite", RememberJoins = true},
    KeySystem = true,
    KeySettings = {
        Title = "TheWizard - Authentification",
        Subtitle = "Entrez votre clé",
        Note = "Clé requise pour accéder",
        FileName = "TheWizardKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"TheWizardBest"}
    }
})

local fovGui = Instance.new("ScreenGui")
fovGui.Name = "twfovgui"
fovGui.ResetOnSpawn = false
fovGui.IgnoreGuiInset = true
fovGui.DisplayOrder = 999
pcall(function() fovGui.Parent = CoreGui end)
if not fovGui.Parent then fovGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local fovFrame = Instance.new("Frame")
fovFrame.Name = "fovframe"
fovFrame.Size = UDim2.new(1, 0, 1, 0)
fovFrame.BackgroundTransparency = 1
fovFrame.Parent = fovGui

local fovCanvas = Instance.new("Frame")
fovCanvas.Name = "canvas"
fovCanvas.Size = UDim2.new(1, 0, 1, 0)
fovCanvas.BackgroundTransparency = 1
fovCanvas.Parent = fovFrame

local outerCircleSegments = {}
local innerCircleSegments = {}
local targetLine = nil
local targetDot = nil

local function createCircleSegments(count, parent, name)
    local segments = {}
    for i = 1, count do
        local seg = Instance.new("Frame")
        seg.Name = name .. i
        seg.BackgroundColor3 = Color3.new(1, 1, 1)
        seg.BorderSizePixel = 0
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        seg.Parent = parent
        segments[i] = seg
    end
    return segments
end

local function updateCircle(segments, cx, cy, radius, color, thickness, alpha)
    local count = #segments
    if count == 0 then return end
    
    for i, seg in ipairs(segments) do
        local angle1 = (i - 1) / count * math.pi * 2
        local angle2 = i / count * math.pi * 2
        
        local x1 = cx + math.cos(angle1) * radius
        local y1 = cy + math.sin(angle1) * radius
        local x2 = cx + math.cos(angle2) * radius
        local y2 = cy + math.sin(angle2) * radius
        
        local mx = (x1 + x2) / 2
        local my = (y1 + y2) / 2
        local len = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
        local angle = math.atan2(y2 - y1, x2 - x1)
        
        seg.Position = UDim2.new(0, mx, 0, my)
        seg.Size = UDim2.new(0, len + 1, 0, thickness)
        seg.Rotation = math.deg(angle)
        seg.BackgroundColor3 = color
        seg.BackgroundTransparency = alpha
        seg.Visible = true
    end
end

local function hideCircle(segments)
    for _, seg in ipairs(segments) do seg.Visible = false end
end

outerCircleSegments = createCircleSegments(64, fovCanvas, "outer")
innerCircleSegments = createCircleSegments(48, fovCanvas, "inner")

targetLine = Instance.new("Frame")
targetLine.Name = "targetline"
targetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
targetLine.BorderSizePixel = 0
targetLine.AnchorPoint = Vector2.new(0, 0.5)
targetLine.Visible = false
targetLine.Parent = fovCanvas

targetDot = Instance.new("Frame")
targetDot.Name = "targetdot"
targetDot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
targetDot.BorderSizePixel = 0
targetDot.AnchorPoint = Vector2.new(0.5, 0.5)
targetDot.Size = UDim2.new(0, 8, 0, 8)
targetDot.Visible = false
targetDot.Parent = fovCanvas
Instance.new("UICorner", targetDot).CornerRadius = UDim.new(1, 0)

local targetInfo = Instance.new("TextLabel")
targetInfo.Name = "targetinfo"
targetInfo.BackgroundTransparency = 1
targetInfo.TextColor3 = Color3.new(1, 1, 1)
targetInfo.TextStrokeTransparency = 0
targetInfo.Font = Enum.Font.GothamBold
targetInfo.TextSize = 12
targetInfo.AnchorPoint = Vector2.new(0.5, 0)
targetInfo.Visible = false
targetInfo.Parent = fovCanvas

local function getVelocityPrediction(root, part)
    if not aim.autoPrediction then return aim.prediction end
    if not root then return aim.prediction end
    
    local vel = root.Velocity
    local speed = vel.Magnitude
    local myRoot = getRoot()
    local dist = myRoot and (myRoot.Position - part.Position).Magnitude or 100
    
    local pred = clamp(speed * 0.002 + dist * 0.0005, 0.05, aim.maxPrediction)
    return pred
end

local function getPredictedPos(part, root)
    if not root then return part.Position end
    local vel = root.Velocity
    local pred = getVelocityPrediction(root, part)
    
    local accel = Vector3.new(0, -workspace.Gravity * pred * 0.5, 0)
    return part.Position + (vel * pred) + accel
end

local function calcPriority(plr, char, dist, hp, screenDist)
    if aim.priority == "Distance" then
        return dist
    elseif aim.priority == "Santé" then
        return hp
    elseif aim.priority == "Écran" then
        return screenDist
    elseif aim.priority == "Menace" then
        local threat = (100 - hp) * 0.3 + (200 - dist) * 0.5 + (aim.fov - screenDist) * 0.2
        return -threat
    end
    return screenDist
end

local function findTarget()
    local best = aim.fov
    local bestPriority = math.huge
    local target, targetVel, targetRoot = nil, nil, nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myRoot = getRoot()
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isTeammate(plr) then continue end
        
        local c = plr.Character
        if not c then continue end
        
        local parts = {aim.part, "Head", "HumanoidRootPart", "UpperTorso"}
        local part = nil
        for _, pn in ipairs(parts) do
            part = c:FindFirstChild(pn)
            if part then break end
        end
        
        local hum = c:FindFirstChildOfClass("Humanoid")
        local root = c:FindFirstChild("HumanoidRootPart")
        
        if not part or not hum or hum.Health <= 0 then continue end
        if not isVisible(part) then continue end
        
        if aim.hitChance < 100 then
            if math.random(1, 100) > aim.hitChance then continue end
        end
        
        local vel = root and root.Velocity or Vector3.new(0, 0, 0)
        local predictedPos = getPredictedPos(part, root)
        local pos, vis = Camera:WorldToViewportPoint(predictedPos)
        
        if not vis then continue end
        
        local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if screenDist > aim.fov then continue end
        
        local dist = myRoot and (myRoot.Position - part.Position).Magnitude or 1000
        local hp = hum.Health
        local priority = calcPriority(plr, c, dist, hp, screenDist)
        
        if priority < bestPriority or (priority == bestPriority and screenDist < best) then
            bestPriority = priority
            best = screenDist
            target = part
            targetVel = vel
            targetRoot = root
        end
    end
    
    return target, targetVel, targetRoot
end

local function getSmooth(dist, screenDist)
    if aim.nearbySlowdown and dist < aim.nearbyRadius then
        local factor = dist / aim.nearbyRadius
        return lerp(aim.nearbySmooth, aim.smooth, factor)
    end
    
    if aim.stickyAim and screenDist < aim.innerFov then
        return aim.smooth * (1 + aim.stickyStrength)
    end
    
    return aim.smooth
end

local function addHumanization()
    if not aim.humanize then return 0, 0 end
    local str = aim.humanizeStrength
    local rx = (math.random() - 0.5) * str * 0.5
    local ry = (math.random() - 0.5) * str * 0.5
    return rx, ry
end

local lastTrigger = 0

local function doTriggerBot()
    if not aim.triggerBot then return end
    if tick() - lastTrigger < aim.triggerDelay then return end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isTeammate(plr) then continue end
        
        local c = plr.Character
        if not c then continue end
        local head = c:FindFirstChild("Head")
        local hum = c:FindFirstChildOfClass("Humanoid")
        
        if not head or not hum or hum.Health <= 0 then continue end
        
        local pos, vis = Camera:WorldToViewportPoint(head.Position)
        if not vis then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < 20 then
            mouse1click()
            lastTrigger = tick()
            break
        end
    end
end

local tab1 = Window:CreateTab("Principal", 4483362458)
tab1:CreateSection("Joueur")

tab1:CreateButton({Name = "TP Spawn", Callback = function()
    local r = getRoot() if r then r.CFrame = CFrame.new(0, 5, 0) notify("TP", "Spawn") end
end})

tab1:CreateToggle({Name = "NoClip", CurrentValue = false, Flag = "noclip", Callback = function(v)
    noclip = v disconn("noclip")
    if v then
        conns["noclip"] = RunService.Stepped:Connect(function()
            if noclip then local c = getChar() if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end end
        end)
    else
        local c = getChar() if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end
    end
    notify("NoClip", v and "ON" or "OFF")
end})

tab1:CreateToggle({Name = "God Mode", CurrentValue = false, Flag = "godmode", Callback = function(v)
    godmode = v disconn("godmode")
    local h = getHum()
    if v then
        if h then h.MaxHealth, h.Health = math.huge, math.huge end
        conns["godmode"] = RunService.Heartbeat:Connect(function()
            if godmode then local hum = getHum() if hum then hum.MaxHealth, hum.Health = math.huge, math.huge end end
        end)
    else if h then h.MaxHealth, h.Health = 100, 100 end end
    notify("God", v and "ON" or "OFF")
end})

tab1:CreateSlider({Name = "Vitesse", Range = {16, 200}, Increment = 1, Suffix = " WS", CurrentValue = 16, Flag = "speed", Callback = function(v) local h = getHum() if h then h.WalkSpeed = v end end})
tab1:CreateSlider({Name = "Saut", Range = {50, 300}, Increment = 5, Suffix = " JP", CurrentValue = 50, Flag = "jump", Callback = function(v) local h = getHum() if h then h.JumpPower = v end end})
tab1:CreateSlider({Name = "Gravité", Range = {0, 400}, Increment = 10, Suffix = " G", CurrentValue = 196, Flag = "gravity", Callback = function(v) workspace.Gravity = v end})

tab1:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "infjump", Callback = function(v)
    disconn("infjump")
    if v then conns["infjump"] = UserInputService.JumpRequest:Connect(function() local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
    notify("Inf Jump", v and "ON" or "OFF")
end})

tab1:CreateToggle({Name = "Fly", CurrentValue = false, Flag = "fly", Callback = function(v)
    flying = v disconn("fly")
    local r = getRoot()
    if v and r then
        local bg = Instance.new("BodyGyro") bg.Name = "twg" bg.P = 9e4 bg.maxTorque = Vector3.new(9e9, 9e9, 9e9) bg.cframe = r.CFrame bg.Parent = r
        local bv = Instance.new("BodyVelocity") bv.Name = "twv" bv.Velocity = Vector3.new(0, 0, 0) bv.maxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = r
        conns["fly"] = RunService.RenderStepped:Connect(function()
            if flying and r then
                local g, vel = r:FindFirstChild("twg"), r:FindFirstChild("twv")
                if g and vel then
                    g.cframe = Camera.CFrame
                    local dir = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                    vel.Velocity = dir * flyspeed
                end
            end
        end)
    else
        if r then local g, vel = r:FindFirstChild("twg"), r:FindFirstChild("twv") if g then g:Destroy() end if vel then vel:Destroy() end end
    end
    notify("Fly", v and "ON" or "OFF")
end})

tab1:CreateSlider({Name = "Fly Speed", Range = {10, 200}, Increment = 5, CurrentValue = 50, Flag = "flyspeed", Callback = function(v) flyspeed = v end})

local tab2 = Window:CreateTab("AimBot", 4483362458)
tab2:CreateSection("Principal")

tab2:CreateToggle({Name = "Activer AimBot", CurrentValue = false, Flag = "aim", Callback = function(v) aim.enabled = v notify("AimBot", v and "ON" or "OFF") end})

tab2:CreateDropdown({Name = "Mode", Options = {"Normal", "Flick", "Assist"}, CurrentOption = {"Normal"}, Flag = "aimmode", Callback = function(o)
    local m = o[1]
    aim.flickMode = m == "Flick"
    aim.aimAssist = m == "Assist"
end})

tab2:CreateDropdown({Name = "Priorité", Options = {"Distance", "Santé", "Écran", "Menace"}, CurrentOption = {"Distance"}, Flag = "aimpriority", Callback = function(o) aim.priority = o[1] end})

tab2:CreateDropdown({Name = "Partie", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, CurrentOption = {"Head"}, Flag = "aimpart", Callback = function(o) aim.part = o[1] end})

tab2:CreateDropdown({Name = "Touche", Options = {"Clic Droit", "Clic Gauche", "Shift", "E", "Q", "F", "C"}, CurrentOption = {"Clic Droit"}, Flag = "aimkey", Callback = function(o)
    local keys = {["Clic Droit"] = Enum.UserInputType.MouseButton2, ["Clic Gauche"] = Enum.UserInputType.MouseButton1, ["Shift"] = Enum.KeyCode.LeftShift, ["E"] = Enum.KeyCode.E, ["Q"] = Enum.KeyCode.Q, ["F"] = Enum.KeyCode.F, ["C"] = Enum.KeyCode.C}
    aim.key = keys[o[1]] or Enum.UserInputType.MouseButton2
end})

tab2:CreateSection("FOV")

tab2:CreateSlider({Name = "FOV Principal", Range = {50, 600}, Increment = 10, Suffix = " px", CurrentValue = 150, Flag = "aimfov", Callback = function(v) aim.fov = v end})
tab2:CreateSlider({Name = "FOV Interne", Range = {10, 200}, Increment = 5, Suffix = " px", CurrentValue = 50, Flag = "aiminnerfov", Callback = function(v) aim.innerFov = v end})
tab2:CreateSlider({Name = "Épaisseur", Range = {1, 5}, Increment = 1, Suffix = " px", CurrentValue = 1, Flag = "fovthick", Callback = function(v) aim.fovThickness = v end})

tab2:CreateToggle({Name = "Afficher FOV", CurrentValue = true, Flag = "showfov", Callback = function(v) aim.showFov = v end})
tab2:CreateToggle({Name = "Afficher FOV Interne", CurrentValue = true, Flag = "showinnerfov", Callback = function(v) aim.showInnerFov = v end})
tab2:CreateToggle({Name = "Ligne vers Cible", CurrentValue = true, Flag = "showtargetline", Callback = function(v) aim.showTargetLine = v end})
tab2:CreateToggle({Name = "FOV Rempli", CurrentValue = false, Flag = "fovfilled", Callback = function(v) aim.fovFilled = v end})

tab2:CreateColorPicker({Name = "Couleur FOV", Color = Color3.fromRGB(255, 255, 255), Flag = "fovcolor", Callback = function(c) aim.fovColor = c end})
tab2:CreateColorPicker({Name = "Couleur Cible", Color = Color3.fromRGB(0, 255, 0), Flag = "fovcolortarget", Callback = function(c) aim.fovColorTarget = c end})
tab2:CreateColorPicker({Name = "Couleur FOV Interne", Color = Color3.fromRGB(255, 100, 100), Flag = "innerfovcolor", Callback = function(c) aim.innerFovColor = c end})

tab2:CreateSection("Précision")

tab2:CreateSlider({Name = "Smoothness", Range = {1, 15}, Increment = 0.5, CurrentValue = 5, Flag = "aimsmooth", Callback = function(v) aim.smooth = v end})
tab2:CreateSlider({Name = "Flick Speed", Range = {5, 30}, Increment = 1, CurrentValue = 15, Flag = "flickspeed", Callback = function(v) aim.flickSpeed = v end})
tab2:CreateSlider({Name = "Prédiction", Range = {0, 0.35}, Increment = 0.01, CurrentValue = 0.13, Flag = "aimpred", Callback = function(v) aim.prediction = v end})
tab2:CreateSlider({Name = "Prédiction Max", Range = {0.1, 0.5}, Increment = 0.01, CurrentValue = 0.25, Flag = "maxpred", Callback = function(v) aim.maxPrediction = v end})
tab2:CreateSlider({Name = "Hit Chance", Range = {1, 100}, Increment = 1, Suffix = "%", CurrentValue = 100, Flag = "hitchance", Callback = function(v) aim.hitChance = v end})

tab2:CreateToggle({Name = "Auto Prédiction", CurrentValue = true, Flag = "autopred", Callback = function(v) aim.autoPrediction = v end})

tab2:CreateSection("Options")

tab2:CreateToggle({Name = "Target Lock", CurrentValue = false, Flag = "targetlock", Callback = function(v) aim.targetLock = v if not v then aim.currentTarget = nil end end})
tab2:CreateToggle({Name = "Sticky Aim", CurrentValue = false, Flag = "stickyaim", Callback = function(v) aim.stickyAim = v end})
tab2:CreateSlider({Name = "Sticky Force", Range = {0.1, 1}, Increment = 0.1, CurrentValue = 0.3, Flag = "stickystr", Callback = function(v) aim.stickyStrength = v end})

tab2:CreateToggle({Name = "Ralentir Proche", CurrentValue = true, Flag = "nearbyslowdown", Callback = function(v) aim.nearbySlowdown = v end})
tab2:CreateSlider({Name = "Rayon Proche", Range = {10, 100}, Increment = 5, Suffix = "m", CurrentValue = 30, Flag = "nearbyradius", Callback = function(v) aim.nearbyRadius = v end})
tab2:CreateSlider({Name = "Smooth Proche", Range = {1, 15}, Increment = 0.5, CurrentValue = 8, Flag = "nearbysmooth", Callback = function(v) aim.nearbySmooth = v end})

tab2:CreateSection("Filtres")

tab2:CreateToggle({Name = "Wall Check", CurrentValue = true, Flag = "wallcheck", Callback = function(v) aim.wallCheck = v end})
tab2:CreateToggle({Name = "Team Check", CurrentValue = false, Flag = "teamcheck", Callback = function(v) aim.teamCheck = v end})

tab2:CreateSection("Extras")

tab2:CreateToggle({Name = "Humanizer", CurrentValue = false, Flag = "humanize", Callback = function(v) aim.humanize = v end})
tab2:CreateSlider({Name = "Humanize Force", Range = {0.1, 2}, Increment = 0.1, CurrentValue = 0.5, Flag = "humanizestr", Callback = function(v) aim.humanizeStrength = v end})

tab2:CreateToggle({Name = "TriggerBot", CurrentValue = false, Flag = "triggerbot", Callback = function(v) aim.triggerBot = v end})
tab2:CreateSlider({Name = "Trigger Delay", Range = {0.01, 0.3}, Increment = 0.01, Suffix = "s", CurrentValue = 0.05, Flag = "triggerdelay", Callback = function(v) aim.triggerDelay = v end})

local tab3 = Window:CreateTab("ESP", 4483362458)
tab3:CreateSection("Options")

local function getHealthColor(pct)
    if pct > 75 then return Color3.fromRGB(0, 255, 0)
    elseif pct > 50 then return Color3.fromRGB(255, 255, 0)
    elseif pct > 25 then return Color3.fromRGB(255, 165, 0)
    else return Color3.fromRGB(255, 0, 0) end
end

local function setupEsp(plr)
    if plr == LocalPlayer then return end
    local function create(char)
        if not char then return end
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not root or not hum then return end
        
        for _, v in pairs(char:GetChildren()) do if v.Name == "twesp" or v.Name == "twhl" then v:Destroy() end end
        
        local bb = Instance.new("BillboardGui") bb.Name = "twesp" bb.Adornee = root bb.Size = UDim2.new(0, 200, 0, 55) bb.StudsOffset = Vector3.new(0, 3, 0) bb.AlwaysOnTop = true bb.Parent = char
        
        local c = Instance.new("Frame") c.Name = "c" c.Size = UDim2.new(1, 0, 1, 0) c.BackgroundTransparency = 1 c.Parent = bb
        
        local nm = Instance.new("TextLabel") nm.Name = "n" nm.Size = UDim2.new(1, 0, 0, 16) nm.BackgroundTransparency = 1 nm.TextColor3 = espColor nm.TextStrokeTransparency = 0 nm.Font = Enum.Font.GothamBold nm.TextSize = 14 nm.Text = plr.Name nm.Parent = c
        
        local hpBg = Instance.new("Frame") hpBg.Name = "hpbg" hpBg.Size = UDim2.new(0.6, 0, 0, 6) hpBg.Position = UDim2.new(0.2, 0, 0, 18) hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40) hpBg.BorderSizePixel = 0 hpBg.Parent = c
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)
        
        local hpBar = Instance.new("Frame") hpBar.Name = "hp" hpBar.Size = UDim2.new(1, 0, 1, 0) hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) hpBar.BorderSizePixel = 0 hpBar.Parent = hpBg
        Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 3)
        
        local hpTxt = Instance.new("TextLabel") hpTxt.Name = "htxt" hpTxt.Size = UDim2.new(1, 0, 0, 14) hpTxt.Position = UDim2.new(0, 0, 0, 26) hpTxt.BackgroundTransparency = 1 hpTxt.TextColor3 = Color3.new(1, 1, 1) hpTxt.TextStrokeTransparency = 0 hpTxt.Font = Enum.Font.Gotham hpTxt.TextSize = 12 hpTxt.Parent = c
        
        local distTxt = Instance.new("TextLabel") distTxt.Name = "dist" distTxt.Size = UDim2.new(1, 0, 0, 12) distTxt.Position = UDim2.new(0, 0, 0, 40) distTxt.BackgroundTransparency = 1 distTxt.TextColor3 = Color3.fromRGB(200, 200, 200) distTxt.TextStrokeTransparency = 0 distTxt.Font = Enum.Font.Gotham distTxt.TextSize = 11 distTxt.Parent = c
        
        local hl = Instance.new("Highlight") hl.Name = "twhl" hl.FillColor = espColor hl.FillTransparency = 0.7 hl.OutlineColor = espColor hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Parent = char
        
        espObjs[plr.Name] = {bb = bb, hl = hl, hpBar = hpBar, hpTxt = hpTxt, distTxt = distTxt, nm = nm, char = char}
        bb.Enabled = esp hl.Enabled = esp and espBox
    end
    if plr.Character then create(plr.Character) end
    plr.CharacterAdded:Connect(function(c) task.wait(0.5) create(c) end)
end

local function removeEsp(plr)
    local o = espObjs[plr.Name]
    if o then pcall(function() if o.bb then o.bb:Destroy() end if o.hl then o.hl:Destroy() end end) espObjs[plr.Name] = nil end
end

local function updateEsp()
    local myRoot = getRoot()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local o = espObjs[plr.Name]
            if o and o.char then
                local show = esp and not isTeammate(plr)
                if o.bb then o.bb.Enabled = show end
                if o.hl then o.hl.Enabled = show and espBox end
                if show then
                    local hum = o.char:FindFirstChildOfClass("Humanoid")
                    local root = o.char:FindFirstChild("HumanoidRootPart")
                    if hum and root then
                        local pct = clamp((hum.Health / hum.MaxHealth) * 100, 0, 100)
                        local col = getHealthColor(pct)
                        if o.hpBar then o.hpBar.Size = UDim2.new(pct / 100, 0, 1, 0) o.hpBar.BackgroundColor3 = col end
                        if o.hpTxt then o.hpTxt.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) o.hpTxt.Visible = espHealth end
                        if o.distTxt and myRoot then local d = (myRoot.Position - root.Position).Magnitude o.distTxt.Text = "[" .. math.floor(d) .. "m]" o.distTxt.Visible = espDist end
                        if o.nm then o.nm.Visible = espName o.nm.TextColor3 = espColor end
                        if o.hl then o.hl.FillColor = espColor o.hl.OutlineColor = espColor end
                    end
                end
            end
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do setupEsp(p) end
Players.PlayerAdded:Connect(setupEsp)
Players.PlayerRemoving:Connect(removeEsp)

tab3:CreateToggle({Name = "ESP", CurrentValue = false, Flag = "esp", Callback = function(v) esp = v updateEsp() notify("ESP", v and "ON" or "OFF") end})
tab3:CreateToggle({Name = "Box/Highlight", CurrentValue = true, Flag = "espbox", Callback = function(v) espBox = v end})
tab3:CreateToggle({Name = "Nom", CurrentValue = true, Flag = "espname", Callback = function(v) espName = v end})
tab3:CreateToggle({Name = "Santé", CurrentValue = true, Flag = "esphealth", Callback = function(v) espHealth = v end})
tab3:CreateToggle({Name = "Distance", CurrentValue = true, Flag = "espdist", Callback = function(v) espDist = v end})
tab3:CreateColorPicker({Name = "Couleur", Color = Color3.fromRGB(255, 0, 0), Flag = "espcolor", Callback = function(c) espColor = c end})

local tab4 = Window:CreateTab("Visuels", 4483362458)
tab4:CreateSection("Crosshair")

local chGui = Instance.new("ScreenGui") chGui.Name = "twch" chGui.ResetOnSpawn = false chGui.IgnoreGuiInset = true
pcall(function() chGui.Parent = CoreGui end)
if not chGui.Parent then chGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local chFrame = Instance.new("Frame") chFrame.AnchorPoint = Vector2.new(0.5, 0.5) chFrame.Position = UDim2.new(0.5, 0, 0.5, 0) chFrame.Size = UDim2.new(0, 20, 0, 20) chFrame.BackgroundTransparency = 1 chFrame.Parent = chGui

local function mkLine(sx, sy, px, py)
    local l = Instance.new("Frame") l.AnchorPoint = Vector2.new(0.5, 0.5) l.Size = UDim2.new(0, sx, 0, sy) l.Position = UDim2.new(0.5, px, 0.5, py) l.BackgroundColor3 = chColor l.BorderSizePixel = 0 l.Parent = chFrame return l
end

local chT, chB, chL, chR, chD = mkLine(2, 10, 0, -8), mkLine(2, 10, 0, 8), mkLine(10, 2, -8, 0), mkLine(10, 2, 8, 0), mkLine(4, 4, 0, 0)
chGui.Enabled = false

local function updChSize()
    local s = chSize
    chT.Size, chT.Position = UDim2.new(0, 2, 0, s), UDim2.new(0.5, 0, 0.5, -s - 2)
    chB.Size, chB.Position = UDim2.new(0, 2, 0, s), UDim2.new(0.5, 0, 0.5, s + 2)
    chL.Size, chL.Position = UDim2.new(0, s, 0, 2), UDim2.new(0.5, -s - 2, 0.5, 0)
    chR.Size, chR.Position = UDim2.new(0, s, 0, 2), UDim2.new(0.5, s + 2, 0.5, 0)
end

local function updChColor() chT.BackgroundColor3, chB.BackgroundColor3, chL.BackgroundColor3, chR.BackgroundColor3, chD.BackgroundColor3 = chColor, chColor, chColor, chColor, chColor end

tab4:CreateToggle({Name = "Crosshair", CurrentValue = false, Flag = "crosshair", Callback = function(v) crosshair = v chGui.Enabled = v end})
tab4:CreateColorPicker({Name = "Couleur", Color = Color3.fromRGB(255, 255, 255), Flag = "chcolor", Callback = function(c) chColor = c updChColor() end})
tab4:CreateSlider({Name = "Taille", Range = {5, 50}, Increment = 1, Suffix = " px", CurrentValue = 10, Flag = "chsize", Callback = function(v) chSize = v updChSize() end})

tab4:CreateSection("Environnement")

tab4:CreateToggle({Name = "Fullbright", CurrentValue = false, Flag = "fullbright", Callback = function(v)
    if v then Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.FogStart = 10, 12, 100000, 100000 Lighting.GlobalShadows = false Lighting.Ambient, Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178), Color3.fromRGB(178, 178, 178)
    else Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.FogStart = origLight.Brightness, origLight.ClockTime, origLight.FogEnd, origLight.FogStart Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = origLight.GlobalShadows, origLight.Ambient, origLight.OutdoorAmbient end
    notify("Fullbright", v and "ON" or "OFF")
end})

tab4:CreateSlider({Name = "FOV Camera", Range = {70, 120}, Increment = 1, Suffix = "°", CurrentValue = 70, Flag = "camfov", Callback = function(v) Camera.FieldOfView = v end})

local tab5 = Window:CreateTab("Téléportation", 4483362458)
local lieux = {["Spawn"] = Vector3.new(0, 5, 0), ["Centre"] = Vector3.new(0, 5, 100), ["Nord"] = Vector3.new(0, 5, 500), ["Sud"] = Vector3.new(0, 5, -500), ["Est"] = Vector3.new(500, 5, 0), ["Ouest"] = Vector3.new(-500, 5, 0), ["Haut"] = Vector3.new(0, 200, 0)}
local lieuSel = "Spawn"

tab5:CreateDropdown({Name = "Lieu", Options = {"Spawn", "Centre", "Nord", "Sud", "Est", "Ouest", "Haut"}, CurrentOption = {"Spawn"}, Flag = "lieu", Callback = function(o) lieuSel = o[1] end})
tab5:CreateButton({Name = "Téléporter", Callback = function() local r = getRoot() if r and lieux[lieuSel] then r.CFrame = CFrame.new(lieux[lieuSel]) notify("TP", lieuSel) end end})

tab5:CreateSection("Coordonnées")
local cx, cy, cz = 0, 5, 0
tab5:CreateInput({Name = "X", CurrentValue = "0", PlaceholderText = "0", NumbersOnly = true, Flag = "cx", Callback = function(t) cx = tonumber(t) or 0 end})
tab5:CreateInput({Name = "Y", CurrentValue = "5", PlaceholderText = "5", NumbersOnly = true, Flag = "cy", Callback = function(t) cy = tonumber(t) or 5 end})
tab5:CreateInput({Name = "Z", CurrentValue = "0", PlaceholderText = "0", NumbersOnly = true, Flag = "cz", Callback = function(t) cz = tonumber(t) or 0 end})
tab5:CreateButton({Name = "TP Coords", Callback = function() local r = getRoot() if r then r.CFrame = CFrame.new(cx, cy, cz) notify("TP", cx..","..cy..","..cz) end end})

tab5:CreateSection("Joueur")
local tpTarget = ""
tab5:CreateInput({Name = "Pseudo", CurrentValue = "", PlaceholderText = "Nom", NumbersOnly = false, Flag = "tptarget", Callback = function(t) tpTarget = t end})
tab5:CreateButton({Name = "TP Joueur", Callback = function()
    local t = Players:FindFirstChild(tpTarget)
    if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then local r = getRoot() if r then r.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) notify("TP", tpTarget) end
    else notify("Erreur", "Introuvable") end
end})

local tab6 = Window:CreateTab("Paramètres", 4483362458)
tab6:CreateSection("Anti-AFK")
if VirtualUser then LocalPlayer.Idled:Connect(function() pcall(function() VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) task.wait(1) VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame) end) end) end
tab6:CreateParagraph({Title = "Anti-AFK", Content = "Actif"})
tab6:CreateSection("Info")
tab6:CreateParagraph({Title = "TheWizard", Content = "v4.0 Ultimate"})

tab6:CreateButton({Name = "Coords", Callback = function() local r = getRoot() if r then local p = r.Position notify("Pos", string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z), 5) end end})

tab6:CreateButton({Name = "Fermer", Callback = function()
    for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
    for _, o in pairs(espObjs) do pcall(function() if o.bb then o.bb:Destroy() end if o.hl then o.hl:Destroy() end end) end
    local r = getRoot() if r then local g, v = r:FindFirstChild("twg"), r:FindFirstChild("twv") if g then g:Destroy() end if v then v:Destroy() end end
    pcall(function() chGui:Destroy() end)
    pcall(function() fovGui:Destroy() end)
    pcall(function() RayfieldLibrary:Destroy() end)
end})

local function isAimKeyPressed()
    if typeof(aim.key) == "EnumItem" then
        if aim.key.EnumType == Enum.UserInputType then return UserInputService:IsMouseButtonPressed(aim.key)
        else return UserInputService:IsKeyDown(aim.key) end
    end
    return false
end

conns["main"] = RunService.RenderStepped:Connect(function()
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    
    if aim.enabled then
        local hasTarget = false
        local targetScreenPos = nil
        
        if aim.showFov then
            local col = aim.fovColor
            if aim.currentTarget then col = aim.fovColorTarget end
            updateCircle(outerCircleSegments, cx, cy, aim.fov, col, aim.fovThickness, aim.fovFilled and aim.fovFilledAlpha or 0)
        else
            hideCircle(outerCircleSegments)
        end
        
        if aim.showInnerFov then
            updateCircle(innerCircleSegments, cx, cy, aim.innerFov, aim.innerFovColor, aim.fovThickness, 0)
        else
            hideCircle(innerCircleSegments)
        end
        
        if isAimKeyPressed() then
            local target, vel, tRoot
            
            if aim.targetLock and aim.currentTarget and aim.currentTarget.Parent then
                local hum = aim.currentTarget.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and isVisible(aim.currentTarget) then
                    target = aim.currentTarget
                    tRoot = aim.currentTarget.Parent:FindFirstChild("HumanoidRootPart")
                    vel = tRoot and tRoot.Velocity or Vector3.new(0, 0, 0)
                else
                    aim.currentTarget = nil
                    target, vel, tRoot = findTarget()
                end
            else
                target, vel, tRoot = findTarget()
            end
            
            if aim.targetLock and target then aim.currentTarget = target end
            
            if target then
                hasTarget = true
                local predictedPos = getPredictedPos(target, tRoot)
                local pos, vis = Camera:WorldToViewportPoint(predictedPos)
                
                if vis then
                    targetScreenPos = Vector2.new(pos.X, pos.Y)
                    local c = Vector2.new(cx, cy)
                    local screenDist = (targetScreenPos - c).Magnitude
                    local myRoot = getRoot()
                    local dist = myRoot and (myRoot.Position - target.Position).Magnitude or 100
                    
                    local smooth = getSmooth(dist, screenDist)
                    local smoothFactor = aim.flickMode and aim.flickSpeed or (16 - smooth)
                    
                    local dx = (pos.X - cx) / smoothFactor
                    local dy = (pos.Y - cy) / smoothFactor
                    
                    local hx, hy = addHumanization()
                    dx = dx + hx
                    dy = dy + hy
                    
                    if not aim.silentAim then
                        Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-dy), math.rad(-dx), 0)
                    end
                end
            end
        else
            if not aim.targetLock then aim.currentTarget = nil end
        end
        
        if aim.showTargetLine and targetScreenPos then
            local dx = targetScreenPos.X - cx
            local dy = targetScreenPos.Y - cy
            local len = math.sqrt(dx * dx + dy * dy)
            local angle = math.deg(math.atan2(dy, dx))
            
            targetLine.Position = UDim2.new(0, cx, 0, cy)
            targetLine.Size = UDim2.new(0, len, 0, 2)
            targetLine.Rotation = angle
            targetLine.BackgroundColor3 = aim.fovColorTarget
            targetLine.Visible = true
            
            targetDot.Position = UDim2.new(0, targetScreenPos.X, 0, targetScreenPos.Y)
            targetDot.BackgroundColor3 = aim.fovColorTarget
            targetDot.Visible = true
        else
            targetLine.Visible = false
            targetDot.Visible = false
        end
        
        if aim.triggerBot then doTriggerBot() end
    else
        hideCircle(outerCircleSegments)
        hideCircle(innerCircleSegments)
        targetLine.Visible = false
        targetDot.Visible = false
        targetInfo.Visible = false
    end
    
    if esp then updateEsp() end
end)

notify("TheWizard", "v4.0 Ultimate", 5)
pcall(function() RayfieldLibrary:LoadConfiguration() end)
