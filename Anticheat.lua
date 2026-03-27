local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local localPlayer = Players.LocalPlayer
local lastPositions = {}
local lastDamages = {}

-- Ngưỡng cảnh báo
local TELEPORT_THRESHOLD = 50
local FAST_ATTACK_THRESHOLD = 0.2

-- Tạo ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerMonitorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Tạo Frame chính
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 10, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "Danh sách người chơi"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Bảng lưu TextLabel player
local playerLabels = {}

-- Hàm tạo label player
local function addPlayerLabel(player)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    lastPositions[player] = hrp and hrp.Position or Vector3.new()
    lastDamages[player] = tick()

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,0,25)
    label.Position = UDim2.new(0,0,0,30 + (#playerLabels * 25))
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Text = player.Name
    label.Parent = frame

    playerLabels[player] = label
end

-- Khởi tạo player hiện tại
for _, player in pairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        addPlayerLabel(player)
    end
end

-- Player mới vào
Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        addPlayerLabel(player)
    end
end)

-- Player rời
Players.PlayerRemoving:Connect(function(player)
    if playerLabels[player] then
        playerLabels[player]:Destroy()
        playerLabels[player] = nil
    end
end)

-- Update label hacker
local function markHack(player, reason)
    if playerLabels[player] then
        playerLabels[player].TextColor3 = Color3.fromRGB(255,0,0)
        playerLabels[player].Text = player.Name.." ⚠ "..reason

        -- 🔔 Thông báo tức thì
        StarterGui:SetCore("SendNotification", {
            Title = "Hack Alert!";
            Text = player.Name.." khả nghi: "..reason;
            Duration = 5;
        })
    end
end

local function resetLabel(player)
    if playerLabels[player] then
        playerLabels[player].TextColor3 = Color3.fromRGB(255,255,255)
        playerLabels[player].Text = player.Name
    end
end

-- Quét realtime
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos = hrp.Position
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local now = tick()

            local suspicious = false
            local reason = ""

            -- Kiểm tra teleport
            local lastPos = lastPositions[player]
            local dist = (pos - lastPos).Magnitude
            if dist > TELEPORT_THRESHOLD then
                suspicious = true
                reason = "Teleport"
            -- Kiểm tra fast attack
            elseif humanoid and humanoid.Health < humanoid.MaxHealth and (now - lastDamages[player] < FAST_ATTACK_THRESHOLD) then
                suspicious = true
                reason = "FastAttack"
                lastDamages[player] = now
            end

            if suspicious then
                markHack(player, reason)
            else
                resetLabel(player)
            end

            lastPositions[player] = pos
        end
    end
end)