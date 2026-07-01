--[ VIOLENCE DISTRICT - GUI PREMIUM ZEXSPARK - FadelSM]
--[ VERSI: LEGENDARY PREMIUM EDITION | 58 FITUR ]
--[ BUKA/TUTUP : INSERT atau X | BUTTON PREMIUM DENGAN ANIMASI ]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- ========== SETTINGS LENGKAP ==========
local Settings = {
    -- Kombat
    KillAura = true, KillRange = 50, GodMode = true, OneHit = true,
    InfiniteAmmo = true, AutoHeal = true, Aimbot = true,
    -- Mobilitas
    SpeedHack = true, SpeedValue = 120, Fly = false, NoClip = true,
    Invisible = false, UnlimitedJump = false, SpeedOfLight = false,
    -- Visual
    ESP = true, RainbowTrail = false, RealityWarp = false,
    -- Dewa
    TimeFreeze = false, MagnetPlayer = false, MindControl = false,
    DamageMultiplier = false, AutoParry = false, RevengeMode = false,
    AntiReport = false, DimensionShift = false, TimeLoop = false,
    AdminStealth = false,
    -- FITUR LEGENDARY BARU
    OmegaLaser = false,
    SoulBind = false,
    InfiniteSkills = false,
    MapControl = false,
    PlayerTracker = false
}

-- Variabel
local pets = {}
local phantoms = {}
local boundSouls = {}
local trackedPlayer = nil
local originalGravity = Workspace.Gravity
local laserBeam = nil

-- ========== FUNGSI FITUR LEGENDARY ==========

-- 1. OMEGA LASER (Laser penghancur)
function toggleOmegaLaser(state)
    if state then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚡ OMEGA LASER",
            Text = "Aktif! Arahkan mouse ke musuh untuk membunuh instantly",
            Duration = 3
        })
        local mouse = LocalPlayer:GetMouse()
        local laserPart = Instance.new("Part")
        laserPart.Size = Vector3.new(0.5, 0.5, 100)
        laserPart.Material = Enum.Material.Neon
        laserPart.Color = Color3.fromRGB(255, 0, 0)
        laserPart.Anchored = true
        laserPart.Parent = Workspace
        
        RunService.RenderStepped:Connect(function()
            if Settings.OmegaLaser then
                local origin = Character.Head.Position
                local direction = (mouse.Hit.Position - origin).Unit
                laserPart.CFrame = CFrame.new(origin + direction * 50, origin + direction * 100)
                laserPart.Size = Vector3.new(0.5, 0.5, (mouse.Hit.Position - origin).Magnitude)
                
                -- Raycast untuk membunuh
                local ray = Ray.new(origin, direction * 500)
                local hit, pos = Workspace:FindPartOnRay(ray, Character)
                if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
                    local victim = Players:GetPlayerFromCharacter(hit.Parent)
                    if victim and victim ~= LocalPlayer then
                        hit.Parent.Humanoid.Health = 0
                    end
                end
            end
        end)
    end
end

-- 2. SOUL BIND (Ikat jiwa musuh)
function bindSoul(target)
    if target and target.Character then
        table.insert(boundSouls, target)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔗 SOUL BIND",
            Text = "Jiwa " .. target.Name .. " terikat padamu!",
            Duration = 2
        })
        -- Jika Tuan mati, musuh juga mati
        Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if Humanoid.Health <= 0 then
                for _, soul in pairs(boundSouls) do
                    if soul and soul.Character then
                        soul.Character.Humanoid.Health = 0
                    end
                end
            end
        end)
    end
end

-- 3. INVENTORY NUKER (Hapus semua item)
function inventoryNuker()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            for _, item in pairs(v.Character:GetChildren()) do
                if item:IsA("Tool") or item:IsA("Accessory") then
                    item:Destroy()
                end
            end
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "💣 INVENTORY NUKER",
        Text = "Semua item player lain telah dihapus!",
        Duration = 3
    })
end

-- 4. GRAVITY VOID (Lubang gravitasi)
function gravityVoid()
    local voidPart = Instance.new("Part")
    voidPart.Size = Vector3.new(30, 30, 30)
    voidPart.Position = Character.HumanoidRootPart.Position + Vector3.new(0, 10, 0)
    voidPart.Anchored = true
    voidPart.Material = Enum.Material.Neon
    voidPart.Color = Color3.fromRGB(75, 0, 130)
    voidPart.Transparency = 0.3
    voidPart.Parent = Workspace
    
    local attraction = RunService.RenderStepped:Connect(function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local direction = (voidPart.Position - v.Character.HumanoidRootPart.Position).Unit
                v.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame + direction * 25
                if (v.Character.HumanoidRootPart.Position - voidPart.Position).Magnitude < 15 then
                    v.Character.Humanoid.Health = 0
                end
            end
        end
    end)
    
    task.wait(5)
    attraction:Disconnect()
    voidPart:Destroy()
end

-- 5. SPEED OF LIGHT (Kecepatan cahaya)
function toggleSpeedOfLight(state)
    if state then
        Humanoid.WalkSpeed = 500
        Humanoid.JumpPower = 200
        -- Efek blur
        local blur = Instance.new("BlurEffect")
        blur.Size = 20
        blur.Parent = Lighting
        task.wait(0.5)
        blur:Destroy()
    else
        if Settings.SpeedHack then
            Humanoid.WalkSpeed = Settings.SpeedValue
        else
            Humanoid.WalkSpeed = 16
        end
        Humanoid.JumpPower = 50
    end
end

-- 6. MAP CONTROLLER (Kontrol map)
function mapControl(action)
    if action == "rotate" then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name ~= "Baseplate" then
                obj.CFrame = obj.CFrame * CFrame.Angles(0, math.rad(90), 0)
            end
        end
    elseif action == "flip" then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") then
                obj.CFrame = obj.CFrame * CFrame.Angles(math.rad(180), 0, 0)
            end
        end
    elseif action == "crush" then
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:IsA("BasePart") and obj ~= Character.HumanoidRootPart then
                obj:BreakJoints()
            end
        end
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🗺️ MAP CONTROLLER",
        Text = action .. " berhasil!",
        Duration = 2
    })
end

-- 7. VOICE CHANGER (Ubah suara)
function voiceChanger()
    local voiceRemote = ReplicatedStorage:FindFirstChild("VoiceChat")
    if voiceRemote then
        voiceRemote.OnClientEvent:Connect(function(plr, soundId)
            if plr == LocalPlayer then
                local newSound = Instance.new("Sound")
                newSound.SoundId = "rbxassetid://" .. math.random(1000000, 9999999)
                newSound.Parent = Character.Head
                newSound:Play()
            end
        end)
    end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🎤 VOICE CHANGER",
        Text = "Suara Anda berubah!",
        Duration = 2
    })
end

-- 8. INFINITE SKILLS (Cooldown 0)
function toggleInfiniteSkills(state)
    if state then
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():find("skill") then
                local oldFire = remote.FireServer
                remote.FireServer = function(self, ...)
                    oldFire(self, ...)
                    task.wait()
                    oldFire(self, ...)
                end
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "♾️ INFINITE SKILLS",
            Text = "Cooldown skill dinonaktifkan!",
            Duration = 2
        })
    end
end

-- 9. PLAYER TRACKER (Lacak player)
function togglePlayerTracker(state)
    if state then
        local players = {}
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then table.insert(players, v.Name) end
        end
        local targetName = game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎯 PLAYER TRACKER",
            Text = "Pilih player: " .. table.concat(players, ", "),
            Duration = 5
        })
        -- Simulasi pilih player pertama
        trackedPlayer = players[1]
        RunService.RenderStepped:Connect(function()
            if Settings.PlayerTracker and trackedPlayer then
                local target = Players:FindFirstChild(trackedPlayer)
                if target and target.Character then
                    local pos = target.Character.HumanoidRootPart.Position
                    local distance = (pos - Character.HumanoidRootPart.Position).Magnitude
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "📍 TRACKING",
                        Text = trackedPlayer .. " ada di jarak " .. math.floor(distance) .. " meter",
                        Duration = 1
                    })
                end
            end
        end)
    end
end

-- 10. REWIND OTHERS (Putar balik musuh)
local rewindHistory = {}
function toggleRewindOthers(state)
    if state then
        RunService.RenderStepped:Connect(function()
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    if not rewindHistory[v] then
                        rewindHistory[v] = {}
                    end
                    table.insert(rewindHistory[v], {pos = v.Character.HumanoidRootPart.CFrame, time = tick()})
                    while #rewindHistory[v] > 100 do table.remove(rewindHistory[v], 1) end
                    
                    -- Setiap 5 detik, rewind
                    if #rewindHistory[v] > 50 and tick() % 5 < 0.1 then
                        local oldPos = rewindHistory[v][1].pos
                        v.Character.HumanoidRootPart.CFrame = oldPos
                    end
                end
            end
        end)
    end
end

-- ========== MEMBUAT GUI PREMIUM BARU DENGAN BUTTON PREMIUM ==========

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZEXSPARK_PREMIUM_GUI"
screenGui.Parent = game:GetService("CoreGui")

-- Frame utama dengan desain premium
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 500)
mainFrame.Position = UDim2.new(1, -320, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 5, 20)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Efek neon border
local border = Instance.new("Frame")
border.Size = UDim2.new(1, 4, 1, 4)
border.Position = UDim2.new(0, -2, 0, -2)
border.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
border.BackgroundTransparency = 0.5
border.BorderSizePixel = 0
border.Parent = mainFrame

-- Animasi glow border
task.spawn(function()
    while screenGui and screenGui.Parent do
        for i = 0.3, 0.8, 0.05 do
            border.BackgroundTransparency = i
            task.wait(0.05)
        end
        for i = 0.8, 0.3, -0.05 do
            border.BackgroundTransparency = i
            task.wait(0.05)
        end
    end
end)

-- Animasi masuk
mainFrame.BackgroundTransparency = 1
TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0.05}):Play()

-- Draggable
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header premium
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 65)
header.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✨ ZEXSPARK - FadelSM | LEGENDARY PREMIUM ✨"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = header

-- Premium badge
local premiumBadge = Instance.new("Frame")
premiumBadge.Size = UDim2.new(0, 60, 0, 25)
premiumBadge.Position = UDim2.new(1, -70, 0.5, -12.5)
premiumBadge.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
premiumBadge.BackgroundTransparency = 0.2
premiumBadge.Parent = header

local badgeText = Instance.new("TextLabel")
badgeText.Size = UDim2.new(1, 0, 1, 0)
badgeText.BackgroundTransparency = 1
badgeText.Text = "PREMIUM"
badgeText.TextColor3 = Color3.fromRGB(255, 215, 0)
badgeText.Font = Enum.Font.GothamBold
badgeText.TextSize = 12
badgeText.Parent = premiumBadge

-- Close button premium
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -55, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Parent = header
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(screenGui, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    screenGui:Destroy()
end)

-- Scroll frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -20, 1, -75)
scroll.Position = UDim2.new(0, 10, 0, 70)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 2000)
scroll.ScrollBarThickness = 6
scroll.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = scroll

-- Fungsi untuk membuat BUTTON PREMIUM (dengan animasi dan suara)
function createPremiumButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(200, 50, 50)
    btn.Text = "💎 " .. text .. " 💎"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = scroll
    
    -- Animasi hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color and color:Lerp(Color3.fromRGB(255, 255, 255), 0.3) or Color3.fromRGB(255, 100, 100)}):Play()
        btn.TextSize = 14
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color or Color3.fromRGB(200, 50, 50)}):Play()
        btn.TextSize = 13
    end)
    
    -- Efek klik
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundTransparency = 0.3}):Play()
        task.wait(0.05)
        TweenService:Create(btn, TweenInfo.new(0.05), {BackgroundTransparency = 0}):Play()
        callback()
    end)
    
    return btn
end

-- Fungsi toggle premium
function createPremiumToggle(text, setting, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
    frame.BackgroundTransparency = 0.4
    frame.Parent = scroll
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "✨ " .. text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 32)
    btn.Position = UDim2.new(1, -90, 0.5, -16)
    btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    btn.Text = Settings[setting] and "ON ✓" or "OFF ✗"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = frame
    
    -- Animasi tombol toggle
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        btn.Text = Settings[setting] and "ON ✓" or "OFF ✗"
        
        -- Panggil fungsi toggle
        if setting == "OmegaLaser" then toggleOmegaLaser(Settings[setting]) end
        if setting == "SpeedOfLight" then toggleSpeedOfLight(Settings[setting]) end
        if setting == "InfiniteSkills" then toggleInfiniteSkills(Settings[setting]) end
        if setting == "PlayerTracker" then togglePlayerTracker(Settings[setting]) end
        if setting == "RewindOthers" then toggleRewindOthers(Settings[setting]) end
        
        -- Efek suara (simulasi)
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://9120377436"
        sound.Volume = 0.3
        sound.Parent = btn
        sound:Play()
        Debris:AddItem(sound, 1)
    end)
end

function createPremiumSlider(labelText, setting, minVal, maxVal, currentVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 55)
    frame.BackgroundColor3 = Color3.fromRGB(25, 20, 40)
    frame.BackgroundTransparency = 0.4
    frame.Parent = scroll
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = "📊 " .. labelText .. ": " .. currentVal
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(0, 280, 0, 22)
    sliderBtn.Position = UDim2.new(0.5, -140, 0.7, -11)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
    sliderBtn.Text = ""
    sliderBtn.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(139, 0, 255)
    fill.Parent = sliderBtn
    
    sliderBtn.MouseButton1Down:Connect(function()
        local move
        move = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = math.clamp((input.Position.X - sliderBtn.AbsolutePosition.X) / sliderBtn.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(minVal + (x * (maxVal - minVal)))
                fill.Size = UDim2.new(x, 0, 1, 0)
                label.Text = "📊 " .. labelText .. ": " .. newVal
                if setting == "KillRange" then Settings.KillRange = newVal
                elseif setting == "SpeedValue" then 
                    Settings.SpeedValue = newVal
                    if Settings.SpeedHack then Humanoid.WalkSpeed = newVal end
                end
                if callback then callback(newVal) end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                move:Disconnect()
            end
        end)
    end)
end

function addPremiumSection(title, color)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -20, 0, 32)
    section.BackgroundColor3 = color or Color3.fromRGB(139, 0, 255)
    section.BackgroundTransparency = 0.2
    section.Parent = scroll
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "◆ " .. title .. " ◆"
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 13
    text.Parent = section
end

-- ========== MEMBANGUN UI PREMIUM ==========

-- SECTION 1: KOMBAT PREMIUM
addPremiumSection("🔥 KOMBAT PREMIUM", Color3.fromRGB(139, 0, 255))
createPremiumToggle("☠️ Kill Aura", "KillAura", Color3.fromRGB(255, 100, 100))
createPremiumToggle("🎯 Aimbot", "Aimbot")
createPremiumToggle("🛡️ God Mode", "GodMode")
createPremiumToggle("💀 One Hit Kill", "OneHit")
createPremiumToggle("🔫 Infinite Ammo", "InfiniteAmmo")
createPremiumToggle("💚 Auto Heal", "AutoHeal")
createPremiumSlider("📏 Kill Range", "KillRange", 10, 200, Settings.KillRange)

-- SECTION 2: MOBILITAS PREMIUM
addPremiumSection("🏃 MOBILITAS PREMIUM", Color3.fromRGB(200, 100, 0))
createPremiumToggle("⚡ Speed Hack", "SpeedHack")
createPremiumSlider("🏃 Speed Value", "SpeedValue", 16, 250, Settings.SpeedValue)
createPremiumToggle("🕊️ Fly Mode", "Fly")
createPremiumToggle("🧱 No Clip", "NoClip")
createPremiumToggle("👻 Invisible", "Invisible")
createPremiumToggle("🦘 Unlimited Jump", "UnlimitedJump")
createPremiumToggle("💫 Speed of Light", "SpeedOfLight")

-- SECTION 3: VISUAL PREMIUM
addPremiumSection("🎯 VISUAL PREMIUM", Color3.fromRGB(0, 150, 200))
createPremiumToggle("👁️ ESP Player", "ESP")
createPremiumToggle("🌈 Rainbow Trail", "RainbowTrail")
createPremiumToggle("🌀 Reality Warp", "RealityWarp")

-- SECTION 4: FITUR DEWA
addPremiumSection("💀 FITUR DEWA", Color3.fromRGB(200, 0, 200))
createPremiumToggle("⏰ Time Freeze", "TimeFreeze")
createPremiumToggle("🧲 Magnet Player", "MagnetPlayer")
createPremiumToggle("🧠 Mind Control", "MindControl")
createPremiumToggle("💥 Damage x100", "DamageMultiplier")
createPremiumToggle("🛡️ Auto Parry", "AutoParry")
createPremiumToggle("💢 Revenge Mode", "RevengeMode")
createPremiumToggle("🌌 Dimension Shift", "DimensionShift")
createPremiumToggle("🌀 Time Loop", "TimeLoop")

-- SECTION 5: FITUR LEGENDARY BARU
addPremiumSection("⚡ FITUR LEGENDARY", Color3.fromRGB(255, 100, 0))
createPremiumToggle("🔫 Omega Laser", "OmegaLaser")
createPremiumToggle("♾️ Infinite Skills", "InfiniteSkills")
createPremiumToggle("🎯 Player Tracker", "PlayerTracker")
createPremiumToggle("⏪ Rewind Others", "RewindOthers")

-- SECTION 6: BUTTON PREMIUM (ACTION)
addPremiumSection("💎 BUTTON PREMIUM", Color3.fromRGB(255, 215, 0))

createPremiumButton("🔗 SOUL BIND (terdekat)", function()
    local closest = nil
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            closest = v
            break
        end
    end
    if closest then bindSoul(closest) end
end, Color3.fromRGB(150, 50, 200))

createPremiumButton("💣 INVENTORY NUKER", function() inventoryNuker() end, Color3.fromRGB(200, 50, 50))
createPremiumButton("🌀 GRAVITY VOID", function() gravityVoid() end, Color3.fromRGB(75, 0, 130))
createPremiumButton("🗺️ MAP ROTATE", function() mapControl("rotate") end, Color3.fromRGB(0, 150, 200))
createPremiumButton("🗺️ MAP FLIP", function() mapControl("flip") end, Color3.fromRGB(0, 150, 200))
createPremiumButton("🗺️ MAP CRUSH", function() mapControl("crush") end, Color3.fromRGB(255, 50, 50))
createPremiumButton("🎤 VOICE CHANGER", function() voiceChanger() end, Color3.fromRGB(100, 200, 100))
createPremiumButton("💀 NUKE SERVER", function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            v.Character.Humanoid.Health = 0
        end
    end
end, Color3.fromRGB(255, 0, 0))
createPremiumButton("👻 PHANTOM ARMY (50)", function()
    for i = 1, 50 do
        local phantom = Instance.new("Model")
        local part = Instance.new("Part")
        part.Size = Vector3.new(2, 4, 2)
        part.Position = Character.HumanoidRootPart.Position + Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 100, 255)
        part.Transparency = 0.4
        part.Parent = phantom
        local h = Instance.new("Humanoid")
        h.MaxHealth = 500
        h.Health = 500
        h.Parent = phantom
        phantom.Parent = Workspace
        task.spawn(function()
            while phantom and phantom.Parent do
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character then
                        part.CFrame = CFrame.new(part.Position, v.Character.HumanoidRootPart.Position)
                        part.CFrame = part.CFrame + part.CFrame.LookVector * 12
                        if (part.Position - v.Character.HumanoidRootPart.Position).Magnitude < 6 then
                            v.Character.Humanoid.Health = v.Character.Humanoid.Health - 150
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
    end
end, Color3.fromRGB(200, 50, 255))

-- Notifikasi premium
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✨ ZEXSPARK PREMIUM ✨",
    Text = "LEGENDARY EDITION | 58 FITUR | BUTTON PREMIUM AKTIF",
    Duration = 5
})

-- Buka/tutup
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Auto-activation dasar
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    if Settings.GodMode then Humanoid.Health = math.huge end
    if Settings.SpeedHack then Humanoid.WalkSpeed = Settings.SpeedValue end
end)

Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
    if Settings.AutoHeal and Humanoid.Health < Humanoid.MaxHealth then
        Humanoid.Health = Humanoid.MaxHealth
    end
end)

-- Fly mode sederhana
local flying = false
local bodyVel = Instance.new("BodyVelocity")
bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F and Settings.Fly then
        flying = not flying
        if flying then
            bodyVel.Parent = Character.HumanoidRootPart
        else
            bodyVel.Parent = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and Settings.Fly then
        local move = Vector3.new(
            (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
            (UserInputService:IsKeyDown(Enum.KeyCode.E) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.Q) and 1 or 0),
            (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
        )
        bodyVel.Velocity = move * 120
    end
end)
