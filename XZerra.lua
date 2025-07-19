local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- == Terms of Service (same as before, omitted here for brevity) ==
-- Assume Terms accepted and script continues...

-- SETTINGS
local espEnabled = false
local chamsEnabled = false
local tracersEnabled = false
local nametagsEnabled = false
local aimbotEnabled = false
local aimbotFOV = 90
local aimbotSmooth = 0.3
local aimbotLockPart = "Head"

local ignorePlayers = {
    ["scripttester129382"] = true,
    ["TestingScripts12354"] = true,
}

-- ESP Drawing storage
local ESPObjects = {}
local chamHighlights = {}

-- FOV Circle
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(0,1,0)
fovCircle.Thickness = 2
fovCircle.NumSides = 100
fovCircle.Filled = false
fovCircle.Visible = false

local function createBox()
    local box = Drawing.new("Square")
    box.Color = Color3.new(1,0,0)
    box.Thickness = 2
    box.Filled = false
    box.Visible = false
    return box
end

local function createTracer()
    local line = Drawing.new("Line")
    line.Color = Color3.new(1,1,1)
    line.Thickness = 1
    line.Visible = false
    return line
end

local function createNametag(name)
    local text = Drawing.new("Text")
    text.Text = name
    text.Color = Color3.new(1,1,1)
    text.Size = 16
    text.Center = true
    text.Outline = true
    text.Visible = false
    return text
end

local function isIgnored(player)
    return player == LocalPlayer or ignorePlayers[player.Name]
end

-- Find closest player to mouse within FOV circle
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
                        -- Raycast check for visibility
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

-- Update ESP per frame
RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    fovCircle.Position = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    fovCircle.Radius = aimbotFOV
    fovCircle.Visible = aimbotEnabled

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
                    -- Create ESP objects if needed
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

                    -- Calculate box position (2D)
                    local boxPosX = screenPos.X - boxWidth / 2
                    local boxPosY = screenPos.Y - boxHeight / 2

                    -- ESP Box
                    if espEnabled then
                        box.Position = Vector2.new(boxPosX, boxPosY)
                        box.Size = Vector2.new(boxWidth, boxHeight)
                        box.Visible = true
                    else
                        box.Visible = false
                    end

                    -- Tracers (from bottom center of screen)
                    if tracersEnabled then
                        tracer.From = Vector2.new(viewportSize.X / 2, viewportSize.Y)
                        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                        tracer.Visible = true
                    else
                        tracer.Visible = false
                    end

                    -- Nametags (above head)
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

                    -- Chams
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
                    -- Hide ESP when not on screen
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

    -- Cleanup ESP for players who left/died
    for player, _ in pairs(ESPObjects) do
        if not playersOnScreen[player] then
            if ESPObjects[player].Box then ESPObjects[player].Box:Remove() end
            if ESPObjects[player].Tracer then ESPObjects[player].Tracer:Remove() end
            if ESPObjects[player].Nametag then ESPObjects[player].Nametag:Remove() end
            ESPObjects[player] = nil
        end
    end
end)

-- Aimbot update
local holding = false

RunService.RenderStepped:Connect(function()
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

        -- Aim exactly at the center of the head
        local camPos = Camera.CFrame.Position
        local direction = (head.Position - camPos).Unit
        local targetCFrame = CFrame.new(camPos, camPos + direction)

        -- Smoothly interpolate the camera
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 - aimbotSmooth)

        -- Hold mouse button 1 (shoot)
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

-- GUI and toggles omitted here for brevity — use your existing GUI code but ensure toggles change the variables espEnabled, chamsEnabled, tracersEnabled, nametagsEnabled, aimbotEnabled, aimbotFOV, aimbotSmooth

-- Don't forget to update the fovCircle.Radius = aimbotFOV when slider changes

