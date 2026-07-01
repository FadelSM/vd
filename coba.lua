--[[
    SCRIPT DISTRIK KEKERASAN - UI SUPERIOR VERSION
    Support untuk Delta Executor (PC & Android)
    Dengan UI yang lebih bagus, animasi, dan fitur lengkap!
--]]

-- ============================================
-- KONFIGURASI
-- ============================================
local CONFIG = {
    Pembunuh = {
        TeleportRange = 50,
        KillRange = 30,
        LongKillRange = 60,
        TeleportCooldown = 2,
        KillCooldown = 1.5,
        InvisibleDuration = 5,
        SpeedBoostMultiplier = 1.5,
        CloneAmount = 3,
    },
    Survivor = {
        RepairSpeed = 3,
        NoFail = true,
        Wallhack = true,
        ESPColor = Color3.fromRGB(255, 105, 180),
        DashDistance = 30,
        DashCooldown = 3,
        ShieldDuration = 5,
    }
}

-- ============================================
-- DETEKSI PLATFORM
-- ============================================
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled
local isPC = not isMobile

-- ============================================
-- VARIABEL GLOBAL
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isKiller = false
local isGameRunning = true
local generators = {}
local killer = nil
local guiCreated = false
local screenGui = nil

-- ============================================
-- FUNGSI ANIMASI
-- ============================================
local function tweenObject(obj, properties, duration)
    local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function createPulseEffect(obj)
    spawn(function()
        while obj and obj.Parent do
            tweenObject(obj, {BackgroundTransparency = 0.1}, 0.5)
            task.wait(0.5)
            tweenObject(obj, {BackgroundTransparency = 0.3}, 0.5)
            task.wait(0.5)
        end
    end)
end

-- ============================================
-- UI SUPERIOR UNTUK HP & PC
-- ============================================
local function createSuperiorUI()
    if guiCreated then return end
    
    -- ScreenGui utama dengan efek blur
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DistrikUI_Superior"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Background gelap transparan untuk efek glassmorphism
    local function createGlassmorphism(parent, size, position, transparency)
        local frame = Instance.new("Frame")
        frame.Size = size
        frame.Position = position
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        frame.BackgroundTransparency = transparency or 0.7
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        frame.BorderSizePixel = 0
        frame.Parent = parent
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 15)
        corner.Parent = frame
        
        -- Efek glassmorphism (stroke)
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Transparency = 0.5
        stroke.Parent = frame
        
        return frame
    end
    
    -- ============================================
    -- 1. ROLE INDICATOR (Atas)
    -- ============================================
    local roleFrame = createGlassmorphism(screenGui, UDim2.new(0, 250, 0, 50), UDim2.new(0.5, -125, 0.02, 0), 0.6)
    
    local roleIcon = Instance.new("TextLabel")
    roleIcon.Size = UDim2.new(0, 40, 1, 0)
    roleIcon.BackgroundTransparency = 1
    roleIcon.Text = isKiller and "🔪" or "🏃"
    roleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    roleIcon.TextScaled = true
    roleIcon.Font = Enum.Font.GothamBold
    roleIcon.Parent = roleFrame
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, -45, 1, 0)
    roleLabel.Position = UDim2.new(0, 45, 0, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = isKiller and "PEMBUNUH" or "SURVIVOR"
    roleLabel.TextColor3 = isKiller and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 50)
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.Parent = roleFrame
    
    -- Animasi pulse role
    createPulseEffect(roleFrame)
    
    -- ============================================
    -- 2. GENERATOR COUNTER (Atas)
    -- ============================================
    local genFrame = createGlassmorphism(screenGui, UDim2.new(0, 250, 0, 40), UDim2.new(0.5, -125, 0.09, 0), 0.6)
    
    local genIcon = Instance.new("TextLabel")
    genIcon.Size = UDim2.new(0, 30, 1, 0)
    genIcon.BackgroundTransparency = 1
    genIcon.Text = "⚡"
    genIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    genIcon.TextScaled = true
    genIcon.Font = Enum.Font.GothamBold
    genIcon.Parent = genFrame
    
    local genLabel = Instance.new("TextLabel")
    genLabel.Size = UDim2.new(1, -35, 1, 0)
    genLabel.Position = UDim2.new(0, 35, 0, 0)
    genLabel.BackgroundTransparency = 1
    genLabel.Text = "Generator: 0/7"
    genLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    genLabel.TextScaled = true
    genLabel.Font = Enum.Font.Gotham
    genLabel.TextXAlignment = Enum.TextXAlignment.Left
    genLabel.Parent = genFrame
    genLabel.Name = "GenLabel"
    
    -- ============================================
    -- 3. STATUS INDICATOR (Kiri Atas)
    -- ============================================
    local statusFrame = createGlassmorphism(screenGui, UDim2.new(0, 200, 0, 100), UDim2.new(0.01, 10, 0.15, 0), 0.5)
    statusFrame.Visible = false
    statusFrame.Name = "StatusFrame"
    
    local statusTitle = Instance.new("TextLabel")
    statusTitle.Size = UDim2.new(1, 0, 0, 25)
    statusTitle.BackgroundTransparency = 1
    statusTitle.Text = "📊 STATUS"
    statusTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusTitle.TextScaled = true
    statusTitle.Font = Enum.Font.GothamBold
    statusTitle.Parent = statusFrame
    
    local statusList = Instance.new("TextLabel")
    statusList.Size = UDim2.new(1, 0, 1, -30)
    statusList.Position = UDim2.new(0, 0, 0, 30)
    statusList.BackgroundTransparency = 1
    statusList.Text = "● Inactive"
    statusList.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusList.TextScaled = true
    statusList.Font = Enum.Font.Gotham
    statusList.TextXAlignment = Enum.TextXAlignment.Left
    statusList.Parent = statusFrame
    statusList.Name = "StatusList"
    
    -- ============================================
    -- 4. KILL COUNTER (Kanan Atas)
    -- ============================================
    if isKiller then
        local killFrame = createGlassmorphism(screenGui, UDim2.new(0, 150, 0, 50), UDim2.new(1, -160, 0.02, 0), 0.6)
        
        local killIcon = Instance.new("TextLabel")
        killIcon.Size = UDim2.new(0, 30, 1, 0)
        killIcon.BackgroundTransparency = 1
        killIcon.Text = "💀"
        killIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        killIcon.TextScaled = true
        killIcon.Font = Enum.Font.GothamBold
        killIcon.Parent = killFrame
        
        local killLabel = Instance.new("TextLabel")
        killLabel.Size = UDim2.new(1, -35, 1, 0)
        killLabel.Position = UDim2.new(0, 35, 0, 0)
        killLabel.BackgroundTransparency = 1
        killLabel.Text = "0 Kill"
        killLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        killLabel.TextScaled = true
        killLabel.Font = Enum.Font.GothamBold
        killLabel.TextXAlignment = Enum.TextXAlignment.Left
        killLabel.Parent = killFrame
        killLabel.Name = "KillLabel"
        
        -- Streak indicator
        local streakFrame = createGlassmorphism(screenGui, UDim2.new(0, 150, 0, 40), UDim2.new(1, -160, 0.09, 0), 0.6)
        streakFrame.Visible = false
        streakFrame.Name = "StreakFrame"
        
        local streakLabel = Instance.new("TextLabel")
        streakLabel.Size = UDim2.new(1, 0, 1, 0)
        streakLabel.BackgroundTransparency = 1
        streakLabel.Text = "🔥 0x Streak"
        streakLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        streakLabel.TextScaled = true
        streakLabel.Font = Enum.Font.GothamBold
        streakLabel.Parent = streakFrame
        streakLabel.Name = "StreakLabel"
    end
    
    -- ============================================
    -- 5. ABILITY COOLDOWN INDICATOR (Bawah)
    -- ============================================
    local cooldownFrame = createGlassmorphism(screenGui, UDim2.new(0, 300, 0, 60), UDim2.new(0.5, -150, 1, -70), 0.5)
    cooldownFrame.Name = "CooldownFrame"
    
    -- Progress bar cooldown
    local cooldownBar = Instance.new("Frame")
    cooldownBar.Size = UDim2.new(1, -20, 0, 20)
    cooldownBar.Position = UDim2.new(0, 10, 0.15, 0)
    cooldownBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    cooldownBar.BorderSizePixel = 0
    cooldownBar.Parent = cooldownFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = cooldownBar
    
    local cooldownFill = Instance.new("Frame")
    cooldownFill.Size = UDim2.new(0, 0, 1, 0)
    cooldownFill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    cooldownFill.BorderSizePixel = 0
    cooldownFill.Parent = cooldownBar
    
    local corner2 = Instance.new("UICorner")
    corner2.CornerRadius = UDim.new(0, 10)
    corner2.Parent = cooldownFill
    
    local cooldownLabel = Instance.new("TextLabel")
    cooldownLabel.Size = UDim2.new(1, 0, 1, 0)
    cooldownLabel.BackgroundTransparency = 1
    cooldownLabel.Text = "⚡ Ability Ready"
    cooldownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cooldownLabel.TextScaled = true
    cooldownLabel.Font = Enum.Font.Gotham
    cooldownLabel.Parent = cooldownFrame
    
    -- ============================================
    -- 6. MINIMAP (Kiri Bawah)
    -- ============================================
    local minimap = createGlassmorphism(screenGui, UDim2.new(0, 120, 0, 120), UDim2.new(0.01, 10, 1, -140), 0.5)
    minimap.Name = "Minimap"
    
    local minimapTitle = Instance.new("TextLabel")
    minimapTitle.Size = UDim2.new(1, 0, 0, 20)
    minimapTitle.BackgroundTransparency = 1
    minimapTitle.Text = "🗺️ MAP"
    minimapTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimapTitle.TextScaled = true
    minimapTitle.Font = Enum.Font.GothamBold
    minimapTitle.Parent = minimap
    
    local mapFrame = Instance.new("Frame")
    mapFrame.Size = UDim2.new(1, -10, 1, -30)
    mapFrame.Position = UDim2.new(0, 5, 0, 25)
    mapFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mapFrame.BackgroundTransparency = 0.3
    mapFrame.BorderSizePixel = 0
    mapFrame.Parent = minimap
    mapFrame.Name = "MapFrame"
    
    -- ============================================
    -- 7. NOTIFICATION CENTER (Tengah)
    -- ============================================
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 400, 0, 60)
    notifFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifFrame.BackgroundTransparency = 0.8
    notifFrame.BorderSizePixel = 2
    notifFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
    notifFrame.Visible = false
    notifFrame.Parent = screenGui
    notifFrame.Name = "NotificationFrame"
    
    local corner3 = Instance.new("UICorner")
    corner3.CornerRadius = UDim.new(0, 20)
    corner3.Parent = notifFrame
    
    local notifLabel = Instance.new("TextLabel")
    notifLabel.Size = UDim2.new(1, 0, 1, 0)
    notifLabel.BackgroundTransparency = 1
    notifLabel.Text = "🔥 TRIPLE KILL!"
    notifLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    notifLabel.TextScaled = true
    notifLabel.Font = Enum.Font.GothamBold
    notifLabel.Parent = notifFrame
    
    -- ============================================
    -- 8. HP & SHIELD BAR (Bawah Tengah)
    -- ============================================
    local hpFrame = createGlassmorphism(screenGui, UDim2.new(0, 300, 0, 30), UDim2.new(0.5, -150, 1, -140), 0.5)
    hpFrame.Name = "HPFrame"
    
    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.new(1, -10, 0, 20)
    hpBar.Position = UDim2.new(0, 5, 0.15, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpFrame
    
    local corner4 = Instance.new("UICorner")
    corner4.CornerRadius = UDim.new(0, 10)
    corner4.Parent = hpBar
    
    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 50)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBar
    hpFill.Name = "HPFill"
    
    local corner5 = Instance.new("UICorner")
    corner5.CornerRadius = UDim.new(0, 10)
    corner5.Parent = hpFill
    
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 1, 0)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100/100"
    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpLabel.TextScaled = true
    hpLabel.Font = Enum.Font.Gotham
    hpLabel.Parent = hpFrame
    hpLabel.Name = "HPLabel"
    
    -- ============================================
    -- 9. BUTTONS UNTUK HP (Mobile)
    -- ============================================
    if isMobile then
        local buttonPositions = {
            -- Baris 1 (Atas)
            {text = "⚡T", pos = UDim2.new(0.7, 0, 0.3, 0), color = Color3.fromRGB(200, 0, 0), action = "teleport"},
            {text = "👻Q", pos = UDim2.new(0.82, 0, 0.3, 0), color = Color3.fromRGB(150, 0, 200), action = "invisible"},
            -- Baris 2
            {text = "💨E", pos = UDim2.new(0.7, 0, 0.45, 0), color = Color3.fromRGB(0, 200, 255), action = "speed"},
            {text = "👥F", pos = UDim2.new(0.82, 0, 0.45, 0), color = Color3.fromRGB(0, 200, 0), action = "clone"},
            -- Baris 3 (Kill)
            {text = "🔪", pos = UDim2.new(0.85, 0, 0.65, 0), color = Color3.fromRGB(255, 0, 0), action = "kill", size = 80},
            {text = "💀", pos = UDim2.new(0.72, 0, 0.65, 0), color = Color3.fromRGB(180, 0, 0), action = "longkill", size = 70},
        }
        
        if not isKiller then
            buttonPositions = {
                {text = "💨Q", pos = UDim2.new(0.7, 0, 0.3, 0), color = Color3.fromRGB(0, 200, 255), action = "dash"},
                {text = "🛡️E", pos = UDim2.new(0.82, 0, 0.3, 0), color = Color3.fromRGB(0, 100, 255), action = "shield"},
                {text = "🔧", pos = UDim2.new(0.78, 0, 0.6, 0), color = Color3.fromRGB(0, 255, 0), action = "repair", size = 90},
            }
        end
        
        for _, btnData in ipairs(buttonPositions) do
            local btn = Instance.new("Frame")
            local size = btnData.size or 65
            btn.Size = UDim2.new(0, size, 0, size)
            btn.Position = btnData.pos
            btn.BackgroundColor3 = btnData.color
            btn.BackgroundTransparency = 0.2
            btn.BorderSizePixel = 2
            btn.BorderColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = screenGui
            
            local corner6 = Instance.new("UICorner")
            corner6.CornerRadius = UDim.new(0, size/2)
            corner6.Parent = btn
            
            -- Efek glow
            local glow = Instance.new("Frame")
            glow.Size = UDim2.new(1.2, 0, 1.2, 0)
            glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
            glow.BackgroundColor3 = btnData.color
            glow.BackgroundTransparency = 0.8
            glow.BorderSizePixel = 0
            glow.Parent = btn
            
            local corner7 = Instance.new("UICorner")
            corner7.CornerRadius = UDim.new(0, size/2 + 5)
            corner7.Parent = glow
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = btnData.text
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextScaled = true
            label.Font = Enum.Font.GothamBold
            label.Parent = btn
            
            -- Touch event
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch then
                    tweenObject(btn, {BackgroundTransparency = 0}, 0.1)
                    task.wait(0.1)
                    tweenObject(btn, {BackgroundTransparency = 0.2}, 0.1)
                    
                    -- Execute action
                    if btnData.action == "teleport" then teleportToSurvivor() end
                    if btnData.action == "invisible" then toggleInvisible() end
                    if btnData.action == "speed" then speedBoost() end
                    if btnData.action == "clone" then createClones() end
                    if btnData.action == "kill" then killSurvivor() end
                    if btnData.action == "longkill" then longKillSurvivor() end
                    if btnData.action == "dash" then dashSurvivor() end
                    if btnData.action == "shield" then createShield() end
                    if btnData.action == "repair" then repairGenerator() end
                end
            end)
            
            -- Animasi pulse untuk kill button
            if btnData.action == "kill" or btnData.action == "longkill" then
                createPulseEffect(btn)
            end
        end
    end
    
    -- ============================================
    -- 10. CROSSHAIR (Tengah)
    -- ============================================
    local crosshair = Instance.new("Frame")
    crosshair.Size = UDim2.new(0, 20, 0, 20)
    crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)
    crosshair.BackgroundTransparency = 1
    crosshair.Parent = screenGui
    
    -- Garis horizontal
    local hLine = Instance.new("Frame")
    hLine.Size = UDim2.new(0, 20, 0, 2)
    hLine.Position = UDim2.new(0, 0, 0.5, -1)
    hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    hLine.BackgroundTransparency = 0.5
    hLine.Parent = crosshair
    
    -- Garis vertikal
    local vLine = Instance.new("Frame")
    vLine.Size = UDim2.new(0, 2, 0, 20)
    vLine.Position = UDim2.new(0.5, -1, 0, 0)
    vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    vLine.BackgroundTransparency = 0.5
    vLine.Parent = crosshair
    
    -- Dot tengah
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    dot.Parent = crosshair
    
    local corner8 = Instance.new("UICorner")
    corner8.CornerRadius = UDim.new(0, 2)
    corner8.Parent = dot
    
    guiCreated = true
    print("✅ UI Superior berhasil dibuat!")
    
    return screenGui
end

-- ============================================
-- UPDATE FUNGSI UNTUK UI
-- ============================================

-- Update HP Bar
local function updateHP()
    if not screenGui then return end
    local hpFrame = screenGui:FindFirstChild("HPFrame")
    if not hpFrame then return end
    
    local hpFill = hpFrame:FindFirstChild("HPFill")
    local hpLabel = hpFrame:FindFirstChild("HPLabel")
    
    if character and humanoid then
        local hp = humanoid.Health
        local maxHp = humanoid.MaxHealth
        local percent = hp / maxHp
        
        hpFill.Size = UDim2.new(percent, 0, 1, 0)
        hpFill.BackgroundColor3 = percent > 0.5 and Color3.fromRGB(0, 255, 50) or percent > 0.25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 0, 0)
        hpLabel.Text = "HP: " .. math.floor(hp) .. "/" .. maxHp
    end
end

-- Update Generator Counter
local function updateGeneratorCounter()
    if not screenGui then return end
    local genFrame = screenGui:FindFirstChild("GenLabel")
    if not genFrame then return end
    
    local fixed = 0
    for _, g in pairs(generators) do
        if g.IsFixed then fixed = fixed + 1 end
    end
    genFrame.Text = "Generator: " .. fixed .. "/" .. #generators
end

-- Update Kill Counter
local killCount = 0
local killStreak = 0
local function updateKillCounter()
    if not screenGui or not isKiller then return end
    local killLabel = screenGui:FindFirstChild("KillLabel")
    if killLabel then
        killLabel.Text = killCount .. " Kill"
    end
    
    local streakFrame = screenGui:FindFirstChild("StreakFrame")
    if streakFrame then
        if killStreak >= 2 then
            streakFrame.Visible = true
            local streakLabel = streakFrame:FindFirstChild("StreakLabel")
            if streakLabel then
                local emoji = killStreak >= 10 and "💀" or killStreak >= 5 and "⚡" or "🔥"
                streakLabel.Text = emoji .. " " .. killStreak .. "x Streak"
            end
        else
            streakFrame.Visible = false
        end
    end
end

-- Show Notification (Big)
local function showBigNotification(title, subtitle, duration)
    if not screenGui then return end
    local notifFrame = screenGui:FindFirstChild("NotificationFrame")
    if not notifFrame then return end
    
    local notifLabel = notifFrame:FindFirstChild("TextLabel")
    if notifLabel then
        notifLabel.Text = title
    end
    
    notifFrame.Visible = true
    tweenObject(notifFrame, {BackgroundTransparency = 0.2}, 0.3)
    task.wait(duration or 2)
    tweenObject(notifFrame, {BackgroundTransparency = 0.8}, 0.3)
    task.wait(0.3)
    notifFrame.Visible = false
end

-- ============================================
-- FUNGSI GAME (UPDATE)
-- ============================================

-- Teleport
local function teleportToSurvivor()
    if not isKiller then return end
    local nearest, dist = getNearestSurvivor()
    if nearest and nearest.Character and dist <= CONFIG.Pembunuh.TeleportRange then
        character.HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
        createEffect(character.HumanoidRootPart.Position, "Bright violet")
        showBigNotification("⚡ TELEPORT!", "Menuju " .. nearest.Name, 1)
    end
end

-- Invisible
local function toggleInvisible()
    if not isKiller then return end
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    showBigNotification("👻 INVISIBLE!", "Kamu tidak terlihat!", 1)
    task.wait(CONFIG.Pembunuh.InvisibleDuration)
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
end

-- Speed Boost
local function speedBoost()
    if not isKiller then return end
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = humanoid.WalkSpeed * CONFIG.Pembunuh.SpeedBoostMultiplier
    showBigNotification("💨 SPEED BOOST!", "Lari lebih cepat!", 1)
    task.wait(5)
    humanoid.WalkSpeed = originalSpeed
end

-- Create Clones
local function createClones()
    if not isKiller then return end
    for i = 1, CONFIG.Pembunuh.CloneAmount do
        local clone = character:Clone()
        clone.Name = "Clone_" .. player.Name .. "_" .. i
        clone.Parent = workspace
        clone.Humanoid.WalkSpeed = 10
        spawn(function()
            while clone.Parent ~= nil do
                local target, _ = getNearestSurvivor()
                if target and target.Character then
                    clone.Humanoid:MoveTo(target.Character.HumanoidRootPart.Position)
                end
                task.wait(2)
            end
        end)
        Debris:AddItem(clone, 10)
    end
    showBigNotification("👥 CLONES!", "3 clone diciptakan!", 1)
end

-- Kill Survivor
local function killSurvivor()
    if not isKiller then return end
    local target, dist = getNearestSurvivor()
    if target and target.Character and dist <= CONFIG.Pembunuh.KillRange then
        target.Character.Humanoid.Health = 0
        createEffect(target.Character.HumanoidRootPart.Position, "Really red")
        killCount = killCount + 1
        killStreak = killStreak + 1
        updateKillCounter()
        
        -- Streak notification
        if killStreak >= 10 then
            showBigNotification("💀 UNSTOPPABLE!", killStreak .. " Kill Streak!", 2)
        elseif killStreak >= 5 then
            showBigNotification("⚡ PENTA KILL!", killStreak .. " Kill Streak!", 2)
        elseif killStreak >= 3 then
            showBigNotification("🔥 TRIPLE KILL!", killStreak .. " Kill Streak!", 2)
        else
            showBigNotification("💀 KILL!", target.Name .. " terbunuh!", 1)
        end
    end
end

-- Long Kill
local function longKillSurvivor()
    if not isKiller then return end
    local target, dist = getNearestSurvivor()
    if target and target.Character and dist <= CONFIG.Pembunuh.LongKillRange then
        target.Character.Humanoid.Health = 0
        createEffect(target.Character.HumanoidRootPart.Position, "Really red")
        killCount = killCount + 1
        killStreak = killStreak + 1
        updateKillCounter()
        showBigNotification("💀 LONG KILL!", target.Name .. " terbunuh dari jauh!", 1)
    end
end

-- Dash
local function dashSurvivor()
    if isKiller then return end
    local direction = character.HumanoidRootPart.CFrame.LookVector * CONFIG.Survivor.DashDistance
    character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + direction
    createEffect(character.HumanoidRootPart.Position, "Bright cyan")
    showBigNotification("💨 DASH!", "Melesat!", 0.5)
end

-- Shield
local function createShield()
    if isKiller then return end
    local shield = Instance.new("Part")
    shield.Size = Vector3.new(5, 6, 5)
    shield.Position = character.HumanoidRootPart.Position
    shield.Anchored = false
    shield.CanCollide = false
    shield.Material = Enum.Material.Neon
    shield.BrickColor = BrickColor.new("Bright blue")
    shield.Transparency = 0.5
    shield.Parent = character
    
    local weld = Instance.new("Weld")
    weld.Part0 = shield
    weld.Part1 = character.HumanoidRootPart
    weld.C0 = CFrame.new(0, 0, 0)
    weld.Parent = shield
    
    showBigNotification("🛡️ SHIELD!", "Perisai aktif!", 1)
    task.wait(CONFIG.Survivor.ShieldDuration)
    shield:Destroy()
end

-- ============================================
-- SPAWN GENERATOR
-- ============================================
local function spawnGenerators()
    local generatorPositions = {
        Vector3.new(10, 2, 10),
        Vector3.new(-20, 2, 15),
        Vector3.new(30, 2, -25),
        Vector3.new(-35, 2, -30),
        Vector3.new(0, 2, 40),
        Vector3.new(25, 2, -15),
        Vector3.new(-25, 2, -20),
    }
    
    for i, pos in ipairs(generatorPositions) do
        local gen = Instance.new("Part")
        gen.Size = Vector3.new(3, 4, 3)
        gen.Position = pos
        gen.Anchored = true
        gen.BrickColor = BrickColor.new("Bright green")
        gen.Material = Enum