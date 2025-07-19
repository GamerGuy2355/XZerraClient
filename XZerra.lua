-- XZerra Client (ESP / Chams / Tracers / Nametags / Aimbot + Auto Shoot + Hollow FOV + Custom Ignore List + F1 Toggle GUI + Super Speed)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Settings
local espEnabled, chamsEnabled, tracersEnabled, nametagsEnabled = false, false, false, false
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmooth = 0.5
local aimbotLockPart = "Head"

local superSpeedEnabled = false
local normalSpeed = 16
local superSpeed = 30

-- List of player names to ignore (won't be targeted by aimbot or ESP)
local ignorePlayers = {
    ["scripttester129382"] = true,
    ["TestingScripts12354"] = true,
    -- Add your friends here like ["FriendName"] = true
}

-- Drawing containers
local ESPObjects, chamHighlights = {}, {}

-- Hollow FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(0,1,0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Radius = aimbotFOV
fovCircle.Visible = false

-- Drawing helpers
local function createBox()
    local d = Drawing.new("Square")
    d.Color, d.Thickness, d.Filled, d.Visible = Color3.new(1,0,0), 2, false, false
    return d
end
local function createTracer()
    local d = Drawing.new("Line")
    d.Color, d.Thickness, d.Visible = Color3.new(1,1,1), 1, false
    return d
end
local function createNametag(name)
    local d = Drawing.new("Text")
    d.Text, d.Color, d.Size, d.Center, d.Outline, d.Visible = name, Color3.new(1,1,1), 16, true, true, false
    return d
end

-- Check if player is ignored
local function isIgnored(player)
    return player == LocalPlayer or ignorePlayers[player.Name] == true
end

-- Get closest visible target within FOV (not ignored)
local function getClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local bestDist, bestPlr = aimbotFOV, nil
    local camPos = Camera.CFrame.Position

    for _, plr in pairs(Players:GetPlayers()) do
        if not isIgnored(plr) and plr.Character and plr.Character:FindFirstChild(aimbotLockPart) then
            local part = plr.Character[aimbotLockPart]
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local screenX, screenY, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenX, screenY) - mousePos).Magnitude
                    if dist < bestDist then
                        -- Raycast to check visibility
                        local rayParams = RaycastParams.new()
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        rayParams.IgnoreWater = true
                        local ray = workspace:Raycast(camPos, (part.Position - camPos), rayParams)
                        if not ray or ray.Instance:IsDescendantOf(plr.Character) then
                            bestDist = dist
                            bestPlr = plr
                        end
                    end
                end
            end
        end
    end

    return bestPlr
end

-- Render ESP, tracers, nametags, chams, and FOV circle
RunService.RenderStepped:Connect(function()
    local vs = Camera.ViewportSize
    fovCircle.Position = Vector2.new(vs.X/2, vs.Y/2)
    fovCircle.Radius = aimbotFOV
    fovCircle.Visible = aimbotEnabled

    local present = {}

    for _, plr in pairs(Players:GetPlayers()) do
        if not isIgnored(plr) and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                present[plr] = true
                local scrX, scrY, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local visible = onScreen and scrY > 0

                if not ESPObjects[plr] then
                    ESPObjects[plr] = {
                        Box = createBox(),
                        Tracer = createTracer(),
                        Nametag = createNametag(plr.Name),
                    }
                end
                local o = ESPObjects[plr]

                -- ESP Box
                if espEnabled and visible then
                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local size = math.clamp(300 / distance, 20, 150)
                    o.Box.Size = Vector2.new(size * 0.6, size)
                    o.Box.Position = Vector2.new(scrX - size * 0.3, scrY - size / 2)
                    o.Box.Visible = true
                else
                    o.Box.Visible = false
                end

                -- Tracer
                if tracersEnabled and visible then
                    o.Tracer.From = Vector2.new(vs.X/2, vs.Y)
                    o.Tracer.To = Vector2.new(scrX, scrY)
                    o.Tracer.Visible = true
                else
                    o.Tracer.Visible = false
                end

                -- Nametag
                if nametagsEnabled and visible then
                    o.Nametag.Position = Vector2.new(scrX, scrY - (o.Box.Size.Y / 2 or 60))
                    o.Nametag.Visible = true
                else
                    o.Nametag.Visible = false
                end

                -- Chams
                if chamsEnabled and not chamHighlights[plr] then
                    chamHighlights[plr] = Instance.new("Highlight", workspace)
                    chamHighlights[plr].Adornee = plr.Character
                    chamHighlights[plr].FillColor = Color3.new(0,1,0)
                    chamHighlights[plr].FillTransparency = 0.5
                    chamHighlights[plr].OutlineColor = Color3.new(0,1,0)
                    chamHighlights[plr].OutlineTransparency = 0.3
                elseif not chamsEnabled and chamHighlights[plr] then
                    chamHighlights[plr]:Destroy()
                    chamHighlights[plr] = nil
                end
            end
        end
    end

    -- Clean up ESP for players not present
    for plr, o in pairs(ESPObjects) do
        if not present[plr] then
            o.Box:Remove()
            o.Tracer:Remove()
            o.Nametag:Remove()
            ESPObjects[plr] = nil
        end
    end
end)

-- Aimbot + autoshoot (hold mouse button)
local holding = false
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        if holding then
            UserInputService:SendMouseButtonEvent(1, false, false, game)
            holding = false
        end
        return
    end

    local tgt = getClosestTarget()
    if tgt and tgt.Character and tgt.Character:FindFirstChild(aimbotLockPart) then
        local head = tgt.Character[aimbotLockPart]
        local camPos = Camera.CFrame.Position
        local headPos = head.CFrame.Position  -- exact center of the head

        -- Create a CFrame from the camera position looking exactly at the head center
        local targetCF = CFrame.new(camPos, headPos)

        -- Smoothly move the camera toward the target CFrame using aimbotSmooth
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - aimbotSmooth)

        -- Auto shoot if not already holding the mouse button
        if not holding then
            UserInputService:SendMouseButtonEvent(1, true, false, game)
            holding = true
        end
    else
        -- Release mouse button if no target
        if holding then
            UserInputService:SendMouseButtonEvent(1, false, false, game)
            holding = false
        end
    end
end)

-- Super speed toggle function
local function setSpeed(enabled)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = enabled and superSpeed or normalSpeed
    end
end

-- When character respawns apply speed if enabled
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    setSpeed(superSpeedEnabled)
end)

-- GUI Creation
local SG = Instance.new("ScreenGui")
SG.Name = "XZerraClient"
SG.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", SG)
main.Size = UDim2.new(0,300,0,450)
main.Position = UDim2.new(0,20,0.5,-225)
main.BackgroundColor3 = Color3.new(0.1,0.1,0.1)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24
title.TextColor3 = Color3.new(1,1,1)
title.Text = "XZerra Client"

local y = 50
local function addToggle(txt, init, cb)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(1,-20,0,35)
    btn.Position = UDim2.new(0,10,0,y)
    btn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.TextColor3 = Color3.new(1,1,1)
    local on = init
    btn.Text = txt..(on and ": ON" or ": OFF")
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = txt..(on and ": ON" or ": OFF")
        cb(on)
    end)
    y = y + 40
end

local function addSlider(txt, min, max, init, cb)
    local lbl = Instance.new("TextLabel", main)
    lbl.Size = UDim2.new(1,-20,0,20)
    lbl.Position = UDim2.new(0,10,0,y)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 16
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = txt..": "..init
    y = y + 20

    local slider = Instance.new("TextBox", main)
    slider.Size = UDim2.new(1,-20,0,25)
    slider.Position = UDim2.new(0,10,0,y)
    slider.BackgroundColor3 = Color3.new(0.15,0.15,0.15)
    slider.TextColor3 = Color3.new(1,1,1)
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 18
    slider.Text = tostring(init)
    y = y + 40

    slider.FocusLost:Connect(function(enterPressed)
        local val = tonumber(slider.Text)
        if val and val >= min and val <= max then
            lbl.Text = txt..": "..val
            cb(val)
        else
            slider.Text = tostring(init)
        end
    end)
end

-- Toggles and Sliders
addToggle("ESP", espEnabled, function(v) espEnabled = v end)
addToggle("Chams", chamsEnabled, function(v) chamsEnabled = v end)
addToggle("Tracers", tracersEnabled, function(v) tracersEnabled = v end)
addToggle("Nametags", nametagsEnabled, function(v) nametagsEnabled = v end)
addToggle("Aimbot", aimbotEnabled, function(v) aimbotEnabled = v end)
addSlider("Aimbot FOV", 10, 300, aimbotFOV, function(v) aimbotFOV = v end)
addSlider("Aimbot Smoothness", 0, 1, aimbotSmooth, function(v) aimbotSmooth = v end)
addToggle("Super Speed", superSpeedEnabled, function(v)
    superSpeedEnabled = v
    setSpeed(v)
end)

-- Toggle GUI visibility with F1
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        SG.Enabled = not SG.Enabled
    end
end)

-- Initial speed set
setSpeed(superSpeedEnabled)

print("[XZerra] Client Loaded!")
