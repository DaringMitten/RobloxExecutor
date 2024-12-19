-- Required Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")

-- Notification Function
local function notify(message)
    StarterGui:SetCore("SendNotification", {
        Title = "Script Notification"; -- Notification title
        Text = message; -- Notification message
        Duration = 3; -- Display duration in seconds
    })
end

-- Example ESP Visibility Toggle
_G.ESPVisible = false -- Default state

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then -- Example key to toggle ESP
        _G.ESPVisible = not _G.ESPVisible -- Toggle visibility
        if _G.ESPVisible then
            notify("ESP Enabled!") -- Send notification when ESP is enabled
        else
            notify("ESP Disabled!") -- Send notification when ESP is disabled
        end
    end
end)

-- ESP Configuration
local ESPEnabled = false
local TeamCheck = false
local ESPTextSize = 14
local ESPTextColor = Color3.fromRGB(0, 255, 0) -- Default Green
local ESPTransparency = 0.7
local ESPOutline = true

-- Store created ESP instances
local ESPInstances = {}

-- Function to Create ESP for a Player
local function CreateESP(player)
    local esp = Drawing.new("Text")
    esp.Size = ESPTextSize
    esp.Center = true
    esp.Outline = ESPOutline
    esp.Color = ESPTextColor
    esp.Transparency = ESPTransparency

    ESPInstances[player] = esp

    RunService.RenderStepped:Connect(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            esp.Visible = false
            return
        end

        if TeamCheck and player.Team == LocalPlayer.Team then
            esp.Visible = false
            return
        end

        local rootPart = player.Character:WaitForChild("HumanoidRootPart")
        local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

        if onScreen and ESPEnabled then
            local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
            esp.Text = string.format("%s [%d]", player.Name, math.floor(distance))
            esp.Position = Vector2.new(screenPosition.X, screenPosition.Y - 25)
            esp.Visible = true
        else
            esp.Visible = false
        end
    end)

    player.AncestryChanged:Connect(function(_, parent)
        if not parent then
            esp:Remove()
        end
    end)
end

-- Setup ESP for all players
local function SetupESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        CreateESP(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if ESPInstances[player] then
            ESPInstances[player]:Remove()
            ESPInstances[player] = nil
        end
    end)
end

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESP_Aimbot_GUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 220)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -125)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleLabel.Text = "ESP GUI"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.Parent = mainFrame

-- Toggle Button Creation Function
local function createToggleButton(name, position, toggleFunction)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Text = name .. ": Off"
    button.Parent = mainFrame

    local active = false
    button.MouseButton1Click:Connect(function()
        active = not active
        button.Text = name .. (active and ": On" or ": Off")
        button.BackgroundColor3 = active and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(60, 60, 60)
        toggleFunction(active)
    end)
end

-- ESP Toggle
createToggleButton("Enable ESP", UDim2.new(0, 10, 0, 40), function(active)
    ESPEnabled = active
end)

-- Team Check Toggle
createToggleButton("Team Check", UDim2.new(0, 10, 0, 80), function(active)
    TeamCheck = active
end)

-- Notification System
local function showNotification(message, duration)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 40)
    notification.Position = UDim2.new(0.5, -150, 0.1, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notification.TextColor3 = Color3.new(1, 1, 1)
    notification.Font = Enum.Font.SourceSansBold
    notification.TextSize = 16
    notification.Text = message
    notification.Parent = screenGui

    task.delay(duration or 3, function()
        screenGui:Destroy()
    end)
end

-- Initialize ESP and Show Notification
SetupESP()
showNotification("ESP GUI Loaded | User: " .. LocalPlayer.Name, 3)

-- Minimize and Reopen Functionality
local isGuiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        isGuiVisible = not isGuiVisible
        screenGui.Enabled = isGuiVisible
    end
end)
