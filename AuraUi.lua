--[[
Aura Pro UI Library - Upgraded Edition with Native Key System & Scaled UI Engine
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

-- Xóa instance cũ để tránh trùng lặp
local PreexistingInstance = CachedParent:FindFirstChild("Aura_Pro_UI")
if PreexistingInstance then PreexistingInstance:Destroy() end
local PreexistingKey = CachedParent:FindFirstChild("Aura_KeySystem_UI")
if PreexistingKey then PreexistingKey:Destroy() end

local AuraPro = {}
AuraPro.Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 19, 24),
        Card = Color3.fromRGB(25, 27, 34),
        Element = Color3.fromRGB(33, 36, 46),
        Border = Color3.fromRGB(48, 52, 66),
        Text = Color3.fromRGB(240, 242, 248),
        SubText = Color3.fromRGB(145, 152, 172),
        Accent = Color3.fromRGB(99, 102, 241),
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
        Accent = Color3.fromRGB(14, 165, 233),
        AccentHover = Color3.fromRGB(56, 189, 248),
        Success = Color3.fromRGB(16, 185, 129),
        Danger = Color3.fromRGB(244, 63, 94)
    }
}

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

--- KEY SYSTEM (Hiển thị bắt buộc đầu tiên dưới dạng cửa sổ độc lập có Scale tự động)
function AuraPro:CreateKeySystem(Config)
    Config = Config or {}
    local TitleText = Config.Name or "Aura UI - Key System"
    local CorrectKey = Config.Key or "AuraPro2026"
    local LinkToGet = Config.Link or ""
    local SelectedTheme = Config.Theme or AuraPro.Themes.Dark
    local UserScale = (Config.Scale or 1.0) * 1.1 -- Đẩy scale mặc định lên thêm 1 tí cho rõ nét
    local Callback = Config.Callback or function() end

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "Aura_KeySystem_UI"
    KeyGui.ResetOnSpawn = false
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.Parent = CachedParent

    local MainFrame = Instance.new("Frame", KeyGui)
    MainFrame.Size = UDim2.new(0, 380, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
    MainFrame.BackgroundColor3 = SelectedTheme.Background
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = SelectedTheme.Border
    Stroke.Thickness = 1.2

    -- Scale Engine cho Key System
    local KeyUIScale = Instance.new("UIScale", MainFrame)
    local function UpdateKeyScale()
        local Camera = Workspace.CurrentCamera
        local ViewportScale = 1
        if Camera then
            local ViewSize = Camera.ViewportSize
            if ViewSize.X < 440 or ViewSize.Y < 280 then
                ViewportScale = math.min(ViewSize.X / 440, ViewSize.Y / 280)
            end
        end
        KeyUIScale.Scale = UserScale * ViewportScale
    end
    UpdateKeyScale()
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateKeyScale)
    end

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, -16, 0, 36)
    TopBar.Position = UDim2.new(0, 8, 0, 8)
    TopBar.BackgroundColor3 = SelectedTheme.Card
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)
    MakeDraggable(MainFrame, TopBar)

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Size = UDim2.new(1, -12, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = TitleText
    TitleLabel.TextColor3 = SelectedTheme.Text
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local KeyBox = Instance.new("TextBox", MainFrame)
    KeyBox.Size = UDim2.new(1, -24, 0, 38)
    KeyBox.Position = UDim2.new(0, 12, 0, 58)
    KeyBox.BackgroundColor3 = SelectedTheme.Element
    KeyBox.PlaceholderText = "Nhập Key vào đây..."
    KeyBox.PlaceholderColor3 = SelectedTheme.SubText
    KeyBox.Text = ""
    KeyBox.TextColor3 = SelectedTheme.Text
    KeyBox.TextSize = 12
    KeyBox.Font = Enum.Font.Gotham
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 6)

    local SubmitBtn = Instance.new("TextButton", MainFrame)
    SubmitBtn.Size = UDim2.new(1, -24, 0, 36)
    SubmitBtn.Position = UDim2.new(0, 12, 0, 106)
    SubmitBtn.BackgroundColor3 = SelectedTheme.Accent
    SubmitBtn.Text = "XÁC NHẬN KEY"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 12
    SubmitBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 6)

    local GetKeyBtn = Instance.new("TextButton", MainFrame)
    GetKeyBtn.Size = UDim2.new(1, -24, 0, 32)
    GetKeyBtn.Position = UDim2.new(0, 12, 0, 150)
    GetKeyBtn.BackgroundColor3 = SelectedTheme.Element
    GetKeyBtn.Text = "LẤY KEY"
    GetKeyBtn.TextColor3 = SelectedTheme.SubText
    GetKeyBtn.TextSize = 11
    GetKeyBtn.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 6)

    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyBox.Text == CorrectKey then
            SubmitBtn.Text = "THÀNH CÔNG!"
            SubmitBtn.BackgroundColor3 = SelectedTheme.Success
            task.wait(0.5)
            KeyGui:Destroy()
            pcall(Callback) -- Chuyển tiếp mở giao diện chính sau khi đúng Key
        else
            SubmitBtn.Text = "SAI KEY!"
            SubmitBtn.BackgroundColor3 = SelectedTheme.Danger
            task.wait(1)
            SubmitBtn.Text = "XÁC NHẬN KEY"
            SubmitBtn.BackgroundColor3 = SelectedTheme.Accent
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(LinkToGet)
            GetKeyBtn.Text = "ĐÃ COPY LINK LẤY KEY!"
            task.wait(2)
            GetKeyBtn.Text = "LẤY KEY"
        else
            GetKeyBtn.Text = "Executor không hỗ trợ sao chép"
        end
    end)
end

--- MAIN WINDOW ENGINE
function AuraPro:CreateWindow(Config)
Config = Config or {}
local TitleText = Config.Name or "Aura UI Pro"
local SelectedTheme = Config.Theme or AuraPro.Themes.Dark
local ConfigFileName = Config.ConfigFile or "AuraConfig.json"
local SaveConfigEnabled = Config.SaveConfig or false
local ToggleKey = Config.ToggleKey or Enum.KeyCode.RightControl

local BaseWidth = Config.Width or 640
local BaseHeight = Config.Height or 440
-- Mặc định tăng tỉ lệ Scale lên thêm một chút (nhân 1.1) theo yêu cầu giao diện to rõ, sắc nét hơn
local UserScale = (Config.Scale or 1.0) * 1.1

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
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CachedParent

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

-- UNIFORM RESPONSIVE SCALE ENGINE CHO TOÀN BỘ BUTTON, TOGGLE, SLIDER BÊN TRONG
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

local TabBarWidth = 150
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(0, TabBarWidth, 1, -65)
TabBar.Position = UDim2.new(0, 10, 0, 58)
TabBar.BackgroundColor3 = SelectedTheme.Card
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

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

function WindowObj:SetScale(NewScale)
    UserScale = math.clamp((NewScale or 1.0) * 1.1, 0.5, 2.2)
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

        Btn.MouseButton1Click:Connect(function()
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

    return TabElements
end

return WindowObj
end
return AuraPro
