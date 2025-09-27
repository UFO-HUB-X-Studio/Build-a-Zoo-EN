----------------------------------------------------------------
-- UFOX SCROLL+BORDER+ORDER (FULL DROP-IN, DO NOT BREAK OLD UI)
-- - เลื่อนขึ้นลง: ทั้ง left และ content (ไม่ลบ ไม่แก้ของเดิม แค่ห่อ)
-- - ทุกชิ้นใหม่มีขอบสีเขียวอัตโนมัติ
-- - ลำดับ 1→2→3…: ของเก่า/ใหม่ต่อท้ายล่างเสมอ
-- - Self-heal: กันซ้ำ/กันซ้อน/กันโดนแก้ stroke
-- - ใส่แล้วจบ ใช้กับ UI เดิม 100%
----------------------------------------------------------------

-------------------- CONFIG --------------------
local CFG = {
    -- สี/สโตรก
    ACCENT               = (ACCENT or Color3.fromRGB(0,255,140)),
    BORDER_THICKNESS     = 2,

    -- สกรอลเลอร์
    SCROLLBAR_THICKNESS  = 8,
    SCROLLBAR_TRANS      = 0.05,
    PADDING              = 10,   -- padding รอบๆ เนื้อหา
    GAP                  = 10,   -- ช่องว่างระหว่างไอเท็ม (UIListLayout.Padding)

    -- Debug log (set true ถ้าอยากเห็น print)
    DEBUG                = false,
}

local function dprint(...)
    if CFG.DEBUG then
        print("[UFOX]", ...)
    end
end

-------------------- HELPERS --------------------
local function isLayoutLike(obj)
    return obj:IsA("UIListLayout") or obj:IsA("UIGridLayout") or obj:IsA("UITableLayout")
        or obj:IsA("UIPadding") or obj:IsA("UICorner") or obj:IsA("UIStroke")
        or obj:IsA("UIGradient") or obj:IsA("UISizeConstraint") or obj:IsA("UITextSizeConstraint")
        or obj:IsA("UICanvasGroup") -- เผื่อมี
end

-- ใส่/บังคับขอบสีเขียว
local function forceGreenBorder(gui)
    if not gui or not gui.Parent then return end
    if not (gui:IsA("Frame") or gui:IsA("TextButton") or gui:IsA("ImageButton") or gui:IsA("ImageLabel")) then
        return
    end
    local stroke = gui:FindFirstChild("UFOX_Border_Green")
    if not stroke then
        stroke = Instance.new("UIStroke")
        stroke.Name = "UFOX_Border_Green"
        stroke.Parent = gui
    end
    stroke.Color = CFG.ACCENT
    stroke.Thickness = CFG.BORDER_THICKNESS
    stroke.Transparency = 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

-- จัดลำดับแบบต่อท้าย
local function nextOrderFor(container)
    local n = container:GetAttribute("UFOX_NextOrder") or 1
    container:SetAttribute("UFOX_NextOrder", n + 1)
    return n
end

-- ตรวจว่ามี scroller เดิมแล้วไหม
local function findScroller(target, key)
    return target:FindFirstChild("UFOX_Scroller_"..key)
end

-- อัปเดต CanvasSize กรณีไม่มี AutomaticCanvasSize.Y
local function manualUpdateCanvas(sc)
    if sc.AutomaticCanvasSize == Enum.AutomaticSize.Y then return end
    local pad   = sc:FindFirstChild("UFOX_Pad")
    local list  = sc:FindFirstChild("UFOX_List")
    local total = 0
    for _,c in ipairs(sc:GetChildren()) do
        if c:IsA("GuiObject") and c ~= pad and c ~= list then
            total += c.AbsoluteSize.Y + (list and list.Padding.Offset or 0)
        end
    end
    total += CFG.PADDING
    sc.CanvasSize = UDim2.new(0,0,0, total)
end

-- ย้ายลูกเก่าเข้า scroller + set order + stroke
local function migrateChildrenInto(sc, from)
    from:SetAttribute("UFOX_NextOrder", 1)

    -- เก็บ “GuiObject ที่ไม่ใช่ layout-like” ทั้งหมด
    local listToMove = {}
    for _,ch in ipairs(from:GetChildren()) do
        if ch ~= sc and ch:IsA("GuiObject") and (not isLayoutLike(ch)) then
            table.insert(listToMove, ch)
        end
    end

    -- ถ้ามี LayoutOrder เดิม, ให้เรียงตามนั้น; ถ้าไม่มีก็เรียงตามลำดับที่เจอ
    local hasOrder = false
    for _,g in ipairs(listToMove) do
        if g.LayoutOrder and g.LayoutOrder ~= 0 then hasOrder = true break end
    end
    if hasOrder then
        table.sort(listToMove, function(a,b) return a.LayoutOrder < b.LayoutOrder end)
    end

    for _,gui in ipairs(listToMove) do
        gui.Parent = sc
        gui.LayoutOrder = nextOrderFor(sc)
        forceGreenBorder(gui)
    end
end

-- ติดตั้ง scroller ให้ target frame
local function installScroller(targetFrame, key)
    if not targetFrame or not targetFrame:IsA("Frame") then
        dprint("skip install: target not Frame", key, targetFrame)
        return nil
    end

    -- กันติดตั้งซ้ำ
    local exists = findScroller(targetFrame, key)
    if exists then
        dprint("scroller exists", key)
        return exists
    end

    -- สร้าง ScrollingFrame
    local sc = Instance.new("ScrollingFrame")
    sc.Name = "UFOX_Scroller_"..key
    sc.Parent = targetFrame
    sc.Size = UDim2.fromScale(1,1)
    sc.Position = UDim2.fromOffset(0,0)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ClipsDescendants = true

    sc.ScrollingDirection = Enum.ScrollingDirection.Y
    sc.ScrollBarThickness = CFG.SCROLLBAR_THICKNESS
    sc.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    sc.ScrollBarImageColor3 = CFG.ACCENT
    sc.ScrollBarImageTransparency = CFG.SCROLLBAR_TRANS
    sc.CanvasPosition = Vector2.new(0,0)
    pcall(function() sc.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

    -- padding
    local pad = Instance.new("UIPadding")
    pad.Name = "UFOX_Pad"
    pad.PaddingTop    = UDim.new(0, CFG.PADDING)
    pad.PaddingBottom = UDim.new(0, CFG.PADDING)
    pad.PaddingLeft   = UDim.new(0, CFG.PADDING)
    pad.PaddingRight  = UDim.new(0, CFG.PADDING)
    pad.Parent = sc

    -- list layout แนวตั้ง
    local list = Instance.new("UIListLayout")
    list.Name = "UFOX_List"
    list.Parent = sc
    list.FillDirection = Enum.FillDirection.Vertical
    list.Padding = UDim.new(0, CFG.GAP)
    list.HorizontalAlignment = Enum.HorizontalAlignment.Stretch
    list.VerticalAlignment   = Enum.VerticalAlignment.Top
    list.SortOrder = Enum.SortOrder.LayoutOrder

    -- อัปเดต Canvas ถ้าต้องทำเอง
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasPosition = Vector2.new(0,0)
        manualUpdateCanvas(sc)
    end)

    -- ย้ายลูกเดิมเข้า scroller
    migrateChildrenInto(sc, targetFrame)

    -- handler: ใส่ของใหม่ที่ target หรือ sc เอง
    local function handleChild(obj)
        if not obj:IsA("GuiObject") or isLayoutLike(obj) then return end
        if obj.Parent == targetFrame then
            obj.Parent = sc
        end
        obj.LayoutOrder = nextOrderFor(sc)
        forceGreenBorder(obj)
        manualUpdateCanvas(sc)
    end

    targetFrame.ChildAdded:Connect(function(ch) task.defer(handleChild, ch) end)
    sc.ChildAdded:Connect(function(ch) task.defer(handleChild, ch) end)

    -- self-heal: stroke ถูกแก้ -> รีเซ็ต
    sc.DescendantAdded:Connect(function(d)
        if d:IsA("UIStroke") and d.Name == "UFOX_Border_Green" then
            task.defer(function()
                if d.Parent and d.Parent:IsA("GuiObject") then
                    d.Color = CFG.ACCENT
                    d.Thickness = CFG.BORDER_THICKNESS
                    d.Transparency = 0
                    d.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                end
            end)
        end
    end)

    -- บังคับไปบนสุด + อัปเดตแรก
    task.delay(0.05, function()
        sc.CanvasPosition = Vector2.new(0,0)
        manualUpdateCanvas(sc)
    end)

    dprint("scroller installed for", key)
    return sc
end

----------------------------------------------------------------
-- >>> ติดตั้งให้ทั้ง 2 ฝั่ง: left และ content <<<
-- หมายเหตุ: โค้ดนี้ “ต้องวางต่อท้าย” ตอนที่ left/content ถูกสร้างแล้ว
----------------------------------------------------------------
local okL, scLeft = pcall(function() return installScroller(left,    "LEFT")    end)
local okR, scRight= pcall(function() return installScroller(content, "CONTENT") end)
if not okL then warn("[UFOX] install LEFT failed:", scLeft) end
if not okR then warn("[UFOX] install CONTENT failed:", scRight) end

-- เสริม: กรณี dev ไปเปลี่ยน Size/Position ของ content/left ภายหลัง → รักษา scroller ให้เต็มเสมอ
for _,pair in ipairs({
    {frame = left,    key = "LEFT"},
    {frame = content, key = "CONTENT"},
}) do
    local fr = pair.frame
    if fr and fr:IsA("GuiObject") then
        fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            local sc = findScroller(fr, pair.key)
            if sc then
                sc.Size = UDim2.fromScale(1,1)
                manualUpdateCanvas(sc)
            end
        end)
        fr.AncestryChanged:Connect(function()
            local sc = findScroller(fr, pair.key)
            if sc then
                sc.Size = UDim2.fromScale(1,1)
                manualUpdateCanvas(sc)
            end
        end)
    end
end

-- จบ. แค่วางบล็อคนี้ “ต่อท้ายสุด” ก็จะ:
-- - เลื่อนขึ้นลงได้ทั้งซ้ายและขวา
-- - ทุกชิ้นมีขอบสีเขียว
-- - อะไรที่สร้างใหม่ → ต่อท้ายล่าง (1..N)
-- - ไม่แตะต้องโครง/สไตล์เดิมของคุณ
----------------------------------------------------------------
