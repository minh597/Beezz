local AuraPro = {
Themes = {
Dark = {
Accent = Color3.fromRGB(0, 180, 216),
Background = Color3.fromRGB(15, 17, 23),
Card = Color3.fromRGB(22, 26, 36),
Element = Color3.fromRGB(28, 35, 48),
Text = Color3.fromRGB(240, 245, 255),
SubText = Color3.fromRGB(140, 160, 190),
Border = Color3.fromRGB(45, 55, 75)
},
Ocean = {
Accent = Color3.fromRGB(0, 230, 180),
Background = Color3.fromRGB(10, 20, 30),
Card = Color3.fromRGB(15, 30, 45),
Element = Color3.fromRGB(20, 40, 60),
Text = Color3.fromRGB(240, 255, 250),
SubText = Color3.fromRGB(130, 180, 190),
Border = Color3.fromRGB(40, 70, 95)
},
Crimson = {
Accent = Color3.fromRGB(235, 50, 80),
Background = Color3.fromRGB(18, 12, 15),
Card = Color3.fromRGB(28, 18, 22),
Element = Color3.fromRGB(38, 24, 30),
Text = Color3.fromRGB(255, 240, 245),
SubText = Color3.fromRGB(190, 140, 155),
Border = Color3.fromRGB(75, 45, 55)
}
}
}

-- Core Service Dependencies
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Target Hierarchy Resolution
local CachedParent = (gethui and gethui())
or (game:GetService("CoreGui"):FindFirstChild("RobloxGui") and game:GetService("CoreGui"))
or LocalPlayer:WaitForChild("PlayerGui")

-- SINGLETON INSTANCE LIFECYCLE MANAGEMENT
-- Prior to instantiating a new interface context, query the target UI hierarchy
-- for pre-existing 'Aura_Pro_UI' elements. If an active instance exists,
-- decommission and destroy it to prevent memory leakage and redundant instances.

local PreexistingInstance = CachedParent:FindFirstChild("Aura_Pro_UI")
if PreexistingInstance then
PreexistingInstance:Destroy()
end

--- Enables interactive drag behavior for a designated UI Frame via a Drag Handle.
-- @param Frame GuiObject The target container frame to translate position.
-- @param HandleFrame GuiObject The interactive handle receiving pointer input events.
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
        TweenService:Create(Frame, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        }):Play()
    end
end)


end

--- Instantiates a new primary window context with configurable parameters.
-- @param Config table Specification dictionary containing UI settings, themes, and feature flags.
-- @return WindowObj table Controller object providing methods for Tab and Element creation.
function AuraPro:CreateWindow(Config)
Config = Config or {}
local TitleText = Config.Name or "Aura UI Pro"
local SelectedTheme = Config.Theme or AuraPro.Themes.Dark
local ConfigFileName = Config.ConfigFile or "AuraConfig.json"
local SaveConfigEnabled = Config.SaveConfig or false

-- Scale and Dimensional Geometry Settings
local BaseWidth = Config.Width or 620
local BaseHeight = Config.Height or 420
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Aura_Pro_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = CachedParent

local UIScale = Instance.new("UIScale", ScreenGui)
local function UpdateScale()
    local Camera = workspace.CurrentCamera
    if Camera then
        local ViewSize = Camera.ViewportSize
        if ViewSize.X < BaseWidth + 40 then
            UIScale.Scale = (ViewSize.X / (BaseWidth + 50)) * UserScale
        else
            UIScale.Scale = UserScale
        end
    end
end
UpdateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScale)
end

-- Notification Subsystem Container
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 280, 1, -20)
NotifContainer.Position = UDim2.new(1, -290, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 9999

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)

--- Displays a transient system notification toast.
-- @param NotifConfig table Contains Title, Content, and Display Duration settings.
function AuraPro:Notify(NotifConfig)
    NotifConfig = NotifConfig or {}
    local NTitle = NotifConfig.Title or "Notification"
    local NContent = NotifConfig.Content or ""
    local NTime = NotifConfig.Duration or 3

    local Card = Instance.new("Frame", NotifContainer)
    Card.Size = UDim2.new(1, 0, 0, 65)
    Card.BackgroundColor3 = SelectedTheme.Card
    Card.Position = UDim2.new(1, 320, 0, 0)
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
    ContentLbl.Size = UDim2.new(1, -16, 0, 30)
    ContentLbl.Position = UDim2.new(0, 10, 0, 28)
    ContentLbl.BackgroundTransparency = 1
    ContentLbl.Text = NContent
    ContentLbl.TextColor3 = SelectedTheme.SubText
    ContentLbl.TextSize = 11
    ContentLbl.Font = Enum.Font.Gotham
    ContentLbl.TextXAlignment = Enum.TextXAlignment.Left
    ContentLbl.TextWrapped = true

    TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()

    task.delay(NTime, function()
        local TweenOut = TweenService:Create(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 320, 0, 0)})
        TweenOut:Play()
        TweenOut.Completed:Connect(function()
            Card:Destroy()
        end)
    end)
end

-- Initialization Loading Sequence
if Config.LoadingScreen then
    local LoadFrame = Instance.new("Frame", ScreenGui)
    LoadFrame.Size = UDim2.new(0, 340, 0, 150)
    LoadFrame.Position = UDim2.new(0.5, -170, 0.5, -75)
    LoadFrame.BackgroundColor3 = SelectedTheme.Background
    LoadFrame.ZIndex = 1000
    Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 12)
    
    local LStroke = Instance.new("UIStroke", LoadFrame)
    LStroke.Color = SelectedTheme.Accent

    local LTitle = Instance.new("TextLabel", LoadFrame)
    LTitle.Size = UDim2.new(1, 0, 0, 40)
    LTitle.Position = UDim2.new(0, 0, 0, 18)
    LTitle.BackgroundTransparency = 1
    LTitle.Text = TitleText
    LTitle.TextColor3 = SelectedTheme.Text
    LTitle.TextSize = 16
    LTitle.Font = Enum.Font.GothamBold

    local BarBG = Instance.new("Frame", LoadFrame)
    BarBG.Size = UDim2.new(0.85, 0, 0, 8)
    BarBG.Position = UDim2.new(0.075, 0, 0.65, 0)
    BarBG.BackgroundColor3 = SelectedTheme.Element
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame", BarBG)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = SelectedTheme.Accent
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    TweenService:Create(BarFill, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(1.3)
    TweenService:Create(LoadFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    LoadFrame:Destroy()
end

-- Primary Application Window Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, BaseWidth, 0, BaseHeight)
MainFrame.Position = UDim2.new(0.5, -BaseWidth / 2, 0.5, -BaseHeight / 2)
MainFrame.BackgroundColor3 = SelectedTheme.Background
MainFrame.ClipsDescendants = false

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = SelectedTheme.Border
MainStroke.Thickness = 1.2

MainFrame.Size = UDim2.new(0, BaseWidth * 0.8, 0, BaseHeight * 0.8)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, BaseWidth, 0, BaseHeight),
    BackgroundTransparency = 0
}):Play()

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, -20, 0, 42)
TopBar.Position = UDim2.new(0, 10, 0, 10)
TopBar.BackgroundColor3 = SelectedTheme.Card
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

MakeDraggable(MainFrame, TopBar)

local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.03, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = TitleText
TitleLabel.TextColor3 = SelectedTheme.Text
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(235, 60, 60)
CloseBtn.BackgroundTransparency = 0.8
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, BaseWidth * 0.8, 0, BaseHeight * 0.8),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.25)
    ScreenGui:Destroy()
end)

-- Authentication Key Verification Subsystem
if Config.KeySystem and Config.KeySystem.Enabled then
    local KeyConfig = Config.KeySystem
    local KeyOverlay = Instance.new("Frame", MainFrame)
    KeyOverlay.Size = UDim2.new(1, 0, 1, 0)
    KeyOverlay.BackgroundColor3 = SelectedTheme.Background
    KeyOverlay.ZIndex = 500
    Instance.new("UICorner", KeyOverlay).CornerRadius = UDim.new(0, 12)

    local KeyCard = Instance.new("Frame", KeyOverlay)
    KeyCard.Size = UDim2.new(0, 340, 0, 210)
    KeyCard.Position = UDim2.new(0.5, -170, 0.5, -105)
    KeyCard.BackgroundColor3 = SelectedTheme.Card
    KeyCard.ZIndex = 501
    Instance.new("UICorner", KeyCard).CornerRadius = UDim.new(0, 10)
    local KStroke = Instance.new("UIStroke", KeyCard)
    KStroke.Color = SelectedTheme.Accent

    local KeyTitle = Instance.new("TextLabel", KeyCard)
    KeyTitle.Size = UDim2.new(1, 0, 0, 42)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = KeyConfig.Title or "🔑 Key System"
    KeyTitle.TextColor3 = SelectedTheme.Accent
    KeyTitle.TextSize = 15
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.ZIndex = 502

    local KeyInput = Instance.new("TextBox", KeyCard)
    KeyInput.Size = UDim2.new(0.85, 0, 0, 40)
    KeyInput.Position = UDim2.new(0.075, 0, 0.3, 0)
    KeyInput.BackgroundColor3 = SelectedTheme.Element
    KeyInput.PlaceholderText = "Enter key here..."
    KeyInput.PlaceholderColor3 = SelectedTheme.SubText
    KeyInput.Text = ""
    KeyInput.TextColor3 = SelectedTheme.Text
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.ZIndex = 502
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

    local SubmitBtn = Instance.new("TextButton", KeyCard)
    SubmitBtn.Size = UDim2.new(0.4, 0, 0, 38)
    SubmitBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
    SubmitBtn.BackgroundColor3 = SelectedTheme.Accent
    SubmitBtn.Text = "Submit Key"
    SubmitBtn.TextColor3 = SelectedTheme.Background
    SubmitBtn.TextSize = 12
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.ZIndex = 502
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

    local GetKeyBtn = Instance.new("TextButton", KeyCard)
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 38)
    GetKeyBtn.Position = UDim2.new(0.525, 0, 0.62, 0)
    GetKeyBtn.BackgroundColor3 = SelectedTheme.Element
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = SelectedTheme.Text
    GetKeyBtn.TextSize = 12
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.ZIndex = 502
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

    SubmitBtn.MouseButton1Click:Connect(function()
        local InputtedKey = KeyInput.Text
        if InputtedKey == (KeyConfig.Key or "") then
            AuraPro:Notify({Title = "Success", Content = "Key verified successfully!"})
            TweenService:Create(KeyOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            KeyOverlay:Destroy()
        else
            AuraPro:Notify({Title = "Error", Content = "Invalid Key! Please try again."})
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        local Link = KeyConfig.Link or ""
        if setclipboard and Link ~= "" then
            setclipboard(Link)
            AuraPro:Notify({Title = "Clipboard", Content = "Key link copied to clipboard!"})
        end
    end)
end

-- Tab Navigation Area
local TabBarWidth = 140
local TabBar = Instance.new("ScrollingFrame", MainFrame)
TabBar.Size = UDim2.new(0, TabBarWidth, 1, -65)
TabBar.Position = UDim2.new(0, 10, 0, 58)
TabBar.BackgroundColor3 = SelectedTheme.Card
TabBar.ScrollBarThickness = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Padding = UDim.new(0, 5)

local TabPadding = Instance.new("UIPadding", TabBar)
TabPadding.PaddingTop = UDim.new(0, 6)
TabPadding.PaddingLeft = UDim.new(0, 6)

local PagesArea = Instance.new("Frame", MainFrame)
PagesArea.Size = UDim2.new(1, -(TabBarWidth + 30), 1, -65)
PagesArea.Position = UDim2.new(0, TabBarWidth + 20, 0, 58)
PagesArea.BackgroundColor3 = SelectedTheme.Card
PagesArea.ClipsDescendants = true
Instance.new("UICorner", PagesArea).CornerRadius = UDim.new(0, 8)

local WindowObj = { CurrentTab = nil, Tabs = {} }

function WindowObj:SetScale(NewScale)
    UserScale = NewScale or 1.0
    UpdateScale()
end

function WindowObj:CreateTab(TabName)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(0, TabBarWidth - 12, 0, 34)
    TabBtn.BackgroundColor3 = SelectedTheme.Element
    TabBtn.BackgroundTransparency = 0.6
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
        PageFrame.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
    end)

    TabBtn.MouseButton1Click:Connect(function()
        if WindowObj.CurrentTab == PageFrame then return end
        
        for _, TabData in ipairs(WindowObj.Tabs) do
            if TabData.Page.Visible then
                TweenService:Create(TabData.Page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 6, 0, 20)
                }):Play()
                task.delay(0.15, function()
                    TabData.Page.Visible = false
                end)
            end
            TweenService:Create(TabData.Btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.6,
                TextColor3 = SelectedTheme.SubText
            }):Play()
        end

        task.wait(0.15)
        WindowObj.CurrentTab = PageFrame
        PageFrame.Position = UDim2.new(0, 6, 0, -10)
        PageFrame.Visible = true
        TweenService:Create(PageFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 6, 0, 6)
        }):Play()

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

    table.insert(WindowObj.Tabs, { Btn = TabBtn, Page = PageFrame })

    local TabElements = {}

    function TabElements:CreateSection(Text)
        local SecLabel = Instance.new("TextLabel", PageFrame)
        SecLabel.Size = UDim2.new(0.98, 0, 0, 24)
        SecLabel.BackgroundTransparency = 1
        SecLabel.Text = "• " .. string.upper(Text)
        SecLabel.TextColor3 = SelectedTheme.Accent
        SecLabel.TextSize = 11
        SecLabel.Font = Enum.Font.GothamBold
        SecLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    function TabElements:CreateLabel(Text)
        local Label = Instance.new("TextLabel", PageFrame)
        Label.Size = UDim2.new(0.98, 0, 0, 24)
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = SelectedTheme.SubText
        Label.TextSize = 12
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
    end

    function TabElements:CreateParagraph(Config)
        local Title = Config.Title or "Paragraph"
        local Content = Config.Content or ""

        local ParaFrame = Instance.new("Frame", PageFrame)
        ParaFrame.Size = UDim2.new(0.98, 0, 0, 56)
        ParaFrame.BackgroundColor3 = SelectedTheme.Element
        Instance.new("UICorner", ParaFrame).CornerRadius = UDim.new(0, 6)

        local PTitle = Instance.new("TextLabel", ParaFrame)
        PTitle.Size = UDim2.new(1, -16, 0, 20)
        PTitle.Position = UDim2.new(0, 8, 0, 4)
        PTitle.BackgroundTransparency = 1
        PTitle.Text = Title
        PTitle.TextColor3 = SelectedTheme.Text
        PTitle.TextSize = 12
        PTitle.Font = Enum.Font.GothamBold
        PTitle.TextXAlignment = Enum.TextXAlignment.Left

        local PContent = Instance.new("TextLabel", ParaFrame)
        PContent.Size = UDim2.new(1, -16, 0, 30)
        PContent.Position = UDim2.new(0, 8, 0, 22)
        PContent.BackgroundTransparency = 1
        PContent.Text = Content
        PContent.TextColor3 = SelectedTheme.SubText
        PContent.TextSize = 11
        PContent.Font = Enum.Font.Gotham
        PContent.TextXAlignment = Enum.TextXAlignment.Left
        PContent.TextWrapped = true
    end

    function TabElements:CreateDivider()
        local Div = Instance.new("Frame", PageFrame)
        Div.Size = UDim2.new(0.98, 0, 0, 1)
        Div.BackgroundColor3 = SelectedTheme.Border
        Div.BorderSizePixel = 0
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
            TweenService:Create(Btn, TweenInfo.new(0.08), {Size = UDim2.new(0.95, 0, 0, 34)}):Play()
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

    function TabElements:CreateDropdown(Config)
        local Name = Config.Name or "Dropdown"
        local Flag = Config.Flag or Name
        local Options = Config.Options or {}
        local Default = SavedData[Flag] or Config.Default or Options[1]
        local Callback = Config.Callback or function() end
        local Expanded = false

        SavedData[Flag] = Default

        local DropFrame = Instance.new("Frame", PageFrame)
        DropFrame.Size = UDim2.new(0.98, 0, 0, 36)
        DropFrame.BackgroundColor3 = SelectedTheme.Element
        DropFrame.ClipsDescendants = true
        Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke", DropFrame)
        Stroke.Color = SelectedTheme.Border

        local HeaderBtn = Instance.new("TextButton", DropFrame)
        HeaderBtn.Size = UDim2.new(1, 0, 0, 36)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = "    " .. Name .. " [" .. tostring(Default) .. "]"
        HeaderBtn.TextColor3 = SelectedTheme.Text
        HeaderBtn.TextSize = 12
        HeaderBtn.Font = Enum.Font.GothamMedium
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

        local Arrow = Instance.new("TextLabel", HeaderBtn)
        Arrow.Size = UDim2.new(0, 30, 1, 0)
        Arrow.Position = UDim2.new(1, -30, 0, 0)
        Arrow.BackgroundTransparency = 1
        Arrow.Text = "▼"
        Arrow.TextColor3 = SelectedTheme.SubText
        Arrow.TextSize = 10

        local OptionContainer = Instance.new("Frame", DropFrame)
        OptionContainer.Size = UDim2.new(1, 0, 0, #Options * 28)
        OptionContainer.Position = UDim2.new(0, 0, 0, 36)
        OptionContainer.BackgroundTransparency = 1

        local OptionLayout = Instance.new("UIListLayout", OptionContainer)
        OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder

        for _, OptName in ipairs(Options) do
            local OptBtn = Instance.new("TextButton", OptionContainer)
            OptBtn.Size = UDim2.new(1, 0, 0, 28)
            OptBtn.BackgroundColor3 = SelectedTheme.Card
            OptBtn.Text = OptName
            OptBtn.TextColor3 = SelectedTheme.SubText
            OptBtn.TextSize = 11
            OptBtn.Font = Enum.Font.Gotham

            OptBtn.MouseButton1Click:Connect(function()
                HeaderBtn.Text = "    " .. Name .. " [" .. OptName .. "]"
                Expanded = false
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.98, 0, 0, 36)}):Play()
                Arrow.Text = "▼"
                SavedData[Flag] = OptName
                SaveCurrentConfig()
                pcall(Callback, OptName)
            end)
        end

        HeaderBtn.MouseButton1Click:Connect(function()
            Expanded = not Expanded
            if Expanded then
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.98, 0, 0, 36 + (#Options * 28))}):Play()
                Arrow.Text = "▲"
            else
                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(0.98, 0, 0, 36)}):Play()
                Arrow.Text = "▼"
            end
        end)
    end

    function TabElements:CreateTextbox(Config)
        local Name = Config.Name or "Textbox"
        local Flag = Config.Flag or Name
        local Placeholder = Config.Placeholder or "Type here..."
        local Default = SavedData[Flag] or Config.Default or ""
        local ClearOnFocus = Config.ClearOnFocus or false
        local Callback = Config.Callback or function() end

        SavedData[Flag] = Default

        local BoxFrame = Instance.new("Frame", PageFrame)
        BoxFrame.Size = UDim2.new(0.98, 0, 0, 38)
        BoxFrame.BackgroundColor3 = SelectedTheme.Element
        Instance.new("UICorner", BoxFrame).CornerRadius = UDim.new(0, 6)
        local Stroke = Instance.new("UIStroke", BoxFrame)
        Stroke.Color = SelectedTheme.Border

        local Label = Instance.new("TextLabel", BoxFrame)
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = Name
        Label.TextColor3 = SelectedTheme.Text
        Label.TextSize = 12
        Label.Font = Enum.Font.GothamMedium
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local InputBox = Instance.new("TextBox", BoxFrame)
        InputBox.Size = UDim2.new(0.45, -10, 0, 26)
        InputBox.Position = UDim2.new(0.52, 0, 0.5, -13)
        InputBox.BackgroundColor3 = SelectedTheme.Card
        InputBox.PlaceholderText = Placeholder
        InputBox.PlaceholderColor3 = SelectedTheme.SubText
        InputBox.Text = Default
        InputBox.TextColor3 = SelectedTheme.Text
        InputBox.TextSize = 11
        InputBox.Font = Enum.Font.Gotham
        InputBox.ClearTextOnFocus = ClearOnFocus
        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)

        local InputStroke = Instance.new("UIStroke", InputBox)
        InputStroke.Color = SelectedTheme.Border

        InputBox.FocusLost:Connect(function(EnterPressed)
            SavedData[Flag] = InputBox.Text
            SaveCurrentConfig()
            pcall(Callback, InputBox.Text, EnterPressed)
        end)
    end

    return TabElements
end

return WindowObj


end

return AuraPro
