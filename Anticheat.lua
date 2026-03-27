local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/vinh12eqweaws/zingmods/refs/heads/main/zingpro')))()

local Window = OrionLib:MakeWindow({Name = "Anti Cheat", HidePremium = false, SaveConfig = true, ConfigFolder = "dxl_bf"})

local Tab = Window:MakeTab({
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
Tab:AddButton({
	Name = "Quét Hacker",
	Callback = function()
		local Players = game:GetService("Players")
		local LocalPlayer = Players.LocalPlayer

		local lastPos = {}
		local flags = {}

		local TELEPORT_DIST = 90
		local NEED_FLAGS = 3
		local SCAN_DELAY = 0.2

		local function scanOnce()
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						flags[plr] = flags[plr] or 0
						if lastPos[plr] then
							local dist = (hrp.Position - lastPos[plr]).Magnitude
							if dist > TELEPORT_DIST then
								flags[plr] += 1
							end
						end
						lastPos[plr] = hrp.Position
					end
				end
			end
		end

		OrionLib:MakeNotification({
			Name = "Anti‑Cheat",
			Content = "Đang quét hành vi bất thường...",
			Time = 2
		})

		flags = {}

		scanOnce()
		task.wait(SCAN_DELAY)
		scanOnce()
		task.wait(SCAN_DELAY)
		scanOnce()

		local found = false
		for plr, count in pairs(flags) do
			if count >= NEED_FLAGS then
				found = true
				OrionLib:MakeNotification({
					Name = "⚠ NGHI NGỜ",
					Content = plr.Name .. " | Teleport bất thường (" .. count .. ")",
					Time = 5
				})
			end
		end

		if not found then
			OrionLib:MakeNotification({
				Name = "Anti‑Cheat",
				Content = "✅ Không phát hiện hành vi đáng ngờ.",
				Time = 4
			})
		end
	end
})
