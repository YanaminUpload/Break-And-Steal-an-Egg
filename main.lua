local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer 
local myUserId = player.UserId
local myUsername = player.Name

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AccountDisplayGui"
screenGui.ResetOnSpawn = false

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

local plotsFolder = workspace.Plots
local plotSaya = nil
local nomorPlotSaya = nil

for _, plot in ipairs(plotsFolder:GetChildren()) do
    local ownerId = plot:GetAttribute("OwnerUserId")
    if ownerId and tonumber(ownerId) == myUserId then
        plotSaya = plot
        local nomorStr = plot.Name:match("%d+")
        if nomorStr then
            nomorPlotSaya = tonumber(nomorStr)
        end
        break
    end
end

if plotSaya and nomorPlotSaya then
    local function eksekusiTreadmill()
        local treadmill = nil
        for _, child in ipairs(plotSaya:GetDescendants()) do
            if child.Name:match("Treadmill") and not child.Name:match("Board") and not child.Name:match("Gui") then
                treadmill = child
                break
            end
        end

        if not treadmill then return end

        local targetPart = treadmill:IsA("Model") and (treadmill.PrimaryPart or treadmill:FindFirstChild("Hitbox") or treadmill:FindFirstChildWhichIsA("BasePart")) or treadmill
        if not targetPart then return end

        local cframeTreadmill = targetPart.CFrame

        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = cframeTreadmill * CFrame.new(0, 2, 0)
        end

        firesignal(ReplicatedStorage.TreadmillSessionRemote.OnClientEvent, nomorPlotSaya, cframeTreadmill)
    end

    eksekusiTreadmill()

    local priceLabel = player:WaitForChild("PlayerGui"):WaitForChild("TreadmillBoardGui"):WaitForChild("Purchase"):WaitForChild("Price")
    local upgradeRemote = ReplicatedStorage:WaitForChild("UpgradeTreadmillRequest")

    local function dapatkanHargaAsli()
        local teks = priceLabel.Text:gsub("[%$%,]", "")
        local angkaMurni = tonumber(teks:match("[%d%.]+"))
        
        if not angkaMurni then return 0 end
        
        local sufiks = teks:match("%a")
        if sufiks then
            sufiks = sufiks:lower()
            if sufiks == "k" then angkaMurni = angkaMurni * 1000
            elseif sufiks == "m" then angkaMurni = angkaMurni * 1000000
            elseif sufiks == "b" then angkaMurni = angkaMurni * 1000000000
            elseif sufiks == "t" then angkaMurni = angkaMurni * 1000000000000
            end
        end
        return angkaMurni
    end

    local function dapatkanUangMurni()
        return player:GetAttribute("Cash") or 0
    end

    task.spawn(function()
        while task.wait(1) do
            local hargaUpgrade = dapatkanHargaAsli()
            local uangGua = dapatkanUangMurni()
            
            if hargaUpgrade > 0 and uangGua >= hargaUpgrade then
                upgradeRemote:FireServer()
                task.wait(0.5)
                eksekusiTreadmill()
            end
        end
    end)
end

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

setupSafeAntiAFK()
