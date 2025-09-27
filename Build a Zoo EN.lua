--========================================================
-- UFO HUB X — FULL (with Sidebar/Home scrolling + Create, Mobile Patch)
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
-- 🧭 [ADD-ON] SCROLL BOTH SIDES + BUILDER LIST (เพิ่มอย่างเดียว)
-- - Sidebar: ScrollingFrame ภายใน left (เรียงเก่าบน→ใหม่ล่าง)
-- - Home: ถ้ายังไม่มี list จะสร้างให้ + API + ปุ่ม Create
----------------------------------------------------------------
do
    -- Sidebar ---------------------------------------------------
    if not left:FindFirstChild("UFOX_LeftList") then
        local sb = make("ScrollingFrame",{
            Name="UFOX_LeftList", Parent=left,
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderSizePixel = 0, ClipsDescendants = true,
            Size=UDim2.new(1,-12,1,-12), Position=UDim2.new(0,6,0,6),
            ScrollBarThickness = 6, CanvasSize = UDim2.new(0,0,0,0),
            ZIndex = left.ZIndex + 1
        },{
            make("UICorner",{CornerRadius=UDim.new(0,12)}),
            make("UIStroke",{Color=ACCENT, Transparency=0.85}),
            make("UIPadding",{PaddingTop=UDim.new(0,8), PaddingBottom=UDim.new(0,8), PaddingLeft=UDim.new(0,8), PaddingRight=UDim.new(0,8)})
        })

        local sblay = make("UIListLayout",{
            Parent=sb, FillDirection=Enum.FillDirection.Vertical,
            HorizontalAlignment=Enum.HorizontalAlignment.Left,
            SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,8)
        },{})

        local function sbUpdate()
            task.defer(function()
                local sz = sblay.AbsoluteContentSize
                sb.CanvasSize = UDim2.fromOffset(0, sz.Y + 16)
            end)
        end
        sblay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sbUpdate)

        local function makeSideButton(text, onclick, order)
            local btn = make("TextButton",{
                Parent=sb, Name="UFOX_SideBtn", LayoutOrder = order or 0,
                AutoButtonColor=false, BackgroundColor3=SUB,
                Size=UDim2.new(1, -0, 0, 36),
                Font=Enum.Font.GothamBold, TextSize=14, TextColor3=FG,
                Text = text or "Item"
            },{
                make("UICorner",{CornerRadius=UDim.new(0,10)}),
                make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.2)})
            })
            if type(onclick)=="function" then
                btn.MouseButton1Click:Connect(function() pcall(onclick, btn) end)
            end
            local glow = make("Frame",{
                Parent=btn, BackgroundColor3=ACCENT, BorderSizePixel=0,
                Size=UDim2.new(0,0,0,2), Position=UDim2.new(0,0,1,-2)
            },{})
            TS:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size=UDim2.new(1,0,0,2)}):Play()
            task.delay(0.35, function()
                TS:Create(glow, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
                task.delay(0.25, function() pcall(function() glow:Destroy() end) end)
            end)
            sbUpdate()
            return btn
        end

        local SSEQ = 0
        _G.UFOX_AddSideItem = function(text, onclick)
            SSEQ += 1
            local b = makeSideButton(text, onclick, SSEQ)
            task.defer(function()
                local maxY = math.max(0, sb.AbsoluteCanvasSize.Y - sb.AbsoluteWindowSize.Y)
                sb.CanvasPosition = Vector2.new(0, maxY)
            end)
            return b
        end

        _G.UFOX_LeftScrollToLatest = function()
            task.defer(function()
                local maxY = math.max(0, sb.AbsoluteCanvasSize.Y - sb.AbsoluteWindowSize.Y)
                sb.CanvasPosition = Vector2.new(0, maxY)
            end)
        end

        local ctrlBar = make("Frame",{
            Parent = sb, BackgroundTransparency=1,
            Size = UDim2.new(1, -0, 0, 0),
            LayoutOrder = -9999
        },{})
        local function tiny(name, txt, posY, cb)
            local b = make("TextButton",{
                Parent=ctrlBar, Name=name, AutoButtonColor=false, Text=txt,
                Font=Enum.Font.GothamBold, TextSize=16, TextColor3=FG,
                Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-36,0,posY),
                BackgroundColor3=SUB
            },{
                make("UICorner",{CornerRadius=UDim.new(0,8)}),
                make("UIStroke",{Color=ACCENT, Transparency=0.4})
            })
            b.MouseButton1Click:Connect(cb)
            return b
        end
        tiny("UFOX_LeftUp","▲",6,function()
            sb.CanvasPosition = Vector2.new(0, math.max(0, sb.CanvasPosition.Y - 140))
        end)
        tiny("UFOX_LeftDn","▼",42,function()
            local maxY = math.max(0, sb.AbsoluteCanvasSize.Y - sb.AbsoluteWindowSize.Y)
            sb.CanvasPosition = Vector2.new(0, math.min(maxY, sb.CanvasPosition.Y + 140))
        end)

        UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            local ctrl = UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)
            if ctrl and i.KeyCode==Enum.KeyCode.PageUp then
                sb.CanvasPosition = Vector2.new(0, math.max(0, sb.CanvasPosition.Y - 180))
            elseif ctrl and i.KeyCode==Enum.KeyCode.PageDown then
                local maxY = math.max(0, sb.AbsoluteCanvasSize.Y - sb.AbsoluteWindowSize.Y)
                sb.CanvasPosition = Vector2.new(0, math.min(maxY, sb.CanvasPosition.Y + 180))
            end
        end)

        sbUpdate()
    end

    -- Home ------------------------------------------------------
    local homeHasList = pgHome:FindFirstChild("UFOX_List") ~= nil
    if not homeHasList then
        local listWrap = make("Frame",{
            Parent = pgHome, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -58), Position = UDim2.new(0, 0, 0, 58),
            Name = "UFOX_ListWrap"
        },{})

        local sc = make("ScrollingFrame",{
            Parent = listWrap, Name="UFOX_List",
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            BorderSizePixel = 0, ClipsDescendants = true,
            Size = UDim2.new(1, -12, 1, -12), Position = UDim2.new(0, 6, 0, 6),
            ScrollBarThickness = 6, CanvasSize = UDim2.new(0,0,0,0)
        },{
            make("UICorner",{CornerRadius=UDim.new(0,12)}),
            make("UIStroke",{Color=ACCENT, Transparency=0.85}),
            make("UIPadding",{PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,10), PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10)})
        })

        local lay = make("UIListLayout",{
            Parent = sc, FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,10)
        },{})

        local function updateCanvas()
            task.defer(function()
                local sz = lay.AbsoluteContentSize
                sc.CanvasSize = UDim2.fromOffset(0, sz.Y + 20)
            end)
        end
        lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        local function tiny(parent, name, txt, posY, cb)
            local b = make("TextButton",{
                Parent=parent, Name=name, AutoButtonColor=false, Text=txt,
                Font=Enum.Font.GothamBold, TextSize=16, TextColor3=FG,
                Size=UDim2.new(0,30,0,30), Position=UDim2.new(1,-38,0,posY),
                BackgroundColor3=SUB
            },{
                make("UICorner",{CornerRadius=UDim.new(0,8)}),
                make("UIStroke",{Color=ACCENT, Transparency=0.4})
            })
            b.MouseButton1Click:Connect(cb)
            return b
        end
        tiny(listWrap, "UFOX_ScrollUp", "▲", 6, function()
            sc.CanvasPosition = Vector2.new(0, math.max(0, sc.CanvasPosition.Y - 140))
        end)
        tiny(listWrap, "UFOX_ScrollDn", "▼", 42, function()
            local maxY = math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y)
            sc.CanvasPosition = Vector2.new(0, math.min(maxY, sc.CanvasPosition.Y + 140))
        end)

        local SEQ = 0
        local function makeCard(title, subtitle)
            SEQ += 1
            local card = make("Frame",{
                Parent = sc, Name = "UFOX_Item_"..SEQ, LayoutOrder = SEQ,
                BackgroundColor3=Color3.fromRGB(24,24,24), BorderSizePixel=0,
                Size = UDim2.new(1, -0, 0, 56), ClipsDescendants=true
            },{
                make("UICorner",{CornerRadius=UDim.new(0,10)}),
                make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.2})
            })

            local lpad = make("Frame",{Parent=card, BackgroundTransparency=1,
                Size=UDim2.new(1,-16,1,-12), Position=UDim2.new(0,8,0,6)},{})

            make("TextLabel",{Parent=lpad, BackgroundTransparency=1,
                Size=UDim2.new(1, -0, 0, 22), Position=UDim2.new(0,0,0,0),
                Font=Enum.Font.GothamBold, TextSize=16, TextColor3=FG,
                Text = title or ("Item #" .. tostring(SEQ)),
                TextXAlignment=Enum.TextXAlignment.Left
            },{})

            make("TextLabel",{Parent=lpad, BackgroundTransparency=1,
                Size=UDim2.new(1, -0, 0, 18), Position=UDim2.new(0,0,0,24),
                Font=Enum.Font.Gotham, TextSize=13, TextColor3=Color3.fromRGB(170,170,170),
                Text = subtitle or os.date("!%Y-%m-%d %H:%M UTC"),
                TextXAlignment=Enum.TextXAlignment.Left
            },{})

            local glow = make("Frame",{Parent=card, BackgroundColor3=ACCENT, BorderSizePixel=0,
                Size=UDim2.new(0,0,0,2), Position=UDim2.new(0,0,1,-2)},{})
            TS:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size=UDim2.new(1,0,0,2)}):Play()
            task.delay(0.35, function()
                TS:Create(glow, TweenInfo.new(0.25), {BackgroundTransparency=1}):Play()
                task.delay(0.25, function() pcall(function() glow:Destroy() end) end)
            end)

            updateCanvas()
            return card
        end

        -- 🔧 API ฝั่งขวา
        _G.UFOX_AddItem = function(title, subtitle)
            local item = makeCard(title, subtitle)
            task.defer(function()
                local maxY = math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y)
                sc.CanvasPosition = Vector2.new(0, maxY)
            end)
            return item
        end

        _G.UFOX_ScrollToLatest = function()
            task.defer(function()
                local maxY = math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y)
                sc.CanvasPosition = Vector2.new(0, maxY)
            end)
        end

        -- Toolbar + ปุ่ม Create
        local bar = make("Frame",{
            Parent = pgHome, BackgroundTransparency=1,
            Size = UDim2.new(1, -20, 0, 46), Position = UDim2.new(0,10,0,10),
            Name = "UFOX_Toolbar"
        },{})
        local createBtn = make("TextButton",{
            Parent=bar, Name="UFOX_CreateBtn", AutoButtonColor=false,
            Text="Create", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=FG,
            BackgroundColor3=SUB,
            Size=UDim2.new(0,100,1,0), Position=UDim2.new(0,0,0,0)
        },{
            make("UICorner",{CornerRadius=UDim.new(0,10)}),
            make("UIStroke",{Color=ACCENT, Thickness=2, Transparency=0.2})
        })

        local AUTO = 0
        createBtn.MouseButton1Click:Connect(function()
            AUTO += 1
            _G.UFOX_AddItem("Created item #" .. tostring(AUTO))
        end)

        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == Enum.KeyCode.N
                and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
                createBtn:Activate()
            elseif i.KeyCode == Enum.KeyCode.End
                and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
                _G.UFOX_ScrollToLatest()
            end
        end)

        updateCanvas()
    end
end

----------------------------------------------------------------
-- 📱 MOBILE PATCH: attach GUI to PlayerGui (safe add-on)
----------------------------------------------------------------
task.defer(function()
    pcall(function() if not game:IsLoaded() then game.Loaded:Wait() end end)

    local function bestGuiParent()
        if typeof(gethui) == "function" then
            local ok, ui = pcall(gethui)
            if ok and typeof(ui) == "Instance" then return ui end
        end
        local CGok = (pcall(function() return CG.Parent ~= nil end) and CG.Parent ~= nil)
        if CGok then return CG end
        local pg = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 2)
        return pg or CG
    end

    local function attachAll()
        local par = bestGuiParent()
        pcall(function() if mainGui.Parent ~= par then mainGui.Parent = par end end)
        pcall(function() if toggleGui.Parent ~= par then toggleGui.Parent = par end end)
        pcall(function() mainGui.Enabled = true end)
        pcall(function() toggleGui.Enabled = true end)
    end

    attachAll()

    mainGui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then attachAll() end
    end)
    toggleGui.AncestryChanged:Connect(function(_, parent)
        if parent == nil then attachAll() end
    end)

    task.delay(0.2, function()
        pcall(function()
            if Camera and main then
                local vp = Camera.ViewportSize
                main.Position = UDim2.fromOffset(
                    math.floor((vp.X - main.AbsoluteSize.X)/2) + X_OFFSET,
                    math.floor((vp.Y - main.AbsoluteSize.Y)/2) + Y_OFFSET
                )
                if TOGGLE_DOCKED and btnToggle then
                    local mPos  = main.AbsolutePosition
                    local mSize = main.AbsoluteSize
                    local tX = math.floor(mPos.X - btnToggle.AbsoluteSize.X - TOGGLE_GAP)
                    local tY = math.floor(mPos.Y + (mSize.Y - btnToggle.AbsoluteSize.Y)/2 + TOGGLE_DY)
                    btnToggle.Position = UDim2.fromOffset(tX, tY)
                end
            end
        end)
    end)

    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "UFO HUB X",
            Text  = "UI loaded (mobile)",
            Duration = 2
        })
    end)
end)
