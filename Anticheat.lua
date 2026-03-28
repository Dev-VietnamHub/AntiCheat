-- ================== LOAD UI ==================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/vinh12eqweaws/zingmods/refs/heads/main/zingpro"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- ================== WINDOW ==================
local Window = OrionLib:MakeWindow({
    Name = "Blox Fruits | Anti Cheat ULTIMATE",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "bf_anticheat"
})

local Tab = Window:MakeTab({
    Name = "Anti‑Cheat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ================== CONFIG ==================
local TELEPORT_DIST = 80
local SPEED_LIMIT = 45
local FAST_ATTACK_TIME = 0.18
local NEED_FLAGS = 3

-- ================== DATA ==================
local lastPos = {}
local lastHit = {}
local flags = {}
local detected = {}

-- ================== FLAG SYSTEM ==================
local function addFlag(plr, reason)
    flags[plr] = (flags[plr] or 0) + 1
    if flags[plr] >= NEED_FLAGS and not detected[plr] then
        detected[plr] = true
        OrionLib:MakeNotification({
            Name = "⚠ PHÁT HIỆN NGHI NGỜ",
            Content = plr.Name .. " | " .. reason,
            Time = 6
        })
    end
end

-- ================== SCAN FUNCTION ==================
local function scanPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")

            if hrp then
                if lastPos[plr] then
                    local dist = (hrp.Position - lastPos[plr]).Magnitude
                    if dist > TELEPORT_DIST then
                        addFlag(plr, "Teleport bất thường")
                    end
                    local speed = dist / 0.06
                    if speed > SPEED_LIMIT then
                        addFlag(plr, "Speed Hack")
                    end
                end
                lastPos[plr] = hrp.Position
            end

            if hum and hum.Health < hum.MaxHealth then
                local now = tick()
                if lastHit[plr] and (now - lastHit[plr]) < FAST_ATTACK_TIME then
                    addFlag(plr, "Fast Attack / Kill Aura")
                end
                lastHit[plr] = now
            end
        end
    end
end

-- ================== BUTTON: SCAN ==================
Tab:AddButton({
    Name = "🔍 Quét Hacker",
    Callback = function()
        flags, detected, lastPos, lastHit = {}, {}, {}, {}
        OrionLib:MakeNotification({
            Name = "Anti‑Cheat",
            Content = "Đang quét hành vi bất thường...",
            Time = 3
        })
        for i = 1, 5 do
            scanPlayers()
            task.wait(0.25)
        end
        if next(detected) == nil then
            OrionLib:MakeNotification({
                Name = "Anti‑Cheat",
                Content = "✅ Không phát hiện người chơi đáng ngờ",
                Time = 4
            })
        end
    end
})

-- ================== ESP SYSTEM ==================
_G.ESPEnabled = false
local ESPs = {}

local function CreateESP(plr)
    if plr == LocalPlayer or ESPs[plr] then return end

    local function apply(char)
        local head = char:WaitForChild("Head", 5)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not head or not hrp then return end

        local gui = Instance.new("BillboardGui")
        gui.Name = "ESP_NAME"
        gui.Adornee = head
        gui.Size = UDim2.new(0, 100, 0, 20)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.AlwaysOnTop = true

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.TextSize = 12
        txt.Font = Enum.Font.Gotham
        txt.TextColor3 = Color3.fromRGB(255,255,255)
        txt.TextStrokeTransparency = 0.5
        txt.Text = plr.Name

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not _G.ESPEnabled or not LocalPlayer.Character then
                if conn then conn:Disconnect() end
                return
            end
            local lhrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if lhrp then
                local dist = math.floor((hrp.Position - lhrp.Position).Magnitude)
                txt.Text = plr.Name .. " [" .. dist .. "m]"
            end
        end)

        gui.Parent = head
        ESPs[plr] = gui
    end

    if plr.Character then apply(plr.Character) end
    plr.CharacterAdded:Connect(apply)
end

local function RemoveESP(plr)
    if ESPs[plr] then
        ESPs[plr]:Destroy()
        ESPs[plr] = nil
    end
end

-- ================== ESP TOGGLE ==================
Tab:AddToggle({
    Name = "👁 ESP Người Chơi (Tên + Mét)",
    Default = false,
    Callback = function(v)
        _G.ESPEnabled = v
        if v then
            for _, plr in pairs(Players:GetPlayers()) do
                CreateESP(plr)
            end
        else
            for plr,_ in pairs(ESPs) do
                RemoveESP(plr)
            end
        end
    end
})

-- ================== FPS BOOST / REDUCE LAG ==================
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Reduced = false

local function ReduceLag()
    if Reduced then
        OrionLib:MakeNotification({
            Name = "FPS BOOST",
            Content = "⚠ FPS Boost đã bật rồi",
            Time = 3
        })
        return
    end
    Reduced = true

    -- Lighting
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)

    -- Remove heavy effects
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter")
        or v:IsA("Trail")
        or v:IsA("Beam")
        or v:IsA("Smoke")
        or v:IsA("Fire")
        or v:IsA("Explosion") then
            pcall(function()
                v.Enabled = false
            end)
        end

        if v:IsA("BasePart") then
            pcall(function()
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.CastShadow = false
            end)
        end
    end

    -- Terrain
    pcall(function()
        Workspace.Terrain.WaterWaveSize = 0
        Workspace.Terrain.WaterWaveSpeed = 0
        Workspace.Terrain.WaterReflectance = 0
        Workspace.Terrain.WaterTransparency = 1
    end)

    OrionLib:MakeNotification({
        Name = "FPS BOOST",
        Content = "✅ Đã giảm lag & tăng FPS thành công",
        Time = 4
    })
end

-- ================== BUTTON ==================
Tab:AddButton({
    Name = "⚡ Giảm Lag / FPS Boost",
    Callback = function()
        ReduceLag()
    end
})

-- ================== HOP SERVER ==================
Tab:AddButton({
    Name = "🌐 Hop Server",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Server Hop",
            Content = "Đang chuyển server...",
            Time = 3
        })
        task.wait(1)
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
})

-- ================== TELEPORT NGƯỜI CHƠI ==================
local SelectedPlayer = nil

local function GetPlayerNames()
    local names = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(names, plr.Name)
        end
    end
    return names
end

Tab:AddDropdown({
    Name = "🎯 Chọn người chơi để Teleport",
    Options = GetPlayerNames(),
    Callback = function(v)
        SelectedPlayer = v
    end
})

Tab:AddButton({
    Name = "🔄 Refresh danh sách người chơi",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Teleport",
            Content = "🔄 Danh sách người chơi đã làm mới",
            Time = 2
        })
    end
})

Tab:AddButton({
    Name = "🚀 Teleport tới người chơi",
    Callback = function()
        if not SelectedPlayer then
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "❌ Chưa chọn người chơi",
                Time = 3
            })
            return
        end

        local target = Players:FindFirstChild(SelectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myHRP then return end

            myHRP.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)

            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "✅ Đã teleport tới: " .. target.Name,
                Time = 3
            })
        else
            OrionLib:MakeNotification({
                Name = "Teleport",
                Content = "⚠ Không tìm thấy người chơi",
                Time = 3
            })
        end
    end
})

-- ================== NOCIP + WALKSPEED ==================
local NoclipEnabled = false
local WalkSpeedValue = 16
local NoclipConnection

local function SetNoclip(state)
    NoclipEnabled = state
    if state then
        if NoclipConnection then NoclipConnection:Disconnect() end
        NoclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end
-- ================== WALK SPEED FIX (ANTI RESET) ==================
local WalkSpeedEnabled = false
local WalkSpeedValue = 16
local WalkSpeedConn

local function StartWalkSpeed()
    if WalkSpeedConn then WalkSpeedConn:Disconnect() end
    WalkSpeedConn = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = WalkSpeedValue
        end
    end)
end

local function StopWalkSpeed()
    if WalkSpeedConn then
        WalkSpeedConn:Disconnect()
        WalkSpeedConn = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = 16
    end
end

-- Toggle WalkSpeed
Tab:AddToggle({
    Name = "🏃 WalkSpeed (Anti Reset)",
    Default = false,
    Callback = function(v)
        WalkSpeedEnabled = v
        if v then
            StartWalkSpeed()
        else
            StopWalkSpeed()
        end
    end
})

-- Slider WalkSpeed
Tab:AddSlider({
    Name = "⚡ Chỉnh tốc độ chạy",
    Min = 16,
    Max = 300,
    Default = 16,
    Increment = 1,
    ValueName = "Speed",
    Callback = function(v)
        WalkSpeedValue = v
    end
})

-- Giữ speed khi respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    if WalkSpeedEnabled then
        StartWalkSpeed()
    end
end)
-- ================== INIT UI ==================
OrionLib:Init()
