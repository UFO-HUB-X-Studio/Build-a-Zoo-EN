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
-- Kavo-Compatible API -> Render ด้วย UFO HUB X UI (ของคุณ)
-- ใช้สคริปต์ที่เขียนแบบ Kavo ได้ แต่หน้าตา/ธีมเป็นของเรา
-- รองรับ: CreateLib, NewTab, NewSection, NewButton, NewToggle, Label, ToggleUI
--========================================================
do
    local GREEN = (typeof(ACCENT)=="Color3" and ACCENT) or Color3.fromRGB(0,255,140)
    local WHITE = Color3.fromRGB(255,255,255)
    local TS    = game:GetService("TweenService")

    -- 0) สร้าง ScrollingFrames ซ้าย/ขวา ถ้ายังไม่มี (ขนาดพอดีกับกรอบ)
    local function ensureScroll(parent: Instance, name: string)
        if not parent then return nil end
        local sc = parent:FindFirstChild(name)
        if not (sc and sc:IsA("ScrollingFrame")) then
            sc = Instance.new("ScrollingFrame")
            sc.Name = name; sc.Parent = parent
            sc.BackgroundTransparency = 1; sc.BorderSizePixel = 0
            sc.ClipsDescendants = true
            sc.ScrollingDirection = Enum.ScrollingDirection.Y
            sc.ScrollBarThickness = 6
            sc.ScrollBarImageColor3 = GREEN
            local list = Instance.new("UIListLayout", sc)
            list.Padding = UDim.new(0,8)
            list.FillDirection = Enum.FillDirection.Vertical
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sc.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 20)
            end)
        end
        sc.Size     = UDim2.new(1, -20, 1, -20)
        sc.Position = UDim2.new(0, 10, 0, 10)
        return sc
    end
    local LeftScroll    = ensureScroll(left,   "LeftScroll")
    local ContentScroll = ensureScroll(pgHome, "ContentScroll")

    -- 1) องค์ประกอบเล็ก ๆ ใช้ซ้ำ -------------------------
    local function makeStroke(p, th) local s=Instance.new("UIStroke", p); s.Color=GREEN; s.Thickness=th or 2; s.Transparency=0.1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end
    local function makeCorner(p, r) local c=Instance.new("UICorner", p); c.CornerRadius=UDim.new(0,r or 12); return c end

    local function sidebarButton(text: string)
        local b = Instance.new("TextButton")
        b.Name = "Btn_"..text; b.Parent = LeftScroll
        b.Size = UDim2.new(1,0,0,44)
        b.BackgroundColor3 = Color3.fromRGB(0,0,0)
        b.TextColor3 = WHITE; b.Font=Enum.Font.GothamBold; b.TextSize=18
        b.TextXAlignment = Enum.TextXAlignment.Left; b.AutoButtonColor=false
        b.Text = text
        makeCorner(b,12); makeStroke(b,2)
        local pad = Instance.new("UIPadding", b); pad.PaddingLeft=UDim.new(0,12); pad.PaddingRight=UDim.new(0,10)
        -- press/hover feel
        b.MouseEnter:Connect(function() TS:Create(b.UIStroke, TweenInfo.new(0.1), {Transparency=0}):Play() end)
        b.MouseLeave:Connect(function() TS:Create(b.UIStroke, TweenInfo.new(0.1), {Transparency=0.1}):Play(); TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency=0}):Play() end)
        b.MouseButton1Down:Connect(function() TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency=0.15}):Play() end)
        b.MouseButton1Up:Connect(function() TS:Create(b, TweenInfo.new(0.08), {BackgroundTransparency=0}):Play() end)
        return b
    end

    local function sectionBox(titleText: string)
        local box = Instance.new("Frame")
        box.Name="Section_"..titleText; box.Parent=ContentScroll
        box.BackgroundColor3 = Color3.fromRGB(18,18,18); box.BorderSizePixel=0
        box.Size = UDim2.new(1,0,0,72) -- สูงเริ่มต้น (จะขยายตามเนื้อหาภายหลัง)
        makeCorner(box,10); local s=makeStroke(box,2); s.Transparency=0.08

        local header = Instance.new("TextLabel", box)
        header.Name="Header"; header.BackgroundTransparency=1
        header.Position=UDim2.new(0,12,0,8); header.Size=UDim2.new(1,-24,0,24)
        header.Font=Enum.Font.GothamBold; header.TextSize=20; header.TextXAlignment=Enum.TextXAlignment.Left
        header.TextColor3 = WHITE; header.Text = titleText

        local line = Instance.new("Frame", box)
        line.BackgroundColor3=GREEN; line.BorderSizePixel=0
        line.Position=UDim2.new(0,12,0,36); line.Size=UDim2.new(1,-24,0,2)
        local grad=Instance.new("UIGradient", line)
        grad.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0,0.55), NumberSequenceKeypoint.new(0.5,0.0), NumberSequenceKeypoint.new(1,0.55)
        }

        local body = Instance.new("Frame", box)
        body.Name="Body"; body.BackgroundTransparency=1
        body.Position=UDim2.new(0,12,0,44); body.Size=UDim2.new(1,-24,0,0)

        local inner = Instance.new("UIListLayout", body)
        inner.Padding=UDim.new(0,8); inner.FillDirection=Enum.FillDirection.Vertical; inner.SortOrder=Enum.SortOrder.LayoutOrder
        inner:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            body.Size = UDim2.new(1,-24,0, inner.AbsoluteContentSize.Y)
            box.Size  = UDim2.new(1, 0, 0, 44 + 8 + inner.AbsoluteContentSize.Y + 12)
        end)

        return box, body
    end

    -- 2) Kavo-Compatible Interface ---------------------------------------
    local Library = {}
    function Library:ToggleUI()
        mainGui.Enabled = not mainGui.Enabled
    end

    function Library.CreateLib(windowTitle, themeTableOrName)
        -- ปรับชื่อบนหัว (ใช้โลโก้/สไตล์เดิมของคุณ)
        -- (ถ้าจะโชว์ชื่อแท็บบน top bar ให้เพิ่มเองได้)
        local win = {}  -- window object (Kavo style)
        local tabs = {}

        function win:NewTab(tabName)
            -- map: Tab = ปุ่มซ้าย + กลุ่ม Section ขวา (ซ่อนได้/โชว์เมื่อเลือก)
            local tab = {name=tabName, sections={}, _leftBtn=nil, _container=nil}
            tab._leftBtn = sidebarButton(tabName)
            tab._container = Instance.new("Frame")
            tab._container.Name = "Tab_"..tabName
            tab._container.Parent = ContentScroll
            tab._container.BackgroundTransparency=1
            tab._container.Size = UDim2.new(1,0,0,0)

            local list = Instance.new("UIListLayout", tab._container)
            list.Padding = UDim.new(0,8); list.FillDirection=Enum.FillDirection.Vertical; list.SortOrder=Enum.SortOrder.LayoutOrder
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tab._container.Size = UDim2.new(1,0,0,list.AbsoluteContentSize.Y)
            end)

            -- ซ่อน/โชว์เมื่อคลิกปุ่มซ้าย
            local function showOnlyThis()
                for _,t in pairs(tabs) do
                    if t._container then t._container.Visible = (t==tab) end
                    if t._leftBtn then t._leftBtn.UIStroke.Transparency = (t==tab) and 0 or 0.1 end
                end
                -- เลื่อนขวาไปช่วงบนของแท็บนี้
                task.defer(function()
                    local y=0
                    for _,c in ipairs(ContentScroll:GetChildren()) do
                        if c:IsA("Frame") then
                            if c==tab._container then break end
                            y = y + c.AbsoluteSize.Y + 8
                        end
                    end
                    ContentScroll.CanvasPosition = Vector2.new(0,y)
                end)
            end
            tab._leftBtn.MouseButton1Click:Connect(showOnlyThis)

            -- Section API
            function tab:NewSection(sectionName)
                local sec, body = sectionBox(sectionName)
                sec.Parent = tab._container

                local sectionApi = {}

                function sectionApi:NewLabel(text)
                    local l = Instance.new("TextLabel")
                    l.Name="Label"; l.Parent = body
                    l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,0,22)
                    l.Font=Enum.Font.Gotham; l.TextSize=16
                    l.TextXAlignment=Enum.TextXAlignment.Left
                    l.TextColor3 = WHITE; l.Text = text or ""
                    return {
                        UpdateLabel = function(_, newText) l.Text = newText end
                    }
                end

                function sectionApi:NewButton(text, desc, callback)
                    local b = Instance.new("TextButton")
                    b.Name="Btn"; b.Parent = body
                    b.Size=UDim2.new(1,0,0,36)
                    b.BackgroundColor3=Color3.fromRGB(0,0,0)
                    b.TextColor3=WHITE; b.Font=Enum.Font.GothamBold; b.TextSize=16
                    b.Text = text or "Button"; b.AutoButtonColor=false
                    makeCorner(b,10); makeStroke(b,2)
                    b.MouseButton1Click:Connect(function()
                        TS:Create(b, TweenInfo.new(0.06), {BackgroundTransparency=0.15}):Play()
                        task.delay(0.08, function() TS:Create(b, TweenInfo.new(0.06), {BackgroundTransparency=0}):Play() end)
                        if callback then pcall(callback) end
                    end)
                    return {
                        UpdateButton = function(_, t) b.Text = t end
                    }
                end

                function sectionApi:NewToggle(text, desc, default, callback)
                    local row = Instance.new("Frame"); row.Parent = body
                    row.BackgroundTransparency=1; row.Size=UDim2.new(1,0,0,36)
                    local lbl = Instance.new("TextLabel", row)
                    lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-60,1,0)
                    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Font=Enum.Font.GothamBold
                    lbl.TextSize=16; lbl.TextColor3=WHITE; lbl.Text = text or "Toggle"
                    local sw = Instance.new("TextButton", row)
                    sw.Name="Switch"; sw.Size=UDim2.new(0,46,0,24); sw.Position=UDim2.new(1,-46,0.5,-12)
                    sw.BackgroundColor3=Color3.fromRGB(30,30,30); sw.AutoButtonColor=false; sw.Text=""
                    makeCorner(sw,12); makeStroke(sw,2)
                    local knob = Instance.new("Frame", sw)
                    knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,4,0.5,-9)
                    knob.BackgroundColor3=WHITE; knob.BorderSizePixel=0; makeCorner(knob,9)

                    local state = not not default
                    local function apply()
                        sw.UIStroke.Color = state and GREEN or Color3.fromRGB(90,90,90)
                        sw.BackgroundColor3 = state and Color3.fromRGB(20,35,25) or Color3.fromRGB(30,30,30)
                        TS:Create(knob, TweenInfo.new(0.12), {Position = state and UDim2.new(1,-22,0.5,-9) or UDim2.new(0,4,0.5,-9)}):Play()
                    end
                    apply()
                    sw.MouseButton1Click:Connect(function()
                        state = not state; apply(); if callback then pcall(callback, state) end
                    end)
                    return {
                        UpdateToggle = function(_, s) state = not not s; apply(); if callback then pcall(callback, state) end end
                    }
                end

                return sectionApi
            end

            table.insert(tabs, tab)
            -- โชว์แท็บแรกทันที
            if #tabs==1 then
                for _,t in ipairs(tabs) do if t._container then t._container.Visible=false end end
                tab._container.Visible=true
                tab._leftBtn.UIStroke.Transparency = 0
            else
                tab._container.Visible=false
                tab._leftBtn.UIStroke.Transparency = 0.1
            end
            return tab
        end

        return win
    end

    -- ใช้งานกับสคริปต์ที่เรียก Kavo:
    -- local Library = Library or LibraryKavoCompat
    if not _G.KavoCompat then _G.KavoCompat = {CreateLib = Library.CreateLib, ToggleUI = function() Library:ToggleUI() end} end
end
--====================== END KAVO COMPAT LAYER ======================

local Library = _G.KavoCompat
local Window  = Library.CreateLib("UFO HUB X")

-- ปุ่ม Sidebar ฝั่งซ้าย
local TabHome = Window:NewTab("👽 Home")

-- Section ข้างใน TabHome
local Sec     = TabHome:NewSection("เมนู")

Sec:NewButton("เริ่มทำงาน", nil, function()
    print("ทำงานแล้ว")
end)
