-- creation

local FOVScreenGui = Instance.new("ScreenGui")
FOVScreenGui.Name = "FOVScreenGui"
FOVScreenGui.DisplayOrder = 15
FOVScreenGui.ResetOnSpawn = false
FOVScreenGui.IgnoreGuiInset = true
FOVScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FOVScreenGui.Parent = game.CoreGui

local function BuildFOV(Name, Config)
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
      StrokeGradient = StrokeGradient,
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

-- core

local function HitPartFromName(target, partName)
    local fc = function(n) return target:FindFirstChild(n) end
    if     partName == "Head"             then return fc("Head")
    elseif partName == "HumanoidRootPart" then return fc("HumanoidRootPart")
    elseif partName == "Torso"            then return fc("Torso") or fc("UpperTorso")
    elseif partName == "UpperTorso"       then return fc("UpperTorso")
    elseif partName == "LowerTorso"       then return fc("LowerTorso")
    elseif partName == "Left Arm"         then return fc("Left Arm") or fc("LeftUpperArm")
    elseif partName == "LeftHand"         then return fc("LeftHand") or fc("Left Arm")
    elseif partName == "LeftLowerArm"     then return fc("LeftLowerArm")
    elseif partName == "LeftUpperArm"     then return fc("LeftUpperArm")
    elseif partName == "Right Arm"        then return fc("Right Arm") or fc("RightUpperArm")
    elseif partName == "RightHand"        then return fc("RightHand") or fc("Right Arm")
    elseif partName == "RightLowerArm"    then return fc("RightLowerArm")
    elseif partName == "RightUpperArm"    then return fc("RightUpperArm")
    elseif partName == "Left Leg"         then return fc("Left Leg") or fc("LeftUpperLeg")
    elseif partName == "LeftFoot"         then return fc("LeftFoot") or fc("Left Leg")
    elseif partName == "LeftLowerLeg"     then return fc("LeftLowerLeg")
    elseif partName == "LeftUpperLeg"     then return fc("LeftUpperLeg")
    elseif partName == "Right Leg"        then return fc("Right Leg") or fc("RightUpperLeg")
    elseif partName == "RightFoot"        then return fc("RightFoot") or fc("Right Leg")
    elseif partName == "RightLowerLeg"    then return fc("RightLowerLeg")
    elseif partName == "RightUpperLeg"    then return fc("RightUpperLeg")
    elseif partName == "Neck"             then return fc("Neck")
    elseif partName == "Back"             then return fc("Back") or fc("HumanoidRootPart")
    elseif partName == "Front"            then return fc("Front") or fc("HumanoidRootPart")
    elseif partName == "Closest" then
        local CameraPosition  = Camera.CFrame.Position
        local CameraLook = Camera.CFrame.LookVector
        local Best, BestD = nil, math.huge
        for _, part in pairs(target:GetChildren()) do
            if part:IsA("BasePart") then
                local d = 1 - CameraLook:Dot((part.Position-CameraPosition).Unit)
                if d < BestD then BestD=d; best=part end
            end
        end
        return Best or fc("HumanoidRootPart")
    elseif partName == "Random" then
        local list = {}
        for _, part in pairs(target:GetChildren()) do
            if part:IsA("BasePart") then table.insert(list, part) end
        end
        if #list > 0 then return list[math.random(1, #list)] end
    end
    return target:FindFirstChild("HumanoidRootPart")
end

local function ShouldHitTarget()
    if silentAim.hitChance >= 100 then return true end
    if silentAim.hitChance <= 0   then return false end
    return math.random(1, 100) <= silentAim.hitChance
end

local function ClosestInFov(radius, center)
    local closest, closestDist = nil, math.huge
    local cam = Camera
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not char:FindFirstChildOfClass("ForceField") then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local Position, OnScreen = WorldToScreen(root.Position, Camera)
                        if OnScreen then
                            local dx = pos.X - center.X
                            local dy = pos.Y - center.Y
                            local dist = math.sqrt(dx*dx + dy*dy)
                            if dist <= radius and dist < closestDist then
                                Closest = char
                                ClosestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end
    return Closest
end

local function ClosestPlayerInFov(radius)
    local Closets = ClosestInFov(radius, silentfovcenter())
    CurrentTarget = Closets
    return Closets
end

