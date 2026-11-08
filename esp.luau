
--[[
    ESP ONLY - ROBLOX STUDIO
    Place in StarterPlayer > StarterPlayerScripts
    Supports PC and Mobile
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Config = {
    Enabled = true,
    Boxes = true,
    Names = true,
    Health = true,
    Items = true,
    Distance = true,
    TeamCheck = false,
    MaxDistance = 1500,
    Color = Color3.fromRGB(0, 255, 170)
}

local ESP = {}
local UIVisible = true

-- GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "ESP_Interface"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = PlayerGui

-- Drawing container
local Overlay = Instance.new("Frame")
Overlay.Name = "ESPOverlay"
Overlay.Size = UDim2.fromScale(1, 1)
Overlay.BackgroundTransparency = 1
Overlay.Parent = GUI

-- Main window
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(270, 390)
Main.Position = UDim2.new(0, 20, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(17, 19, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = GUI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 9)

local Stroke = Instance.new("UIStroke")
Stroke.Color = Config.Color
Stroke.Thickness = 1
Stroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 42)
Title.BackgroundColor3 = Color3.fromRGB(25, 28, 36)
Title.Text = "  INFORMANT  //  ESP"
Title.TextColor3 = Config.Color
Title.TextSize = 17
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 9)

-- Mobile / PC dragging
do
    local dragging = false
    local dragStart
    local startPosition

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            Main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- UI helper
local function CreateButton(text, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 34)
    button.Position = UDim2.fromOffset(12, y)
    button.BackgroundColor3 = Color3.fromRGB(31, 35, 44)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 14
    button.Font = Enum.Font.Code
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = Main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 5)

    button.Activated:Connect(callback)
    return button
end

local function Toggle(name, y, key)
    local button

    local function refresh()
        button.Text = name .. "  :  " ..
            (Config[key] and "ON" or "OFF")

        button.TextColor3 = Config[key]
            and Config.Color
            or Color3.fromRGB(160, 160, 160)
    end

    button = CreateButton("", y, function()
        Config[key] = not Config[key]
        refresh()
    end)

    refresh()
end

Toggle("ESP", 55, "Enabled")
Toggle("2D BOXES", 94, "Boxes")
Toggle("PLAYER NAMES", 133, "Names")
Toggle("HEALTH BAR", 172, "Health")
Toggle("HELD ITEM", 211, "Items")
Toggle("DISTANCE", 250, "Distance")
Toggle("TEAM CHECK", 289, "TeamCheck")

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(1, -24, 0, 25)
DistanceLabel.Position = UDim2.fromOffset(12, 331)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.TextColor3 = Config.Color
DistanceLabel.Font = Enum.Font.Code
DistanceLabel.TextSize = 13
DistanceLabel.Text = "MAX DISTANCE: 1500"
DistanceLabel.Parent = Main

local DistanceButton = CreateButton("CHANGE MAX DISTANCE", 356, function()
    Config.MaxDistance = Config.MaxDistance + 500
    if Config.MaxDistance > 3000 then
        Config.MaxDistance = 500
    end
    DistanceLabel.Text = "MAX DISTANCE: " .. Config.MaxDistance
end)

-- Mobile visibility button
local MobileButton = Instance.new("TextButton")
MobileButton.Name = "ESPMenuButton"
MobileButton.Size = UDim2.fromOffset(90, 42)
MobileButton.Position = UDim2.new(1, -105, 0, 15)
MobileButton.BackgroundColor3 = Color3.fromRGB(17, 19, 25)
MobileButton.TextColor3 = Config.Color
MobileButton.Text = "ESP MENU"
MobileButton.TextSize = 13
MobileButton.Font = Enum.Font.Code
MobileButton.Parent = GUI

Instance.new("UICorner", MobileButton).CornerRadius = UDim.new(0, 7)

MobileButton.Activated:Connect(function()
    UIVisible = not UIVisible
    Main.Visible = UIVisible
end)

-- ESP object creation
local function CreateESP(player, character)
    if player == LocalPlayer then return end

    if ESP[player] then
        for _, object in pairs(ESP[player]) do
            if typeof(object) == "Instance" then
                object:Destroy()
            end
        end
    end

    local box = Instance.new("Frame")
    box.Name = "ESPBox"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Visible = false
    box.Parent = Overlay

    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Config.Color
    boxStroke.Thickness = 1.5
    boxStroke.Parent = box

    local healthBackground = Instance.new("Frame")
    healthBackground.Size = UDim2.fromOffset(5, 100)
    healthBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    healthBackground.BorderSizePixel = 0
    healthBackground.Visible = false
    healthBackground.Parent = Overlay

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.Position = UDim2.fromScale(0, 1)
    healthFill.AnchorPoint = Vector2.new(0, 1)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBackground

    local info = Instance.new("TextLabel")
    info.BackgroundTransparency = 1
    info.TextColor3 = Config.Color
    info.TextStrokeTransparency = 0.2
    info.Font = Enum.Font.Code
    info.TextSize = 13
    info.Text = ""
    info.Visible = false
    info.Parent = Overlay

    ESP[player] = {
        Box = box,
        BoxStroke = boxStroke,
        HealthBackground = healthBackground,
        HealthFill = healthFill,
        Info = info,
        Character = character
    }
end

local function RemoveESP(player)
    local data = ESP[player]
    if not data then return end

    data.Box:Destroy()
    data.HealthBackground:Destroy()
    data.Info:Destroy()

    ESP[player] = nil
end

local function TrackPlayer(player)
    if player == LocalPlayer then return end

    player.CharacterAdded:Connect(function(character)
        CreateESP(player, character)
    end)

    if player.Character then
        CreateESP(player, player.Character)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    TrackPlayer(player)
end

Players.PlayerAdded:Connect(TrackPlayer)
Players.PlayerRemoving:Connect(RemoveESP)

-- 2D ESP update
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    for player, data in pairs(ESP) do
        local character = data.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")

        local function hide()
            data.Box.Visible = false
            data.HealthBackground.Visible = false
            data.Info.Visible = false
        end

        if not character or not character.Parent
        or not humanoid or humanoid.Health <= 0
        or not root or not head then
            hide()
            continue
        end

        local distance = (Camera.CFrame.Position - root.Position).Magnitude

        local sameTeam = Config.TeamCheck
            and LocalPlayer.Team ~= nil
            and player.Team == LocalPlayer.Team

        if not Config.Enabled or distance > Config.MaxDistance or sameTeam then
            hide()
            continue
        end

        -- Calculate screen-space bounding rectangle
        local topWorld = (head.CFrame * CFrame.new(0, 0.7, 0)).Position
        local bottomWorld = (root.CFrame * CFrame.new(0, -3, 0)).Position

        local top, topVisible = Camera:WorldToViewportPoint(topWorld)
        local bottom, bottomVisible = Camera:WorldToViewportPoint(bottomWorld)

        if not topVisible and not bottomVisible then
            hide()
            continue
        end

        local height = math.abs(bottom.Y - top.Y)
        local width = height * 0.55

        if height < 2 then
            hide()
            continue
        end

        local x = top.X - width / 2
        local y = math.min(top.Y, bottom.Y)

        -- 2D box
        data.Box.Visible = Config.Boxes
        data.Box.Position = UDim2.fromOffset(x, y)
        data.Box.Size = UDim2.fromOffset(width, height)
        data.BoxStroke.Color = Config.Color

        -- Health bar
        local healthPercent = math.clamp(
            humanoid.Health / math.max(humanoid.MaxHealth, 1),
            0, 1
        )

        data.HealthBackground.Visible = Config.Health
        data.HealthBackground.Position = UDim2.fromOffset(x - 9, y)
        data.HealthBackground.Size = UDim2.fromOffset(5, height)

        data.HealthFill.Size = UDim2.new(1, 0, healthPercent, 0)

        if healthPercent > 0.6 then
            data.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        elseif healthPercent > 0.3 then
            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        end

        -- Name, held item and distance
        local infoText = {}

        if Config.Names then
            table.insert(infoText, player.DisplayName)
        end

        if Config.Items then
            local tool = character:FindFirstChildOfClass("Tool")
            table.insert(infoText, tool and tool.Name or "No item")
        end

        if Config.Distance then
            table.insert(infoText, string.format("%.0f studs", distance))
        end

        data.Info.Visible = #infoText > 0
        data.Info.Text = table.concat(infoText, "\n")
        data.Info.Size = UDim2.fromOffset(220, 55)
        data.Info.Position = UDim2.fromOffset(x + width / 2 - 110, y - 58)
    end
end)

-- Keyboard shortcut
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        UIVisible = not UIVisible
        Main.Visible = UIVisible
    end
end)

print("[ESP] Loaded successfully")
