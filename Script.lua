-- ====================================================================
-- SCRIPT BERMALAM BERSAMA OPAH (ADVANCED UTILITY V2 - FIXED)
-- Fitur: ESP Kunci, ESP Kode Kertas, TP Kunci, TP Lock_1 & Auto-Collect
-- ====================================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Fungsi membuat ESP Visual Text Box
local function buatESP(objek, teks, warna)
    if not objek then return end
    if objek:FindFirstChild("ESP_Highlight") then return end

    -- Buat Box Sorot (Highlight)
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_Highlight"
    hl.FillColor = warna
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.OutlineTransparency = 0
    hl.Adornee = objek
    hl.Parent = objek

    -- Buat Label Teks di Atas Objek
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_Label"
    bb.Size = UDim2.new(0, 100, 0, 30)
    bb.AlwaysOnTop = true
    bb.PlayerToHideFrom = nil
    bb.Adornee = objek
    
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = teks
    tl.TextColor3 = warna
    tl.TextSize = 14
    tl.Font = Enum.Font.SourceSansBold
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    tl.Parent = bb
    
    bb.Parent = objek
end

-- ==========================================
-- 1. AKTIFKAN ESP KEY DAN ESP KERTAS KODE
-- ==========================================
local function aktifkanESP()
    -- ESP Kunci (Sesuai folder PuzzleItems)
    local puzzleItems = Workspace:FindFirstChild("PuzzleItems")
    if puzzleItems then
        for _, item in pairs(puzzleItems:GetChildren()) do
            if item.Name == "Key" then
                buatESP(item, "🔑 Kunci", Color3.fromRGB(255, 215, 0))
            end
        end
    end

    -- ESP Kertas Catatan Kode (Sesuai folder PasscodeNote)
    for _, item in pairs(Workspace:GetChildren()) do
        if item.Name == "PasscodeNote" then
            buatESP(item, "📜 Kertas Kode", Color3.fromRGB(255, 50, 50))
        elseif item:IsA("Model") and item:FindFirstChild("PasscodeNote") then
            buatESP(item.PasscodeNote, "📜 Kertas Kode", Color3.fromRGB(255, 50, 50))
        end
    end
end

-- ==========================================
-- 2. FITUR TELEPORTASI KUNCI (DEKAT & JAUH - FIXED)
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
            -- Deteksi posisi objek tanpa terhambat pengecekan tipe Model
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
            -- Memicu interaksi klik jarak jauh pada tombol puzzle kunci
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
-- 4. FITUR TELEPORTASI KE LOCK_1
-- ==========================================
local function tpKeLock1()
    local karakter = LocalPlayer.Character
    if not karakter or not karakter:FindFirstChild("HumanoidRootPart") then return end
    
    local puzzleLocks = Workspace:FindFirstChild("PuzzleLocks")
    local lock1 = puzzleLocks and puzzleLocks:FindFirstChild("Lock_1")
    
    if lock1 then
        local partLock = lock1:IsA("BasePart") and lock1 or lock1:FindFirstChildWhichIsA("BasePart") or lock1:FindFirstChild("Padlock")
        if partLock then
            karakter.HumanoidRootPart.CFrame = partLock.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- ==========================================
-- CREATING ADVANCED CONTROL GUI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OpahHelperGUI"
ScreenGui.ResetOnSpawn = false -- GUI tidak hilang walau karakter reset/mati
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 230)
Frame.Position = UDim2.new(0.1, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "Opah Helper Mod v2"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = Frame

local btnESP = Instance.new("TextButton")
btnESP.Size = UDim2.new(0.9, 0, 0, 30)
btnESP.Position = UDim2.new(0.05, 0, 0.18, 0)
btnESP.Text = "Aktifkan ESP (Kunci/Kode)"
btnESP.Parent = Frame
btnESP.MouseButton1Click:Connect(aktifkanESP)

local btnCollect = Instance.new("TextButton")
btnCollect.Size = UDim2.new(0.9, 0, 0, 30)
btnCollect.Position = UDim2.new(0.05, 0, 0.34, 0)
btnCollect.Text = "⚡ Ambil Semua Kunci (Auto)"
btnCollect.BackgroundColor3 = Color3.fromRGB(139, 0, 0)
btnCollect.Parent = Frame
btnCollect.MouseButton1Click:Connect(autoCollectKunci)

local btnTPDekat = Instance.new("TextButton")
btnTPDekat.Size = UDim2.new(0.9, 0, 0, 30)
btnTPDekat.Position = UDim2.new(0.05, 0, 0.50, 0)
btnTPDekat.Text = "TP Kunci Terdekat"
btnTPDekat.Parent = Frame
btnTPDekat.MouseButton1Click:Connect(function() tpKeKunci(true) end)

local btnTPJauh = Instance.new("TextButton")
btnTPJauh.Size = UDim2.new(0.9, 0, 0, 30)
btnTPJauh.Position = UDim2.new(0.05, 0, 0.66, 0)
btnTPJauh.Text = "TP Kunci Terjauh"
btnTPJauh.Parent = Frame
btnTPJauh.MouseButton1Click:Connect(function() tpKeKunci(false) end)

local btnTPLock1 = Instance.new("TextButton")
btnTPLock1.Size = UDim2.new(0.9, 0, 0, 30)
btnTPLock1.Position = UDim2.new(0.05, 0, 0.82, 0)
btnTPLock1.Text = "TP Ke Tempat Lock 1"
btnTPLock1.Parent = Frame
btnTPLock1.MouseButton1Click:Connect(tpKeLock1)

for _, b in pairs(Frame:GetChildren()) do
    if b:IsA("TextButton") then
        if b.BackgroundColor3 == Color3.fromRGB(253, 253, 253) or b.BackgroundColor3 == Color3.fromRGB(0,0,0) then
            b.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
        end
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.SourceSansBold
        b.TextSize = 14
    end
end
