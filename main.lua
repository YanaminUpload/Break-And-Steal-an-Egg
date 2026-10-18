-- 1. Tunggu game selesai loading penuh
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local startPlaceId = game.PlaceId

-- ==================== [ GUI USERNAME AKUN ] ====================
local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccountInfoGui"
screenGui.ResetOnSpawn = false

local player = Players.LocalPlayer 
local myUserId = player.UserId
local myUsername = player.Name

local suksesGui, errGui = pcall(function()
    screenGui.Parent = CoreGui
end)
if not suksesGui then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 50)
frame.Position = UDim2.new(0.5, -125, 0.5, -25)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.2
frame.Parent = screenGui

pcall(function()
    GuiService.MenuOpened:Connect(function()
        screenGui.Enabled = false
    end)
    GuiService.MenuClosed:Connect(function()
        screenGui.Enabled = true
    end)
end)

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -40, 1, 0)
label.Position = UDim2.new(0, 10, 0, 0)
label.BackgroundTransparency = 1
label.Text = "Account: " .. myUsername
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.SourceSansBold
label.TextSize = 18
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 25, 0, 25)
toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.Text = "-"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local invisibleClicker = Instance.new("TextButton")
invisibleClicker.Size = UDim2.new(1, 0, 1, 0)
invisibleClicker.BackgroundTransparency = 1
invisibleClicker.Text = ""
invisibleClicker.Visible = false
invisibleClicker.Parent = frame

local isMinimized = false

toggleBtn.MouseButton1Click:Connect(function()
    if not isMinimized then
        isMinimized = true
        toggleBtn.Visible = false
        label.Visible = false
        frame:TweenSize(UDim2.new(0, 50, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.3)
        invisibleClicker.Visible = true
    end
end)

invisibleClicker.MouseButton1Click:Connect(function()
    if isMinimized then
        isMinimized = false
        invisibleClicker.Visible = false
        frame:TweenSize(UDim2.new(0, 250, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
        task.wait(0.15)
        label.Visible = true
        toggleBtn.Position = UDim2.new(1, -35, 0.5, -12.5)
        toggleBtn.Text = "-"
        toggleBtn.Visible = true
    end
end)

print("[MELOAD] Loaded - treadmill + reconnect + GUI aktif (HP & PC Fix)")

-- Variabel Kontrol untuk Fitur Auto Reconnect
local autoReconnectEnabled = true
local isReconnecting = false

-- ==================== [ FUNGSI AUTO RECONNECT ] ====================

local function handleReconnect(reason)
    if isReconnecting or not autoReconnectEnabled then
        return
    end

    isReconnecting = true
    warn("[AutoReconnect]", reason)

    pcall(function()
        if #Players:GetPlayers() <= 1 then
            pcall(function() LocalPlayer:Kick("\nRejoining...") end)
        end
        TeleportService:Teleport(startPlaceId, LocalPlayer)
    end)
    isReconnecting = false
end

pcall(function()
    if GuiService then
        GuiService.ErrorMessageChanged:Connect(function(msg)
            if not autoReconnectEnabled or isReconnecting then
                return
            end

            msg = tostring(msg):lower()

            if #msg == 0
            or msg:find("729")
            or msg:find("277")
            or msg:find("disconnect")
            or msg:find("internet")
            or msg:find("connection")
            or msg:find("datastore")
            or msg:find("lock")
            or msg:find("locklost")
            or msg:find("lost")
            or msg:find("ownership")
            or msg:find("network")
            or msg:find("shut")
            or msg:find("closed")
            or msg:find("kicked")
            or msg:find("maintenance")
            or msg:find("update")
            or msg:find("769")
            or msg:find("536")
            or msg:find("522")
            or msg:find("273") then
                handleReconnect("Connection Error Detected")
            end
        end)
    end
end)

-- ==================== [ FUNGSI KAVLING BASE ] ====================

local function findMyOwnPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return nil end

    local expected = {
        [LocalPlayer.DisplayName:lower():gsub("%s+", "")] = true,
        [LocalPlayer.Name:lower():gsub("%s+", "")] = true,
    }
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        for _, object in ipairs(plot:GetDescendants()) do
            if object.Name == "PlayerName" and object:IsA("TextLabel") then
                local name = object.Text:lower():gsub("%s+", "")
                if expected[name] then return plot end
            end
        end
    end
    return nil
end
-- ==================== [ FUNGSI UTAMA TREADMILL ] ====================

local function requestEquip()
    task.wait(1)
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then return end

    local plotSaya, nomorPlotSaya
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local ownerId = plot:GetAttribute("OwnerUserId")
        if ownerId and tonumber(ownerId) == LocalPlayer.UserId then
            plotSaya = plot
            local nomorStr = plot.Name:match("%d+")
            nomorPlotSaya = nomorStr and tonumber(nomorStr)
            break
        end
    end
    if not plotSaya or not nomorPlotSaya then return end

    local treadmill
    for _, object in ipairs(plotSaya:GetDescendants()) do
        local name = object.Name:lower()
        if name:find("treadmill", 1, true) and not name:find("board", 1, true) and not name:find("gui", 1, true) then
            treadmill = object
            break
        end
    end
    if not treadmill then return end

    local targetPart
    if treadmill:IsA("BasePart") then
        targetPart = treadmill
    elseif treadmill:IsA("Model") then
        targetPart = treadmill.PrimaryPart or treadmill:FindFirstChild("Hitbox", true) or treadmill:FindFirstChildWhichIsA("BasePart", true)
    else
        targetPart = treadmill:FindFirstChild("Hitbox", true) or treadmill:FindFirstChildWhichIsA("BasePart", true)
    end
    if not targetPart or not targetPart:IsA("BasePart") then return end

    local cframeTreadmill = targetPart.CFrame
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then rootPart.CFrame = cframeTreadmill * CFrame.new(0, 2, 0) end

    local remote = ReplicatedStorage:FindFirstChild("TreadmillSessionRemote")
    if remote and remote:IsA("RemoteEvent") and firesignal then
        pcall(function()
            firesignal(remote.OnClientEvent, nomorPlotSaya, cframeTreadmill)
        end)
    end
end
-- ==================== [ ANTI-AFK INTERNAL ] ====================

local function setupSafeAntiAFK()
    if getconnections then
        for _, c in getconnections(LocalPlayer.Idled) do
            pcall(function() c:Disable() end)
            pcall(function() c:Disconnect() end)
        end
    end

    LocalPlayer.Idled:Connect(function()
        pcall(function()
            local VirtualInputManager = Instance.new("VirtualInputManager")
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            VirtualInputManager:Destroy()
        end)
    end)
end

-- ==================== [ EKSEKUSI UTAMA ] ====================
setupSafeAntiAFK()

task.spawn(requestEquip)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(5) 
    requestEquip()
end)

-- Auto upgrade khusus game breaksae.
local priceLabel = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("TreadmillBoardGui"):WaitForChild("Purchase"):WaitForChild("Price")
local upgradeRemote = ReplicatedStorage:WaitForChild("UpgradeTreadmillRequest")
local lastAttemptPrice = nil

local function dapatkanHargaAsli()
    local teks = priceLabel.Text:gsub("[%$%,%s]", "")
    local angka = tonumber(teks:match("[%d%.]+"))
    if not angka then return 0 end
    local sufiks = teks:match("([kKmMbBtT])$")
    local multiplier = ({ k = 1e3, m = 1e6, b = 1e9, t = 1e12 })[(sufiks or ""):lower()] or 1
    return angka * multiplier
end

task.spawn(function()
    while task.wait(1) do
        local hargaUpgrade = dapatkanHargaAsli()
        local uangGua = tonumber(LocalPlayer:GetAttribute("Cash")) or 0
        if hargaUpgrade > 0 and uangGua >= hargaUpgrade and lastAttemptPrice ~= hargaUpgrade then
            lastAttemptPrice = hargaUpgrade
            local ok = pcall(function()
                upgradeRemote:FireServer()
            end)
            if ok then task.delay(1, requestEquip) end
        end
    end
end)

