local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Name = "FOVScreenGui"
FOVScreenGui.DisplayOrder = INSTANCE_GAMEPLAY_OVERLAY_ORDER
FOVScreenGui.ResetOnSpawn = false
FOVScreenGui.IgnoreGuiInset = true
FOVScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVScreenGui.Parent = game.CoreGui

local function BuildFOV(name, Config)
    local Container = Instance.new("Frame")
    Container.Name                   = Name
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel        = 0
    Container.Visible                = false
    Container.Parent                 = FOVScreenGui

    local Fill = Instance.new("Frame")
    Fill.Size                   = UDim2.new(1, 0, 1, 0)
    Fill.BackgroundColor3       = Color3.new(1, 1, 1)
    Fill.BackgroundTransparency = Config.FilledTransparency
    Fill.BorderSizePixel        = 0
    Fill.Visible                = false
    Fill.ZIndex                 = 1
    Fill.Parent                 = Container

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent       = Fill
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.FilledColor1),
        ColorSequenceKeypoint.new(1, Config.FilledColor2),
    })
    FillGradient.Rotation = Config.FilledRotation
    Fillgradient.Parent   = Fill

    local Outline = Instance.new("Frame")
    Outline.Size                   = UDim2.new(1, 0, 1, 0)
    Outline.BackgroundTransparency = 1
    Outline.BorderSizePixel        = 0
    Outline.ZIndex                 = 2
    Outline.Parent                 = Container

    local OutlineCorner = Instance.new("UICorner")
    OutlineCorner.CornerRadius = UDim.new(1, 0)
    OutlineCorner.Parent       = Outline

    local Stroke = Instance.new("UIStroke")
    Stroke.Color           = Color3.new(1, 1, 1)
    Stroke.Thickness       = Config.OutlineThickness
    Stroke.Transparency    = Config.OutlineTransparency
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent          = Outline

    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.OutlineColor1),
        ColorSequenceKeypoint.new(1, Config.OutlineColor2),
    })
    StrokeGradient.Rotation = Config.OutlineRotation
    StrokeGradient.Parent   = Stroke

    return {
        Container      = Container,
        Fill           = Fill,
        FillGradient   = FillGradient,
        Stroke         = Stroke,
      SstrokeGradient = StrokeGradient,
    }
end

local SlientFOV  = BuildFOV("SilentFOV", silentFOVConfig)
local SilentFOVContainer  = SlientFOV.Container
local SilentFOVFill       = SlientFOV.Fill
local SilentFOVFillGradient   = SlientFOV.FillGradient
local SilentFOVStroke     = SlientFOV.Stroke
local SilentFOVStrokeGradient = SlientFOV.StrokeGradient

local function SilentLineGradient()
    silentFOVStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SilentFOVConfig.OutlineColor1),
        ColorSequenceKeypoint.new(1, SilentFOVConfig.OutlineColor2),
    })
end
local function UpdSilentGradient()
    silentFOVFillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, SilentFOVConfig.FilledColor1),
        ColorSequenceKeypoint.new(1, SilentFOVConfig.FilledColor2),
    })
end

local AimbotFOVConfig = {
    OutlineColor1       = Color3.fromRGB(255, 255, 255),
    OutlineColor2       = Color3.fromRGB(255, 255, 255),
    OutlineRotation     = 0,
    OutlineThickness    = 1.5,
    OutlineTransparency = 0,
    FilledEnabled       = false,
    FilledColor1        = Color3.fromRGB(255, 255, 255),
    FilledColor2        = Color3.fromRGB(0, 0, 0),
    FilledRotation      = 0,
    FilledTransparency  = 0.7,
    FilledAnimated      = false,
    FilledSpeed         = 1,
    SpinOn              = false,
    SpinSpeed           = 1,
}

local AimbotFOV                = buildfov("AimbotFOV", AimbotFOVConfig)
local AimbotFOVContainer  = AimbotFOV.Container
local AimbotFOVFill       = AimbotFOV.Fill
local AimbotFOVFillGrad   = AimbotFOV.FillGradient
local AimbotFOVStroke     = AimbotFOV.Stroke
local AimbotFOVStrokeGrad = AimbotFOV.StrokeGradient

local function UpdAimbotOutlineGradient()
    aimbotFOVStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, aimbotFOVConfig.OutlineColor1),
        ColorSequenceKeypoint.new(1, aimbotFOVConfig.OutlineColor2),
    })
end
local function UpdAimbotFillGradient()
    aimbotFOVFillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, aimbotFOVConfig.FilledColor1),
        ColorSequenceKeypoint.new(1, aimbotFOVConfig.FilledColor2),
    })
end

