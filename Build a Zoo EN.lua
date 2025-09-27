--========================================================
-- UFO HUB X — FULL (now with Home button + AFK switch)
--========================================================

-------------------- Services --------------------
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CG      = game:GetService("CoreGui")
local Camera  = workspace.CurrentCamera
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-------------------- CONFIG --------------------
local LOGO_ID      = 112676905543996  -- โลโก้
local X_OFFSET     = 18               -- ขยับ UI ใหญ่ไปขวา (+ขวา, -ซ้าย)
local Y_OFFSET     = -40              -- ขยับ UI ใหญ่ขึ้น/ลง (ลบ=ขึ้น, บวก=ลง)
local TOGGLE_GAP   = 60               -- ระยะห่าง ปุ่ม ↔ ขอบซ้าย UI ใหญ่
local TOGGLE_DY    = -70              -- ยกปุ่มขึ้นจากกึ่งกลางแนวตั้ง (ลบ=สูงขึ้น)
local CENTER_TWEEN = true
local CENTER_TIME  = 0.25
local TOGGLE_DOCKED = true            -- เริ่มแบบเกาะซ้าย

-- AFK
local INTERVAL_SEC = 5*60             -- กี่วินาทีต่อหนึ่งครั้งคลิก (5 นาที)

-------------------- Helpers --------------------
local function safeParent(gui)
    local ok=false
    if syn and syn.protect_gui then pcall(function() syn.protect_gui(gui) end) end
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then gui.Parent = CG end
end
local function make(class, props, children)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    for _,c in ipairs(children or {}) do c.Parent = o end
    return o
end
local function tweenPos(obj, pos)
    TS:Create(obj, TweenInfo.new(CENTER_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = pos}):Play()
end

-------------------- Theme --------------------
local ACCENT = Color3.fromRGB(0,255,140)
local BG     = Color3.fromRGB(12,12,12)
local FG     = Color3.fromRGB(230,230,230)
local SUB    = Color3.fromRGB(22,22,22)
local D_GREY = Color3.fromRGB(16,16,16)
local OFFCOL = Color3.fromRGB(210,60,60)

-------------------- ScreenGuis --------------------
local mainGui   = make("ScreenGui", {Name="UFOHubX_Main", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
local toggleGui = make("ScreenGui", {Name="UFOHubX_Toggle", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling}, {})
safeParent(mainGui); safeParent(toggleGui)

-------------------- MAIN WINDOW --------------------
local main = make("Frame", {
    Name="Main", Parent=mainGui, Size=UDim2.new(0,620,0,380),
    BackgroundColor3=BG, BorderSizePixel=0, Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,16)}),
    make("UIStroke",{Thickness=2, Color=ACCENT, Transparency=0.08}),
    make("UIGradient",{Rotation=90, Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18,18,18)),
        ColorSequenceKeypoint.new(1, BG)
    }})
})

-- Top bar ------------------------------------------------
local top = make("Frame", {Parent=main, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1},{})

make("ImageLabel", {
    Parent=top, BackgroundTransparency=1, Image="rbxassetid://"..LOGO_ID,
    Size=UDim2.new(0,26,0,26), Position=UDim2.new(0,16,0,12)
}, {})

-- ชื่อ 2 สี: UFO (เขียว) + HUB X (ขาว)
local titleFrame = make("Frame", {
    Parent=top, BackgroundTransparency=1, Size=UDim2.new(1,-160,1,0),
    Position=UDim2.new(0,50,0,0)
},{})
make("UIListLayout", {Parent=titleFrame, FillDirection=Enum.FillDirection.Horizontal,
    HorizontalAlignment=Enum.HorizontalAlignment.Left, VerticalAlignment=Enum.VerticalAlignment.Center,
    Padding=UDim.new(0,8)}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="UFO", TextColor3=ACCENT}, {})
make("TextLabel", {Parent=titleFrame, BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    Size=UDim2.new(0,0,1,0), Font=Enum.Font.GothamBold, TextSize=22, Text="HUB X", TextColor3=Color3.new(1,1,1)}, {})

local underline = make("Frame", {Parent=top, Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2), BackgroundColor3=ACCENT},{
    make("UIGradient",{Transparency=NumberSequence.new{
        NumberSequenceKeypoint.new(0,0.7), NumberSequenceKeypoint.new(0.5,0), NumberSequenceKeypoint.new(1,0.7)
    }})
})

local function neonButton(parent, text, xOff)
    return make("TextButton", {
        Parent=parent, Text=text, Font=Enum.Font.GothamBold, TextSize=18, TextColor3=FG,
        BackgroundColor3=SUB, Size=UDim2.new(0,36,0,36), Position=UDim2.new(1,xOff,0,7), AutoButtonColor=false
    },{make("UICorner",{CornerRadius=UDim.new(0,10)}), make("UIStroke",{Color=ACCENT, Transparency=0.75})})
end
local btnMini  = neonButton(top, "–", -88)
local btnClose = neonButton(top, "",  -46)
btnClose.BackgroundColor3 = Color3.fromRGB(210,35,50)
local function mkX(rot)
    local b = Instance.new("Frame")
    b.Parent=btnClose; b.AnchorPoint=Vector2.new(0.5,0.5)
    b.Position=UDim2.new(0.5,0,0.5,0); b.Size=UDim2.new(0,18,0,2)
    b.BackgroundColor3=Color3.new(1,1,1); b.BorderSizePixel=0; b.Rotation=rot
    Instance.new("UICorner", b).CornerRadius=UDim.new(0,1)
end
mkX(45); mkX(-45)

-- Sidebar ------------------------------------------------
local left = make("Frame", {Parent=main, Size=UDim2.new(0,170,1,-60), Position=UDim2.new(0,12,0,55),
    BackgroundColor3=Color3.fromRGB(18,18,18)},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.85})})
make("UIListLayout",{Parent=left, Padding=UDim.new(0,10)})

-- Content ------------------------------------------------
local content = make("Frame", {Parent=main, Size=UDim2.new(1,-210,1,-70), Position=UDim2.new(0,190,0,60),
    BackgroundColor3=D_GREY},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.8})})

local pgHome = make("Frame",{Parent=content, Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1, Visible=true}, {})

-------------------- Toggle Button (dock + drag) --------------------
local btnToggle = make("ImageButton", {
    Parent=toggleGui, Size=UDim2.new(0,64,0,64),
    BackgroundColor3=SUB, AutoButtonColor=false, ClipsDescendants=true,
    Active=true, Draggable=true
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.1})
})
make("ImageLabel", {
    Parent=btnToggle, BackgroundTransparency=1,
    Size=UDim2.new(1,-6,1,-6), Position=UDim2.new(0,3,0,3),
    Image="rbxassetid://"..LOGO_ID, ScaleType=Enum.ScaleType.Stretch
},{ make("UICorner",{CornerRadius=UDim.new(0,8)}) })

-------------------- Behaviors --------------------
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
        left.Visible=false; content.Visible=false; underline.Visible=false
        TS:Create(main, TweenInfo.new(.2), {Size=UDim2.new(0,620,0,56)}):Play()
        btnMini.Text="▢"
    else
        left.Visible=true; content.Visible=true; underline.Visible=true
        TS:Create(main, TweenInfo.new(.2), {Size=originalSize}):Play()
        btnMini.Text="–"
    end
end)
btnClose.MouseButton1Click:Connect(function() setHidden(true) end)

-------------------- จัดกลาง + dock ปุ่ม --------------------
local function dockToggleToMain()
    local mPos  = main.AbsolutePosition
    local mSize = main.AbsoluteSize
    local tX = math.floor(mPos.X - btnToggle.AbsoluteSize.X - TOGGLE_GAP)
    local tY = math.floor(mPos.Y + (mSize.Y - btnToggle.AbsoluteSize.Y)/2 + TOGGLE_DY)
    btnToggle.Position = UDim2.fromOffset(tX, tY)
end

local function centerMain(animated)
    local vp = Camera.ViewportSize
    local targetMain = UDim2.fromOffset(
        math.floor((vp.X - main.AbsoluteSize.X)/2) + X_OFFSET,
        math.floor((vp.Y - main.AbsoluteSize.Y)/2) + Y_OFFSET
    )
    if animated and CENTER_TWEEN then tweenPos(main, targetMain) else main.Position = targetMain end
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
        TOGGLE_DOCKED = false -- ลากเอง → ปลด dock
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
--========================================================
-- [PATCH] Scroll system for LEFT (Sidebar) and RIGHT (Content)
-- *ไม่ลบของเดิม* — แค่เพิ่ม ScrollingFrame แล้วชี้ Parent ใหม่ให้ใช้งาน
--========================================================

-- LEFT: make a scrolling container inside `left`
local leftScroll = make("ScrollingFrame", {
    Parent = left,
    Name = "LeftScroll",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1,-10, 1,-10),
    Position = UDim2.new(0,5, 0,5),
    ScrollBarThickness = 4,
    ScrollBarImageTransparency = 0.15,
    ScrollBarImageColor3 = ACCENT,
    AutomaticCanvasSize = Enum.AutomaticSize.Y, -- ปรับความยาว canvas อัตโนมัติ
    CanvasSize = UDim2.new(0,0, 0,0),
    ClipsDescendants = true
}, {
    make("UIPadding", {PaddingTop=UDim.new(0,6), PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6), PaddingBottom=UDim.new(0,6)}),
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0,8),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
})

-- NOTE: เดิมเราเคยสร้าง UIListLayout ใส่ไว้ใน `left` แล้ว
-- เรา "ไม่ลบ" แต่จากนี้เวลาเพิ่มปุ่มเมนู/รายการ ให้ Parent = leftScroll แทน
-- ตัวอย่างฟังก์ชันช่วยสร้างปุ่มลง Sidebar แล้วใส่ใน leftScroll:
local function AddSidebarItem(text)
    local b = make("TextButton", {
        Parent = leftScroll,
        Size = UDim2.new(1,0, 0,36),
        AutoButtonColor = true,
        BackgroundColor3 = SUB,
        Text = text,
        TextColor3 = FG,
        Font = Enum.Font.GothamBold,
        TextSize = 16
    }, {
        make("UICorner", {CornerRadius = UDim.new(0,8)}),
        make("UIStroke", {Color = ACCENT, Transparency = 0.85})
    })
    return b
end
-- ตัวอย่าง (คอมเมนต์ไว้ก่อน): -- AddSidebarItem("Home")

-- RIGHT: scrolling container inside `content`
local contentScroll = make("ScrollingFrame", {
    Parent = content,
    Name = "ContentScroll",
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(1,-10, 1,-10),
    Position = UDim2.new(0,5, 0,5),
    ScrollBarThickness = 5,
    ScrollBarImageTransparency = 0.15,
    ScrollBarImageColor3 = ACCENT,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.new(0,0, 0,0),
    ClipsDescendants = true
}, {
    make("UIPadding", {PaddingTop=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10), PaddingBottom=UDim.new(0,10)}),
    make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0,10),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
})

-- ย้ายหน้าเริ่มต้น `pgHome` ไปโชว์ในพื้นที่เลื่อนของฝั่งขวา (ไม่ลบของเดิม แค่เปลี่ยน Parent)
pgHome.Parent = contentScroll

-- ฟังก์ชันช่วย: เพิ่มเซกชัน/การ์ดในฝั่งขวา (วางเป็นตัวอย่าง)
local function AddContentSection(title, height)
    local card = make("Frame", {
        Parent = contentScroll,
        BackgroundColor3 = Color3.fromRGB(20,20,20),
        Size = UDim2.new(1,0, 0, height or 140)
    }, {
        make("UICorner", {CornerRadius = UDim.new(0,10)}),
        make("UIStroke", {Color = ACCENT, Transparency = 0.82})
    })
    make("TextLabel", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(0,12, 0,10),
        Size = UDim2.new(1,-24, 0,24),
        Text = title or "Section",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = FG,
        TextXAlignment = Enum.TextXAlignment.Left
    }, {})

    return card
end
-- ตัวอย่าง (คอมเมนต์ไว้): -- AddContentSection("Welcome", 160)

-- ปรับการสลับย่อ/ขยาย ให้ซ่อนเฉพาะเนื้อหาด้านใน (scroll containers) ตามสถานะเดิม
collapsed = collapsed or false
local function setCollapsedUI(isCollapsed)
    if isCollapsed then
        left.Visible=false; content.Visible=false; underline.Visible=false
    else
        left.Visible=true; content.Visible=true; underline.Visible=true
    end
end
-- ผูกกับปุ่มเดิมโดยไม่แก้บรรทัดเก่า (แค่เสริม listener เผื่อมีการเปลี่ยนสถานะจากที่อื่น)
btnMini:GetPropertyChangedSignal("Text"):Connect(function()
    setCollapsedUI(btnMini.Text == "▢")
end)
--========================================================
-- UFO HUB X — System: Sidebar "🏠 Home" + Page Switch
--========================================================

-- สมมติว่ามี leftScroll (ScrollingFrame) และ contentScroll (ScrollingFrame) อยู่แล้ว
-- และมี Frame ชื่อ pgHome สำหรับหน้าหลัก

-- ลบปุ่ม Home เก่าออก (กันซ้อน)
for _,c in ipairs(leftScroll:GetChildren()) do
    if c:IsA("TextButton") and (c.Name=="Home" or c.Text=="หน้าหลัก") then
        c:Destroy()
    end
end

-- สร้างปุ่ม Sidebar: 🏠 Home
local btnHome = Instance.new("TextButton")
btnHome.Name = "Home"
btnHome.Parent = leftScroll
btnHome.Size = UDim2.new(1,0,0,36)
btnHome.AutoButtonColor = true
btnHome.BackgroundColor3 = SUB
btnHome.Text = "🏠 Home"
btnHome.TextColor3 = Color3.fromRGB(255,255,255)
btnHome.Font = Enum.Font.GothamBold
btnHome.TextSize = 16
btnHome.TextXAlignment = Enum.TextXAlignment.Left

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,8)
corner.Parent = btnHome

local stroke = Instance.new("UIStroke")
stroke.Color = ACCENT
stroke.Transparency = 0.85
stroke.Parent = btnHome

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0,10)
pad.Parent = btnHome

-- ระบบเลือกปุ่ม Sidebar
local function setSidebarSelected(btn)
    for _,c in ipairs(leftScroll:GetChildren()) do
        if c:IsA("TextButton") then
            c.BackgroundColor3 = SUB
            c.TextColor3 = Color3.fromRGB(255,255,255)
        end
    end
    if btn then
        btn.BackgroundColor3 = Color3.fromRGB(26,26,26)
        btn.TextColor3 = ACCENT
    end
end

-- ระบบจัดการ Pages
local Pages = { ["Home"] = pgHome }

local function showPage(name)
    for n,frame in pairs(Pages) do
        if frame and frame.Parent then
            frame.Visible = (n == name)
        end
    end
    -- เวลาเปลี่ยนหน้า รีเซ็ต Scroll ขึ้นบนสุด
    if contentScroll then
        contentScroll.CanvasPosition = Vector2.new(0,0)
    end
end

-- Event: คลิกปุ่ม Home
btnHome.MouseButton1Click:Connect(function()
    showPage("Home")
    setSidebarSelected(btnHome)
end)

-- เปิดเริ่มต้นเป็นหน้าหลัก
showPage("Home")
setSidebarSelected(btnHome)
