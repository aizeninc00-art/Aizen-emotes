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
    lbl.Text = "AIZEN EMOTES"
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(170, 90, 255)
    lbl.TextStrokeTransparency = 0.3
    lbl.Parent = bb

    task.spawn(function()
        local t = 0
        while bb.Parent do
            t += RunService.Heartbeat:Wait()
            lbl.TextColor3 = Color3.fromHSV((t * 0.2) % 1, 0.7, 1)
        end
    end)
end

-- ========== RP name + bio (visible to everyone) ==========
local RP_NAME = "AIZEN EMOTES"
local RP_BIO = "by Anshux"
local RP_COLOR = Color3.fromRGB(170, 90, 255)

-- RGB name + bio: cycles the colors through the game's own RP color remote,
-- so everyone in the server sees the rainbow effect
local rainbowOn = false
local function startRainbow(re, textRemote)
    if rainbowOn then return end
    rainbowOn = true
    local colorRemote = re:FindFirstChild("1RPNam1eColo1r") or textRemote
    task.spawn(function()
        local hue = 0
        while rainbowOn do
            hue = (hue + 0.04) % 1
            local nameColor = Color3.fromHSV(hue, 1, 1)
            local bioColor = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
            pcall(function() colorRemote:FireServer("PickingRPNameColor", nameColor) end)
            pcall(function() colorRemote:FireServer("PickingRPBioColor", bioColor) end)
            task.wait(0.35)
        end
    end)
end

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

    startRainbow(re, remote)
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
            frame.Size = UDim2.new(0, targetW, 0, 0)
            frame.Visible = true
            TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back),
                {Size = UDim2.new(0, targetW, 0, targetH)}):Play()
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
    title = "AVATAR  <font size='10' color='rgb(180,180,180)'>copier</font>",
    minTitle = "AVATAR",
    w = 190, h = 300, minW = 100,
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
local currentSource       -- the character being copied (lets us copy their real in-game body parts)
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

    -- Body colors (always copied)
    pcall(function()
        local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
        bc.HeadColor3 = desc.HeadColor
        bc.TorsoColor3 = desc.TorsoColor
        bc.LeftArmColor3 = desc.LeftArmColor
        bc.RightArmColor3 = desc.RightArmColor
        bc.LeftLegColor3 = desc.LeftLegColor
        bc.RightLegColor3 = desc.RightLegColor
    end)

    -- Real in-game body parts, copied straight from their character
    if currentSource and currentSource.Parent then
        for _, part in ipairs(currentSource:GetChildren()) do
            if part:IsA("MeshPart") then
                local mine = char:FindFirstChild(part.Name)
                if mine and mine:IsA("MeshPart") then
                    pcall(function() mine.MeshId = part.MeshId end)
                    pcall(function() mine.TextureID = part.TextureID end)
                    local oldSA = mine:FindFirstChildWhichIsA("SurfaceAppearance")
                    if oldSA then oldSA:Destroy() end
                    local sa = part:FindFirstChildWhichIsA("SurfaceAppearance")
                    if sa then sa:Clone().Parent = mine end
                end
            end
        end
        -- R6-style head mesh
        pcall(function()
            local theirMesh = currentSource:FindFirstChild("Head") and currentSource.Head:FindFirstChildWhichIsA("SpecialMesh")
            local myMesh = char:FindFirstChild("Head") and char.Head:FindFirstChildWhichIsA("SpecialMesh")
            if theirMesh and myMesh then
                myMesh.MeshId = theirMesh.MeshId
                myMesh.TextureId = theirMesh.TextureId
                myMesh.Scale = theirMesh.Scale
            end
        end)
    end

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

    -- Body scale (R15, always copied)
    pcall(function()
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
    end)
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

local function applyDesc(desc, full)
    local hum = getHumanoid()
    local all = full or copyFace
    local ok, err = pcall(function()
        if all then
            hum:ApplyDescription(desc)
        else
            -- keep your own face, copy everything else from the outfit
            local mine = hum:GetAppliedDescription()
            mine.Shirt = desc.Shirt
            mine.Pants = desc.Pants
            mine.GraphicTShirt = desc.GraphicTShirt
            copyBodyFields(mine, desc)
            mine:SetAccessories(desc:GetAccessories(true), true)
            hum:ApplyDescription(mine)
        end
    end)
    if ok then return true, "full" end

    -- The game blocked ApplyDescription, so use the manual client-side method
    local ok2, err2 = pcall(manualApply, desc, full)
    if ok2 then return true, "local" end
    return false, tostring(err2 or err)
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
aList.Size = UDim2.new(1, -12, 1, -138)
aList.Position = UDim2.new(0, 6, 0, 76)
aList.BackgroundTransparency = 1
aList.ScrollBarThickness = 4
aList.CanvasSize = UDim2.new(0, 0, 0, 0)
aList.AutomaticCanvasSize = Enum.AutomaticSize.Y
aList.Parent = abody
local aLayout = Instance.new("UIListLayout", aList)
aLayout.Padding = UDim.new(0, 4)
aLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function refreshPlayers()
    for _, c in ipairs(aList:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    for i, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 40)
            b.BackgroundColor3 = Color3.fromRGB(60, 50, 85)
            b.Text = ""
            b.LayoutOrder = i
            b.Parent = aList
            corner(b, 6)

            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 34, 0, 34)
            img.Position = UDim2.new(0, 3, 0.5, -17)
            img.BackgroundColor3 = Color3.fromRGB(35, 30, 50)
            img.BorderSizePixel = 0
            img.Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(plr.UserId)
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
        end
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.5) refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.1) refreshPlayers() end)
refreshPlayers()

-- Scan: lists the game's avatar-related remotes so we can see what this game supports
local function scanRemotes()
    for _, c in ipairs(aList:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
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

local scanBtn = makeButton(abody, "Scan", scanRemotes)
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
    end
end)

aNameBox.FocusLost:Connect(function(enter)
    if enter then copyAvatar(aNameBox.Text) end
end)

-- ========== Hub (main window, always stays) ==========
local hub = makeWindow({
    title = "AIZEN  <font size='10' color='rgb(180,180,180)'>by Anshux</font>",
    minTitle = "AIZEN",
    w = 150, h = 110, minW = 80,
    pos = UDim2.new(0, 20, 0, 20),
})

local emoteOpen = makeButton(hub.body, "Emotes", function() emoteWin.toggle() end)
emoteOpen.Size = UDim2.new(1, -16, 0, 30)
emoteOpen.Position = UDim2.new(0, 8, 0, 4)
emoteOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local avatarOpen = makeButton(hub.body, "Avatar", function() avatarWin.toggle() end)
avatarOpen.Size = UDim2.new(1, -16, 0, 30)
avatarOpen.Position = UDim2.new(0, 8, 0, 38)
avatarOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

hub.toggle()
