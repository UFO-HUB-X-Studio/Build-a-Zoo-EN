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
-- ADD-ONLY: Scroll System (Green) for "UI อันใหญ่"
-- - ไม่แก้ / ไม่ลบของเดิม
-- - เพิ่ม ScrollingFrame สำหรับฝั่งซ้าย (left) และคอนเทนต์ (pgHome)
-- - แถบเลื่อนสีเขียวตามธีม (ACCENT)
-- - ปรับ CanvasSize อัตโนมัติ
-- - รองรับเมาส์/ทัช/เกมแพด
--========================================================
do
    -- ถ้ามีของเดิมชื่อนี้พร้อมชนิดนี้แล้ว จะคืนของเดิม (ไม่สร้างซ้ำ)
    local function ensureChild(parent, name, className)
        if not parent then return nil end
        local ex = parent:FindFirstChild(name)
        if ex and ex.ClassName == className then return ex end
        return nil
    end

    -- สร้าง/การันตี ScrollingFrame + Layout + Padding โดย "เพิ่มอย่างเดียว"
    local function ensureScroll(container, name, padding)
        if not container then return nil end

        local sc = ensureChild(container, name, "ScrollingFrame")
        if not sc then
            sc = make("ScrollingFrame", {
                Name = name,
                Parent = container,
                BackgroundTransparency = 1, -- ไม่ทับธีม
                BorderSizePixel = 0,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                CanvasSize = UDim2.fromOffset(0, 0),
                ScrollBarThickness = 6,
                ScrollBarImageTransparency = 0,
                ScrollBarImageColor3 = ACCENT, -- เขียว
                ClipsDescendants = true,
                AutomaticCanvasSize = Enum.AutomaticSize.None, -- คุมเอง
                Active = true,
                Selectable = true,
                ScrollingEnabled = true,
            }, {
                make("UIPadding", {
                    PaddingTop = UDim.new(0, padding),
                    PaddingBottom = UDim.new(0, padding),
                    PaddingLeft = UDim.new(0, padding),
                    PaddingRight = UDim.new(0, padding)
                }),
                make("UIListLayout", {
                    Name = "ListLayout",
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
            })
        else
            -- ถ้าเจอของเดิม ก็เพียง "อัปเดตค่าที่จำเป็น" ให้ได้สี/พฤติกรรมตามต้องการ
            sc.ScrollingDirection = Enum.ScrollingDirection.Y
            sc.ScrollBarThickness = 6
            sc.ScrollBarImageTransparency = 0
            sc.ScrollBarImageColor3 = ACCENT
            sc.ClipsDescendants = true
            sc.AutomaticCanvasSize = Enum.AutomaticSize.None
            sc.Active, sc.Selectable, sc.ScrollingEnabled = true, true, true

            if not sc:FindFirstChild("ListLayout") then
                make("UIListLayout", {
                    Name = "ListLayout",
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                }).Parent = sc
            end
            if not sc:FindFirstChildOfClass("UIPadding") then
                make("UIPadding", {
                    PaddingTop = UDim.new(0, padding),
                    PaddingBottom = UDim.new(0, padding),
                    PaddingLeft = UDim.new(0, padding),
                    PaddingRight = UDim.new(0, padding)
                }).Parent = sc
            end
        end

        -- กินพื้นที่เต็มของ container โดยเหลือขอบเท่ากับ padding
        local function resizeToFit()
            sc.Size = UDim2.new(1, -padding*2, 1, -padding*2)
            sc.Position = UDim2.new(0, padding, 0, padding)
        end
        resizeToFit()
        if container:IsA("GuiObject") then
            container:GetPropertyChangedSignal("AbsoluteSize"):Connect(resizeToFit)
        end

        -- อัปเดต CanvasSize ตามคอนเทนต์จริง
        local layout = sc:FindFirstChild("ListLayout")
        if layout then
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sc.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + padding*2)
            end)
            -- เรียกครั้งแรก
            sc.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + padding*2)
        end

        -- รองรับโฟกัส (เกมแพด/คีย์บอร์ด)
        sc.SelectionGroup = true

        return sc
    end

    -- ฝั่งซ้าย (left)
    local leftScroll = ensureScroll(left, "LeftScroll", 10)

    -- ฝั่งคอนเทนต์: ใช้พื้นที่หน้า pgHome (ไม่ทับ frame 'content')
    local contentScroll = ensureScroll(pgHome, "ContentScroll", 10)

    -- Helper: ให้ผู้ใช้เรียกตำแหน่งที่จะวางไอเท็มได้ทันที (เพิ่มเท่านั้น ไม่ยุ่งของเดิม)
    _G.UFOHubX_GetLeftList = function()
        return (left and left:FindFirstChild("LeftScroll")) or leftScroll
    end
    _G.UFOHubX_GetContentArea = function()
        return (pgHome and pgHome:FindFirstChild("ContentScroll")) or contentScroll
    end
end
--========================
-- END ADD-ONLY: Scroll System
--========================
--========================================================
-- FORCE PATCH: Home button + header with fallback + log
--========================================================
do
    local GREEN = (typeof(ACCENT)=="Color3" and ACCENT) or Color3.fromRGB(0,255,140)

    local function log(msg)
        print("[UFO HUB X PATCH] " .. msg)
    end

    local function ensureScrollFrame(parent, name)
        if not parent then return nil end
        local sc = parent:FindFirstChild(name)
        if not (sc and sc:IsA("ScrollingFrame")) then
            sc = Instance.new("ScrollingFrame")
            sc.Name = name
            sc.Parent = parent
            sc.BackgroundTransparency = 1
            sc.BorderSizePixel = 0
            sc.ClipsDescendants = true
            sc.ScrollingDirection = Enum.ScrollingDirection.Y
            sc.ScrollBarThickness = 6
            sc.ScrollBarImageColor3 = GREEN
            sc.Size = UDim2.new(1,-20,1,-20)
            sc.Position = UDim2.new(0,10,0,10)

            local list = Instance.new("UIListLayout", sc)
            list.Padding = UDim.new(0,8)
            list.FillDirection = Enum.FillDirection.Vertical
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sc.CanvasSize = UDim2.fromOffset(0, list.AbsoluteContentSize.Y + 20)
            end)
        end
        return sc
    end

    local function ensureEmoji(target, emoji, fallbackAssetId, xOffset, sizePx)
        if not (target and target:IsA("GuiObject")) then return end
        local lbl = target:FindFirstChild("EmojiIcon")
        if not lbl then
            lbl = Instance.new("TextLabel")
            lbl.Name = "EmojiIcon"
            lbl.Parent = target
            lbl.BackgroundTransparency = 1
            lbl.Size = UDim2.fromOffset(sizePx, sizePx)
            lbl.Position = UDim2.new(0,xOffset,0.5,-sizePx/2)
            lbl.Font = Enum.Font.GothamBold
            lbl.Text = emoji
            lbl.TextSize = sizePx
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.ZIndex = (target.ZIndex or 1)+1
        end
        task.defer(function()
            if lbl and (lbl.TextBounds.X < 1 or lbl.TextBounds.Y < 1) then
                lbl.Visible = false
                if not target:FindFirstChild("EmojiImage") then
                    local img = Instance.new("ImageLabel")
                    img.Name = "EmojiImage"
                    img.Parent = target
                    img.BackgroundTransparency = 1
                    img.Size = UDim2.fromOffset(sizePx, sizePx)
                    img.Position = UDim2.new(0,xOffset,0.5,-sizePx/2)
                    img.Image = "rbxassetid://"..tostring(fallbackAssetId or 112676905543996)
                    img.ScaleType = Enum.ScaleType.Fit
                    img.ZIndex = (target.ZIndex or 1)+1
                end
            end
        end)
    end

    -- LEFT
    local leftScroll = (left and ensureScrollFrame(left,"LeftScroll"))
    if leftScroll then
        local btn = leftScroll:FindFirstChild("Btn_Home")
        if not (btn and btn:IsA("TextButton")) then
            btn = Instance.new("TextButton")
            btn.Name = "Btn_Home"
            btn.Parent = leftScroll
        end
        btn.Size = UDim2.new(1,0,0,40)
        btn.BackgroundColor3 = Color3.new(0,0,0)
        btn.Text = "Home"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        local stroke = btn:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke",btn)
        stroke.Color = GREEN
        stroke.Thickness = 2
        stroke.Transparency = 0.1
        local pad = btn:FindFirstChildOfClass("UIPadding") or Instance.new("UIPadding",btn)
        pad.PaddingLeft = UDim.new(0,28)
        ensureEmoji(btn,"🏠",LOGO_ID,6,18)
        log("Btn_Home created/updated")
    else
        log("⚠️ LeftScroll missing and could not be created")
    end

    -- RIGHT
    local contentScroll = (pgHome and ensureScrollFrame(pgHome,"ContentScroll"))
    if contentScroll then
        local header = contentScroll:FindFirstChild("Header_Home")
        if not (header and header:IsA("Frame")) then
            header = Instance.new("Frame")
            header.Name = "Header_Home"
            header.Parent = contentScroll
        end
        header.BackgroundTransparency = 1
        header.Size = UDim2.new(1,0,0,32)
        local title = header:FindFirstChild("Title") or Instance.new("TextLabel",header)
        title.Name = "Title"
        title.BackgroundTransparency = 1
        title.Text = "Home"
        title.Font = Enum.Font.GothamBold
        title.TextSize = 18
        title.TextColor3 = Color3.new(1,1,1)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Size = UDim2.new(1,-28,1,0)
        title.Position = UDim2.new(0,28,0,0)
        local line = header:FindFirstChild("Underline") or Instance.new("Frame",header)
        line.Name = "Underline"
        line.BorderSizePixel = 0
        line.BackgroundColor3 = GREEN
        line.Size = UDim2.new(1,0,0,2)
        line.Position = UDim2.new(0,0,1,-2)
        ensureEmoji(header,"🏠",LOGO_ID,4,18)
        log("Header_Home created/updated")
    else
        log("⚠️ ContentScroll missing and could not be created")
    end
end
