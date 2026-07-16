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

local function createLayer(parent, name, sizeOffset, thickness, color, gradientA, gradientB)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 10
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Name = "_stroke"
	stroke.Enabled = true
	stroke.Color = color or Color3.fromRGB(255, 255, 255)
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = frame

	local gradient = Instance.new("UIGradient")
	gradient.Name = "UIGradient"
	gradient.Enabled = true
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, gradientA or Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, gradientB or Color3.fromRGB(166, 193, 255)),
		ColorSequenceKeypoint.new(1, gradientA or Color3.fromRGB(0, 94, 255)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	gradient.Parent = stroke

	frame._sizeOffset = sizeOffset or 0
	return frame
end

local function createModeVisual(parent, baseColor)
	local layers = {
		createLayer(parent, "OuterLayer", 0, 1, baseColor, Color3.fromRGB(255, 255, 255), Color3.fromRGB(166, 193, 255)),
		createLayer(parent, "MiddleLayer", -18, 1.25, baseColor, Color3.fromRGB(255, 255, 255), Color3.fromRGB(123, 212, 255)),
		createLayer(parent, "AccentLayer", -36, 2.5, baseColor, Color3.fromRGB(197, 118, 188), Color3.fromRGB(111, 142, 255)),
		createLayer(parent, "OutlineLayer", -54, 3.25, baseColor, Color3.fromRGB(255, 255, 255), Color3.fromRGB(128, 221, 255)),
	}
	return layers
end

function Visuals.new(aimLib)
	local self = setmetatable({}, Visuals)
	self.Gui = Instance.new("ScreenGui")
	self.Gui.Name = "AimbotShooterVisuals"
	self.Gui.ResetOnSpawn = false
	self.Gui.IgnoreGuiInset = true
	self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

	self.FOVVisuals = {
		Aimbot = createModeVisual(self.Gui, Color3.fromRGB(255, 255, 255)),
		SilentAim = createModeVisual(self.Gui, Color3.fromRGB(255, 255, 255)),
	}

	self._connection = RunService.RenderStepped:Connect(function(dt)
		if aimLib then
			self:Update(aimLib, dt)
		end
	end)

	return self
end

function Visuals:DrawFOV(modeName, modeConfig, position)
	local layers = self.FOVVisuals[modeName]
	if not layers then
		return
	end

	local radius = modeConfig.FOV or 200
	for _, layer in ipairs(layers) do
		layer.Visible = modeConfig.ShowFOV and self.Enabled
		layer.Size = UDim2.new(0, math.max(0, radius * 2 + (layer._sizeOffset or 0)), 0, math.max(0, radius * 2 + (layer._sizeOffset or 0)))
		layer.Position = UDim2.new(0, position.X, 0, position.Y)
		layer.ZIndex = 10

		local stroke = layer:FindFirstChild("_stroke")
		if stroke then
			stroke.Color = modeConfig.Color or Color3.fromRGB(255, 255, 255)
			stroke.Thickness = math.max(1, (modeConfig.Thickness or 1) + (layer._sizeOffset < 0 and 0.5 or 0))
			stroke.Transparency = modeConfig.Transparency or 0.1
		end
	end
end

function Visuals:Update(aimLib, dt)
	if not aimLib then
		return
	end

	self.Enabled = aimLib.Config.Visuals.Enabled
	if self.Enabled then
		local aimbotPosition = aimLib:GetFOVPosition(aimLib.Config.Aimbot)
		local silentPosition = aimLib:GetFOVPosition(aimLib.Config.SilentAim)
		self:DrawFOV("Aimbot", aimLib.Config.Aimbot, aimbotPosition)
		self:DrawFOV("SilentAim", aimLib.Config.SilentAim, silentPosition)
	else
		for _, mode in pairs(self.FOVVisuals) do
			for _, layer in ipairs(mode) do
				layer.Visible = false
			end
		end
	end
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
