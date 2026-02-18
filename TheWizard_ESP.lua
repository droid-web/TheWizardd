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
local aimFov, aimSmooth = 100, 3
local chSize = 10
local chColor = Color3.fromRGB(255, 255, 255)

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
    if conns[n] then
        pcall(function() conns[n]:Disconnect() end)
        conns[n] = nil
    end
end

local Window = RayfieldLibrary:CreateWindow({
    Name = "TheWizard",
    Icon = 0,
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "par TheWizard",
    Theme = "Amethyst",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TheWizard",
        FileName = "config"
    },
    Discord = {Enabled = false, Invite = "noinvite", RememberJoins = true},
    KeySystem = false,
})

local tab1 = Window:CreateTab("Principal", 4483362458)
tab1:CreateSection("Joueur")

tab1:CreateButton({
    Name = "TP Spawn",
    Callback = function()
        local r = getRoot()
        if r then
            r.CFrame = CFrame.new(0, 5, 0)
            notify("TP", "Spawn")
        end
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
                    if c then
                        for _, p in pairs(c:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end
            end)
        else
            local c = getChar()
            if c then
                for _, p in pairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
                end
            end
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
                if godmode then
                    local hum = getHum()
                    if hum then hum.MaxHealth, hum.Health = math.huge, math.huge end
                end
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
                local h = getHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        notify("Inf Jump", v and "ON" or "OFF")
    end,
})

local flying = false
local flyspeed = 50

tab1:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "fly",
    Callback = function(v)
        flying = v
        disconn("fly")
        local r = getRoot()
        if v and r then
            local bg = Instance.new("BodyGyro")
            bg.Name = "twg"
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = r.CFrame
            bg.Parent = r
            
            local bv = Instance.new("BodyVelocity")
            bv.Name = "twv"
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = r
            
            conns["fly"] = RunService.RenderStepped:Connect(function()
                if flying and r then
                    local g = r:FindFirstChild("twg")
                    local vel = r:FindFirstChild("twv")
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
                local g = r:FindFirstChild("twg")
                local vel = r:FindFirstChild("twv")
                if g then g:Destroy() end
                if vel then vel:Destroy() end
            end
        end
        notify("Fly", v and "ON (WASD+Space/Ctrl)" or "OFF")
    end,
})

tab1:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    Suffix = "",
    CurrentValue = 50,
    Flag = "flyspeed",
    Callback = function(v) flyspeed = v end,
})

local tab2 = Window:CreateTab("Combat", 4483362458)
tab2:CreateSection("ESP")

local function setupEsp(plr)
    if plr == LocalPlayer then return end
    
    local function create(char)
        if not char then return end
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local old = head:FindFirstChild("twesp")
        if old then old:Destroy() end
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "twesp"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 100, 0, 40)
        bb.StudsOffset = Vector3.new(0, 2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = head
        
        local nm = Instance.new("TextLabel")
        nm.Name = "n"
        nm.Size = UDim2.new(1, 0, 0.5, 0)
        nm.BackgroundTransparency = 1
        nm.TextColor3 = espColor
        nm.TextStrokeTransparency = 0
        nm.Font = Enum.Font.GothamBold
        nm.TextSize = 14
        nm.Text = plr.Name
        nm.Parent = bb
        
        local hp = Instance.new("TextLabel")
        hp.Name = "h"
        hp.Size = UDim2.new(1, 0, 0.5, 0)
        hp.Position = UDim2.new(0, 0, 0.5, 0)
        hp.BackgroundTransparency = 1
        hp.TextColor3 = Color3.fromRGB(0, 255, 0)
        hp.TextStrokeTransparency = 0
        hp.Font = Enum.Font.GothamBold
        hp.TextSize = 12
        hp.Parent = bb
        
        local hl = Instance.new("Highlight")
        hl.Name = "twhl"
        hl.FillColor = espColor
        hl.FillTransparency = 0.8
        hl.OutlineColor = espColor
        hl.Parent = char
        
        espObjs[plr.Name] = {bb = bb, hl = hl, hp = hp}
        bb.Enabled = esp
        hl.Enabled = esp
    end
    
    if plr.Character then create(plr.Character) end
    plr.CharacterAdded:Connect(function(c) task.wait(0.5) create(c) end)
end

local function removeEsp(plr)
    local o = espObjs[plr.Name]
    if o then
        if o.bb then pcall(function() o.bb:Destroy() end) end
        if o.hl then pcall(function() o.hl:Destroy() end) end
        espObjs[plr.Name] = nil
    end
end

local function updateEsp()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local o = espObjs[plr.Name]
            if o then
                if o.bb then o.bb.Enabled = esp end
                if o.hl then o.hl.Enabled = esp end
                if esp and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and o.hp then
                        local pct = (hum.Health / hum.MaxHealth) * 100
                        o.hp.Text = math.floor(hum.Health) .. " HP"
                        if pct > 66 then o.hp.TextColor3 = Color3.fromRGB(0, 255, 0)
                        elseif pct > 33 then o.hp.TextColor3 = Color3.fromRGB(255, 255, 0)
                        else o.hp.TextColor3 = Color3.fromRGB(255, 0, 0) end
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
    Callback = function(v)
        esp = v
        updateEsp()
        notify("ESP", v and "ON" or "OFF")
    end,
})

tab2:CreateColorPicker({
    Name = "Couleur ESP",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "espcolor",
    Callback = function(c)
        espColor = c
        for _, o in pairs(espObjs) do
            if o.hl then o.hl.FillColor, o.hl.OutlineColor = c, c end
            if o.bb then local n = o.bb:FindFirstChild("n") if n then n.TextColor3 = c end end
        end
    end,
})

tab2:CreateSection("AimBot")

local function findTarget()
    local best = aimFov
    local target = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local c = plr.Character
        if not c then continue end
        local head = c:FindFirstChild("Head")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not head or not hum or hum.Health <= 0 then continue end
        
        local pos, vis = Camera:WorldToViewportPoint(head.Position)
        if not vis then continue end
        
        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
        if dist < best then
            best = dist
            target = head
        end
    end
    return target
end

tab2:CreateToggle({
    Name = "AimBot",
    CurrentValue = false,
    Flag = "aimbot",
    Callback = function(v)
        aimbot = v
        notify("AimBot", v and "ON (clic droit)" or "OFF")
    end,
})

tab2:CreateSlider({
    Name = "FOV",
    Range = {50, 500},
    Increment = 10,
    Suffix = " px",
    CurrentValue = 100,
    Flag = "aimfov",
    Callback = function(v) aimFov = v end,
})

tab2:CreateSlider({
    Name = "Smooth",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 3,
    Flag = "aimsmooth",
    Callback = function(v) aimSmooth = v end,
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

local chT = mkLine(2, 10, 0, -8)
local chB = mkLine(2, 10, 0, 8)
local chL = mkLine(10, 2, -8, 0)
local chR = mkLine(10, 2, 8, 0)
local chD = mkLine(4, 4, 0, 0)
chGui.Enabled = false

local function updChSize()
    local s = chSize
    chT.Size, chT.Position = UDim2.new(0, 2, 0, s), UDim2.new(0.5, 0, 0.5, -s - 2)
    chB.Size, chB.Position = UDim2.new(0, 2, 0, s), UDim2.new(0.5, 0, 0.5, s + 2)
    chL.Size, chL.Position = UDim2.new(0, s, 0, 2), UDim2.new(0.5, -s - 2, 0.5, 0)
    chR.Size, chR.Position = UDim2.new(0, s, 0, 2), UDim2.new(0.5, s + 2, 0.5, 0)
end

local function updChColor()
    chT.BackgroundColor3 = chColor
    chB.BackgroundColor3 = chColor
    chL.BackgroundColor3 = chColor
    chR.BackgroundColor3 = chColor
    chD.BackgroundColor3 = chColor
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
            Lighting.Brightness = 10
            Lighting.ClockTime = 12
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = origLight.Brightness
            Lighting.ClockTime = origLight.ClockTime
            Lighting.FogEnd = origLight.FogEnd
            Lighting.FogStart = origLight.FogStart
            Lighting.GlobalShadows = origLight.GlobalShadows
            Lighting.Ambient = origLight.Ambient
            Lighting.OutdoorAmbient = origLight.OutdoorAmbient
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
    MultipleOptions = false,
    Callback = function(o) lieuSel = o[1] end,
})

tab4:CreateButton({
    Name = "Téléporter",
    Callback = function()
        local r = getRoot()
        if r and lieux[lieuSel] then
            r.CFrame = CFrame.new(lieux[lieuSel])
            notify("TP", lieuSel)
        end
    end,
})

tab4:CreateSection("Coordonnées")
local cx, cy, cz = 0, 5, 0

tab4:CreateInput({
    Name = "X",
    CurrentValue = "0",
    PlaceholderText = "0",
    NumbersOnly = true,
    Flag = "cx",
    Callback = function(t) cx = tonumber(t) or 0 end,
})

tab4:CreateInput({
    Name = "Y",
    CurrentValue = "5",
    PlaceholderText = "5",
    NumbersOnly = true,
    Flag = "cy",
    Callback = function(t) cy = tonumber(t) or 5 end,
})

tab4:CreateInput({
    Name = "Z",
    CurrentValue = "0",
    PlaceholderText = "0",
    NumbersOnly = true,
    Flag = "cz",
    Callback = function(t) cz = tonumber(t) or 0 end,
})

tab4:CreateButton({
    Name = "TP Coords",
    Callback = function()
        local r = getRoot()
        if r then
            r.CFrame = CFrame.new(cx, cy, cz)
            notify("TP", string.format("%d, %d, %d", cx, cy, cz))
        end
    end,
})

tab4:CreateSection("Joueur")
local tpTarget = ""

tab4:CreateInput({
    Name = "Pseudo",
    CurrentValue = "",
    PlaceholderText = "Nom",
    NumbersOnly = false,
    Flag = "tptarget",
    Callback = function(t) tpTarget = t end,
})

tab4:CreateButton({
    Name = "TP Joueur",
    Callback = function()
        local t = Players:FindFirstChild(tpTarget)
        if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            local r = getRoot()
            if r then
                r.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                notify("TP", tpTarget)
            end
        else
            notify("Erreur", "Joueur introuvable")
        end
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

tab5:CreateKeybind({
    Name = "Toggle Menu",
    CurrentKeybind = "RightShift",
    HoldToInteract = false,
    Flag = "keybind",
    Callback = function() end,
})

tab5:CreateSection("Info")

tab5:CreateParagraph({Title = "TheWizard", Content = "v2.2"})

tab5:CreateButton({
    Name = "Coords",
    Callback = function()
        local r = getRoot()
        if r then
            local p = r.Position
            notify("Position", string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z), 5)
        end
    end,
})

tab5:CreateButton({
    Name = "Fermer",
    Callback = function()
        for _, c in pairs(conns) do pcall(function() c:Disconnect() end) end
        for _, o in pairs(espObjs) do
            pcall(function() if o.bb then o.bb:Destroy() end if o.hl then o.hl:Destroy() end end)
        end
        local r = getRoot()
        if r then
            local g = r:FindFirstChild("twg")
            local v = r:FindFirstChild("twv")
            if g then g:Destroy() end
            if v then v:Destroy() end
        end
        pcall(function() chGui:Destroy() end)
        pcall(function() RayfieldLibrary:Destroy() end)
    end,
})

conns["main"] = RunService.RenderStepped:Connect(function()
    if aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = findTarget()
        if t then
            local pos = Camera:WorldToViewportPoint(t.Position)
            local c = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dx = (pos.X - c.X) / (aimSmooth * 50)
            local dy = (pos.Y - c.Y) / (aimSmooth * 50)
            Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-dy), math.rad(-dx), 0)
        end
    end
    if esp then updateEsp() end
end)

notify("TheWizard", "Chargé", 5)
pcall(function() RayfieldLibrary:LoadConfiguration() end)
