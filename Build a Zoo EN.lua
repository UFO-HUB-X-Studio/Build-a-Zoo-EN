--========================================================
-- UFO HUB X — FULL (no left HOME btn, no right welcome text)
--========================================================

-------------------- Services --------------------
local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local CG      = game:GetService("CoreGui")
local Camera  = workspace.CurrentCamera

-------------------- CONFIG --------------------
local LOGO_ID      = 112676905543996  -- โลโก้
local X_OFFSET     = 18               -- ขยับ UI ใหญ่ไปขวา (+ขวา, -ซ้าย)
local Y_OFFSET     = -40              -- ขยับ UI ใหญ่ขึ้น/ลง (ลบ=ขึ้น, บวก=ลง)
local TOGGLE_GAP   = 60               -- ระยะห่าง ปุ่ม ↔ ขอบซ้าย UI ใหญ่
local TOGGLE_DY    = -70              -- ยกปุ่มขึ้นจากกึ่งกลางแนวตั้ง (ลบ=สูงขึ้น)
local CENTER_TWEEN = true
local CENTER_TIME  = 0.25
local TOGGLE_DOCKED = true            -- เริ่มแบบเกาะซ้าย

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

-- Sidebar (ปล่อยว่าง พร้อมใส่ปุ่มในอนาคต) ---------------------
local left = make("Frame", {Parent=main, Size=UDim2.new(0,170,1,-60), Position=UDim2.new(0,12,0,55),
    BackgroundColor3=Color3.fromRGB(18,18,18)},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.85})})
make("UIListLayout",{Parent=left, Padding=UDim.new(0,10)})

-- Content (ไม่มีหัวข้อ/ตัวหนังสือใดๆ) --------------------------
local content = make("Frame", {Parent=main, Size=UDim2.new(1,-210,1,-70), Position=UDim2.new(0,190,0,60),
    BackgroundColor3=Color3.fromRGB(16,16,16)},
    {make("UICorner",{CornerRadius=UDim.new(0,12)}), make("UIStroke",{Color=ACCENT, Transparency=0.8})})

local pgHome = make("Frame",{Parent=content, Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
    BackgroundTransparency=1, Visible=true}, {})
-- ✨ ไม่มี TextLabel ในหน้านี้แล้ว ตามที่ขอ

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

-- เริ่มต้น: จัดกลาง + dock
centerMain(false)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function() centerMain(false) end)

main.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 and TOGGLE_DOCKED then
        dockToggleToMain()
    end
end)

btnToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        TOGGLE_DOCKED = false -- ลากเอง → ปลด dock อัตโนมัติ
    end
end)

-- ปุ่มลัด: F9 = จัดกลาง + รี-dock, F8 = toggle dock on/off
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F9 then
        TOGGLE_DOCKED = true
        centerMain(true)
    elseif i.KeyCode==Enum.KeyCode.F8 then
        TOGGLE_DOCKED = not TOGGLE_DOCKED
        if TOGGLE_DOCKED then dockToggleToMain() end
    end
end)

-- UFO HUB X — AFK Switch (auto click every 5 min)
-- ใส่ไฟล์นี้ไว้ตรงไหนก็ได้ในบูตโหลดของคุณ

-- ===== Config =====
local INTERVAL_SEC = 5 * 60  -- 5 นาที (เปลี่ยนได้)
local POS          = UDim2.new(1,-160, 1,-100) -- ตำแหน่งกล่อง (มุมขวาล่าง)
local ACCENT_ON    = Color3.fromRGB(0,255,140)
local ACCENT_OFF   = Color3.fromRGB(210,60,60)
local BG_BOX       = Color3.fromRGB(16,16,16)
local FG_TEXT      = Color3.fromRGB(235,235,235)

-- ===== Services =====
local Players   = game:GetService("Players")
local CG        = game:GetService("CoreGui")
local TS        = game:GetService("TweenService")
local LP        = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- ===== Helpers =====
local function softParent(gui)
    if syn and syn.protect_gui then pcall(syn.protect_gui, gui) end
    local ok=false
    if gethui then ok = pcall(function() gui.Parent = gethui() end) end
    if not ok then gui.Parent = CG end
    pcall(function()
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 999999
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    end)
end

local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end

-- ===== Root GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "UFOX_AFK_Toggle"
softParent(gui)

local card = make("Frame", {
    Parent=gui, Size=UDim2.fromOffset(150, 60),
    AnchorPoint=Vector2.new(1,1), Position=POS,
    BackgroundColor3=BG_BOX, BorderSizePixel=0
},{
    make("UICorner",{CornerRadius=UDim.new(0,12)}),
    make("UIStroke",{Color=Color3.fromRGB(60,60,60), Transparency=0.5}),
})

local title = make("TextLabel",{
    Parent=card, BackgroundTransparency=1,
    Position=UDim2.new(0,12,0,8), Size=UDim2.new(1,-24,0,22),
    Font=Enum.Font.GothamBold, TextSize=16, Text="AFK: OFF",
    TextColor3=FG_TEXT, TextXAlignment=Enum.TextXAlignment.Left
},{})

-- สวิตช์
local switch = make("TextButton",{
    Parent=card, AutoButtonColor=false,
    Position=UDim2.new(0,12,0,32), Size=UDim2.fromOffset(126, 20),
    BackgroundColor3=Color3.fromRGB(36,36,36), Text=""
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)})
})
local knob = make("Frame",{
    Parent=switch, BackgroundColor3=ACCENT_OFF,
    Size=UDim2.fromOffset(56, 20), Position=UDim2.new(0,0,0,0)
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
})

-- ===== AFK Engine =====
local enabled = false
local loopThread = nil
local idleConn   = nil

local function simulateClick()
    -- แตะหน้าจอเบา ๆ เพื่อกันหลุด idle
    pcall(function()
        VirtualUser:Button1Down(Vector2.new(0,0))
        task.wait(0.05)
        VirtualUser:Button1Up(Vector2.new(0,0))
    end)
end

local function startAFK()
    if enabled then return end
    enabled = true
    -- สี/สถานะ UI
    title.Text = "AFK: ON"
    TS:Create(knob, TweenInfo.new(0.12), {BackgroundColor3=ACCENT_ON, Position=UDim2.new(1,-56,0,0)}):Play()

    -- กัน Roblox Idle เด้งเอง (สำรอง)
    idleConn = LP.Idled:Connect(function()
        simulateClick()
    end)

    -- ลูปทุก INTERVAL_SEC
    loopThread = task.spawn(function()
        while enabled do
            task.wait(INTERVAL_SEC)
            if not enabled then break end
            simulateClick()
        end
    end)
end

local function stopAFK()
    if not enabled then return end
    enabled = false
    title.Text = "AFK: OFF"
    TS:Create(knob, TweenInfo.new(0.12), {BackgroundColor3=ACCENT_OFF, Position=UDim2.new(0,0,0,0)}):Play()
    if idleConn then idleConn:Disconnect(); idleConn=nil end
    -- ไม่ต้อง kill thread แรง ๆ ปล่อยหลุดจาก while ได้เอง
end

-- สลับสวิตช์
switch.MouseButton1Click:Connect(function()
    if enabled then stopAFK() else startAFK() end
end)
