-- XZerra Client FULL WORKING SCRIPT
-- Dependencies: Roblox Lua, works in any executor supporting Drawing API

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ignore these players (add your testers or script dev names here)
local ignorePlayers = {
    [LocalPlayer.Name] = true,
}

-- SETTINGS (default values)
local espEnabled = false
local chamsEnabled = false
local tracersEnabled = false
local nametagsEnabled = false
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmooth = 0.3
local aimbotLockPart = "Head"

-- Storage for drawings and highlights
local ESPObjects = {}
local chamHighlights = {}

-- Drawing objects for FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(0, 1, 0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = false

-- Helper functions to create ESP drawings
local function createBox()
    local box = Drawing.new("Square")
    box.Color = Color3.new(1, 0, 0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    return box
end

local function createTracer()
    local line = Drawing.new("Line")
    line.Color = Color3.new(1, 1, 1)
    line.Thickness = 1
    line.Visible = false
    return line
end

local function createNametag(name)
    local text = Drawing.new("Text")
    text.Text = name
    text.Color = Color3.new(1, 1, 1)
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

-- Check if player should be ignored
local function isIgnored(player)
    return ignorePlayers[player.Name]
end

-- Get closest target for aimbot based on FOV and visibility
local function getClosestTarget()
    local mousePos = UserInputService:GetMouseLocation()
    local bestDist = aimbotFOV
    local bestPlayer = nil
    local camPos = Camera.CFrame.Position

    for _, player in pairs(Players:GetPlayers()) do
        if not isIgnored(player) and player.Character and player.Character:FindFirstChild(aimbotLockPart) then
            local head = player.Character[aimbotLockPart]
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < bestDist then
                        -- Visibility check raycast
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        rayParams.IgnoreWater = true
                        local ray = workspace:Raycast(camPos, (head.Position - camPos), rayParams)

                        if not ray or ray.Instance:IsDescendantOf(player.Character) then
                            bestDist = dist
                            bestPlayer = player
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

-- Cleanup function to remove all drawings and highlights when closing
local function cleanup()
    -- Remove ESP drawings
    for _, data in pairs(ESPObjects) do
        if data.Box then data.Box:Remove() end
        if data.Tracer then data.Tracer:Remove() end
        if data.Nametag then data.Nametag:Remove() end
    end
    ESPObjects = {}

    -- Remove highlights
    for _, hl in pairs(chamHighlights) do
        if hl then hl:Destroy() end
    end
    chamHighlights = {}

    -- Remove FOV circle
    if fovCircle then
        fovCircle:Remove()
    end

    -- Disconnect all connections (added later)
    if connection_RenderStepped then
        connection_RenderStepped:Disconnect()
    end
    if connection_Aimbot then
        connection_Aimbot:Disconnect()
    end

    -- Destroy GUI if any (added later)
    if mainGui then
        mainGui:Destroy()
    end
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XZerraClientGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local mainGui = ScreenGui

local function createButton(text, pos, size)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Position = pos
    btn.Size = size
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = mainGui
    return btn
end

local function createLabel(text, pos, size)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Position = pos
    label.Size = size
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.Parent = mainGui
    return label
end

local function createSlider(labelText, pos, size, min, max, default)
    local label = createLabel(labelText, pos, UDim2.new(0, size.X.Offset, 0, 20))
    local slider = Instance.new("TextBox")
    slider.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + 22)
    slider.Size = UDim2.new(0, size.X.Offset, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.TextColor3 = Color3.new(1, 1, 1)
    slider.Text = tostring(default)
    slider.ClearTextOnFocus = false
    slider.Font = Enum.Font.SourceSans
    slider.TextSize = 16
    slider.Parent = mainGui
    return label, slider
end

-- Toggle Buttons
local espBtn = createButton("ESP: OFF", UDim2.new(0, 20, 0, 20), UDim2.new(0, 120, 0, 35))
local chamsBtn = createButton("Chams: OFF", UDim2.new(0, 160, 0, 20), UDim2.new(0, 120, 0, 35))
local tracersBtn = createButton("Tracers: OFF", UDim2.new(0, 300, 0, 20), UDim2.new(0, 120, 0, 35))
local nametagsBtn = createButton("Nametags: OFF", UDim2.new(0, 440, 0, 20), UDim2.new(0, 120, 0, 35))
local aimbotBtn = createButton("Aimbot: OFF", UDim2.new(0, 580, 0, 20), UDim2.new(0, 120, 0, 35))

-- Sliders
local fovLabel, fovSlider = createSlider("Aimbot FOV (px)", UDim2.new(0, 20, 0, 70), UDim2.new(0, 180, 0, 50), 10, 300, aimbotFOV)
local smoothLabel, smoothSlider = createSlider("Aimbot Smoothness (0-1)", UDim2.new(0, 220, 0, 70), UDim2.new(0, 180, 0, 50), 0, 1, aimbotSmooth)

-- Close button
local closeBtn = createButton("X", UDim2.new(1, -40, 0, 10), UDim2.new(0, 30, 0, 30))
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)

-- Button click handlers
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
end)

chamsBtn.MouseButton1Click:Connect(function()
    chamsEnabled = not chamsEnabled
    chamsBtn.Text = "Chams: " .. (chamsEnabled and "ON" or "OFF")
end)

tracersBtn.MouseButton1Click:Connect(function()
    tracersEnabled = not tracersEnabled
    tracersBtn.Text = "Tracers: " .. (tracersEnabled and "ON" or "OFF")
end)

nametagsBtn.MouseButton1Click:Connect(function()
    nametagsEnabled = not nametagsEnabled
    nametagsBtn.Text = "Nametags: " .. (nametagsEnabled and "ON" or "OFF")
end)

aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = "Aimbot: " .. (aimbotEnabled and "ON" or "OFF")
    fovCircle.Visible = aimbotEnabled
end)

-- Slider input handlers
local function updateFOV()
    local val = tonumber(fovSlider.Text)
    if val and val >= 10 and val <= 300 then
        aimbotFOV = val
    else
        fovSlider.Text = tostring(aimbotFOV)
    end
    fovCircle.Radius = aimbotFOV
end

local function updateSmooth()
    local val = tonumber(smoothSlider.Text)
    if val and val >= 0 and val <= 1 then
        aimbotSmooth = val
    else
        smoothSlider.Text = tostring(aimbotSmooth)
    end
end

fovSlider.FocusLost:Connect(updateFOV)
smoothSlider.FocusLost:Connect(updateSmooth)

-- Close button handler
closeBtn.MouseButton1Click:Connect(function()
    cleanup()
end)

-- Aimbot hold mouse button state
local holding = false

-- Main RenderStepped connection for ESP and visuals
connection_RenderStepped = RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    fovCircle.Radius = aimbotFOV

    local playersOnScreen = {}

    for _, player in pairs(Players:GetPlayers()) do
        if not isIgnored(player) and player.Character then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and hrp and head then
                playersOnScreen[player] = true

                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    if not ESPObjects[player] then
                        ESPObjects[player] = {
                            Box = createBox(),
                            Tracer = createTracer(),
                            Nametag = createNametag(player.Name)
                        }
                    end

                    local box = ESPObjects[player].Box
                    local tracer = ESPObjects[player].Tracer
                    local nametag = ESPObjects[player].Nametag

                    local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                    local boxHeight = math.clamp(300 / distance, 20, 150)
                    local boxWidth = boxHeight / 2

                    local boxPosX = screenPos.X - boxWidth / 2
                    local boxPosY = screenPos.Y - boxHeight / 2

                    if espEnabled then
                        box.Position = Vector2.new(boxPosX, boxPosY)
                        box.Size = Vector2.new(boxWidth, boxHeight)
                        box.Visible = true
                    else
                        box.Visible = false
                    end

                    if tracersEnabled then
                        tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end

                    if nametagsEnabled then
                        local headPos, onScreenHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        if onScreenHead then
                            nametag.Position = Vector2.new(headPos.X, headPos.Y)
                            nametag.Visible = true
                        else
                            nametag.Visible = false
                        end
                    else
                        nametag.Visible = false
                    end

                    if chamsEnabled then
                        if not chamHighlights[player] then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = player.Character
                            highlight.Parent = workspace
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                            highlight.OutlineTransparency = 0.3
                            chamHighlights[player] = highlight
                        end
                    else
                        if chamHighlights[player] then
                            chamHighlights[player]:Destroy()
                            chamHighlights[player] = nil
                        end
                    end
                else
                    if ESPObjects[player] then
                        ESPObjects[player].Box.Visible = false
                        ESPObjects[player].Tracer.Visible = false
                        ESPObjects[player].Nametag.Visible = false
                    end
                    if chamHighlights[player] then
                        chamHighlights[player]:Destroy()
                        chamHighlights[player] = nil
                    end
                end
            else
                if ESPObjects[player] then
                    ESPObjects[player].Box.Visible = false
                    ESPObjects[player].Tracer.Visible = false
                    ESPObjects[player].Nametag.Visible = false
                end
                if chamHighlights[player] then
                    chamHighlights[player]:Destroy()
                    chamHighlights[player] = nil
                end
            end
        end
    end

    -- Cleanup for players who left/died
    for player, _ in pairs(ESPObjects) do
        if not playersOnScreen[player] then
            if ESPObjects[player].Box then ESPObjects[player].Box:Remove() end
            if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
            if ESPObjects[player].Nametag then ESPObjects[player].Nametag:Remove() end
            ESPObjects[player] = nil
        end
    end
end)

-- Aimbot update (smoothly move camera and hold mouse button)
connection_Aimbot = RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then
        if holding then
            UserInputService:SendMouseButtonEvent(1, false, false, game)
            holding = false
        end
        return
    end

    local target = getClosestTarget()
    if target and target.Character and target.Character:FindFirstChild(aimbotLockPart) then
        local head = target.Character[aimbotLockPart]
        local camPos = Camera.CFrame.Position
        local direction = (head.Position - camPos).Unit
        local targetCFrame = CFrame.new(camPos, camPos + direction)

        -- Smooth lerp to target
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - aimbotSmooth)

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

print("[XZerra] Client loaded! Use GUI to toggle features.")
