local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

function Library.new(aimLib)
	local self = setmetatable({}, Library)
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "AimbotShooterVisuals"
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	self.Root = Instance.new("Frame")
	self.Root.Name = "Root"
	self.Root.Size = UDim2.new(0, 320, 0, 140)
	self.Root.Position = UDim2.new(0.02, 0, 0.02, 0)
	self.Root.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
	self.Root.BorderSizePixel = 0
	self.Root.Parent = self.Gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = self.Root

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1
	stroke.Transparency = 0.2
	stroke.Parent = self.Root

	self.Title = Instance.new("TextLabel")
	self.Title.Size = UDim2.new(1, -20, 0, 24)
	self.Title.Position = UDim2.new(0, 10, 0, 10)
	self.Title.Text = "Aimbot Shooter"
	self.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.Title.TextSize = 16
	self.Title.Font = Enum.Font.GothamBold
	self.Title.BackgroundTransparency = 1
	self.Title.TextXAlignment = Enum.TextXAlignment.Left
	self.Title.Parent = self.Root

	self.AimbotLabel = Instance.new("TextLabel")
	self.AimbotLabel.Size = UDim2.new(0.5, -12, 0, 46)
	self.AimbotLabel.Position = UDim2.new(0, 10, 0, 42)
	self.AimbotLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	self.AimbotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.AimbotLabel.TextSize = 13
	self.AimbotLabel.Font = Enum.Font.Gotham
	self.AimbotLabel.TextWrapped = true
	self.AimbotLabel.Text = "Aimbot\nOff"
	self.AimbotLabel.Parent = self.Root
	local aimbotCorner = Instance.new("UICorner")
	aimbotCorner.CornerRadius = UDim.new(0, 8)
	aimbotCorner.Parent = self.AimbotLabel

	self.SilentLabel = Instance.new("TextLabel")
	self.SilentLabel.Size = UDim2.new(0.5, -12, 0, 46)
	self.SilentLabel.Position = UDim2.new(0.5, 2, 0, 42)
	self.SilentLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	self.SilentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	self.SilentLabel.TextSize = 13
	self.SilentLabel.Font = Enum.Font.Gotham
	self.SilentLabel.TextWrapped = true
	self.SilentLabel.Text = "Silent Aim\nOff"
	self.SilentLabel.Parent = self.Root
	local silentCorner = Instance.new("UICorner")
	silentCorner.CornerRadius = UDim.new(0, 8)
	silentCorner.Parent = self.SilentLabel

	self.FOVVisuals = {
		Aimbot = {
			Fill = Drawing.new("Circle"),
			Rings = {},
		},
		SilentAim = {
			Fill = Drawing.new("Circle"),
			Rings = {},
		},
	}
	for i = 1, 4 do
		local ring = Drawing.new("Circle")
		ring.Visible = false
		ring.Filled = false
		ring.Thickness = 1
		ring.Transparency = 0.4
		table.insert(self.FOVVisuals.Aimbot.Rings, ring)
		local ring2 = Drawing.new("Circle")
		ring2.Visible = false
		ring2.Filled = false
		ring2.Thickness = 1
		ring2.Transparency = 0.4
		table.insert(self.FOVVisuals.SilentAim.Rings, ring2)
	end
	self._connection = RunService.RenderStepped:Connect(function(dt)
		if aimLib then
			self:Update(aimLib, dt)
		end
	end)

	return self
end

function Library:DrawFOV(modeName, modeConfig, position)
	local visuals = self.FOVVisuals[modeName]
	if not visuals then
		return
	end

	local fill = visuals.Fill
	fill.Visible = modeConfig.ShowFOV and self.Enabled
	fill.Color = modeConfig.FillColor or modeConfig.Color
	fill.Transparency = modeConfig.Transparency or 0.35
	fill.Radius = modeConfig.FOV
	fill.Position = position
	fill.Thickness = 0
	fill.Filled = modeConfig.Fill

	for index, ring in ipairs(visuals.Rings) do
		ring.Visible = modeConfig.ShowFOV and self.Enabled and modeConfig.Outline
		ring.Color = modeConfig.Color or Color3.fromRGB(255, 255, 255)
		ring.Transparency = modeConfig.Transparency or 0.35
		ring.Radius = modeConfig.FOV + (index * 3)
		ring.Position = position
		ring.Thickness = modeConfig.Thickness + index
	end
end

function Library:Update(aimLib, dt)
	if not aimLib then
		return
	end

	self.Enabled = aimLib.Config.Visuals.Enabled
	self.Root.Visible = self.Enabled

	if self.Enabled then
		local aimbotPosition = aimLib:GetFOVPosition(aimLib.Config.Aimbot)
		local silentPosition = aimLib:GetFOVPosition(aimLib.Config.SilentAim)
		self:DrawFOV("Aimbot", aimLib.Config.Aimbot, aimbotPosition)
		self:DrawFOV("SilentAim", aimLib.Config.SilentAim, silentPosition)
	end

	self.AimbotLabel.Text = string.format("Aimbot\n%s\nFOV: %s", aimLib.Config.Aimbot.Enabled and "On" or "Off", tostring(aimLib.Config.Aimbot.FOV))
	self.SilentLabel.Text = string.format("Silent Aim\n%s\nFOV: %s", aimLib.Config.SilentAim.Enabled and "On" or "Off", tostring(aimLib.Config.SilentAim.FOV))
end

function Library:Destroy()
	if self._connection then
		self._connection:Disconnect()
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

return Library
