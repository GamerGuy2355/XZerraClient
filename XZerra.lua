-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ignore local player for ESP/Aimbot
local ignorePlayers = {
    [LocalPlayer.Name]
	["TestingScripts12354"] = true,
	["scripttester129382"]
}

-- Settings (default)
local espEnabled = false
local chamsEnabled = false
local tracersEnabled = false
local nametagsEnabled = false
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmooth = 0.3
local aimbotLockPart = "Head"

-- Storage
local ESPObjects = {}
local chamHighlights = {}

-- FOV circle drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(0, 1, 0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = false

-- Helper to create ESP drawings
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

local function isIgnored(player)
    return ignorePlayers[player.Name]
end

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

local function cleanup()
    for _, data in pairs(ESPObjects) do
        if data.Box then data.Box:Remove() end
        if data.Tracer then data.Tracer:Remove() end
        if data.Nametag then data.Nametag:Remove() end
    end
    ESPObjects = {}

    for _, hl in pairs(chamHighlights) do
        if hl then hl:Destroy() end
    end
    chamHighlights = {}

    if fovCircle then
        fovCircle:Remove()
    end

    if connection_RenderStepped then connection_RenderStepped:Disconnect() end
    if connection_Aimbot then connection_Aimbot:Disconnect() end

    if screenGui then
        screenGui:Destroy()
    end
end

-- === GUI Setup ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "XZerraClientGui"
screenGui.Parent = game.CoreGui
screenGui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 450) -- wider and taller for space
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
titleBar.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "XZerra Client"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(1, -35, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 20
closeBtn.Parent = titleBar

closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

-- Draggable logic
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Button creator with toggle state and callback
local function createToggle(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 20
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = text .. ": OFF"
    btn.Parent = frame
    local toggled = false
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = text .. ": " .. (toggled and "ON" or "OFF")
        callback(toggled)
    end)
    return btn
end

-- Slider creator for number input
local function createSlider(labelText, posY, default, min, max, step, callback)
    local label = Instance.new("TextLabel")
    label.Text = labelText
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, posY)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -20, 0, 30)
    textBox.Position = UDim2.new(0, 10, 0, posY + 22)
    textBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textBox.TextColor3 = Color3.new(1,1,1)
    textBox.Font = Enum.Font.SourceSans
    textBox.TextSize = 18
    textBox.Text = tostring(default)
    textBox.ClearTextOnFocus = false
    textBox.Parent = frame

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local val = tonumber(textBox.Text)
            if val and val >= min and val <= max then
                callback(val)
            else
                textBox.Text = tostring(default) -- revert invalid
            end
        end
    end)

    return textBox
end

-- Toggle buttons with callbacks to set variables and update related stuff
local espBtn = createToggle("ESP", 50, function(state)
    espEnabled = state
end)

local chamsBtn = createToggle("Chams", 100, function(state)
    chamsEnabled = state
end)

local tracersBtn = createToggle("Tracers", 150, function(state)
    tracersEnabled = state
end)

local nametagsBtn = createToggle("Nametags", 200, function(state)
    nametagsEnabled = state
end)

local aimbotBtn = createToggle("Aimbot", 250, function(state)
    aimbotEnabled = state
    fovCircle.Visible = state
end)

local fovBox = createSlider("Aimbot FOV (1-180)", 300, aimbotFOV, 1, 180, 1, function(val)
    aimbotFOV = val
end)

local smoothBox = createSlider("Aimbot Smooth (0.01-1)", 350, aimbotSmooth, 0.01, 1, 0.01, function(val)
    aimbotSmooth = val
end)

-- Highlight function for chams
-- Optimized function for chams highlighting
local function updateChams()
    -- Only update if chams are enabled
    if not chamsEnabled then return end

    -- Create and update highlights only if necessary
    for _, player in pairs(Players:GetPlayers()) do
        if not isIgnored(player) and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")

            -- Check if the player already has a highlight
            local existingHighlight = chamHighlights[player]

            if hrp then
                if not existingHighlight then
                    -- Create a new highlight only if it doesn't exist
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = player.Character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    highlight.Parent = workspace
                    chamHighlights[player] = highlight
                else
                    -- Update the existing highlight (optional, if properties need updates)
                    existingHighlight.Adornee = player.Character
                    existingHighlight.Visible = true  -- Ensure it's visible
                end
            elseif existingHighlight then
                -- Remove the highlight if the player has no HumanoidRootPart
                existingHighlight.Visible = false
            end
        else
            -- Ensure highlight is hidden if the player is not in the game or has no character
            local existingHighlight = chamHighlights[player]
            if existingHighlight then
                existingHighlight.Visible = false
            end
        end
    end
end


-- Update ESP drawings
local function updateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if isIgnored(player) then
            -- Remove any existing ESP
            if ESPObjects[player] then
                if ESPObjects[player].Box then ESPObjects[player].Box.Visible = false end
                if ESPObjects[player].Tracer then ESPObjects[player].Tracer.Visible = false end
                if ESPObjects[player].Nametag then ESPObjects[player].Nametag.Visible = false end
            end
        else
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and hrp then
                local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if not ESPObjects[player] then
                    ESPObjects[player] = {
                        Box = createBox(),
                        Tracer = createTracer(),
                        Nametag = createNametag(player.Name),
                    }
                end

                local box = ESPObjects[player].Box
                local tracer = ESPObjects[player].Tracer
                local nametag = ESPObjects[player].Nametag

                if espEnabled then
                    -- Calculate box size roughly
                    local head = char:FindFirstChild("Head")
                    local root = hrp.Position
                    if head then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                        if onScreen and headOnScreen then
                            local sizeY = math.abs(headPos.Y - rootPos.Y)
                            local sizeX = sizeY / 2

                            -- Draw box around root + head
                            box.Visible = true
                            box.Size = Vector2.new(sizeX, sizeY)
                            box.Position = Vector2.new(rootPos.X - sizeX/2, rootPos.Y - sizeY/2)
                        else
                            box.Visible = false
                        end
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end

                if tracersEnabled then
                    local bottomScreen = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    tracer.From = bottomScreen
                    tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end

                if nametagsEnabled then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        if headOnScreen then
                            nametag.Position = Vector2.new(headPos.X, headPos.Y)
                            nametag.Visible = true
                        else
                            nametag.Visible = false
                        end
                    else
                        nametag.Visible = false
                    end
                else
                    nametag.Visible = false
                end
            else
                if ESPObjects[player] then
                    if ESPObjects[player].Box then ESPObjects[player].Box.Visible = false end
                    if ESPObjects[player].Tracer then ESPObjects[player].Tracer.Visible = false end
                    if ESPObjects[player].Nametag then ESPObjects[player].Nametag.Visible = false end
                end
            end
        end
    end
end

-- Update loop
local connection_RenderStepped = RunService.RenderStepped:Connect(function()
    updateESP()
    updateChams()
    -- Update FOV circle for aimbot
    if aimbotEnabled then
        fovCircle.Visible = true
        fovCircle.Radius = (aimbotFOV / 180) * (Camera.ViewportSize.X / 2)
        fovCircle.Position = UserInputService:GetMouseLocation()
    else
        fovCircle.Visible = false
    end
end)

-- Aimbot aiming logic
local connection_Aimbot = RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(aimbotLockPart) then
            local headPos = target.Character[aimbotLockPart].Position
            local camPos = Camera.CFrame.Position

            -- Calculate desired CFrame to look at
            local lookAt = CFrame.new(camPos, headPos)

            -- Smoothly interpolate camera rotation
            local currentCFrame = Camera.CFrame
            local newCFrame = currentCFrame:Lerp(lookAt, aimbotSmooth)
            Camera.CFrame = newCFrame
        end
    end
end)

-- Toggle GUI visibility with F1
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F1 then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Cleanup on script unload (optional)
--[[
game:BindToClose(function()
    cleanup()
end)
--]]

print("XZerra Client loaded! Press F1 to toggle GUI.")
