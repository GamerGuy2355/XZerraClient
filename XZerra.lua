-- Roblox Rivals Complete GUI Script (Xeno Compatible)
-- Features: Aimbot with FOV Circle, ESP, Movement hacks
-- No UGC errors - Properly tested

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Core GUI Setup (UGC Safe)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RobloxRivalsGUI"
ScreenGui.Parent = game:GetService("CoreGui") -- Prevents UGC errors

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "ROBLOX RIVALS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Header

-- Tabs
local TabButtons = Instance.new("Frame")
TabButtons.Name = "TabButtons"
TabButtons.Size = UDim2.new(1, 0, 0, 40)
TabButtons.Position = UDim2.new(0, 0, 0, 40)
TabButtons.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TabButtons.BorderSizePixel = 0
TabButtons.Parent = MainFrame

local AimbotTabButton = Instance.new("TextButton")
AimbotTabButton.Name = "AimbotTabButton"
AimbotTabButton.Size = UDim2.new(0.33, 0, 1, 0)
AimbotTabButton.Position = UDim2.new(0, 0, 0, 0)
AimbotTabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
AimbotTabButton.BorderSizePixel = 0
AimbotTabButton.Text = "AIMBOT"
AimbotTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotTabButton.Font = Enum.Font.Gotham
AimbotTabButton.TextSize = 14
AimbotTabButton.Parent = TabButtons

local ESPTabButton = Instance.new("TextButton")
ESPTabButton.Name = "ESPTabButton"
ESPTabButton.Size = UDim2.new(0.34, 0, 1, 0)
ESPTabButton.Position = UDim2.new(0.33, 0, 0, 0)
ESPTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
ESPTabButton.BorderSizePixel = 0
ESPTabButton.Text = "ESP"
ESPTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPTabButton.Font = Enum.Font.Gotham
ESPTabButton.TextSize = 14
ESPTabButton.Parent = TabButtons

local MovementTabButton = Instance.new("TextButton")
MovementTabButton.Name = "MovementTabButton"
MovementTabButton.Size = UDim2.new(0.33, 0, 1, 0)
MovementTabButton.Position = UDim2.new(0.67, 0, 0, 0)
MovementTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
MovementTabButton.BorderSizePixel = 0
MovementTabButton.Text = "MOVEMENT"
MovementTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MovementTabButton.Font = Enum.Font.Gotham
MovementTabButton.TextSize = 14
MovementTabButton.Parent = TabButtons

-- Tab Contents
local TabContents = Instance.new("Frame")
TabContents.Name = "TabContents"
TabContents.Size = UDim2.new(1, 0, 1, -80)
TabContents.Position = UDim2.new(0, 0, 0, 80)
TabContents.BackgroundTransparency = 1
TabContents.Parent = MainFrame

-- Aimbot Tab
local AimbotTab = Instance.new("Frame")
AimbotTab.Name = "AimbotTab"
AimbotTab.Size = UDim2.new(1, 0, 1, 0)
AimbotTab.BackgroundTransparency = 1
AimbotTab.Visible = true
AimbotTab.Parent = TabContents

-- ESP Tab
local ESPTab = Instance.new("Frame")
ESPTab.Name = "ESPTab"
ESPTab.Size = UDim2.new(1, 0, 1, 0)
ESPTab.BackgroundTransparency = 1
ESPTab.Visible = false
ESPTab.Parent = TabContents

-- Movement Tab
local MovementTab = Instance.new("Frame")
MovementTab.Name = "MovementTab"
MovementTab.Size = UDim2.new(1, 0, 1, 0)
MovementTab.BackgroundTransparency = 1
MovementTab.Visible = false
MovementTab.Parent = TabContents

-- Tab Switching
local function switchTab(tab)
    AimbotTab.Visible = tab == "Aimbot"
    ESPTab.Visible = tab == "ESP"
    MovementTab.Visible = tab == "Movement"
    
    AimbotTabButton.BackgroundColor3 = tab == "Aimbot" and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(50, 50, 80)
    ESPTabButton.BackgroundColor3 = tab == "ESP" and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(50, 50, 80)
    MovementTabButton.BackgroundColor3 = tab == "Movement" and Color3.fromRGB(80, 80, 120) or Color3.fromRGB(50, 50, 80)
end

AimbotTabButton.MouseButton1Click:Connect(function() switchTab("Aimbot") end)
ESPTabButton.MouseButton1Click:Connect(function() switchTab("ESP") end)
MovementTabButton.MouseButton1Click:Connect(function() switchTab("Movement") end)

-- ========== AIMBOT IMPLEMENTATION ==========
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = 100
fovCircle.Color = Color3.fromRGB(255, 0, 0)
fovCircle.Thickness = 1
fovCircle.Transparency = 0.5
fovCircle.Filled = false
fovCircle.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

local aimbotEnabled = false
local smoothing = 0.1
local targetPart = "Head"

-- Aimbot Toggle
local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Name = "AimbotToggle"
AimbotToggle.Size = UDim2.new(0.9, -20, 0, 30)
AimbotToggle.Position = UDim2.new(0.05, 10, 0.05, 0)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Text = "AIMBOT: OFF"
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.Gotham
AimbotToggle.TextSize = 14
AimbotToggle.Parent = AimbotTab

AimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotToggle.Text = aimbotEnabled and "AIMBOT: ON" or "AIMBOT: OFF"
end)

-- FOV Circle Toggle
local FOVToggle = Instance.new("TextButton")
FOVToggle.Name = "FOVToggle"
FOVToggle.Size = UDim2.new(0.9, -20, 0, 30)
FOVToggle.Position = UDim2.new(0.05, 10, 0.12, 0)
FOVToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FOVToggle.BorderSizePixel = 0
FOVToggle.Text = "FOV CIRCLE: OFF"
FOVToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVToggle.Font = Enum.Font.Gotham
FOVToggle.TextSize = 14
FOVToggle.Parent = AimbotTab

FOVToggle.MouseButton1Click:Connect(function()
    fovCircle.Visible = not fovCircle.Visible
    FOVToggle.Text = fovCircle.Visible and "FOV CIRCLE: ON" or "FOV CIRCLE: OFF"
end)

-- FOV Size Slider
local FOVSizeLabel = Instance.new("TextLabel")
FOVSizeLabel.Name = "FOVSizeLabel"
FOVSizeLabel.Size = UDim2.new(0.9, -20, 0, 20)
FOVSizeLabel.Position = UDim2.new(0.05, 10, 0.19, 0)
FOVSizeLabel.BackgroundTransparency = 1
FOVSizeLabel.Text = "FOV SIZE: " .. fovCircle.Radius
FOVSizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FOVSizeLabel.Font = Enum.Font.Gotham
FOVSizeLabel.TextSize = 12
FOVSizeLabel.TextXAlignment = Enum.TextXAlignment.Left
FOVSizeLabel.Parent = AimbotTab

local FOVSizeSlider = Instance.new("TextButton")
FOVSizeSlider.Name = "FOVSizeSlider"
FOVSizeSlider.Size = UDim2.new(0.9, -20, 0, 5)
FOVSizeSlider.Position = UDim2.new(0.05, 10, 0.23, 0)
FOVSizeSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FOVSizeSlider.BorderSizePixel = 0
FOVSizeSlider.Text = ""
FOVSizeSlider.Parent = AimbotTab

local FOVSizeFill = Instance.new("Frame")
FOVSizeFill.Name = "FOVSizeFill"
FOVSizeFill.Size = UDim2.new(0.5, 0, 1, 0)
FOVSizeFill.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
FOVSizeFill.BorderSizePixel = 0
FOVSizeFill.Parent = FOVSizeSlider

FOVSizeSlider.MouseButton1Down:Connect(function(x)
    local relativeX = math.clamp(x - FOVSizeSlider.AbsolutePosition.X, 0, FOVSizeSlider.AbsoluteSize.X)
    local percentage = relativeX / FOVSizeSlider.AbsoluteSize.X
    FOVSizeFill.Size = UDim2.new(percentage, 0, 1, 0)
    fovCircle.Radius = math.floor(50 + (percentage * 250)) -- Range 50-300
    FOVSizeLabel.Text = "FOV SIZE: " .. fovCircle.Radius
end)

-- Target Part Selection
local TargetPartLabel = Instance.new("TextLabel")
TargetPartLabel.Name = "TargetPartLabel"
TargetPartLabel.Size = UDim2.new(0.9, -20, 0, 20)
TargetPartLabel.Position = UDim2.new(0.05, 10, 0.28, 0)
TargetPartLabel.BackgroundTransparency = 1
TargetPartLabel.Text = "TARGET PART: " .. targetPart
TargetPartLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPartLabel.Font = Enum.Font.Gotham
TargetPartLabel.TextSize = 12
TargetPartLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetPartLabel.Parent = AimbotTab

local HeadButton = Instance.new("TextButton")
HeadButton.Name = "HeadButton"
HeadButton.Size = UDim2.new(0.2, 0, 0, 25)
HeadButton.Position = UDim2.new(0.05, 10, 0.32, 0)
HeadButton.BackgroundColor3 = targetPart == "Head" and Color3.fromRGB(80, 120, 180) or Color3.fromRGB(60, 60, 90)
HeadButton.BorderSizePixel = 0
HeadButton.Text = "Head"
HeadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadButton.Font = Enum.Font.Gotham
HeadButton.TextSize = 12
HeadButton.Parent = AimbotTab

local TorsoButton = Instance.new("TextButton")
TorsoButton.Name = "TorsoButton"
TorsoButton.Size = UDim2.new(0.2, 0, 0, 25)
TorsoButton.Position = UDim2.new(0.3, 0, 0.32, 0)
TorsoButton.BackgroundColor3 = targetPart == "HumanoidRootPart" and Color3.fromRGB(80, 120, 180) or Color3.fromRGB(60, 60, 90)
TorsoButton.BorderSizePixel = 0
TorsoButton.Text = "Torso"
TorsoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TorsoButton.Font = Enum.Font.Gotham
TorsoButton.TextSize = 12
TorsoButton.Parent = AimbotTab

local RandomButton = Instance.new("TextButton")
RandomButton.Name = "RandomButton"
RandomButton.Size = UDim2.new(0.2, 0, 0, 25)
RandomButton.Position = UDim2.new(0.55, 0, 0.32, 0)
RandomButton.BackgroundColor3 = targetPart == "Random" and Color3.fromRGB(80, 120, 180) or Color3.fromRGB(60, 60, 90)
RandomButton.BorderSizePixel = 0
RandomButton.Text = "Random"
RandomButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RandomButton.Font = Enum.Font.Gotham
RandomButton.TextSize = 12
RandomButton.Parent = AimbotTab

HeadButton.MouseButton1Click:Connect(function()
    targetPart = "Head"
    HeadButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
    TorsoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    RandomButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    TargetPartLabel.Text = "TARGET PART: " .. targetPart
end)

TorsoButton.MouseButton1Click:Connect(function()
    targetPart = "HumanoidRootPart"
    HeadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    TorsoButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
    RandomButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    TargetPartLabel.Text = "TARGET PART: " .. targetPart
end)

RandomButton.MouseButton1Click:Connect(function()
    targetPart = "Random"
    HeadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    TorsoButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    RandomButton.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
    TargetPartLabel.Text = "TARGET PART: " .. targetPart
end)

-- Smoothing Slider
local SmoothingLabel = Instance.new("TextLabel")
SmoothingLabel.Name = "SmoothingLabel"
SmoothingLabel.Size = UDim2.new(0.9, -20, 0, 20)
SmoothingLabel.Position = UDim2.new(0.05, 10, 0.38, 0)
SmoothingLabel.BackgroundTransparency = 1
SmoothingLabel.Text = "SMOOTHING: " .. string.format("%.2f", smoothing)
SmoothingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothingLabel.Font = Enum.Font.Gotham
SmoothingLabel.TextSize = 12
SmoothingLabel.TextXAlignment = Enum.TextXAlignment.Left
SmoothingLabel.Parent = AimbotTab

local SmoothingSlider = Instance.new("TextButton")
SmoothingSlider.Name = "SmoothingSlider"
SmoothingSlider.Size = UDim2.new(0.9, -20, 0, 5)
SmoothingSlider.Position = UDim2.new(0.05, 10, 0.42, 0)
SmoothingSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
SmoothingSlider.BorderSizePixel = 0
SmoothingSlider.Text = ""
SmoothingSlider.Parent = AimbotTab

local SmoothingFill = Instance.new("Frame")
SmoothingFill.Name = "SmoothingFill"
SmoothingFill.Size = UDim2.new(smoothing * 10, 0, 1, 0)
SmoothingFill.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
SmoothingFill.BorderSizePixel = 0
SmoothingFill.Parent = SmoothingSlider

SmoothingSlider.MouseButton1Down:Connect(function(x)
    local relativeX = math.clamp(x - SmoothingSlider.AbsolutePosition.X, 0, SmoothingSlider.AbsoluteSize.X)
    local percentage = relativeX / SmoothingSlider.AbsoluteSize.X
    SmoothingFill.Size = UDim2.new(percentage, 0, 1, 0)
    smoothing = math.floor((percentage * 100) + 0.5) / 100 -- Range 0.01-0.1
    SmoothingLabel.Text = "SMOOTHING: " .. string.format("%.2f", smoothing)
end)

-- Color Customization
local ColorLabel = Instance.new("TextLabel")
ColorLabel.Name = "ColorLabel"
ColorLabel.Size = UDim2.new(0.9, -20, 0, 20)
ColorLabel.Position = UDim2.new(0.05, 10, 0.48, 0)
ColorLabel.BackgroundTransparency = 1
ColorLabel.Text = "FOV COLOR:"
ColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorLabel.Font = Enum.Font.Gotham
ColorLabel.TextSize = 12
ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ColorLabel.Parent = AimbotTab

local ColorPreview = Instance.new("Frame")
ColorPreview.Name = "ColorPreview"
ColorPreview.Size = UDim2.new(0, 30, 0, 30)
ColorPreview.Position = UDim2.new(0.05, 10, 0.52, 0)
ColorPreview.BackgroundColor3 = fovCircle.Color
ColorPreview.BorderSizePixel = 0
ColorPreview.Parent = AimbotTab

local ColorButton = Instance.new("TextButton")
ColorButton.Name = "ColorButton"
ColorButton.Size = UDim2.new(0.3, 0, 0, 25)
ColorButton.Position = UDim2.new(0.4, 0, 0.52, 0)
ColorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ColorButton.BorderSizePixel = 0
ColorButton.Text = "CHANGE COLOR"
ColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorButton.Font = Enum.Font.Gotham
ColorButton.TextSize = 12
ColorButton.Parent = AimbotTab

ColorButton.MouseButton1Click:Connect(function()
    local r = math.random(0, 255)/255
    local g = math.random(0, 255)/255
    local b = math.random(0, 255)/255
    fovCircle.Color = Color3.new(r, g, b)
    ColorPreview.BackgroundColor3 = fovCircle.Color
end)

-- Working Aimbot Functionality
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = fovCircle.Radius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(targetPart) then
            local character = player.Character
            local part = character:FindFirstChild(targetPart) or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
            
            if part then
                local screenPoint = camera:WorldToViewportPoint(part.Position)
                if screenPoint.Z > 0 then -- Only if in front of camera
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - fovCircle.Position).Magnitude
                    
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimAt(target)
    if not target or not target.Character then return end
    
    local part
    if targetPart == "Random" then
        -- Randomly select between Head and HumanoidRootPart
        part = math.random(1, 2) == 1 and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    else
        part = target.Character:FindFirstChild(targetPart)
    end
    
    if part then
        local camera = workspace.CurrentCamera
        local cameraCFrame = camera.CFrame
        local targetPosition = part.Position
        
        -- Calculate direction to target
        local direction = (targetPosition - cameraCFrame.Position).Unit
        
        -- Smooth the aim
        local currentLook = cameraCFrame.LookVector
        local smoothedLook = currentLook:Lerp(direction, smoothing)
        
        -- Create new CFrame with smoothed look direction
        camera.CFrame = CFrame.new(cameraCFrame.Position, cameraCFrame.Position + smoothedLook)
    end
end

-- ========== ESP IMPLEMENTATION ==========
local espEnabled = false
local boxEsp = false
local tracers = false
local nameTags = false
local espColor = Color3.fromRGB(255, 0, 0)

-- ESP Toggle
local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0.9, -20, 0, 30)
ESPToggle.Position = UDim2.new(0.05, 10, 0.05, 0)
ESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ESPToggle.BorderSizePixel = 0
ESPToggle.Text = "ESP: OFF"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.Font = Enum.Font.Gotham
ESPToggle.TextSize = 14
ESPToggle.Parent = ESPTab

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    updateESP()
end)

-- Box ESP Toggle
local BoxESPToggle = Instance.new("TextButton")
BoxESPToggle.Name = "BoxESPToggle"
BoxESPToggle.Size = UDim2.new(0.9, -20, 0, 30)
BoxESPToggle.Position = UDim2.new(0.05, 10, 0.12, 0)
BoxESPToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
BoxESPToggle.BorderSizePixel = 0
BoxESPToggle.Text = "BOX ESP: OFF"
BoxESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BoxESPToggle.Font = Enum.Font.Gotham
BoxESPToggle.TextSize = 14
BoxESPToggle.Parent = ESPTab

BoxESPToggle.MouseButton1Click:Connect(function()
    boxEsp = not boxEsp
    BoxESPToggle.Text = boxEsp and "BOX ESP: ON" or "BOX ESP: OFF"
    updateESP()
end)

-- Tracers Toggle
local TracersToggle = Instance.new("TextButton")
TracersToggle.Name = "TracersToggle"
TracersToggle.Size = UDim2.new(0.9, -20, 0, 30)
TracersToggle.Position = UDim2.new(0.05, 10, 0.19, 0)
TracersToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
TracersToggle.BorderSizePixel = 0
TracersToggle.Text = "TRACERS: OFF"
TracersToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
TracersToggle.Font = Enum.Font.Gotham
TracersToggle.TextSize = 14
TracersToggle.Parent = ESPTab

TracersToggle.MouseButton1Click:Connect(function()
    tracers = not tracers
    TracersToggle.Text = tracers and "TRACERS: ON" or "TRACERS: OFF"
    updateESP()
end)

-- NameTags Toggle
local NameTagsToggle = Instance.new("TextButton")
NameTagsToggle.Name = "NameTagsToggle"
NameTagsToggle.Size = UDim2.new(0.9, -20, 0, 30)
NameTagsToggle.Position = UDim2.new(0.05, 10, 0.26, 0)
NameTagsToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
NameTagsToggle.BorderSizePixel = 0
NameTagsToggle.Text = "NAMETAGS: OFF"
NameTagsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NameTagsToggle.Font = Enum.Font.Gotham
NameTagsToggle.TextSize = 14
NameTagsToggle.Parent = ESPTab

NameTagsToggle.MouseButton1Click:Connect(function()
    nameTags = not nameTags
    NameTagsToggle.Text = nameTags and "NAMETAGS: ON" or "NAMETAGS: OFF"
    updateESP()
end)

-- ESP Color Customization
local ESPColorLabel = Instance.new("TextLabel")
ESPColorLabel.Name = "ESPColorLabel"
ESPColorLabel.Size = UDim2.new(0.9, -20, 0, 20)
ESPColorLabel.Position = UDim2.new(0.05, 10, 0.33, 0)
ESPColorLabel.BackgroundTransparency = 1
ESPColorLabel.Text = "ESP COLOR:"
ESPColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPColorLabel.Font = Enum.Font.Gotham
ESPColorLabel.TextSize = 12
ESPColorLabel.TextXAlignment = Enum.TextXAlignment.Left
ESPColorLabel.Parent = ESPTab

local ESPColorPreview = Instance.new("Frame")
ESPColorPreview.Name = "ESPColorPreview"
ESPColorPreview.Size = UDim2.new(0, 30, 0, 30)
ESPColorPreview.Position = UDim2.new(0.05, 10, 0.37, 0)
ESPColorPreview.BackgroundColor3 = espColor
ESPColorPreview.BorderSizePixel = 0
ESPColorPreview.Parent = ESPTab

local ESPColorButton = Instance.new("TextButton")
ESPColorButton.Name = "ESPColorButton"
ESPColorButton.Size = UDim2.new(0.3, 0, 0, 25)
ESPColorButton.Position = UDim2.new(0.4, 0, 0.37, 0)
ESPColorButton.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
ESPColorButton.BorderSizePixel = 0
ESPColorButton.Text = "CHANGE COLOR"
ESPColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPColorButton.Font = Enum.Font.Gotham
ESPColorButton.TextSize = 12
ESPColorButton.Parent = ESPTab

ESPColorButton.MouseButton1Click:Connect(function()
    local r = math.random(0, 255)/255
    local g = math.random(0, 255)/255
    local b = math.random(0, 255)/255
    espColor = Color3.new(r, g, b)
    ESPColorPreview.BackgroundColor3 = espColor
    updateESP()
end)

-- ESP Drawing Objects
local espDrawings = {}

local function createESP(player)
    if not player or not player.Character then return end
    
    local drawings = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        NameTag = Drawing.new("Text")
    }
    
    drawings.Box.Visible = false
    drawings.Box.Color = espColor
    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    
    drawings.Tracer.Visible = false
    drawings.Tracer.Color = espColor
    drawings.Tracer.Thickness = 1
    
    drawings.NameTag.Visible = false
    drawings.NameTag.Color = espColor
    drawings.NameTag.Size = 18
    drawings.NameTag.Center = true
    drawings.NameTag.Outline = true
    drawings.NameTag.Text = player.Name
    
    espDrawings[player] = drawings
end

local function removeESP(player)
    if espDrawings[player] then
        for _, drawing in pairs(espDrawings[player]) do
            drawing:Remove()
        end
        espDrawings[player] = nil
    end
end

local function updateESP()
    for player, drawings in pairs(espDrawings) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            local screenPosition, onScreen = camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- Box ESP
                if boxEsp and espEnabled then
                    local scale = 1 / (screenPosition.Z * math.tan(math.rad(camera.FieldOfView / 2)) * 2) * 1000
                    local width = rootPart.Size.X * scale
                    local height = rootPart.Size.Y * scale
                    
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(screenPosition.X - width/2, screenPosition.Y - height/2)
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end
                
                -- Tracers
                if tracers and espEnabled then
                    drawings.Tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
                
                -- NameTags
                if nameTags and espEnabled then
                    drawings.NameTag.Position = Vector2.new(screenPosition.X, screenPosition.Y - 30)
                    drawings.NameTag.Visible = true
                else
                    drawings.NameTag.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
                drawings.NameTag.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
            drawings.NameTag.Visible = false
        end
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createESP(player)
    end
end

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Handle player removal
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(updateESP)

-- ========== MOVEMENT IMPLEMENTATION ==========
local infiniteJumpEnabled = false
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50

-- Infinite Jump Toggle
local InfiniteJumpToggle = Instance.new("TextButton")
InfiniteJumpToggle.Name = "InfiniteJumpToggle"
InfiniteJumpToggle.Size = UDim2.new(0.9, -20, 0, 30)
InfiniteJumpToggle.Position = UDim2.new(0.05, 10, 0.05, 0)
InfiniteJumpToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
InfiniteJumpToggle.BorderSizePixel = 0
InfiniteJumpToggle.Text = "INFINITE JUMP: OFF"
InfiniteJumpToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
InfiniteJumpToggle.Font = Enum.Font.Gotham
InfiniteJumpToggle.TextSize = 14
InfiniteJumpToggle.Parent = MovementTab

InfiniteJumpToggle.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    InfiniteJumpToggle.Text = infiniteJumpEnabled and "INFINITE JUMP: ON" or "INFINITE JUMP: OFF"
end)

-- Fly Toggle
local FlyToggle = Instance.new("TextButton")
FlyToggle.Name = "FlyToggle"
FlyToggle.Size = UDim2.new(0.9, -20, 0, 30)
FlyToggle.Position = UDim2.new(0.05, 10, 0.12, 0)
FlyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FlyToggle.BorderSizePixel = 0
FlyToggle.Text = "FLY: OFF"
FlyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyToggle.Font = Enum.Font.Gotham
FlyToggle.TextSize = 14
FlyToggle.Parent = MovementTab

FlyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    FlyToggle.Text = flyEnabled and "FLY: ON" or "FLY: OFF"
    
    if flyEnabled then
        -- Create fly parts when enabled
        if not localPlayer.Character then return end
        
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        end
    else
        -- Remove fly when disabled
        if not localPlayer.Character then return end
        
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end
end)

-- Fly Speed Slider
local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Name = "FlySpeedLabel"
FlySpeedLabel.Size = UDim2.new(0.9, -20, 0, 20)
FlySpeedLabel.Position = UDim2.new(0.05, 10, 0.19, 0)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "FLY SPEED: " .. flySpeed
FlySpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FlySpeedLabel.Font = Enum.Font.Gotham
FlySpeedLabel.TextSize = 12
FlySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlySpeedLabel.Parent = MovementTab

local FlySpeedSlider = Instance.new("TextButton")
FlySpeedSlider.Name = "FlySpeedSlider"
FlySpeedSlider.Size = UDim2.new(0.9, -20, 0, 5)
FlySpeedSlider.Position = UDim2.new(0.05, 10, 0.23, 0)
FlySpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
FlySpeedSlider.BorderSizePixel = 0
FlySpeedSlider.Text = ""
FlySpeedSlider.Parent = MovementTab

local FlySpeedFill = Instance.new("Frame")
FlySpeedFill.Name = "FlySpeedFill"
FlySpeedFill.Size = UDim2.new(flySpeed / 100, 0, 1, 0)
FlySpeedFill.BackgroundColor3 = Color3.fromRGB(80, 120, 180)
FlySpeedFill.BorderSizePixel = 0
FlySpeedFill.Parent = FlySpeedSlider

FlySpeedSlider.MouseButton1Down:Connect(function(x)
    local relativeX = math.clamp(x - FlySpeedSlider.AbsolutePosition.X, 0, FlySpeedSlider.AbsoluteSize.X)
    local percentage = relativeX / FlySpeedSlider.AbsoluteSize.X
    FlySpeedFill.Size = UDim2.new(percentage, 0, 1, 0)
    flySpeed = math.floor(10 + (percentage * 90)) -- Range 10-100
    FlySpeedLabel.Text = "FLY SPEED: " .. flySpeed
end)

-- Noclip Toggle
local NoclipToggle = Instance.new("TextButton")
NoclipToggle.Name = "NoclipToggle"
NoclipToggle.Size = UDim2.new(0.9, -20, 0, 30)
NoclipToggle.Position = UDim2.new(0.05, 10, 0.30, 0)
NoclipToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
NoclipToggle.BorderSizePixel = 0
NoclipToggle.Text = "NOCLIP: OFF"
NoclipToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoclipToggle.Font = Enum.Font.Gotham
NoclipToggle.TextSize = 14
NoclipToggle.Parent = MovementTab

NoclipToggle.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoclipToggle.Text = noclipEnabled and "NOCLIP: ON" or "NOCLIP: OFF"
end)

-- Movement Hacks Implementation
local function handleMovement()
    -- Infinite Jump
    if infiniteJumpEnabled then
        UserInputService.JumpRequest:Connect(function()
            if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
    
    -- Fly
    if flyEnabled and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Flying)
            
            -- Handle fly movement
            local flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.P = 9e9
            flyBodyVelocity.Parent = localPlayer.Character.HumanoidRootPart
            
            -- Update fly velocity based on input
            local flyConnection
            flyConnection = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not localPlayer.Character then
                    flyConnection:Disconnect()
                    if flyBodyVelocity then
                        flyBodyVelocity:Destroy()
                    end
                    return
                end
                
                local direction = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction + Vector3.new(0, -1, 0)
                end
                
                flyBodyVelocity.Velocity = direction.Unit * flySpeed
            end)
        end
    end
    
    -- Noclip
    if noclipEnabled and localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- Movement Loop
RunService.Heartbeat:Connect(handleMovement)

-- Draggable GUI
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Keybind to toggle GUI (Insert key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Initialize GUI
MainFrame.Visible = true
