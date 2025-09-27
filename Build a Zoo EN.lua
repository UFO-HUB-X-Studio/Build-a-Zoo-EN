--========================================================
-- UFO HUB X — FULL PACK (Big UI + 2-Pane Scrollers + Tabs)
-- เลื่อนขึ้นลงได้ทั้ง "เมนูซ้าย" และ "คอนเทนต์ขวา"
-- มีหน้า Home/Shop ตัวอย่าง + ปุ่มสลับหน้า + API _G.UFOX
--========================================================

-------------------- Services --------------------
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CG      = game:GetService("CoreGui")
local Camera  = workspace.CurrentCamera
local Players = game:GetService("Players")

-------------------- THEME --------------------
local ACCENT  = Color3.fromRGB(0,255,140)
local BG      = Color3.fromRGB(12,12,12)
local FG      = Color3.fromRGB(230,230,230)
local SUB     = Color3.fromRGB(22,22,22)
local D_GREY  = Color3.fromRGB(16,16,16)
local LOGO_ID = 112676905543996

-------------------- CLEAN PREVIOUS --------------------
for _, name in ipairs({"UFOHubX_Main","UFOHubX_Toggle"}) do
    local old = CG:FindFirstChild(name)
    if old then old:Destroy() end
end

-------------------- Helpers --------------------
local function safeParent(gui)
    local ok=false
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then gui.Parent = CG end
end
local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end
local function tween(obj, ti, goal) TS:Create(obj, ti, goal):Play() end

-------------------- ScreenGuis --------------------
local mainGui   = make("ScreenGui",{Name="UFOHubX_Main", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling},{})
local toggleGui = make("ScreenGui",{Name="UFOHubX_Toggle", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling},{})
safeParent(mainGui); safeParent(toggleGui)

-------------------- MAIN WINDOW --------------------
local main = make("Frame",{
    Name="Main", Parent=mainGui, Size=UDim2.new(0,640,0,400),
    BackgroundColor3=BG, BorderSizePixel=0, Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,16)}),
    make("UIStroke",{Thickness=2, Color=ACCENT, Transparency=0.08}),
    make("UIGradient",{Rotation=90, Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)),
        ColorSequenceKeypoint.new(1, BG)
    }})
})

-- Top bar
local top = make("Frame",{Parent=main, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1},{})
make("ImageLabel",{Parent=top, BackgroundTransparency=1, Image="rbxassetid://"..LOGO_ID, Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,16,0,12)},{})
local title = make("Frame",{Parent=top, BackgroundTransparency=1, Size=UDim2.new(1,-160,1,0), Position=UDim2.new(0,50,0,0)},{})
make("UIListLayout",{Parent=title, FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
    HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center},{})
make("TextLabel",{Parent=title, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,1,0),
    Font=Enum.Font.GothamBold, TextSize=22, Text="UFO", TextColor3=ACCENT},{})
make("TextLabel",{Parent=title, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X, Size=UDim2.new(0,0,1,0),
    Font=Enum.Font.GothamBold, TextSize=22, Text="HUB X", TextColor3=Color3.new(1,1,1)},{})
local underline = make("Frame",{Parent=top, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), BackgroundColor3=ACCENT},{
    make("UIGradient",{Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.7), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,0.7)
    }})
})

local function neonButton(parent, text, xOff)
    return make("TextButton",{
        Parent=parent, Text=text, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=FG,
        BackgroundColor3=SUB, Size=UDim2.new(0,36,0,36), Position=UDim2.new(1,xOff,0,7),
        AutoButtonColor=false
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Color=ACCENT, Transparency=0.75})
    })
end
local btnMini  = neonButton(top,"–",-88)
local btnClose = neonButton(top,"", -46); btnClose.BackgroundColor3 = Color3.fromRGB(210,35,50)
local function mkX(rot)
    local b = Instance.new("Frame"); b.Parent=btnClose; b.AnchorPoint=Vector2.new(0.5,0.5)
    b.Position=UDim2.new(0.5,0,0.5,0); b.Size=UDim2.new(0,18,0,2)
    b.BackgroundColor3=Color3.new(1,1,1); b.BorderSizePixel=0; b.Rotation=rot
    Instance.new("UICorner", b).CornerRadius=UDim.new(0,1)
end
mkX(45); mkX(-45)

-- Sidebar (LEFT) : container + scroller
local leftContainer = make("Frame",{
    Parent=main, Size=UDim2.new(0,180,1,-60), Position=UDim2.new(0,12,0,55),
    BackgroundColor3=Color3.fromRGB(18,18,18)
},{
    make("UICorner",{CornerRadius=UDim.new(0,12)}),
    make("UIStroke",{Color=ACCENT, Transparency=0.85})
})

local leftScroll = make("ScrollingFrame",{
    Name="UFOX_LeftScroll", Parent=leftContainer, Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true,
    ScrollingDirection=Enum.ScrollingDirection.Y, ScrollBarThickness=8,
    VerticalScrollBarInset=Enum.ScrollBarInset.Always, ScrollBarImageColor3=ACCENT,
    ScrollBarImageTransparency=0.05
},{})
pcall(function() leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
make("UIPadding",{Parent=leftScroll, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)},{})
local leftList = make("UIListLayout",{
    Parent=leftScroll, FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,10),
    HorizontalAlignment=Enum.HorizontalAlignment.Stretch, VerticalAlignment=Enum.VerticalAlignment.Top,
    SortOrder=Enum.SortOrder.LayoutOrder
},{})

-- Content (RIGHT) : container + scroller
local contentContainer = make("Frame",{
    Parent=main, Size=UDim2.new(1,-220,1,-70), Position=UDim2.new(0,200,0,60),
    BackgroundColor3=D_GREY
},{
    make("UICorner",{CornerRadius=UDim.new(0,12)}),
    make("UIStroke",{Color=ACCENT, Transparency=0.8})
})

local rightScroll = make("ScrollingFrame",{
    Name="UFOX_RightScroll", Parent=contentContainer, Size=UDim2.fromScale(1,1),
    BackgroundTransparency=1, BorderSizePixel=0, ClipsDescendants=true,
    ScrollingDirection=Enum.ScrollingDirection.Y, ScrollBarThickness=8,
    VerticalScrollBarInset=Enum.ScrollBarInset.Always, ScrollBarImageColor3=ACCENT,
    ScrollBarImageTransparency=0.05
},{})
pcall(function() rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)
make("UIPadding",{Parent=rightScroll, PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)},{})
local rightList = make("UIListLayout",{
    Parent=rightScroll, FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,10),
    HorizontalAlignment=Enum.HorizontalAlignment.Stretch, VerticalAlignment=Enum.VerticalAlignment.Top,
    SortOrder=Enum.SortOrder.LayoutOrder
},{})

-- Fallback canvas update (ถ้าสตูดิโอไม่รองรับ AutomaticCanvasSize)
local function updateCanvas(sc, list)
    local sum=0
    for _,c in ipairs(sc:GetChildren()) do
        if c:IsA("GuiObject") and not c:IsA("UIPadding") and not c:IsA("UIListLayout") then
            sum += c.AbsoluteSize.Y + list.Padding.Offset
        end
    end
    sc.CanvasSize = UDim2.new(0,0,0,sum + 10)
end
leftList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    leftScroll.CanvasPosition = Vector2.new(0,0); updateCanvas(leftScroll,leftList)
end)
rightList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    rightScroll.CanvasPosition = Vector2.new(0,0); updateCanvas(rightScroll,rightList)
end)

-------------------- Tabs (Home / Shop) --------------------
local function mkSideBtn(name, icon, order)
    local btn = make("TextButton",{
        Name=name, Parent=leftScroll, LayoutOrder=order or 1,
        AutoButtonColor=false, Text="", Size=UDim2.new(1, -4, 0, 44),
        BackgroundColor3=SUB
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Name="Stroke", Color=ACCENT, Thickness=2, Transparency=0})
    })
    local row = make("Frame",{Parent=btn, BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)},{
        make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
            HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center})
    })
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
        Font=Enum.Font.GothamBold, TextSize=16, Text=icon, TextColor3=FG},{})
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
        Font=Enum.Font.GothamBold, TextSize=15, Text=name:gsub("^UFOX_",""), TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG},{})
    return btn
end

local btnHome = mkSideBtn("UFOX_HomeBtn","🏠",1)
local btnShop = mkSideBtn("UFOX_ShopBtn","🛒",2)

-- หน้าคอนเทนต์ (วางเป็น "Page Frame" ใน rightScroll)
local function mkPage(name, order)
    local pg = make("Frame",{
        Name=name, Parent=rightScroll, LayoutOrder=order or 1,
        BackgroundTransparency=1, Size=UDim2.new(1,-4, 0, 0), AutomaticSize=Enum.AutomaticSize.Y
    },{})
    return pg
end

local pgHome = mkPage("pgHome",1)
local pgShop = mkPage("pgShop",2)

-- ตัวอย่างคอนเทนต์ใน Home
local function mkCard(parent, titleText, height)
    local card = make("Frame",{
        Parent=parent, BackgroundColor3=Color3.fromRGB(18,18,18),
        Size=UDim2.new(1, -4, 0, height or 56)
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Color=ACCENT, Transparency=0.15, Thickness=2})
    })
    make("TextLabel",{Parent=card, BackgroundTransparency=1, Text=titleText, Font=Enum.Font.GothamBold,
        TextSize=16, TextColor3=FG, TextXAlignment=Enum.TextXAlignment.Left, Size=UDim2.new(1,-24,1,0),
        Position=UDim2.new(0,12,0,0)},{})
    return card
end
mkCard(pgHome,"AFK / Auto Collect / Auto Egg Hatch",56)
mkCard(pgHome,"Tips: เพิ่มเมนู/ระบบอื่นได้เรื่อย ๆ",56)

-- ตัวอย่างคอนเทนต์ใน Shop
mkCard(pgShop,"Shop — Coming Soon",120)

-- สลับหน้า
local function setTabActive(which)
    local isHome = (which=="Home")
    pgHome.Visible = isHome
    pgShop.Visible = not isHome
    rightScroll.CanvasPosition = Vector2.new(0,0)

    local stH = btnHome:FindFirstChild("Stroke")
    local stS = btnShop:FindFirstChild("Stroke")
    if stH then stH.Transparency = isHome and 0 or 0.4 end
    if stS then stS.Transparency = (not isHome) and 0 or 0.4 end
end
btnHome.MouseButton1Click:Connect(function() setTabActive("Home") end)
btnShop.MouseButton1Click:Connect(function() setTabActive("Shop") end)
setTabActive("Home") -- เปิดมาหน้า Home เสมอ

-------------------- Toggle Button (dock + drag) --------------------
local btnToggle = make("ImageButton",{
    Parent=toggleGui, Size=UDim2.new(0,64,0,64), BackgroundColor3=SUB,
    AutoButtonColor=false, ClipsDescendants=true, Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.1})
})
make("ImageLabel",{Parent=btnToggle, BackgroundTransparency=1, Size=UDim2.new(1,-6,1,-6), Position=UDim2.new(0,3,0,3),
    Image="rbxassetid://"..LOGO_ID, ScaleType=Enum.ScaleType.Stretch},{
    make("UICorner",{CornerRadius=UDim.new(0,8)})
})
local hidden=false
local function setHidden(s) hidden=s; mainGui.Enabled = not hidden end
btnToggle.MouseButton1Click:Connect(function() setHidden(not hidden) end)
UIS.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightControl then setHidden(not hidden) end end)

-- ย่อ/ขยาย
local collapsed=false
local originalSize = main.Size
btnMini.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    if collapsed then
        leftContainer.Visible=false; contentContainer.Visible=false; underline.Visible=false
        tween(main, TweenInfo.new(.2), {Size=UDim2.new(0,640,0,56)})
        btnMini.Text="▢"
    else
        leftContainer.Visible=true; contentContainer.Visible=true; underline.Visible=true
        tween(main, TweenInfo.new(.2), {Size=originalSize})
        btnMini.Text="–"
    end
end)
btnClose.MouseButton1Click:Connect(function() setHidden(true) end)

-------------------- Center on screen + dock toggle left --------------------
local X_OFFSET, Y_OFFSET, TOGGLE_GAP, TOGGLE_DY = 18, -40, 60, -70
local CENTER_TWEEN, CENTER_TIME, TOGGLE_DOCKED = true, 0.25, true
local function tweenPos(obj, pos) tween(obj, TweenInfo.new(CENTER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = pos}) end
local function dockToggleToMain()
    local mPos, mSize = main.AbsolutePosition, main.AbsoluteSize
    local tX = math.floor(mPos.X - btnToggle.AbsoluteSize.X - TOGGLE_GAP)
    local tY = math.floor(mPos.Y + (mSize.Y - btnToggle.AbsoluteSize.Y)/2 + TOGGLE_DY)
    btnToggle.Position = UDim2.fromOffset(tX, tY)
end
local function centerMain(animated)
    local vp = Camera.ViewportSize
    local target = UDim2.fromOffset(
        math.floor((vp.X - main.AbsoluteSize.X)/2) + X_OFFSET,
        math.floor((vp.Y - main.AbsoluteSize.Y)/2) + Y_OFFSET
    )
    if animated and CENTER_TWEEN then tweenPos(main, target) else main.Position = target end
    if TOGGLE_DOCKED then dockToggleToMain() end
end
centerMain(false)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() centerMain(false) end)
main.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 and TOGGLE_DOCKED then
        dockToggleToMain()
    end
end)
btnToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TOGGLE_DOCKED = false
    end
end)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F9 then
        TOGGLE_DOCKED = true; centerMain(true)
    elseif i.KeyCode==Enum.KeyCode.F8 then
        TOGGLE_DOCKED = not TOGGLE_DOCKED
        if TOGGLE_DOCKED then dockToggleToMain() end
    end
end)

-------------------- PUBLIC API (เพื่ออนาคต) --------------------
_G.UFOX = _G.UFOX or {}
_G.UFOX.GetScrollers = function() return leftScroll, rightScroll end
_G.UFOX.AddSection = function(side, text)
    local parent = (side=="left") and leftScroll or rightScroll
    local h = Instance.new("TextLabel")
    h.Name = "Section_"..(text or "Section")
    h.Parent = parent
    h.BackgroundTransparency = 1
    h.Font = Enum.Font.GothamBold
    h.TextSize = 16
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.TextColor3 = ACCENT
    h.Text = tostring(text or "Section")
    h.Size = UDim2.new(1,-4,0,18)
    return h
end
_G.UFOX.AddCard = function(side, titleText, height)
    local parent = (side=="left") and leftScroll or rightScroll
    local card = Instance.new("Frame")
    card.Parent = parent
    card.BackgroundColor3 = Color3.fromRGB(18,18,18)
    card.Size = UDim2.new(1,-4,0,height or 56)
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,10)
    local st = Instance.new("UIStroke", card); st.Color=ACCENT; st.Transparency=0.15; st.Thickness=2
    local lb = Instance.new("TextLabel")
    lb.Parent=card; lb.BackgroundTransparency=1; lb.Font=Enum.Font.GothamBold; lb.TextSize=16
    lb.TextColor3=FG; lb.TextXAlignment=Enum.TextXAlignment.Left; lb.Text=titleText or "Card"
    lb.Size=UDim2.new(1,-24,1,0); lb.Position=UDim2.new(0,12,0,0)
    return card
end
