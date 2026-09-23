-- created by CrystalHub owner
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local _v3_new = Vector3.new
local _cf_new = CFrame.new

local function BuildGoldenBomb()
    local Main = Instance.new('Part')

    Main.Name = 'VisualGoldDrop'
    Main.Size = _v3_new(1.65, 0.9, 1.3)
    Main.Transparency = 0
    Main.CanCollide = true

    local Mesh = Instance.new('SpecialMesh')

    Mesh.MeshId = ''
    Mesh.TextureId = ''
    Mesh.Scale = _v3_new(1.5, 1.5, 1.5)
    Mesh.Parent = Main

    return Main
end
local function AttachNaturalBombEffects(part)
    local Smoke = Instance.new('Smoke', part)

    Smoke.Color = Color3.fromRGB(128, 128, 128)
    Smoke.Opacity = 0.2
    Smoke.Size = 0.1
    Smoke.RiseVelocity = 1
    Smoke.Enabled = true

    local BillboardGui = Instance.new('BillboardGui', part)

    BillboardGui.Size = UDim2.new(3, 0, 3, 0)
    BillboardGui.ExtentsOffset = _v3_new(0, 0, 1)

    local LightImage = Instance.new('ImageLabel', BillboardGui)

    LightImage.Size = UDim2.new(1, 0, 1, 0)
    LightImage.BackgroundTransparency = 1
    LightImage.Image = ''
    LightImage.Visible = false

    task.spawn(function()
        while part and part.Parent do
            LightImage.Visible = not LightImage.Visible

            task.wait(0.18)
        end
    end)
end
local function CreateSilentGoldExplosion(pos)
    local expPos = pos + _v3_new(0, 1.2, 0)
    local flash = Instance.new('Part')

    flash.Shape = Enum.PartType.Ball
    flash.Size = _v3_new(0.5, 0.5, 0.5)
    flash.Color = Color3.fromRGB(255, 215, 0)
    flash.Material = Enum.Material.Neon
    flash.Anchored = true
    flash.CanCollide = false
    flash.CFrame = _cf_new(expPos)
    flash.Parent = Workspace

    local emitter = Instance.new('ParticleEmitter')

    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 130)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 190, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 90, 0)),
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(0.5, 0.6),
        NumberSequenceKeypoint.new(1, 0),
    })
    emitter.Speed = NumberRange.new(12, 25)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Lifetime = NumberRange.new(0.4, 0.7)
    emitter.Acceleration = _v3_new(0, -8, 0)
    emitter.LightEmission = 1
    emitter.Parent = flash

    task.spawn(function()
        task.wait(0.02)

        if emitter and emitter.Parent then
            emitter:Emit(60)
        end
    end)
    task.spawn(function()
        for i = 1, 12 do
            if flash and flash.Parent then
                flash.Size = flash.Size + _v3_new(0.7, 0.7, 0.7)
                flash.Transparency = i / 12
            end

            task.wait(0.015)
        end

        if flash then
            flash:Destroy()
        end
    end)
end
local function CountVisualGoldBombs()
    local count = 0

    if Player.Backpack then
        for _, item in ipairs(Player.Backpack:GetChildren())do
            if item:IsA('Tool') and item.Name == 'GoldBomb (Visual)' then
                count += 1
            end
        end
    end
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren())do
            if item:IsA('Tool') and item.Name == 'GoldBomb (Visual)' then
                count += 1
            end
        end
    end

    return count
end
local function CreateOneVisualGoldTool()
    local Tool = Instance.new('Tool')

    Tool.Name = 'GoldBomb (Visual)'
    Tool.RequiresHandle = true
    Tool.CanBeDropped = false
    Tool.TextureId = ''
    Tool.Grip = _cf_new(-0.6, 0, -0.4, -0.936466694, -3.63886356E-5, -0.350756258, -0.168184027, 0.877594054, 0.448935181, 0.30780527, 0.479404479, -0.821843743)

    local Handle = BuildGoldenBomb()

    Handle.Name = 'Handle'
    Handle.CanCollide = false
    Handle.Parent = Tool

    local canUseThisTool, localDroppedBomb = true, nil

    Tool.Activated:Connect(function()
        if not canUseThisTool then
            return
        end

        local char = Player.Character
        local hrp = char and char:FindFirstChild('HumanoidRootPart')

        if not hrp then
            return
        end

        canUseThisTool = false

        if localDroppedBomb then
            localDroppedBomb:Destroy()
        end

        local droppedBomb = BuildGoldenBomb()

        droppedBomb.CFrame = hrp.CFrame * _cf_new(0, -3.2, 0)
        droppedBomb.Parent = Workspace
        localDroppedBomb = droppedBomb

        AttachNaturalBombEffects(droppedBomb)

        local bv = Instance.new('BodyVelocity', droppedBomb)

        bv.MaxForce = _v3_new(1e5, 1e5, 1e5)
        bv.Velocity = ((Mouse.Hit.p - hrp.Position).Unit * 25) + _v3_new(0, 10, 0)

        game.Debris:AddItem(bv, 0.1)

        local humanoid = char:FindFirstChildOfClass('Humanoid')

        if humanoid then
            humanoid.Jump = true
        end

        local parts = {}
        local v_root = Tool

        for _, p in pairs(v_root:GetChildren())do
            if p:IsA('BasePart') then
                parts[p] = p.Transparency
                p.Transparency = 1

                local mesh = p:FindFirstChildOfClass('SpecialMesh')

                if mesh then
                    mesh.Scale = _v3_new(0, 0, 0)
                end
            end
        end

        task.wait(1.5)

        if localDroppedBomb and localDroppedBomb.Parent then
            CreateSilentGoldExplosion(localDroppedBomb.Position)
            localDroppedBomb:Destroy()

            localDroppedBomb = nil
        end

        for p, trans in pairs(parts)do
            if p then
                p.Transparency = trans

                local mesh = p:FindFirstChildOfClass('SpecialMesh')

                if mesh then
                    mesh.Scale = _v3_new(1.5, 1.5, 1.5)
                end
            end
        end

        canUseThisTool = true
    end)

    Tool.Parent = Player.Backpack
end

GiveVisualGoldBomb = function()
    local targetAmount = math.clamp(1, 1, 4)
    local currentCount = CountVisualGoldBombs()

    if currentCount < targetAmount then
        for _ = 1, (targetAmount - currentCount)do
            CreateOneVisualGoldTool()
        end
    end
end



GiveVisualGoldBomb()
