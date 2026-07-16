local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local AimLib = {}
AimLib.__index = AimLib

local function getCamera()
	local camera = Workspace.CurrentCamera
	if camera then
		return camera
	end
	return nil
end

local function getMouse()
	if not LocalPlayer then
		return nil
	end
	local success, mouse = pcall(function()
		return LocalPlayer:GetMouse()
	end)
	if success and mouse then
		return mouse
	end
	return nil
end

local Visuals = {}
Visuals.__index = Visuals

function Visuals.new(aimLib)
	local self = setmetatable({}, Visuals)
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

function Visuals:DrawFOV(modeName, modeConfig, position)
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

function Visuals:Update(aimLib, dt)
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

function Visuals:Destroy()
	if self._connection then
		self._connection:Disconnect()
	end
	if self.Gui then
		self.Gui:Destroy()
	end
end

function AimLib.CreateDefaultConfig()
	return {
		FOV = 200,
		Aimbot = {
			Enabled = false,
			Key = Enum.UserInputType.MouseButton2,
			Players = true,
			PlayerPart = "Head",
			FriendlyPlayers = {},
			TeamCheck = false,
			AliveCheck = false,
			VisibilityCheck = false,
			Smoothing = 0,
			SmoothingMethod = 0,
			Offset = {0, 0},
			FOV = 200,
			ShowFOV = true,
			Fill = true,
			Outline = true,
			Thickness = 1,
			Transparency = 0.35,
			Color = Color3.fromRGB(255, 255, 255),
			FillColor = Color3.fromRGB(255, 0, 140),
			Rotation = 0,
			RotateSpeed = 0,
			RotationDirection = "Clockwise",
			PositionPart = "Mouse",
			PositionLerp = 0.25,
			ClosestPart = true,
			ClosestPosition = false,
			HitChance = 100,
			UseHitChance = true,
			CustomParts = {},
		},
		SilentAim = {
			Enabled = false,
			Key = Enum.UserInputType.MouseButton2,
			Players = true,
			PlayerPart = "Head",
			FriendlyPlayers = {},
			TeamCheck = false,
			AliveCheck = false,
			VisibilityCheck = false,
			FOV = 200,
			ShowFOV = true,
			Fill = true,
			Outline = true,
			Thickness = 1,
			Transparency = 0.35,
			Color = Color3.fromRGB(0, 255, 170),
			FillColor = Color3.fromRGB(0, 170, 255),
			Rotation = 0,
			RotateSpeed = 0,
			RotationDirection = "Counter Clockwise",
			PositionPart = "Mouse",
			PositionLerp = 0.25,
			ClosestPart = true,
			ClosestPosition = false,
			HitChance = 100,
			UseHitChance = true,
			Delay = 0,
			RandomDelay = false,
			DelayMin = 0,
			DelayMax = 0.05,
			MissBehavior = "None",
			Function = nil,
			CustomFunction = nil,
			CustomParts = {},
		},
		Visuals = {
			Enabled = true,
		},
	}
end

function AimLib.new(config)
	local self = setmetatable({}, AimLib)
	self.Config = AimLib.CreateDefaultConfig()
	self:SetConfig(config or {})
	self._keyPressed = {Aimbot = false, SilentAim = false}
	self._connections = {}
	self._pendingActions = {}
	self._visuals = nil
	self:_connectVisuals()
	self:_connectEvents()
	return self
end

function AimLib:SetConfig(newConfig)
	if type(newConfig) ~= "table" then
		return
	end

	if newConfig.Enabled ~= nil then
		self.Config.Aimbot.Enabled = newConfig.Enabled
	end
	if newConfig.SilentAim ~= nil then
		self.Config.SilentAim.Enabled = newConfig.SilentAim
	end
	if newConfig.FOV ~= nil then
		self.Config.Aimbot.FOV = newConfig.FOV
		self.Config.SilentAim.FOV = newConfig.FOV
	end
	if newConfig.ShowFOV ~= nil then
		self.Config.Aimbot.ShowFOV = newConfig.ShowFOV
		self.Config.SilentAim.ShowFOV = newConfig.ShowFOV
	end
	if newConfig.FOVFill ~= nil then
		self.Config.Aimbot.Fill = newConfig.FOVFill
		self.Config.SilentAim.Fill = newConfig.FOVFill
	end
	if newConfig.FOVOutline ~= nil then
		self.Config.Aimbot.Outline = newConfig.FOVOutline
		self.Config.SilentAim.Outline = newConfig.FOVOutline
	end
	if newConfig.FOVThickness ~= nil then
		self.Config.Aimbot.Thickness = newConfig.FOVThickness
		self.Config.SilentAim.Thickness = newConfig.FOVThickness
	end
	if newConfig.FOVTransparency ~= nil then
		self.Config.Aimbot.Transparency = newConfig.FOVTransparency
		self.Config.SilentAim.Transparency = newConfig.FOVTransparency
	end
	if newConfig.FOVColor ~= nil then
		self.Config.Aimbot.Color = newConfig.FOVColor
		self.Config.SilentAim.Color = newConfig.FOVColor
	end
	if newConfig.FOVFillColor ~= nil then
		self.Config.Aimbot.FillColor = newConfig.FOVFillColor
		self.Config.SilentAim.FillColor = newConfig.FOVFillColor
	end
	if newConfig.HitChance ~= nil then
		self.Config.Aimbot.HitChance = newConfig.HitChance
	end
	if newConfig.SilentAimHitChance ~= nil then
		self.Config.SilentAim.HitChance = newConfig.SilentAimHitChance
	end
	if newConfig.CustomParts ~= nil then
		self.Config.Aimbot.CustomParts = newConfig.CustomParts
		self.Config.SilentAim.CustomParts = newConfig.CustomParts
	end

	for key, value in pairs(newConfig) do
		if key == "Aimbot" and type(value) == "table" then
			for subKey, subValue in pairs(value) do
				self.Config.Aimbot[subKey] = subValue
			end
		elseif key == "SilentAim" and type(value) == "table" then
			for subKey, subValue in pairs(value) do
				self.Config.SilentAim[subKey] = subValue
			end
		elseif key == "Visuals" and type(value) == "table" then
			for subKey, subValue in pairs(value) do
				self.Config.Visuals[subKey] = subValue
			end
		elseif key ~= "Enabled" and key ~= "SilentAim" and key ~= "FOV" and key ~= "ShowFOV" and key ~= "FOVFill" and key ~= "FOVOutline" and key ~= "FOVThickness" and key ~= "FOVTransparency" and key ~= "FOVColor" and key ~= "FOVFillColor" and key ~= "HitChance" and key ~= "SilentAimHitChance" and key ~= "CustomParts" then
			self.Config[key] = value
		end
	end
end

function AimLib:BindLinoria(bindings)
	if type(bindings) ~= "table" then
		return
	end

	for _, info in pairs(bindings) do
		if type(info) == "table" and info.Target and type(info.Target.OnChanged) == "function" then
			info.Target:OnChanged(function()
				local value = info.Target.Value
				if info.Key then
					self.Config[info.Key] = value
				end
				if info.Callback then
					info.Callback(value)
				end
			end)
		end
	end
end

function AimLib:_connectVisuals()
	self._visuals = Visuals.new(self)
end

function AimLib:_connectEvents()
	self._connections.InputBegan = UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then
			return
		end

		if input.KeyCode == self.Config.Aimbot.Key or input.UserInputType == self.Config.Aimbot.Key then
			self._keyPressed.Aimbot = true
		end
		if input.KeyCode == self.Config.SilentAim.Key or input.UserInputType == self.Config.SilentAim.Key then
			self._keyPressed.SilentAim = true
		end
	end)

	self._connections.InputEnded = UserInputService.InputEnded:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then
			return
		end

		if input.KeyCode == self.Config.Aimbot.Key or input.UserInputType == self.Config.Aimbot.Key then
			self._keyPressed.Aimbot = false
		end
		if input.KeyCode == self.Config.SilentAim.Key or input.UserInputType == self.Config.SilentAim.Key then
			self._keyPressed.SilentAim = false
		end
	end)

	self._connections.RenderStepped = RunService.RenderStepped:Connect(function(dt)
		self:Update(dt)
	end)
end

function AimLib:GetFOVPosition(modeConfig)
	local camera = getCamera()
	local mouse = getMouse()
	if not camera or not mouse then
		return Vector2.new(0, 0)
	end

	if modeConfig.PositionPart == "Mouse" then
		return Vector2.new(mouse.X, mouse.Y)
	end

	local character = LocalPlayer.Character
	if not character then
		return Vector2.new(mouse.X, mouse.Y)
	end

	local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
	if not root then
		return Vector2.new(mouse.X, mouse.Y)
	end

	local success, position = pcall(function()
		return camera:WorldToScreenPoint(root.Position)
	end)
	if not success or not position then
		return Vector2.new(mouse.X, mouse.Y)
	end

	local targetPos = Vector2.new(position.X, position.Y)
	local currentPos = Vector2.new(mouse.X, mouse.Y)
	return currentPos:Lerp(targetPos, modeConfig.PositionLerp)
end

function AimLib:FindClosestTarget(modeConfig)
	local camera = getCamera()
	local mouse = getMouse()
	if not camera or not mouse then
		return nil
	end

	local parts = {}
	for _, part in ipairs(modeConfig.CustomParts or {}) do
		if part and (part:IsA("Part") or part:IsA("BasePart") or part:IsA("MeshPart")) then
			table.insert(parts, part)
		end
	end

	if modeConfig.Players then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and not table.find(modeConfig.FriendlyPlayers or {}, player.Name) then
				if modeConfig.AliveCheck and player.Character then
					local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
					if humanoid and humanoid.Health < 1 then
						continue
					end
				end
				if modeConfig.TeamCheck and player.TeamColor == LocalPlayer.TeamColor then
					continue
				end
				if player.Character and player.Character:FindFirstChild(modeConfig.PlayerPart) then
					local part = player.Character[modeConfig.PlayerPart]
					if modeConfig.VisibilityCheck then
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Blacklist
						params.IgnoreWater = true
						params.FilterDescendantsInstances = {part.Parent, LocalPlayer.Character}
						local raycast = Workspace:Raycast(camera.CFrame.Position, (part.Position - camera.CFrame.Position), params)
						if raycast then
							continue
						end
					end
					table.insert(parts, part)
				end
			end
		end
	end

	local target = nil
	local referencePoint = Vector2.new(mouse.X, mouse.Y)
	if modeConfig.ClosestPosition then
		referencePoint = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	end

	for _, part in ipairs(parts) do
		local success, screenPosition = pcall(function()
			return camera:WorldToScreenPoint(part.Position)
		end)
		if not success or not screenPosition then
			continue
		end
		if screenPosition.Z < 0 then
			continue
		end

		local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - referencePoint).Magnitude
		if distance > modeConfig.FOV then
			continue
		end

		if not target then
			target = {Part = part, Position = screenPosition, Distance = distance}
		elseif modeConfig.ClosestPart then
			if distance < target.Distance then
				target = {Part = part, Position = screenPosition, Distance = distance}
			end
		end
	end

	return target
end

function AimLib:AimTo(modeConfig, x, y)
	local mouse = getMouse()
	if not mouse then
		return
	end

	local deltaX = (x + modeConfig.Offset[1] - mouse.X)
	local deltaY = (y + modeConfig.Offset[2] - mouse.Y)
	if modeConfig.SmoothingMethod == 0 then
		deltaX = deltaX / (5 * (modeConfig.Smoothing + 1))
		deltaY = deltaY / (5 * (modeConfig.Smoothing + 1))
	else
		deltaX = deltaX / (modeConfig.Smoothing + 1)
		deltaY = deltaY / (modeConfig.Smoothing + 1)
	end
	pcall(function()
		mousemoverel(deltaX, deltaY)
	end)
end

function AimLib:ShouldFire(modeConfig)
	if not modeConfig.UseHitChance then
		return true
	end
	if modeConfig.HitChance >= 100 then
		return true
	end
	return math.random(1, 100) <= modeConfig.HitChance
end

function AimLib:GetDelay(modeConfig)
	if modeConfig.RandomDelay then
		local minDelay = math.max(0, modeConfig.DelayMin)
		local maxDelay = math.max(minDelay, modeConfig.DelayMax)
		return math.random() * (maxDelay - minDelay) + minDelay
	end
	return modeConfig.Delay or 0
end

function AimLib:QueueAction(modeName, target)
	local modeConfig = self.Config[modeName]
	if not modeConfig or not target then
		return false
	end

	local delay = self:GetDelay(modeConfig)
	self._pendingActions[modeName] = {
		Target = target,
		Time = os.clock() + delay,
	}
	return true
end

function AimLib:RunQueuedActions()
	local now = os.clock()
	for modeName, action in pairs(self._pendingActions) do
		if action and action.Time <= now then
			self._pendingActions[modeName] = nil
			self:ExecuteModeAction(modeName, action.Target)
		end
	end
end

function AimLib:ExecuteModeAction(modeName, target)
	local modeConfig = self.Config[modeName]
	if not modeConfig or not target then
		return false
	end

	if modeName == "Aimbot" and modeConfig.Enabled and self._keyPressed.Aimbot then
		if self:ShouldFire(modeConfig) then
			self:AimTo(modeConfig, target.Position.X, target.Position.Y)
		end
		return true
	end

	if modeName == "SilentAim" and modeConfig.Enabled and self._keyPressed.SilentAim then
		if not self:ShouldFire(modeConfig) then
			if modeConfig.MissBehavior == "Delay" then
				self:QueueAction("SilentAim", target)
			elseif modeConfig.MissBehavior == "Disconnect" then
				return false
			end
			return false
		end

		if modeConfig.Function then
			return modeConfig.Function(self, target)
		end
		if modeConfig.CustomFunction then
			return modeConfig.CustomFunction(self, target)
		end

		local mouse = getMouse()
		local screenPosition = target.Position
		if mouse then
			local deltaX = screenPosition.X + modeConfig.Offset[1] - mouse.X
			local deltaY = screenPosition.Y + modeConfig.Offset[2] - mouse.Y
			pcall(function()
				mousemoverel(deltaX, deltaY)
			end)
		end
		return true
	end

	return false
end

function AimLib:Update(dt)
	local camera = getCamera()
	if not camera then
		return
	end

	self:RunQueuedActions()

	if self._visuals and self.Config.Visuals.Enabled then
		self._visuals:Update(self, dt)
	end

	if self.Config.Aimbot.Enabled and self._keyPressed.Aimbot then
		local target = self:FindClosestTarget(self.Config.Aimbot)
		if target then
			self:ExecuteModeAction("Aimbot", target)
		end
	end

	if self.Config.SilentAim.Enabled and self._keyPressed.SilentAim then
		local target = self:FindClosestTarget(self.Config.SilentAim)
		if target then
			self:QueueAction("SilentAim", target)
		end
	end
end

function AimLib:Destroy()
	for _, connection in pairs(self._connections or {}) do
		if connection then
			connection:Disconnect()
		end
	end
	if self._visuals and type(self._visuals.Destroy) == "function" then
		self._visuals:Destroy()
	end
end

if type(getgenv) == "function" then
	getgenv().AimLib = AimLib
end

return AimLib
