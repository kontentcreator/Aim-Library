local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Name = "FOVScreenGui"
FOVScreenGui.DisplayOrder = INSTANCE_GAMEPLAY_OVERLAY_ORDER
FOVScreenGui.ResetOnSpawn = false
FOVScreenGui.IgnoreGuiInset = true
FOVScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVScreenGui.Parent = game.CoreGui


local function BuildFOV(name, cfg)
    local Container = Instance.new("Frame")
    Container.Name                   = Name
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel        = 0
    Container.Visible                = false
    Container.Parent                 = FOVScreenGui

    local Fill = Instance.new("Frame")
    Fill.Size                   = UDim2.new(1, 0, 1, 0)
    Fill.BackgroundColor3       = Color3.new(1, 1, 1)
    Fill.BackgroundTransparency = cfg.FilledTransparency
    Fill.BorderSizePixel        = 0
    Fill.Visible                = false
    Fill.ZIndex                 = 1
    Fill.Parent                 = Container

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent       = Fill
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.FilledColor1),
        ColorSequenceKeypoint.new(1, cfg.FilledColor2),
    })
    FillGradient.Rotation = cfg.FilledRotation
    Fillgradient.Parent   = Fill

    local Outline = Instance.new("Frame")
    Outline.Size                   = UDim2.new(1, 0, 1, 0)
    Outline.BackgroundTransparency = 1
    Outline.BorderSizePixel        = 0
    Outline.ZIndex                 = 2
    Outline.Parent                 = container

    local OutlineCorner = Instance.new("UICorner")
    OutlineCorner.CornerRadius = UDim.new(1, 0)
    OutlineCorner.Parent       = outline

    local Stroke = Instance.new("UIStroke")
    Stroke.Color           = Color3.new(1, 1, 1)
    Stroke.Thickness       = cfg.OutlineThickness
    Stroke.Transparency    = cfg.OutlineTransparency
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent          = Outline

    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, cfg.OutlineColor1),
        ColorSequenceKeypoint.new(1, cfg.OutlineColor2),
    })
    StrokeGradient.Rotation = cfg.OutlineRotation
    StrokeGradient.Parent   = Stroke

    return {
        Container      = Container,
        Fill           = Fill,
        FillGradient   = Fillqradient,
        Stroke         = Stroke,
      SstrokeGradient = StrokeGradient,
    }
end

local SlientFOV  = BuildFOV("SilentFOV", silentFOVCfg)
local SilentFOVContainer  = SlientFOV.Container
local SilentFOVFill       = SlientFOV.Fill
local SilentFOVFillGradient   = SlientFOV.FillGradient
local SilentFOVStroke     = SlientFOV.Stroke
local SilentFOVStrokeGradient = SlientFOV.StrokeGradient

local function SilentLineGradient()
    silentFOVStrokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, silentFOVCfg.OutlineColor1),
        ColorSequenceKeypoint.new(1, silentFOVCfg.OutlineColor2),
    })
end
local function UpdSilentGradient()
    silentFOVFillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, silentFOVCfg.FilledColor1),
        ColorSequenceKeypoint.new(1, silentFOVCfg.FilledColor2),
    })
end


