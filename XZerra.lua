-- XZerra Client with Terms of Service Acceptance + Sliders + Close Button

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- === Terms of Service GUI ===
local tosGui = Instance.new("ScreenGui")
tosGui.Name = "ToSGui"
tosGui.ResetOnSpawn = false
tosGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame", tosGui)
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0.5)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Terms of Service"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 28
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local text = Instance.new("TextLabel", frame)
text.Size = UDim2.new(1, -20, 1, -100)
text.Position = UDim2.new(0, 10, 0, 50)
text.BackgroundTransparency = 1
text.TextWrapped = true
text.TextYAlignment = Enum.TextYAlignment.Top
text.Font = Enum.Font.SourceSans
text.TextSize = 16
text.TextColor3 = Color3.fromRGB(200, 200, 200)
text.Text = [[
By using this cheat, you agree to the following terms:

- Use at your own risk.
- Do not share the cheat with others.
- The author is not responsible for any bans or consequences.
- Respect others and use responsibly.

Please accept to continue.
]]

local acceptBtn = Instance.new("TextButton", frame)
acceptBtn.Size = UDim2.new(0.4, 0, 0, 40)
acceptBtn.Position = UDim2.new(0.1, 0, 1, -50)
acceptBtn.Text = "Accept"
acceptBtn.Font = Enum.Font.SourceSansBold
acceptBtn.TextSize = 22
acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
acceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)

local declineBtn = Instance.new("TextButton", frame)
declineBtn.Size = UDim2.new(0.4, 0, 0, 40)
declineBtn.Position = UDim2.new(0.5, 0, 1, -50)
declineBtn.Text = "Decline"
declineBtn.Font = Enum.Font.SourceSansBold
declineBtn.TextSize = 22
declineBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
declineBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

local accepted = false

acceptBtn.MouseButton1Click:Connect(function()
    accepted = true
    tosGui:Destroy()
end)

declineBtn.MouseButton1Click:Connect(function()
    tosGui:Destroy()
    if LocalPlayer then
        LocalPlayer:Kick("You declined the Terms of Service.")
    end
end)

-- Pause script until accepted
repeat wait() until accepted


-- === Begin XZerra Client code ===

-- Settings
local espEnabled, chamsEnabled, tracersEnabled, nametagsEnabled = false, false, false, false
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmooth = 0.5
local aimbotLockPart = "Head"

local ignorePlayers = {
    ["scripttester129382"] = true,
    ["TestingScripts12354"] = true,
}

local ESPObjects, chamHighlights = {}, {}

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(0,1,0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Radius = aimbotFOV
fovCircle.Visible = false

local connections = {}

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

local function isIgnored(player)
    return player == LocalPlayer or ignorePlayers[player.Name] == true
end

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

connections.renderStepped = RunService.RenderStepped:Connect(function()
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

    for plr, o in pairs(ESPObjects) do
        if not present[plr] then
            o.Box:Remove()
            o.Tracer:Remove()
            o.Nametag:Remove()
            ESPObjects[plr] = nil
        end
    end
end)

local holding = false
connections.aimbotStep = RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        if holding then
            UserInputService:SendMouseButtonEvent(1, false, false, game)
            holding = false
        end
        return
    end

    local tgt = getClosestTarget()
    if tgt and tgt.Character and tgt.Character:FindFirstChild(aimbotLockPart) then
        local part = tgt.Character[aimbotLockPart]
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.new(camPos, part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 - aimbotSmooth)

        if not holding then
            UserInputService:SendMouseButtonEvent(1, true, false, game)
            holding = true
        end
    else
        if holding then
            UserInputService:SendMouseButtonEvent(1, false, false, game)
            holding = false
        end
    end
end)

-- GUI Creation
local SG = Instance.new("ScreenGui")
SG.Name = "XZerraClient"
SG.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", SG)
main.Size = UDim2.new(0,300,0,480)
main.Position = UDim2.new(0,20,0.5,-240)
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

-- Close (X) Button
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.TextColor3 = Color3.new(1,0,0)
closeBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
closeBtn.BorderSizePixel = 0

closeBtn.MouseButton1Click:Connect(function()
    -- Clean up drawings
    for _, o in pairs(ESPObjects) do
        if o.Box then o.Box:Remove() end
        if o.Tracer then o.Tracer:Remove() end
        if o.Nametag then o.Nametag:Remove() end
    end
    for _, h in pairs(chamHighlights) do
        if h then h:Destroy() end
    end
    fovCircle:Remove()
    -- Disconnect connections
    for _, conn in pairs(connections) do
        if conn then conn:Disconnect() end
    end
    -- Destroy GUI
    SG:Destroy()
    print("[XZerra] Client closed and cleaned up.")
end)

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
    y = y + 45
    return btn
end

local function addSlider(txt, min, max, def, decimals, cb)
    local label = Instance.new("TextLabel", main)
    label.Size = UDim2.new(1,-20,0,25)
    label.Position = UDim2.new(0,10,0,y)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 18
    label.TextColor3 = Color3.new(1,1,1)
    label.Text = txt..": "..tostring(def)
    label.TextXAlignment = Enum.TextXAlignment.Left

    y = y + 25

    local sliderFrame = Instance.new("Frame", main)
    sliderFrame.Size = UDim2.new(1,-20,0,20)
    sliderFrame.Position = UDim2.new(0,10,0,y)
    sliderFrame.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    sliderFrame.BorderSizePixel = 0

    local fill = Instance.new("Frame", sliderFrame)
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.new(0,1,0)

    local dragging = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    sliderFrame.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
            local value = (mouseX / sliderFrame.AbsoluteSize.X) * (max - min) + min
            value = math.floor(value * (10^decimals)) / (10^decimals)
            fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
            label.Text = txt..": "..tostring(value)
            cb(value)
        end
    end)

    y = y + 35
end

-- Add Toggles
addToggle("ESP", espEnabled, function(v) espEnabled = v end)
addToggle("Chams", chamsEnabled, function(v) chamsEnabled = v end)
addToggle("Tracers", tracersEnabled, function(v) tracersEnabled = v end)
addToggle("Nametags", nametagsEnabled, function(v) nametagsEnabled = v end)
addToggle("Aimbot", aimbotEnabled, function(v) 
    aimbotEnabled = v 
    fovCircle.Visible = v
end)

-- Add Sliders for Aimbot FOV and Smooth
addSlider("Aimbot FOV", 20, 300, aimbotFOV, 0, function(val)
    aimbotFOV = val
end)

addSlider("Aimbot Smooth", 0, 1, aimbotSmooth, 2, function(val)
    aimbotSmooth = val
end)

print("[XZerra] Loaded with Terms accepted.")
