local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "AizenEmotes"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- ========== Helpers ==========
local function getHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("Humanoid")
end

local function corner(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
end

-- ========== Head tag ==========
local function addHeadTag(char)
    local head = char:WaitForChild("Head", 5)
    if not head then return end
    local old = head:FindFirstChild("AizenTag")
    if old then old:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "AizenTag"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 40)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "AIZEN PANEL"
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(170, 90, 255)
    lbl.TextStrokeTransparency = 0.3
    lbl.Parent = bb

end

-- ========== RP name + bio (visible to everyone) ==========
local RP_NAME = "AIZEN PANEL"
local RP_BIO = "by ANSHUx"
local RP_COLOR = Color3.fromRGB(170, 90, 255)

local rpBusy = false
local function setRPInfo()
    if rpBusy then return end
    rpBusy = true

    -- Wait for the game's remotes instead of giving up if they aren't loaded yet
    local re = ReplicatedStorage:WaitForChild("RE", 15)
    local remote = re and re:WaitForChild("1RPNam1eTex1t", 15)
    if not remote then
        rpBusy = false
        return
    end

    -- Send a few times: the game can overwrite/reset the name right after spawn
    for _ = 1, 3 do
        pcall(function() remote:FireServer("RolePlayName", RP_NAME) end)
        task.wait(0.4)
        pcall(function() remote:FireServer("RolePlayBio", RP_BIO) end)
        task.wait(1.2)
    end
    rpBusy = false
end

if player.Character then
    task.spawn(addHeadTag, player.Character)
end
task.spawn(function()
    task.wait(2) -- let the game finish loading first
    setRPInfo()
end)

-- ========== Intro animation ==========
local intro = Instance.new("Frame")
intro.Size = UDim2.new(1, 0, 1, 0)
intro.BackgroundColor3 = Color3.new(0, 0, 0)
intro.BackgroundTransparency = 1
intro.ZIndex = 10
intro.Parent = gui

local introTitle = Instance.new("TextLabel")
introTitle.AnchorPoint = Vector2.new(0.5, 0.5)
introTitle.Position = UDim2.new(0.5, 0, 0.45, 0)
introTitle.Size = UDim2.new(0, 400, 0, 60)
introTitle.BackgroundTransparency = 1
introTitle.Text = "AIZEN EMOTES"
introTitle.Font = Enum.Font.GothamBlack
introTitle.TextSize = 12
introTitle.TextColor3 = Color3.fromRGB(170, 90, 255)
introTitle.TextTransparency = 1
introTitle.ZIndex = 11
introTitle.Parent = intro

local introSub = Instance.new("TextLabel")
introSub.AnchorPoint = Vector2.new(0.5, 0.5)
introSub.Position = UDim2.new(0.5, 0, 0.55, 0)
introSub.Size = UDim2.new(0, 300, 0, 30)
introSub.BackgroundTransparency = 1
introSub.Text = "by Anshux"
introSub.Font = Enum.Font.GothamMedium
introSub.TextSize = 20
introSub.TextColor3 = Color3.new(1, 1, 1)
introSub.TextTransparency = 1
introSub.ZIndex = 11
introSub.Parent = intro

local function playIntro()
    local fade = TweenInfo.new(0.6)
    TweenService:Create(intro, fade, {BackgroundTransparency = 0.15}):Play()
    task.wait(0.5)
    TweenService:Create(introTitle, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {TextSize = 52, TextTransparency = 0}):Play()
    task.wait(0.7)
    TweenService:Create(introSub, fade, {TextTransparency = 0}):Play()
    task.wait(1.6)
    local out = TweenInfo.new(0.7)
    TweenService:Create(introTitle, out, {TextTransparency = 1}):Play()
    TweenService:Create(introSub, out, {TextTransparency = 1}):Play()
    TweenService:Create(intro, out, {BackgroundTransparency = 1}):Play()
    task.wait(0.8)
    intro:Destroy()
end

task.spawn(playIntro)

-- Announce in chat (works with both the new and the legacy Roblox chat)
local function sendChat(msg)
    pcall(function()
        local TextChatService = game:GetService("TextChatService")
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:WaitForChild("TextChannels", 5)
            local general = channels and channels:WaitForChild("RBXGeneral", 5)
            if general then general:SendAsync(msg) end
        else
            local events = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents", 5)
            local say = events and events:WaitForChild("SayMessageRequest", 5)
            if say then say:FireServer(msg, "All") end
        end
    end)
end
task.spawn(function()
    task.wait(1.5)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "AIZEN PANEL",
            Text = "Launched successfully  •  by Anshux",
            Duration = 5,
        })
    end)
    sendChat("✦ AIZEN PANEL ✦ Launched successfully • Emotes & Avatar ready • by Anshux")
end)

-- ========== Window system ==========
local function makeButton(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 26)
    b.BackgroundColor3 = Color3.fromRGB(60, 50, 85)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.Parent = parent
    corner(b, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- cfg: title, minTitle, w, h, minW, pos (UDim2)
local function makeWindow(cfg)
    local win = {minimized = false}
    local MIN_H = 30

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, cfg.w, 0, cfg.h)
    frame.Position = cfg.pos
    frame.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
    frame.Active = true
    frame.Draggable = true
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = gui
    corner(frame, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(170, 90, 255)
    stroke.Thickness = 1.5

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = cfg.title
    title.RichText = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextColor3 = Color3.fromRGB(190, 120, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.Parent = frame

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, -34)
    body.Position = UDim2.new(0, 0, 0, 32)
    body.BackgroundTransparency = 1
    body.Parent = frame

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 22, 0, 22)
    minBtn.Position = UDim2.new(1, -26, 0, 4)
    minBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 80)
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.Parent = frame
    corner(minBtn, 6)

    function win.setMinimized(state)
        win.minimized = state
        minBtn.Text = state and "+" or "-"
        if state then
            body.Visible = false
            title.Text = cfg.minTitle
            TweenService:Create(frame, TweenInfo.new(0.25), {
                Size = UDim2.new(0, cfg.minW, 0, MIN_H)
            }):Play()
        else
            title.Text = cfg.title
            TweenService:Create(frame, TweenInfo.new(0.25), {
                Size = UDim2.new(0, cfg.w, 0, cfg.h)
            }):Play()
            task.delay(0.2, function()
                if not win.minimized then body.Visible = true end
            end)
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        win.setMinimized(not win.minimized)
    end)

    -- show / hide (used by the hub buttons)
    function win.toggle()
        if frame.Visible then
            frame.Visible = false
        else
            local targetH = win.minimized and MIN_H or cfg.h
            local targetW = win.minimized and cfg.minW or cfg.w
            body.Visible = false
            frame.Size = UDim2.new(0, targetW, 0, 0)
            frame.Visible = true
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                {Size = UDim2.new(0, targetW, 0, targetH)}):Play()
            task.delay(0.32, function()
                if frame.Visible and not win.minimized then body.Visible = true end
            end)
        end
    end

    win.frame = frame
    win.body = body
    return win
end

-- ========== Emotes window ==========
local emoteWin = makeWindow({
    title = "EMOTES  <font size='10' color='rgb(180,180,180)'>by Anshux</font>",
    minTitle = "EMOTES",
    w = 190, h = 300, minW = 100,
    pos = UDim2.new(0, 180, 0, 20),
})
local body = emoteWin.body

-- Emote button with a preview thumbnail
local function makeEmoteButton(parent, name, assetId, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 44)
    b.BackgroundColor3 = Color3.fromRGB(60, 50, 85)
    b.Text = ""
    b.AutoButtonColor = true
    b.Parent = parent
    corner(b, 6)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 38, 0, 38)
    img.Position = UDim2.new(0, 3, 0.5, -19)
    img.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
    img.BorderSizePixel = 0
    img.ScaleType = Enum.ScaleType.Fit
    img.Image = ("rbxthumb://type=Asset&id=%d&w=150&h=150"):format(assetId)
    img.Parent = b
    corner(img, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, -4)
    lbl.Position = UDim2.new(0, 46, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.Parent = b

    b.MouseButton1Click:Connect(cb)
    return b
end

-- Search
local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -12, 0, 24)
search.Position = UDim2.new(0, 6, 0, 0)
search.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderText = "Search + Enter"
search.Text = ""
search.Font = Enum.Font.Gotham
search.TextSize = 12
search.ClearTextOnFocus = false
search.Parent = body
corner(search, 6)

-- List
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -12, 1, -134)
list.Position = UDim2.new(0, 6, 0, 28)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = body
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Text = ""
status.LayoutOrder = -1
status.Parent = list

-- ========== Animation playing ==========
local currentTrack
local keepOn = false
local animCache = {}

local function stopAll()
    currentTrack = nil
    for _, t in ipairs(getHumanoid():GetPlayingAnimationTracks()) do
        t:Stop()
    end
end

local function playId(id)
    stopAll()
    local hum = getHumanoid()
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. id
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play()
        currentTrack = track
    end
end

local function playEmote(id)
    local animId = animCache[id]
    if not animId then
        local ok, objs = pcall(function()
            return game:GetObjects("rbxassetid://" .. id)
        end)
        if ok and objs and objs[1] then
            local anim = objs[1]:IsA("Animation") and objs[1]
                or objs[1]:FindFirstChildWhichIsA("Animation", true)
            animId = anim and tonumber(tostring(anim.AnimationId):match("%d+"))
            animCache[id] = animId
        end
    end
    if animId then
        playId(animId)
        return
    end
    -- fallback
    stopAll()
    local ok, track = pcall(function()
        return getHumanoid():PlayEmoteAndGetAnimTrackById(id)
    end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        currentTrack = track
    else
        status.Text = "This emote can't be played"
    end
end

-- Keep emote playing while moving
RunService.Heartbeat:Connect(function()
    if keepOn and currentTrack and not currentTrack.IsPlaying then
        pcall(function() currentTrack:Play() end)
    end
end)

player.CharacterAdded:Connect(function(char)
    currentTrack = nil
    task.spawn(addHeadTag, char)
    task.delay(3, setRPInfo)
end)

-- ========== Catalog loader ==========
local classic = {
    {"Wave", 507770239}, {"Point", 507770453}, {"Cheer", 507770677},
    {"Laugh", 507770818}, {"Dance 1", 507771019}, {"Dance 2", 507776043},
    {"Dance 3", 507777268},
}

local domains = {"catalog.roblox.com", "catalog.roproxy.com"}
local variants = {"Category=12&Subcategory=39", "Category=AvatarAnimations&Subcategory=Emotes"}

local function httpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and body and body ~= "" then return body end
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if req then
        local ok2, res = pcall(function() return req({Url = url, Method = "GET"}) end)
        if ok2 and res and res.Body and (res.StatusCode or 200) == 200 then
            return res.Body
        end
    end
end

local function getCatalog(extra)
    for _, domain in ipairs(domains) do
        for _, v in ipairs(variants) do
            local url = ("https://%s/v1/search/items/details?%s&Limit=30%s"):format(domain, v, extra)
            local raw = httpGet(url)
            if raw then
                local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and data and data.data then return data end
            end
        end
    end
end

local nextCursor, loading = nil, false

local loadMore = makeButton(list, "Load more...", function() end)
loadMore.LayoutOrder = 99999
loadMore.BackgroundColor3 = Color3.fromRGB(90, 60, 140)
loadMore.Visible = false

local function clearList()
    for _, c in ipairs(list:GetChildren()) do
        if c:IsA("TextButton") and c ~= loadMore then c:Destroy() end
    end
end

local order = 0
local function fetchEmotes(reset)
    if loading then return end
    loading = true
    local q = search.Text
    status.Text = "Loading..."
    if reset then
        nextCursor = nil
        order = 0
        clearList()
        if q == "" then
            for _, e in ipairs(classic) do
                order += 1
                local b = makeEmoteButton(list, e[1], e[2], function() playId(e[2]) end)
                b.LayoutOrder = order
            end
        end
    end

    local extra = ""
    if q ~= "" then extra ..= "&Keyword=" .. HttpService:UrlEncode(q) end
    if nextCursor then extra ..= "&Cursor=" .. nextCursor end

    local res = getCatalog(extra)
    if res then
        for _, item in ipairs(res.data) do
            order += 1
            local b = makeEmoteButton(list, item.name or "Emote", item.id, function() playEmote(item.id) end)
            b.LayoutOrder = order
        end
        nextCursor = res.nextPageCursor
        status.Text = ""
    else
        status.Text = "Failed to load catalog (wait & retry)"
    end
    loadMore.Visible = nextCursor ~= nil
    loading = false
end

loadMore.MouseButton1Click:Connect(function() fetchEmotes(false) end)
search.FocusLost:Connect(function() fetchEmotes(true) end)
task.spawn(fetchEmotes, true)

-- ========== Bottom controls ==========
local keepBtn
keepBtn = makeButton(body, "Keep: OFF", function()
    keepOn = not keepOn
    keepBtn.Text = "Keep: " .. (keepOn and "ON" or "OFF")
    keepBtn.BackgroundColor3 = keepOn and Color3.fromRGB(50, 130, 80) or Color3.fromRGB(60, 50, 85)
end)
keepBtn.Position = UDim2.new(0, 6, 1, -102)
keepBtn.Size = UDim2.new(1, -12, 0, 26)

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -12, 0, 24)
box.Position = UDim2.new(0, 6, 1, -72)
box.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
box.TextColor3 = Color3.new(1, 1, 1)
box.PlaceholderText = "Animation ID"
box.Text = ""
box.Font = Enum.Font.Gotham
box.TextSize = 12
box.ClearTextOnFocus = false
box.Parent = body
corner(box, 6)

local playBtn = makeButton(body, "Play ID", function()
    local id = tonumber(box.Text)
    if id then playId(id) end
end)
playBtn.Size = UDim2.new(0.5, -9, 0, 26)
playBtn.Position = UDim2.new(0, 6, 1, -42)

local stopBtn = makeButton(body, "Stop", stopAll)
stopBtn.Size = UDim2.new(0.5, -9, 0, 26)
stopBtn.Position = UDim2.new(0.5, 3, 1, -42)
stopBtn.BackgroundColor3 = Color3.fromRGB(110, 45, 70)

-- ========== Avatar copier window ==========
local avatarWin = makeWindow({
    title = "AVATAR  <font size='10' color='rgb(255,190,60)'>BETA</font>",
    minTitle = "AVATAR <font size='9' color='rgb(255,190,60)'>BETA</font>",
    w = 190, h = 330, minW = 125,
    pos = UDim2.new(0, 385, 0, 20),
})
local abody = avatarWin.body

local aNameBox = Instance.new("TextBox")
aNameBox.Size = UDim2.new(1, -12, 0, 24)
aNameBox.Position = UDim2.new(0, 6, 0, 0)
aNameBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
aNameBox.TextColor3 = Color3.new(1, 1, 1)
aNameBox.PlaceholderText = "Username / User ID"
aNameBox.Text = ""
aNameBox.Font = Enum.Font.Gotham
aNameBox.TextSize = 12
aNameBox.ClearTextOnFocus = false
aNameBox.Parent = abody
corner(aNameBox, 6)

local aStatus = Instance.new("TextLabel")
aStatus.Size = UDim2.new(1, -12, 0, 16)
aStatus.Position = UDim2.new(0, 6, 0, 56)
aStatus.BackgroundTransparency = 1
aStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
aStatus.Font = Enum.Font.Gotham
aStatus.TextSize = 11
aStatus.TextXAlignment = Enum.TextXAlignment.Left
aStatus.Text = "Tap a player or type a name"
aStatus.Parent = abody

local lastDesc          -- last copied description (for keep-on-respawn)
local copyFace = false    -- clothing, body, hair and accessories are always copied; face only when this is true
local copyBody = true     -- body colors, scale and body parts (from their saved avatar)
local currentSource       -- the character being copied (used for their in-game animations)

-- ----- Animation helpers -----
local function relPath(d, root)
    local parts, cur = {}, d
    while cur and cur ~= root do
        table.insert(parts, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(parts, ".")
end

local function collectAnims(animate)
    local map = {}
    for _, d in ipairs(animate:GetDescendants()) do
        if d:IsA("Animation") then map[relPath(d, animate)] = d.AnimationId end
    end
    return map
end

local function applyAnimMap(animate, map)
    for _, d in ipairs(animate:GetDescendants()) do
        if d:IsA("Animation") then
            local id = map[relPath(d, animate)]
            if id and id ~= "" then d.AnimationId = id end
        end
    end
    -- restart the Animate script so the new animations are picked up
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    animate.Disabled = true
    if hum then
        for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do tr:Stop() end
    end
    task.wait(0.1)
    animate.Disabled = false
end

local animSnapshot -- your own animations, for Reset
task.spawn(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local animate = char:WaitForChild("Animate", 10)
    if animate then animSnapshot = collectAnims(animate) end
end)
local originalDesc      -- your own avatar, for Reset
local keepRespawn = false

task.spawn(function()
    local ok, d = pcall(function() return getHumanoid():GetAppliedDescription() end)
    if ok and d then
        originalDesc = d
    else
        local ok2, d2 = pcall(function()
            return Players:GetHumanoidDescriptionFromUserId(player.UserId)
        end)
        if ok2 then originalDesc = d2 end
    end
end)

-- Loads an asset's instances (executor GetObjects first, InsertService as backup)
local function loadAsset(id)
    local ok, objs = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if ok and objs and objs[1] then return objs[1] end
    local InsertService = game:GetService("InsertService")
    local ok2, model = pcall(function() return InsertService:LoadAsset(id) end)
    if ok2 and model then return model end
end

-- Manual, client-side version of ApplyDescription (used when the game blocks it)
local function manualApply(desc, full)
    local all = full or copyFace
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    -- Body colors
    if copyBody then pcall(function()
        local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
        bc.HeadColor3 = desc.HeadColor
        bc.TorsoColor3 = desc.TorsoColor
        bc.LeftArmColor3 = desc.LeftArmColor
        bc.RightArmColor3 = desc.RightArmColor
        bc.LeftLegColor3 = desc.LeftLegColor
        bc.RightLegColor3 = desc.RightLegColor
    end) end

    -- Remove current clothing + accessories
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then
            v:Destroy()
        elseif v:IsA("Accessory") then
            v:Destroy()
        end
    end

    -- Shirt / Pants / T-Shirt
    local function wearClothing(id, className)
        if not id or id == 0 then return end
        local model = loadAsset(id)
        if not model then return end
        local item = model:IsA(className) and model or model:FindFirstChildWhichIsA(className, true)
        if item then item:Clone().Parent = char end
    end
    wearClothing(desc.Shirt, "Shirt")
    wearClothing(desc.Pants, "Pants")
    wearClothing(desc.GraphicTShirt, "ShirtGraphic")

    -- Face (everything mode only)
    if all then pcall(function()
        if desc.Face and desc.Face ~= 0 then
            local model = loadAsset(desc.Face)
            local decal = model and (model:IsA("Decal") and model or model:FindFirstChildWhichIsA("Decal", true))
            local head = char:FindFirstChild("Head")
            if decal and head then
                local old = head:FindFirstChild("face")
                if old then old:Destroy() end
                local d = decal:Clone()
                d.Name = "face"
                d.Parent = head
            end
        end
    end) end

    -- Accessories (hats, hair, layered clothing, etc.)
    local okAcc, accs = pcall(function() return desc:GetAccessories(true) end)
    if okAcc and accs then
        for _, a in ipairs(accs) do
          if true then
            local model = loadAsset(a.AssetId)
            local acc = model and (model:IsA("Accessory") and model or model:FindFirstChildWhichIsA("Accessory", true))
            if acc then
                local copy = acc:Clone()
                -- 3D / layered clothing: keep the original layering order + puffiness
                if a.IsLayered then
                    pcall(function()
                        local wrap = copy:FindFirstChildWhichIsA("WrapLayer", true)
                        if wrap then
                            if a.Order then wrap.Order = a.Order end
                            if a.Puffiness then wrap.Puffiness = a.Puffiness end
                        end
                    end)
                end
                pcall(function() hum:AddAccessory(copy) end)
            end
          end
        end
    end

    -- Body scale (R15)
    if copyBody then pcall(function()
        local scales = {
            BodyHeightScale = desc.HeightScale,
            BodyWidthScale = desc.WidthScale,
            BodyDepthScale = desc.DepthScale,
            HeadScale = desc.HeadScale,
        }
        for name, value in pairs(scales) do
            local v = hum:FindFirstChild(name)
            if v then v.Value = value end
        end
    end) end
end

local BODY_KEYS = {
    "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg",
    "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor",
    "HeightScale", "WidthScale", "DepthScale", "HeadScale", "BodyTypeScale", "ProportionScale",
}
local function copyBodyFields(dst, src)
    for _, k in ipairs(BODY_KEYS) do
        pcall(function() dst[k] = src[k] end)
    end
end

local ANIM_KEYS = {
    "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation",
    "FallAnimation", "ClimbAnimation", "SwimAnimation",
}

local function applyDesc(desc, full)
    local hum = getHumanoid()
    local ok, err = pcall(function()
        if full then
            hum:ApplyDescription(desc)
        else
            -- start from your own look, then swap in what was chosen
            local mine = hum:GetAppliedDescription()
            mine.Shirt = desc.Shirt
            mine.Pants = desc.Pants
            mine.GraphicTShirt = desc.GraphicTShirt
            mine:SetAccessories(desc:GetAccessories(true), true)
            if copyBody then copyBodyFields(mine, desc) end
            if copyFace then pcall(function() mine.Face = desc.Face end) end
            for _, k in ipairs(ANIM_KEYS) do
                pcall(function() mine[k] = desc[k] end)
            end
            hum:ApplyDescription(mine)
        end
    end)
    if ok then return true, "full" end

    -- The game blocked ApplyDescription, so use the manual client-side method
    local ok2, err2 = pcall(manualApply, desc, full)
    if ok2 then return true, "local" end
    return false, tostring(err2 or err)
end

-- Makes sure 3D (layered) clothing really ended up on the character
local function ensureLayered(desc)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local okAcc, accs = pcall(function() return desc:GetAccessories(true) end)
    if not okAcc or not accs then return end
    local wanted = 0
    for _, a in ipairs(accs) do if a.IsLayered then wanted += 1 end end
    if wanted == 0 then return end
    local have = 0
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Accessory") and v:FindFirstChildWhichIsA("WrapLayer", true) then have += 1 end
    end
    if have >= wanted then return end
    for _, a in ipairs(accs) do
        if a.IsLayered then
            local model = loadAsset(a.AssetId)
            local acc = model and (model:IsA("Accessory") and model or model:FindFirstChildWhichIsA("Accessory", true))
            if acc then
                local copy = acc:Clone()
                pcall(function()
                    local wrap = copy:FindFirstChildWhichIsA("WrapLayer", true)
                    if wrap then
                        if a.Order then wrap.Order = a.Order end
                        if a.Puffiness then wrap.Puffiness = a.Puffiness end
                    end
                end)
                pcall(function() hum:AddAccessory(copy) end)
            end
        end
    end
end

-- Copies their walk / idle / run / jump / fall / climb / swim animations.
-- Animations played on your own character are seen by everyone.
local function copyAnimations(desc)
    local char = player.Character
    local animate = char and char:FindFirstChild("Animate")
    if not animate then return false end

    local map
    if currentSource and currentSource.Parent then
        local theirs = currentSource:FindFirstChild("Animate")
        if theirs then map = collectAnims(theirs) end
    end
    if not map then
        map = {}
        for _, k in ipairs(ANIM_KEYS) do
            local id = desc[k]
            if id and id ~= 0 then
                local model = loadAsset(id)
                if model then
                    for _, a in ipairs(model:GetDescendants()) do
                        if a:IsA("Animation") then
                            for _, mine in ipairs(animate:GetDescendants()) do
                                if mine:IsA("Animation") and mine.Name == a.Name then
                                    map[relPath(mine, animate)] = a.AnimationId
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if next(map) == nil then return false end
    applyAnimMap(animate, map)
    return true
end

-- ========== Share with other players (uses the game's own "wear" remote) ==========
local function findWearRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local w = remotes and remotes:FindFirstChild("Wear")
    if w then return w end
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and d.Name:lower():find("wear") then
            return d
        end
    end
end

local function printRemoteCandidates()
    local names = {}
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            local n = d.Name:lower()
            if n:find("wear") or n:find("avatar") or n:find("cloth") or n:find("outfit")
                or n:find("shirt") or n:find("pant") or n:find("color") or n:find("accessor") then
                table.insert(names, d:GetFullName())
            end
        end
    end
    print("[Aizen] Possible avatar remotes:", #names > 0 and table.concat(names, ", ") or "none found")
end

-- Returns: itemsAccepted, itemsTotal (nil if no remote was found)
local function shareWithOthers(desc)
    local remote = findWearRemote()
    if not remote then
        printRemoteCandidates()
        return nil
    end

    local ids = {}
    for _, key in ipairs({"Shirt", "Pants", "GraphicTShirt"}) do
        local id = desc[key]
        if id and id ~= 0 then table.insert(ids, id) end
    end
    local okAcc, accs = pcall(function() return desc:GetAccessories(true) end)
    if okAcc and accs then
        for _, a in ipairs(accs) do
            table.insert(ids, a.AssetId)
        end
    end

    local accepted = 0
    for _, id in ipairs(ids) do
        local ok
        if remote:IsA("RemoteFunction") then
            ok = pcall(function() return remote:InvokeServer(id) end)
        else
            ok = pcall(function() remote:FireServer(id) end)
        end
        if ok then accepted += 1 end
        task.wait(0.2)
    end
    return accepted, #ids
end

-- Finds a player in this server by username or display name
local function findServerPlayer(text)
    local lower = text:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower() == lower or plr.DisplayName:lower() == lower then
            return plr
        end
    end
end

local copying = false
local function copyAvatar(input)
    if copying then return end
    input = (input or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if input == "" then
        aStatus.Text = "Type a name first"
        return
    end
    copying = true
    aStatus.Text = "Copying..."

    local desc, label
    local target = findServerPlayer(input)

    -- Best precision: what the player is wearing right now
    if target and target.Character then
        local th = target.Character:FindFirstChildOfClass("Humanoid")
        if th then
            local ok, d = pcall(function() return th:GetAppliedDescription() end)
            if ok and d then desc, label = d, target.Name end
        end
    end

    -- Otherwise use their saved Roblox avatar (works for anyone, even offline)
    if not desc then
        local userId = tonumber(input)
        if not userId then
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(input) end)
            if ok then userId = id end
        end
        if userId then
            local ok, d = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(userId)
            end)
            if ok and d then desc, label = d, tostring(input) end
        end
    end

    if not desc then
        aStatus.Text = "User not found"
        copying = false
        return
    end

    currentSource = (target and target.Character) or nil
    local ok, mode = applyDesc(desc)
    if ok then
        lastDesc = desc
        aStatus.Text = "Applying 3D clothes + animations..."
        pcall(ensureLayered, desc)
        pcall(copyAnimations, desc)
        aStatus.Text = "Sharing with others..."
        local accepted, total = shareWithOthers(desc)
        if accepted then
            aStatus.Text = ("Copied: %s (shared %d/%d)"):format(label, accepted, total)
        else
            aStatus.Text = "Copied: " .. label .. " (local only)"
        end
    else
        aStatus.Text = "Failed: " .. tostring(mode):sub(1, 40)
    end
    copying = false
end

local copyBtn = makeButton(abody, "Copy", function() copyAvatar(aNameBox.Text) end)
copyBtn.Size = UDim2.new(0, 56, 0, 26)
copyBtn.Position = UDim2.new(0, 6, 0, 28)
copyBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local resetBtn = makeButton(abody, "Reset", function()
    if originalDesc then
        currentSource = nil
        local ok = applyDesc(originalDesc, true)
        pcall(function()
            local animate = player.Character and player.Character:FindFirstChild("Animate")
            if animate and animSnapshot then applyAnimMap(animate, animSnapshot) end
        end)
        lastDesc = nil
        aStatus.Text = ok and "Back to your avatar" or "Reset failed"
    else
        aStatus.Text = "No saved avatar"
    end
end)
resetBtn.Size = UDim2.new(0, 56, 0, 26)
resetBtn.Position = UDim2.new(0, 66, 0, 28)
resetBtn.BackgroundColor3 = Color3.fromRGB(110, 45, 70)

-- Players in the server (tap to copy)
local aList = Instance.new("ScrollingFrame")
aList.Size = UDim2.new(1, -12, 1, -168)
aList.Position = UDim2.new(0, 6, 0, 76)
aList.BackgroundTransparency = 1
aList.ScrollBarThickness = 4
aList.CanvasSize = UDim2.new(0, 0, 0, 0)
aList.AutomaticCanvasSize = Enum.AutomaticSize.Y
aList.Parent = abody
local aLayout = Instance.new("UIListLayout", aList)
aLayout.Padding = UDim.new(0, 4)
aLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Player list: built only when the window is first opened, and in small batches
-- (building everything at once is what made opening the window lag)
local playerButtons = {}
local listBuilt = false

local function makePlayerButton(plr)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(60, 50, 85)
    b.Text = ""
    b.Parent = aList
    corner(b, 6)

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 34, 0, 34)
    img.Position = UDim2.new(0, 3, 0.5, -17)
    img.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
    img.BorderSizePixel = 0
    img.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(plr.UserId)
    img.Parent = b
    corner(img, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -44, 1, -4)
    lbl.Position = UDim2.new(0, 42, 0, 2)
    lbl.BackgroundTransparency = 1
    lbl.Text = plr.DisplayName .. "\n@" .. plr.Name
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = b

    b.MouseButton1Click:Connect(function()
        aNameBox.Text = plr.Name
        copyAvatar(plr.Name)
    end)
    return b
end

local function addPlayerButton(plr)
    if plr == player or playerButtons[plr] then return end
    playerButtons[plr] = makePlayerButton(plr)
end

local function clearList()
    for _, c in ipairs(aList:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    playerButtons = {}
    listBuilt = false
end

local function buildList()
    if listBuilt then return end
    listBuilt = true
    task.spawn(function()
        local n = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if not listBuilt then return end
            addPlayerButton(plr)
            n += 1
            if n % 3 == 0 then task.wait() end -- let the frame breathe
        end
    end)
end

Players.PlayerAdded:Connect(function(plr)
    if listBuilt then task.wait(0.5) addPlayerButton(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    local b = playerButtons[plr]
    if b then b:Destroy() playerButtons[plr] = nil end
end)

-- Scan: lists the game's avatar-related remotes so we can see what this game supports
local scanShown = false
local scanBtn
local function scanRemotes()
    if scanShown then
        -- go back to the player list
        scanShown = false
        scanBtn.Text = "Scan"
        clearList()
        aStatus.Text = "Tap a player or type a name"
        buildList()
        return
    end
    scanShown = true
    scanBtn.Text = "Back"
    clearList()
    listBuilt = true -- keep the player list from rebuilding over the scan results
    local keys = {"wear", "avatar", "cloth", "outfit", "shirt", "pant", "color", "accessor",
        "body", "skin", "face", "hair", "head", "hat", "bundle", "torso", "arm", "leg",
        "scale", "size", "morph", "charact", "appear", "rp"}
    local found, total = {}, 0
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            total += 1
            local n = d.Name:lower()
            for _, k in ipairs(keys) do
                if n:find(k, 1, true) then
                    local path = d:GetFullName():gsub("^ReplicatedStorage%.", "")
                    table.insert(found, path .. (d:IsA("RemoteFunction") and "  [F]" or "  [E]"))
                    break
                end
            end
        end
    end
    aStatus.Text = ("Remotes: %d total, %d matched"):format(total, #found)
    print("[Aizen] Avatar remotes:", table.concat(found, " | "))
    for i, name in ipairs(found) do
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.Gotham
        l.TextSize = 10
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = " " .. name
        l.LayoutOrder = i
        l.Parent = aList
        corner(l, 4)
    end
end

scanBtn = makeButton(abody, "Scan", scanRemotes)
scanBtn.Size = UDim2.new(0, 56, 0, 26)
scanBtn.Position = UDim2.new(0, 126, 0, 28)
scanBtn.BackgroundColor3 = Color3.fromRGB(45, 90, 120)

local modeBtn
modeBtn = makeButton(abody, "Copy face: OFF", function()
    copyFace = not copyFace
    modeBtn.Text = "Copy face: " .. (copyFace and "ON" or "OFF")
    modeBtn.BackgroundColor3 = copyFace and Color3.fromRGB(50, 130, 80) or Color3.fromRGB(60, 50, 85)
end)
modeBtn.Size = UDim2.new(1, -12, 0, 26)
modeBtn.Position = UDim2.new(0, 6, 1, -58)
modeBtn.TextSize = 11

local bodyBtn
bodyBtn = makeButton(abody, "Copy body: ON", function()
    copyBody = not copyBody
    bodyBtn.Text = "Copy body: " .. (copyBody and "ON" or "OFF")
    bodyBtn.BackgroundColor3 = copyBody and Color3.fromRGB(50, 130, 80) or Color3.fromRGB(60, 50, 85)
end)
bodyBtn.Size = UDim2.new(1, -12, 0, 26)
bodyBtn.Position = UDim2.new(0, 6, 1, -88)
bodyBtn.TextSize = 11
bodyBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 80)

local keepAvBtn
keepAvBtn = makeButton(abody, "Keep on respawn: OFF", function()
    keepRespawn = not keepRespawn
    keepAvBtn.Text = "Keep on respawn: " .. (keepRespawn and "ON" or "OFF")
    keepAvBtn.BackgroundColor3 = keepRespawn and Color3.fromRGB(50, 130, 80) or Color3.fromRGB(60, 50, 85)
end)
keepAvBtn.Size = UDim2.new(1, -12, 0, 26)
keepAvBtn.Position = UDim2.new(0, 6, 1, -28)
keepAvBtn.TextSize = 11

player.CharacterAdded:Connect(function()
    if keepRespawn and lastDesc then
        task.wait(1.5)
        applyDesc(lastDesc)
        pcall(ensureLayered, lastDesc)
        pcall(copyAnimations, lastDesc)
    end
end)

aNameBox.FocusLost:Connect(function(enter)
    if enter then copyAvatar(aNameBox.Text) end
end)

-- ========== Aizen Chat (private chat for script users only) ==========
-- Messages do NOT go through Roblox chat, so only people running this script can read them.
-- With Firebase set up (recommended) the [OWNER] tag is checked by Firebase's security rules,
-- so nobody can fake it. Without Firebase it falls back to the public ntfy.sh relay
-- (no verified owner tag).
local CHAT_TOPIC = "aizen-panel-chat-k7q2x9f4m1"
local CHAT_URL = "https://ntfy.sh/" .. CHAT_TOPIC   -- fallback relay
local POLL_EVERY = 5      -- seconds between checks for new messages
local SEND_EVERY = 2      -- seconds between your messages
local MAX_LEN = 150
local MAX_LOG = 60

-- ===== Firebase settings (see firebase-rules.json) =====
local FIREBASE_URL = "https://aizenrechat-default-rtdb.firebaseio.com"      -- e.g. "https://your-project-default-rtdb.firebaseio.com"
local FIREBASE_API_KEY = "AIzaSyC6MTnIx3Gb7n__fWMqs3yQpG0TECWfjHU"  -- Firebase console -> Project settings -> Web API key

-- Your owner login. Do NOT write these in this file if it is public. Run these in your
-- executor BEFORE loading the script:
--   getgenv().AIZEN_OWNER_EMAIL = "you@example.com"
--   getgenv().AIZEN_OWNER_PASSWORD = "your password"
local OWNER_EMAIL, OWNER_PASSWORD = "", ""
pcall(function()
    local g = getgenv()
    OWNER_EMAIL = tostring(g.AIZEN_OWNER_EMAIL or "")
    OWNER_PASSWORD = tostring(g.AIZEN_OWNER_PASSWORD or "")
end)

local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

local idToken, tokenExpires = nil, 0
local function getOwnerToken()
    if OWNER_EMAIL == "" or OWNER_PASSWORD == "" or FIREBASE_API_KEY == "" or not httpRequest then
        return nil
    end
    if idToken and os.time() < tokenExpires then return idToken end
    local ok, res = pcall(httpRequest, {
        Url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" .. FIREBASE_API_KEY,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            email = OWNER_EMAIL,
            password = OWNER_PASSWORD,
            returnSecureToken = true,
        }),
    })
    if not ok or not res or not res.Body then return nil end
    local okJ, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if okJ and type(data) == "table" and data.idToken then
        idToken = data.idToken
        tokenExpires = os.time() + (tonumber(data.expiresIn) or 3600) - 120
        return idToken
    end
    return nil
end

local chatWin = makeWindow({
    title = "AIZEN CHAT  <font size='10' color='rgb(180,180,180)'>script users</font>",
    minTitle = "CHAT",
    w = 210, h = 300, minW = 90,
    pos = UDim2.new(0, 180, 0, 70),
})
local cbody = chatWin.body

local cLog = Instance.new("ScrollingFrame")
cLog.Size = UDim2.new(1, -12, 1, -56)
cLog.Position = UDim2.new(0, 6, 0, 0)
cLog.BackgroundColor3 = Color3.fromRGB(18, 15, 28)
cLog.ScrollBarThickness = 4
cLog.CanvasSize = UDim2.new(0, 0, 0, 0)
cLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
cLog.Parent = cbody
corner(cLog, 6)
local cLogLayout = Instance.new("UIListLayout", cLog)
cLogLayout.Padding = UDim.new(0, 3)
cLogLayout.SortOrder = Enum.SortOrder.LayoutOrder

local cStatus = Instance.new("TextLabel")
cStatus.Size = UDim2.new(1, -12, 0, 16)
cStatus.Position = UDim2.new(0, 6, 1, -52)
cStatus.BackgroundTransparency = 1
cStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
cStatus.Font = Enum.Font.Gotham
cStatus.TextSize = 10
cStatus.TextXAlignment = Enum.TextXAlignment.Left
cStatus.Text = "Opening chat..."
cStatus.Parent = cbody

local cBox = Instance.new("TextBox")
cBox.Size = UDim2.new(1, -74, 0, 28)
cBox.Position = UDim2.new(0, 6, 1, -32)
cBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
cBox.TextColor3 = Color3.new(1, 1, 1)
cBox.PlaceholderText = "Message script users..."
cBox.Text = ""
cBox.Font = Enum.Font.Gotham
cBox.TextSize = 12
cBox.ClearTextOnFocus = false
cBox.TextXAlignment = Enum.TextXAlignment.Left
cBox.Parent = cbody
corner(cBox, 6)

local function escapeRich(t)
    return (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local logCount = 0
local unread = 0
local avatarOpenBtnText -- (unused placeholder)

local function addChatLine(name, text, mine, owner)
    logCount += 1
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -6, 0, 0)
    l.AutomaticSize = Enum.AutomaticSize.Y
    l.BackgroundTransparency = 1
    l.RichText = true
    l.TextWrapped = true
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = logCount
    local color = mine and "#6fe39a" or "#b98aff"
    local tag = owner and "<font color='#ffc83d'><b>[OWNER]</b></font> " or ""
    l.Text = ("%s<font color='%s'><b>%s</b></font>  %s"):format(tag, color, escapeRich(name), escapeRich(text))
    l.Parent = cLog

    local lines = {}
    for _, c in ipairs(cLog:GetChildren()) do
        if c:IsA("TextLabel") then table.insert(lines, c) end
    end
    if #lines > MAX_LOG then
        table.sort(lines, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        lines[1]:Destroy()
    end
    task.defer(function()
        cLog.CanvasPosition = Vector2.new(0, 1e6)
    end)
end

local mySent = {}     -- nonces of messages we sent (so the poll doesn't show them twice)
local seenIds = {}    -- relay message ids already shown
local lastSent = 0
local polling = false
local lastTime = nil

local function chatSend(text)
    text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end
    if not httpRequest then
        cStatus.Text = "Executor has no HTTP support"
        return
    end
    if os.clock() - lastSent < SEND_EVERY then
        cStatus.Text = "Slow down a little..."
        return
    end
    lastSent = os.clock()
    text = text:sub(1, MAX_LEN)

    local nonce = HttpService:GenerateGUID(false)
    mySent[nonce] = true
    addChatLine(player.DisplayName, text, true, FIREBASE_URL ~= "" and OWNER_EMAIL ~= "")

    task.spawn(function()
        local payload = HttpService:JSONEncode({
            n = nonce,
            u = player.Name,
            d = player.DisplayName,
            t = text,
        })
        local req
        if FIREBASE_URL ~= "" then
            local token = getOwnerToken()
            local body = HttpService:JSONEncode({
                n = nonce,
                u = player.Name,
                d = player.DisplayName,
                t = text,
                o = token ~= nil,                 -- Firebase rules only accept o=true from the owner
                time = {[".sv"] = "timestamp"},   -- server-side timestamp
            })
            req = {
                Url = FIREBASE_URL .. "/chat.json" .. (token and ("?auth=" .. token) or ""),
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = body,
            }
        else
            req = {Url = CHAT_URL, Method = "POST", Headers = {["Content-Type"] = "text/plain"}, Body = payload}
        end
        local ok, res = pcall(httpRequest, req)
        if ok and res and (res.StatusCode == 200 or res.Success) then
            cStatus.Text = "Online"
        else
            cStatus.Text = "Send failed"
        end
    end)
end

local sendBtn = makeButton(cbody, "Send", function()
    local t = cBox.Text
    cBox.Text = ""
    chatSend(t)
end)
sendBtn.Size = UDim2.new(0, 56, 0, 28)
sendBtn.Position = UDim2.new(1, -62, 1, -32)
sendBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

cBox.FocusLost:Connect(function(enter)
    if enter then
        local t = cBox.Text
        cBox.Text = ""
        chatSend(t)
    end
end)

local chatOpenBtn -- set when the hub button is created

local function showIncoming(data, owner)
    if not (type(data) == "table" and type(data.t) == "string") then return end
    if data.n and mySent[data.n] then return end
    local name = tostring(data.d or data.u or "?"):sub(1, 20)
    addChatLine(name, data.t:sub(1, MAX_LEN), false, owner == true)
    if not chatWin.frame.Visible or chatWin.minimized then
        unread += 1
        if chatOpenBtn then chatOpenBtn.Text = "Chat (" .. unread .. ")" end
    end
end

local function pollChat()
    if not httpRequest then
        cStatus.Text = "Executor has no HTTP support"
        return
    end

    -- Firebase: owner messages carry o = true, which Firebase's rules only allow for the owner
    if FIREBASE_URL ~= "" then
        local url
        if lastTime then
            url = FIREBASE_URL .. "/chat.json?orderBy=%22time%22&startAt=" .. tostring(lastTime + 1)
        else
            url = FIREBASE_URL .. "/chat.json?orderBy=%22time%22&limitToLast=30"
        end
        local ok, res = pcall(httpRequest, {Url = url, Method = "GET"})
        if not ok or not res or not res.Body then cStatus.Text = "Offline" return end
        local okJ, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if not okJ then cStatus.Text = "Offline" return end
        cStatus.Text = "Online"
        if type(data) ~= "table" then return end

        local list = {}
        for id, m in pairs(data) do
            if type(m) == "table" then
                m._id = id
                table.insert(list, m)
            end
        end
        table.sort(list, function(a, b) return (a.time or 0) < (b.time or 0) end)
        for _, m in ipairs(list) do
            if not seenIds[m._id] then
                seenIds[m._id] = true
                if type(m.time) == "number" then lastTime = math.max(lastTime or 0, m.time) end
                showIncoming(m, m.o == true)
            end
        end
        return
    end

    -- Public ntfy.sh relay (no verified owner tag)
    local since = lastTime and tostring(lastTime) or "10m"
    local ok, res = pcall(httpRequest, {
        Url = CHAT_URL .. "/json?poll=1&since=" .. since,
        Method = "GET",
    })
    if not ok or not res or not res.Body then
        cStatus.Text = "Offline"
        return
    end
    cStatus.Text = "Online"

    for line in tostring(res.Body):gmatch("[^\r\n]+") do
        local okJ, m = pcall(function() return HttpService:JSONDecode(line) end)
        if okJ and type(m) == "table" and m.event == "message" and m.id and not seenIds[m.id] then
            seenIds[m.id] = true
            if type(m.time) == "number" then
                lastTime = math.max(lastTime or 0, m.time)
            end
            local okD, data = pcall(function() return HttpService:JSONDecode(m.message) end)
            if okD then showIncoming(data, false) end
        end
    end
    if not lastTime then lastTime = os.time() end
end

local function startChat()
    if polling then return end
    polling = true
    task.spawn(function()
        while polling do
            pcall(pollChat)
            task.wait(POLL_EVERY)
        end
    end)
end

-- ========== Rechat window (resend your own recent messages) ==========
local rechatWin = makeWindow({
    title = "RECHAT  <font size='10' color='rgb(180,180,180)'>resend</font>",
    minTitle = "RECHAT",
    w = 190, h = 270, minW = 100,
    pos = UDim2.new(0, 180, 0, 50),
})
local rbody = rechatWin.body

local history = {}          -- your recent messages, newest first
local lastSend = 0
local SEND_COOLDOWN = 3     -- seconds between sends

local rStatus = Instance.new("TextLabel")
rStatus.Size = UDim2.new(1, -12, 0, 16)
rStatus.Position = UDim2.new(0, 6, 0, 32)
rStatus.BackgroundTransparency = 1
rStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
rStatus.Font = Enum.Font.Gotham
rStatus.TextSize = 11
rStatus.TextXAlignment = Enum.TextXAlignment.Left
rStatus.Text = "Your last messages appear here"
rStatus.Parent = rbody

local function resend(msg)
    if os.clock() - lastSend < SEND_COOLDOWN then
        rStatus.Text = "Wait a moment..."
        return
    end
    lastSend = os.clock()
    sendChat(msg)
    rStatus.Text = "Sent!"
end

local rList = Instance.new("ScrollingFrame")
rList.Size = UDim2.new(1, -12, 1, -108)
rList.Position = UDim2.new(0, 6, 0, 52)
rList.BackgroundTransparency = 1
rList.ScrollBarThickness = 4
rList.CanvasSize = UDim2.new(0, 0, 0, 0)
rList.AutomaticCanvasSize = Enum.AutomaticSize.Y
rList.Parent = rbody
local rLayout = Instance.new("UIListLayout", rList)
rLayout.Padding = UDim.new(0, 4)
rLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshHistory()
    for _, c in ipairs(rList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    for i, msg in ipairs(history) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 30)
        b.BackgroundColor3 = Color3.fromRGB(60, 50, 85)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.Gotham
        b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextTruncate = Enum.TextTruncate.AtEnd
        b.Text = "  " .. msg
        b.LayoutOrder = i
        b.Parent = rList
        corner(b, 6)
        b.MouseButton1Click:Connect(function() resend(msg) end)
    end
end

local function recordMessage(msg)
    if type(msg) ~= "string" or msg == "" or msg:sub(1, 1) == "/" then return end
    for i = #history, 1, -1 do
        if history[i] == msg then table.remove(history, i) end
    end
    table.insert(history, 1, msg)
    if #history > 10 then table.remove(history) end
    refreshHistory()
end

player.Chatted:Connect(recordMessage)
pcall(function()
    local TCS = game:GetService("TextChatService")
    TCS.MessageReceived:Connect(function(m)
        if m.TextSource and m.TextSource.UserId == player.UserId then
            recordMessage(m.Text)
        end
    end)
end)

local resendLast = makeButton(rbody, "Resend last", function()
    if history[1] then resend(history[1]) else rStatus.Text = "Nothing to resend yet" end
end)
resendLast.Size = UDim2.new(1, -12, 0, 26)
resendLast.Position = UDim2.new(0, 6, 1, -54)
resendLast.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local clearHist = makeButton(rbody, "Clear history", function()
    history = {}
    refreshHistory()
    rStatus.Text = "Cleared"
end)
clearHist.Size = UDim2.new(1, -12, 0, 26)
clearHist.Position = UDim2.new(0, 6, 1, -26)
clearHist.BackgroundColor3 = Color3.fromRGB(110, 45, 70)

-- ========== Hub (main window, always stays) ==========
local hub = makeWindow({
    title = "AIZEN  <font size='10' color='rgb(180,180,180)'>by Anshux</font>",
    minTitle = "AIZEN",
    w = 150, h = 182, minW = 80,
    pos = UDim2.new(0, 20, 0, 20),
})

local emoteOpen = makeButton(hub.body, "Emotes", function() emoteWin.toggle() end)
emoteOpen.Size = UDim2.new(1, -16, 0, 30)
emoteOpen.Position = UDim2.new(0, 8, 0, 4)
emoteOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local avatarOpen = makeButton(hub.body, "Avatar (Beta)", function()
    avatarWin.toggle()
    if avatarWin.frame.Visible then buildList() end
end)
avatarOpen.Size = UDim2.new(1, -16, 0, 30)
avatarOpen.Position = UDim2.new(0, 8, 0, 38)
avatarOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local rechatOpen = makeButton(hub.body, "Rechat", function() rechatWin.toggle() end)
rechatOpen.Size = UDim2.new(1, -16, 0, 30)
rechatOpen.Position = UDim2.new(0, 8, 0, 72)
rechatOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

chatOpenBtn = makeButton(hub.body, "Chat", function()
    chatWin.toggle()
    if chatWin.frame.Visible then
        unread = 0
        chatOpenBtn.Text = "Chat"
        startChat()
    end
end)
chatOpenBtn.Size = UDim2.new(1, -16, 0, 30)
chatOpenBtn.Position = UDim2.new(0, 8, 0, 106)
chatOpenBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

hub.toggle()
