local RayfieldLibrary = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not RayfieldLibrary then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TheWizard",
        Text = "Erreur de chargement",
        Duration = 5
    })
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)

local noclip, godmode, esp, aimbot, crosshair = false, false, false, false, false
local espColor = Color3.fromRGB(255, 0, 0)
local espBox, espName, espHealth, espDist, espTracer, espSkeleton = true, true, true, true, false, false
local aimFov, aimSmooth, aimPrediction = 150, 5, 0.12
local aimPart = "Head"
local aimKey = Enum.UserInputType.MouseButton2
local aimWallCheck, aimTeamCheck, aimShowFov = true, false, true
local chSize = 10
local chColor = Color3.fromRGB(255, 255, 255)
local flying, flyspeed = false, 50

local conns = {}
local espObjs = {}

local origLight = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

local function notify(t, c, d)
    pcall(function()
        RayfieldLibrary:Notify({Title = t, Content = c, Duration = d or 3})
    end)
end

local function getChar() return LocalPlayer and LocalPlayer.Character end
local function getHum() local c = getChar() return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end

local function disconn(n)
    if conns[n] then pcall(function() conns[n]:Disconnect() end) conns[n] = nil end
end

local function isTeammate(plr)
    if not aimTeamCheck then return false end
    return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
end

local function isVisible(part)
    if not aimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = Ray.new(origin, dir)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, Camera})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local Window = RayfieldLibrary:CreateWindow({
    Name = "TheWizard",
    Icon = 0,
    LoadingTitle = "TheWizard",
    LoadingSubtitle = "Chargement...",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TheWizard",
        FileName = "config"
    },
    Discord = {Enabled = false, Invite = "noinvite", RememberJoins = true},
    KeySystem = true,
    KeySettings = {
        Title = "TheWizard - Authentification",
        Subtitle = "Entrez la clé pour accéder",
        Note = "Contactez le développeur pour obtenir une clé",
        FileName = "TheWizardKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"TheWizardBest"}
    }
})

local tab1 = Window:CreateTab("Principal", 4483362458)
tab1:CreateSection("Joueur")

tab1:CreateButton({
    Name = "TP Spawn",
    Callback = function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(0, 5, 0) notify("TP", "Spawn") end
    end,
})

tab1:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "noclip",
    Callback = function(v)
        noclip = v
        disconn("noclip")
        if v then
            conns["noclip"] = RunService.Stepped:Connect(function()
                if noclip then
                    local c = getChar()
                    if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
                end
            end)
        else
            local c = getChar()
            if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end
        end
        notify("NoClip", v and "ON" or "OFF")
    end,
})

tab1:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "godmode",
    Callback = function(v)
        godmode = v
        disconn("godmode")
        local h = getHum()
        if v then
            if h then h.MaxHealth, h.Health = math.huge, math.huge end
            conns["godmode"] = RunService.Heartbeat:Connect(function()
                if godmode then local hum = getHum() if hum then hum.MaxHealth, hum.Health = math.huge, math.huge end end
            end)
        else
            if h then h.MaxHealth, h.Health = 100, 100 end
        end
        notify("God Mode", v and "ON" or "OFF")
    end,
})

tab1:CreateSlider({
    Name = "Vitesse",
    Range = {16, 200},
    Increment = 1,
    Suffix = " WS",
    CurrentValue = 16,
    Flag = "speed",
    Callback = function(v) local h = getHum() if h then h.WalkSpeed = v end end,
})

tab1:CreateSlider({
    Name = "Saut",
    Range = {50, 300},
    Increment = 5,
    Suffix = " JP",
    CurrentValue = 50,
    Flag = "jump",
    Callback = function(v) local h = getHum() if h then h.JumpPower = v end end,
})

tab1:CreateSlider({
    Name = "Gravité",
    Range = {0, 400},
    Increment = 10,
    Suffix = " G",
    CurrentValue = 196,
    Flag = "gravity",
    Callback = function(v) workspace.Gravity = v end,
})

tab1:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "infjump",
    Callback = function(v)
        disconn("infjump")
        if v then
            conns["infjump"] = UserInputService.JumpRequest:Connect(function()
                local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("Inf Jump", v and "ON" or "OFF")
    end,
})

tab1:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly",
    Callback = function(v)
        flying = v
        disconn("fly")
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
            if r then
                local g, vel = r:FindFirstChild("twg"), r:FindFirstChild("twv")
                if g then g:Destroy() end if vel then vel:Destroy() end
            end
        end
        notify("Fly", v and "ON" or "OFF")
    end,
})

tab1:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "flyspeed",
    Callback = function(v) flyspeed = v end,
})

local tab2 = Window:CreateTab("Combat", 4483362458)
tab2:CreateSection("ESP Avancé")

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
        local head = char:WaitForChild("Head", 5)
        local hum = char:WaitForChild("Humanoid", 5)
        if not root or not head or not hum then return end
        
        for _, v in pairs(char:GetChildren()) do if v.Name == "twesp" or v.Name == "twhl" then v:Destroy() end end
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "twesp"
        bb.Adornee = root
        bb.Size = UDim2.new(0, 200, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = char
        
        local container = Instance.new("Frame")
        container.Name = "c"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = bb
        
        local nm = Instance.new("TextLabel")
        nm.Name = "n"
        nm.Size = UDim2.new(1, 0, 0, 16)
        nm.Position = UDim2.new(0, 0, 0, 0)
        nm.BackgroundTransparency = 1
        nm.TextColor3 = espColor
        nm.TextStrokeTransparency = 0
        nm.TextStrokeColor3 = Color3.new(0, 0, 0)
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 14
        nm.Text = plr.Name
        nm.Parent = container
        
        local hpBg = Instance.new("Frame")
        hpBg.Name = "hpbg"
        hpBg.Size = UDim2.new(0.6, 0, 0, 6)
        hpBg.Position = UDim2.new(0.2, 0, 0, 18)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = container
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 3)
        
        local hpBar = Instance.new("Frame")
        hpBar.Name = "hp"
        hpBar.Size = UDim2.new(1, 0, 1, 0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = hpBg
        Instance.new("UICorner", hpBar).CornerRadius = UDim.new(0, 3)
        
        local hpTxt = Instance.new("TextLabel")
        hpTxt.Name = "htxt"
        hpTxt.Size = UDim2.new(1, 0, 0, 14)
        hpTxt.Position = UDim2.new(0, 0, 0, 26)
        hpTxt.BackgroundTransparency = 1
        hpTxt.TextColor3 = Color3.new(1, 1, 1)
        hpTxt.TextStrokeTransparency = 0
        hpTxt.Font = Enum.Font.Gotham
        hpTxt.TextSize = 12
        hpTxt.Parent = container
        
        local distTxt = Instance.new("TextLabel")
        distTxt.Name = "dist"
        distTxt.Size = UDim2.new(1, 0, 0, 12)
        distTxt.Position = UDim2.new(0, 0, 0, 40)
        distTxt.BackgroundTransparency = 1
        distTxt.TextColor3 = Color3.fromRGB(200, 200, 200)
        distTxt.TextStrokeTransparency = 0
        distTxt.Font = Enum.Font.Gotham
        distTxt.TextSize = 11
        distTxt.Parent = container
        
        local hl = Instance.new("Highlight")
        hl.Name = "twhl"
        hl.FillColor = espColor
        hl.FillTransparency = 0.7
        hl.OutlineColor = espColor
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        
        espObjs[plr.Name] = {bb = bb, hl = hl, hpBar = hpBar, hpTxt = hpTxt, distTxt = distTxt, nm = nm, char = char}
        bb.Enabled = esp
        hl.Enabled = esp and espBox
    end
    
    if plr.Character then create(plr.Character) end
    plr.CharacterAdded:Connect(function(c) task.wait(0.5) create(c) end)
end

local function removeEsp(plr)
    local o = espObjs[plr.Name]
    if o then
        pcall(function() if o.bb then o.bb:Destroy() end end)
        pcall(function() if o.hl then o.hl:Destroy() end end)
        espObjs[plr.Name] = nil
    end
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
                        local pct = math.clamp((hum.Health / hum.MaxHealth) * 100, 0, 100)
                        local col = getHealthColor(pct)
                        
                        if o.hpBar then
                            o.hpBar.Size = UDim2.new(pct / 100, 0, 1, 0)
                            o.hpBar.BackgroundColor3 = col
                        end
                        
                        if o.hpTxt and espHealth then
                            o.hpTxt.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. " HP"
                            o.hpTxt.Visible = true
                        elseif o.hpTxt then
                            o.hpTxt.Visible = false
                        end
                        
                        if o.distTxt and espDist and myRoot then
                            local dist = (myRoot.Position - root.Position).Magnitude
                            o.distTxt.Text = "[" .. math.floor(dist) .. "m]"
                            o.distTxt.Visible = true
                        elseif o.distTxt then
                            o.distTxt.Visible = false
                        end
                        
                        if o.nm then
                            o.nm.Visible = espName
                            o.nm.TextColor3 = espColor
                        end
                        
                        if o.hl then
                            o.hl.FillColor = espColor
                            o.hl.OutlineColor = espColor
                        end
                    end
                end
            end
        end
    end
end

for _, p in pairs(Players:GetPlayers()) do setupEsp(p) end
Players.PlayerAdded:Connect(setupEsp)
Players.PlayerRemoving:Connect(removeEsp)

tab2:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Flag = "esp",
    Callback = function(v) esp = v updateEsp() notify("ESP", v and "ON" or "OFF") end,
})

tab2:CreateToggle({
    Name = "ESP Box/Highlight",
    CurrentValue = true,
    Flag = "espbox",
    Callback = function(v) espBox = v end,
})

tab2:CreateToggle({
    Name = "ESP Nom",
    CurrentValue = true,
    Flag = "espname",
    Callback = function(v) espName = v end,
})

tab2:CreateToggle({
    Name = "ESP Santé",
    CurrentValue = true,
    Flag = "esphealth",
    Callback = function(v) espHealth = v end,
})

tab2:CreateToggle({
    Name = "ESP Distance",
    CurrentValue = true,
    Flag = "espdist",
    Callback = function(v) espDist = v end,
})

tab2:CreateColorPicker({
    Name = "Couleur ESP",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "espcolor",
    Callback = function(c) espColor = c end,
})

tab2:CreateSection("AimBot Pro")

local fovCircle = Instance.new("ScreenGui")
fovCircle.Name = "twfov"
fovCircle.ResetOnSpawn = false
fovCircle.IgnoreGuiInset = true
pcall(function() fovCircle.Parent = CoreGui end)
if not fovCircle.Parent then fovCircle.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local fovFrame = Instance.new("Frame")
fovFrame.Name = "fov"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
fovFrame.BackgroundTransparency = 1
fovFrame.Parent = fovCircle

local fovImage = Instance.new("ImageLabel")
fovImage.Name = "circle"
fovImage.AnchorPoint = Vector2.new(0.5, 0.5)
fovImage.Position = UDim2.new(0.5, 0, 0.5, 0)
fovImage.BackgroundTransparency = 1
fovImage.Image = "rbxassetid://3570695787"
fovImage.ImageColor3 = Color3.new(1, 1, 1)
fovImage.ImageTransparency = 0.7
fovImage.Parent = fovFrame

fovCircle.Enabled = false

local function updateFovCircle()
    fovImage.Size = UDim2.new(0, aimFov * 2, 0, aimFov * 2)
    fovCircle.Enabled = aimbot and aimShowFov
end

local function getPredictedPos(part, velocity)
    if not aimPrediction or aimPrediction == 0 then return part.Position end
    return part.Position + (velocity * aimPrediction)
end

local function findTarget()
    local best = aimFov
    local target = nil
    local targetVel = Vector3.new(0, 0, 0)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if isTeammate(plr) then continue end
        
        local c = plr.Character
        if not c then continue end
        
        local part = c:FindFirstChild(aimPart) or c:FindFirstChild("Head")
        local hum = c:FindFirstChildOfClass("Humanoid")
        local root = c:FindFirstChild("HumanoidRootPart")
        
        if not part or not hum or hum.Health <= 0 then continue end
        if not isVisible(part) then continue end
        
        local vel = root and root.Velocity or Vector3.new(0, 0, 0)
        local predictedPos = getPredictedPos(part, vel)
        local pos, vis = Camera:WorldToViewportPoint(predictedPos)
        
        if not vis then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < best then
            best = dist
            target = part
            targetVel = vel
        end
    end
    return target, targetVel
end

local currentTarget = nil
local targetLock = false

tab2:CreateToggle({
    Name = "AimBot",
    CurrentValue = false,
    Flag = "aimbot",
    Callback = function(v)
        aimbot = v
        updateFovCircle()
        notify("AimBot", v and "ON" or "OFF")
    end,
})

tab2:CreateToggle({
    Name = "Target Lock",
    Description = "Verrouille sur la cible",
    CurrentValue = false,
    Flag = "aimlock",
    Callback = function(v) targetLock = v if not v then currentTarget = nil end end,
})

tab2:CreateToggle({
    Name = "Afficher FOV",
    CurrentValue = true,
    Flag = "showfov",
    Callback = function(v) aimShowFov = v updateFovCircle() end,
})

tab2:CreateToggle({
    Name = "Wall Check",
    Description = "Ignore les cibles derrière les murs",
    CurrentValue = true,
    Flag = "wallcheck",
    Callback = function(v) aimWallCheck = v end,
})

tab2:CreateToggle({
    Name = "Team Check",
    Description = "Ignore les coéquipiers",
    CurrentValue = false,
    Flag = "teamcheck",
    Callback = function(v) aimTeamCheck = v end,
})

tab2:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 150,
    Flag = "aimfov",
    Callback = function(v) aimFov = v updateFovCircle() end,
})

tab2:CreateSlider({
    Name = "Smoothness",
    Description = "1 = Snap, 10 = Très fluide",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 5,
    Flag = "aimsmooth",
    Callback = function(v) aimSmooth = v end,
})

tab2:CreateSlider({
    Name = "Prédiction",
    Description = "Anticipe le mouvement",
    Range = {0, 0.3},
    Increment = 0.01,
    CurrentValue = 0.12,
    Flag = "aimpred",
    Callback = function(v) aimPrediction = v end,
})

tab2:CreateDropdown({
    Name = "Partie visée",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Flag = "aimpart",
    Callback = function(o) aimPart = o[1] end,
})

tab2:CreateDropdown({
    Name = "Touche AimBot",
    Options = {"Clic Droit", "Clic Gauche", "Shift", "E", "Q"},
    CurrentOption = {"Clic Droit"},
    Flag = "aimkey",
    Callback = function(o)
        local keys = {
            ["Clic Droit"] = Enum.UserInputType.MouseButton2,
            ["Clic Gauche"] = Enum.UserInputType.MouseButton1,
            ["Shift"] = Enum.KeyCode.LeftShift,
            ["E"] = Enum.KeyCode.E,
            ["Q"] = Enum.KeyCode.Q
        }
        aimKey = keys[o[1]] or Enum.UserInputType.MouseButton2
    end,
})

local tab3 = Window:CreateTab("Visuels", 4483362458)
tab3:CreateSection("Crosshair")

local chGui = Instance.new("ScreenGui")
chGui.Name = "twch"
chGui.ResetOnSpawn = false
chGui.IgnoreGuiInset = true
pcall(function() chGui.Parent = CoreGui end)
if not chGui.Parent then chGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local chFrame = Instance.new("Frame")
chFrame.AnchorPoint = Vector2.new(0.5, 0.5)
chFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
chFrame.Size = UDim2.new(0, 20, 0, 20)
chFrame.BackgroundTransparency = 1
chFrame.Parent = chGui

local function mkLine(sx, sy, px, py)
    local l = Instance.new("Frame")
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.Size = UDim2.new(0, sx, 0, sy)
    l.Position = UDim2.new(0.5, px, 0.5, py)
    l.BackgroundColor3 = chColor
    l.BorderSizePixel = 0
    l.Parent = chFrame
    return l
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

local function updChColor()
    chT.BackgroundColor3, chB.BackgroundColor3, chL.BackgroundColor3, chR.BackgroundColor3, chD.BackgroundColor3 = chColor, chColor, chColor, chColor, chColor
end

tab3:CreateToggle({
    Name = "Crosshair",
    CurrentValue = false,
    Flag = "crosshair",
    Callback = function(v) crosshair = v chGui.Enabled = v end,
})

tab3:CreateColorPicker({
    Name = "Couleur",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "chcolor",
    Callback = function(c) chColor = c updChColor() end,
})

tab3:CreateSlider({
    Name = "Taille",
    Range = {5, 50},
    Increment = 1,
    Suffix = " px",
    CurrentValue = 10,
    Flag = "chsize",
    Callback = function(v) chSize = v updChSize() end,
})

tab3:CreateSection("Environnement")

tab3:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "fullbright",
    Callback = function(v)
        if v then
            Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.FogStart = 10, 12, 100000, 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient, Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178), Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.FogStart = origLight.Brightness, origLight.ClockTime, origLight.FogEnd, origLight.FogStart
            Lighting.GlobalShadows, Lighting.Ambient, Lighting.OutdoorAmbient = origLight.GlobalShadows, origLight.Ambient, origLight.OutdoorAmbient
        end
        notify("Fullbright", v and "ON" or "OFF")
    end,
})

tab3:CreateSlider({
    Name = "FOV Camera",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "fov",
    Callback = function(v) Camera.FieldOfView = v end,
})

local tab4 = Window:CreateTab("Téléportation", 4483362458)

local lieux = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Centre"] = Vector3.new(0, 5, 100),
    ["Nord"] = Vector3.new(0, 5, 500),
    ["Sud"] = Vector3.new(0, 5, -500),
    ["Est"] = Vector3.new(500, 5, 0),
    ["Ouest"] = Vector3.new(-500, 5, 0),
    ["Haut"] = Vector3.new(0, 200, 0),
    ["Très Haut"] = Vector3.new(0, 500, 0),
}

local lieuSel = "Spawn"

tab4:CreateDropdown({
    Name = "Lieu",
    Options = {"Spawn", "Centre", "Nord", "Sud", "Est", "Ouest", "Haut", "Très Haut"},
    CurrentOption = {"Spawn"},
    Flag = "lieu",
    Callback = function(o) lieuSel = o[1] end,
})

tab4:CreateButton({
    Name = "Téléporter",
    Callback = function()
        local r = getRoot()
        if r and lieux[lieuSel] then r.CFrame = CFrame.new(lieux[lieuSel]) notify("TP", lieuSel) end
    end,
})

tab4:CreateSection("Coordonnées")
local cx, cy, cz = 0, 5, 0

tab4:CreateInput({Name = "X", CurrentValue = "0", PlaceholderText = "0", NumbersOnly = true, Flag = "cx", Callback = function(t) cx = tonumber(t) or 0 end})
tab4:CreateInput({Name = "Y", CurrentValue = "5", PlaceholderText = "5", NumbersOnly = true, Flag = "cy", Callback = function(t) cy = tonumber(t) or 5 end})
tab4:CreateInput({Name = "Z", CurrentValue = "0", PlaceholderText = "0", NumbersOnly = true, Flag = "cz", Callback = function(t) cz = tonumber(t) or 0 end})

tab4:CreateButton({
    Name = "TP Coords",
    Callback = function()
        local r = getRoot()
        if r then r.CFrame = CFrame.new(cx, cy, cz) notify("TP", string.format("%d, %d, %d", cx, cy, cz)) end
    end,
})

tab4:CreateSection("Joueur")
local tpTarget = ""

tab4:CreateInput({Name = "Pseudo", CurrentValue = "", PlaceholderText = "Nom", NumbersOnly = false, Flag = "tptarget", Callback = function(t) tpTarget = t end})

tab4:CreateButton({
    Name = "TP Joueur",
    Callback = function()
        local t = Players:FindFirstChild(tpTarget)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local r = getRoot()
            if r then r.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) notify("TP", tpTarget) end
        else notify("Erreur", "Joueur introuvable") end
    end,
})

local tab5 = Window:CreateTab("Paramètres", 4483362458)
tab5:CreateSection("Anti-AFK")

if VirtualUser then
    LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end)
end

tab5:CreateParagraph({Title = "Anti-AFK", Content = "Actif automatiquement"})
tab5:CreateSection("Interface")

tab5:CreateKeybind({Name = "Toggle Menu", CurrentKeybind = "RightShift", HoldToInteract = false, Flag = "keybind", Callback = function() end})

tab5:CreateSection("Info")
tab5:CreateParagraph({Title = "TheWizard", Content = "v3.0 Pro"})

tab5:CreateButton({
    Name = "Coords",
    Callback = function()
        local r = getRoot()
        if r then local p = r.Position notify("Position", string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z), 5) end
    end,
})

tab5:CreateButton({
    Name = "Fermer",
    Callback = function()
        for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
        for _, o in pairs(espObjs) do pcall(function() if o.bb then o.bb:Destroy() end if o.hl then o.hl:Destroy() end end) end
        local r = getRoot()
        if r then local g, v = r:FindFirstChild("twg"), r:FindFirstChild("twv") if g then g:Destroy() end if v then v:Destroy() end end
        pcall(function() chGui:Destroy() end)
        pcall(function() fovCircle:Destroy() end)
        pcall(function() RayfieldLibrary:Destroy() end)
    end,
})

local function isAimKeyPressed()
    if typeof(aimKey) == "EnumItem" then
        if aimKey.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(aimKey)
        else
            return UserInputService:IsKeyDown(aimKey)
        end
    end
    return false
end

conns["main"] = RunService.RenderStepped:Connect(function()
    if aimbot then
        updateFovCircle()
        
        if isAimKeyPressed() then
            local target, vel
            
            if targetLock and currentTarget and currentTarget.Parent then
                local hum = currentTarget.Parent:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and isVisible(currentTarget) then
                    target = currentTarget
                    vel = currentTarget.Parent:FindFirstChild("HumanoidRootPart") and currentTarget.Parent.HumanoidRootPart.Velocity or Vector3.new(0,0,0)
                else
                    currentTarget = nil
                    target, vel = findTarget()
                end
            else
                target, vel = findTarget()
            end
            
            if targetLock and target then currentTarget = target end
            
            if target then
                local predictedPos = getPredictedPos(target, vel or Vector3.new(0,0,0))
                local pos = Camera:WorldToViewportPoint(predictedPos)
                local c = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                
                local smoothFactor = 11 - aimSmooth
                local dx = (pos.X - c.X) / (smoothFactor * 8)
                local dy = (pos.Y - c.Y) / (smoothFactor * 8)
                
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-dy), math.rad(-dx), 0)
            end
        else
            if not targetLock then currentTarget = nil end
        end
    end
    
    if esp then updateEsp() end
end)

notify("TheWizard", "v3.0 Pro chargé", 5)
pcall(function() RayfieldLibrary:LoadConfiguration() end)
