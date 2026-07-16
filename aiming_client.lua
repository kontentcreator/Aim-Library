local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local AimLibrary = require(script.Parent:WaitForChild("drawlib"))

local controller = AimLibrary.new()
controller:Start(PlayerGui)

local theme = controller.config.Theme

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

local function addCorner(parent, radius)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 12),
	})
end

local function addStroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color or theme.Accent,
		Thickness = thickness or 1,
		Transparency = transparency or 0.9,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		LineJoinMode = Enum.LineJoinMode.Round,
	})
end

local function addGradient(parent, colors, rotation)
	local keypoints = {}
	for index, color in ipairs(colors) do
		keypoints[index] = ColorSequenceKeypoint.new((index - 1) / math.max(#colors - 1, 1), color)
	end

	return create("UIGradient", {
		Parent = parent,
		Rotation = rotation or 0,
		Color = ColorSequence.new(keypoints),
	})
end

local function bindHover(button, baseColor, hoverColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor,
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = baseColor,
		}):Play()
	end)
end

local function createPill(parent, text, accentColor)
	local pill = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.XY,
	})
	addCorner(pill, 999)
	addStroke(pill, accentColor or theme.Accent, 1, 0.82)

	create("UIPadding", {
		Parent = pill,
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
	})

	create("TextLabel", {
		Parent = pill,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = text,
		TextColor3 = theme.Text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	return pill
end

local function bindingToText(binding)
	if typeof(binding) ~= "EnumItem" then
		return "NONE"
	end

	if binding.EnumType == Enum.UserInputType then
		if binding == Enum.UserInputType.MouseButton1 then
			return "LMB"
		elseif binding == Enum.UserInputType.MouseButton2 then
			return "RMB"
		elseif binding == Enum.UserInputType.MouseButton3 then
			return "MMB"
		end
	end

	return binding.Name
end

local camera = Workspace.CurrentCamera
while not camera do
	task.wait()
	camera = Workspace.CurrentCamera
end

local viewport = camera.ViewportSize
local mainWidth = 860
local mainHeight = 520
local mainX = math.max(20, math.floor((viewport.X - mainWidth) * 0.5))
local mainY = math.max(20, math.floor((viewport.Y - mainHeight) * 0.5))

local rootGui = create("ScreenGui", {
	Name = "AimbotShooterUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	DisplayOrder = 100,
	Parent = PlayerGui,
})

local backdrop = create("Frame", {
	Parent = rootGui,
	BackgroundColor3 = theme.Background,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Visible = true,
})

addGradient(backdrop, {
	Color3.fromRGB(11, 15, 24),
	Color3.fromRGB(9, 12, 20),
	Color3.fromRGB(6, 8, 14),
}, 35)

local glowLeft = create("Frame", {
	Parent = backdrop,
	BackgroundColor3 = theme.Accent,
	BackgroundTransparency = 0.88,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(-120, -100),
	Size = UDim2.fromOffset(420, 420),
})
addCorner(glowLeft, 999)
addGradient(glowLeft, {
	theme.Accent,
	theme.Accent2,
	theme.Background,
}, 25)

local glowRight = create("Frame", {
	Parent = backdrop,
	BackgroundColor3 = theme.Accent2,
	BackgroundTransparency = 0.9,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, 140, 1, 100),
	Size = UDim2.fromOffset(500, 500),
})
addCorner(glowRight, 999)
addGradient(glowRight, {
	theme.Accent2,
	theme.Accent,
	theme.Background,
}, -30)

local glowBottom = create("Frame", {
	Parent = backdrop,
	BackgroundColor3 = theme.Accent3,
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, 120),
	Size = UDim2.fromOffset(560, 260),
})
addCorner(glowBottom, 999)
addGradient(glowBottom, {
	theme.Accent3,
	theme.Accent,
	theme.Background,
}, 0)

local shadow = create("Frame", {
	Parent = backdrop,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.6,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(mainX + 6, mainY + 8),
	Size = UDim2.fromOffset(mainWidth, mainHeight),
})
addCorner(shadow, 20)

local main = create("Frame", {
	Parent = backdrop,
	BackgroundColor3 = theme.Surface,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(mainX, mainY),
	Size = UDim2.fromOffset(mainWidth, mainHeight),
})
addCorner(main, 20)
addStroke(main, Color3.fromRGB(255, 255, 255), 1, 0.88)
addGradient(main, {
	theme.Surface,
	theme.SurfaceAlt,
}, 18)

local scale = create("UIScale", {
	Parent = main,
	Scale = 0.96,
})

local accentStrip = create("Frame", {
	Parent = main,
	BackgroundColor3 = theme.Accent,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 4),
})
addGradient(accentStrip, {
	theme.Accent,
	theme.Accent2,
	theme.Accent3,
}, 0)

local header = create("Frame", {
	Parent = main,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 4),
	Size = UDim2.new(1, 0, 0, 84),
	Active = true,
})

create("Frame", {
	Parent = header,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Position = UDim2.new(0, 0, 1, -1),
	Size = UDim2.new(1, 0, 0, 1),
})

create("UIPadding", {
	Parent = header,
	PaddingLeft = UDim.new(0, 18),
	PaddingRight = UDim.new(0, 18),
	PaddingTop = UDim.new(0, 14),
	PaddingBottom = UDim.new(0, 14),
})

local headerTitle = create("TextLabel", {
	Parent = header,
	BackgroundTransparency = 1,
	Size = UDim2.new(0, 420, 0, 30),
	Font = Enum.Font.GothamBlack,
	Text = '<font color="#66D4FF">AIMBOT</font> <font color="#F5F7FC">SHOOTER</font>',
	TextColor3 = theme.Text,
	TextSize = 22,
	RichText = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
})

local headerSubtitle = create("TextLabel", {
	Parent = header,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 30),
	Size = UDim2.new(0, 520, 0, 20),
	Font = Enum.Font.GothamMedium,
	Text = "Soft tracking, FOV gating, and a clean live control panel.",
	TextColor3 = theme.Subtle,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center,
})

local headerPills = create("Frame", {
	Parent = header,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(260, 84),
})

local headerPillLayout = create("UIListLayout", {
	Parent = headerPills,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local livePill = createPill(headerPills, "IDLE", theme.Accent3)
local bindPill = createPill(headerPills, "RMB", theme.Accent)
local uiPill = createPill(headerPills, "RIGHTSHIFT", theme.Accent2)

local closeButton = create("TextButton", {
	Parent = header,
	AnchorPoint = Vector2.new(1, 0),
	BackgroundColor3 = theme.SurfaceAlt,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(mainWidth - 18, 14),
	Size = UDim2.fromOffset(34, 34),
	AutoButtonColor = false,
	Text = "X",
	Font = Enum.Font.GothamBold,
	TextColor3 = theme.Text,
	TextSize = 15,
})
addCorner(closeButton, 10)
addStroke(closeButton, theme.Accent2, 1, 0.84)
bindHover(closeButton, theme.SurfaceAlt, Color3.fromRGB(34, 41, 62))

local body = create("Frame", {
	Parent = main,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(0, 88),
	Size = UDim2.new(1, 0, 1, -88),
})

local sidebar = create("Frame", {
	Parent = body,
	BackgroundColor3 = Color3.fromRGB(13, 18, 29),
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0,
	Size = UDim2.new(0, 190, 1, 0),
})
addGradient(sidebar, {
	Color3.fromRGB(13, 18, 29),
	Color3.fromRGB(11, 15, 24),
}, 90)

create("Frame", {
	Parent = sidebar,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
	Position = UDim2.new(1, 0, 0, 0),
	Size = UDim2.fromOffset(1, 1),
})

create("UIPadding", {
	Parent = sidebar,
	PaddingLeft = UDim.new(0, 14),
	PaddingRight = UDim.new(0, 14),
	PaddingTop = UDim.new(0, 14),
	PaddingBottom = UDim.new(0, 14),
})

local sidebarLayout = create("UIListLayout", {
	Parent = sidebar,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 12),
})

local sidebarHeader = create("Frame", {
	Parent = sidebar,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 64),
})

create("TextLabel", {
	Parent = sidebarHeader,
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 26),
	Font = Enum.Font.GothamBlack,
	Text = "CONTROL",
	TextColor3 = theme.Text,
	TextSize = 18,
	TextXAlignment = Enum.TextXAlignment.Left,
})

create("TextLabel", {
	Parent = sidebarHeader,
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 26),
	Size = UDim2.new(1, 0, 0, 18),
	Font = Enum.Font.GothamMedium,
	Text = "Aim tuning with a sharp visual hierarchy.",
	TextColor3 = theme.Subtle,
	TextSize = 12,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextWrapped = true,
})

local tabsContainer = create("Frame", {
	Parent = sidebar,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.new(1, 0, 0, 170),
})

local tabsLayout = create("UIListLayout", {
	Parent = tabsContainer,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 10),
})

local tabButtons = {}
local pages = {}
local activeTab = nil

local function createTabButton(title, subtitle)
	local button = create("TextButton", {
		Parent = tabsContainer,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 48),
		AutoButtonColor = false,
		Text = "",
	})
	addCorner(button, 14)
	addStroke(button, Color3.fromRGB(255, 255, 255), 1, 0.92)

	local indicator = create("Frame", {
		Parent = button,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(10, 14),
		Size = UDim2.fromOffset(3, 20),
	})
	addCorner(indicator, 999)

	create("TextLabel", {
		Parent = button,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 6),
		Size = UDim2.new(1, -34, 0, 18),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = button,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(22, 24),
		Size = UDim2.new(1, -34, 0, 14),
		Font = Enum.Font.GothamMedium,
		Text = subtitle,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	return button, indicator
end

local function createPage(name)
	local page = create("ScrollingFrame", {
		Parent = body,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(190, 0),
		Size = UDim2.new(1, -190, 1, 0),
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent,
		Visible = false,
		AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
	})

	create("UIPadding", {
		Parent = page,
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
		PaddingTop = UDim.new(0, 16),
		PaddingBottom = UDim.new(0, 16),
	})

	create("UIListLayout", {
		Parent = page,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 14),
	})

	pages[name] = page
	return page
end

local function createCard(parent, title, description)
	local card = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	addCorner(card, 16)
	addStroke(card, Color3.fromRGB(255, 255, 255), 1, 0.9)

	local content = create("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})

	create("UIPadding", {
		Parent = content,
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
	})

	create("UIListLayout", {
		Parent = content,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
	})

	local titleRow = create("Frame", {
		Parent = content,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})

	create("TextLabel", {
		Parent = titleRow,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = titleRow,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, 22),
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.GothamMedium,
		Text = description,
		TextColor3 = theme.Subtle,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local bodyFrame = create("Frame", {
		Parent = content,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})

	create("UIListLayout", {
		Parent = bodyFrame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
	})

	return card, bodyFrame
end

local function makeToggle(parent, title, description, defaultValue, callback)
	local state = not not defaultValue

	local row = create("TextButton", {
		Parent = parent,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 54),
		AutoButtonColor = false,
		Text = "",
	})
	addCorner(row, 14)
	addStroke(row, Color3.fromRGB(255, 255, 255), 1, 0.92)
	bindHover(row, theme.Surface, Color3.fromRGB(24, 31, 48))

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -120, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -120, 0, 16),
		Font = Enum.Font.GothamMedium,
		Text = description,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local switch = create("Frame", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(74, 28),
	})
	addCorner(switch, 999)

	local knob = create("Frame", {
		Parent = switch,
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(40, 4),
		Size = UDim2.fromOffset(20, 20),
	})
	addCorner(knob, 999)

	local statusLabel = create("TextLabel", {
		Parent = switch,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "ON",
		TextColor3 = theme.Background,
		TextSize = 11,
	})

	local function refresh()
		TweenService:Create(switch, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = state and theme.Accent or Color3.fromRGB(33, 39, 57),
		}):Play()

		TweenService:Create(knob, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = state and UDim2.fromOffset(48, 4) or UDim2.fromOffset(4, 4),
		}):Play()

		statusLabel.Text = state and "ON" or "OFF"
		statusLabel.TextColor3 = state and theme.Background or theme.Subtle
	end

	row.Activated:Connect(function()
		state = not state
		refresh()
		if callback then
			callback(state)
		end
	end)

	refresh()

	return {
		Set = function(value)
			state = not not value
			refresh()
		end,
		Get = function()
			return state
		end,
	}
end

local function makeSlider(parent, title, description, minValue, maxValue, defaultValue, formatValue, callback)
	local value = math.clamp(defaultValue, minValue, maxValue)

	local row = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 76),
	})
	addCorner(row, 14)
	addStroke(row, Color3.fromRGB(255, 255, 255), 1, 0.92)

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -120, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -120, 0, 16),
		Font = Enum.Font.GothamMedium,
		Text = description,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local valueLabel = create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 10),
		Size = UDim2.fromOffset(90, 16),
		Font = Enum.Font.GothamSemibold,
		Text = "",
		TextColor3 = theme.Accent,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	local track = create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = Color3.fromRGB(27, 34, 50),
		BorderSizePixel = 0,
		Position = UDim2.new(0, 14, 1, -14),
		Size = UDim2.new(1, -28, 0, 12),
		AutoButtonColor = false,
		Text = "",
	})
	addCorner(track, 999)

	local fill = create("Frame", {
		Parent = track,
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	})
	addCorner(fill, 999)

	local knob = create("Frame", {
		Parent = track,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = theme.Text,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
	})
	addCorner(knob, 999)
	addStroke(knob, theme.Background, 1, 0.2)

	local dragging = false

	local function updateVisual()
		local alpha = (value - minValue) / math.max(maxValue - minValue, 1)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = formatValue and formatValue(value) or tostring(math.floor(value + 0.5))
	end

	local function setFromX(screenX)
		local trackX = track.AbsolutePosition.X
		local trackWidth = track.AbsoluteSize.X
		local alpha = math.clamp((screenX - trackX) / math.max(trackWidth, 1), 0, 1)
		value = minValue + ((maxValue - minValue) * alpha)
		updateVisual()
		if callback then
			callback(value)
		end
	end

	track.Activated:Connect(function()
		setFromX(UserInputService:GetMouseLocation().X)
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	updateVisual()

	return {
		Set = function(newValue)
			value = math.clamp(newValue, minValue, maxValue)
			updateVisual()
		end,
		Get = function()
			return value
		end,
	}
end

local function makeSegmented(parent, title, description, options, defaultValue, callback)
	local selected = defaultValue

	local card = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	addCorner(card, 14)
	addStroke(card, Color3.fromRGB(255, 255, 255), 1, 0.92)

	create("UIPadding", {
		Parent = card,
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 14),
	})

	create("UIListLayout", {
		Parent = card,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})

	create("TextLabel", {
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.GothamMedium,
		Text = description,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local optionsFrame = create("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})

	create("UIListLayout", {
		Parent = optionsFrame,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})

	local buttons = {}

	local function refresh()
		for valueName, button in pairs(buttons) do
			local active = valueName == selected
			TweenService:Create(button, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = active and theme.Accent or theme.SurfaceAlt,
			}):Play()
			button.TextColor3 = active and theme.Background or theme.Text
		end
	end

	for _, option in ipairs(options) do
		local button = create("TextButton", {
			Parent = optionsFrame,
			BackgroundColor3 = theme.SurfaceAlt,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, 34),
			AutoButtonColor = false,
			Text = option.label,
			Font = Enum.Font.GothamSemibold,
			TextColor3 = theme.Text,
			TextSize = 12,
		})
		addCorner(button, 12)
		addStroke(button, Color3.fromRGB(255, 255, 255), 1, 0.94)
		create("UIPadding", {
			Parent = button,
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}) 

		button.Activated:Connect(function()
			selected = option.value
			refresh()
			if callback then
				callback(option.value)
			end
		end)

		buttons[option.value] = button
	end

	refresh()

	return {
		Set = function(newValue)
			selected = newValue
			refresh()
		end,
		Get = function()
			return selected
		end,
	}
end

local function makeKeybind(parent, title, description, defaultBinding, callback)
	local binding = defaultBinding
	local capturing = false

	local row = create("TextButton", {
		Parent = parent,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 56),
		AutoButtonColor = false,
		Text = "",
	})
	addCorner(row, 14)
	addStroke(row, Color3.fromRGB(255, 255, 255), 1, 0.92)
	bindHover(row, theme.Surface, Color3.fromRGB(24, 31, 48))

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 8),
		Size = UDim2.new(1, -140, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 26),
		Size = UDim2.new(1, -140, 0, 16),
		Font = Enum.Font.GothamMedium,
		Text = description,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local button = create("TextButton", {
		Parent = row,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(96, 30),
		AutoButtonColor = false,
		Text = "",
	})
	addCorner(button, 12)
	addStroke(button, theme.Accent, 1, 0.82)

	local label = create("TextLabel", {
		Parent = button,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		Text = "RMB",
		TextColor3 = theme.Text,
		TextSize = 12,
	})

	local function updateLabel()
		label.Text = capturing and "PRESS..." or bindingToText(binding)
	end

	button.Activated:Connect(function()
		capturing = true
		updateLabel()
	end)

	local captureConnection
	captureConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not capturing then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			binding = input.KeyCode
		elseif input.UserInputType ~= Enum.UserInputType.None then
			binding = input.UserInputType
		else
			return
		end

		capturing = false
		updateLabel()
		if callback then
			callback(binding)
		end
	end)

	updateLabel()

	return {
		Set = function(newBinding)
			binding = newBinding
			capturing = false
			updateLabel()
		end,
		Get = function()
			return binding
		end,
		Destroy = function()
			if captureConnection then
				captureConnection:Disconnect()
				captureConnection = nil
			end
		end,
	}
end

local function makeInfoCard(parent, title, subtitle)
	local card = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.SurfaceAlt,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})
	addCorner(card, 16)
	addStroke(card, Color3.fromRGB(255, 255, 255), 1, 0.92)

	create("UIPadding", {
		Parent = card,
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 14),
	})

	create("UIListLayout", {
		Parent = card,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})

	create("TextLabel", {
		Parent = card,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		Font = Enum.Font.GothamSemibold,
		Text = title,
		TextColor3 = theme.Text,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	if subtitle and subtitle ~= "" then
		create("TextLabel", {
			Parent = card,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = Enum.Font.GothamMedium,
			Text = subtitle,
			TextColor3 = theme.Subtle,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
	end

	local infoRow = create("Frame", {
		Parent = card,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
	})

	create("UIListLayout", {
		Parent = infoRow,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	})

	return card, infoRow
end

local function addInfoLine(parent, label, value, accentColor)
	local row = create("Frame", {
		Parent = parent,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
	})
	addCorner(row, 10)

	create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(0.46, 0, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = label,
		TextColor3 = theme.Subtle,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	local valueLabel = create("TextLabel", {
		Parent = row,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Font = Enum.Font.GothamSemibold,
		Text = value,
		TextColor3 = accentColor or theme.Text,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	return valueLabel
end

local aimPage = createPage("Aim")
local targetPage = createPage("Target")
local fovPage = createPage("FOV")

local aimButton, aimIndicator = createTabButton("Aim", "tracking")
local targetButton, targetIndicator = createTabButton("Target", "filters")
local fovButton, fovIndicator = createTabButton("FOV", "circle")

tabButtons.Aim = {
	Button = aimButton,
	Indicator = aimIndicator,
}
tabButtons.Target = {
	Button = targetButton,
	Indicator = targetIndicator,
}
tabButtons.FOV = {
	Button = fovButton,
	Indicator = fovIndicator,
}

local function setTabState(tabName)
	activeTab = tabName
	for name, record in pairs(tabButtons) do
		local active = name == tabName
		TweenService:Create(record.Button, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = active and theme.SurfaceAlt or theme.Surface,
		}):Play()

		TweenService:Create(record.Indicator, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = active and 0 or 1,
		}):Play()

		record.Button.TextColor3 = active and theme.Text or theme.Subtle
	end

	for name, page in pairs(pages) do
		page.Visible = name == tabName
	end
end

aimButton.Activated:Connect(function()
	setTabState("Aim")
end)

targetButton.Activated:Connect(function()
	setTabState("Target")
end)

fovButton.Activated:Connect(function()
	setTabState("FOV")
end)

setTabState("Aim")

local aimCard, aimBody = createCard(aimPage, "Aim Core", "Primary tracking behavior and input binding.")
local targetCard, targetBody = createCard(targetPage, "Target Filter", "Who the system may lock onto.")
local fovCard, fovBody = createCard(fovPage, "FOV Ring", "Tune the circle that gates target selection.")

local aimEnabledToggle = makeToggle(aimBody, "Enabled", "Master switch for the aim controller.", controller.config.Enabled, function(value)
	controller:SetEnabled(value)
end)

local aimModeToggle = makeToggle(aimBody, "Toggle Mode", "Hold to track or toggle it on with the bind.", controller.config.ToggleMode, function(value)
	controller:SetToggleMode(value)
end)

local keybindControl = makeKeybind(aimBody, "Activation Key", "Set the aim bind used for hold or toggle mode.", controller.config.ActivationKey, function(binding)
	controller:SetActivationKey(binding)
	local status = controller:GetStatus()
	bindPill.Text = status.Binding
end)

local lockSpeedSlider = makeSlider(aimBody, "Lock Speed", "Higher values pull the camera faster toward a target.", 1, 100, controller.config.LockSpeed, function(value)
	return string.format("%d%%", math.floor(value + 0.5))
end, function(value)
	controller:SetLockSpeed(value)
end)

local predictionSlider = makeSlider(aimBody, "Prediction", "Lead moving targets by a few frames.", 0, 0.25, controller.config.Prediction, function(value)
	return string.format("%.2fs", value)
end, function(value)
	controller:SetPrediction(value)
end)

local aimPartGroup = makeSegmented(aimBody, "Aim Part", "Pick a fixed part or let the library choose the closest one.", {
	{ label = "Closest", value = "Closest" },
	{ label = "Head", value = "Head" },
	{ label = "UpperTorso", value = "UpperTorso" },
	{ label = "HumanoidRootPart", value = "HumanoidRootPart" },
	{ label = "Torso", value = "Torso" },
}, controller.config.UseClosestPart and "Closest" or controller.config.AimPart, function(value)
	if value == "Closest" then
		controller:SetUseClosestPart(true)
	else
		controller:SetUseClosestPart(false)
		controller:SetAimPart(value)
	end
end)

local teamToggle = makeToggle(targetBody, "Team Check", "Skip players on your own team.", controller.config.TeamCheck, function(value)
	controller:SetTeamCheck(value)
end)

local aliveToggle = makeToggle(targetBody, "Alive Check", "Only consider living characters.", controller.config.AliveCheck, function(value)
	controller:SetAliveCheck(value)
end)

local visibilityToggle = makeToggle(targetBody, "Visibility Check", "Require a clear line of sight to the target.", controller.config.VisibilityCheck, function(value)
	controller:SetVisibilityCheck(value)
end)

local friendToggle = makeToggle(targetBody, "Ignore Friends", "Leave your friends out of target selection.", controller.config.IgnoreFriends, function(value)
	controller:SetIgnoreFriends(value)
end)

local maxDistanceSlider = makeSlider(targetBody, "Max Distance", "Targets beyond this range are ignored.", 100, 4000, controller.config.MaxDistance, function(value)
	return string.format("%d studs", math.floor(value + 0.5))
end, function(value)
	controller:SetMaxDistance(value)
end)

local fovVisibleToggle = makeToggle(fovBody, "Show FOV", "Draw the circle overlay on screen.", controller.config.FOV.Visible, function(value)
	controller:SetFOVVisible(value)
end)

local fovFillToggle = makeToggle(fovBody, "Fill Circle", "Add a soft translucent fill under the ring.", controller.config.FOV.Fill, function(value)
	controller:SetFOVFill(value)
end)

local fovOutlineToggle = makeToggle(fovBody, "Outline", "Keep the ring stroke sharp and readable.", controller.config.FOV.Outline, function(value)
	controller:SetFOVOutline(value)
end)

local fovRadiusSlider = makeSlider(fovBody, "Radius", "The search boundary for target selection.", 60, 320, controller.config.FOV.Radius, function(value)
	return string.format("%d px", math.floor(value + 0.5))
end, function(value)
	controller:SetFOVRadius(value)
end)

local anchorControl = makeSegmented(fovBody, "Anchor", "Track the cursor or the center of the screen.", {
	{ label = "Mouse", value = "Mouse" },
	{ label = "Center", value = "Center" },
}, controller.config.FOV.Anchor, function(value)
	controller:SetFOVAnchor(value)
end)

local rotationSlider = makeSlider(fovBody, "Rotation", "Subtle motion keeps the ring feeling alive.", 0, 60, controller.config.FOV.RotationSpeed, function(value)
	return string.format("%.0f deg/s", value)
end, function(value)
	controller:SetFOVRotationSpeed(value)
end)

local sidebarInfoCard, sidebarInfoBody = makeInfoCard(sidebar, "Live Readout")
local liveTargetLabel = addInfoLine(sidebarInfoBody, "Target", "None", theme.Text)
local livePartLabel = addInfoLine(sidebarInfoBody, "Part", "Head", theme.Accent)
local liveModeLabel = addInfoLine(sidebarInfoBody, "Mode", "Hold", theme.Accent2)
local liveBindingLabel = addInfoLine(sidebarInfoBody, "Bind", "RMB", theme.Accent3)

local panelVisible = true
local panelTween

local function setPanelVisible(visible)
	if panelVisible == visible then
		return
	end

	panelVisible = visible

	if panelTween then
		panelTween:Cancel()
		panelTween = nil
	end

	if visible then
		backdrop.Visible = true
		main.Visible = true
		scale.Scale = 0.96
		panelTween = TweenService:Create(scale, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Scale = 1,
		})
		panelTween:Play()
	else
		panelTween = TweenService:Create(scale, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Scale = 0.96,
		})
		panelTween:Play()
		panelTween.Completed:Once(function()
			if not panelVisible then
				backdrop.Visible = false
				main.Visible = false
			end
		end)
	end
end

closeButton.Activated:Connect(function()
	setPanelVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		setPanelVisible(not panelVisible)
	end
end)

local dragActive = false
local dragStart = Vector2.new()
local startPosition = Vector2.new(main.Position.X.Offset, main.Position.Y.Offset)

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragActive = true
		dragStart = input.Position
		startPosition = Vector2.new(main.Position.X.Offset, main.Position.Y.Offset)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragActive then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.fromOffset(startPosition.X + delta.X, startPosition.Y + delta.Y)
		shadow.Position = UDim2.fromOffset(startPosition.X + delta.X + 6, startPosition.Y + delta.Y + 8)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragActive = false
	end
end)

local gradientClock = 0
local function updateStatus()
	local status = controller:GetStatus()
	liveTargetLabel.Text = status.TargetName
	livePartLabel.Text = status.TargetPart
	liveModeLabel.Text = status.Active and (status.Mode .. " / LIVE") or status.Mode
	liveBindingLabel.Text = status.Binding
	bindPill.Text = status.Binding
	livePill.Text = status.Active and "LIVE" or "IDLE"
	livePill.BackgroundColor3 = status.Active and theme.Accent3 or theme.SurfaceAlt
end

updateStatus()

RunService.RenderStepped:Connect(function(dt)
	gradientClock = (gradientClock + (dt * 18)) % 360
	accentStrip.Rotation = gradientClock
	glowLeft.Rotation = (gradientClock * 0.45) % 360
	glowRight.Rotation = (-gradientClock * 0.5) % 360
	glowBottom.Rotation = (gradientClock * 0.28) % 360

	if panelVisible then
		updateStatus()
	end
end)

task.defer(function()
	TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end)
