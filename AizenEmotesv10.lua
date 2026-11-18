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

-- ========== Intro animation (anime-style opening) ==========
-- Letterbox bars, charging ring, radial speed lines, slashes, a glitchy chromatic title that
-- pops in letter by letter, drifting sparks, and a flash out. Tap the screen to skip.
local playIntro
do
    local ACCENT = Color3.fromRGB(170, 90, 255)
    local ACCENT_LIGHT = Color3.fromRGB(215, 170, 255)
    local WHITE = Color3.new(1, 1, 1)
    local LETTER_W, LETTER_H, LETTER_SIZE = 58, 84, 76

    -- Intro sound ("Yokoso Watashi no Soul Society"). Pick ONE of these:
    --  1) put your own clip in the executor's workspace folder named yokoso.mp3, or
    --  2) set INTRO_SOUND_ID to an audio id you uploaded / that is public, e.g. "rbxassetid://123456789"
    local INTRO_SOUND_FILE = "yokoso.mp3"
    local INTRO_SOUND_ID = ""
    local INTRO_SOUND_VOLUME = 1

    local function startIntroSound()
        local src
        pcall(function()
            if isfile and getcustomasset and isfile(INTRO_SOUND_FILE) then
                src = getcustomasset(INTRO_SOUND_FILE)
            end
        end)
        if not src and tostring(INTRO_SOUND_ID) ~= "" then
            local id = tostring(INTRO_SOUND_ID)
            src = id:find("rbxasset") and id or ("rbxassetid://" .. id)
        end
        if not src then return nil end
        local snd = Instance.new("Sound")
        snd.Name = "AizenIntroSound"
        snd.SoundId = src
        snd.Volume = INTRO_SOUND_VOLUME
        snd.Parent = game:GetService("SoundService")
        local ok = pcall(function() snd:Play() end)
        if not ok then snd:Destroy() return nil end
        snd.Ended:Once(function() snd:Destroy() end)
        game:GetService("Debris"):AddItem(snd, 60)
        return snd
    end

    playIntro = function()
        local skipped = false
        local introSound = startIntroSound()

        local root = Instance.new("Frame")
        root.Name = "AizenIntro"
        root.Size = UDim2.new(1, 0, 1, 0)
        root.BackgroundColor3 = Color3.new(0, 0, 0)
        root.BackgroundTransparency = 1
        root.ZIndex = 20
        root.ClipsDescendants = true
        root.Parent = gui

        local skipBtn = Instance.new("TextButton")
        skipBtn.Size = UDim2.new(1, 0, 1, 0)
        skipBtn.BackgroundTransparency = 1
        skipBtn.Text = ""
        skipBtn.ZIndex = 60
        skipBtn.Parent = root
        skipBtn.MouseButton1Click:Connect(function()
            skipped = true
            if introSound then introSound:Stop() end   -- tapping the screen skips the sound too
        end)

        -- waits, but returns early if the intro was skipped
        local function pause(t)
            local e = 0
            while e < t and not skipped do e += task.wait() end
        end
        local function tween(obj, time, props, style, dir)
            local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad,
                dir or Enum.EasingDirection.Out), props)
            t:Play()
            return t
        end
        local function make(class, props, parent)
            local o = Instance.new(class)
            for k, v in pairs(props) do o[k] = v end
            o.Parent = parent
            return o
        end

        -- Everything that fades/zooms out together lives in one CanvasGroup
        local stage = make("CanvasGroup", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 24,
        }, root)
        local stageScale = Instance.new("UIScale", stage)

        -- Letterbox bars
        local barTop = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0, ZIndex = 35,
        }, root)
        local barBottom = make("Frame", {
            Size = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0),
            BorderSizePixel = 0, ZIndex = 35,
        }, root)
        for _, bar in ipairs({barTop, barBottom}) do
            local edge = make("Frame", {
                Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = ACCENT, BorderSizePixel = 0,
                AnchorPoint = Vector2.new(0, bar == barTop and 1 or 0),
                Position = UDim2.new(0, 0, bar == barTop and 1 or 0, 0), ZIndex = 36,
            }, bar)
        end

        -- White flash overlay
        local flash = make("Frame", {
            Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = WHITE,
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 50,
        }, root)
        local function doFlash(strength, time)
            flash.BackgroundTransparency = 1 - strength
            tween(flash, time, {BackgroundTransparency = 1})
        end

        -- Radial speed lines bursting from the center
        local function burst(count, color, minLen, maxLen, dur)
            for i = 1, count do
                local ang = math.rad((i / count) * 360 + math.random(-5, 5))
                local r0 = math.random(30, 110)
                local line = make("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0.5, math.cos(ang) * r0, 0.5, math.sin(ang) * r0),
                    Size = UDim2.new(0, 0, 0, math.random(2, 4)),
                    Rotation = math.deg(ang),
                    BackgroundColor3 = (i % 4 == 0) and WHITE or color,
                    BorderSizePixel = 0, ZIndex = 22,
                }, root)
                local len = math.random(minLen, maxLen)
                tween(line, dur, {Size = UDim2.new(0, len, 0, 1), BackgroundTransparency = 1})
                task.delay(dur + 0.1, function() line:Destroy() end)
            end
        end

        -- Expanding / collapsing ring
        local function ring(fromSize, toSize, dur, style, dir)
            local r = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, fromSize, 0, fromSize), BackgroundTransparency = 1,
                ZIndex = 23,
            }, root)
            make("UICorner", {CornerRadius = UDim.new(0.5, 0)}, r)
            local st = make("UIStroke", {Color = ACCENT_LIGHT, Thickness = 4, Transparency = 0.2}, r)
            tween(r, dur, {Size = UDim2.new(0, toSize, 0, toSize)}, style, dir)
            tween(st, dur, {Transparency = 1, Thickness = 1}, style, dir)
            task.delay(dur + 0.1, function() r:Destroy() end)
        end

        -- A quick diagonal slash across the screen
        local function slash(angle, color)
            local sl = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(0, 0, 0, 5), Rotation = angle, BackgroundColor3 = color,
                BorderSizePixel = 0, ZIndex = 26,
            }, root)
            tween(sl, 0.16, {Size = UDim2.new(0, 1600, 0, 5)}, Enum.EasingStyle.Quint)
            task.delay(0.12, function()
                tween(sl, 0.3, {BackgroundTransparency = 1, Size = UDim2.new(0, 1600, 0, 1)})
            end)
            task.delay(0.5, function() sl:Destroy() end)
        end

        -- Letter-by-letter title builder
        local TITLE_Y = 0.44
        local function makeTitle(text, color, z)
            local holder = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, TITLE_Y, 0),
                Size = UDim2.new(0, #text * LETTER_W, 0, LETTER_H), BackgroundTransparency = 1,
                ZIndex = z,
            }, stage)
            local letters = {}
            for i = 1, #text do
                letters[i] = make("TextLabel", {
                    Size = UDim2.new(0, LETTER_W, 0, LETTER_H),
                    Position = UDim2.new(0, (i - 1) * LETTER_W, 0, 0),
                    BackgroundTransparency = 1, Text = text:sub(i, i),
                    Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = color,
                    TextTransparency = 1, Rotation = math.random(-25, 25), ZIndex = z,
                }, holder)
            end
            return holder, letters
        end
        local function popLetters(letters, finalTransparency)
            for i, l in ipairs(letters) do
                task.delay(0.07 * (i - 1), function()
                    tween(l, 0.45, {TextSize = LETTER_SIZE, TextTransparency = finalTransparency,
                        Rotation = 0}, Enum.EasingStyle.Back)
                end)
            end
        end

        local titleText = "AIZEN"
        local redHolder, redLetters = makeTitle(titleText, Color3.fromRGB(255, 60, 100), 25)
        local cyanHolder, cyanLetters = makeTitle(titleText, Color3.fromRGB(60, 230, 255), 25)
        local mainHolder, mainLetters = makeTitle(titleText, WHITE, 26)
        for _, l in ipairs(mainLetters) do
            l.TextStrokeColor3 = ACCENT
            l.TextStrokeTransparency = 0.45
        end

        local underline = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, TITLE_Y, LETTER_H / 2 + 6),
            Size = UDim2.new(0, 0, 0, 3), BackgroundColor3 = ACCENT, BorderSizePixel = 0, ZIndex = 26,
        }, stage)
        local subtitle = make("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 50, TITLE_Y, LETTER_H / 2 + 14),
            Size = UDim2.new(0, 320, 0, 26), BackgroundTransparency = 1, Text = "P  A  N  E  L",
            Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = ACCENT_LIGHT,
            TextTransparency = 1, ZIndex = 26,
        }, stage)
        local tagline = make("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, TITLE_Y, LETTER_H / 2 + 46),
            Size = UDim2.new(0, 300, 0, 20), BackgroundTransparency = 1, Text = "by  ANSHUx",
            Font = Enum.Font.GothamMedium, TextSize = 15, TextColor3 = WHITE,
            TextTransparency = 1, ZIndex = 26,
        }, stage)

        -- Drifting sparks
        local function sparks()
            for i = 1, 26 do
                if skipped then return end
                local x = math.random()
                local sz = math.random(3, 6)
                local sp = make("Frame", {
                    Size = UDim2.new(0, sz, 0, sz), Position = UDim2.new(x, 0, 1.05, 0),
                    BackgroundColor3 = (i % 3 == 0) and WHITE or ACCENT_LIGHT, BorderSizePixel = 0,
                    Rotation = math.random(0, 90), ZIndex = 23,
                }, root)
                local dur = math.random(16, 26) / 10
                tween(sp, dur, {
                    Position = UDim2.new(math.clamp(x + (math.random() - 0.5) * 0.2, 0, 1), 0,
                        math.random(10, 55) / 100, 0),
                    BackgroundTransparency = 1, Rotation = sp.Rotation + 180,
                }, Enum.EasingStyle.Sine)
                task.delay(dur + 0.1, function() sp:Destroy() end)
                task.wait(0.1)
            end
        end

        -- ===== Timeline =====
        tween(root, 0.35, {BackgroundTransparency = 0.12})
        tween(barTop, 0.5, {Size = UDim2.new(1, 0, 0.12, 0)}, Enum.EasingStyle.Quart)
        tween(barBottom, 0.5, {Size = UDim2.new(1, 0, 0.12, 0)}, Enum.EasingStyle.Quart)
        pause(0.45)

        -- charge up: ring collapses into the center
        if not skipped then ring(900, 0, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In) end
        pause(0.5)

        -- impact: flash, shockwave, speed lines, slashes, title pops in
        if not skipped then
            doFlash(0.85, 0.4)
            ring(0, 800, 0.6, Enum.EasingStyle.Quint)
            burst(26, ACCENT, 420, 900, 0.55)
            slash(-24, WHITE)
            task.delay(0.08, function() slash(18, ACCENT_LIGHT) end)
            task.spawn(sparks)
            popLetters(redLetters, 0.45)
            popLetters(cyanLetters, 0.45)
            popLetters(mainLetters, 0)
        end

        -- glitch: the red/cyan copies jitter, then settle
        if not skipped then
            local start = os.clock()
            while os.clock() - start < 0.8 and not skipped do
                local k = math.max(0, 1 - (os.clock() - start) / 0.8) * 10
                local function jitter() return (math.random(-100, 100) / 100) * k end
                redHolder.Position = UDim2.new(0.5, -3 - jitter(), TITLE_Y, jitter() / 3)
                cyanHolder.Position = UDim2.new(0.5, 3 + jitter(), TITLE_Y, -jitter() / 3)
                mainHolder.Position = UDim2.new(0.5, jitter() / 4, TITLE_Y, 0)
                task.wait(0.035)
            end
            redHolder.Position = UDim2.new(0.5, -2, TITLE_Y, 0)
            cyanHolder.Position = UDim2.new(0.5, 2, TITLE_Y, 0)
            mainHolder.Position = UDim2.new(0.5, 0, TITLE_Y, 0)
        end

        -- underline sweeps out, subtitle slides in
        if not skipped then
            tween(underline, 0.5, {Size = UDim2.new(0, #titleText * LETTER_W, 0, 3)}, Enum.EasingStyle.Quint)
            tween(subtitle, 0.5, {Position = UDim2.new(0.5, 0, TITLE_Y, LETTER_H / 2 + 14),
                TextTransparency = 0}, Enum.EasingStyle.Quint)
        end
        pause(0.5)
        if not skipped then
            tween(tagline, 0.5, {TextTransparency = 0})
            for _, l in ipairs(redLetters) do tween(l, 0.5, {TextTransparency = 0.8}) end
            for _, l in ipairs(cyanLetters) do tween(l, 0.5, {TextTransparency = 0.8}) end
        end
        pause(1.5)

        -- outro: flash, then the whole title zooms and fades away
        if not skipped then
            doFlash(0.7, 0.35)
            burst(18, ACCENT_LIGHT, 300, 700, 0.4)
        end
        tween(stage, 0.55, {GroupTransparency = 1})
        tween(stageScale, 0.55, {Scale = 1.3}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(barTop, 0.5, {Size = UDim2.new(1, 0, 0, 0)})
        tween(barBottom, 0.5, {Size = UDim2.new(1, 0, 0, 0)})
        tween(root, 0.6, {BackgroundTransparency = 1})
        task.wait(0.7)
        root:Destroy()
    end
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
local allWindows = {}   -- every window frame (the Settings window changes their opacity)
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
    table.insert(allWindows, frame)
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

    -- change the full height later (used by the hub when the owner button appears)
    function win.setHeight(h)
        cfg.h = h
        if frame.Visible and not win.minimized then
            TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(0, cfg.w, 0, h)}):Play()
        end
    end

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
-- Saved (favorite) emotes, stored on this device
local FAV_FILE = "AizenSavedEmotes.json"
local favList, favIndex = {}, {}
local savedView = false
do
    local ok, raw = pcall(function()
        if isfile and isfile(FAV_FILE) then return readfile(FAV_FILE) end
    end)
    if ok and raw then
        local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if ok2 and type(data) == "table" then
            for _, e in ipairs(data) do
                if type(e) == "table" and tonumber(e.id) then
                    e.id = tonumber(e.id)
                    table.insert(favList, e)
                    favIndex[e.id] = e
                end
            end
        end
    end
end
local function saveFavs()
    pcall(function() writefile(FAV_FILE, HttpService:JSONEncode(favList)) end)
end
local function toggleFav(name, id, direct)
    if favIndex[id] then
        for i, e in ipairs(favList) do
            if e.id == id then table.remove(favList, i) break end
        end
        favIndex[id] = nil
    else
        local e = {name = name, id = id, direct = direct and true or false}
        table.insert(favList, e)
        favIndex[id] = e
    end
    saveFavs()
end

-- Emote button with a preview thumbnail (direct = play the id as an animation id)
local function makeEmoteButton(parent, name, assetId, cb, direct)
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
    lbl.Size = UDim2.new(1, -76, 1, -4)
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

    local star = Instance.new("TextButton")
    star.Size = UDim2.new(0, 24, 0, 24)
    star.Position = UDim2.new(1, -28, 0.5, -12)
    star.BackgroundTransparency = 1
    star.Font = Enum.Font.GothamBold
    star.TextSize = 18
    star.Parent = b
    local function paintStar()
        local on = favIndex[assetId] ~= nil
        star.Text = on and "★" or "☆"
        star.TextColor3 = on and Color3.fromRGB(255, 200, 61) or Color3.fromRGB(160, 150, 185)
    end
    paintStar()
    star.MouseButton1Click:Connect(function()
        toggleFav(name, assetId, direct)
        paintStar()
        if savedView and not favIndex[assetId] then b:Destroy() end
    end)
    return b
end

-- Search
local search = Instance.new("TextBox")
search.Size = UDim2.new(1, -52, 0, 24)
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
                local b = makeEmoteButton(list, e[1], e[2], function() playId(e[2]) end, true)
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
-- "★" button: show only your saved emotes
local savedBtn
local function paintSaved()
    savedBtn.BackgroundColor3 = savedView and Color3.fromRGB(150, 110, 30) or Color3.fromRGB(60, 50, 85)
end
savedBtn = makeButton(body, "★", function() end)
savedBtn.Size = UDim2.new(0, 34, 0, 24)
savedBtn.Position = UDim2.new(1, -40, 0, 0)
savedBtn.TextSize = 16
savedBtn.TextColor3 = Color3.fromRGB(255, 200, 61)

local function showSaved()
    clearList()
    loadMore.Visible = false
    local n = 0
    for _, e in ipairs(favList) do
        n += 1
        local b = makeEmoteButton(list, e.name, e.id, function()
            if e.direct then playId(e.id) else playEmote(e.id) end
        end, e.direct)
        b.LayoutOrder = n
    end
    status.Text = n == 0 and "No saved emotes yet - tap ☆ on one" or ""
end

savedBtn.MouseButton1Click:Connect(function()
    savedView = not savedView
    paintSaved()
    if savedView then showSaved() else fetchEmotes(true) end
end)
search.FocusLost:Connect(function()
    savedView = false
    paintSaved()
    fetchEmotes(true)
end)
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
    w = 230, h = 350, minW = 90,
    pos = UDim2.new(0, 180, 0, 50),
})
local cbody = chatWin.body

-- Status row: colored dot + text + character counter
local cDot = Instance.new("Frame")
cDot.Size = UDim2.new(0, 8, 0, 8)
cDot.Position = UDim2.new(0, 8, 0, 6)
cDot.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
cDot.Parent = cbody
corner(cDot, 4)

local cStatus = Instance.new("TextLabel")
cStatus.Size = UDim2.new(1, -112, 0, 16)
cStatus.Position = UDim2.new(0, 20, 0, 2)
cStatus.BackgroundTransparency = 1
cStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
cStatus.Font = Enum.Font.Gotham
cStatus.TextSize = 10
cStatus.TextXAlignment = Enum.TextXAlignment.Left
cStatus.Text = "Opening chat..."
cStatus.Parent = cbody

local cCount = Instance.new("TextLabel")
cCount.Size = UDim2.new(0, 60, 0, 16)
cCount.Position = UDim2.new(1, -66, 0, 2)
cCount.BackgroundTransparency = 1
cCount.TextColor3 = Color3.fromRGB(130, 125, 150)
cCount.Font = Enum.Font.Gotham
cCount.TextSize = 10
cCount.TextXAlignment = Enum.TextXAlignment.Right
cCount.Text = "0/" .. MAX_LEN
cCount.Parent = cbody

-- the dot changes color with the status text
cStatus:GetPropertyChangedSignal("Text"):Connect(function()
    local t = cStatus.Text:lower()
    if t == "online" then
        cDot.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
    elseif t:find("offline") or t:find("failed") or t:find("executor") then
        cDot.BackgroundColor3 = Color3.fromRGB(235, 80, 80)
    else
        cDot.BackgroundColor3 = Color3.fromRGB(240, 190, 60)
    end
end)

-- Message area
local cLog = Instance.new("ScrollingFrame")
cLog.Size = UDim2.new(1, -12, 1, -84)
cLog.Position = UDim2.new(0, 6, 0, 44)
cLog.BackgroundColor3 = Color3.fromRGB(16, 13, 26)
cLog.BorderSizePixel = 0
cLog.ScrollBarThickness = 3
cLog.CanvasSize = UDim2.new(0, 0, 0, 0)
cLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
cLog.Parent = cbody
corner(cLog, 8)
local cLogLayout = Instance.new("UIListLayout", cLog)
cLogLayout.Padding = UDim.new(0, 6)
cLogLayout.SortOrder = Enum.SortOrder.LayoutOrder
local cLogPad = Instance.new("UIPadding", cLog)
cLogPad.PaddingLeft = UDim.new(0, 6)
cLogPad.PaddingRight = UDim.new(0, 8)
cLogPad.PaddingTop = UDim.new(0, 6)
cLogPad.PaddingBottom = UDim.new(0, 6)

local cEmpty = Instance.new("TextLabel")
cEmpty.Size = UDim2.new(1, -24, 0, 40)
cEmpty.Position = UDim2.new(0, 12, 0.4, 20)
cEmpty.BackgroundTransparency = 1
cEmpty.TextColor3 = Color3.fromRGB(130, 125, 150)
cEmpty.Font = Enum.Font.Gotham
cEmpty.TextSize = 12
cEmpty.TextWrapped = true
cEmpty.Text = "No messages yet.\nSay hi to other script users!"
cEmpty.Parent = cbody

-- Input
local cBox = Instance.new("TextBox")
cBox.Size = UDim2.new(1, -60, 0, 30)
cBox.Position = UDim2.new(0, 6, 1, -34)
cBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
cBox.TextColor3 = Color3.new(1, 1, 1)
cBox.PlaceholderText = "Message... (/clear to wipe)"
cBox.PlaceholderColor3 = Color3.fromRGB(130, 125, 150)
cBox.Text = ""
cBox.Font = Enum.Font.Gotham
cBox.TextSize = 12
cBox.ClearTextOnFocus = false
cBox.TextXAlignment = Enum.TextXAlignment.Left
cBox.Parent = cbody
corner(cBox, 8)
local cBoxPad = Instance.new("UIPadding", cBox)
cBoxPad.PaddingLeft = UDim.new(0, 8)
cBoxPad.PaddingRight = UDim.new(0, 8)

cBox:GetPropertyChangedSignal("Text"):Connect(function()
    if #cBox.Text > MAX_LEN then cBox.Text = cBox.Text:sub(1, MAX_LEN) end
    cCount.Text = #cBox.Text .. "/" .. MAX_LEN
end)

local function escapeRich(t)
    return (t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local dm = {}   -- private-message state + functions (filled in further down)
local chatTab = "public"
local applyChatTab
local logCount = 0
local unread = 0
local MAX_BUBBLE = 176

-- Adds a message bubble. mine = your own message (right side), owner = gold [OWNER] tag,
-- ts = unix time in seconds, kind = "announce" for owner announcements
local function addChatLine(name, text, mine, owner, ts, kind, senderId)
    logCount += 1
    local isAnn = kind == "announce"
    local isDM = kind == "dm"

    local row = Instance.new("Frame")
    row.Name = "Row"
    row.Size = UDim2.new(1, 0, 0, 0)
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.BackgroundTransparency = 1
    row.LayoutOrder = logCount
    row:SetAttribute("Kind", (kind == "dm") and "dm" or "pub")
    row.Visible = (chatTab == "private") == (kind == "dm")
    if row.Visible then cEmpty.Visible = false end
    row.Parent = cLog

    local bubble = Instance.new("Frame")
    bubble.AutomaticSize = Enum.AutomaticSize.XY
    bubble.Size = UDim2.new(0, 0, 0, 0)
    if isAnn then
        bubble.AnchorPoint = Vector2.new(0.5, 0)
        bubble.Position = UDim2.new(0.5, 0, 0, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(62, 48, 18)
    elseif mine then
        bubble.AnchorPoint = Vector2.new(1, 0)
        bubble.Position = UDim2.new(1, 0, 0, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(80, 62, 155)
    else
        bubble.AnchorPoint = Vector2.new(0, 0)
        bubble.Position = UDim2.new(0, 0, 0, 0)
        bubble.BackgroundColor3 = Color3.fromRGB(44, 39, 62)
    end
    if isDM then
        bubble.BackgroundColor3 = mine and Color3.fromRGB(105, 45, 110) or Color3.fromRGB(80, 38, 90)
    end
    bubble.Parent = row
    corner(bubble, 10)

    local pad = Instance.new("UIPadding", bubble)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.PaddingTop = UDim.new(0, 5)
    pad.PaddingBottom = UDim.new(0, 5)
    local lay = Instance.new("UIListLayout", bubble)
    lay.Padding = UDim.new(0, 2)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    local limit = Instance.new("UISizeConstraint", bubble)
    limit.MaxSize = Vector2.new(isAnn and (MAX_BUBBLE + 20) or MAX_BUBBLE, math.huge)

    if owner or isAnn or isDM then
        local st = Instance.new("UIStroke", bubble)
        st:SetAttribute("NoTheme", true)
        st.Color = isDM and Color3.fromRGB(255, 143, 208) or Color3.fromRGB(255, 200, 61)
        st.Thickness = 1
    end

    local timeText = os.date("%H:%M", math.floor(ts or os.time()))
    local nameColor = mine and "#c9f5d9" or "#b98aff"
    local tag = owner and "<font color='#ffc83d'><b>OWNER</b></font>  " or ""
    if isDM then tag = tag .. "<font color='#ff8fd0'><b>PRIVATE</b></font>  " end
    local shownName = mine and "You" or name
    if isDM and mine then shownName = "You > " .. name end

    -- other people's names can be tapped to start a private chat with them
    local canTap = (not mine) and senderId ~= nil and not isAnn
    local nameText = escapeRich(shownName)
    if canTap then nameText = "<u>" .. nameText .. "</u>" end

    local head = Instance.new(canTap and "TextButton" or "TextLabel")
    head.AutomaticSize = Enum.AutomaticSize.XY
    head.Size = UDim2.new(0, 0, 0, 0)
    head.BackgroundTransparency = 1
    head.RichText = true
    head.Font = Enum.Font.Gotham
    head.TextSize = 10
    head.TextColor3 = Color3.new(1, 1, 1)
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.LayoutOrder = 1
    head.Text = ("%s<font color='%s'><b>%s</b></font>  <font color='#8d88a8'>%s</font>"):format(
        tag, nameColor, nameText, timeText)
    if canTap then
        head.AutoButtonColor = false
        head.MouseButton1Click:Connect(function() dm.select(senderId, name) end)
    end
    head.Parent = bubble

    local msg = Instance.new("TextLabel")
    msg.AutomaticSize = Enum.AutomaticSize.XY
    msg.Size = UDim2.new(0, 0, 0, 0)
    msg.BackgroundTransparency = 1
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 12
    msg.TextColor3 = Color3.new(1, 1, 1)
    msg.TextWrapped = true
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.LayoutOrder = 2
    msg.Text = text
    msg.Parent = bubble
    local msgLimit = Instance.new("UISizeConstraint", msg)
    msgLimit.MaxSize = Vector2.new((isAnn and (MAX_BUBBLE + 20) or MAX_BUBBLE) - 16, math.huge)

    -- keep the log from growing forever
    local rows = {}
    for _, c in ipairs(cLog:GetChildren()) do
        if c.Name == "Row" then table.insert(rows, c) end
    end
    if #rows > MAX_LOG then
        table.sort(rows, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        rows[1]:Destroy()
    end

    -- scroll to the newest message
    task.defer(function() cLog.CanvasPosition = Vector2.new(0, 1e6) end)
    task.delay(0.1, function() cLog.CanvasPosition = Vector2.new(0, 1e6) end)
end

local mySent = {}     -- nonces of messages we sent (so the poll doesn't show them twice)
local seenIds = {}    -- relay message ids already shown
local lastSent = 0
local polling = false
local lastTime = nil

-- Wipes the messages from YOUR chat window (does not delete them for anyone else)
local function clearChatLog()
    for _, c in ipairs(cLog:GetChildren()) do
        if c.Name == "Row" then c:Destroy() end
    end
    cEmpty.Text = "Chat cleared."
    cEmpty.Visible = true
end

local function chatSend(text)
    text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then return end

    -- Commands
    if text:lower() == "/clear" then
        clearChatLog()
        return
    end

    -- Private tab: the message goes only to the person you picked
    if chatTab == "private" then
        if not dm.target then
            cStatus.Text = "Enter a username above first"
            return
        end
        if os.clock() - lastSent < SEND_EVERY then
            cStatus.Text = "Slow down a little..."
            return
        end
        lastSent = os.clock()
        dm.send(text:sub(1, MAX_LEN))
        return
    end
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
    addChatLine(player.DisplayName, text, true, FIREBASE_URL ~= "" and OWNER_EMAIL ~= "", os.time())

    task.spawn(function()
        local payload = HttpService:JSONEncode({
            n = nonce,
            u = player.Name,
            d = player.DisplayName,
            i = player.UserId,
            t = text,
        })
        local req
        if FIREBASE_URL ~= "" then
            local token = getOwnerToken()
            local body = HttpService:JSONEncode({
                n = nonce,
                u = player.Name,
                d = player.DisplayName,
                i = player.UserId,
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
sendBtn.Size = UDim2.new(0, 48, 0, 30)
sendBtn.Position = UDim2.new(1, -54, 1, -34)
sendBtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

cBox.FocusLost:Connect(function(enter)
    if enter then
        local t = cBox.Text
        cBox.Text = ""
        chatSend(t)
    end
end)

local chatOpenBtn -- set when the hub button is created

-- ===== Private messages =====
-- Tap another script user's name to message only them. Messages are stored under that user's
-- id in Firebase, and Firebase's rules only let the person who claimed that id read them.
-- (Needs "Anonymous" sign-in enabled in Firebase Authentication.)
do
    local anon = {token = nil, refresh = nil, uid = nil, exp = 0}
    local claimedUid = nil
    local seen = {}
    local lastDM = nil

    local function decode(body)
        local ok, d = pcall(function() return HttpService:JSONDecode(body) end)
        if ok then return d end
    end
    local function okStatus(res)
        return res and (res.StatusCode == 200 or res.Success)
    end

    -- Anonymous Firebase login (gives this session a private id)
    function dm.getAuth()
        if FIREBASE_URL == "" or FIREBASE_API_KEY == "" or not httpRequest then return nil end
        if anon.token and os.time() < anon.exp then return anon.token, anon.uid end

        if anon.refresh then
            local ok, res = pcall(httpRequest, {
                Url = "https://securetoken.googleapis.com/v1/token?key=" .. FIREBASE_API_KEY,
                Method = "POST",
                Headers = {["Content-Type"] = "application/x-www-form-urlencoded"},
                Body = "grant_type=refresh_token&refresh_token=" .. anon.refresh,
            })
            local d = ok and res and res.Body and decode(res.Body)
            if type(d) == "table" and d.id_token then
                anon.token = d.id_token
                anon.refresh = d.refresh_token or anon.refresh
                anon.uid = d.user_id or anon.uid
                anon.exp = os.time() + (tonumber(d.expires_in) or 3600) - 120
                return anon.token, anon.uid
            end
            anon.refresh = nil
        end

        local ok, res = pcall(httpRequest, {
            Url = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" .. FIREBASE_API_KEY,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({returnSecureToken = true}),
        })
        local d = ok and res and res.Body and decode(res.Body)
        if type(d) == "table" and d.idToken then
            anon.token = d.idToken
            anon.refresh = d.refreshToken
            anon.uid = d.localId
            anon.exp = os.time() + (tonumber(d.expiresIn) or 3600) - 120
            return anon.token, anon.uid
        end
        return nil
    end

    -- Registers "this session owns my Roblox id" so Firebase lets it read messages sent to me
    function dm.claim()
        local token, uid = dm.getAuth()
        if not token then return false end
        if claimedUid == uid then return true end
        local ok, res = pcall(httpRequest, {
            Url = FIREBASE_URL .. "/users/" .. player.UserId .. ".json?auth=" .. token,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({uid = uid, name = player.Name}),
        })
        if ok and okStatus(res) then
            claimedUid = uid
            return true
        end
        return false
    end

    function dm.send(text)
        local target = dm.target
        if not target then return end
        addChatLine(target.name, text, true, false, os.time(), "dm")
        task.spawn(function()
            if not dm.claim() then
                cStatus.Text = "Private chat unavailable"
                return
            end
            local token = dm.getAuth()
            local ok, res = pcall(httpRequest, {
                Url = FIREBASE_URL .. "/dm/" .. target.id .. ".json?auth=" .. token,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    t = text,
                    f = tostring(player.UserId),
                    fn = player.DisplayName:sub(1, 30),
                    n = HttpService:GenerateGUID(false),
                    time = {[".sv"] = "timestamp"},
                }),
            })
            cStatus.Text = (ok and okStatus(res)) and "Online" or "Send failed"
        end)
    end

    function dm.poll()
        if not dm.claim() then return end
        local token = dm.getAuth()
        local range = lastDM and ("startAt=" .. tostring(lastDM + 1)) or "limitToLast=20"
        local ok, res = pcall(httpRequest, {
            Url = FIREBASE_URL .. "/dm/" .. player.UserId .. ".json?auth=" .. token
                .. "&orderBy=%22time%22&" .. range,
            Method = "GET",
        })
        if not ok or not res or not res.Body then return end
        local data = decode(res.Body)
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
            if not seen[m._id] and type(m.t) == "string" then
                seen[m._id] = true
                if type(m.time) == "number" then lastDM = math.max(lastDM or 0, m.time) end
                addChatLine(tostring(m.fn or "?"):sub(1, 20), m.t:sub(1, MAX_LEN), false, false,
                    type(m.time) == "number" and m.time / 1000 or nil, "dm", tonumber(m.f))
                if not chatWin.frame.Visible or chatWin.minimized then
                    unread += 1
                    if chatOpenBtn then chatOpenBtn.Text = "Chat (" .. unread .. ")" end
                end
                if dm.onIncoming then dm.onIncoming() end
            end
        end
    end

    -- "Private to NAME  x" bar above the input box
    local chip = Instance.new("Frame")
    chip.Size = UDim2.new(1, -12, 0, 22)
    chip.Position = UDim2.new(0, 6, 1, -58)
    chip.BackgroundColor3 = Color3.fromRGB(70, 35, 75)
    chip.Visible = false
    chip.Parent = cbody
    corner(chip, 6)
    local chipLabel = Instance.new("TextLabel")
    chipLabel.Size = UDim2.new(1, -30, 1, 0)
    chipLabel.Position = UDim2.new(0, 8, 0, 0)
    chipLabel.BackgroundTransparency = 1
    chipLabel.TextColor3 = Color3.fromRGB(255, 190, 230)
    chipLabel.Font = Enum.Font.GothamMedium
    chipLabel.TextSize = 11
    chipLabel.TextXAlignment = Enum.TextXAlignment.Left
    chipLabel.TextTruncate = Enum.TextTruncate.AtEnd
    chipLabel.Parent = chip
    local chipClose = Instance.new("TextButton")
    chipClose.Size = UDim2.new(0, 22, 1, 0)
    chipClose.Position = UDim2.new(1, -22, 0, 0)
    chipClose.BackgroundTransparency = 1
    chipClose.Text = "X"
    chipClose.TextColor3 = Color3.fromRGB(255, 190, 230)
    chipClose.Font = Enum.Font.GothamBold
    chipClose.TextSize = 12
    chipClose.Parent = chip

    -- Username box (shown in the Private tab when nobody is picked yet)
    local userBox = Instance.new("TextBox")
    userBox.Size = UDim2.new(1, -12, 0, 22)
    userBox.Position = UDim2.new(0, 6, 1, -58)
    userBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    userBox.TextColor3 = Color3.new(1, 1, 1)
    userBox.PlaceholderText = "Roblox username + Enter"
    userBox.PlaceholderColor3 = Color3.fromRGB(130, 125, 150)
    userBox.Text = ""
    userBox.Font = Enum.Font.Gotham
    userBox.TextSize = 11
    userBox.ClearTextOnFocus = false
    userBox.Visible = false
    userBox.Parent = cbody
    corner(userBox, 6)

    -- Public / Private tabs
    local tabPub = makeButton(cbody, "Public", function() applyChatTab("public") end)
    tabPub.Size = UDim2.new(0.5, -9, 0, 20)
    tabPub.Position = UDim2.new(0, 6, 0, 20)
    tabPub.TextSize = 11
    local tabPriv = makeButton(cbody, "Private", function() applyChatTab("private") end)
    tabPriv.Size = UDim2.new(0.5, -9, 0, 20)
    tabPriv.Position = UDim2.new(0.5, 3, 0, 20)
    tabPriv.TextSize = 11

    dm.unread = 0
    function dm.onIncoming()
        if chatTab ~= "private" then
            dm.unread += 1
            tabPriv.Text = "Private (" .. dm.unread .. ")"
        end
    end

    local function layoutChat()
        local priv = chatTab == "private"
        chip.Visible = priv and dm.target ~= nil
        userBox.Visible = priv and dm.target == nil
        cLog.Size = priv and UDim2.new(1, -12, 1, -110) or UDim2.new(1, -12, 1, -84)
        if not priv then
            cBox.PlaceholderText = "Message... (/clear to wipe)"
        elseif dm.target then
            cBox.PlaceholderText = "Private message to " .. dm.target.name .. "..."
        else
            cBox.PlaceholderText = "Pick a user above first..."
        end
    end

    function applyChatTab(tab)
        chatTab = tab
        local priv = tab == "private"
        tabPub.BackgroundColor3 = priv and Color3.fromRGB(60, 50, 85) or Color3.fromRGB(90, 60, 140)
        tabPriv.BackgroundColor3 = priv and Color3.fromRGB(105, 45, 110) or Color3.fromRGB(60, 50, 85)
        if priv then
            dm.unread = 0
            tabPriv.Text = "Private"
        end
        local any = false
        for _, r in ipairs(cLog:GetChildren()) do
            if r.Name == "Row" then
                r.Visible = priv == (r:GetAttribute("Kind") == "dm")
                if r.Visible then any = true end
            end
        end
        cEmpty.Text = priv and "No private messages yet.\nType a username below,\nor tap a name in Public chat."
            or "No messages yet.\nSay hi to other script users!"
        cEmpty.Visible = not any
        layoutChat()
        task.defer(function() cLog.CanvasPosition = Vector2.new(0, 1e6) end)
    end
    applyChatTab("public")

    userBox.FocusLost:Connect(function(enter)
        if not enter then return end
        local name = (userBox.Text:gsub("%s", ""))
        if name == "" then return end
        userBox.Text = ""
        task.spawn(function()
            local ok, id = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
            if ok and id then
                local ok2, realName = pcall(function() return Players:GetNameFromUserIdAsync(id) end)
                dm.select(id, ok2 and realName or name)
            else
                cStatus.Text = "User not found"
            end
        end)
    end)

    function dm.setTarget(id, name)
        if id then
            dm.target = {id = tostring(id), name = name}
            chipLabel.Text = "Private to " .. name .. "  (only they can read it)"
        else
            dm.target = nil
        end
        layoutChat()
    end
    chipClose.MouseButton1Click:Connect(function() dm.setTarget(nil) end)

    function dm.select(id, name)
        if FIREBASE_URL == "" then
            cStatus.Text = "Private chat needs Firebase"
            return
        end
        if tostring(id) == tostring(player.UserId) then
            cStatus.Text = "You can't message yourself"
            return
        end
        applyChatTab("private")
        dm.setTarget(id, name)
        cBox:CaptureFocus()
    end
end

-- ===== Announcements (sent by the owner, shown to every script user) =====
local bannerFrame
local function showAnnouncement(text)
    text = tostring(text):sub(1, 200)
    addChatLine("ANNOUNCEMENT", text, false, true, os.time(), "announce")

    if bannerFrame then bannerFrame:Destroy() end
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 320, 0, 64)
    f.AnchorPoint = Vector2.new(0.5, 0)
    f.Position = UDim2.new(0.5, 0, 0, -80)
    f.BackgroundColor3 = Color3.fromRGB(25, 22, 35)
    f.Parent = gui
    corner(f, 10)
    local st = Instance.new("UIStroke", f)
    st.Color = Color3.fromRGB(255, 200, 61)
    st.Thickness = 1.5

    local head = Instance.new("TextLabel")
    head.Size = UDim2.new(1, -16, 0, 16)
    head.Position = UDim2.new(0, 8, 0, 4)
    head.BackgroundTransparency = 1
    head.Text = "📢  AIZEN ANNOUNCEMENT"
    head.TextColor3 = Color3.fromRGB(255, 200, 61)
    head.Font = Enum.Font.GothamBold
    head.TextSize = 11
    head.TextXAlignment = Enum.TextXAlignment.Left
    head.Parent = f

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -16, 1, -24)
    body.Position = UDim2.new(0, 8, 0, 22)
    body.BackgroundTransparency = 1
    body.Text = text
    body.TextColor3 = Color3.new(1, 1, 1)
    body.Font = Enum.Font.GothamMedium
    body.TextSize = 12
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Parent = f

    bannerFrame = f
    TweenService:Create(f, TweenInfo.new(0.35, Enum.EasingStyle.Back),
        {Position = UDim2.new(0.5, 0, 0, 56)}):Play()
    task.delay(9, function()
        if f.Parent then
            local t = TweenService:Create(f, TweenInfo.new(0.3),
                {Position = UDim2.new(0.5, 0, 0, -80)})
            t:Play()
            t.Completed:Wait()
            f:Destroy()
        end
    end)
end

local lastAnnounce
local function checkAnnouncement()
    local ok, res = pcall(httpRequest, {Url = FIREBASE_URL .. "/announce.json", Method = "GET"})
    if not ok or not res or not res.Body then return end
    local okJ, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if not okJ or type(data) ~= "table" or type(data.text) ~= "string" or type(data.time) ~= "number" then
        if lastAnnounce == nil then lastAnnounce = 0 end -- nothing announced yet
        return
    end
    if lastAnnounce == nil then
        lastAnnounce = data.time -- first check: remember it, don't replay old announcements
        return
    end
    if data.time > lastAnnounce then
        lastAnnounce = data.time
        showAnnouncement(data.text)
    end
end

local function showIncoming(data, owner, ts)
    if not (type(data) == "table" and type(data.t) == "string") then return end
    if data.n and mySent[data.n] then return end
    local name = tostring(data.d or data.u or "?"):sub(1, 20)
    addChatLine(name, data.t:sub(1, MAX_LEN), false, owner == true, ts, nil, tonumber(data.i))
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
        pcall(checkAnnouncement)
        pcall(dm.poll)
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
                showIncoming(m, m.o == true, type(m.time) == "number" and m.time / 1000 or nil)
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
            if okD then showIncoming(data, false, type(m.time) == "number" and m.time or nil) end
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

-- ========== Settings window (theme, opacity, keybind) ==========
local settingsWin, initSettings = (function()
    local UserInputService = game:GetService("UserInputService")
    local SETTINGS_FILE = "AizenPanel_settings.json"
    local settings = {theme = "Purple", opacity = 1, key = "RightShift", floating = false}

    local function loadSettings()
        pcall(function()
            if isfile and isfile(SETTINGS_FILE) then
                local d = HttpService:JSONDecode(readfile(SETTINGS_FILE))
                for k, v in pairs(d) do
                    if settings[k] ~= nil and type(v) == type(settings[k]) then settings[k] = v end
                end
            end
        end)
    end
    local function saveSettings()
        pcall(function()
            if writefile then writefile(SETTINGS_FILE, HttpService:JSONEncode(settings)) end
        end)
    end

    local THEMES = {
        {name = "Purple", hue = nil,  swatch = Color3.fromRGB(170, 90, 255)},
        {name = "Blue",   hue = 0.60, swatch = Color3.fromHSV(0.60, 0.70, 1)},
        {name = "Cyan",   hue = 0.50, swatch = Color3.fromHSV(0.50, 0.65, 1)},
        {name = "Green",  hue = 0.38, swatch = Color3.fromHSV(0.38, 0.65, 0.95)},
        {name = "Pink",   hue = 0.90, swatch = Color3.fromHSV(0.90, 0.55, 1)},
        {name = "Red",    hue = 0.00, swatch = Color3.fromHSV(0.00, 0.70, 1)},
    }
    local themeHue = nil

    -- ----- recolor every purple "accent" element in the script's UI -----
    local accentProps = setmetatable({}, {__mode = "k"})
    local function isAccent(c)
        local h, s, v = c:ToHSV()
        return h >= 0.70 and h <= 0.82 and s >= 0.25 and v >= 0.35
    end
    local function paint(o)
        local props = accentProps[o]
        if not props then return end
        for prop, orig in pairs(props) do
            if themeHue then
                local _, s, v = orig:ToHSV()
                o[prop] = Color3.fromHSV(themeHue, s, v)
            else
                o[prop] = orig
            end
        end
    end
    local function consider(o)
        if accentProps[o] or o:GetAttribute("NoTheme") then return end
        local props = {}
        if o:IsA("UIStroke") then
            if isAccent(o.Color) then props.Color = o.Color end
        elseif o:IsA("GuiObject") then
            if o.BackgroundTransparency < 1 and isAccent(o.BackgroundColor3) then
                props.BackgroundColor3 = o.BackgroundColor3
            end
            if (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) and isAccent(o.TextColor3) then
                props.TextColor3 = o.TextColor3
            end
        end
        if next(props) then
            accentProps[o] = props
            paint(o)
        end
    end

    -- ----- the window -----
    local win = makeWindow({
        title = "SETTINGS  <font size='10' color='rgb(180,180,180)'>look & feel</font>",
        minTitle = "SETTINGS",
        w = 210, h = 290, minW = 100,
        pos = UDim2.new(0, 180, 0, 40),
    })
    local body = win.body

    local function label(text, y)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -12, 0, 16)
        l.Position = UDim2.new(0, 8, 0, y)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(200, 200, 215)
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = body
        return l
    end

    -- Theme swatches
    label("Theme", 0)
    local swatchStrokes = {}
    for i, t in ipairs(THEMES) do
        local b = Instance.new("TextButton")
        b:SetAttribute("NoTheme", true)
        b.Size = UDim2.new(0, 28, 0, 28)
        b.Position = UDim2.new(0, 8 + (i - 1) * 33, 0, 20)
        b.BackgroundColor3 = t.swatch
        b.Text = ""
        b.AutoButtonColor = true
        b.Parent = body
        corner(b, 14)
        local st = Instance.new("UIStroke", b)
        st:SetAttribute("NoTheme", true)
        st.Color = Color3.new(1, 1, 1)
        st.Thickness = 0
        swatchStrokes[t.name] = st
        b.MouseButton1Click:Connect(function()
            settings.theme = t.name
            themeHue = t.hue
            for o in pairs(accentProps) do
                if o.Parent then paint(o) end
            end
            for name, stroke in pairs(swatchStrokes) do
                stroke.Thickness = (name == t.name) and 2 or 0
            end
            saveSettings()
        end)
    end

    -- Opacity slider
    local opacityLabel = label("Window opacity  100%", 58)
    local track = Instance.new("TextButton")
    track.Size = UDim2.new(1, -24, 0, 24)
    track.Position = UDim2.new(0, 12, 0, 78)
    track.BackgroundTransparency = 1
    track.Text = ""
    track.AutoButtonColor = false
    track.Parent = body
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.AnchorPoint = Vector2.new(0, 0.5)
    bar.Position = UDim2.new(0, 0, 0.5, 0)
    bar.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    bar.Parent = track
    corner(bar, 3)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(170, 90, 255)
    fill.Parent = bar
    corner(fill, 3)
    local knob = Instance.new("Frame")
    knob:SetAttribute("NoTheme", true)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(1, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.Parent = track
    corner(knob, 8)

    local MIN_OPACITY = 0.4
    local function applyOpacity()
        for _, f in ipairs(allWindows) do
            f.BackgroundTransparency = 1 - settings.opacity
        end
        local rel = (settings.opacity - MIN_OPACITY) / (1 - MIN_OPACITY)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        opacityLabel.Text = "Window opacity  " .. math.floor(settings.opacity * 100 + 0.5) .. "%"
    end
    local dragging = false
    local function setFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        settings.opacity = MIN_OPACITY + (1 - MIN_OPACITY) * rel
        applyOpacity()
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            saveSettings()
        end
    end)

    -- Hide/show keybind (keyboard)
    label("Hide / show key (keyboard)", 112)
    local capturing = false
    local keyBtn
    keyBtn = makeButton(body, "Key: RightShift", function()
        capturing = true
        keyBtn.Text = "Press a key..."
    end)
    keyBtn.Size = UDim2.new(1, -16, 0, 26)
    keyBtn.Position = UDim2.new(0, 8, 0, 130)
    keyBtn.TextSize = 11
    keyBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 85)

    UserInputService.InputBegan:Connect(function(input, processed)
        if capturing then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                settings.key = input.KeyCode.Name
                keyBtn.Text = "Key: " .. settings.key
                capturing = false
                saveSettings()
            end
            return
        end
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == settings.key then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- Floating show/hide button (for phones, which have no keyboard)
    label("Floating hide/show button", 164)
    local fgui = Instance.new("ScreenGui")
    fgui.Name = "AizenToggle"
    fgui.ResetOnSpawn = false
    fgui.DisplayOrder = 50
    fgui.Parent = player:WaitForChild("PlayerGui")
    local fbtn = Instance.new("TextButton")
    fbtn:SetAttribute("NoTheme", true)
    fbtn.Size = UDim2.new(0, 40, 0, 40)
    fbtn.Position = UDim2.new(0, 12, 0.5, -20)
    fbtn.BackgroundColor3 = Color3.fromRGB(90, 60, 140)
    fbtn.TextColor3 = Color3.new(1, 1, 1)
    fbtn.Text = "A"
    fbtn.Font = Enum.Font.GothamBlack
    fbtn.TextSize = 18
    fbtn.Draggable = true
    fbtn.Active = true
    fbtn.Visible = false
    fbtn.Parent = fgui
    corner(fbtn, 20)
    fbtn.MouseButton1Click:Connect(function() gui.Enabled = not gui.Enabled end)

    local floatBtn
    local function applyFloating()
        fbtn.Visible = settings.floating
        floatBtn.Text = "Floating button: " .. (settings.floating and "ON" or "OFF")
        floatBtn.BackgroundColor3 = settings.floating and Color3.fromRGB(50, 130, 80) or Color3.fromRGB(60, 50, 85)
    end
    floatBtn = makeButton(body, "Floating button: OFF", function()
        settings.floating = not settings.floating
        applyFloating()
        saveSettings()
    end)
    floatBtn.Size = UDim2.new(1, -16, 0, 26)
    floatBtn.Position = UDim2.new(0, 8, 0, 182)
    floatBtn.TextSize = 11

    local resetBtn = makeButton(body, "Reset settings", function()
        settings.theme, settings.opacity, settings.key, settings.floating = "Purple", 1, "RightShift", false
        themeHue = nil
        for o in pairs(accentProps) do if o.Parent then paint(o) end end
        for name, stroke in pairs(swatchStrokes) do stroke.Thickness = (name == "Purple") and 2 or 0 end
        keyBtn.Text = "Key: RightShift"
        applyOpacity()
        applyFloating()
        saveSettings()
    end)
    resetBtn.Size = UDim2.new(1, -16, 0, 26)
    resetBtn.Position = UDim2.new(0, 8, 0, 216)
    resetBtn.TextSize = 11
    resetBtn.BackgroundColor3 = Color3.fromRGB(110, 45, 70)

    local note = label("Saved on this device", 246)
    note.TextSize = 10
    note.TextColor3 = Color3.fromRGB(130, 125, 150)

    -- Called once, after every window has been built
    local function init()
        loadSettings()
        for _, o in ipairs(gui:GetDescendants()) do consider(o) end
        gui.DescendantAdded:Connect(function(o)
            task.defer(function() consider(o) end) -- wait until its properties are set
        end)
        for _, t in ipairs(THEMES) do
            if t.name == settings.theme then themeHue = t.hue end
        end
        for o in pairs(accentProps) do if o.Parent then paint(o) end end
        for name, stroke in pairs(swatchStrokes) do
            stroke.Thickness = (name == settings.theme) and 2 or 0
        end
        keyBtn.Text = "Key: " .. settings.key
        applyOpacity()
        applyFloating()
    end

    return win, init
end)()

local ownerLogin   -- assigned further down (owner-only unlock)

-- ========== Commands window (Infinite Yield style) ==========
-- Type a command + Enter (a leading ; is optional). Tap a command in the list to fill it in.
local cmdWin = makeWindow({
    title = "COMMANDS  <font size='10' color='rgb(180,180,180)'>by Anshux</font>",
    minTitle = "CMDS",
    w = 230, h = 340, minW = 90,
    pos = UDim2.new(0, 20, 0, 60),
})
local function buildCommands()   -- own function = own local-variable budget (Luau limit is 200)
    local UIS = game:GetService("UserInputService")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local TeleportService = game:GetService("TeleportService")
    local kbody = cmdWin.body

    -- Command prefix (saved on this device). Works in the box AND in Roblox chat.
    local PREFIX_FILE = "AizenPrefix.txt"
    local prefix = ";"
    pcall(function()
        if isfile and isfile(PREFIX_FILE) then
            local p = readfile(PREFIX_FILE):gsub("%s", "")
            if p ~= "" and #p <= 3 and p:match("^%p+$") and not p:find("[<>&]") then prefix = p end
        end
    end)

    -- ----- UI -----
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -12, 0, 26)
    input.Position = UDim2.new(0, 6, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.PlaceholderText = "Command + Enter  (e.g. fly 80)"
    input.PlaceholderColor3 = Color3.fromRGB(130, 125, 150)
    input.Text = ""
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    input.ClearTextOnFocus = false
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = kbody
    corner(input, 6)
    local inPad = Instance.new("UIPadding", input)
    inPad.PaddingLeft = UDim.new(0, 8)

    local kstatus = Instance.new("TextLabel")
    kstatus.Size = UDim2.new(1, -62, 0, 16)
    kstatus.Position = UDim2.new(0, 6, 0, 28)
    kstatus.BackgroundTransparency = 1
    kstatus.TextColor3 = Color3.fromRGB(180, 180, 180)
    kstatus.Font = Enum.Font.Gotham
    kstatus.TextSize = 10
    kstatus.TextXAlignment = Enum.TextXAlignment.Left
    kstatus.Text = "Tap a command below to use it"
    kstatus.Parent = kbody
    local function say(t) kstatus.Text = t end

    local prefixBox = Instance.new("TextBox")
    prefixBox.Size = UDim2.new(0, 46, 0, 16)
    prefixBox.Position = UDim2.new(1, -52, 0, 28)
    prefixBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
    prefixBox.TextColor3 = Color3.fromRGB(185, 138, 255)
    prefixBox.Font = Enum.Font.GothamBold
    prefixBox.TextSize = 11
    prefixBox.Text = prefix
    prefixBox.PlaceholderText = "prefix"
    prefixBox.ClearTextOnFocus = true
    prefixBox.Parent = kbody
    corner(prefixBox, 4)

    local klist = Instance.new("ScrollingFrame")
    klist.Size = UDim2.new(1, -12, 1, -50)
    klist.Position = UDim2.new(0, 6, 0, 46)
    klist.BackgroundColor3 = Color3.fromRGB(16, 13, 26)
    klist.BorderSizePixel = 0
    klist.ScrollBarThickness = 3
    klist.CanvasSize = UDim2.new(0, 0, 0, 0)
    klist.AutomaticCanvasSize = Enum.AutomaticSize.Y
    klist.Parent = kbody
    corner(klist, 8)
    local kLayout = Instance.new("UIListLayout", klist)
    kLayout.Padding = UDim.new(0, 3)
    kLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local kPad = Instance.new("UIPadding", klist)
    kPad.PaddingLeft = UDim.new(0, 4)
    kPad.PaddingRight = UDim.new(0, 6)
    kPad.PaddingTop = UDim.new(0, 4)
    kPad.PaddingBottom = UDim.new(0, 4)

    -- ----- helpers -----
    local cmdList, byName = {}, {}
    local function add(names, usage, desc, fn)
        local c = {names = names, usage = usage, desc = desc, fn = fn}
        table.insert(cmdList, c)
        for _, n in ipairs(names) do byName[n] = c end
    end
    local function getChar() return player.Character end
    local function getRoot()
        local c = player.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function getHum()
        local c = player.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function num(v, default) return tonumber(v) or default end
    local setPrefix   -- defined after the list is built

    local function findPlayer(q)
        if not q or q == "" then return nil end
        q = q:lower()
        if q == "me" then return player end
        local partial
        for _, p in ipairs(Players:GetPlayers()) do
            local n, d = p.Name:lower(), p.DisplayName:lower()
            if n == q or d == q then return p end
            if not partial and (n:sub(1, #q) == q or d:sub(1, #q) == q) then partial = p end
        end
        if partial then return partial end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Name:lower():find(q, 1, true) or p.DisplayName:lower():find(q, 1, true) then return p end
        end
    end

    local conns = {}
    local function disconnect(name)
        if conns[name] then conns[name]:Disconnect() conns[name] = nil end
    end

    -- locked walk speed / jump power (games often reset them)
    local lockWS, lockJP
    RunService.Heartbeat:Connect(function()
        local h = getHum()
        if not h then return end
        if lockWS then h.WalkSpeed = lockWS end
        if lockJP then h.UseJumpPower = true h.JumpPower = lockJP end
    end)

    -- ----- fly -----
    local flyObjs
    local function stopFly()
        disconnect("fly")
        if flyObjs then
            for _, o in ipairs(flyObjs) do o:Destroy() end
            flyObjs = nil
        end
        local h = getHum()
        if h then h.PlatformStand = false end
    end
    local function startFly(speed)
        stopFly()
        local r, h = getRoot(), getHum()
        if not r or not h then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bv.Velocity = Vector3.zero
        bv.Parent = r
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bg.P = 9e4
        bg.CFrame = r.CFrame
        bg.Parent = r
        flyObjs = {bv, bg}
        h.PlatformStand = true
        conns.fly = RunService.Heartbeat:Connect(function()
            local cam = Workspace.CurrentCamera
            if not cam or not r.Parent then stopFly() return end
            local d = cam.CFrame:VectorToObjectSpace(h.MoveDirection)
            local v = cam.CFrame.LookVector * -d.Z + cam.CFrame.RightVector * d.X
            if UIS:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v -= Vector3.yAxis end
            bv.Velocity = v * speed
            bg.CFrame = cam.CFrame
        end)
    end

    -- ----- spin / freeze / esp / lighting -----
    local function stopSpin()
        local r = getRoot()
        local s = r and r:FindFirstChild("AizenSpin")
        if s then s:Destroy() end
    end
    local function setFrozen(state)
        local r = getRoot()
        if r then r.Anchored = state end
    end

    local espOn = false
    local function clearEsp()
        espOn = false
        for _, p in ipairs(Players:GetPlayers()) do
            local hl = p.Character and p.Character:FindFirstChild("AizenESP")
            if hl then hl:Destroy() end
        end
    end
    local function startEsp()
        if espOn then return end
        espOn = true
        task.spawn(function()
            while espOn do
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character and not p.Character:FindFirstChild("AizenESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "AizenESP"
                        hl.FillColor = Color3.fromRGB(170, 90, 255)
                        hl.FillTransparency = 0.6
                        hl.OutlineColor = Color3.new(1, 1, 1)
                        hl.Parent = p.Character
                    end
                end
                task.wait(1.5)
            end
        end)
    end

    local fbOrig
    local function fullbrightOff()
        if fbOrig then
            for k, v in pairs(fbOrig) do Lighting[k] = v end
            fbOrig = nil
        end
    end

    local function viewReset()
        local cam = Workspace.CurrentCamera
        local h = getHum()
        if cam and h then cam.CameraSubject = h end
    end

    player.CharacterAdded:Connect(function()
        stopFly()
    end)

    -- ----- commands -----
    add({"walkspeed", "ws", "speed"}, "[n]", "Set walk speed (no number = reset to 16)", function(n)
        local v = num(n, 16)
        lockWS = (v ~= 16) and v or nil
        local h = getHum()
        if h then h.WalkSpeed = v end
        say("Walk speed: " .. v)
    end)
    add({"jumppower", "jp", "jump"}, "[n]", "Set jump power (no number = reset to 50)", function(n)
        local v = num(n, 50)
        lockJP = (v ~= 50) and v or nil
        local h = getHum()
        if h then h.UseJumpPower = true h.JumpPower = v end
        say("Jump power: " .. v)
    end)
    add({"hipheight", "hh"}, "[n]", "Set hip height", function(n)
        local h = getHum()
        if h then h.HipHeight = num(n, 2) end
    end)
    add({"gravity", "grav"}, "[n]", "Set gravity (default 196.2)", function(n)
        Workspace.Gravity = num(n, 196.2)
    end)
    add({"fov"}, "[n]", "Set field of view (default 70)", function(n)
        local cam = Workspace.CurrentCamera
        if cam then cam.FieldOfView = num(n, 70) end
    end)
    add({"zoom"}, "[n]", "Set max camera zoom distance", function(n)
        player.CameraMaxZoomDistance = num(n, 128)
    end)
    add({"fly"}, "[speed]", "Fly (move with your joystick/WASD, look to steer; Space/Ctrl = up/down)", function(n)
        startFly(num(n, 60))
        say("Fly ON  (unfly to stop)")
    end)
    add({"unfly"}, "", "Stop flying", function() stopFly() say("Fly OFF") end)
    add({"noclip"}, "", "Walk through walls", function()
        disconnect("noclip")
        conns.noclip = RunService.Stepped:Connect(function()
            local c = getChar()
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
        say("Noclip ON  (clip to stop)")
    end)
    add({"clip", "unnoclip"}, "", "Turn noclip off", function() disconnect("noclip") say("Noclip OFF") end)
    add({"infjump", "infinitejump"}, "", "Jump again in mid-air", function()
        disconnect("infjump")
        conns.infjump = UIS.JumpRequest:Connect(function()
            local h = getHum()
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        say("Infinite jump ON")
    end)
    add({"uninfjump", "noinfjump"}, "", "Turn infinite jump off", function() disconnect("infjump") say("Infinite jump OFF") end)
    add({"sit"}, "", "Sit down", function()
        local h = getHum()
        if h then h.Sit = true end
    end)
    add({"reset", "die"}, "", "Reset your character", function()
        local h = getHum()
        if h then h.Health = 0 end
    end)
    add({"freeze", "anchor"}, "", "Freeze yourself in place", function() setFrozen(true) say("Frozen") end)
    add({"unfreeze", "thaw", "unanchor"}, "", "Unfreeze", function() setFrozen(false) say("Unfrozen") end)
    add({"spin"}, "[speed]", "Spin your character", function(n)
        stopSpin()
        local r = getRoot()
        if not r then return end
        local s = Instance.new("BodyAngularVelocity")
        s.Name = "AizenSpin"
        s.MaxTorque = Vector3.new(0, 1e9, 0)
        s.AngularVelocity = Vector3.new(0, num(n, 20), 0)
        s.Parent = r
    end)
    add({"unspin"}, "", "Stop spinning", function() stopSpin() end)
    add({"goto", "to", "tp"}, "<player>", "Teleport to a player", function(q)
        local t = findPlayer(q)
        local r, tr = getRoot(), t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        if r and tr then
            r.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
            say("Teleported to " .. t.DisplayName)
        else
            say("Player not found")
        end
    end)
    add({"view", "spectate"}, "<player>", "Watch a player through your camera", function(q)
        local t = findPlayer(q)
        local th = t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
        local cam = Workspace.CurrentCamera
        if th and cam then
            cam.CameraSubject = th
            say("Viewing " .. t.DisplayName .. "  (unview to stop)")
        else
            say("Player not found")
        end
    end)
    add({"unview", "unspectate"}, "", "Go back to your own camera", function() viewReset() say("Camera reset") end)
    add({"esp"}, "", "Highlight all players (see through walls)", function() startEsp() say("ESP ON") end)
    add({"unesp", "noesp"}, "", "Remove player highlights", function() clearEsp() say("ESP OFF") end)
    add({"fullbright", "fb"}, "", "Remove darkness and shadows", function()
        if not fbOrig then
            fbOrig = {
                Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
                FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
                Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            }
        end
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e5
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        say("Fullbright ON")
    end)
    add({"unfullbright", "nofb"}, "", "Restore normal lighting", function() fullbrightOff() say("Fullbright OFF") end)
    add({"day"}, "", "Set the time to day", function() Lighting.ClockTime = 14 end)
    add({"night"}, "", "Set the time to night", function() Lighting.ClockTime = 0 end)
    add({"antiafk", "noafk"}, "", "Don't get kicked for being idle", function()
        disconnect("afk")
        conns.afk = player.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
        say("Anti-AFK ON")
    end)
    add({"rejoin", "rj"}, "", "Rejoin this server", function()
        say("Rejoining...")
        pcall(function()
            if #Players:GetPlayers() <= 1 then
                player:Kick("\nRejoining...")
                task.wait()
                TeleportService:Teleport(game.PlaceId, player)
            else
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            end
        end)
    end)
    -- ----- bang protection (personal safety) -----
    -- Detects a player who stays pressed right behind you, "bans" them on YOUR screen
    -- (hidden, no collision, blocked-prompt) and moves you to your house whenever they come near.
    -- It cannot kick anyone from the server; use Roblox's Report button for that.
    local StarterGui = game:GetService("StarterGui")
    local BAN_FILE, HOUSE_FILE = "AizenBannedPlayers.json", "AizenHouse.json"
    local HIT_DISTANCE, HIT_TIME, BAN_RADIUS = 3.2, 1.2, 9
    local antiOn = false
    local banned, trusted, closeSince = {}, {}, {}   -- banned[userId] = name
    local house            -- CFrame of your safe spot
    local lastEscape = 0

    pcall(function()
        if isfile and isfile(BAN_FILE) then
            for _, e in ipairs(HttpService:JSONDecode(readfile(BAN_FILE))) do
                if tonumber(e.id) then banned[tonumber(e.id)] = tostring(e.name) end
            end
        end
        if isfile and isfile(HOUSE_FILE) then
            local d = HttpService:JSONDecode(readfile(HOUSE_FILE))
            if d.place == game.PlaceId and type(d.c) == "table" and #d.c == 12 then
                house = CFrame.new(table.unpack(d.c))
            end
        end
    end)
    local function saveBans()
        local arr = {}
        for id, n in pairs(banned) do table.insert(arr, {id = id, name = n}) end
        pcall(function() writefile(BAN_FILE, HttpService:JSONEncode(arr)) end)
    end
    local function saveHouse()
        if not house then return end
        pcall(function()
            writefile(HOUSE_FILE, HttpService:JSONEncode({place = game.PlaceId, c = {house:GetComponents()}}))
        end)
    end
    local function setHouseHere()
        local r = getRoot()
        if not r then say("No character yet") return false end
        house = r.CFrame
        saveHouse()
        return true
    end
    local function goHouse()
        local r = getRoot()
        if r and house then
            r.AssemblyLinearVelocity = Vector3.zero
            r.CFrame = house + Vector3.new(0, 3, 0)
            return true
        end
        return false
    end

    -- hide a banned player's character on this client only
    local function hideBanned(p)
        local c = p.Character
        if not c then return end
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanCollide = false
                d.LocalTransparencyModifier = 1
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 1
            elseif d:IsA("BillboardGui") then
                d.Enabled = false
            end
        end
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
    end

    local function escape()
        if os.clock() - lastEscape < 1.5 then return end
        lastEscape = os.clock()
        if goHouse() then
            say("Moved you to your house")
        else
            say("No house set - run sethouse")
        end
    end

    local function banPlayer(p, why)
        if banned[p.UserId] then return end
        banned[p.UserId] = p.Name
        saveBans()
        hideBanned(p)
        escape()
        say("Banned " .. p.DisplayName .. " (" .. why .. ")")
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Bang protection", Text = p.DisplayName .. " was banned", Duration = 5})
        end)
        pcall(function() StarterGui:SetCore("PromptBlockPlayer", p) end)
    end

    local acc = 0
    RunService.Heartbeat:Connect(function(dt)
        acc += dt
        if acc < 0.1 then return end
        acc = 0
        local r = getRoot()
        local now = os.clock()
        -- banned players stay hidden; if one gets near you, you are moved away again
        for id in pairs(banned) do
            local p = Players:GetPlayerByUserId(id)
            if p and p ~= player then
                hideBanned(p)
                local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if antiOn and r and tr and (tr.Position - r.Position).Magnitude <= BAN_RADIUS then
                    escape()
                end
            end
        end
        -- detect someone staying pressed right behind you
        if not antiOn or not r then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and not banned[p.UserId] and not trusted[p.UserId] then
                local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local off = tr.Position - r.Position
                    local flat = Vector3.new(off.X, 0, off.Z)
                    local behind = flat.Magnitude > 0.01
                        and r.CFrame.LookVector:Dot(flat.Unit) < -0.2
                    if off.Magnitude <= HIT_DISTANCE and math.abs(off.Y) < 3 and behind then
                        closeSince[p.UserId] = closeSince[p.UserId] or now
                        if now - closeSince[p.UserId] >= HIT_TIME then
                            closeSince[p.UserId] = nil
                            banPlayer(p, "stuck behind you")
                        end
                    else
                        closeSince[p.UserId] = nil
                    end
                end
            end
        end
    end)

    -- "get a house" prompt shown when you turn bang protection on
    local pop = Instance.new("Frame")
    pop.Size = UDim2.new(1, -24, 0, 128)
    pop.Position = UDim2.new(0, 12, 0, 60)
    pop.BackgroundColor3 = Color3.fromRGB(30, 26, 46)
    pop.BorderSizePixel = 0
    pop.Visible = false
    pop.ZIndex = 20
    pop.Parent = kbody
    corner(pop, 10)
    local popText = Instance.new("TextLabel")
    popText.Size = UDim2.new(1, -16, 0, 56)
    popText.Position = UDim2.new(0, 8, 0, 6)
    popText.BackgroundTransparency = 1
    popText.TextWrapped = true
    popText.TextColor3 = Color3.new(1, 1, 1)
    popText.Font = Enum.Font.Gotham
    popText.TextSize = 12
    popText.ZIndex = 21
    popText.Text = "Bang protection needs a house: a safe spot you get moved to. Stand where you want it, then tap Set house."
    popText.Parent = pop
    local function popBtn(text, y, color, cb)
        local b = makeButton(pop, text, cb)
        b.Size = UDim2.new(1, -16, 0, 24)
        b.Position = UDim2.new(0, 8, 0, y)
        b.ZIndex = 21
        b.TextSize = 11
        if color then b.BackgroundColor3 = color end
        return b
    end
    local function closePop() pop.Visible = false end
    popBtn("Set house here", 64, Color3.fromRGB(90, 60, 140), function()
        if setHouseHere() then
            antiOn = true
            say("Bang protection ON - house set")
        end
        closePop()
    end)
    local useSaved = popBtn("Use my saved house", 64, Color3.fromRGB(60, 50, 85), function()
        antiOn = true
        say("Bang protection ON - saved house")
        closePop()
    end)
    local cancelBtn = popBtn("Cancel", 94, Color3.fromRGB(60, 50, 85), function() closePop() end)
    local function openPop()
        if house then
            useSaved.Visible = true
            useSaved.Position = UDim2.new(0, 8, 0, 92)
            cancelBtn.Position = UDim2.new(0, 8, 0, 120)
        else
            useSaved.Visible = false
            cancelBtn.Position = UDim2.new(0, 8, 0, 94)
        end
        pop.Size = UDim2.new(1, -24, 0, house and 150 or 128)
        pop.Visible = true
    end

    add({"antibang", "bangprotect"}, "", "Bang protection: bans anyone who gets stuck behind you and moves you to your house", function()
        if antiOn then
            antiOn = false
            say("Bang protection OFF")
        else
            openPop()
        end
    end)
    add({"sethouse"}, "", "Save your current spot as your house", function()
        if setHouseHere() then say("House saved here") end
    end)
    add({"house", "home"}, "", "Teleport to your house", function()
        if not goHouse() then say("No house set - run sethouse") end
    end)
    add({"unban"}, "<player>", "Remove someone from your bang-protection ban list", function(q)
        q = (q or ""):lower()
        for id, n in pairs(banned) do
            if q ~= "" and n:lower():find(q, 1, true) then
                banned[id] = nil
                saveBans()
                say("Unbanned " .. n .. " (rejoin to see them again)")
                return
            end
        end
        say("Not on your ban list")
    end)
    add({"banlist", "bans"}, "", "Show who you have banned", function()
        local t = {}
        for _, n in pairs(banned) do table.insert(t, n) end
        say(#t == 0 and "Ban list is empty" or ("Banned: " .. table.concat(t, ", ")))
    end)
    add({"trust"}, "<player>", "Bang protection will ignore this player (this session)", function(q)
        local t = findPlayer(q)
        if t then trusted[t.UserId] = true say("Trusting " .. t.DisplayName) else say("Player not found") end
    end)
    add({"untrust"}, "<player>", "Stop trusting a player", function(q)
        local t = findPlayer(q)
        if t then trusted[t.UserId] = nil say("No longer trusting " .. t.DisplayName) else say("Player not found") end
    end)

    add({"prefix"}, "<chars>", "Change the command prefix (1-3 symbols, e.g. ! or ;)", function(p)
        if p and #p <= 3 and p:match("^%p+$") and not p:find("[<>&]") then
            setPrefix(p)
        else
            say("Prefix must be 1-3 symbols, like ; ! . -")
        end
    end)
    add({"stopall", "unall"}, "", "Turn off everything (fly, noclip, esp, speed...)", function()
        stopFly(); stopSpin(); clearEsp(); fullbrightOff(); viewReset(); setFrozen(false)
        disconnect("noclip"); disconnect("infjump")
        lockWS, lockJP = nil, nil
        local h = getHum()
        if h then h.WalkSpeed = 16 h.JumpPower = 50 end
        say("Everything turned off")
    end)

    -- ----- build the list -----
    table.sort(cmdList, function(a, b) return a.names[1] < b.names[1] end)
    local rows = {}
    local function rowText(c)
        local alias = #c.names > 1 and ("  <font color='#8d88a8'>(" .. table.concat(c.names, ", ", 2) .. ")</font>") or ""
        local usage = c.usage:gsub("<", "&lt;"):gsub(">", "&gt;")
        return ("<b><font color='#b98aff'>%s%s</font></b> %s%s\n<font color='#c8c4d8'>%s</font>"):format(
            prefix, c.names[1], usage, alias, c.desc)
    end
    for i, c in ipairs(cmdList) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 0)
        btn.AutomaticSize = Enum.AutomaticSize.Y
        btn.BackgroundColor3 = Color3.fromRGB(38, 33, 56)
        btn.AutoButtonColor = true
        btn.RichText = true
        btn.TextWrapped = true
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextYAlignment = Enum.TextYAlignment.Top
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.LayoutOrder = i
        btn.Text = rowText(c)
        btn.Parent = klist
        corner(btn, 6)
        local bp = Instance.new("UIPadding", btn)
        bp.PaddingLeft = UDim.new(0, 6)
        bp.PaddingRight = UDim.new(0, 6)
        bp.PaddingTop = UDim.new(0, 4)
        bp.PaddingBottom = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            if c.usage == "" then
                local ok, err = pcall(c.fn)
                if not ok then say("Error: " .. tostring(err):sub(1, 40)) end
            else
                input.Text = c.names[1] .. " "
                input:CaptureFocus()
            end
        end)
        rows[i] = {btn = btn, cmd = c}
    end

    -- filter the list while typing
    local function refilter()
        local t = input.Text
        if t:sub(1, #prefix) == prefix then t = t:sub(#prefix + 1) end
        local q = (t:match("^%s*(%S*)") or ""):lower()
        for _, r in ipairs(rows) do
            local show = q == ""
            if not show then
                for _, n in ipairs(r.cmd.names) do
                    if n:sub(1, #q) == q then show = true break end
                end
            end
            r.btn.Visible = show
        end
    end
    input:GetPropertyChangedSignal("Text"):Connect(refilter)

    function setPrefix(p)
        prefix = p
        prefixBox.Text = p
        pcall(function() writefile(PREFIX_FILE, p) end)
        for _, r in ipairs(rows) do r.btn.Text = rowText(r.cmd) end
        say("Prefix is now " .. p)
    end
    prefixBox.FocusLost:Connect(function()
        local p = prefixBox.Text:gsub("%s", "")
        if p ~= "" and #p <= 3 and p:match("^%p+$") and not p:find("[<>&]") then
            setPrefix(p)
        else
            prefixBox.Text = prefix
            say("Prefix must be 1-3 symbols, like ; ! . -")
        end
    end)

    local function run(text, fromChat)
        text = (text:gsub("^%s+", ""))
        if text:sub(1, #prefix) == prefix then text = text:sub(#prefix + 1) end
        local parts = {}
        for w in text:gmatch("%S+") do parts[#parts + 1] = w end
        local name = (table.remove(parts, 1) or ""):lower()
        if name == "" then return end
        if name == "owner" then   -- hidden owner unlock: owner <email> <password>
            if fromChat then say("Owner login only works in the command box") return end
            if ownerLogin then ownerLogin(parts[1], parts[2], say) end
            return
        end
        local c = byName[name]
        if not c then say("Unknown command: " .. name) return end
        local ok, err = pcall(c.fn, table.unpack(parts))
        if not ok then say("Error: " .. tostring(err):sub(1, 40)) end
    end
    input.FocusLost:Connect(function(enter)
        if enter then
            local t = input.Text
            input.Text = ""
            run(t)
        end
    end)

    -- Commands typed in Roblox chat (works with the old and the new chat system).
    -- Note: other players in the server can still see the chat message itself.
    local lastChat, lastChatT = "", 0
    local function onChat(msg)
        if type(msg) ~= "string" or #msg <= #prefix or msg:sub(1, #prefix) ~= prefix then return end
        local now = os.clock()
        if msg == lastChat and now - lastChatT < 0.5 then return end   -- both chat events fired
        lastChat, lastChatT = msg, now
        run(msg:sub(#prefix + 1), true)
    end
    player.Chatted:Connect(onChat)
    pcall(function()
        game:GetService("TextChatService").SendingMessage:Connect(function(m) onChat(m.Text) end)
    end)
end
buildCommands()

-- ========== Hub (main window, always stays) ==========
local hub = makeWindow({
    title = "AIZEN  <font size='10' color='rgb(180,180,180)'>by Anshux</font>",
    minTitle = "AIZEN",
    w = 150, h = 244, minW = 80,
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

-- ========== Owner panel (only appears after your owner login is verified) ==========
local ownerWin = makeWindow({
    title = "OWNER  <font size='10' color='rgb(255,200,61)'>announce</font>",
    minTitle = "OWNER",
    w = 190, h = 150, minW = 90,
    pos = UDim2.new(0, 180, 0, 100),
})
local obody = ownerWin.body

local oBox = Instance.new("TextBox")
oBox.Size = UDim2.new(1, -12, 0, 60)
oBox.Position = UDim2.new(0, 6, 0, 0)
oBox.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
oBox.TextColor3 = Color3.new(1, 1, 1)
oBox.PlaceholderText = "Announcement for all script users..."
oBox.Text = ""
oBox.Font = Enum.Font.Gotham
oBox.TextSize = 12
oBox.TextWrapped = true
oBox.ClearTextOnFocus = false
oBox.TextXAlignment = Enum.TextXAlignment.Left
oBox.TextYAlignment = Enum.TextYAlignment.Top
oBox.Parent = obody
corner(oBox, 6)

local oStatus = Instance.new("TextLabel")
oStatus.Size = UDim2.new(1, -12, 0, 16)
oStatus.Position = UDim2.new(0, 6, 0, 64)
oStatus.BackgroundTransparency = 1
oStatus.TextColor3 = Color3.fromRGB(200, 200, 200)
oStatus.Font = Enum.Font.Gotham
oStatus.TextSize = 11
oStatus.TextXAlignment = Enum.TextXAlignment.Left
oStatus.Text = "Max 200 characters"
oStatus.Parent = obody

local oSend = makeButton(obody, "Send announcement", function()
    local text = oBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then oStatus.Text = "Type something first" return end
    oStatus.Text = "Sending..."
    task.spawn(function()
        local token = getOwnerToken()
        if not token then oStatus.Text = "Owner login failed" return end
        local ok, res = pcall(httpRequest, {
            Url = FIREBASE_URL .. "/announce.json?auth=" .. token,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                text = text:sub(1, 200),
                time = {[".sv"] = "timestamp"},
            }),
        })
        if ok and res and (res.StatusCode == 200 or res.Success) then
            oStatus.Text = "Announcement sent!"
            oBox.Text = ""
        else
            oStatus.Text = "Failed (check the rules)"
        end
    end)
end)
oSend.Size = UDim2.new(1, -12, 0, 28)
oSend.Position = UDim2.new(0, 6, 0, 86)
oSend.BackgroundColor3 = Color3.fromRGB(150, 110, 30)

local commandsOpen = makeButton(hub.body, "Commands", function() cmdWin.toggle() end)
commandsOpen.Size = UDim2.new(1, -16, 0, 30)
commandsOpen.Position = UDim2.new(0, 8, 0, 140)
commandsOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local settingsOpen = makeButton(hub.body, "Settings", function() settingsWin.toggle() end)
settingsOpen.Size = UDim2.new(1, -16, 0, 30)
settingsOpen.Position = UDim2.new(0, 8, 0, 174)
settingsOpen.BackgroundColor3 = Color3.fromRGB(90, 60, 140)

local ownerBtn = makeButton(hub.body, "Owner", function() ownerWin.toggle() end)
ownerBtn.Size = UDim2.new(1, -16, 0, 30)
ownerBtn.Position = UDim2.new(0, 8, 0, 208)
ownerBtn.BackgroundColor3 = Color3.fromRGB(150, 110, 30)
ownerBtn.Visible = false

-- The Owner + ANN buttons only appear after Firebase accepts your owner login
local ownerShown = false
local function showOwnerUI()
    if ownerShown then return end
    ownerShown = true
    ownerBtn.Visible = true
    hub.setHeight(278)

    -- Owner-only "announce" button inside the chat window
    local annBtn = makeButton(cbody, "ANN", function()
        if not ownerWin.frame.Visible then ownerWin.toggle() end
    end)
    annBtn.Size = UDim2.new(0, 34, 0, 16)
    annBtn.Position = UDim2.new(1, -100, 0, 2)
    annBtn.TextSize = 10
    annBtn.BackgroundColor3 = Color3.fromRGB(150, 110, 30)
end

-- Unlock from the Commands box:  owner <email> <password>
ownerLogin = function(email, pw, report)
    if not email or not pw then report("Usage: owner <email> <password>") return end
    if FIREBASE_URL == "" then report("Firebase is not set up") return end
    local oldE, oldP = OWNER_EMAIL, OWNER_PASSWORD
    OWNER_EMAIL, OWNER_PASSWORD = email, pw
    idToken = nil
    report("Logging in...")
    task.spawn(function()
        if getOwnerToken() then
            showOwnerUI()
            report("Owner unlocked")
        else
            OWNER_EMAIL, OWNER_PASSWORD = oldE, oldP
            report("Owner login failed")
        end
    end)
end

if FIREBASE_URL ~= "" then
    task.spawn(function()
        if getOwnerToken() then showOwnerUI() end
    end)
    startChat() -- start checking for announcements + chat right away
end

initSettings()
hub.toggle()
