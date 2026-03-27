-- ================== LOAD UI ==================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/vinh12eqweaws/zingmods/refs/heads/main/zingpro"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

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
local lastPos, lastHit, flags, detected = {}, {}, {}, {}

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

-- ================== SCAN ==================
local function scanPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hrp then
                if lastPos[plr] then
                    local dist = (hrp.Position - lastPos[plr]).Magnitude
                    if dist > TELEPORT_DIST then addFlag(plr,"Teleport") end
                    if (dist/0.06) > SPEED_LIMIT then addFlag(plr,"Speed") end
                end
                lastPos[plr] = hrp.Position
            end
            if hum and hum.Health < hum.MaxHealth then
                local now = tick()
                if lastHit[plr] and (now-lastHit[plr]) < FAST_ATTACK_TIME then
                    addFlag(plr,"Fast Attack")
                end
                lastHit[plr] = now
            end
        end
    end
end

Tab:AddButton({
    Name = "🔍 Quét Hacker",
    Callback = function()
        lastPos, lastHit, flags, detected = {}, {}, {}, {}
        for i=1,5 do scanPlayers(); task.wait(0.25) end
        if next(detected)==nil then
            OrionLib:MakeNotification({
                Name="Anti‑Cheat",
                Content="✅ Không phát hiện người chơi đáng ngờ",
                Time=3
            })
        end
    end
})

-- ================== ESP ==================
_G.ESPEnabled = false
local ESPs = {}

local function CreateESP(plr)
    if plr==LocalPlayer or ESPs[plr] then return end
    local function apply(char)
        local head = char:WaitForChild("Head",5)
        local hrp = char:WaitForChild("HumanoidRootPart",5)
        if not head or not hrp then return end

        local gui = Instance.new("BillboardGui")
        gui.Size = UDim2.new(0,160,0,30)
        gui.StudsOffset = Vector3.new(0,2.3,0)
        gui.AlwaysOnTop = true
        gui.Adornee = head

        local txt = Instance.new("TextLabel", gui)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.TextSize = 12
        txt.Font = Enum.Font.Gotham
        txt.TextColor3 = Color3.new(1,1,1)
        txt.TextStrokeTransparency = 0.5

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not _G.ESPEnabled or not LocalPlayer.Character then
                conn:Disconnect(); return
            end
            local lhrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if lhrp then
                local d = math.floor((hrp.Position-lhrp.Position).Magnitude)
                txt.Text = plr.Name.." ["..d.."m]"
            end
        end)

        gui.Parent = head
        ESPs[plr]=gui
    end
    if plr.Character then apply(plr.Character) end
    plr.CharacterAdded:Connect(apply)
end

local function RemoveESP(plr)
    if ESPs[plr] then ESPs[plr]:Destroy(); ESPs[plr]=nil end
end

Tab:AddToggle({
    Name="👁 ESP (Tên + Mét)",
    Default=false,
    Callback=function(v)
        _G.ESPEnabled=v
        if v then
            for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
        else
            for p,_ in pairs(ESPs) do RemoveESP(p) end
        end
    end
})

-- ================== FREECAM FIXED (NO SHAKE | PC + MOBILE) ==================
_G.Freecam = false

local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local camPos
local yaw, pitch = 0, 0
local speed = 1.4
local sensitivity = 0.002

local keys = {W=0,A=0,S=0,D=0,Q=0,E=0}

local function startFreecam()
    local cf = Camera.CFrame
    camPos = cf.Position
    yaw, pitch = 0, 0

    Camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    UserInputService.MouseIconEnabled = false
end

local function stopFreecam()
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    UserInputService.MouseIconEnabled = true
end

-- PC keyboard
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if keys[i.KeyCode.Name] ~= nil then keys[i.KeyCode.Name] = 1 end
end)

UserInputService.InputEnded:Connect(function(i)
    if keys[i.KeyCode.Name] ~= nil then keys[i.KeyCode.Name] = 0 end
end)

-- Mouse (PC)
UserInputService.InputChanged:Connect(function(i)
    if not _G.Freecam then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement then
        yaw -= i.Delta.X * sensitivity
        pitch = math.clamp(pitch - i.Delta.Y * sensitivity, -1.5, 1.5)
    end
end)

-- Touch (Mobile)
UserInputService.TouchMoved:Connect(function(t, gp)
    if not _G.Freecam or gp then return end
    yaw -= t.Delta.X * sensitivity * 1.5
    pitch = math.clamp(pitch - t.Delta.Y * sensitivity * 1.5, -1.5, 1.5)
end)

-- Update camera (NO multiply stacking)
RunService.RenderStepped:Connect(function()
    if not _G.Freecam then return end

    local moveDir = Vector3.new(
        keys.D - keys.A,
        keys.E - keys.Q,
        keys.S - keys.W
    )

    local rot = CFrame.fromOrientation(pitch, yaw, 0)
    camPos += rot:VectorToWorldSpace(moveDir) * speed
    Camera.CFrame = CFrame.new(camPos) * rot
end)

-- ================== FREECAM TOGGLE (UI) ==================
Tab:AddToggle({
    Name = "🎥 Freecam (Mượt – Không Rung)",
    Default = false,
    Callback = function(v)
        _G.Freecam = v
        if v then
            startFreecam()
            OrionLib:MakeNotification({
                Name = "Freecam",
                Content = "Đã bật Freecam (mượt)",
                Time = 2
            })
        else
            stopFreecam()
            OrionLib:MakeNotification({
                Name = "Freecam",
                Content = "Đã tắt Freecam",
                Time = 2
            })
        end
    end
})
-- ================== HOP SERVER ==================
Tab:AddButton({
    Name="🌐 Hop Server",
    Callback=function()
        TeleportService:Teleport(PlaceId, LocalPlayer)
    end
})

OrionLib:Init()
