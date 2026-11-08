-- ====================================================================
-- SCRIPT BERMALAM BERSAMA OPAH (ADVANCED UTILITY V4 - CUSTOM EDITION)
-- Fitur: Advanced ESP Toggle, TP Kunci, Auto-Collect, & TP Player Spawn
-- ====================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Fungsi membuat ESP Visual Pintar (Sesuai Script Referensi)
local function createESP(obj, col, nm)
    if not obj then return end
    if not obj:FindFirstChild("ESPHighlight") then
        local hl = Instance.new("Highlight", obj)
        hl.Name = "ESPHighlight"
        hl.FillColor = col
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.new(1,1,1)
        hl.OutlineTransparency = 0
        
        local bb = Instance.new("BillboardGui", obj)
        bb.Name = "ESPText"
        bb.Size = UDim2.new(0,150,0,30)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0,3,0)
        
        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = nm
        lbl.TextColor3 = col
        lbl.TextSize = 14
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0,0,0)
    end
end

-- Fungsi menghapus ESP Visual Pintar
local function removeESP(obj)
    if not obj then return end
    if obj:FindFirstChild("ESPHighlight") then obj.ESPHighlight:Destroy() end
    if obj:FindFirstChild("ESPText") then obj.ESPText:Destroy() end
end

-- Status Toggle ESP
local espKunciAktif = false
local espKodeAktif = false

-- Fungsi Mengatur/Refresh ESP Kunci & Kode Catatan
local function refreshESP()
    -- Mengatur ESP Kunci (Folder PuzzleItems)
    local puzzleItems = Workspace:FindFirstChild("PuzzleItems")
    if puzzleItems then
        for _, item in pairs(puzzleItems:GetChildren()) do
            if item.Name == "Key" then
                if espKunciAktif then
                    createESP(item, Color3.new(1,1,0), "🔑 Kunci")
                else
                    removeESP(item)
                end
            end
        end
    end

    -- Mengatur ESP Kertas Catatan Kode (Folder PasscodeNote)
    for _, item in pairs(Workspace:GetChildren()) do
        if item.Name == "PasscodeNote" then
            if espKodeAktif then
                createESP(item, Color3.new(0,1,1), "📄 Catatan Kode")
            else
                removeESP(item)
            end
        elseif item:IsA("Model") and item:FindFirstChild("PasscodeNote") then
            if espKodeAktif then
                createESP(item.PasscodeNote, Color3.new(0,1,1), "📄 Catatan Kode")
            else
                removeESP(item.PasscodeNote)
            end
        end
    end
end

-- Loop Otomatis untuk memperbarui ESP jika ada item baru yang spawn
task.spawn(function()
    while true do
        task.wait(1)
        pcall(refreshESP)
    end
end)

-- ==========================================
-- 2. FITUR TELEPORTASI KUNCI (DEKAT & JAUH)
-- ==========================================
local function tpKeKunci(cariTerdekat)
    local karakter = LocalPlayer.Character
    if not karakter or not karakter:FindFirstChild("HumanoidRootPart") then return end
    
    local puzzleItems = Workspace:FindFirstChild("PuzzleItems")
    if not puzzleItems then return end
    
    local targetPart = nil
    local jarakTarget = cariTerdekat and math.huge or -math.huge
    local hrpPos = karakter.HumanoidRootPart.Position
    
    for _, item in pairs(puzzleItems:GetChildren()) do
        if item.Name == "Key" then
            local partKunci = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if partKunci then
                local jarak = (hrpPos - partKunci.Position).Magnitude
                if cariTerdekat then
                    if jarak < jarakTarget then
                        jarakTarget = jarak
                        targetPart = partKunci
                    end
                else
                    if jarak > jarakTarget then
                        jarakTarget = jarak
                        targetPart = partKunci
                    end
                end
            end
        end
    end
    
    if targetPart then
        karakter.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ==========================================
-- 3. FITUR AUTO-COLLECT / AMBIL KUNCI INSTAN
-- ==========================================
local function autoCollectKunci()
    local puzzleItems = Workspace:FindFirstChild("PuzzleItems")
    if not puzzleItems then return end
    
    for _, item in pairs(puzzleItems:GetChildren()) do
        if item.Name == "Key" then
            local clickDetector = item:FindFirstChild("PuzzleClick") or item:FindFirstChildWhichIsA("ClickDetector") or item:FindFirstChildWhichIsA("ProximityPrompt")
            
            if clickDetector then
                if clickDetector:IsA("ClickDetector") then
                    fireclickdetector(clickDetector)
                elseif clickDetector:IsA("ProximityPrompt") then
                    fireproximityprompt(clickDetector)
                end
            end
        end
    end
end

-- ==========================================
-- 4. FITUR TELEPORTASI KE PLAYER SPAWN (NEW)
-- ==========================================
local function tpKePlayerSpawn()
    local karakter = LocalPlayer.Character
    if not karakter or not karakter:FindFirstChild("HumanoidRootPart") then return end
    
    -- Mencari objek PlayerSpawn langsung di dalam Workspace (Sesuai Gambar Explorer)
    local playerSpawn = Workspace:FindFirstChild("PlayerSpawn")
    if playerSpawn and playerSpawn:IsA("BasePart") then
        karakter.HumanoidRootPart.CFrame = playerSpawn.CFrame + Vector3.new(0, 3, 0)
    end
end

-- ==========================================
-- CREATING ADVANCED CONTROL GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OpahHelperGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 260)
Frame.Position = UDim2.new(0.1, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Opah Helper Mod v4"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = Frame

-- Tombol 1: Toggle ESP Kunci
local btnESPKunci = Instance.new("TextButton")
btnESPKunci.Size = UDim2.new(0.9, 0, 0, 30)
btnESPKunci.Position = UDim2.new(0.05, 0, 0.16, 0)
btnESPKunci.Text = "Toggle ESP Kunci: OFF"
btnESPKunci.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
btnESPKunci.Parent = Frame
btnESPKunci.MouseButton1Click:Connect(function()
    espKunciAktif = not espKunciAktif
    btnESPKunci.Text = "Toggle ESP Kunci: " .. (espKunciAktif and "ON" or "OFF")
    btnESPKunci.BackgroundColor3 = espKunciAktif and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(50, 50, 60)
    refreshESP()
end)

-- Tombol 2: Toggle ESP Kertas Kode
local btnESPKode = Instance.new("TextButton")
btnESPKode.Size = UDim2.new(0.9, 0, 0, 30)
btnESPKode.Position = UDim2.new(0.05, 0, 0.30, 0)
btnESPKode.Text = "Toggle ESP Kode: OFF"
btnESPKode.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
btnESPKode.Parent = Frame
btnESPKode.MouseButton1Click:Connect(function()
    espKodeAktif = not espKodeAktif
    btnESPKode.Text = "Toggle ESP Kode: " .. (espKodeAktif and "ON" or "OFF")
    btnESPKode.BackgroundColor3 = espKodeAktif and Color3.fromRGB(50, 120, 150) or Color3.fromRGB(50, 50, 60)
    refreshESP()
end)

-- Tombol 3: Auto Collect Kunci
local btnCollect = Instance.new("TextButton")
btnCollect.Size = UDim2.new(0.9, 0, 0, 30)
btnCollect.Position = UDim2.new(0.05, 0, 0.44, 0)
btnCollect.Text = "⚡ Ambil Semua Kunci (Auto)"
btnCollect.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
btnCollect.Parent = Frame
btnCollect.MouseButton1Click:Connect(autoCollectKunci)

-- Tombol 4: TP Kunci Dekat
local btnTPDekat = Instance.new("TextButton")
btnTPDekat.Size = UDim2.new(0.9, 0, 0, 30)
btnTPDekat.Position = UDim2.new(0.05, 0, 0.58, 0)
btnTPDekat.Text = "TP Kunci Terdekat"
btnTPDekat.Parent = Frame
btnTPDekat.MouseButton1Click:Connect(function() tpKeKunci(true) end)

-- Tombol 5: TP Kunci Jauh
local btnTPJauh = Instance.new("TextButton")
btnTPJauh.Size = UDim2.new(0.9, 0, 0, 30)
btnTPJauh.Position = UDim2.new(0.05, 0, 0.72, 0)
btnTPJauh.Text = "TP Kunci Terjauh"
btnTPJauh.Parent = Frame
btnTPJauh.MouseButton1Click:Connect(function() tpKeKunci(false) end)

-- Tombol 6: TP Ke Player Spawn (Ganti dari Lock_1)
local btnTPSpawn = Instance.new("TextButton")
btnTPSpawn.Size = UDim2.new(0.9, 0, 0, 30)
btnTPSpawn.Position = UDim2.new(0.05, 0, 0.86, 0)
btnTPSpawn.Text = "🌀 TP ke Player Spawn"
btnTPSpawn.BackgroundColor3 = Color3.fromRGB(70, 50, 120)
btnTPSpawn.Parent = Frame
btnTPSpawn.MouseButton1Click:Connect(tpKePlayerSpawn)

-- Auto styling teks button
for _, b in pairs(Frame:GetChildren()) do
    if b:IsA("TextButton") then
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 14
        if b.BackgroundColor3 == Color3.fromRGB(253, 253, 253) or b.BackgroundColor3 == Color3.fromRGB(0,0,0) then
            b.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        end
    end
end
