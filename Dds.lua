-- VLC SAFE SPEED v1.3 — Part 1/3
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local VERSION = "v1.3"

local COL = {
    bg=Color3.fromRGB(12,12,16), bg2=Color3.fromRGB(20,20,26),
    panel=Color3.fromRGB(16,16,22), input=Color3.fromRGB(36,36,44),
    status=Color3.fromRGB(24,24,32), stroke=Color3.fromRGB(120,70,220),
    strokeDim=Color3.fromRGB(50,35,90), accent=Color3.fromRGB(160,90,255),
    text=Color3.fromRGB(230,225,245), textDim=Color3.fromRGB(150,140,180),
    green=Color3.fromRGB(90,230,160), red=Color3.fromRGB(255,90,110),
}
local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

local function stroke(p,c,t,tr)
    local st = Instance.new("UIStroke")
    st.Color = c; st.Thickness = t or 1; st.Transparency = tr or 0
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = p
    return st
end

local function get_container()
    if gethui then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

pcall(function()
    if CoreGui:FindFirstChild("VLC_SafeSpeed") then CoreGui["VLC_SafeSpeed"]:Destroy() end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("VLC_SafeSpeed") then pg["VLC_SafeSpeed"]:Destroy() end
end)

-- ============================================================
-- OPTIMIZATION
-- ============================================================
local function isTreeOrPlant(name)
    local n = name:lower()
    return n:find("tree") or n:find("bush") or n:find("plant")
        or n:find("flower") or n:find("grass") or n:find("leaf")
        or n:find("vine") or n:find("foliage") or n:find("shrub")
        or n:find("cactus") or n:find("mushroom") or n:find("rock")
        or n:find("stone") or n:find("cloud") or n:find("bird")
        or n:find("butterfly") or n:find("insect") or n:find("fish")
        or n:find("debris") or n:find("particle") or n:find("smoke")
        or n:find("firework") or n:find("confetti") or n:find("sparkle")
end

local function optimizeDescendant(v)
    pcall(function()
        if v:IsA("BasePart") then
            v.CastShadow = false
            if v.Material == Enum.Material.Grass
            or v.Material == Enum.Material.LeafyGrass
            or v.Material == Enum.Material.Fabric
            or v.Material == Enum.Material.Foil
            or v.Material == Enum.Material.Granite
            or v.Material == Enum.Material.Pebble
            or v.Material == Enum.Material.CorrodedMetal then
                v.Material = Enum.Material.SmoothPlastic
            end
            for _, d in ipairs(v:GetChildren()) do
                if d:IsA("Decal") or d:IsA("Texture") then
                    d.Transparency = 1
                end
            end
        end
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
        if v:IsA("ParticleEmitter") or v:IsA("Trail")
        or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")
        or v:IsA("Beam") or v:IsA("Firework") then
            v.Enabled = false
        end
        if v:IsA("Highlight") or v:IsA("SelectionBox")
        or v:IsA("SelectionSphere") or v:IsA("SurfaceGui")
        or v:IsA("BillboardGui") then
            v.Enabled = false
        end
        if v:IsA("Sound") then v.Volume = 0; v.Playing = false end
        if v:IsA("Sky") then v.Parent = nil end
        if v:IsA("Model") and isTreeOrPlant(v.Name) then v.Parent = nil end
        if v:IsA("BasePart") and isTreeOrPlant(v.Name) then
            v.Transparency = 1; v.CanCollide = false; v.CastShadow = false
        end
        if v:IsA("ForceField") then v.Visible = false end
        if v:IsA("Accessory") or v:IsA("Hat") then
            local pchar = v:FindFirstAncestorOfClass("Model")
            if pchar and pchar ~= LocalPlayer.Character then v.Parent = nil end
        end
    end)
end

local function disablePerformance()
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.ShadowSoftness = 0
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then v.Enabled = false end
            if v:IsA("Sky") then v.Parent = nil end
            if v:IsA("Atmosphere") then v.Density = 0 end
            if v:IsA("Clouds") then v.Cover = 0 end
        end
    end)
    task.spawn(function()
        for _, v in ipairs(workspace:GetDescendants()) do
            optimizeDescendant(v)
        end
    end)
end

local function startContinuousOptimize()
    workspace.DescendantAdded:Connect(function(v)
        task.spawn(function()
            optimizeDescendant(v)
            task.wait(0.3)
            optimizeDescendant(v)
        end)
    end)
    task.spawn(function()
        while true do
            task.wait(8)
            pcall(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    optimizeDescendant(v)
                end
                Lighting.GlobalShadows = false
                for _, v in ipairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") then v.Enabled = false end
                end
            end)
        end
    end)
end

disablePerformance()
startContinuousOptimize()

-- ============================================================
-- ANTI-RAGDOLL AUTO
-- ============================================================
local AntiRagdoll = true

local function attachAntiRagdoll(character)
    local hum = character:WaitForChild("Humanoid", 5)
    if not hum then return end
    local function fix()
        if not AntiRagdoll then return end
        pcall(function()
            hum.PlatformStand = false
            if hum:GetState() == Enum.HumanoidStateType.Physics
            or hum:GetState() == Enum.HumanoidStateType.FallingDown
            or hum:GetState() == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
    hum.StateChanged:Connect(function(_, newState)
        if not AntiRagdoll then return end
        if newState == Enum.HumanoidStateType.Physics
        or newState == Enum.HumanoidStateType.FallingDown
        or newState == Enum.HumanoidStateType.Ragdoll then
            task.wait(0.05); fix()
        end
    end)
    task.spawn(function()
        while character.Parent do
            task.wait(0.2); fix()
        end
    end)
end

if LocalPlayer.Character then attachAntiRagdoll(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char)
    attachAntiRagdoll(char)
    task.wait(1); disablePerformance()
end)

-- ============================================================
-- GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VLC_SafeSpeed"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = get_container()

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://9114427901"
clickSound.Volume = 0.4
clickSound.Parent = ScreenGui

local function playClick()
    pcall(function()
        local s = clickSound:Clone()
        s.Parent = ScreenGui; s:Play()
        Debris:AddItem(s, 1)
    end)
end

local SHINE_COLORS = {
    gold    = { Color3.fromRGB(255,215,0),   Color3.fromRGB(255,240,180), Color3.fromRGB(200,160,20) },
    silver  = { Color3.fromRGB(220,220,235), Color3.fromRGB(255,255,255), Color3.fromRGB(180,180,200) },
    emerald = { Color3.fromRGB(80,220,150),  Color3.fromRGB(180,255,220), Color3.fromRGB(40,160,100) },
}

local function makeShine(parent, opts)
    opts = opts or {}
    local baseWidth = opts.width or 12
    local baseTrans = opts.transparency or 0.4
    local baseSpeed = opts.speed or 1.6
    local baseDelay = opts.delay or 1.2
    local zBase = opts.z or 2
    local layers = {
        { key="gold",    widthMult=1.4, speedMult=1.15, delayOffset=0.0,  zOff=0, transOff=0.05 },
        { key="silver",  widthMult=1.0, speedMult=1.00, delayOffset=0.35, zOff=1, transOff=0.00 },
        { key="emerald", widthMult=0.7, speedMult=0.85, delayOffset=0.70, zOff=2, transOff=-0.05 },
    }
    for _, layer in ipairs(layers) do
        local cols = SHINE_COLORS[layer.key]
        local shine = Instance.new("Frame")
        shine.Size = UDim2.new(0, math.floor(baseWidth * layer.widthMult), 1.8, 0)
        shine.Position = UDim2.new(0, -60, -0.4, 0)
        shine.BackgroundColor3 = Color3.fromRGB(255,255,255)
        shine.BackgroundTransparency = math.clamp(baseTrans + layer.transOff, 0, 1)
        shine.BorderSizePixel = 0
        shine.Rotation = 18
        shine.ZIndex = zBase + layer.zOff
        shine.Parent = parent
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, cols[1]),
            ColorSequenceKeypoint.new(0.5, cols[2]),
            ColorSequenceKeypoint.new(1, cols[3]),
        })
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.05),
            NumberSequenceKeypoint.new(1, 1),
        })
        g.Parent = shine
        local speed = baseSpeed * layer.speedMult
        local delay = baseDelay + layer.delayOffset
        task.spawn(function()
            task.wait(layer.delayOffset)
            while shine.Parent do
                shine.Position = UDim2.new(0, -60, -0.4, 0)
                local tw = TweenService:Create(shine, TweenInfo.new(speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                    Position = UDim2.new(1, 20, -0.4, 0)
                })
                tw:Play(); tw.Completed:Wait(); task.wait(delay)
            end
        end)
    end
end

local BoostActive = false
local FloatBoostEnabled = true
local StatusLabel, ToggleButton, FloatBoostBtn, FloatHolder, AntiRagdollBtn

local function toggleBoost()
    BoostActive = not BoostActive
    if StatusLabel then
        StatusLabel.Text = BoostActive and "Mabilis at safe!" or "Nakatigil"
        StatusLabel.TextColor3 = BoostActive and COL.green or COL.text
    end
    if ToggleButton then
        ToggleButton.Text = BoostActive and "BOOST: ON" or "BOOST: OFF"
        ToggleButton.TextColor3 = BoostActive and COL.green or COL.accent
    end
    if FloatBoostBtn then
        FloatBoostBtn.Text = BoostActive and "ON" or "OFF"
        FloatBoostBtn.TextColor3 = BoostActive and COL.green or COL.accent
    end
end

-- FLOATING BOOST
FloatHolder = Instance.new("Frame")
FloatHolder.Name = "FloatBoost"
FloatHolder.Size = UDim2.fromOffset(52, 52)
FloatHolder.Position = UDim2.new(0, 70, 0.5, -26)
FloatHolder.BackgroundTransparency = 1
FloatHolder.Active = true
FloatHolder.Visible = true
FloatHolder.ZIndex = 998
FloatHolder.Parent = ScreenGui

local fHex = 52 * 0.62
for i = 1, 3 do
    local d = Instance.new("Frame")
    d.Size = UDim2.fromOffset(fHex, fHex)
    d.Position = UDim2.new(0.5, -fHex/2, 0.5, -fHex/2)
    d.BackgroundColor3 = COL.bg
    d.BorderSizePixel = 0
    d.Rotation = 60 * i
    d.ZIndex = 1
    d.Parent = FloatHolder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = d
    local s = Instance.new("UIStroke")
    s.Color = COL.green; s.Thickness = 1.5; s.Transparency = 0.15
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = d
end

local floatClip = Instance.new("Frame")
floatClip.Size = UDim2.fromScale(1, 1)
floatClip.BackgroundTransparency = 1
floatClip.ClipsDescendants = true
floatClip.ZIndex = 3
floatClip.Parent = FloatHolder
makeShine(floatClip, { width = 12, speed = 1.3, transparency = 0.3, delay = 0.9, z = 4 })

FloatBoostBtn = Instance.new("TextButton")
FloatBoostBtn.Size = UDim2.fromScale(1, 1)
FloatBoostBtn.BackgroundTransparency = 1
FloatBoostBtn.Text = "OFF"
FloatBoostBtn.TextColor3 = COL.accent
FloatBoostBtn.Font = FONT_BOLD
FloatBoostBtn.TextSize = 11
FloatBoostBtn.AutoButtonColor = false
FloatBoostBtn.Active = true
FloatBoostBtn.ZIndex = 5
FloatBoostBtn.Parent = FloatHolder

local fbDragActive, fbDragStart, fbStartPos, fbDragged = false, nil, nil, false
FloatBoostBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        fbDragActive = true; fbDragged = false
        fbDragStart = input.Position
        fbStartPos = FloatHolder.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not fbDragActive then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - fbDragStart
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then fbDragged = true end
        FloatHolder.Position = UDim2.new(fbStartPos.X.Scale, fbStartPos.X.Offset + d.X,
                                         fbStartPos.Y.Scale, fbStartPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if fbDragActive and not fbDragged then playClick(); toggleBoost() end
        fbDragActive = false
    end
end)
-- VLC SAFE SPEED v1.3 — Part 2/3

-- OPEN BUTTON
local BTN_SIZE = 40
local toggleHolder = Instance.new("Frame")
toggleHolder.Size = UDim2.fromOffset(BTN_SIZE, BTN_SIZE)
toggleHolder.Position = UDim2.new(0, 16, 0.5, -BTN_SIZE/2)
toggleHolder.BackgroundTransparency = 1
toggleHolder.Active = true
toggleHolder.Visible = false
toggleHolder.ZIndex = 999
toggleHolder.Parent = ScreenGui

local hexSide = BTN_SIZE * 0.62
for i = 1, 3 do
    local d = Instance.new("Frame")
    d.Size = UDim2.fromOffset(hexSide, hexSide)
    d.Position = UDim2.new(0.5, -hexSide/2, 0.5, -hexSide/2)
    d.BackgroundColor3 = COL.bg
    d.BorderSizePixel = 0
    d.Rotation = 60 * i
    d.ZIndex = 1
    d.Parent = toggleHolder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = d
    local s = Instance.new("UIStroke")
    s.Color = COL.stroke; s.Thickness = 1.3; s.Transparency = 0.2
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = d
end

local openClip = Instance.new("Frame")
openClip.Size = UDim2.fromScale(1, 1)
openClip.BackgroundTransparency = 1
openClip.ClipsDescendants = true
openClip.ZIndex = 3
openClip.Parent = toggleHolder
makeShine(openClip, { width = 10, speed = 1.4, transparency = 0.35, delay = 1.0, z = 4 })

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.fromScale(1, 1)
openBtn.BackgroundTransparency = 1
openBtn.Text = "S"
openBtn.TextColor3 = COL.accent
openBtn.Font = FONT_BOLD
openBtn.TextSize = 15
openBtn.AutoButtonColor = false
openBtn.Active = true
openBtn.ZIndex = 5
openBtn.Parent = toggleHolder

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = COL.bg
MainFrame.Position = UDim2.new(0.5, -105, 0.5, -130)
MainFrame.Size = UDim2.fromOffset(210, 260)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
stroke(MainFrame, COL.stroke, 1.2, 0.2)
makeShine(MainFrame, { width = 32, speed = 2.6, transparency = 0.88, delay = 2.2 })

-- TITLE
local Title = Instance.new("Frame")
Title.Name = "TitleBar"
Title.Parent = MainFrame
Title.BackgroundColor3 = COL.bg2
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BorderSizePixel = 0
Title.ZIndex = 4
stroke(Title, COL.stroke, 1, 0.5)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = Title
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Font = FONT_BOLD
TitleLabel.Text = "VLC SPEED " .. VERSION
TitleLabel.TextColor3 = COL.accent
TitleLabel.TextSize = 11
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 5

-- CLOSE BUTTON (hexagon)
local CLOSE_SIZE = 20
local closeHolder = Instance.new("Frame")
closeHolder.Size = UDim2.fromOffset(CLOSE_SIZE, CLOSE_SIZE)
closeHolder.Position = UDim2.new(1, -CLOSE_SIZE - 6, 0.5, -CLOSE_SIZE/2)
closeHolder.BackgroundTransparency = 1
closeHolder.ZIndex = 5
closeHolder.Parent = Title

local cdSide = CLOSE_SIZE * 0.6
for i = 1, 3 do
    local d = Instance.new("Frame")
    d.Size = UDim2.fromOffset(cdSide, cdSide)
    d.Position = UDim2.new(0.5, -cdSide/2, 0.5, -cdSide/2)
    d.BackgroundColor3 = COL.panel
    d.BorderSizePixel = 0
    d.Rotation = 60 * i
    d.ZIndex = 1
    d.Parent = closeHolder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = d
    local s = Instance.new("UIStroke")
    s.Color = COL.accent; s.Thickness = 1.2; s.Transparency = 0.15
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = d
end

local closeClip = Instance.new("Frame")
closeClip.Size = UDim2.fromScale(1, 1)
closeClip.BackgroundTransparency = 1
closeClip.ClipsDescendants = true
closeClip.ZIndex = 3
closeClip.Parent = closeHolder
makeShine(closeClip, { width = 6, speed = 1.2, transparency = 0.3, delay = 0.8, z = 4 })

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromScale(1, 1)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "×"
closeBtn.TextColor3 = COL.accent
closeBtn.Font = FONT_BOLD
closeBtn.TextSize = 12
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 5
closeBtn.Parent = closeHolder

-- SPEED INPUT
local SpeedInput = Instance.new("TextBox")
SpeedInput.Name = "SpeedInput"
SpeedInput.Parent = MainFrame
SpeedInput.BackgroundColor3 = COL.input
SpeedInput.Position = UDim2.new(0, 10, 0, 38)
SpeedInput.Size = UDim2.new(1, -20, 0, 28)
SpeedInput.Font = FONT
SpeedInput.PlaceholderText = "Speed (max 250)"
SpeedInput.Text = "200"
SpeedInput.TextColor3 = COL.text
SpeedInput.PlaceholderColor3 = COL.textDim
SpeedInput.TextSize = 11
SpeedInput.ClearTextOnFocus = false
SpeedInput.ZIndex = 4
stroke(SpeedInput, COL.strokeDim, 1, 0.5)

-- STATUS
StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundColor3 = COL.status
StatusLabel.Position = UDim2.new(0, 10, 0, 72)
StatusLabel.Size = UDim2.new(1, -20, 0, 28)
StatusLabel.Font = FONT
StatusLabel.Text = "Anti-Ragdoll: ON"
StatusLabel.TextColor3 = COL.green
StatusLabel.TextSize = 9
StatusLabel.TextWrapped = true
StatusLabel.ZIndex = 4
stroke(StatusLabel, COL.strokeDim, 1, 0.5)
-- VLC SAFE SPEED v1.3 — Part 3/3

-- BOOST TOGGLE
ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = COL.panel
ToggleButton.Position = UDim2.new(0, 10, 0, 106)
ToggleButton.Size = UDim2.new(1, -20, 0, 28)
ToggleButton.Font = FONT_BOLD
ToggleButton.Text = "BOOST: OFF"
ToggleButton.TextColor3 = COL.accent
ToggleButton.TextSize = 11
ToggleButton.AutoButtonColor = false
ToggleButton.ClipsDescendants = true
ToggleButton.ZIndex = 4
stroke(ToggleButton, COL.stroke, 1, 0.4)

local toggleClip = Instance.new("Frame")
toggleClip.Size = UDim2.fromScale(1, 1)
toggleClip.BackgroundTransparency = 1
toggleClip.ClipsDescendants = true
toggleClip.ZIndex = 6
toggleClip.Parent = ToggleButton
makeShine(toggleClip, { width = 16, speed = 1.8, transparency = 0.5, delay = 1.4, z = 7 })

-- ANTI-RAGDOLL TOGGLE
AntiRagdollBtn = Instance.new("TextButton")
AntiRagdollBtn.Name = "AntiRagdollBtn"
AntiRagdollBtn.Parent = MainFrame
AntiRagdollBtn.BackgroundColor3 = COL.panel
AntiRagdollBtn.Position = UDim2.new(0, 10, 0, 140)
AntiRagdollBtn.Size = UDim2.new(1, -20, 0, 28)
AntiRagdollBtn.Font = FONT_BOLD
AntiRagdollBtn.Text = "ANTI-RAGDOLL: ON"
AntiRagdollBtn.TextColor3 = COL.green
AntiRagdollBtn.TextSize = 10
AntiRagdollBtn.AutoButtonColor = false
AntiRagdollBtn.ClipsDescendants = true
AntiRagdollBtn.ZIndex = 4
stroke(AntiRagdollBtn, COL.stroke, 1, 0.4)

local arClip = Instance.new("Frame")
arClip.Size = UDim2.fromScale(1, 1)
arClip.BackgroundTransparency = 1
arClip.ClipsDescendants = true
arClip.ZIndex = 6
arClip.Parent = AntiRagdollBtn
makeShine(arClip, { width = 16, speed = 1.8, transparency = 0.5, delay = 1.4, z = 7 })

-- FLOAT TOGGLE
local FloatToggleBtn = Instance.new("TextButton")
FloatToggleBtn.Name = "FloatToggleBtn"
FloatToggleBtn.Parent = MainFrame
FloatToggleBtn.BackgroundColor3 = COL.panel
FloatToggleBtn.Position = UDim2.new(0, 10, 0, 174)
FloatToggleBtn.Size = UDim2.new(1, -20, 0, 28)
FloatToggleBtn.Font = FONT_BOLD
FloatToggleBtn.Text = "FLOAT BTN: ON"
FloatToggleBtn.TextColor3 = COL.green
FloatToggleBtn.TextSize = 11
FloatToggleBtn.AutoButtonColor = false
FloatToggleBtn.ClipsDescendants = true
FloatToggleBtn.ZIndex = 4
stroke(FloatToggleBtn, COL.stroke, 1, 0.4)

local floatToggleClip = Instance.new("Frame")
floatToggleClip.Size = UDim2.fromScale(1, 1)
floatToggleClip.BackgroundTransparency = 1
floatToggleClip.ClipsDescendants = true
floatToggleClip.ZIndex = 6
floatToggleClip.Parent = FloatToggleBtn
makeShine(floatToggleClip, { width = 16, speed = 1.8, transparency = 0.5, delay = 1.4, z = 7 })

-- FOOTER
local Footer = Instance.new("TextLabel")
Footer.Parent = MainFrame
Footer.BackgroundTransparency = 1
Footer.Position = UDim2.new(0, 10, 1, -40)
Footer.Size = UDim2.new(1, -20, 0, 32)
Footer.Font = FONT
Footer.Text = "HELLO USER THIS SCRIPT IS UPDATING WEEK BY WEEK TY FOR USING ME."
Footer.TextColor3 = COL.textDim
Footer.TextSize = 8
Footer.TextWrapped = true
Footer.TextXAlignment = Enum.TextXAlignment.Center
Footer.ZIndex = 4

-- DRAG (title bar)
do
    local dragging, dragStart, startPos
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- OPEN/CLOSE
closeBtn.MouseButton1Click:Connect(function()
    playClick(); MainFrame.Visible = false; toggleHolder.Visible = true
end)

local dragActive, dragStartMouse, dragStartPos, dragged = false, nil, nil, false
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragActive = true; dragged = false
        dragStartMouse = input.Position; dragStartPos = toggleHolder.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragActive then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        local d = input.Position - dragStartMouse
        if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then dragged = true end
        toggleHolder.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + d.X,
                                          dragStartPos.Y.Scale, dragStartPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        if dragActive and not dragged then
            playClick(); MainFrame.Visible = true; toggleHolder.Visible = false
        end
        dragActive = false
    end
end)

-- HOVER
for _, b in ipairs({ToggleButton, AntiRagdollBtn, FloatToggleBtn}) do
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0.2 }):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()
    end)
end

closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromRGB(255,140,120) }):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), { TextColor3 = COL.accent }):Play()
end)

-- TOGGLE ACTIONS
ToggleButton.MouseButton1Click:Connect(function()
    playClick(); toggleBoost()
end)

AntiRagdollBtn.MouseButton1Click:Connect(function()
    playClick()
    AntiRagdoll = not AntiRagdoll
    if AntiRagdoll then
        AntiRagdollBtn.Text = "ANTI-RAGDOLL: ON"
        AntiRagdollBtn.TextColor3 = COL.green
    else
        AntiRagdollBtn.Text = "ANTI-RAGDOLL: OFF"
        AntiRagdollBtn.TextColor3 = COL.textDim
    end
end)

FloatToggleBtn.MouseButton1Click:Connect(function()
    playClick()
    FloatBoostEnabled = not FloatBoostEnabled
    FloatHolder.Visible = FloatBoostEnabled
    if FloatBoostEnabled then
        FloatToggleBtn.Text = "FLOAT BTN: ON"
        FloatToggleBtn.TextColor3 = COL.green
    else
        FloatToggleBtn.Text = "FLOAT BTN: OFF"
        FloatToggleBtn.TextColor3 = COL.textDim
    end
end)

-- RIGHT SHIFT
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        playClick()
        if MainFrame.Visible then
            MainFrame.Visible = false
            toggleHolder.Visible = true
        else
            MainFrame.Visible = true
            toggleHolder.Visible = false
        end
    end
end)

-- ANTI-AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- BOOST LOOP
RunService.Heartbeat:Connect(function()
    if not BoostActive then return end
    local rawSpeed = tonumber(SpeedInput.Text) or 200
    local targetSpeed = math.clamp(rawSpeed, 10, 260)
    pcall(function()
        local player = LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.SeatPart then
                local seat = humanoid.SeatPart
                local rootPart = seat.AssemblyRootPart or seat
                local look = rootPart.CFrame.LookVector
                local currentVel = rootPart.AssemblyLinearVelocity
                rootPart.AssemblyLinearVelocity = Vector3.new(
                    look.X * targetSpeed,
                    currentVel.Y,
                    look.Z * targetSpeed
                )
            end
        end
    end)
end)
