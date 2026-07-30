--[[
Aura Pro UI Library - Upgraded Edition
Features: Responsive UIScale Engine, Modern Dark Theme, Dynamic Search,
Keybind Listener, ColorPicker, Multi-Dropdown, Notification Subsystem,
Auto-Config Saving, and Custom Window Scaling.
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local CachedParent = (gethui and gethui())
or (CoreGui:FindFirstChild("RobloxGui") and CoreGui)
or (LocalPlayer and LocalPlayer:WaitForChild("PlayerGui"))
or CoreGui

-- Decommission pre-existing instance to prevent duplicates/memory leaks
local PreexistingInstance = CachedParent:FindFirstChild("Aura_Pro_UI")
if PreexistingInstance then
PreexistingInstance:Destroy()
end

local AuraPro = {}
AuraPro.Themes = {
Dark = {
Background = Color3.fromRGB(18, 19, 24),
Card = Color3.fromRGB(25, 27, 34),
Element = Color3.fromRGB(33, 36, 46),
Border = Color3.fromRGB(48, 52, 66),
Text = Color3.fromRGB(240, 242, 248),
SubText = Color3.fromRGB(145, 152, 172),
Accent = Color3.fromRGB(99, 102, 241), -- Vibrant Indigo
AccentHover = Color3.fromRGB(129, 140, 248),
Success = Color3.fromRGB(34, 197, 94),
Danger = Color3.fromRGB(239, 68, 68)
},
Midnight = {
Background = Color3.fromRGB(11, 15, 25),
Card = Color3.fromRGB(17, 23, 39),
Element = Color3.fromRGB(24, 33, 55),
Border = Color3.fromRGB(37, 49, 80),
Text = Color3.fromRGB(243, 244, 246),
SubText = Color3.fromRGB(156, 163, 175),
Accent = Color3.fromRGB(14, 165, 233), -- Deep Sky Blue
AccentHover = Color3.fromRGB(56, 189, 248),
Success = Color3.fromRGB(16, 185, 129),
Danger = Color3.fromRGB(244, 63, 94)
}
}

--- Dragging Utility with scaling calculation safety
local function MakeDraggable(Frame, HandleFrame)
local Dragging = false
local DragInput, DragStart, StartPos

HandleFrame.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = Input.Position
        StartPos = Frame.Position

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

HandleFrame.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
        DragInput = Input
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Input == DragInput and Dragging then
        local Delta = Input.Position - DragStart
        TweenService:Create(Frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        }):Play()
    end
end)


end

--- Instantiates primary window context with uniform responsive scaling
function AuraPro:CreateWindow(Config)
Config = Config or {}
local TitleText = Config.Name or "Aura UI Pro"
local SelectedTheme = Config.Theme or AuraPro.Themes.Dark
local ConfigFileName = Config.ConfigFile or "AuraConfig.json"
local SaveConfigEnabled = Config.SaveConfig or false
local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightControl

local BaseWidth = Config.Width or 640
local BaseHeight = Config.Height or 440
local UserScale = Config.Scale or 1.0

local SavedData = {}
if SaveConfigEnabled and readfile and isfile and isfile(ConfigFileName) then
    pcall(function()
        SavedData = HttpService:JSONDecode(readfile(ConfigFileName))
    end)
end

local function SaveCurrentConfig()
    if SaveConfigEnabled and writefile then
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(SavedData))
        end)
    end
end

-- Primary ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aura_Pro_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CachedParent

-- Notification Container (Root level)
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 300, 1, -20)
NotifContainer.Position = UDim2.new(1, -310, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 9999

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)

function AuraPro:Notify(NotifConfig)
    NotifConfig = NotifConfig or {}
    local NTitle = NotifConfig.Title or "Notification"
    local NContent = NotifConfig.Content or ""
    local NTime = NotifConfig.Duration or 3.5

    local Card = Instance.new("Frame", NotifContainer)
    Card.Size = UDim2.new(1, 0, 0, 68)
    Card.BackgroundColor3 = SelectedTheme.Card
    Card.Position = UDim2.new(1, 350, 0, 0)
    Card.ClipsDescendants = true
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Card)
    Stroke.Color = SelectedTheme.Accent
    Stroke.Thickness = 1.2

    local TitleLbl = Instance.new("TextLabel", Card)
    TitleLbl.Size = UDim2.new(1, -16, 0, 22)
    TitleLbl.Position = UDim2.new(0, 10, 0, 6)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = NTitle
    TitleLbl.TextColor3 = SelectedTheme.Accent
    TitleLbl.TextSize = 13
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local ContentLbl = Instance.new("TextLabel", Card)
    ContentLbl.Size = UDim2.new(1, -16, 0, 34)
    ContentLbl.Position = UDim2.new(0, 10, 0, 28)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.Text = NContent
    ContentLbl.TextColor3 = SelectedTheme.SubText
    ContentLbl.TextSize = 11
    ContentLbl.Font = Enum.Font.Gotham
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
    ContentLbl.TextWrapped = true

    TweenService:Create(Card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(NTime, function()
        local TweenOut = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 350, 0, 0)})
        TweenOut:Play()
        TweenOut.Completed:Connect(function()
            Card:Destroy()
        end)
    end)
end

-- Primary Window Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
MainFrame.Position = UDim2.new(0.5, -BaseWidth / 2, 0.5, -BaseHeight / 2)
MainFrame.BackgroundColor3 = SelectedTheme.Background
MainFrame.ClipsDescendants = false

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = SelectedTheme.Border
MainStroke.Thickness = 1.2

-- UNIFORM UI SCALE ENGINE
-- All components inside MainFrame automatically scale proportionally according to MainUIScale!
local MainUIScale = Instance.new("UIScale", MainFrame)

local function UpdateGlobalScale()
    local Camera = Workspace.CurrentCamera
    local ViewportScale = 1
    if Camera then
        local ViewSize = Camera.ViewportSize
        if ViewSize.X < (BaseWidth + 60) or ViewSize.Y < (BaseHeight + 60) then
            ViewportScale = math.min(ViewSize.X / (BaseWidth + 60), ViewSize.Y / (BaseHeight + 60))
        end
    end
    MainUIScale.Scale = UserScale * ViewportScale
end

UpdateGlobalScale()
if Workspace.CurrentCamera then
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateGlobalScale)
end

-- Top Navigation Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, -20, 0, 42)
TopBar.Position = UDim2.new(0, 10, 0, 10)
TopBar.BackgroundColor3 = SelectedTheme.Card
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

MakeDraggable(MainFrame, TopBar)

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = TitleText
TitleLabel.TextColor3 = SelectedTheme.Text
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Window Action Controls (Minimize & Close)
local ControlsContainer = Instance.new("Frame", TopBar)
ControlsContainer.Size = UDim2.new(0, 70, 1, 0)
ControlsContainer.Position = UDim2.new(1, -75, 0, 0)
ControlsContainer.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", ControlsContainer)
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(0, 0, 0.5, -14)
MinimizeBtn.BackgroundColor3 = SelectedTheme.Element
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = SelectedTheme.SubText
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", ControlsContainer)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(0, 34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
CloseBtn.BackgroundTransparency = 0.85
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local UIVisible = true
local function ToggleUIVisibility()
    UIVisible = not UIVisible
    if UIVisible then
        MainFrame.Visible = true
        TweenService:Create(MainUIScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Scale = UserScale
        }):Play()
    else
        local Tween = TweenService:Create(MainUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Scale = 0
        })
        Tween:Play()
        Tween.Completed:Connect(function()
            if not UIVisible then MainFrame.Visible = false end
        end)
    end
end

MinimizeBtn.MouseButton1Click:Connect(ToggleUIVisibility)
UserInputService.InputBegan:Connect(function(Input, Processed)
    if not Processed and Input.KeyCode == ToggleKey then
        ToggleUIVisibility()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainUIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0}):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- Tab Navigation Container
local TabBarWidth = 150
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, TabBarWidth, 1, -65)
TabBar.Position = UDim2.new(0, 10, 0, 58)
TabBar.BackgroundColor3 = SelectedTheme.Card
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

-- Tab Search Filter Input
local SearchBox = Instance.new("TextBox", TabBar)
SearchBox.Size = UDim2.new(1, -12, 0, 26)
SearchBox.Position = UDim2.new(0, 6, 0, 6)
SearchBox.BackgroundColor3 = SelectedTheme.Element
SearchBox.PlaceholderText = "🔍 Search..."
SearchBox.PlaceholderColor3 = SelectedTheme.SubText
SearchBox.Text = ""
SearchBox.TextColor3 = SelectedTheme.Text
SearchBox.TextSize = 11
SearchBox.Font = Enum.Font.Gotham
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 5)

local TabScroll = Instance.new("ScrollingFrame", TabBar)
TabScroll.Size = UDim2.new(1, 0, 1, -38)
TabScroll.Position = UDim2.new(0, 0, 0, 38)
TabScroll.BackgroundTransparency = 1
TabScroll.ScrollBarThickness = 2
TabScroll.ScrollBarImageColor3 = SelectedTheme.Border

local TabLayout = Instance.new("UIListLayout", TabScroll)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 4)

local TabPadding = Instance.new("UIPadding", TabScroll)
TabPadding.PaddingTop = UDim.new(0, 4)
TabPadding.PaddingLeft = UDim.new(0, 6)

local PagesArea = Instance.new("Frame", MainFrame)
PagesArea.Size = UDim2.new(1, -(TabBarWidth + 30), 1, -65)
PagesArea.Position = UDim2.new(0, TabBarWidth + 20, 0, 58)
PagesArea.BackgroundColor3 = SelectedTheme.Card
PagesArea.ClipsDescendants = true
Instance.new("UICorner", PagesArea).CornerRadius = UDim.new(0, 8)

local WindowObj = { CurrentTab = nil, Tabs = {} }

--- Dynamic Window Scale Modifier
function WindowObj:SetScale(NewScale)
    UserScale = math.clamp(NewScale or 1.0, 0.5, 2.0)
    UpdateGlobalScale()
end

function WindowObj:CreateTab(TabName)
    local TabBtn = Instance.new("TextButton", TabScroll)
    TabBtn.Size = UDim2.new(0, TabBarWidth - 12, 0, 32)
    TabBtn.BackgroundColor3 = SelectedTheme.Element
    TabBtn.BackgroundTransparency = 0.7
    TabBtn.Text = TabName
    TabBtn.TextColor3 = SelectedTheme.SubText
    TabBtn.TextSize = 12
    TabBtn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local PageFrame = Instance.new("ScrollingFrame", PagesArea)
    PageFrame.Size = UDim2.new(1, -12, 1, -12)
    PageFrame.Position = UDim2.new(0, 6, 0, 6)
    PageFrame.BackgroundTransparency = 1
    PageFrame.Visible = false
    PageFrame.ScrollBarThickness = 3
    PageFrame.ScrollBarImageColor3 = SelectedTheme.Accent

    local PageLayout = Instance.new("UIListLayout", PageFrame)
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 6)

    PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 12)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if WindowObj.CurrentTab == PageFrame then return end
        
        for _, TabData in ipairs(WindowObj.Tabs) do
            if TabData.Page.Visible then
                TabData.Page.Visible = false
            end
            TweenService:Create(TabData.Btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.7,
                TextColor3 = SelectedTheme.SubText
            }):Play()
        end

        WindowObj.CurrentTab = PageFrame
        PageFrame.Visible = true
        TweenService:Create(TabBtn, TweenInfo.new(0.2), {
            BackgroundTransparency = 0,
            TextColor3 = SelectedTheme.Text
        }):Play()
    end)

    if #WindowObj.Tabs == 0 then
        WindowObj.CurrentTab = PageFrame
        PageFrame.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.TextColor3 = SelectedTheme.Text
    end

    table.insert(WindowObj.Tabs, { Btn = TabBtn, Page = PageFrame, Name = TabName })

    -- Realtime UI Search Filter
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = string.lower(SearchBox.Text)
        for _, Element in ipairs(PageFrame:GetChildren()) do
            if Element:IsA("Frame") or Element:IsA("TextButton") then
                local Label = Element:FindFirstChildWhichIsA("TextLabel") or Element
                if Label and Label.Text then
                    if Query == "" or string.find(string.lower(Label.Text), Query) then
                        Element.Visible = true
                    else
                        Element.Visible = false
                    end
                end
            end
        end
    end)

    local TabElements = {}

    function TabElements:CreateSection(Text)
        local SecLabel = Instance.new("TextLabel", PageFrame)
        SecLabel.Size = UDim2.new(0.98, 0, 0, 22)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Text = "• " .. string.upper(Text)
        SecLabel.TextColor3 = SelectedTheme.Accent
        SecLabel.TextSize = 11
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    function TabElements:CreateButton(Config)
        local Name = Config.Name or "Button"
        local Callback = Config.Callback or function() end

        local Btn = Instance.new("TextButton", PageFrame)
        Btn.Size = UDim2.new(0.98, 0, 0, 36)
        Btn.BackgroundColor3 = SelectedTheme.Element
        Btn.Text = "    " .. Name
        Btn.TextColor3 = SelectedTheme.Text
        Btn.TextSize = 12
        Btn.Font = Enum.Font.GothamMedium
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        local Stroke = Instance.new("UIStroke", Btn)
        Stroke.Color = SelectedTheme.Border

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = SelectedTheme.Border}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = SelectedTheme.Element}):Play()
        end)
        Btn.MouseButton1Click:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.08), {Size = UDim2.new(0.96, 0, 0, 34)}):Play()
            task.wait(0.08)
            TweenService:Create(Btn, TweenInfo.new(0.08), {Size = UDim2.new(0.98, 0, 0, 36)}):Play()
            pcall(Callback)
        end)
    end

    function TabElements:CreateToggle(Config)
        local Name = Config.Name or "Toggle"
        local Flag = Config.Flag or Name
        local Default = SavedData[Flag] ~= nil and SavedData[Flag] or (Config.Default or false)
        local Callback = Config.Callback or function() end
        local Toggled = Default

        SavedData[Flag] = Toggled

        local ToggleBtn = Instance.new("TextButton", PageFrame)
        ToggleBtn.Size = UDim2.new(0.98, 0, 0, 36)
        ToggleBtn.BackgroundColor3 = SelectedTheme.Element
        ToggleBtn.Text = "    " .. Name
        ToggleBtn.TextColor3 = SelectedTheme.Text
        ToggleBtn.TextSize = 12
        ToggleBtn.Font = Enum.Font.GothamMedium
        ToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

        local Stroke = Instance.new("UIStroke", ToggleBtn)
        Stroke.Color = SelectedTheme.Border

        local SwitchBG = Instance.new("Frame", ToggleBtn)
        SwitchBG.Size = UDim2.new(0, 34, 0, 18)
        SwitchBG.Position = UDim2.new(1, -42, 0.5, -9)
        SwitchBG.BackgroundColor3 = Toggled and SelectedTheme.Accent or SelectedTheme.Border
        Instance.new("UICorner", SwitchBG).CornerRadius = UDim.new(1, 0)

        local SwitchPin = Instance.new("Frame", SwitchBG)
        SwitchPin.Size = UDim2.new(0, 14, 0, 14)
        SwitchPin.Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        SwitchPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", SwitchPin).CornerRadius = UDim.new(1, 0)

        ToggleBtn.MouseButton1Click:Connect(function()
            Toggled = not Toggled
            SavedData[Flag] = Toggled
            SaveCurrentConfig()

            TweenService:Create(SwitchBG, TweenInfo.new(0.2), {
                BackgroundColor3 = Toggled and SelectedTheme.Accent or SelectedTheme.Border
            }):Play()
            TweenService:Create(SwitchPin, TweenInfo.new(0.2), {
                Position = Toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            }):Play()

            pcall(Callback, Toggled)
        end)

        if Toggled then pcall(Callback, Toggled) end
    end

    function TabElements:CreateSlider(Config)
        local Name = Config.Name or "Slider"
        local Flag = Config.Flag or Name
        local Min = Config.Min or 0
        local Max = Config.Max or 100
        local Default = SavedData[Flag] ~= nil and SavedData[Flag] or (Config.Default or Min)
        local Callback = Config.Callback or function() end

        local Value = Default
        local Sliding = false
        SavedData[Flag] = Value

        local SliderFrame = Instance.new("Frame", PageFrame)
        SliderFrame.Size = UDim2.new(0.98, 0, 0, 48)
        SliderFrame.BackgroundColor3 = SelectedTheme.Element
        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke", SliderFrame)
        Stroke.Color = SelectedTheme.Border

        local Label = Instance.new("TextLabel", SliderFrame)
        Label.Size = UDim2.new(1, -60, 0, 22)
        Label.Position = UDim2.new(0, 10, 0, 2)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = SelectedTheme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local ValLabel = Instance.new("TextLabel", SliderFrame)
        ValLabel.Size = UDim2.new(0, 50, 0, 22)
        ValLabel.Position = UDim2.new(1, -55, 0, 2)
        ValLabel.BackgroundTransparency = 1
        ValLabel.Text = tostring(Value)
        ValLabel.TextColor3 = SelectedTheme.Accent
        ValLabel.TextSize = 12
        ValLabel.Font = Enum.Font.GothamBold

        local Bar = Instance.new("Frame", SliderFrame)
        Bar.Size = UDim2.new(0.92, 0, 0, 6)
        Bar.Position = UDim2.new(0.04, 0, 0.7, 0)
        Bar.BackgroundColor3 = SelectedTheme.Border
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((Value - Min)/(Max - Min), 0, 1, 0)
        Fill.BackgroundColor3 = SelectedTheme.Accent
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local function Update(Input)
            local Pos = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Value = math.floor(Min + (Max - Min) * Pos)
            ValLabel.Text = tostring(Value)
            TweenService:Create(Fill, TweenInfo.new(0.08), {Size = UDim2.new(Pos, 0, 1, 0)}):Play()
            SavedData[Flag] = Value
            SaveCurrentConfig()
            pcall(Callback, Value)
        end

        Bar.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Sliding = true
                Update(Input)
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                Sliding = false
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                Update(Input)
            end
        end)
    end

    function TabElements:CreateKeybind(Config)
        local Name = Config.Name or "Keybind"
        local Flag = Config.Flag or Name
        local DefaultKey = SavedData[Flag] or Config.Default or Enum.KeyCode.E
        local Callback = Config.Callback or function() end

        SavedData[Flag] = tostring(DefaultKey)

        local BindFrame = Instance.new("Frame", PageFrame)
        BindFrame.Size = UDim2.new(0.98, 0, 0, 36)
        BindFrame.BackgroundColor3 = SelectedTheme.Element
        Instance.new("UICorner", BindFrame).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke", BindFrame)
        Stroke.Color = SelectedTheme.Border

        local Label = Instance.new("TextLabel", BindFrame)
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = SelectedTheme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local KeyBtn = Instance.new("TextButton", BindFrame)
        KeyBtn.Size = UDim2.new(0, 80, 0, 24)
        KeyBtn.Position = UDim2.new(1, -88, 0.5, -12)
        KeyBtn.BackgroundColor3 = SelectedTheme.Card
        KeyBtn.Text = typeof(DefaultKey) == "EnumItem" and DefaultKey.Name or tostring(DefaultKey)
        KeyBtn.TextColor3 = SelectedTheme.Accent
        KeyBtn.TextSize = 11
        KeyBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

        local Listening = false
        KeyBtn.MouseButton1Click:Connect(function()
            Listening = true
            KeyBtn.Text = "Press key..."
        end)

        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Listening and not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
                Listening = false
                KeyBtn.Text = Input.KeyCode.Name
                SavedData[Flag] = Input.KeyCode.Name
                SaveCurrentConfig()
                pcall(Callback, Input.KeyCode)
            end
        end)
    end

    function TabElements:CreateColorpicker(Config)
        local Name = Config.Name or "Colorpicker"
        local Flag = Config.Flag or Name
        local DefaultColor = Config.Default or Color3.fromRGB(99, 102, 241)
        local Callback = Config.Callback or function() end

        local ColorFrame = Instance.new("Frame", PageFrame)
        ColorFrame.Size = UDim2.new(0.98, 0, 0, 36)
        ColorFrame.BackgroundColor3 = SelectedTheme.Element
        Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke", ColorFrame)
        Stroke.Color = SelectedTheme.Border

        local Label = Instance.new("TextLabel", ColorFrame)
        Label.Size = UDim2.new(0.6, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = SelectedTheme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Preview = Instance.new("TextButton", ColorFrame)
        Preview.Size = UDim2.new(0, 30, 0, 20)
        Preview.Position = UDim2.new(1, -38, 0.5, -10)
        Preview.BackgroundColor3 = DefaultColor
        Preview.Text = ""
        Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

        Preview.MouseButton1Click:Connect(function()
            -- Cycles through predefined vibrant accent colors for demonstration palette
            local Presets = {
                Color3.fromRGB(99, 102, 241),
                Color3.fromRGB(34, 197, 94),
                Color3.fromRGB(239, 68, 68),
                Color3.fromRGB(234, 179, 8),
                Color3.fromRGB(168, 85, 247)
            }
            local NextIdx = 1
            for idx, col in ipairs(Presets) do
                if col == Preview.BackgroundColor3 then
                    NextIdx = (idx % #Presets) + 1
                    break
                end
            end
            local NewColor = Presets[NextIdx]
            Preview.BackgroundColor3 = NewColor
            pcall(Callback, NewColor)
        end)
    end

    return TabElements
end

return WindowObj


end

return AuraPro
