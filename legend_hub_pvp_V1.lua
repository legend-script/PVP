--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║                    BRANZZ HUB PvP v1.0                       ║
    ║                  Script by: LegendDev                        ║
    ╚══════════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Configurações
local Config = {
    SpeedBoostValue = 49,
    TPForwardDistance = 17,
    InstantTPHeight = 100,
    InstantTPSpeed = 0.1,
    FakePingUpdateRate = 0.1,
    HitboxMaxSize = 250,
    HitboxTransparency = 0.7,
    HitboxColor = Color3.fromRGB(255, 255, 255),
    UI = {
        PrimaryColor = Color3.fromRGB(25, 25, 35),
        SecondaryColor = Color3.fromRGB(35, 35, 50),
        AccentColor = Color3.fromRGB(147, 112, 219),
        TextColor = Color3.fromRGB(255, 255, 255),
        TitleBarColor = Color3.fromRGB(20, 20, 30),
        ButtonColor = Color3.fromRGB(45, 45, 65),
        ButtonHover = Color3.fromRGB(60, 60, 85),
        SuccessColor = Color3.fromRGB(100, 255, 100),
        ErrorColor = Color3.fromRGB(255, 100, 100),
        WarningColor = Color3.fromRGB(255, 200, 100)
    }
}

-- Variáveis de Estado
local State = {
    MarkedPosition = nil,
    IsMinimized = false,
    SpeedBoostActive = false,
    FakePingActive = false,
    HitboxActive = false,
    HitboxSize = 50,
    IsDragging = false,
    DragStart = nil,
    StartPos = nil,
    InstantTPRunning = false,
    TPCountdownRunning = false,
    FakePingClone = nil,
    FakePingConnection = nil,
    HitboxConnections = {},
    ExpandedHitboxes = {}
}

-- Criar GUI Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Legend HubPvP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 315, 0, 405)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Config.UI.PrimaryColor
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Cantos arredondados
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.ZIndex = -1
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.Parent = MainFrame

-- Barra de Título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Config.UI.TitleBarColor
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Gradiente na barra de título
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.UI.TitleBarColor),
    ColorSequenceKeypoint.new(1, Config.UI.SecondaryColor)
})
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 13, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "branzz hub PvP"
TitleLabel.TextColor3 = Config.UI.AccentColor
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Botões da Barra de Título
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(0, 110, 1, 0)
ButtonContainer.Position = UDim2.new(1, -115, 0, 0)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = TitleBar

local function CreateTitleButton(name, text, color, position)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 27, 0, 27)
    btn.Position = UDim2.new(0, position, 0.5, -15)
    btn.BackgroundColor3 = Config.UI.ButtonColor
    btn.Text = text
    btn.TextColor3 = color
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ButtonContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonHover}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonColor}):Play()
    end)
    
    return btn
end

local MinimizeBtn = CreateTitleButton("Minimize", "−", Config.UI.TextColor, 5)
local MaximizeBtn = CreateTitleButton("Maximize", "□", Config.UI.TextColor, 40)
local CloseBtn = CreateTitleButton("Close", "×", Config.UI.ErrorColor, 75)

-- Container de Conteúdo (Scroll)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, -45)
ContentContainer.Position = UDim2.new(0, 0, 0, 40)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

-- ScrollingFrame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Size = UDim2.new(1, -20, 1, -20)
ScrollFrame.Position = UDim2.new(0, 9, 0, 9)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Config.UI.AccentColor
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = ContentContainer

-- Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- Padding
local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.PaddingBottom = UDim.new(0, 5)
UIPadding.Parent = ScrollFrame

-- Sistema de Notificações
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "NotificationFrame"
NotificationFrame.Size = UDim2.new(0, 252, 0, 54)
NotificationFrame.Position = UDim2.new(0.5, -140, 0, -70)
NotificationFrame.BackgroundColor3 = Config.UI.SecondaryColor
NotificationFrame.BorderSizePixel = 0
NotificationFrame.Visible = false
NotificationFrame.Parent = ScreenGui

local NotifCorner = Instance.new("UICorner")
NotifCorner.CornerRadius = UDim.new(0, 10)
NotifCorner.Parent = NotificationFrame

local NotifText = Instance.new("TextLabel")
NotifText.Name = "Text"
NotifText.Size = UDim2.new(1, -20, 1, 0)
NotifText.Position = UDim2.new(0, 9, 0, 0)
NotifText.BackgroundTransparency = 1
NotifText.Text = ""
NotifText.TextColor3 = Config.UI.TextColor
NotifText.TextSize = 14
NotifText.Font = Enum.Font.Gotham
NotifText.TextWrapped = true
NotifText.Parent = NotificationFrame

-- Função de Notificação
local function ShowNotification(text, color)
    NotifText.Text = text
    NotifText.TextColor3 = color or Config.UI.TextColor
    NotificationFrame.Visible = true
    
    TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -140, 0, 20)
    }):Play()
    
    task.delay(3, function()
        TweenService:Create(NotificationFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(0.5, -140, 0, -70)
        }):Play()
        task.wait(0.3)
        NotificationFrame.Visible = false
    end)
end

-- Função para criar botões
local function CreateButton(parent, text, icon, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -10, 0, 45)
    btnFrame.BackgroundColor3 = Config.UI.ButtonColor
    btnFrame.BorderSizePixel = 0
    btnFrame.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btnFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = icon .. " " .. text
    btn.TextColor3 = Config.UI.TextColor
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = btnFrame
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonHover}):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        TweenService:Create(btnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonColor}):Play()
    end)
    
    btn.MouseButton1Click:Connect(callback)
    
    return btnFrame
end

-- Função para criar Toggle com Checkbox
local function CreateToggle(parent, text, icon, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 45)
    toggleFrame.BackgroundColor3 = Config.UI.ButtonColor
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 13, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Config.UI.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local checkbox = Instance.new("Frame")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 21, 0, 21)
    checkbox.Position = UDim2.new(1, -40, 0.5, -12)
    checkbox.BackgroundColor3 = Config.UI.SecondaryColor
    checkbox.BorderSizePixel = 0
    checkbox.Parent = toggleFrame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkbox
    
    local checkmark = Instance.new("TextLabel")
    checkmark.Name = "Checkmark"
    checkmark.Size = UDim2.new(1, 0, 1, 0)
    checkmark.BackgroundTransparency = 1
    checkmark.Text = "✓"
    checkmark.TextColor3 = Config.UI.SuccessColor
    checkmark.TextSize = 18
    checkmark.Font = Enum.Font.GothamBold
    checkmark.Visible = false
    checkmark.Parent = checkbox
    
    local isActive = false
    
    local function UpdateState()
        isActive = not isActive
        checkmark.Visible = isActive
        if isActive then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.AccentColor}):Play()
        else
            TweenService:Create(checkbox, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.SecondaryColor}):Play()
        end
        callback(isActive)
    end
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = toggleFrame
    
    clickArea.MouseEnter:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonHover}):Play()
    end)
    
    clickArea.MouseLeave:Connect(function()
        TweenService:Create(toggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Config.UI.ButtonColor}):Play()
    end)
    
    clickArea.MouseButton1Click:Connect(UpdateState)
    
    return {
        Frame = toggleFrame,
        SetState = function(state)
            isActive = state
            checkmark.Visible = state
            checkbox.BackgroundColor3 = state and Config.UI.AccentColor or Config.UI.SecondaryColor
        end,
        GetState = function() return isActive end
    }
end

-- Função para criar Slider
local function CreateSlider(parent, text, icon, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 80)
    sliderFrame.BackgroundColor3 = Config.UI.ButtonColor
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 9, 0, 7)
    label.BackgroundTransparency = 1
    label.Text = icon .. " " .. text
    label.TextColor3 = Config.UI.TextColor
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 45, 0, 22)
    valueLabel.Position = UDim2.new(1, -60, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Config.UI.AccentColor
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = sliderFrame
    
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -30, 0, 8)
    track.Position = UDim2.new(0, 13, 0, 40)
    track.BackgroundColor3 = Config.UI.SecondaryColor
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Config.UI.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -9, 0.5, -9)
    knob.BackgroundColor3 = Config.UI.TextColor
    knob.BorderSizePixel = 0
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0.5, 0)
    knobCorner.Parent = knob
    
    local isDragging = false
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -9, 0.5, -9)
        valueLabel.Text = tostring(value)
        
        callback(value)
        return value
    end
    
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
        end
    end)
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            UpdateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    
    return sliderFrame
end

-- Separador
local function CreateSeparator(parent)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -20, 0, 2)
    sep.Position = UDim2.new(0, 9, 0, 0)
    sep.BackgroundColor3 = Config.UI.SecondaryColor
    sep.BorderSizePixel = 0
    sep.Parent = parent
    return sep
end

-- Título de Seção
local function CreateSectionTitle(parent, text)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = text
    title.TextColor3 = Config.UI.AccentColor
    title.TextSize = 12
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = parent
    return title
end

-- Criar Botões e Funções

-- Seção: Teleporte
CreateSectionTitle(ScrollFrame, "═ TELEPORTE ═")

-- Mark Position
CreateButton(ScrollFrame, "Mark Position", "🚩", function()
    if State.MarkedPosition then
        ShowNotification("❌ Erro: Já existe uma posição marcada! Use Clear Position primeiro.", Config.UI.ErrorColor)
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        ShowNotification("❌ Erro: Personagem não encontrado!", Config.UI.ErrorColor)
        return
    end
    
    State.MarkedPosition = character.HumanoidRootPart.Position
    ShowNotification("✅ Posição marcada com sucesso!", Config.UI.SuccessColor)
end)

-- Clear Position
CreateButton(ScrollFrame, "Clear Position", "🗑️", function()
    if not State.MarkedPosition then
        ShowNotification("❌ Nenhuma posição marcada!", Config.UI.ErrorColor)
        return
    end
    
    State.MarkedPosition = nil
    ShowNotification("✅ Posição apagada!", Config.UI.SuccessColor)
end)

CreateSeparator(ScrollFrame)

-- Instant TP
CreateButton(ScrollFrame, "Instant TP", "⚡", function()
    if State.InstantTPRunning then
        ShowNotification("❌ Teleporte já está em andamento!", Config.UI.ErrorColor)
        return
    end
    
    if not State.MarkedPosition then
        ShowNotification("❌ Marque uma posição primeiro!", Config.UI.ErrorColor)
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        ShowNotification("❌ Personagem não encontrado!", Config.UI.ErrorColor)
        return
    end
    
    State.InstantTPRunning = true
    ShowNotification("⚡ Iniciando teleporte voador...", Config.UI.WarningColor)
    
    task.spawn(function()
        local hrp = character.HumanoidRootPart
        local targetPos = State.MarkedPosition
        local startPos = hrp.Position
        
        -- Subir
        local height = math.max(startPos.Y, targetPos.Y) + Config.InstantTPHeight
        
        -- Função para empurrar jogadores
        local function PushPlayersAway()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if otherHRP then
                        local distance = (hrp.Position - otherHRP.Position).Magnitude
                        if distance < 20 then
                            local pushDirection = (otherHRP.Position - hrp.Position).Unit
                            otherHRP.Velocity = pushDirection * 100 + Vector3.new(0, 50, 0)
                        end
                    end
                end
            end
        end
        
        -- Subir voando
        for i = 1, 20 do
            if not character or not character:FindFirstChild("HumanoidRootPart") then break end
            hrp.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y + (height - startPos.Y) / 20, hrp.Position.Z)
            PushPlayersAway()
            task.wait(Config.InstantTPSpeed)
        end
        
        -- Mover horizontalmente com micro teleportes
        local currentPos = hrp.Position
        local direction = (targetPos - currentPos).Unit
        local distance = (targetPos - currentPos).Magnitude
        local steps = math.floor(distance / 10)
        
        for i = 1, steps do
            if not character or not character:FindFirstChild("HumanoidRootPart") then break end
            currentPos = currentPos + direction * 10
            hrp.CFrame = CFrame.new(currentPos.X, height, currentPos.Z)
            PushPlayersAway()
            task.wait(Config.InstantTPSpeed)
        end
        
        -- Descer
        for i = 1, 20 do
            if not character or not character:FindFirstChild("HumanoidRootPart") then break end
            local newY = height - (height - targetPos.Y) * (i / 20)
            hrp.CFrame = CFrame.new(targetPos.X, newY, targetPos.Z)
            PushPlayersAway()
            task.wait(Config.InstantTPSpeed)
        end
        
        hrp.CFrame = CFrame.new(targetPos)
        State.InstantTPRunning = false
        ShowNotification("✅ Teleporte concluído!", Config.UI.SuccessColor)
    end)
end)

-- TP Countdown
CreateButton(ScrollFrame, "TP Countdown (5s)", "⏳", function()
    if State.TPCountdownRunning then
        ShowNotification("❌ Contagem já em andamento!", Config.UI.ErrorColor)
        return
    end
    
    if not State.MarkedPosition then
        ShowNotification("❌ Marque uma posição primeiro!", Config.UI.ErrorColor)
        return
    end
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        ShowNotification("❌ Personagem não encontrado!", Config.UI.ErrorColor)
        return
    end
    
    State.TPCountdownRunning = true
    
    task.spawn(function()
        for i = 5, 1, -1 do
            ShowNotification("⏳ Teleporte em " .. i .. " segundos...", Config.UI.WarningColor)
            task.wait(1)
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(State.MarkedPosition)
            ShowNotification("✅ Teleportado com sucesso!", Config.UI.SuccessColor)
        end
        
        State.TPCountdownRunning = false
    end)
end)

-- TP Forward
CreateButton(ScrollFrame, "TP Forward (17 studs)", "🚀", function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        ShowNotification("❌ Personagem não encontrado!", Config.UI.ErrorColor)
        return
    end
    
    local hrp = character.HumanoidRootPart
    local forward = hrp.CFrame.LookVector * Config.TPForwardDistance
    local newPos = hrp.Position + forward + Vector3.new(0, 5, 0)
    
    -- Animação de flutuar
    for i = 1, 10 do
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        hrp.CFrame = CFrame.new(hrp.Position + forward / 10 + Vector3.new(0, 0.5, 0))
        task.wait(0.02)
    end
    
    hrp.CFrame = CFrame.new(newPos)
    ShowNotification("✅ Teleportado para frente!", Config.UI.SuccessColor)
end)

CreateSeparator(ScrollFrame)

-- Seção: Modificações
CreateSectionTitle(ScrollFrame, "═ MODIFICAÇÕES ═")

-- Speed Boost
local SpeedToggle = CreateToggle(ScrollFrame, "Speed Boost", "🏁", function(isActive)
    State.SpeedBoostActive = isActive
    
    local function ApplySpeed()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = isActive and Config.SpeedBoostValue or 16
        end
    end
    
    ApplySpeed()
    
    -- Persistir após respawn
    if isActive then
        LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if State.SpeedBoostActive then
                local humanoid = char:WaitForChild("Humanoid")
                humanoid.WalkSpeed = Config.SpeedBoostValue
            end
        end)
    end
    
    ShowNotification(isActive and "🏁 Speed Boost ATIVADO! (Velocidade: 49)" or "🏁 Speed Boost DESATIVADO!", 
        isActive and Config.UI.SuccessColor or Config.UI.ErrorColor)
end)

-- Fake Ping Server
local FakePingToggle = CreateToggle(ScrollFrame, "Fake Ping Server", "📵", function(isActive)
    State.FakePingActive = isActive
    
    if isActive then
        local character = LocalPlayer.Character
        if not character then
            ShowNotification("❌ Personagem não encontrado!", Config.UI.ErrorColor)
            FakePingToggle.SetState(false)
            State.FakePingActive = false
            return
        end
        
        -- Criar clone
        local clone = Instance.new("Model")
        clone.Name = LocalPlayer.Name .. "_Clone"
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local clonePart = part:Clone()
                clonePart.CanCollide = false
                clonePart.Anchored = true
                clonePart.Parent = clone
            end
        end
        
        local cloneHRP = Instance.new("Part")
        cloneHRP.Name = "HumanoidRootPart"
        cloneHRP.Size = Vector3.new(2, 2, 1)
        cloneHRP.CFrame = character.HumanoidRootPart.CFrame
        cloneHRP.Anchored = true
        cloneHRP.CanCollide = false
        cloneHRP.Transparency = 1
        cloneHRP.Parent = clone
        
        clone.Parent = Workspace
        State.FakePingClone = clone
        
        -- Tornar personagem real invisível para outros
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part:SetAttribute("OriginalTransparency", part.Transparency)
                part.Transparency = 1
            end
        end
        
        -- Criar holograma visível apenas para o jogador
        local hologram = clone:Clone()
        hologram.Name = "Hologram"
        
        for _, part in ipairs(hologram:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.Material = Enum.Material.ForceField
                part.Color = Color3.fromRGB(147, 112, 219)
            end
        end
        
        hologram.Parent = Workspace
        
        -- Atualizar posição do clone (efeito de lag)
        State.FakePingConnection = RunService.Heartbeat:Connect(function()
            if clone and clone:FindFirstChild("HumanoidRootPart") then
                local currentPos = clone.HumanoidRootPart.Position
                local randomOffset = Vector3.new(
                    math.random(-2, 2),
                    0,
                    math.random(-2, 2)
                )
                clone.HumanoidRootPart.CFrame = CFrame.new(currentPos + randomOffset)
                
                -- Atualizar holograma para posição real
                if character and character:FindFirstChild("HumanoidRootPart") then
                    hologram.HumanoidRootPart.CFrame = character.HumanoidRootPart.CFrame
                end
            end
        end)
        
        -- Sistema de segurança - teleportar para local seguro se alguém tentar atacar
        local safetyConnection
        safetyConnection = RunService.Heartbeat:Connect(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    if otherHRP and character and character:FindFirstChild("HumanoidRootPart") then
                        local distance = (character.HumanoidRootPart.Position - otherHRP.Position).Magnitude
                        if distance < 10 then
                            character.HumanoidRootPart.CFrame = CFrame.new(character.HumanoidRootPart.Position + Vector3.new(0, 50, 0))
                        end
                    end
                end
            end
        end)
        
        State.SafetyConnection = safetyConnection
        
        ShowNotification("📵 Fake Ping ATIVADO! Você está invisível globalmente.", Config.UI.SuccessColor)
    else
        -- Desativar
        if State.FakePingClone then
            State.FakePingClone:Destroy()
            State.FakePingClone = nil
        end
        
        if State.FakePingConnection then
            State.FakePingConnection:Disconnect()
            State.FakePingConnection = nil
        end
        
        if State.SafetyConnection then
            State.SafetyConnection:Disconnect()
            State.SafetyConnection = nil
        end
        
        -- Tornar personagem visível novamente
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part:GetAttribute("OriginalTransparency") then
                    part.Transparency = part:GetAttribute("OriginalTransparency")
                end
            end
        end
        
        -- Remover holograma
        local hologram = Workspace:FindFirstChild("Hologram")
        if hologram then
            hologram:Destroy()
        end
        
        ShowNotification("📵 Fake Ping DESATIVADO!", Config.UI.ErrorColor)
    end
end)

CreateSeparator(ScrollFrame)

-- Seção: Hitbox
CreateSectionTitle(ScrollFrame, "═ HITBOX EXPANDER ═")

-- Hitbox Toggle
local HitboxToggle = CreateToggle(ScrollFrame, "Hitbox Expander", "💠", function(isActive)
    State.HitboxActive = isActive
    
    if isActive then
        -- Expandir hitboxes
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if not State.ExpandedHitboxes[player] then
                            State.ExpandedHitboxes[player] = {}
                        end
                        
                        local originalSize = part.Size
                        State.ExpandedHitboxes[player][part] = originalSize
                        
                        part.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                        part.Transparency = Config.HitboxTransparency
                        part.Color = Config.HitboxColor
                        part.Material = Enum.Material.ForceField
                        part.CanCollide = false
                    end
                end
            end
        end
        
        -- Atualizar quando novos jogadores entrarem
        local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(character)
                if State.HitboxActive then
                    task.wait(1)
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            if not State.ExpandedHitboxes[player] then
                                State.ExpandedHitboxes[player] = {}
                            end
                            
                            State.ExpandedHitboxes[player][part] = part.Size
                            part.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                            part.Transparency = Config.HitboxTransparency
                            part.Color = Config.HitboxColor
                            part.Material = Enum.Material.ForceField
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end)
        
        table.insert(State.HitboxConnections, playerAddedConnection)
        
        ShowNotification("💠 Hitbox Expander ATIVADO! Tamanho: " .. State.HitboxSize, Config.UI.SuccessColor)
    else
        -- Restaurar hitboxes
        for player, parts in pairs(State.ExpandedHitboxes) do
            for part, originalSize in pairs(parts) do
                if part and part.Parent then
                    part.Size = originalSize
                    part.Transparency = 0
                    part.Material = Enum.Material.Plastic
                end
            end
        end
        
        State.ExpandedHitboxes = {}
        
        -- Desconectar conexões
        for _, connection in ipairs(State.HitboxConnections) do
            connection:Disconnect()
        end
        State.HitboxConnections = {}
        
        ShowNotification("💠 Hitbox Expander DESATIVADO!", Config.UI.ErrorColor)
    end
end)

-- Hitbox Slider
CreateSlider(ScrollFrame, "Hitbox Size", "", 10, Config.HitboxMaxSize, 50, function(value)
    State.HitboxSize = value
    
    -- Atualizar hitboxes se estiver ativo
    if State.HitboxActive then
        for player, parts in pairs(State.ExpandedHitboxes) do
            for part, _ in pairs(parts) do
                if part and part.Parent then
                    part.Size = Vector3.new(value, value, value)
                end
            end
        end
    end
end)

-- Sistema de Arrastar
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.IsDragging = true
        State.DragStart = input.Position
        State.StartPos = MainFrame.Position
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if State.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - State.DragStart
        MainFrame.Position = UDim2.new(
            State.StartPos.X.Scale,
            State.StartPos.X.Offset + delta.X,
            State.StartPos.Y.Scale,
            State.StartPos.Y.Offset + delta.Y
        )
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        State.IsDragging = false
    end
end)

-- Botão Minimizar
MinimizeBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = true
    ContentContainer.Visible = false
    MainFrame.Size = UDim2.new(0, 315, 0, 40)
    ShowNotification("➖ Janela minimizada", Config.UI.WarningColor)
end)

-- Botão Maximizar
MaximizeBtn.MouseButton1Click:Connect(function()
    State.IsMinimized = false
    ContentContainer.Visible = true
    MainFrame.Size = UDim2.new(0, 315, 0, 405)
    ShowNotification("⬜ Janela maximizada", Config.UI.SuccessColor)
end)

-- Botão Fechar
CloseBtn.MouseButton1Click:Connect(function()
    -- Desativar todas as funções antes de fechar
    if State.SpeedBoostActive then
        SpeedToggle.SetState(false)
    end
    if State.FakePingActive then
        FakePingToggle.SetState(false)
    end
    if State.HitboxActive then
        HitboxToggle.SetState(false)
    end
    
    ScreenGui:Destroy()
end)

-- Animação de entrada
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 315, 0, 405),
    Position = UDim2.new(0.5, -175, 0.5, -225)
}):Play()

ShowNotification("🎮 Legend Hub PvP carregado com sucesso!", Config.UI.SuccessColor)

print("╔══════════════════════════════════════════════════════════════╗")
print("║                    BRANZZ HUB PvP v1.0                       ║")
print("║                     Carregado com sucesso!                   ║")
print("╚══════════════════════════════════════════════════════════════╝")
