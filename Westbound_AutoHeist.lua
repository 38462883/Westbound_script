local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local soygunAcik = false
local mobile = false

-- ✅ Mobil kontrol butonu (sağ üst köşe, taşınabilir)
local function MobilButonOlustur()
	local ekran = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	ekran.Name = "WB_MobilKontrol"
	ekran.ResetOnSpawn = false

	local buton = Instance.new("TextButton", ekran)
	buton.Size = UDim2.new(0, 60, 0, 30)
	buton.Position = UDim2.new(1, -70, 0, 10) -- Sağ üst köşe
	buton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	buton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buton.Text = "Aç"
	buton.Draggable = true
	buton.Active = true

	buton.MouseButton1Click:Connect(function()
		soygunAcik = not soygunAcik
		buton.Text = soygunAcik and "Kapat" or "Aç"
	end)
end

-- ✅ Anti-AFK sistemi
LocalPlayer.Idled:Connect(function()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

-- ✅ E tuşu simülasyonu (silah ateşi veya prompt etkileşimi)
local function EBas()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	wait(0.1)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ✅ Otomatik soygun sistemi
local function OtomatikSoygun()
	while true do
		task.wait(1)
		if soygunAcik then
			for _, nesne in pairs(workspace:GetDescendants()) do
				if nesne:IsA("ProximityPrompt") and nesne.MaxActivationDistance > 0 then
					pcall(function()
						fireproximityprompt(nesne)
					end)
				end
			end
			EBas()
		end
	end
end

-- ✅ Platform kontrolü: mobil ya da PC
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	mobile = true
	MobilButonOlustur()
else
	-- PC için E tuşu ile aktif/pasif yap
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.E then
			soygunAcik = not soygunAcik
			warn("[WB AutoHeist] Durum:", soygunAcik and "AKTİF" or "PASİF")
		end
	end)
end

-- ✅ Sistem başlatılıyor
task.spawn(OtomatikSoygun)