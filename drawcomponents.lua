local DrawComponents = {}

local function create(className, properties)
	local instance = Instance.new(className)
	local parent = nil

	if properties then
		parent = properties.Parent
		for key, value in pairs(properties) do
			if key ~= "Parent" then
				instance[key] = value
			end
		end
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

local function setGradientColors(gradient, colors)
	local keypoints = {}
	for index, color in ipairs(colors) do
		keypoints[index] = ColorSequenceKeypoint.new((index - 1) / math.max(#colors - 1, 1), color)
	end
	gradient.Color = ColorSequence.new(keypoints)
end

function DrawComponents.newFOV(parent, options)
	local config = options or {}
	local radius = math.max(10, tonumber(config.Radius) or 180)
	local shell = create("Frame", {
		Name = "FOVCircle",
		Parent = parent,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(radius * 2, radius * 2),
		Visible = false,
		ClipsDescendants = false,
	})

	local fill = create("Frame", {
		Name = "Fill",
		BackgroundColor3 = config.FillColor or Color3.fromRGB(70, 183, 255),
		BackgroundTransparency = config.FillTransparency or 0.84,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	})
	create("UICorner", {
		Parent = fill,
		CornerRadius = UDim.new(1, 0),
	})
	fill.Parent = shell

	local outline = create("UIStroke", {
		Name = "Stroke",
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = config.Color or Color3.fromRGB(244, 248, 255),
		Thickness = config.Thickness or 2,
		Transparency = config.Transparency or 0.28,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
	outline.Parent = shell

	local gradient = create("UIGradient", {
		Name = "StrokeGradient",
		Rotation = config.Rotation or 0,
	})
	setGradientColors(gradient, {
		config.Color or Color3.fromRGB(244, 248, 255),
		config.AccentColor or Color3.fromRGB(92, 199, 255),
		config.SecondAccentColor or Color3.fromRGB(171, 102, 255),
	})
	gradient.Parent = outline

	local dot = create("Frame", {
		Name = "CenterDot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = config.DotColor or Color3.fromRGB(70, 235, 188),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(4, 4),
	})
	create("UICorner", {
		Parent = dot,
		CornerRadius = UDim.new(1, 0),
	})
	create("UIStroke", {
		Parent = dot,
		Color = config.DotOutlineColor or Color3.fromRGB(9, 12, 20),
		Thickness = 1,
		Transparency = 0.2,
	})
	dot.Parent = shell

	local component = {
		Root = shell,
	}

	function component:SetPosition(position)
		shell.Position = UDim2.fromOffset(math.floor(position.X + 0.5), math.floor(position.Y + 0.5))
	end

	function component:SetRadius(newRadius)
		local safeRadius = math.max(10, tonumber(newRadius) or radius)
		radius = safeRadius
		shell.Size = UDim2.fromOffset(safeRadius * 2, safeRadius * 2)
	end

	function component:SetVisible(visible)
		shell.Visible = not not visible
	end

	function component:SetFillVisible(visible)
		fill.Visible = not not visible
	end

	function component:SetFillColor(color)
		fill.BackgroundColor3 = color
	end

	function component:SetFillTransparency(transparency)
		fill.BackgroundTransparency = math.clamp(tonumber(transparency) or 0, 0, 1)
	end

	function component:SetOutlineVisible(visible)
		outline.Enabled = not not visible
	end

	function component:SetOutlineColor(color)
		outline.Color = color
	end

	function component:SetOutlineThickness(thickness)
		outline.Thickness = math.max(0, tonumber(thickness) or outline.Thickness)
	end

	function component:SetOutlineTransparency(transparency)
		outline.Transparency = math.clamp(tonumber(transparency) or 0, 0, 1)
	end

	function component:SetRotation(rotation)
		gradient.Rotation = tonumber(rotation) or 0
	end

	function component:SetStrokeColors(color1, color2, color3)
		setGradientColors(gradient, {
			color1 or outline.Color,
			color2 or color1 or outline.Color,
			color3 or color2 or outline.Color,
		})
	end

	function component:SetDotColor(color)
		dot.BackgroundColor3 = color
	end

	function component:Destroy()
		shell:Destroy()
	end

	return component
end

DrawComponents.CreateFOV = DrawComponents.newFOV
DrawComponents.createFOV = DrawComponents.newFOV

return DrawComponents
