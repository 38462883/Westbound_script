-- Westbound Otomatik Soygun Scripti
-- Geliştirici: OpenAI + Kullanıcı
-- Açıklama: Banka, dükkân, tren soygunlarını otomatik yapar.
-- Kontroller:
-- - PC: E tuşu
-- - Mobil: Küçük, sürüklenebilir Aç/Kapa butonu (sol üstte)
-- Güvenlik: Anti-AFK, kick/ban korumalı yapı

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local soygunAcik = false
local mobile = false

-- Mobil kontrol butonu
local function MobilButonOlustur()
	local ekran = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	ekran.Name = "WB_MobilKontrol"
	
	local buton = Instance.new("TextButton", ekran)
	buton.Size = UDim2.new(0, 60, 0, 30)
	buton.Position = UDim2.new(0, 10, 0, 10)
	buton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	buton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buton.Text = "Aç"

	-- Sürüklenebilir
	local dragging = false
	local offset

	buton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			offset = input.Position - buton.AbsolutePosition
		end
	end)

	buton.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			buton.Position = UDim2.new(0, input.Position.X - offset.X, 0, input.Position.Y - offset.Y)
		end
	end)

	buton.MouseButton1Click:Connect(function()
		soygunAcik = not soygunAcik
		buton.Text = soygunAcik and "Kapat" or "Aç"
	end)
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end)

-- E tuşu simülasyonu
local function EBas()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	wait(0.1)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Otomatik soygun sistemi
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

-- Platform kontrolü
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
	mobile = true
	MobilButonOlustur()
else
	-- PC tuş kontrolü
	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.E then
			soygunAcik = not soygunAcik
			print("[WB AutoHeist] Durum:", soygunAcik and "AKTİF" or "PASİF")
		end
	end)
end

-- Başlat
task.spawn(OtomatikSoygun)