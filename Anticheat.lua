-- ================== LOAD UI ==================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/vinh12eqweaws/zingmods/refs/heads/main/zingpro"
))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local Camera = workspace.CurrentCamera

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

-- ================== FREECAM DATA ==================
local Freecam = false
local Speed = 2
local Sensitivity = 0.15

local move = Vector3.zero
local rotation = Vector2.zero
local lastCF

-- ================== FREECAM FUNCTIONS ==================
local function enableFreecam()
    Freecam = true
    lastCF = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable
end

local function disableFreecam()
    Freecam = false
    Camera.CameraType = Enum.CameraType.Custom
    Camera.CFrame = lastCF
end

-- ================== FREECAM BUTTON ==================
Tab:AddToggle({
    Name = "🎥 FreeCam (FlyCam)",
    Default = false,
    Callback = function(Value)
        if Value then
            enableFreecam()
        else
            disableFreecam()
        end
    end
})

-- ================== PC CONTROL ==================
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not Freecam then return end
    if input.KeyCode == Enum.KeyCode.W then move += Vector3.new(0,0,-1) end
    if input.KeyCode == Enum.KeyCode.S then move += Vector3.new(0,0,1) end
    if input.KeyCode == Enum.KeyCode.A then move += Vector3.new(-1,0,0) end
    if input.KeyCode == Enum.KeyCode.D then move += Vector3.new(1,0,0) end
    if input.KeyCode == Enum.KeyCode.Space then move += Vector3.new(0,1,0) end
    if input.KeyCode == Enum.KeyCode.LeftShift then move += Vector3.new(0,-1,0) end
end)

UIS.InputEnded:Connect(function(input)
    if not Freecam then return end
    if input.KeyCode == Enum.KeyCode.W then move -= Vector3.new(0,0,-1) end
    if input.KeyCode == Enum.KeyCode.S then move -= Vector3.new(0,0,1) end
    if input.KeyCode == Enum.KeyCode.A then move -= Vector3.new(-1,0,0) end
    if input.KeyCode == Enum.KeyCode.D then move -= Vector3.new(1,0,0) end
    if input.KeyCode == Enum.KeyCode.Space then move -= Vector3.new(0,1,0) end
    if input.KeyCode == Enum.KeyCode.LeftShift then move -= Vector3.new(0,-1,0) end
end)

-- ================== MOBILE + MOUSE LOOK ==================
UIS.InputChanged:Connect(function(input)
    if not Freecam then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
        rotation += Vector2.new(-input.Delta.y, -input.Delta.x) * Sensitivity
    end
end)

-- ================== UPDATE CAMERA ==================
RunService.RenderStepped:Connect(function()
    if not Freecam then return end
    local cf = Camera.CFrame
    local rotCF = CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), 0)
    local moveWorld = cf:VectorToWorldSpace(move) * Speed
    Camera.CFrame = CFrame.new(cf.Position) * rotCF + moveWorld
end)

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
