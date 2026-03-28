-- ================== LOAD UI ==================
local OrionLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/vinh12eqweaws/zingmods/refs/heads/main/zingpro"
))()

local Window = OrionLib:MakeWindow({Name = "ZingMod", HidePremium = false, SaveConfig = true, ConfigFolder = "dxl_bf"})

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
local selectedPlayer = ""
local noclipEnabled = false
local jumpPowerValue = 100
local noclipConn

Tab:AddSection({"Di chuyển"})

-- 2. NÚT BẬT/TẮT NOCLIP
Tab:AddToggle({
    Name = "Bật Noclip (Xuyên tường)",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            noclipConn = game:GetService("RunService").Stepped:Connect(function()
                if game.Players.LocalPlayer.Character then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
            -- Khôi phục va chạm
            if game.Players.LocalPlayer.Character then
                for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})
local function ApplyWalkSpeed()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = WalkSpeedValue
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    ApplyWalkSpeed()
    if NoclipEnabled then
        SetNoclip(true)
    end
end)

Tab:AddToggle({
    Name = "🚪 Noclip (Xuyên tường)",
    Default = false,
    Callback = function(Value)
        SetNoclip(Value)
        OrionLib:MakeNotification({
            Name = "Noclip",
            Content = Value and "✅ Đã bật Noclip" or "❌ Đã tắt Noclip",
            Time = 2
        })
    end
})

local WalkSpeedValue = 16

Tab:AddTextbox({
    Name = "🏃 Nhập WalkSpeed",
    Default = "16",
    TextDisappear = false,
    Callback = function(txt)
        local v = tonumber(txt)
        if v and v >= 16 and v <= 120 then
            WalkSpeedValue = v
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = WalkSpeedValue
            end
        end
    end
})

-- 3. ĐIỀU CHỈNH NHẢY CAO
Tab:AddSlider({
    Name = "Độ cao bước nhảy",
    Min = 50,
    Max = 500,
    Default = 100,
    Callback = function(Value)
        jumpPowerValue = Value
        local lp = game.Players.LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.UseJumpPower = true
            lp.Character.Humanoid.JumpPower = jumpPowerValue
        end
    end
})

Tab:AddToggle({
  Name = "Auto M1 (Fruit/Melee/Sword)",
  Default = false,
  Callback = function(Value)
    _G.AutoM1 = Value
    
    -- Chạy vòng lặp trong một luồng riêng (spawn) để không làm treo UI
    spawn(function()
        local VirtualUser = game:GetService("VirtualUser")
        
        while _G.AutoM1 do
            task.wait(0.1) -- Tốc độ click (0.1 là khá nhanh và an toàn)
            
            -- Kiểm tra xem người chơi có đang cầm vũ khí nào không
            if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(851, 158), game.Workspace.CurrentCamera.CFrame)
            end
        end
    end)
  end
})
-- Đảm bảo Nhảy cao hoạt động sau khi hồi sinh
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(0.5)
    hum.UseJumpPower = true
    hum.JumpPower = jumpPowerValue
end)

local selectedPlayer = ""

-- Hàm lấy danh sách tên người chơi
local function getPlayerList()
    local players = {}
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Name ~= game.Players.LocalPlayer.Name then
            table.insert(players, v.Name)
        end
    end
    return players
end

-- Tạo Dropdown chọn người chơi
local Dropdown = Tab:AddDropdown({
    Name = "Chọn người chơi",
    Options = getPlayerList(),
    Default = "",
    Callback = function(Value)
        selectedPlayer = Value
    end
})

-- Nút làm mới danh sách (Refresh)
Tab:AddButton({
    Name = "Làm mới danh sách",
    Callback = function()
        Dropdown:Refresh(getPlayerList(), true)
    end
})
-- Danh sách tọa độ các đảo (Bạn có thể thêm tiếp vào đây)
local IslandPositions = {
    ["Haunted Castle"] = CFrame.new(-9515.372, 164.006, 5786.061),
    ["Sea of Treats"] = CFrame.new(-13242, 38, -7612),
    ["Floating Turtle"] = CFrame.new(-13246, 532, -7576),
    ["Castle on the Sea"] = CFrame.new(-5075, 314, -3151)
}

-- Biến lưu trữ Tween hiện tại để có thể dừng giữa chừng
local CurrentTween = nil
_G.Speed = 250
_G.Noclip = false
-- Hệ thống Noclip (Giữ nguyên để bay xuyên vật cản)
game:GetService("RunService").Stepped:Connect(function()
    if _G.Noclip and game.Players.LocalPlayer.Character then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)
-- Hàm Tween cải tiến
function To(TargetCFrame)
    local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    
    -- Nếu đang bay thì dừng cái cũ trước khi bay cái mới
    if CurrentTween then CurrentTween:Cancel() end

    local Distance = (Root.Position - TargetCFrame.Position).Magnitude
    local TweenTime = Distance / _G.Speed
    
    _G.Noclip = true
    CurrentTween = game:GetService("TweenService"):Create(Root, TweenInfo.new(TweenTime, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    CurrentTween:Play()
    
    CurrentTween.Completed:Connect(function()
        _G.Noclip = false
        CurrentTween = nil
    end)
end

Tab:AddDropdown({
  Name = "Chọn Đảo Để Bay",
  Options = {"Haunted Castle", "Sea of Treats", "Floating Turtle", "Castle on the Sea"},
  Default = "Haunted Castle",
  Callback = function(SelectedIsland)
    local TargetCF = IslandPositions[SelectedIsland]
    if TargetCF then
        print("Đang bay tới: " .. SelectedIsland)
        To(TargetCF)
    end
  end
})
Tab:AddButton({
  Name = "Dừng Bay (Stop Tween)",
  Callback = function()
    if CurrentTween then 
        CurrentTween:Cancel() 
        _G.Noclip = false
        print("Đã dừng bay!")
    end
  end
})
-- Nút thực hiện Kill
Tab:AddButton({
    Name = "Kill Người Chơi",
    Callback = function()
        if selectedPlayer ~= "" then
            local target = game.Players:FindFirstChild(selectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                -- Lưu ý: Trong Prison Life, việc kill trực tiếp 
                -- thường yêu cầu script phải có công cụ (Guns/Melee) 
                -- hoặc RemoteEvent của Game.
                target.Character.Humanoid.Health = 0
                print("Đã tiêu diệt: " .. selectedPlayer)
            end
        else
            print("Vui lòng chọn một người chơi trước!")
        end
    end
})
-- ================== INIT UI ==================
OrionLib:Init()
