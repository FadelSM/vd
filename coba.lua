--[[
    SCRIPT DISTRIK KEKERASAN - PC & HP Compatible
    Support untuk Delta Executor (PC & Android)
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
local isMobile = false
local isPC = false

-- Deteksi apakah pengguna menggunakan mobile
local function detectPlatform()
    local UserInputService = game:GetService("UserInputService")
    if UserInputService.TouchEnabled then
        isMobile = true
        isPC = false
        print("📱 Mode HP Terdeteksi!")
    else
        isMobile = false
        isPC = true
        print("💻 Mode PC Terdeteksi!")
    end
end

-- ============================================
-- VARIABEL GLOBAL
-- ============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local isKiller = false
local isGameRunning = true
local generators = {}
local killer = nil
local guiCreated = false

-- ============================================
-- FUNGSI GUI UNTUK HP
-- ============================================
local function createMobileGUI()
    if guiCreated then return end
    if not isMobile then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DistrikGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Background tombol
    local function createButton(text, position, size, color, action)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, size or 60, 0, 60)
        frame.Position = UDim2.new(position.X or 0.8, 0, position.Y or 0.5, 0)
        frame.BackgroundColor3 = color or Color3.fromRGB(255, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
        frame.Parent = screenGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 30)
        corner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        -- Touch event untuk HP
        local function onTouch()
            if action then action() end
            -- Efek klik
            frame.BackgroundTransparency = 0
            task.wait(0.1)
            frame.BackgroundTransparency = 0.3
        end
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                onTouch()
            end
        end)
        
        return frame
    end
    
    if isKiller then
        -- Tombol untuk pembunuh (HP)
        createButton("⚡T", {X = 0.7, Y = 0.3}, 60, Color3.fromRGB(200, 0, 0), function()
            if isKiller then
                local nearest = getNearestSurvivor()
                if nearest and nearest.Character then
                    local dist = (character.HumanoidRootPart.Position - nearest.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= CONFIG.Pembunuh.TeleportRange then
                        character.HumanoidRootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                        createEffect(character.HumanoidRootPart.Position, "Bright violet")
                    end
                end
            end
        end)
        
        createButton("👻Q", {X = 0.8, Y = 0.3}, 60, Color3.fromRGB(100, 0, 200), function()
            if isKiller then
                toggleInvisible()
            end
        end)
        
        createButton("💨E", {X = 0.7, Y = 0.45}, 60, Color3.fromRGB(0, 200, 255), function()
            if isKiller then
                speedBoost()
            end
        end)
        
        createButton("👥F", {X = 0.8, Y = 0.45}, 60, Color3.fromRGB(0, 200, 0), function()
            if isKiller then
                createClones()
            end
        end)
        
        -- Tombol kill untuk HP
        local killBtn = createButton("🔪", {X = 0.85, Y = 0.7}, 80, Color3.fromRGB(255, 0, 0), function()
            if isKiller then
                local target, dist = getNearestSurvivor()
                if target and target.Character and dist <= CONFIG.Pembunuh.KillRange then
                    target.Character.Humanoid.Health = 0
                    createEffect(target.Character.HumanoidRootPart.Position, "Really red")
                    print("💀 " .. target.Name .. " terbunuh!")
                end
            end
        end)
        
        -- Tombol long kill untuk HP
        createButton("💀", {X = 0.75, Y = 0.7}, 80, Color3.fromRGB(150, 0, 0), function()
            if isKiller then
                local target, dist = getNearestSurvivor()
                if target and target.Character and dist <= CONFIG.Pembunuh.LongKillRange then
                    target.Character.Humanoid.Health = 0
                    createEffect(target.Character.HumanoidRootPart.Position, "Really red")
                    print("💀💀 " .. target.Name .. " terbunuh (long range)!")
                end
            end
        end)
        
    else
        -- Tombol untuk survivor (HP)
        createButton("💨Q", {X = 0.7, Y = 0.3}, 60, Color3.fromRGB(0, 200, 255), function()
            if not isKiller then
                local direction = character.HumanoidRootPart.CFrame.LookVector * CONFIG.Survivor.DashDistance
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + direction
                createEffect(character.HumanoidRootPart.Position, "Bright cyan")
            end
        end)
        
        createButton("🛡️E", {X = 0.8, Y = 0.3}, 60, Color3.fromRGB(0, 100, 255), function()
            if not isKiller then
                createShield()
            end
        end)
        
        -- Tombol repair untuk HP
        createButton("🔧", {X = 0.7, Y = 0.7}, 80, Color3.fromRGB(0, 255, 0), function()
            if not isKiller then
                repairGenerator()
            end
        end)
    end
    
    -- Informasi role
    local roleFrame = Instance.new("Frame")
    roleFrame.Size = UDim2.new(0, 200, 0, 40)
    roleFrame.Position = UDim2.new(0.5, -100, 0.05, 0)
    roleFrame.BackgroundColor3 = isKiller and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    roleFrame.BackgroundTransparency = 0.2
    roleFrame.BorderSizePixel = 2
    roleFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    roleFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = roleFrame
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Size = UDim2.new(1, 0, 1, 0)
    roleLabel.BackgroundTransparency = 1
    roleLabel.Text = isKiller and "🔪 PEMBUNUH" or "🏃 SURVIVOR"
    roleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    roleLabel.TextScaled = true
    roleLabel.Font = Enum.Font.GothamBold
    roleLabel.Parent = roleFrame
    
    -- Info generator
    local genFrame = Instance.new("Frame")
    genFrame.Size = UDim2.new(0, 200, 0, 30)
    genFrame.Position = UDim2.new(0.5, -100, 0.12, 0)
    genFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    genFrame.BackgroundTransparency = 0.5
    genFrame.BorderSizePixel = 0
    genFrame.Parent = screenGui
    
    local genLabel = Instance.new("TextLabel")
    genLabel.Size = UDim2.new(1, 0, 1, 0)
    genLabel.BackgroundTransparency = 1
    genLabel.Text = "Generator: 0/" .. #generators
    genLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    genLabel.TextScaled = true
    genLabel.Font = Enum.Font.Gotham
    genLabel.Parent = genFrame
    
    -- Update generator info
    spawn(function()
        while isGameRunning do
            local fixed = 0
            for _, g in pairs(generators) do
                if g.IsFixed then fixed = fixed + 1 end
            end
            genLabel.Text = "Generator: " .. fixed .. "/" .. #generators
            task.wait(0.5)
        end
    end)
    
    guiCreated = true
    print("📱 GUI Mobile dibuat!")
end

-- ============================================
-- FUNGSI EFEK
-- ============================================
local function createEffect(position, color)
    local part = Instance.new("Part")
    part.Size = Vector3.new(5, 5, 5)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.BrickColor = BrickColor.new(color or "Bright red")
    part.Transparency = 0.5
    part.Parent = workspace
    Debris:AddItem(part, 0.5)
end

-- ============================================
-- FUNGSI KILLER
-- ============================================
local isInvisible = false
local isSpeedBoost = false

local function getNearestSurvivor()
    local nearest = nil
    local minDist = math.huge
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local dist = (character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = p
            end
        end
    end
    
    return nearest, minDist
end

local function toggleInvisible()
    if isInvisible then return end
    isInvisible = true
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    task.wait(CONFIG.Pembunuh.InvisibleDuration)
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
        end
    end
    
    isInvisible = false
end

local function speedBoost()
    if isSpeedBoost then return end
    isSpeedBoost = true
    
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = humanoid.WalkSpeed * CONFIG.Pembunuh.SpeedBoostMultiplier
    
    task.wait(5)
    humanoid.WalkSpeed = originalSpeed
    isSpeedBoost = false
end

local function createClones()
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
end

-- ============================================
-- FUNGSI SURVIVOR
-- ============================================
local function createShield()
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
    
    task.wait(CONFIG.Survivor.ShieldDuration)
    shield:Destroy()
end

local function repairGenerator()
    for _, genData in pairs(generators) do
        if character and character:FindFirstChild("HumanoidRootPart") then
            local distance = (character.HumanoidRootPart.Position - genData.Object.Position).Magnitude
            if distance < 10 and not genData.IsFixed then
                genData.Progress = math.min(genData.Progress + (CONFIG.Survivor.RepairSpeed * 0.2), 100)
                genData.UI.Size = UDim2.new(genData.Progress / 100, 0, 1, 0)
                
                if genData.Progress >= 100 and not genData.IsFixed then
                    genData.IsFixed = true
                    genData.Object.BrickColor = BrickColor.new("Bright blue")
                    genData.Object.Material = Enum.Material.SmoothPlastic
                    
                    local sound = Instance.new("Sound")
                    sound.SoundId = "rbxassetid://9120372812"
                    sound.Volume = 10
                    sound.Parent = genData.Object
                    sound:Play()
                    
                    print("⚡ Generator selesai!")
                    
                    local allFixed = true
                    for _, g in pairs(generators) do
                        if not g.IsFixed then
                            allFixed = false
                            break
                        end
                    end
                    
                    if allFixed then
                        print("🎉 SELAMAT! Anda MENANG!")
                        StarterGui:SetCore("SendNotification", {
                            Title = "🎉 MENANG!",
                            Text = "Semua generator selesai!",
                            Duration = 5,
                        })
                    end
                end
            end
        end
    end
end

-- ============================================
-- ESP (WALLHACK)
-- ============================================
local function setupESP()
    local function createESP(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Pink"
        highlight.Adornee = targetPlayer.Character
        highlight.FillColor = CONFIG.Survivor.ESPColor
        highlight.FillTransparency = 0.4
        highlight.OutlineColor = CONFIG.Survivor.ESPColor
        highlight.OutlineTransparency = 0
        highlight.Parent = targetPlayer.Character
        
        if targetPlayer ~= player then
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        
        return highlight
    end
    
    local function updateESP()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not p.Character:FindFirstChild("ESP_Pink") then
                    createESP(p)
                end
            end
        end
    end
    
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            createESP(p)
        end)
    end)
    
    spawn(function()
        while isGameRunning do
            updateESP()
            task.wait(0.5)
        end
    end)
    
    task.wait(1)
    updateESP()
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
        gen.Material = Enum.Material.Neon
        gen.Name = "Generator_" .. i
        gen.Parent = workspace
        
        local genData = {
            Object = gen,
            IsFixed = false,
            Progress = 0,
        }
        table.insert(generators, genData)
        
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.Adornee = gen
        billboard.Parent = gen
        
        local progressBar = Instance.new("Frame")
        progressBar.Size = UDim2.new(1, 0, 1, 0)
        progressBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        progressBar.Parent = billboard
        
        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        progressFill.Parent = progressBar
        
        genData.UI = progressFill
    end
end

-- ============================================
-- SETUP ROLE
-- ============================================
local function checkRole()
    local allPlayers = Players:GetPlayers()
    if #allPlayers > 0 then
        killer = allPlayers[1]
        isKiller = (player == killer)
    end
end

-- ============================================
-- SETUP KILLER (PC)
-- ============================================
local function setupKillerPC()
    if not isKiller then return end
    
    print("🔪 Anda adalah PEMBUNUH!")
    
    local teleportCooldown = false
    local killCooldown = false
    local abilityCooldown = false
    
    UserInputService.InputBegan:Connect(function(input)
        if not isKiller then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            
            -- Teleport (T)
            if key == Enum.KeyCode.T and not teleportCooldown then
                local target, dist = getNearestSurvivor()
                if target and target.Character and dist <= CONFIG.Pembunuh.TeleportRange then
                    character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
                    createEffect(character.HumanoidRootPart.Position, "Bright violet")
                    teleportCooldown = true
                    task.wait(CONFIG.Pembunuh.TeleportCooldown)
                    teleportCooldown = false
                end
            end
            
            -- Invisible (Q)
            if key == Enum.KeyCode.Q and not abilityCooldown then
                toggleInvisible()
            end
            
            -- Speed Boost (E)
            if key == Enum.KeyCode.E and not abilityCooldown then
                speedBoost()
            end
            
            -- Clone (F)
            if key == Enum.KeyCode.F and not abilityCooldown then
                createClones()
            end
        end
        
        -- Kill (Klik Kiri)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not killCooldown then
            local target, dist = getNearestSurvivor()
            if target and target.Character and dist <= CONFIG.Pembunuh.KillRange then
                target.Character.Humanoid.Health = 0
                createEffect(target.Character.HumanoidRootPart.Position, "Really red")
                print("💀 " .. target.Name .. " terbunuh!")
                killCooldown = true
                task.wait(CONFIG.Pembunuh.KillCooldown)
                killCooldown = false
            end
        end
        
        -- Long Kill (Klik Kanan)
        if input.UserInputType == Enum.UserInputType.MouseButton2 and not killCooldown then
            local target, dist = getNearestSurvivor()
            if target and target.Character and dist <= CONFIG.Pembunuh.LongKillRange then
                target.Character.Humanoid.Health = 0
                createEffect(target.Character.HumanoidRootPart.Position, "Really red")
                print("💀💀 " .. target.Name .. " terbunuh (long range)!")
                killCooldown = true
                task.wait(CONFIG.Pembunuh.KillCooldown)
                killCooldown = false
            end
        end
    end)
end

-- ============================================
-- SETUP SURVIVOR (PC)
-- ============================================
local function setupSurvivorPC()
    if isKiller then return end
    
    print("🏃 Anda adalah SURVIVOR!")
    
    setupESP()
    
    if CONFIG.Survivor.NoFail then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
    
    local dashCooldown = false
    local shieldCooldown = false
    
    UserInputService.InputBegan:Connect(function(input)
        if isKiller then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local key = input.KeyCode
            
            -- Dash (Q)
            if key == Enum.KeyCode.Q and not dashCooldown then
                local direction = character.HumanoidRootPart.CFrame.LookVector * CONFIG.Survivor.DashDistance
                character.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame + direction
                createEffect(character.HumanoidRootPart.Position, "Bright cyan")
                dashCooldown = true
                task.wait(CONFIG.Survivor.DashCooldown)
                dashCooldown = false
            end
            
            -- Shield (E)
            if key == Enum.KeyCode.E and not shieldCooldown then
                createShield()
                shieldCooldown = true
                task.wait(10)
                shieldCooldown = false
            end
        end
        
        -- Repair (E - juga untuk HP)
        if input.KeyCode == Enum.KeyCode.E and not isKiller then
            repairGenerator()
        end
    end)
end

-- ============================================
-- AUTO REPAIR (UNTUK SEMUA PLATFORM)
-- ============================================
local function autoRepair()
    if isKiller then return end
    
    spawn(function()
        while isGameRunning do
            task.wait(0.1)
            
            for _, genData in pairs(generators) do
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - genData.Object.Position).Magnitude
                    if distance < 10 and not genData.IsFixed then
                        genData.Progress = math.min(genData.Progress + (CONFIG.Survivor.RepairSpeed * 0.05), 100)
                        genData.UI.Size = UDim2.new(genData.Progress / 100, 0, 1, 0)
                        
                        if genData.Progress >= 100 and not genData.IsFixed then
                            genData.IsFixed = true
                            genData.Object.BrickColor = BrickColor.new("Bright blue")
                            genData.Object.Material = Enum.Material.SmoothPlastic
                            
                            local sound = Instance.new("Sound")
                            sound.SoundId = "rbxassetid://9120372812"
                            sound.Volume = 10
                            sound.Parent = genData.Object
                            sound:Play()
                            
                            print("⚡ Generator selesai!")
                            
                            local allFixed = true
                            for _, g in pairs(generators) do
                                if not g.IsFixed then
                                    allFixed = false
                                    break
                                end
                            end
                            
                            if allFixed then
                                print("🎉 MENANG!")
                                StarterGui:SetCore("SendNotification", {
                                    Title = "🎉 MENANG!",
                                    Text = "Semua generator selesai!",
                                    Duration = 5,
                                })
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- NOTIFIKASI
-- ============================================
local function showNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3,
    })
end

-- ============================================
-- MAIN EXECUTION
-- ============================================
print("🚀 Loading Distrik Kekerasan...")

-- Deteksi platform
detectPlatform()

-- Spawn generator
spawnGenerators()

-- Cek role
checkRole()

-- Setup berdasarkan role dan platform
if isKiller then
    setupKillerPC()
    showNotification("🔪 PEMBUNUH", "Bunuh semua survivor!", 3)
else
    setupSurvivorPC()
    autoRepair()
    showNotification("🏃 SURVIVOR", "Selesaikan semua generator!", 3)
end

-- Buat GUI untuk HP
if isMobile then
    task.wait(1)
    createMobileGUI()
end

-- Informasi kontrol
print("========================================")
print("🎮 DISTRIK KEKERASAN")
print("========================================")

if isPC then
    if isKiller then
        print("🔪 KONTROL PEMBUNUH (PC):")
        print("  T = Teleport ke survivor")
        print("  Q = Invisible (5 detik)")
        print("  E = Speed Boost")
        print("  F = Buat Clone")
        print("  Klik Kiri = Bunuh jarak dekat")
        print("  Klik Kanan = Bunuh jarak jauh")
    else
        print("🏃 KONTROL SURVIVOR (PC):")
        print("  Q = Dash (lompat jauh)")
        print("  E = Shield & Repair Generator")
        print("  [OTOMATIS] = Auto repair generator")
        print("  [OTOMATIS] = ESP Pink (wallhack)")
    end
else
    if isKiller then
        print("🔪 KONTROL PEMBUNUH (HP):")
        print("  🔴 Tombol merah = Bunuh")
        print("  ⚡T = Teleport")
        print("  👻Q = Invisible")
        print("  💨E = Speed Boost")
        print("  👥F = Clone")
        print("  💀 = Bunuh jarak jauh")
    else
        print("🏃 KONTROL SURVIVOR (HP):")
        print("  💨Q = Dash")
        print("  🛡️E = Shield")
        print("  🔧 = Repair Generator")
        print("  [OTOMATIS] = Auto repair")
        print("  [OTOMATIS] = ESP Pink")
    end
end
print("========================================")

-- Cleanup saat player respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    task.wait(0.5)
    
    if isKiller then
        setupKillerPC()
    else
        setupSurvivorPC()
        autoRepair()
    end
    
    -- Recreate GUI untuk HP
    if isMobile then
        task.wait(1)
        createMobileGUI()
    end
end)

print("✅ Script berhasil dijalankan!")
print("📱 Platform: " .. (isPC and "PC" or "HP"))

-- ============================================
-- COMMAND UNTUK TOGGLE FITUR
-- ============================================
local function setupCommands()
    _G.Distrik = {
        ToggleESP = function()
            CONFIG.Survivor.Wallhack = not CONFIG.Survivor.Wallhack
            print("ESP: " .. (CONFIG.Survivor.Wallhack and "ON" or "OFF"))
        end,
        ToggleAutoRepair = function()
            -- Auto repair sudah berjalan
            print("Auto repair selalu aktif untuk survivor!")
        end,
        GetGenerators = function()
            local fixed = 0
            for _, g in pairs(generators) do
                if g.IsFixed then fixed = fixed + 1 end
            end
            print("Generator: " .. fixed .. "/" .. #generators .. " selesai")
        end
    }
    
    print("💡 Gunakan _G.Distrik.ToggleESP() untuk toggle ESP")
end

setupCommands()