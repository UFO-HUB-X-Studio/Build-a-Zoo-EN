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

----------------------------------------------------------------
-- 🔩 REQUIRE: โค้ดนี้สมมติว่าคุณมีตัวแปร/ฟังก์ชันต่อไปนี้จาก UI หลัก:
-- mainGui, content, left, TS (TweenService), ACCENT, SUB, FG
-- ถ้าไม่มี ผมใส่ fallback ไว้ให้ด้านล่างแล้ว
----------------------------------------------------------------
local TS = TS or game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local RS = game:GetService("ReplicatedStorage")

local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)

-- ตัวช่วยสร้างอินสแตนซ์
local function make(class, props, kids)
    local o=Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end
    return o
end

----------------------------------------------------------------
-- 🏠 HOME BUTTON (ขอบเขียวคมชัด)
----------------------------------------------------------------
do
    local old = left:FindFirstChild("UFOX_HomeBtn"); if old then old:Destroy() end
    local btnHome = make("TextButton",{
        Name="UFOX_HomeBtn", Parent=left, AutoButtonColor=false,
        Size=UDim2.new(1,-16,0,38), Position=UDim2.fromOffset(8,8),
        BackgroundColor3=SUB, Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG,
        Text="", ClipsDescendants=true
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{
            Color=ACCENT, Thickness=2, Transparency=0,
            ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        })
    })

    local row = make("Frame",{
        Parent=btnHome, BackgroundTransparency=1,
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0)
    },{
        make("UIListLayout",{
            FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,8),
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            VerticalAlignment=Enum.VerticalAlignment.Center
        })
    })
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.fromOffset(20,20),
        Font=Enum.Font.GothamBold, TextSize=16, Text="🏠", TextColor3=FG})
    make("TextLabel",{Parent=row, BackgroundTransparency=1, Size=UDim2.new(1,-36,1,0),
        Font=Enum.Font.GothamBold, TextSize=15, Text="Home",
        TextXAlignment=Enum.TextXAlignment.Left, TextColor3=FG})

    -- เอฟเฟกต์เล็ก ๆ
    btnHome.MouseEnter:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(32,32,32)}):Play()
    end)
    btnHome.MouseLeave:Connect(function()
        TS:Create(btnHome, TweenInfo.new(0.12), {BackgroundColor3 = SUB}):Play()
    end)

    btnHome.MouseButton1Click:Connect(function()
        if typeof(_G.UFO_OpenHomePage)=="function" then
            pcall(_G.UFO_OpenHomePage)
        else
            -- ถ้ายังไม่มีหน้าอื่น ก็แค่กะพริบ content ให้รู้ว่ากดแล้ว
            TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(24,24,24)}):Play()
            task.delay(0.12, function()
                TS:Create(content, TweenInfo.new(0.10), {BackgroundColor3 = Color3.fromRGB(16,16,16)}):Play()
            end)
        end
    end)
end

----------------------------------------------------------------
-- 🔁 AFK AUTO-CLICK (anti-kick 20m) — drop-in replacement
-- ใช้ VirtualUser + VirtualInputManager + Idled hook หลายชั้น
-- - คลิกเบา ๆ / ขยับเมาส์ / ส่งปุ่มสเปซเป็นครั้งคราว
-- - ค่าเริ่มต้น: กันเตะทุก ~55 วิ + คลิกใหญ่ทุก 5 นาที
----------------------------------------------------------------
local INTERVAL_KEEPALIVE = 55        -- ส่งสัญญาณกันว่างทุก ๆ 55 วิ (น้อยกว่า 60)
local INTERVAL_BIGCLICK  = 5*60      -- คลิกใหญ่ทุก 5 นาที (กันเกมที่เช็คหนัก)
local SAFE_JUMP_EVERY    = 5*60      -- กระตุก spacebar ทุก 5 นาที (เบามาก, ปิดได้ด้วยตัวแปร)
local ENABLE_SAFE_JUMP   = true      -- ถ้ารบกวนเกม ให้ตั้ง false

-- ===== Dependencies ที่ UI หลักมีอยู่แล้ว =====
local TS    = TS or game:GetService("TweenService")
local UIS   = game:GetService("UserInputService")
local VIM   = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local LP    = LP or Players.LocalPlayer
local VirtualUser = VirtualUser or game:GetService("VirtualUser")
local ACCENT = ACCENT or Color3.fromRGB(0,255,140)
local SUB    = SUB    or Color3.fromRGB(22,22,22)
local FG     = FG     or Color3.fromRGB(235,235,235)
local content = content  -- มาจาก UI หลัก

-- ลบของเก่า (ถ้ามี)
local old = content and content:FindFirstChild("UFOX_RowAFK")
if old then old:Destroy() end

-- ===== UI แถวสวิตช์ (เล็กสไตล์ iOS) =====
local function make(class, props, kids)
    local o=Instance.new(class); for k,v in pairs(props or {}) do o[k]=v end
    for _,c in ipairs(kids or {}) do c.Parent=o end; return o
end

local rowAFK = make("Frame",{
    Name="UFOX_RowAFK", Parent=content, BackgroundColor3=Color3.fromRGB(18,18,18),
    Size=UDim2.new(1,-20,0,44), Position=UDim2.fromOffset(10,10)
},{
    make("UICorner",{CornerRadius=UDim.new(0,10)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
})

local lbAFK = make("TextLabel",{
    Parent=rowAFK, BackgroundTransparency=1, Text="AFK (OFF)",
    Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG, TextXAlignment=Enum.TextXAlignment.Left,
    Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-150,1,0)
},{})

local swAFK = make("TextButton",{
    Parent=rowAFK, AutoButtonColor=false, Text="", AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-12,0.5,0), Size=UDim2.fromOffset(60,24), BackgroundColor3=SUB
},{
    make("UICorner",{CornerRadius=UDim.new(1,0)}),
    make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
})
local knob = make("Frame",{
    Parent=swAFK, Size=UDim2.fromOffset(20,20), Position=UDim2.new(0,2,0,2),
    BackgroundColor3=Color3.fromRGB(210,60,60), BorderSizePixel=0
},{ make("UICorner",{CornerRadius=UDim.new(1,0)}) })

-- ===== Core anti-idle engines =====
local AFK_ON = false
local idleConn
local keepaliveThread
local bigClickThread
local lastBig = 0
local lastJump = 0

local function cameraCenterXY()
    local cam = workspace.CurrentCamera
    if not cam then return 400, 300 end
    local v = cam.ViewportSize
    return math.floor(v.X/2), math.floor(v.Y/2)
end

local function tinyMouseNudge()
    -- ขยับเมาส์ 1 พิกเซลไปมา (บางเกมพอแค่นี้)
    local x,y = cameraCenterXY()
    pcall(function()
        VIM:SendMouseMoveEvent(x+1, y, game, 0)
        task.wait(0.02)
        VIM:SendMouseMoveEvent(x,   y, game, 0)
    end)
end

local function virtualUserKick()
    -- ยิง VirtualUser แบบมาตรฐานกันเตะ
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0,0))
    end)
end

local function softSpacebar()
    if not ENABLE_SAFE_JUMP then return end
    pcall(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.03)
        VIM:SendKeyEvent(false,Enum.KeyCode.Space, false, game)
    end)
end

local function simulateKeepAlive()
    -- เล็กแต่ถี่: พยายามไม่รบกวนเกม
    tinyMouseNudge()
    virtualUserKick()
end

local function simulateBig()
    -- กดคลิกชัด ๆ ที่กึ่งกลาง (เผื่อบางเกมเช็คเข้ม)
    local x,y = cameraCenterXY()
    pcall(function()
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end

-- ===== UI states =====
local function setAFKUI(on)
    if on then
        lbAFK.Text = "AFK (ON)"
        TS:Create(swAFK, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28,60,40)}):Play()
        TS:Create(knob,  TweenInfo.new(0.12), {Position=UDim2.new(1,-22,0,2), BackgroundColor3=ACCENT}):Play()
    else
        lbAFK.Text = "AFK (OFF)"
        TS:Create(swAFK, TweenInfo.new(0.12), {BackgroundColor3 = SUB}):Play()
        TS:Create(knob,  TweenInfo.new(0.12), {Position=UDim2.new(0,2,0,2),  BackgroundColor3=Color3.fromRGB(210,60,60)}):Play()
    end
end

-- ===== Loops & hooks =====
local function startAFK()
    if AFK_ON then return end
    AFK_ON = true
    setAFKUI(true)

    -- Hook Roblox anti-idle: โดนเรียกก่อนครบ 20 นาทีเสมอ
    if idleConn then idleConn:Disconnect() end
    idleConn = LP.Idled:Connect(function()
        simulateKeepAlive()
        softSpacebar()
    end)

    -- keepalive ถี่ ๆ ทุก ~55 วิ
    keepaliveThread = task.spawn(function()
        while AFK_ON do
            simulateKeepAlive()
            task.wait(INTERVAL_KEEPALIVE)
        end
    end)

    -- big click + spacebar ทุก 5 นาที
    bigClickThread = task.spawn(function()
        while AFK_ON do
            local now = os.clock()
            if now - lastBig >= INTERVAL_BIGCLICK then
                simulateBig()
                lastBig = now
            end
            if ENABLE_SAFE_JUMP and (now - lastJump >= SAFE_JUMP_EVERY) then
                softSpacebar()
                lastJump = now
            end
            task.wait(1)
        end
    end)
end

local function stopAFK()
    if not AFK_ON then return end
    AFK_ON = false
    setAFKUI(false)
    if idleConn then idleConn:Disconnect(); idleConn=nil end
    -- threads จะหลุดจากลูปเอง
end

swAFK.MouseButton1Click:Connect(function()
    if AFK_ON then stopAFK() else startAFK() end
end)

-- ให้สคริปต์อื่นเรียกได้
_G.UFO_AFK_IsOn  = function() return AFK_ON end
_G.UFO_AFK_Start = startAFK
_G.UFO_AFK_Stop  = stopAFK
_G.UFO_AFK_Set   = function(b) if b then startAFK() else stopAFK() end end

-- ค่าเริ่มต้น
setAFKUI(false)
----------------------------------------------------------------
-- 💰 AUTO-CLAIM (ทุก 5 วิ ยิง Claim ทุก Pet)
----------------------------------------------------------------
local function buildAutoClaimRow(y)
    local row = make("Frame",{
        Name="UFOX_RowClaim", Parent=content, BackgroundColor3=Color3.fromRGB(18,18,18),
        Size=UDim2.new(1,-20,0,44), Position=UDim2.fromOffset(10,y)
    },{
        make("UICorner",{CornerRadius=UDim.new(0,10)}),
        make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
    })

    local lb = make("TextLabel",{
        Parent=row, BackgroundTransparency=1, Text="Auto-Claim (OFF)",
        Font=Enum.Font.GothamBold, TextSize=15, TextColor3=FG,
        TextXAlignment=Enum.TextXAlignment.Left,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(1,-150,1,0)
    },{})

    local sw = make("TextButton",{
        Parent=row, AutoButtonColor=false, Text="",
        AnchorPoint=Vector2.new(1,0.5), Position=UDim2.new(1,-12,0.5,0),
        Size=UDim2.fromOffset(60,24), BackgroundColor3=SUB
    },{
        make("UICorner",{CornerRadius=UDim.new(1,0)}),
        make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.05})
    })
    local knob = make("Frame",{
        Parent=sw, Size=UDim2.fromOffset(20,20), Position=UDim2.new(0,2,0,2),
        BackgroundColor3=Color3.fromRGB(210,60,60), BorderSizePixel=0
    },{
        make("UICorner",{CornerRadius=UDim.new(1,0)})
    })

    ----------------------------------------------------------------
    -- Engine
    ----------------------------------------------------------------
    local ON=false
    local INTERVAL=5
    local loop

    local function setUI(state)
        if state then
            lb.Text="Auto-Claim (ON)"
            TS:Create(sw,   TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(28,60,40)}):Play()
            TS:Create(knob, TweenInfo.new(0.12), {Position=UDim2.new(1,-22,0,2), BackgroundColor3=ACCENT}):Play()
        else
            lb.Text="Auto-Claim (OFF)"
            TS:Create(sw,   TweenInfo.new(0.12), {BackgroundColor3=SUB}):Play()
            TS:Create(knob, TweenInfo.new(0.12), {Position=UDim2.new(0,2,0,2), BackgroundColor3=Color3.fromRGB(210,60,60)}):Play()
        end
    end

    local function claimAllPets()
        local petsFolder = workspace:FindFirstChild("Pets")
        if not petsFolder then return end

        for _,pet in ipairs(petsFolder:GetChildren()) do
            local root = pet:FindFirstChild("RootPart")
            if root then
                local re = root:FindFirstChild("RE")
                if re and re:IsA("RemoteEvent") then
                    pcall(function()
                        re:FireServer("Claim")
                    end)
                end
            end
        end
    end

    local function startLoop()
        if loop then return end
        loop = task.spawn(function()
            while ON do
                claimAllPets()
                for _=1, INTERVAL*10 do
                    if not ON then break end
                    task.wait(0.1)
                end
            end
            loop=nil
        end)
    end

    sw.MouseButton1Click:Connect(function()
        ON = not ON
        setUI(ON)
        if ON then startLoop() end
    end)

    setUI(false)
end

-- เรียกสร้าง Auto-Claim Row ใต้ AFK
local y = rowAFK and (rowAFK.Position.Y.Offset + rowAFK.Size.Y.Offset + 8) or 10
buildAutoClaimRow(y)
----------------------------------------------------------------
-- 🥚 AUTO-HATCH (เจาะจงชื่อไข่ เช่น Super Rare Egg, Epic Egg)
----------------------------------------------------------------
local Players = game:GetService("Players")
local LP      = Players.LocalPlayer
local TS      = game:GetService("TweenService")
local TweenFast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- === ตั้งชื่อไข่ที่ต้องการให้ Auto Hatch ===
local EggNames = {
    "Super Rare Egg",
    "Epic Egg",
}

-- Utility: หา Hatch UI หรือ Instance ที่เกี่ยวกับไข่
local function findEggTargets()
    local targets = {}

    -- 1) ใน PlayerGui
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then
        for _,v in ipairs(pg:GetDescendants()) do
            if v:IsA("GuiButton") and (v.Text and string.find(v.Text,"Hatch")) then
                table.insert(targets, v)
            elseif v:IsA("GuiObject") and table.find(EggNames, v.Name) then
                table.insert(targets, v)
            end
        end
    end

    -- 2) ใน Workspace (กรณีไข่อยู่ในโลก 3D)
    for _,name in ipairs(EggNames) do
        local eg = workspace:FindFirstChild(name, true)
        if eg then
            table.insert(targets, eg)
        end
    end

    return targets
end

-- สร้าง RemoteFunction แบบที่คุณใช้
local function hatchOnce()
    pcall(function()
        local rf = Instance.new("RemoteFunction") -- parent=nil
        rf:InvokeServer("Hatch")
    end)
end

-- ============ UI Switch ==============
local row = Instance.new("Frame")
row.Name = "RowAutoHatch"
row.Parent = content
row.BackgroundColor3 = Color3.fromRGB(18,18,18)
row.Size = UDim2.new(1,-20,0,44)
row.Position = UDim2.fromOffset(10, 120) -- วางต่อจากแถวก่อนหน้า
Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
local st = Instance.new("UIStroke", row); st.Color = ACCENT; st.Thickness = 2; st.Transparency = 0.05

local lb = Instance.new("TextLabel")
lb.Parent = row
lb.BackgroundTransparency = 1
lb.Font = Enum.Font.GothamBold
lb.TextSize = 15
lb.TextXAlignment = Enum.TextXAlignment.Left
lb.TextColor3 = FG
lb.Text = "Auto-Hatch (OFF)"
lb.Position = UDim2.new(0,12,0,0)
lb.Size = UDim2.new(1,-150,1,0)

local sw = Instance.new("TextButton")
sw.Parent = row
sw.AnchorPoint = Vector2.new(1,0.5)
sw.Position = UDim2.new(1,-12,0.5,0)
sw.Size = UDim2.fromOffset(60,24)
sw.BackgroundColor3 = SUB
sw.Text = ""
sw.AutoButtonColor = false
Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
local st2 = Instance.new("UIStroke", sw); st2.Color = ACCENT; st2.Thickness = 2; st2.Transparency = 0.05

local knob = Instance.new("Frame")
knob.Parent = sw
knob.Size = UDim2.fromOffset(20,20)
knob.Position = UDim2.new(0,2,0,2)
knob.BackgroundColor3 = Color3.fromRGB(210,60,60)
knob.BorderSizePixel = 0
Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

-- ============ Engine ============
local ON = false
local INTERVAL = 1
local BURST    = 3
local loop

local function setUI(state)
    if state then
        lb.Text = "Auto-Hatch (ON)"
        TS:Create(sw,TweenFast,{BackgroundColor3 = Color3.fromRGB(28,60,40)}):Play()
        TS:Create(knob,TweenFast,{Position=UDim2.new(1,-22,0,2),BackgroundColor3=ACCENT}):Play()
    else
        lb.Text = "Auto-Hatch (OFF)"
        TS:Create(sw,TweenFast,{BackgroundColor3 = SUB}):Play()
        TS:Create(knob,TweenFast,{Position=UDim2.new(0,2,0,2),BackgroundColor3=Color3.fromRGB(210,60,60)}):Play()
    end
end

local function startLoop()
    if ON then return end
    ON = true
    loop = task.spawn(function()
        while ON do
            local eggs = findEggTargets()
            if #eggs > 0 then
                for _,eg in ipairs(eggs) do
                    for i=1,BURST do
                        hatchOnce()
                        task.wait(0.05)
                    end
                end
            end
            task.wait(INTERVAL)
        end
    end)
    setUI(true)
end

local function stopLoop()
    ON=false
    setUI(false)
end

sw.MouseButton1Click:Connect(function()
    if ON then stopLoop() else startLoop() end
end)

setUI(false)
