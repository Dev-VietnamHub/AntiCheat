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
        gui.Size = UDim2.new(0, 160, 0, 30)
        gui.StudsOffset = Vector3.new(0, 2.3, 0)
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

OrionLib:Init()
