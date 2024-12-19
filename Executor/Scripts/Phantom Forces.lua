-- Original Source : https://pastebin.com/raw/Va4mY1GY
-- Remaked by ver#3494
-- Join Ver's Discord : https://discord.com/invite/Jvg3s3W2Jc

local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Phantom Forces - ver#3494", "Sentinel")

local AimbotTab = Window:NewTab("Aimbot")
local AimbotSection = AimbotTab:NewSection("Aimbot")
local FovSet = AimbotTab:NewSection("FOV Settings")

local EspTab = Window:NewTab("ESP")
local EspSection = EspTab:NewSection("ESP")

local ExperimentalTab = Window:NewTab("Experimental")
local SASection = ExperimentalTab:NewSection("Silent Aim")
local FovSet2 = ExperimentalTab:NewSection("FOV Settings")

local ColorTab = Window:NewTab("Settings")
local BindsSection = ColorTab:NewSection("Binds")

local scList = {}
scList = {"Scripter: CNF-RDev", "UiLib: KavoUI", "Ramaker: ver#3494"}

local changelogs = {}
changelogs = {"> Released (7 - October - 2021)"}

local AbColor = Color3.fromRGB(255, 128, 128)
local EspColor = Color3.fromRGB(255, 128, 128)
local AbColor2 = Color3.fromRGB(255, 128, 128)

FovSet:NewColorPicker("Fov Color", "VER: Change ur Ring Fov Color", Color3.fromRGB(255,128,128), function(color)
    AbColor2 = color
end)

FovSet2:NewColorPicker("Fov Color", "VER: Change ur Ring Fov Color", Color3.fromRGB(255,128,128), function(color)
    AbColor = color
end)

EspSection:NewColorPicker("Esp Color", "VER: Change ur ESP Color", Color3.fromRGB(255,128,128), function(color)
    EspColor = color
end)


local smoothing = 1
local fov = 500
local wallCheck = false
local maxWalls = 0
local abTargetPart = "Head"
local FOVringList = {}

local function isPointVisible(targetForWallCheck, mw)
    local castPoints = {targetForWallCheck.PrimaryPart.Position}
    local ignoreList = {targetForWallCheck, game.Players.LocalPlayer.Character, game.Workspace.CurrentCamera}
    local result = workspace.CurrentCamera:GetPartsObscuringTarget(castPoints, ignoreList)
    
    return #result <= mw
end

AimbotSection:NewToggle("Enabled", "VER: Aimbot, RMB to action", function(state)
    if state then
        FOVringList = {}
        abLoop = rs.RenderStepped:Connect(function()
            for i,v in pairs(FOVringList) do
                v:Remove()
            end
            
            FOVringList = {}
            
            local FOVring2 = Drawing.new("Circle")
            FOVring2.Visible = vsfov
            FOVring2.Thickness = trfov / 1
            FOVring2.Radius = fov / workspace.CurrentCamera.FieldOfView
            FOVring2.Transparency = 1
            FOVring2.Color = AbColor2
            FOVring2.Position = game.Workspace.CurrentCamera.ViewportSize/2
            
            FOVringList[#FOVringList+1] = FOVring2
            
            local team
            if game.Players.LocalPlayer.Team.Name == "Ghosts" then team = "Phantoms" else team = "Ghosts" end
            
            local target = Vector2.new(math.huge, math.huge)
            local targetPos
            local targetPlayer
            if game.Workspace.Players:FindFirstChild(team) then
                for i,v in pairs(game.Workspace.Players:FindFirstChild(team):GetChildren()) do
                    local pos = v[abTargetPart].Position
                    local ScreenSpacePos, IsOnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(pos)
                    ScreenSpacePos = Vector2.new(ScreenSpacePos.X, ScreenSpacePos.Y) - game.Workspace.CurrentCamera.ViewportSize/2
                    
                    if IsOnScreen and ScreenSpacePos.Magnitude < target.Magnitude and (isPointVisible(v, maxWalls) or not wallCheck) then
                        target = ScreenSpacePos
                        targetPos = pos
                        targetPlayer = v
                    end
                end
            end
            
            if target.Magnitude <= fov / workspace.CurrentCamera.FieldOfView and uis:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                if target ~= Vector2.new(math.huge, math.huge) then
                    mousemoverel(target.X/smoothing, target.Y/smoothing)
                end
            end
        end)
    else
        abLoop:Disconnect()
        for i,v in pairs(FOVringList) do
            v:Remove()
        end
    end
end)
AimbotSection:NewToggle("Visible Check", "VER: Just accept to Visible Enemy ", function(state) wallCheck = state end)
AimbotSection:NewSlider("Max Wallbangs", "VER: Max of ur Wallbangs", 50, 0, function(s) maxWalls = s end)
AimbotSection:NewSlider("Smoothing", "VER: i can't explain this shit", 300, 100, function(s) smoothing = s/100 end)
AimbotSection:NewDropdown("Target Part", "VER: Target body to aim", {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}, function(currentOption) abTargetPart = currentOption end)
FovSet:NewSlider("Fov Size", "VER: Resize Ring", 50000, 500, function(s) fov = s end)
FovSet:NewSlider("Fov Thickness", "VER: Make ur FOV fat", 5, 1, function(d) trfov = d end)
FovSet:NewToggle("Enable Fov", "VER: Visible ur Fov ", function(a) vsfov = a end)


local saTargetPart = "Head"
local safov = 500
local panicMode = false
local panicDistance = 5
local saWallCheck = false
local saWallBangs = 0
local gunCF
local motor
local sa = false
local saFovRingList = {}

saLoop = rs.RenderStepped:Connect(function()
    for i,v in pairs(saFovRingList) do
        v:Remove()
    end
      
    saFovRingList = {}
    if not sa then return end        
    local FOVring = Drawing.new("Circle")
    FOVring.Visible = hsgov
    FOVring.Thickness = hstgov
    FOVring.Radius = safov / workspace.CurrentCamera.FieldOfView
    FOVring.Transparency = 1
    FOVring.Color = AbColor
    FOVring.Position = game.Workspace.CurrentCamera.ViewportSize/2
            
    saFovRingList[#saFovRingList+1] = FOVring
    
    local team
    if game.Players.LocalPlayer.Team.Name == "Ghosts" then team = "Phantoms" else team = "Ghosts" end
                
    local targetPos
    local last = Vector2.new(math.huge, math.huge)
    if game.Workspace.Players:FindFirstChild(team) then
        for i,v in pairs(game.Workspace.Players:FindFirstChild(team):GetChildren()) do
            local pos = v[saTargetPart].Position
            local ScreenSpacePos, IsOnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(pos)
            ScreenSpacePos = Vector2.new(ScreenSpacePos.X, ScreenSpacePos.Y) - game.Workspace.CurrentCamera.ViewportSize/2
            
            if (v[saTargetPart].Position - Workspace.CurrentCamera.CFrame.Position).Magnitude <= panicDistance and panicMode then
                targetPos = pos
                break
            end
                    
            if IsOnScreen and ScreenSpacePos.Magnitude < last.Magnitude and ScreenSpacePos.Magnitude <= (safov / workspace.CurrentCamera.FieldOfView) and (isPointVisible(v, saWallBangs) or not saWallCheck) then
                last = ScreenSpacePos
                targetPos = pos
            end
        end
    end
    if targetPos then
        motor = Workspace.CurrentCamera:GetChildren()[3].Trigger.Motor6D
        local cf = motor.C0
                
        local cf2 = CFrame.new(motor.Part0.CFrame:ToWorldSpace(cf).Position, targetPos)
        gunCF = motor.Part0.CFrame:ToObjectSpace(cf2)
    else
        gunCF = nil
        motor = nil
    end
end)
local OldIndex
OldIndex = hookmetamethod(game, "__newindex", newcclosure(function(...)
    local Self, Key, Value = ...

    if sa and motor and gunCF and Self == motor and Key == "C0" then
        return OldIndex(Self, Key, gunCF)
    end

    return OldIndex(...)
end))

SASection:NewToggle("Silent Aim (OP)", "VER: This very sus action", function(state)
    sa = state
end)

SASection:NewToggle("Visible Check", "VER: Just accept to Visible enemy", function(state) saWallCheck = state end)
SASection:NewSlider("Max Wallbangs", "NOTE: This very usefull", 50, 0, function(s) saWallBangs = s end)
SASection:NewDropdown("Target Part", "VER: Target body to aim", {"Head", "Torso", "Right Arm", "Left Arm", "Right Leg", "Left Leg"}, function(currentOption)saTargetPart = currentOption end)
SASection:NewToggle("Panic Mode", "VER: Will track closest player if they are within panic distance", function(state) panicMode = state end)
SASection:NewSlider("Panic Distance", "NOTE: when u get sus moment", 40, 5, function(s) panicDistance = s end)

FovSet2:NewSlider("Fov Size", "VER: Resize Fov Ring", 50000, 500, function(s) safov = s end)
FovSet2:NewSlider("Fov Thickness", "VER: Fov Transparency", 5, 1, function(d) hstgov = d end)
FovSet2:NewToggle("Enabled Fov", "VER: Visible ur Fov ", function(a) hsgov = a end)

local LineList = {}
local width = 3
local height = 5

EspSection:NewToggle("Enabled", "VER: to know enemy location", function(state)
    if state then
        LineList = {}
        espLoop = rs.RenderStepped:Connect(function()
            for i,v in pairs(LineList) do
                if v then
                    v:Remove()
                end
            end
            
            local team
            if game.Players.LocalPlayer.Team.Name == "Ghosts" then team = "Phantoms" else team = "Ghosts" end
            
            LineList = {}
            if game.Workspace.Players:FindFirstChild(team) then
                for i,v in pairs(game.Workspace.Players:FindFirstChild(team):GetChildren()) do
                    local pos = v.PrimaryPart.Position
                    local ScreenSpacePos, IsOnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(pos)
                    
                    a = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Torso.CFrame:PointToWorldSpace(Vector3.new(width/2, height/2, 0)))
                    b = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Torso.CFrame:PointToWorldSpace(Vector3.new(-width/2, height/2, 0)))
                    c = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Torso.CFrame:PointToWorldSpace(Vector3.new(-width/2, -height/2, 0)))
                    d = game.Workspace.CurrentCamera:WorldToViewportPoint(v.Torso.CFrame:PointToWorldSpace(Vector3.new(width/2, -height/2, 0)))
                    
                    a = Vector2.new(a.X, a.Y)
                    b = Vector2.new(b.X, b.Y)
                    c = Vector2.new(c.X, c.Y)
                    d = Vector2.new(d.X, d.Y)
                    
                    if IsOnScreen then
                        local Line = Drawing.new("Quad")
                        Line.Visible = true
                        Line.PointA = a
                        Line.PointB = b
                        Line.PointC = c
                        Line.PointD = d
                        Line.Color = EspColor
                        Line.Thickness = 2
                        Line.Transparency = 1
                        
                        LineList[#LineList+1] = Line
                    end
                end
            end
        end)
    else
        espLoop:Disconnect()
        for i,v in pairs(LineList) do
            v:Remove()
        end
        LineList = {}
    end
end)


-- LOBBY ( IMPORTANT )
local lobby = Window:NewTab("Credits")
local sclobby1 = lobby:NewSection("🔥 Credits")
sclobby1:NewDropdown("Credits", "Name of Creator", scList, function()

end)
sclobby1:NewDropdown("Changelogs", "nothing here", changelogs, function()

end)
sclobby1:NewButton("Games: Phantom Forces", "By StyLIs Studio", function()
    
end)
sclobby1:NewButton("Discord", "Discord: https://discord.gg/Jvg3s3W2Jc", function()
    setclipboard("https://discord.com/invite/Jvg3s3W2Jc")
end)
sclobby1:NewButton("Kick Self", "Kick urself idiot", function()
    game:GetService("Players").LocalPlayer:Kick("Kicked by urself.")
end)
sclobby1:NewButton("Rejoin", "Rejoin a server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,game:GetService("Players").LocalPlayer)
end)
BindsSection:NewKeybind("Toggle UI", "VER: Close/Open Ui", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)