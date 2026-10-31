-- ============================================================
-- Mahito UI (Purple) + Botão Flutuante de Chama Roxa
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Variáveis de Controle
local state = {
    Noclip = false,
    Bypass = false,
    SweepAll = false,
}
local CONFIG = { SweepTime = 0.01 }
local resetCount = 0

-- Notificação
local function notify(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3
        })
    end)
end

-- ============================================================
-- LÓGICA DO SCRIPT (NOS BASTIDORES)
-- ============================================================

-- 1. Noclip
RunService.Stepped:Connect(function()
    if state.Noclip and localPlayer.Character then
        for _, part in ipairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 2. Bypass
task.spawn(function()
    while true do
        task.wait(0.5)
        if state.Bypass then
            local character = localPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            if hrp and humanoid and humanoid.Health > 0 then  
                local targets = {}
                for _, p in ipairs(Players:GetPlayers()) do  
                    if p ~= localPlayer and p.Character then  
                        local h = p.Character:FindFirstChildOfClass("Humanoid")  
                        local r = p.Character:FindFirstChild("HumanoidRootPart")  
                        if h and h.Health > 0 and r and (r.Position - hrp.Position).Magnitude <= 500 then 
                            table.insert(targets, h) 
                        end  
                    end  
                end  
                for _, obj in ipairs(Workspace:GetDescendants()) do  
                    if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then  
                        local h = obj:FindFirstChildOfClass("Humanoid")  
                        local r = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")  
                        if h and h.Health > 0 and r and (r.Position - hrp.Position).Magnitude <= 500 then 
                            table.insert(targets, h) 
                        end  
                    end  
                end  

                if #targets > 0 then
                    local targetHumanoid = targets[math.random(1, #targets)]
                    local targetHRP = targetHumanoid.Parent:FindFirstChild("HumanoidRootPart") or targetHumanoid.Parent:FindFirstChild("Torso")

                    if targetHRP then  
                        local startPos = hrp.Position  
                        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)  
                        local teleportedBack = false  
                        local timer = 0  
                        while timer < 3 do  
                            task.wait(0.1)  
                            timer = timer + 0.1  
                            if not state.Bypass or not humanoid or humanoid.Health <= 0 then break end  
                            if (hrp.Position - startPos).Magnitude < 10 then  
                                teleportedBack = true  
                                break  
                            end  
                        end  
                        if state.Bypass and humanoid and humanoid.Health > 0 and teleportedBack then  
                            local resetRemote = ReplicatedStorage:FindFirstChild("Knit")  
                                and ReplicatedStorage.Knit:FindFirstChild("Knit")  
                                and ReplicatedStorage.Knit.Knit:FindFirstChild("Services")  
                                and ReplicatedStorage.Knit.Knit.Services:FindFirstChild("JoinService")  
                                and ReplicatedStorage.Knit.Knit.Services.JoinService:FindFirstChild("RE")  
                                and ReplicatedStorage.Knit.Knit.Services.JoinService.RE:FindFirstChild("Reset")  
                            while state.Bypass and humanoid and humanoid.Health > 0 do  
                                if resetRemote then  
                                    resetRemote:FireServer()  
                                    resetCount = resetCount + 1  
                                end  
                                task.wait(3)  
                            end  
                        end  
                    end  
                end
            end  
        end
    end
end)

-- 3. Sweep All
task.spawn(function()
    while true do
        task.wait(0.01)
        if state.SweepAll then
            local myChar = localPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            local humanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

            if myHRP and humanoid and humanoid.Health > 0 then  
                local targets = {}  
                for _, p in ipairs(Players:GetPlayers()) do  
                    if p ~= localPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then  
                        local hrp = p.Character.HumanoidRootPart  
                        if (hrp.Position - myHRP.Position).Magnitude <= 500 then table.insert(targets, hrp) end  
                    end  
                end  
                for _, obj in ipairs(Workspace:GetDescendants()) do  
                    if obj:IsA("Model") and string.lower(obj.Name) == "dummy" then  
                        local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")  
                        if hrp and (hrp.Position - myHRP.Position).Magnitude <= 500 then table.insert(targets, hrp) end  
                    end  
                end  
                for _, targetHRP in ipairs(targets) do  
                    if not state.SweepAll or not humanoid or humanoid.Health <= 0 then break end  
                    if myHRP and targetHRP and targetHRP.Parent then  
                        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2.5)  
                        task.wait(CONFIG.SweepTime)  
                    end  
                end  
            end  
        end
    end
end)

-- ============================================================
-- INTERFACE MAHITO (PRETO E VERMELHO)
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MahitoUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local RED = Color3.fromRGB(104, 147, 252)
local DARK_RED = Color3.fromRGB(35, 62, 125)
local BLACK = Color3.fromRGB(8, 8, 10)
local WHITE = Color3.fromRGB(245, 245, 245)
local GRAY = Color3.fromRGB(155, 155, 160)

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 310)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -155)
MainFrame.BackgroundColor3 = BLACK
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = RED
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Cabeçalho
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundColor3 = Color3.fromRGB(10, 15, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -105, 0, 27)
Title.Position = UDim2.new(0, 16, 0, 7)
Title.BackgroundTransparency = 1
Title.Text = "MAHITO"
Title.TextColor3 = WHITE
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TopBar

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -105, 0, 20)
Subtitle.Position = UDim2.new(0, 16, 0, 31)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Farm ult | painel"
Subtitle.TextColor3 = GRAY
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.Parent = TopBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 34, 0, 32)
MinBtn.Position = UDim2.new(1, -79, 0, 13)
MinBtn.BackgroundColor3 = BLACK
MinBtn.Text = "-"
MinBtn.TextColor3 = WHITE
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)
local MinStroke = Instance.new("UIStroke")
MinStroke.Color = DARK_RED
MinStroke.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 32)
CloseBtn.Position = UDim2.new(1, -39, 0, 13)
CloseBtn.BackgroundColor3 = BLACK
CloseBtn.Text = "X"
CloseBtn.TextColor3 = WHITE
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = DARK_RED
CloseStroke.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Indicador de estado
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -28, 0, 48)
StatusFrame.Position = UDim2.new(0, 14, 0, 70)
StatusFrame.BackgroundColor3 = Color3.fromRGB(12, 18, 34)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = MainFrame
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 5)
local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = DARK_RED
StatusStroke.Parent = StatusFrame

local StatusDot = Instance.new("TextLabel")
StatusDot.Size = UDim2.new(0, 34, 1, 0)
StatusDot.Position = UDim2.new(0, 10, 0, 0)
StatusDot.BackgroundTransparency = 1
StatusDot.Text = "●"
StatusDot.TextColor3 = RED
StatusDot.Font = Enum.Font.GothamBold
StatusDot.TextSize = 20
StatusDot.Parent = StatusFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -55, 1, 0)
StatusText.Position = UDim2.new(0, 48, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "SYSTEM INACTIVE"
StatusText.TextColor3 = RED
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Font = Enum.Font.GothamBold
StatusText.TextSize = 15
StatusText.Parent = StatusFrame

-- Botão principal FARM ULT (usa a função Sweep All já existente)
local FarmBtn = Instance.new("TextButton")
FarmBtn.Size = UDim2.new(1, -28, 0, 78)
FarmBtn.Position = UDim2.new(0, 14, 0, 130)
FarmBtn.BackgroundColor3 = Color3.fromRGB(13, 22, 48)
FarmBtn.BorderSizePixel = 0
FarmBtn.Text = "FARM ULT"
FarmBtn.TextColor3 = RED
FarmBtn.Font = Enum.Font.GothamBlack
FarmBtn.TextSize = 25
FarmBtn.Parent = MainFrame
Instance.new("UICorner", FarmBtn).CornerRadius = UDim.new(0, 5)
local FarmStroke = Instance.new("UIStroke")
FarmStroke.Color = RED
FarmStroke.Thickness = 1.5
FarmStroke.Parent = FarmBtn

FarmBtn.MouseButton1Click:Connect(function()
    state.SweepAll = not state.SweepAll
    FarmBtn.Text = state.SweepAll and "FARM ULT: ON" or "FARM ULT"
    FarmBtn.TextColor3 = state.SweepAll and WHITE or RED
    StatusText.Text = state.SweepAll and "SYSTEM ACTIVE" or "SYSTEM INACTIVE"
    StatusDot.TextColor3 = state.SweepAll and Color3.fromRGB(60, 255, 90) or RED
end)

-- Botões auxiliares
local function createScriptButton(text, xPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -21, 0, 42)
    btn.Position = UDim2.new(0, xPos, 0, 222)
    btn.BackgroundColor3 = Color3.fromRGB(12, 18, 36)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = WHITE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    local stroke = Instance.new("UIStroke")
    stroke.Color = DARK_RED
    stroke.Parent = btn
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
end

createScriptButton("BYPASS: OFF", 14, function(btn)
    state.Bypass = not state.Bypass
    btn.Text = state.Bypass and "BYPASS: ON" or "BYPASS: OFF"
    btn.TextColor3 = state.Bypass and RED or WHITE
end)

createScriptButton("NOCLIP: OFF", 185, function(btn)
    state.Noclip = not state.Noclip
    btn.Text = state.Noclip and "NOCLIP: ON" or "NOCLIP: OFF"
    btn.TextColor3 = state.Noclip and RED or WHITE
end)

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -20, 0, 22)
Footer.Position = UDim2.new(0, 10, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "MAHITO"
Footer.TextColor3 = GRAY
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 11
Footer.Parent = MainFrame

-- Minimizar e restaurar
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    StatusFrame.Visible = not minimized
    FarmBtn.Visible = not minimized
    Footer.Visible = not minimized
    for _, obj in ipairs(MainFrame:GetChildren()) do
        if obj:IsA("TextButton") and obj ~= MinBtn and obj ~= CloseBtn then
            if obj ~= FarmBtn then obj.Visible = not minimized end
        end
    end
    MainFrame.Size = minimized and UDim2.new(0, 350, 0, 58) or UDim2.new(0, 350, 0, 310)
    MinBtn.Text = minimized and "+" or "-"
end)

-- Botão flutuante circular com M
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "MahitoFloatingButton"
FloatBtn.Size = UDim2.new(0, 54, 0, 54)
FloatBtn.Position = UDim2.new(0, 22, 0.5, -27)
FloatBtn.BackgroundColor3 = BLACK
FloatBtn.Text = "M"
FloatBtn.TextColor3 = RED
FloatBtn.TextSize = 25
FloatBtn.Font = Enum.Font.GothamBlack
FloatBtn.Active = true
FloatBtn.Draggable = true
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = RED
FloatStroke.Thickness = 2
FloatStroke.Parent = FloatBtn

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
