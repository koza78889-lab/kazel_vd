-- GoatLose (v21 Engine Integrated) | Violence District
-- Integrated Visual Systems & Multi-Tab Configuration Infrastructure

Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
RunService = game:GetService("RunService")
UIS = game:GetService("UserInputService")
TweenService = game:GetService("TweenService")
Lighting = game:GetService("Lighting")
HttpService = game:GetService("HttpService")
VIM = game:GetService("VirtualInputManager")
RS = game:GetService("ReplicatedStorage")
LP = Players.LocalPlayer

BINDING = false
MENU_KEY = "RightShift"
GOAT_STARTED = false
goatMain = nil
math.randomseed(os.time())

-- ===== GLOBAL MOBILE / CURSOR STATE =====
MOBILE = false
pcall(function() MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled end)
EMOTE_WHEEL_OPEN = false
MOBILE_AIM_HOLD = false

-- ===================== GOATLOSE INTRO SPLASH =====================
local SPLASH_TIME = 10
local SPLASH_TRACKS = {
    {id="137501570448783", offset=2,  weight=2},
    {id="84788331299898",  offset=8,  weight=1},
    {id="101241740024903", offset=0,  weight=1},
    {id="859705272741266", offset=30, weight=1},
    {id="121176604894290", offset=11, weight=1},
    {id="122737382770761", offset=17, weight=1},
    {id="88926785631231",  offset=73, weight=1},
    {id="105000479529169", offset=0,  weight=1},
}
local function pickSplashTrack()
    local total = 0
    for _, t in ipairs(SPLASH_TRACKS) do total = total + (tonumber(t.weight) or 1) end
    local roll = math.random(total); local acc = 0
    for _, t in ipairs(SPLASH_TRACKS) do acc = acc + (tonumber(t.weight) or 1); if roll <= acc then return t end end
    return SPLASH_TRACKS[1]
end
local function PlaySplashMusic()
    local track = pickSplashTrack()
    local s = Instance.new("Sound"); s.Name = "GoatLoseSplashMusic"; s.SoundId = "rbxassetid://"..track.id; s.Volume = 0; s.TimePosition = track.offset
    s.Parent = Workspace.CurrentCamera or Workspace
    task.spawn(function()
        pcall(function() game:GetService("ContentProvider"):PreloadAsync({s}) end)
        pcall(function() s.TimePosition = track.offset end)
        pcall(function() s:Play(1,0.01,track.offset) end)
        pcall(function() TweenService:Create(s,TweenInfo.new(0.8,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Volume=0.55}):Play() end)
        task.delay(1.5,function() if s and s.Parent and not s.Playing then pcall(function() s.TimePosition=track.offset; s:Play(1,0.01,track.offset) end) end end)
        task.delay(3,function() if s and s.Parent and not s.Playing then pcall(function() s.TimePosition=0; s:Play(1,0.01,0) end) end end)
    end)
    return s
end
local function StopSplashMusic(s)
    if not s then return end
    pcall(function() TweenService:Create(s,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Volume=0}):Play() end)
    task.delay(0.55,function() pcall(function() s:Stop(); s:Destroy() end) end)
end
local function ShowSplash()
    local sg = Instance.new("ScreenGui"); sg.Name = "GoatLoseSplash"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
    pcall(function() sg.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = LP:WaitForChild("PlayerGui") end
    local bg = Instance.new("Frame",sg); bg.Size = UDim2.fromScale(1,1); bg.BackgroundColor3 = Color3.fromRGB(8,9,13); bg.BorderSizePixel = 0
    local logo = Instance.new("TextLabel",bg); logo.Size = UDim2.new(1,0,0,60); logo.Position = UDim2.new(0,0,0.5,-80); logo.BackgroundTransparency = 1; logo.Text = "GOATLOSE"; logo.Font = Enum.Font.GothamBlack; logo.TextSize = 42; logo.TextColor3 = Color3.fromRGB(0,255,200)
    local status = Instance.new("TextLabel",bg); status.Size = UDim2.new(1,0,0,20); status.Position = UDim2.new(0,0,0.5,-8); status.BackgroundTransparency = 1; status.Text = "initializing..."; status.Font = Enum.Font.Gotham; status.TextSize = 13; status.TextColor3 = Color3.fromRGB(150,156,170)
    local barBg = Instance.new("Frame",bg); barBg.Size = UDim2.new(0,320,0,6); barBg.Position = UDim2.new(0.5,-160,0.5,28); barBg.BackgroundColor3 = Color3.fromRGB(30,33,42); barBg.BorderSizePixel = 0
    local c1 = Instance.new("UICorner",barBg); c1.CornerRadius = UDim.new(0,3)
    local bar = Instance.new("Frame",barBg); bar.Size = UDim2.new(0,0,1,0); bar.BackgroundColor3 = Color3.fromRGB(0,255,200); bar.BorderSizePixel = 0
    local c2 = Instance.new("UICorner",bar); c2.CornerRadius = UDim.new(0,3)
    local pct = Instance.new("TextLabel",bg); pct.Size = UDim2.new(1,0,0,16); pct.Position = UDim2.new(0,0,0.5,42); pct.BackgroundTransparency = 1; pct.Text = "0%"; pct.Font = Enum.Font.GothamSemibold; pct.TextSize = 12; pct.TextColor3 = Color3.fromRGB(210,215,225)
    local music = PlaySplashMusic()
    local skipped = false
    local skipBtn = Instance.new("TextButton")
    skipBtn.Name = "SkipSplash"
    skipBtn.Size = UDim2.fromOffset(110, 32)
    skipBtn.Position = UDim2.new(0, 16, 1, -48)
    skipBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 34)
    skipBtn.Text = "SKIP"
    skipBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    skipBtn.Font = Enum.Font.GothamBold
    skipBtn.TextSize = 13
    skipBtn.Parent = bg
    Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 6)
    local sks = Instance.new("UIStroke", skipBtn)
    sks.Color = Color3.fromRGB(0, 255, 200)
    sks.Thickness = 1
    skipBtn.MouseButton1Click:Connect(function()
        skipped = true
    end)
    local steps = 100; local stepTime = SPLASH_TIME/steps
    local messages = {[1]="initializing...",[20]="loading assets...",[45]="preparing ui...",[70]="injecting hooks...",[92]="ready..."}
    for i = 1, steps do
        if skipped then break end
        local p = i/steps; bar.Size = UDim2.new(p,0,1,0); pct.Text = tostring(math.floor(p*100)).."%"
        if messages[i] then status.Text = messages[i] end
        task.wait(stepTime)
    end
    StopSplashMusic(music); task.wait(0.1); pcall(function() sg:Destroy() end)
end
ShowSplash()

-- ===================== BACKGROUND ENGINE =====================
local BG_GATE_ID = "97305033309089"
local BG_MENU_ID = ""
GATE_BG = nil; MAIN_BG = nil
local function setBgImage(img,id)
    if not img then return end
    local url = (type(id)=="string" and id~="") and ("rbxassetid://"..id) or ""
    img.Image = url; img.Visible = (url~="")
end
function ApplyBg() setBgImage(GATE_BG,BG_GATE_ID); setBgImage(MAIN_BG,BG_MENU_ID) end

-- ===================== KEY CACHE & AUTH SYSTEM =====================
local CACHE_FILE = "GoatLose_KeyCache.json"
local CURRENT_VER = "21"
local TTL = 24*3600
local function cacheSave(uname,key) pcall(function() if writefile then writefile(CACHE_FILE,HttpService:JSONEncode({username=uname,key=key,ver=CURRENT_VER,exp=os.time()+TTL})) end end) end
local function cacheLoad()
    if not (readfile and isfile and isfile(CACHE_FILE)) then return nil end
    local ok,d = pcall(function() return HttpService:JSONDecode(readfile(CACHE_FILE)) end)
    if ok and type(d)=="table" then return d end
    return nil
end
local function cacheAllow(uname)
    local d = cacheLoad(); if not d then return false end
    if d.username ~= uname then return false end
    if type(d.key) ~= "string" or #d.key == 0 then return false end
    if d.ver ~= CURRENT_VER then return false end
    if type(d.exp) ~= "number" or os.time() > d.exp then return false end
    return true
end
local MASTER_KEYS = { ["Kazel"]=true, ["kazel"]=true, ["ArtemFemboy"]=true, ["artemfemboy"]=true }

if not cacheAllow(LP.Name) then
    local KS_Gui = Instance.new("ScreenGui"); KS_Gui.Name = "GoatLoseKeyGui"; KS_Gui.ResetOnSpawn = false; KS_Gui.IgnoreGuiInset = true
    pcall(function() KS_Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
    if not KS_Gui.Parent then KS_Gui.Parent = LP:WaitForChild("PlayerGui") end
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0,320,0,200); Frame.Position = UDim2.new(0.5,-160,0.5,-100)
    Frame.BackgroundColor3 = Color3.fromRGB(15,23,42); Frame.BorderSizePixel = 0; Frame.ClipsDescendants = true; Frame.Parent = KS_Gui
    local FC = Instance.new("UICorner"); FC.CornerRadius = UDim.new(0,10); FC.Parent = Frame
    local FG = Instance.new("UIGradient"); FG.Rotation = 45
    FG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,255,200)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,23,42))}); FG.Parent = Frame
    GATE_BG = Instance.new("ImageLabel"); GATE_BG.Size = UDim2.new(1,0,1,0); GATE_BG.BackgroundTransparency = 1; GATE_BG.Image = ""; GATE_BG.ScaleType = Enum.ScaleType.Crop; GATE_BG.Transparency = 0.35; GATE_BG.ZIndex = 1; GATE_BG.Parent = Frame
    ApplyBg()
    local CloseButton = Instance.new("TextButton"); CloseButton.Text = "✕"; CloseButton.Font = Enum.Font.GothamBold; CloseButton.TextSize = 18; CloseButton.TextColor3 = Color3.fromRGB(255,255,255); CloseButton.BackgroundTransparency = 1; CloseButton.ZIndex = 3; CloseButton.Size = UDim2.new(0,28,0,28); CloseButton.Position = UDim2.new(1,-32,0,4); CloseButton.Parent = Frame
    local TitleLabel = Instance.new("TextLabel"); TitleLabel.Text = "GOATLOSE - Enter Key"; TitleLabel.Font = Enum.Font.GothamBold; TitleLabel.TextSize = 16; TitleLabel.TextColor3 = Color3.fromRGB(255,255,255); TitleLabel.TextStrokeTransparency = 0; TitleLabel.TextStrokeColor3 = Color3.fromRGB(10,20,30); TitleLabel.BackgroundTransparency = 1; TitleLabel.Size = UDim2.new(1,0,0,30); TitleLabel.Position = UDim2.new(0,0,0,12); TitleLabel.ZIndex = 2; TitleLabel.Parent = Frame
    local KeyBox = Instance.new("TextBox"); KeyBox.PlaceholderText = "Enter Access Key..."; KeyBox.Text = ""; KeyBox.Font = Enum.Font.Gotham; KeyBox.TextSize = 14; KeyBox.TextColor3 = Color3.fromRGB(255,255,255); KeyBox.PlaceholderColor3 = Color3.fromRGB(150,200,225); KeyBox.BackgroundColor3 = Color3.fromRGB(20,30,45); KeyBox.ZIndex = 2; KeyBox.Size = UDim2.new(1,-40,0,34); KeyBox.Position = UDim2.new(0,20,0,52); KeyBox.ClearTextOnFocus = false; KeyBox.Parent = Frame
    local KC = Instance.new("UICorner"); KC.CornerRadius = UDim.new(0,6); KC.Parent = KeyBox
    local StatusLabel = Instance.new("TextLabel"); StatusLabel.Text = ""; StatusLabel.Font = Enum.Font.Gotham; StatusLabel.TextSize = 12; StatusLabel.TextColor3 = Color3.fromRGB(255,255,255); StatusLabel.TextStrokeTransparency = 0; StatusLabel.TextStrokeColor3 = Color3.fromRGB(10,20,30); StatusLabel.BackgroundTransparency = 1; StatusLabel.Size = UDim2.new(1,-40,0,36); StatusLabel.Position = UDim2.new(0,20,0,92); StatusLabel.TextWrapped = true; StatusLabel.ZIndex = 2; StatusLabel.Parent = Frame
    local LoginButton = Instance.new("TextButton"); LoginButton.Text = "LOGIN"; LoginButton.Font = Enum.Font.GothamBold; LoginButton.TextSize = 15; LoginButton.TextColor3 = Color3.fromRGB(15,23,42); LoginButton.BackgroundColor3 = Color3.fromRGB(0,255,200); LoginButton.ZIndex = 2; LoginButton.Size = UDim2.new(1,-40,0,36); LoginButton.Position = UDim2.new(0,20,0,148); LoginButton.Parent = Frame
    local LC = Instance.new("UICorner"); LC.CornerRadius = UDim.new(0,6); LC.Parent = LoginButton
    CloseButton.Activated:Connect(function() KS_Gui:Destroy() end)
    LoginButton.Activated:Connect(function()
        local key = KeyBox.Text:gsub("^%s+",""):gsub("%s+$","")
        if key == "" then StatusLabel.TextColor3 = Color3.fromRGB(255,210,210); StatusLabel.Text = "Please enter a key"; return end
        if MASTER_KEYS[key] then
            cacheSave(LP.Name,key); StatusLabel.TextColor3 = Color3.fromRGB(255,255,255); StatusLabel.Text = "Success! (master)"
            task.wait(0.3); pcall(function() KS_Gui:Destroy() end); if not GOAT_STARTED then task.defer(function() if type(goatMain)=="function" then goatMain() end end) end; return
        end
        StatusLabel.TextColor3 = Color3.fromRGB(255,255,255); StatusLabel.Text = "Checking..."
        local settled = false
        local function succeed() if settled then return end settled = true; cacheSave(LP.Name,key); StatusLabel.TextColor3 = Color3.fromRGB(255,255,255); StatusLabel.Text = "Success!"; task.wait(0.4); pcall(function() KS_Gui:Destroy() end); if not GOAT_STARTED then task.defer(function() if type(goatMain)=="function" then goatMain() end end) end end
        local function fail(m) if settled then return end settled = true; StatusLabel.TextColor3 = Color3.fromRGB(255,200,200); StatusLabel.Text = m end
        task.spawn(function() task.wait(15); if not settled then fail("Timed Out, try using VPN") end end)
        task.spawn(function()
            local success,response = pcall(function() return HttpService:RequestAsync({Url="https://solyariy.devrobloxnoob.workers.dev/validate",Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode({key=key,username=LP.Name})}) end)
            if settled then return end
            if not success then fail("Network error"); return end
            local code = response.StatusCode
            if code >= 500 then fail("Server down, try later"); return end
            local dok,decoded = pcall(function() return HttpService:JSONDecode(response.Body) end)
            if not dok then fail("Bad server reply"); return end
            if code == 200 and decoded and decoded.valid then succeed() else fail((decoded and decoded.message) or "Invalid key") end
        end)
    end)
else
    task.defer(function() if type(goatMain)=="function" then goatMain() end end)
end

goatMain = function()
if GOAT_STARTED then return end
-- destroy previous UI if re-injected
pcall(function()
	local parent = (gethui and gethui()) or game:GetService("CoreGui")
	local oldUi = parent:FindFirstChild("GoatLoseUI")
	if oldUi then
		oldUi:Destroy()
		-- will fire AncestryChanged notify
	end
end)
GOAT_STARTED = true

-- ===== GOATLOSE THEME COLORS =====
C_BG = Color3.fromRGB(15,23,42)
C_SIDE = Color3.fromRGB(11,17,32)
C_BOX = Color3.fromRGB(20,30,50)
C_ROW = Color3.fromRGB(26,38,62)
C_ACC = Color3.fromRGB(0,255,200)
C_TXT = Color3.fromRGB(240,245,255)
C_DIM = Color3.fromRGB(130,145,170)

Gui = Instance.new("ScreenGui"); Gui.Name = "GoatLoseUI"; Gui.ResetOnSpawn = false; Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function GoatNotifyClosed()
	pcall(function()
		local parent = (gethui and gethui()) or game:GetService("CoreGui")
		local old = parent:FindFirstChild("GoatLoseClosedNotify")
		if old then old:Destroy() end
		local sg = Instance.new("ScreenGui")
		sg.Name = "GoatLoseClosedNotify"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 99999
		sg.Parent = parent
		local f = Instance.new("Frame")
		f.Size = UDim2.new(0, 320, 0, 56)
		f.Position = UDim2.new(0.5, -160, 0.08, 0)
		f.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
		f.BorderSizePixel = 0
		f.Parent = sg
		local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 10); c.Parent = f
		local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(0, 255, 200); s.Thickness = 1.5; s.Parent = f
		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1, -16, 1, 0)
		lab.Position = UDim2.new(0, 8, 0, 0)
		lab.BackgroundTransparency = 1
		lab.Text = "GoatLose — скрипт остановлен / закрыт"
		lab.Font = Enum.Font.GothamBold
		lab.TextSize = 15
		lab.TextColor3 = Color3.fromRGB(0, 255, 200)
		lab.Parent = f
		task.delay(3.5, function()
			pcall(function() sg:Destroy() end)
		end)
	end)
end

_G.GoatLoseUnload = function()
	pcall(function()
		GOAT_STARTED = false
		if MUSIC and MUSIC.Cleanup then MUSIC.Cleanup() end
		if XIVIVIDE and XIVIVIDE.Cleanup then XIVIVIDE.Cleanup() end
		if Gui then Gui:Destroy() end
	end)
	GoatNotifyClosed()
end

Gui.AncestryChanged:Connect(function(_, parent)
	if parent == nil then
		GOAT_STARTED = false
		GoatNotifyClosed()
	end
end)

pcall(function() Gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

function N(c,p,pr) local o = Instance.new(c) for k,v in pairs(pr or {}) do o[k] = v end o.Parent = p return o end
function corner(p,r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0,r or 6); c.Parent = p return c end

Main = N("Frame",Gui,{Size=UDim2.fromOffset(640,440),Position=UDim2.new(0.5,-320,0.5,-220),BackgroundColor3=C_BG,BorderSizePixel=0,Active=true,Draggable=true,ClipsDescendants=true,Visible=true})
corner(Main,10)
MAIN_BG = N("ImageLabel",Main,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,Transparency=0.45,ZIndex=1}); corner(MAIN_BG,10)
ApplyBg()

Top = N("Frame",Main,{Size=UDim2.new(1,0,0,40),BackgroundColor3=C_SIDE,BorderSizePixel=0,ZIndex=2}); corner(Top,10)
N("TextLabel",Top,{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="GOATLOSE MENU",Font=Enum.Font.GothamBlack,TextSize=15,TextColor3=C_ACC,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3})
N("TextLabel",Top,{Size=UDim2.new(0.5,-12,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,Text="Menu Key / Esc",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3})

Side = N("Frame",Main,{Size=UDim2.new(0,140,1,-40),Position=UDim2.new(0,0,0,40),BackgroundColor3=C_SIDE,BorderSizePixel=0,ZIndex=2}); corner(Side,10)
TabList = N("Frame",Side,{Size=UDim2.new(1,-14,1,-14),Position=UDim2.new(0,7,0,7),BackgroundTransparency=1,ZIndex=3})
N("UIListLayout",TabList,{Padding=UDim.new(0,5)})
Content = N("Frame",Main,{Size=UDim2.new(1,-140,1,-40),Position=UDim2.new(0,140,0,40),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2})

-- ===== MOBILE RESIZE =====
if MOBILE then
	local cam = Workspace.CurrentCamera
	local vw = cam and cam.ViewportSize.X or 800
	local vh = cam and cam.ViewportSize.Y or 600
	local w = math.clamp(math.floor(vw*0.88),280,390)
	local h = math.clamp(math.floor(vh*0.70),300,430)
	Main.Size = UDim2.fromOffset(w,h); Main.Position = UDim2.new(0.5,-w/2,0.5,-h/2)
	Top.Size = UDim2.new(1,0,0,36); Side.Size = UDim2.new(0,108,1,-36)
	Content.Position = UDim2.new(0,108,0,36); Content.Size = UDim2.new(1,-108,1,-36)
	for _,ch in ipairs(Top:GetChildren()) do
		if ch:IsA("TextLabel") and ch.Text:find("Menu Key") then ch.Visible = false end
	end
end

pages = {}; tabBtns = {}
function SelectTab(n) 
	for k,p in pairs(pages) do p.Scroll.Visible = (k==n) end 
	for k,b in pairs(tabBtns) do 
		if k==n then 
			b.L.TextColor3 = Color3.fromRGB(255,255,255)
			b.B.BackgroundColor3 = C_BOX 
		else 
			b.L.TextColor3 = C_DIM
			b.B.BackgroundColor3 = C_SIDE 
		end 
	end 
end

-- ===================== CONFIG REGISTRY =====================
CFG_CONTROLS = {}; CFG_USED_KEYS = {}
CFG_FOLDER = "GoatLose"
CFG_INDEX_FILE = "GoatLose/_index.json"
CFG_SELECTED = ""

BUILTIN_CONFIGS = {
	["From Dev - Legit"] = [[{"Emote Anim":"Dagger","Fake Parry Emote":true,"Remove World Fog":false,"TP Random Survivor":"None","Hat Color":[255,0,255],"Auto SkillCheck Keybind":"None","Auto SkillCheck":true,"China Hat":true,"Hide Default Nametags":false,"God Mode Client Override":false,"Window Vault Teleport":"None","Crosshair Style":"Classic","Parry Range Circle":true,"Spear Speed":150,"Killer Light Color":[255,0,255],"Auto Dagger":true,"Instant Heal":false,"Custom FOV Enabled":true,"Vivid Preset Engine":false,"Speed Multiplier":1.69,"Gen Buff Keybind":"H","Spear Gravity":98,"Pallet Vacuum (highlight near)":false,"Fly Keybind":"None","Drochka Animation Loop":false,"Crosshair Color":[183.28125,0,255],"No Attack CD Keybind":"None","Depth Of Field":false,"GL_NameChangerText":"GoatLose","GL_NameChangerOn":false,"Moonwalk Engine":false,"Save Teammate Keybind":"Six","Player Highlights":true,"Moonwalk Keybind":"None","Speedboost":false,"Silent Spear Fire":false,"Ghost Always On Top":true,"CS2 Box & Skeleton ESP":true,"Desync Movement":false,"Auto Crouch":false,"Noclip Keybind":"None","Manual Heal Keybind":"Four","Attack Spam Rate":0.04,"Aim Smoothness":0.18,"Desync Keybind":"Five","Circle Color":[94.48661148548126,0,255],"Speedboost Keybind":"L","Veil Spear Aimbot":false,"Vault Search Range":14,"No Slowdown":false,"Priority":"Nearest","CS2 Color":[0,255,0],"Killer Color":[255,0,0],"Ghost Transparency":0.45,"GL_OutfitUser":"","Instant SkillCheck":true,"Click TP Snap Floor":true,"Fill Highlights":true,"Animation Speed Multiplier":2.5,"Pallet Color":[127.00000002980232,0,255],"Auto Dagger Range":12,"Aimbot FOV":180,"Emote Wheel":true,"Ghost Color":[0,255,200.00000327825546],"Atmosphere Cycle":"Void","DBD Status Icons":true,"Noclip":false,"Generator Color":[0,255,255],"Instant Heal Keybind":"None","Name Changer Loop":false,"Veil Aimbot Keybind":"None","Auto Dagger Keybind":"None","Pallet Vacuum Keybind":"Three","Name Preset":"GoatLose","Camera Field Of View":118.42794759825327,"Click TP Through Walls":true,"Pallet ESP":false,"Generator ESP":false,"Instant SkillCheck Keybind":"None","Killer Light Color Fix":true,"No Attack Cooldown":true,"RTX Visual Enhancements":true,"Fake Parry Keybind":"One","Fill Color":[255,0,0],"Fly System":false,"Show Crosshair":true,"Prediction Offset":0.05,"Lighting Presets":"Default","Aimbot Hold Key":"MouseButton2","Menu Toggle Key":"RightShift","Rainbow Highlight":false,"Save Teammate Range":80,"Desync Ghost":true,"Crosshair Scale":4,"Click Teleport Key":"T","Emote Wheel Key":"B","Survivor Color":[0,255,0],"Pallet Vacuum Range":12,"Auto Unhook Keybind":"None","Click TP Max Dist":50,"Target Part":"UpperTorso"}]],
	["От разраба - Legit"] = [[{"Emote Anim":"Dagger","Fake Parry Emote":true,"Remove World Fog":false,"TP Random Survivor":"None","Hat Color":[255,0,255],"Auto SkillCheck Keybind":"None","Auto SkillCheck":true,"China Hat":true,"Hide Default Nametags":false,"God Mode Client Override":false,"Window Vault Teleport":"None","Crosshair Style":"Classic","Parry Range Circle":true,"Spear Speed":150,"Killer Light Color":[255,0,255],"Auto Dagger":true,"Instant Heal":false,"Custom FOV Enabled":true,"Vivid Preset Engine":false,"Speed Multiplier":1.69,"Gen Buff Keybind":"H","Spear Gravity":98,"Pallet Vacuum (highlight near)":false,"Fly Keybind":"None","Drochka Animation Loop":false,"Crosshair Color":[183.28125,0,255],"No Attack CD Keybind":"None","Depth Of Field":false,"GL_NameChangerText":"GoatLose","GL_NameChangerOn":false,"Moonwalk Engine":false,"Save Teammate Keybind":"Six","Player Highlights":true,"Moonwalk Keybind":"None","Speedboost":false,"Silent Spear Fire":false,"Ghost Always On Top":true,"CS2 Box & Skeleton ESP":true,"Desync Movement":false,"Auto Crouch":false,"Noclip Keybind":"None","Manual Heal Keybind":"Four","Attack Spam Rate":0.04,"Aim Smoothness":0.18,"Desync Keybind":"Five","Circle Color":[94.48661148548126,0,255],"Speedboost Keybind":"L","Veil Spear Aimbot":false,"Vault Search Range":14,"No Slowdown":false,"Priority":"Nearest","CS2 Color":[0,255,0],"Killer Color":[255,0,0],"Ghost Transparency":0.45,"GL_OutfitUser":"","Instant SkillCheck":true,"Click TP Snap Floor":true,"Fill Highlights":true,"Animation Speed Multiplier":2.5,"Pallet Color":[127.00000002980232,0,255],"Auto Dagger Range":12,"Aimbot FOV":180,"Emote Wheel":true,"Ghost Color":[0,255,200.00000327825546],"Atmosphere Cycle":"Void","DBD Status Icons":true,"Noclip":false,"Generator Color":[0,255,255],"Instant Heal Keybind":"None","Name Changer Loop":false,"Veil Aimbot Keybind":"None","Auto Dagger Keybind":"None","Pallet Vacuum Keybind":"Three","Name Preset":"GoatLose","Camera Field Of View":118.42794759825327,"Click TP Through Walls":true,"Pallet ESP":false,"Generator ESP":false,"Instant SkillCheck Keybind":"None","Killer Light Color Fix":true,"No Attack Cooldown":true,"RTX Visual Enhancements":true,"Fake Parry Keybind":"One","Fill Color":[255,0,0],"Fly System":false,"Show Crosshair":true,"Prediction Offset":0.05,"Lighting Presets":"Default","Aimbot Hold Key":"MouseButton2","Menu Toggle Key":"RightShift","Rainbow Highlight":false,"Save Teammate Range":80,"Desync Ghost":true,"Crosshair Scale":4,"Click Teleport Key":"T","Emote Wheel Key":"B","Survivor Color":[0,255,0],"Pallet Vacuum Range":12,"Auto Unhook Keybind":"None","Click TP Max Dist":50,"Target Part":"UpperTorso"}]],
}


local function cfgKey(title)
	local base = tostring(title or "control"); local key = base; local n = 1
	while CFG_USED_KEYS[key] do n = n + 1; key = base.." ("..n..")" end
	CFG_USED_KEYS[key] = true; return key
end

local function safeCfgName(n)
	n = tostring(n or ""); n = n:match("([^/\\]+)$") or n; n = n:gsub("%.json$",""); n = n:gsub("^%s+",""):gsub("%s+$",""); n = n:gsub('[/\\:%*%?"<>|]','_')
	if n == "" then n = "config" end; return n:sub(1,40)
end

local function ensureCfgFolder() pcall(function() if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end) end
local function cfgPath(name) return CFG_FOLDER.."/"..safeCfgName(name)..".json" end

local function loadCfgIndex()
	local out = {}; local set = {}
	pcall(function()
		if readfile and isfile and isfile(CFG_INDEX_FILE) then
			local d = HttpService:JSONDecode(readfile(CFG_INDEX_FILE)); local arr = nil
			if type(d)=="table" then if type(d.names)=="table" then arr = d.names elseif #d>0 then arr = d end end
			if type(arr)=="table" then for _,v in ipairs(arr) do local n = safeCfgName(v); if n~="" and not set[n] then set[n] = true; table.insert(out,n) end end end
		end
	end)
	return out
end

local function saveCfgIndex(names) ensureCfgFolder(); pcall(function() if writefile then writefile(CFG_INDEX_FILE,HttpService:JSONEncode({names=names or {}})) end end) end
local function addCfgIndex(name) name = safeCfgName(name); local list = loadCfgIndex(); local set = {} for _,v in ipairs(list) do set[v] = true end if not set[name] then table.insert(list,name) end table.sort(list); saveCfgIndex(list) end
local function removeCfgIndex(name) name = safeCfgName(name); local list = loadCfgIndex(); local out = {} for _,v in ipairs(list) do if v~=name then table.insert(out,v) end end saveCfgIndex(out) end

local function getConfigNames()
	local list = {}; local set = {}
	local function push(n) n = safeCfgName(n); if n~="" and n~="_index" and not set[n] then set[n] = true; table.insert(list,n) end end
	for _,n in ipairs(loadCfgIndex()) do push(n) end
	pcall(function() if type(listfiles)=="function" then local files = listfiles(CFG_FOLDER); if type(files)=="table" then for _,f in ipairs(files) do local bn = tostring(f):match("([^/\\]+)$") or tostring(f); local nm = bn:gsub("%.json$",""); if nm~="_index" then push(nm) end end end end end)
	table.sort(list); return list,set
end

local function nextAutoCfgName() local list,set = getConfigNames(); for i = 1, 999 do local n = "GoatLoseCfg"..i; if not set[n] then return n end end; return "GoatLoseCfg"..tostring(math.floor(os.time())) end

-- ===================== UI FACTORIES =====================
function AddTab(n)
	local b = N("TextButton",TabList,{Size=UDim2.new(1,0,0,32),BackgroundColor3=C_SIDE,AutoButtonColor=false,Text="",ZIndex=4}); corner(b,7)
	local l = N("TextLabel",b,{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=n,Font=Enum.Font.GothamSemibold,TextSize=13,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
	local sc = N("ScrollingFrame",Content,{Size=UDim2.new(1,-14,1,-14),Position=UDim2.new(0,7,0,7),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=3})
	N("UIListLayout",sc,{Padding=UDim.new(0,9)})
	pages[n] = {Scroll=sc}; tabBtns[n] = {B=b,L=l}
	b.Activated:Connect(function() SelectTab(n) end)
	return sc
end

function AddSection(ps,t)
	local box = N("Frame",ps,{Size=UDim2.new(1,0,0,32),BackgroundColor3=C_BOX,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4}); corner(box,8)
	N("TextLabel",box,{Size=UDim2.new(1,-14,0,28),Position=UDim2.new(0,10,0,2),BackgroundTransparency=1,Text=t,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
	local rows = N("Frame",box,{Size=UDim2.new(1,-10,0,5),Position=UDim2.new(0,5,0,30),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5})
	N("UIListLayout",rows,{Padding=UDim.new(0,4)}); N("UIPadding",rows,{PaddingBottom=UDim.new(0,7)})
	return rows
end

function AddToggle(p,t,d,cb)
	local row = N("TextButton",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,AutoButtonColor=false,Text="",ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local tr = N("Frame",row,{Size=UDim2.fromOffset(32,17),Position=UDim2.new(1,-41,0.5,-8),BackgroundColor3=Color3.fromRGB(45,50,62),BorderSizePixel=0,ZIndex=7}); corner(tr,8)
	local kn = N("Frame",tr,{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=Color3.fromRGB(150,156,170),BorderSizePixel=0,ZIndex=8}); corner(kn,6)
	local on = false
	local function set(v) on = v; tr.BackgroundColor3 = v and C_ACC or Color3.fromRGB(45,50,62); kn.Position = v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6); kn.BackgroundColor3 = v and Color3.fromRGB(15,23,42) or Color3.fromRGB(150,156,170); pcall(cb,v) end
	CFG_CONTROLS[cfgKey(t)] = {type="toggle",set=set,get=function() return on end}
	row.Activated:Connect(function() set(not on) end)
	set(on)
	return {Set=set,Get=function() return on end}
end

function AddSlider(p,t,mn,mx,d,dec,cb,reg)
	reg = reg ~= false
	local row = N("Frame",p,{Size=UDim2.new(1,0,0,34),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(0.6,-9,0,15),Position=UDim2.new(0,9,0,3),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local val = N("TextLabel",row,{Size=UDim2.new(0.4,-9,0,15),Position=UDim2.new(0.6,0,0,3),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=7})
	local tr = N("Frame",row,{Size=UDim2.new(1,-18,0,4),Position=UDim2.new(0,9,0,24),BackgroundColor3=Color3.fromRGB(45,50,62),BorderSizePixel=0,ZIndex=7}); corner(tr,2)
	local fl = N("Frame",tr,{Size=UDim2.new(0.5,0,1,0),BackgroundColor3=C_ACC,BorderSizePixel=0,ZIndex=8}); corner(fl,2)
	local kn = N("Frame",tr,{Size=UDim2.fromOffset(9,9),Position=UDim2.new(0.5,-4,0.5,-4),BackgroundColor3=Color3.fromRGB(235,238,245),BorderSizePixel=0,ZIndex=9}); corner(kn,4)
	local value = d; local drag = false
	local function ap(f) f = math.clamp(f,0,1); value = mn+(mx-mn)*f; if dec and dec>0 then local pw = 10^dec value = math.floor(value*pw+0.5)/pw end; fl.Size = UDim2.new(f,0,1,0); kn.Position = UDim2.new(f,-4,0.5,-4); val.Text = tostring(value); pcall(cb,value) end
	local function isDown(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
	local function isMove(i) return i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch end
	local function isEnd(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
	local hit = N("TextButton",row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10,Active=true})
	hit.InputBegan:Connect(function(i) if isDown(i) then drag = true; local dn = tr.AbsoluteSize.X; if dn<=0 then dn = 1 end; ap((i.Position.X-tr.AbsolutePosition.X)/dn) end end)
	UIS.InputChanged:Connect(function(i) if drag and isMove(i) then local dn = tr.AbsoluteSize.X; if dn<=0 then dn = 1 end; ap((i.Position.X-tr.AbsolutePosition.X)/dn) end end)
	UIS.InputEnded:Connect(function(i) if drag and isEnd(i) then drag = false end end)
	local api = {Set=function(v) ap((v-mn)/(mx-mn)) end,Get=function() return value end}
	if reg then CFG_CONTROLS[cfgKey(t)] = {type="slider",set=api.Set,get=api.Get} end
	ap((d-mn)/(mx-mn))
	return api
end

function AddColor(p,t,d,cb)
	local holder = N("Frame",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=6}); corner(holder,6)
	local row = N("TextButton",holder,{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,AutoButtonColor=false,Text="",ZIndex=7})
	N("TextLabel",row,{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8})
	local pv = N("Frame",row,{Size=UDim2.fromOffset(32,13),Position=UDim2.new(1,-41,0.5,-6),BackgroundColor3=d,BorderSizePixel=0,ZIndex=8}); corner(pv,4)
	local ex = N("Frame",holder,{Size=UDim2.new(1,-10,0,0),Position=UDim2.new(0,5,0,28),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=8})
	N("UIListLayout",ex,{Padding=UDim.new(0,3)}); N("UIPadding",ex,{PaddingBottom=UDim.new(0,5)})
	local cur = {r=d.R*255,g=d.G*255,b=d.B*255}
	local function live() local c = Color3.fromRGB(cur.r,cur.g,cur.b); pv.BackgroundColor3 = c; pcall(cb,c) end
	AddSlider(ex,"R",0,255,cur.r,0,function(v) cur.r=v; live() end,false)
	AddSlider(ex,"G",0,255,cur.g,0,function(v) cur.g=v; live() end,false)
	AddSlider(ex,"B",0,255,cur.b,0,function(v) cur.b=v; live() end,false)
	local api = {Get=function() return {cur.r,cur.g,cur.b} end,Set=function(c) if typeof(c)=="Color3" then cur.r=c.R*255; cur.g=c.G*255; cur.b=c.B*255 elseif type(c)=="table" then cur.r=c[1] or 0; cur.g=c[2] or 0; cur.b=c[3] or 0 end; live() end}
	CFG_CONTROLS[cfgKey(t)] = {type="color",set=function(v) if typeof(v)=="Color3" then api.Set(v) elseif type(v)=="table" then api.Set(Color3.fromRGB(v[1] or 0,v[2] or 0,v[3] or 0)) end end,get=function() return api.Get() end}
	row.Activated:Connect(function() ex.Visible = not ex.Visible end)
	return api
end

function AddKeybind(p,t,dk,op)
	local row = N("Frame",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-76,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local bw = MOBILE and 46 or 60
	local bx = N("TextButton",row,{Size=UDim2.fromOffset(bw,17),Position=UDim2.new(1,-(bw+8),0.5,-8),BackgroundColor3=MOBILE and C_ACC or Color3.fromRGB(20,23,30),AutoButtonColor=false,Font=Enum.Font.GothamSemibold,TextSize=10,TextColor3=MOBILE and Color3.fromRGB(10,12,16) or C_DIM,ZIndex=7}); corner(bx,5)
	local cur = dk; local lis = false; local lw = 0
	local function lb() if cur=="None" then bx.Text="[None]" else bx.Text="["..cur.."]" end; bx.TextColor3 = C_DIM end
	local function lbMobile() if cur=="None" or cur=="MWheel" then bx.Text="TAP" else bx.Text=cur:sub(1,4) end end
	local function setKey(k) if type(k)=="string" and k~="" then cur = k else cur = "None" end; if MOBILE then lbMobile() else lb() end end
	if MOBILE then
		lbMobile(); bx.Activated:Connect(function() pcall(op) end)
	else
		lb(); bx.Activated:Connect(function() lis = true; BINDING = true; bx.Text = "[...]"; bx.TextColor3 = C_ACC end)
		UIS.InputBegan:Connect(function(i,gp)
			if lis then lis = false; BINDING = false; if i.KeyCode==Enum.KeyCode.Escape then cur = "None"; lb(); return end; if i.KeyCode~=Enum.KeyCode.Unknown then cur = i.KeyCode.Name; lb() end; return end
			if gp then return end
			if cur~="None" and cur~="MWheel" and i.KeyCode.Name==cur then pcall(op) end
		end)
		UIS.InputChanged:Connect(function(i,gp)
			if gp then return end
			if lis and i.UserInputType==Enum.UserInputType.MouseWheel then lis = false; BINDING = false; cur = "MWheel"; lb(); return end
			if cur=="MWheel" and i.Position.Z>0 and tick()-lw>0.2 then lw = tick(); pcall(op) end
		end)
	end
	CFG_CONTROLS[cfgKey(t)] = {type="keybind",set=setKey,get=function() return cur end}
	return {Get=function() return cur end,Set=setKey}
end

function AddDropdown(p,t,vals,def,cb)
	local row = N("Frame",p,{Size=UDim2.new(1,0,0,52),BackgroundColor3=C_ROW,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-18,0,16),Position=UDim2.new(0,9,0,3),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local list = N("Frame",row,{Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,9,0,21),BackgroundColor3=Color3.fromRGB(20,23,30),BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=7}); corner(list,4)
	N("UIListLayout",list,{Padding=UDim.new(0,2)}); N("UIPadding",list,{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)})
	local cur = def
	local function setValue(v) cur = v; for _,o in ipairs(list:GetChildren()) do if o:IsA("TextButton") then o.TextColor3 = (o.Text==v) and C_ACC or C_DIM end end; pcall(cb,v) end
	for _,v in ipairs(vals) do
		local b = N("TextButton",list,{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=v,Font=Enum.Font.Gotham,TextSize=11,TextColor3=(v==def) and C_ACC or C_DIM,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=8})
		b.Activated:Connect(function() setValue(v) end)
	end
	CFG_CONTROLS[cfgKey(t)] = {type="dropdown",set=setValue,get=function() return cur end}
	return {Get=function() return cur end,Set=setValue}
end

function AddButton(p,t,cb)
	local b = N("TextButton",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,AutoButtonColor=false,Text=t,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=C_TXT,ZIndex=6}); corner(b,6)
	b.Activated:Connect(function() pcall(cb) end)
	return b
end

function AddLabel(p,t)
	local l = N("TextLabel",p,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=10,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
	return {Set=function(s) l.Text = s end}
end

-- ===================== UTILITY & GAME LOGIC FUNCTIONS =====================
function GetRoot(c) if not c then return nil end return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
function GetHum(c) if not c then return nil end return c:FindFirstChildOfClass("Humanoid") end
function IsKiller(p) if not p or not p.Character then return false end local n = p.Name:lower() if n:find("killer") or n:find("hunter") or n:find("murderer") or n:find("slasher") then return true end for _,w in ipairs({"Knife","Axe","Sword","Parrying Dagger","Machete","Bat","Weapon"}) do if p.Character:FindFirstChild(w) or p.Character:FindFirstChild(w:lower()) then return true end end local a,b = 0,0 for _,v in pairs(p.Character:GetDescendants()) do if v:IsA("BasePart") then a = a + 1 if v.Color.R<0.3 and v.Color.G<0.3 and v.Color.B<0.3 then b = b + 1 end end end return a>0 and b/a>0.5 end
function IsSurv() local t = LP.Team if not t then return false end local n = t.Name:lower() return n:find("survivor")~=nil or n=="survivors" or n=="survivor" end
function IsLocalKiller()
	-- team name
	local t = LP.Team
	if t then
		local n = t.Name:lower()
		if n:find("killer") or n:find("hunter") or n:find("murderer") or n:find("slasher") or n:find("maniac") then
			return true
		end
	end
	-- attributes
	local a = LP:GetAttribute("IsKiller")
	if a == true then return true end
	local c = LP.Character
	if c then
		if c:GetAttribute("IsKiller") == true then return true end
		-- tools typical for killer
		for _,w in ipairs({"Knife","Axe","Sword","Parrying Dagger","Machete","Bat","Weapon","Spear","Veil"}) do
			if c:FindFirstChild(w) then return true end
		end
	end
	return false
end
function IsSpectator()
	local t = LP.Team
	if not t then return true end -- no team often = lobby/spec
	local n = t.Name:lower()
	if n:find("spect") or n:find("lobby") or n:find("observer") then return true end
	return false
end
function CanUseOutfitChanger()
	-- visible/custom outfit only as survivor or spectator (not killer)
	if IsLocalKiller() then return false end
	return true
end
function PressSpace() pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) end) task.wait(0.02) pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end) end
function httpGetBody(u)
	if type(request)=="function" then local o,r = pcall(request,{Url=u,Method="GET"}); if o and r and r.Body then return r.Body end end
	if type(http_request)=="function" then local o,r = pcall(http_request,{Url=u,Method="GET"}); if o and r and r.Body then return r.Body end end
	local o,r = pcall(function() return game:HttpGet(u) end); if o and r then return r end
	return nil
end
function GetNum(pl,key,def) local v = pl:GetAttribute(key) if typeof(v)=="number" then return v end if pl.Character then local c = pl.Character:GetAttribute(key) if typeof(c)=="number" then return c end end return def end
function GetStr(pl,key,def) local v = pl:GetAttribute(key) if typeof(v)=="string" and v~="" then return v end return def end

-- ===================== STATE DICTIONARY =====================
S = {
ESP = {On=false,Surv=Color3.fromRGB(0,255,0),Kill=Color3.fromRGB(255,0,0),Fill=false,FillColor=Color3.fromRGB(255,0,0),CS2=false,CS2C=Color3.fromRGB(0,255,0),Gen=false,Pallet=false,GenC=Color3.fromRGB(0,255,255),PalC=Color3.fromRGB(127,0,255)},
Parry = {Range=10,Anim=1}, CTP = {On=false,Dist=50,SnapGround=true,ThroughWalls=true}, BW = {Range=14}, Droch = {Speed=2.5},
China = {Color=Color3.fromRGB(255,0,255)}, PC = {Color=Color3.fromRGB(0,255,80)}, Tint = {On=false,R=255,G=200,B=200,Br=1},
KL = {Color=Color3.fromRGB(255,255,0)}, Traj = {Color=Color3.fromRGB(0,240,255)},
VS = {RTX=false,DOF=false,Tint="Default",Preset="Default",Sat=0.55,Con=-0.35,Atmo=0.3,Fog=false,FogColor=Color3.fromRGB(120,160,200),FogStart=0,FogEnd=100000,NoFog=true,Light=false,LightColor=Color3.fromRGB(255,255,255),Time="Default",ClockTime=14.5,Bloom=false,BloomI=0,BloomS=24,BloomT=0.85,SunRays=true,SunI=0.45,SunSpread=0.7,FOV=70,Crosshair=false,CrossStyle="Classic",CrossColor=Color3.fromRGB(0,255,255),CrossSize=10,Vivid=true},
On = {},
}

-- ===================== VISUAL & GAME SYSTEMS =====================
function RefreshESP()
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character then
			local hl = pl.Character:FindFirstChild("GoatLoseESP")
			if S.ESP.On then
				if not hl then hl = Instance.new("Highlight"); hl.Name = "GoatLoseESP"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = pl.Character end
				local ik = IsKiller(pl)
				if ik and S.ESP.Fill then hl.FillTransparency = 0.5; hl.FillColor = S.ESP.FillColor else hl.FillTransparency = 1 end
				hl.OutlineColor = ik and S.ESP.Kill or S.ESP.Surv
			elseif hl then hl:Destroy() end
		end
	end
end

function RefreshObjESP()
	for _,d in ipairs(Workspace:GetDescendants()) do
		local isGen = (d.Name:lower():find("generator")~=nil) and (d:IsA("Model") or d:IsA("BasePart"))
		local isPal = d.Name=="Palletwrong"
		if isGen or isPal then
			local hl = d:FindFirstChild("GoatLoseObj")
			local want = (isGen and S.ESP.Gen) or (isPal and S.ESP.Pallet)
			if want then
				if not hl then hl = Instance.new("Highlight"); hl.Name = "GoatLoseObj"; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = d end
				hl.FillColor = isGen and S.ESP.GenC or S.ESP.PalC; hl.OutlineColor = hl.FillColor; hl.FillTransparency = 0.5
			elseif hl then hl:Destroy() end
		end
	end
end
task.spawn(function() while true do task.wait(2) if S.ESP.On then RefreshESP() end if S.ESP.Gen or S.ESP.Pallet then RefreshObjESP() end end end)
Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function() task.wait(0.5) RefreshESP() end) end)

CS2 = {P={},C=nil}
BONES_R15 = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
}
BONES_R6 = {
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}
}

local function CS2Ensure(pl)
	local e = CS2.P[pl]
	if e then return e end
	e = {box={}, name=nil, lines={}}
	for i=1,8 do
		local ln = Drawing.new("Line")
		ln.Thickness = 1.5
		ln.Transparency = 1
		ln.Visible = false
		e.box[i] = ln
	end
	e.name = Drawing.new("Text")
	e.name.Size = 13
	e.name.Center = true
	e.name.Outline = true
	e.name.OutlineColor = Color3.fromRGB(0,0,0)
	e.name.Visible = false
	for i=1,14 do
		local ln = Drawing.new("Line")
		ln.Thickness = 1.4
		ln.Transparency = 1
		ln.Visible = false
		e.lines[i] = ln
	end
	CS2.P[pl] = e
	return e
end

function CS2Hide(e)
	if not e then return end
	if e.box then for i=1,#e.box do if e.box[i] then e.box[i].Visible = false end end end
	if e.name then e.name.Visible = false end
	if e.lines then for i=1,#e.lines do if e.lines[i] then e.lines[i].Visible = false end end end
end

local function CS2DrawBox(e, x, y, w, h, col)
	local cx = math.max(4, math.floor(w*0.25))
	local cy = math.max(4, math.floor(h*0.25))
	local lines = {
		{x, y, x+cx, y}, {x, y, x, y+cy},
		{x+w, y, x+w-cx, y}, {x+w, y, x+w, y+cy},
		{x, y+h, x+cx, y+h}, {x, y+h, x, y+h-cy},
		{x+w, y+h, x+w-cx, y+h}, {x+w, y+h, x+w, y+h-cy},
	}
	for i=1,8 do
		local ln = e.box[i]
		local L = lines[i]
		ln.From = Vector2.new(L[1], L[2])
		ln.To = Vector2.new(L[3], L[4])
		ln.Color = col
		ln.Visible = true
	end
end

function CS2Upd()
	local cam = Workspace.CurrentCamera
	if not cam then return end
	for _,pl in ipairs(Players:GetPlayers()) do
		local e = CS2.P[pl]
		local ch = (pl ~= LP) and pl.Character or nil
		local r = ch and GetRoot(ch)
		local hd = ch and ch:FindFirstChild("Head")
		if not (S.ESP.CS2 and ch and r and hd) then
			CS2Hide(e)
		else
			e = CS2Ensure(pl)
			local top = cam:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.75, 0))
			local bot = cam:WorldToViewportPoint(r.Position - Vector3.new(0, 3.0, 0))
			local vis = top.Z > 0 and bot.Z > 0
			if not vis then
				CS2Hide(e)
			else
				local h = math.abs(bot.Y - top.Y)
				if h < 8 then h = 8 end
				local w = h * 0.48
				local x = top.X - w/2
				local y = top.Y
				local col = S.ESP.CS2C
				CS2DrawBox(e, x, y, w, h, col)
				e.name.Visible = true
				e.name.Color = Color3.fromRGB(255,255,255)
				e.name.Position = Vector2.new(top.X, top.Y - 16)
				e.name.Text = pl.DisplayName or pl.Name
				local isR15 = ch:FindFirstChild("UpperTorso") ~= nil
				local bs = isR15 and BONES_R15 or BONES_R6
				for i=1,14 do
					local ln = e.lines[i]
					local pr = bs[i]
					if pr then
						local a = ch:FindFirstChild(pr[1])
						local b = ch:FindFirstChild(pr[2])
						if a and b then
							local pa, va = cam:WorldToViewportPoint(a.Position)
							local pb, vb = cam:WorldToViewportPoint(b.Position)
							if va and vb and pa.Z > 0 and pb.Z > 0 then
								ln.From = Vector2.new(pa.X, pa.Y)
								ln.To = Vector2.new(pb.X, pb.Y)
								ln.Color = col
								ln.Visible = true
							else
								ln.Visible = false
							end
						else
							ln.Visible = false
						end
					else
						ln.Visible = false
					end
				end
			end
		end
	end
	for pl,e in pairs(CS2.P) do
		if not pl.Parent then
			CS2Hide(e)
			CS2.P[pl] = nil
		end
	end
end

function CS2Tgl(on)
	S.On.cs2 = on
	S.ESP.CS2 = on
	if on then
		if not CS2.C then CS2.C = RunService.RenderStepped:Connect(CS2Upd) end
		return
	end
	if CS2.C then CS2.C:Disconnect(); CS2.C = nil end
	for _,e in pairs(CS2.P) do CS2Hide(e) end
end

PARRY = {}; PARRY_DIGITS = {} for _,id in ipairs({"rbxassetid://110355011987939","rbxassetid://139369275981139","rbxassetid://117042998468241","rbxassetid://133963973694098","rbxassetid://113255068724446","rbxassetid://74968262036854","rbxassetid://118907603246885","rbxassetid://78432063483146","rbxassetid://129784271201071","rbxassetid://122812055447896","rbxassetid://138720291317243","rbxassetid://106871536134254","rbxassetid://109402730355822","rbxassetid://111920872708571","rbxassetid://105374834496520"}) do PARRY[id] = true; local d=tostring(id):match("%d+"); if d then PARRY_DIGITS[d]=true; PARRY["rbxassetid://"..d]=true end end
AP = {On=false,Conns={},Spam=false}
function APSpam()
	if AP.Spam then return end
	AP.Spam = true
	pcall(function() VIM:SendMouseButtonEvent(0,0,1,true,game,0) end)
	task.spawn(function()
		task.wait()
		pcall(function() VIM:SendMouseButtonEvent(0,0,1,false,game,0) end)
		AP.Spam = false
	end)
end
function APClear(p) if AP.Conns[p] then for _,c in ipairs(AP.Conns[p]) do pcall(function() c:Disconnect() end) end AP.Conns[p] = nil end end
function APHook(p,ch)
	if p==LP then return end
	APClear(p); AP.Conns[p] = {}
	local function onT(tr) if not AP.On or not IsSurv() then return end local a = tr.Animation; if a then a = a.AnimationId end if a and PARRY[a] then local my = GetRoot(LP.Character); local th = GetRoot(ch) if my and th and (my.Position-th.Position).Magnitude<=S.Parry.Range then APSpam() end end end
	local h = GetHum(ch); if not h then return end
	local an = h:FindFirstChildOfClass("Animator")
	if an then table.insert(AP.Conns[p],an.AnimationPlayed:Connect(onT))
	else
		local wc
		wc = h.ChildAdded:Connect(function(child) if child:IsA("Animator") then wc:Disconnect(); local l = AP.Conns[p]; if l then table.insert(l,child.AnimationPlayed:Connect(onT)) end end end)
		table.insert(AP.Conns[p],wc)
	end
	table.insert(AP.Conns[p],p.CharacterAdded:Connect(function(c2) task.wait(0.1) if AP.On then APHook(p,c2) end end))
end
function APTgl(on)
	AP.On = on; S.On.autoparry = on
	for k in pairs(AP.Conns) do APClear(k) end
	if on then
		for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then APHook(pl,pl.Character) end end
		AP.PA = Players.PlayerAdded:Connect(function(pl) AP.Conns[pl] = {}; table.insert(AP.Conns[pl],pl.CharacterAdded:Connect(function(ch) task.wait(0.1) if AP.On then APHook(pl,ch) end end)) end)
		AP.PR = Players.PlayerRemoving:Connect(APClear)
	else
		if AP.PA then AP.PA:Disconnect(); AP.PA = nil end
		if AP.PR then AP.PR:Disconnect(); AP.PR = nil end
	end
end


-- ===================== AUTO DAGGER (lunge/attack anim in circle) =====================
ADAG = {On=false,Range=12,Conns={},PA=nil,PR=nil,Last=0,CD=0.05,Busy=false}

local function ADAGIdMatch(id)
	if not id then return false end
	id = tostring(id)
	if PARRY[id] then return true end
	local digits = id:match("%d+")
	if digits and PARRY_DIGITS and PARRY_DIGITS[digits] then return true end
	if digits and PARRY["rbxassetid://"..digits] then return true end
	return false
end

local function ADAGFire()
	local now = tick()
	if ADAG.Busy then return end
	if now - (ADAG.Last or 0) < (ADAG.CD or 0.08) then return end
	ADAG.Last = now
	ADAG.Busy = true
	-- hypnosis/VD dagger = right mouse (button 1)
	pcall(function() VIM:SendMouseButtonEvent(0, 0, 1, true, game, 0) end)
	task.delay(0.05, function()
		pcall(function() VIM:SendMouseButtonEvent(0, 0, 1, false, game, 0) end)
		ADAG.Busy = false
	end)
end

local function ADAGOnTrack(pl, ch, tr)
	if not ADAG.On then return end
	local a = tr.Animation
	local id = a and a.AnimationId
	if not ADAGIdMatch(id) then return end
	local my = GetRoot(LP.Character)
	local th = GetRoot(ch)
	if not my or not th then return end
	if (my.Position - th.Position).Magnitude <= (tonumber(ADAG.Range) or 14) then
		ADAGFire()
	end
end

local function ADAGClear(p)
	if ADAG.Conns[p] then
		for _,c in ipairs(ADAG.Conns[p]) do pcall(function() c:Disconnect() end) end
		ADAG.Conns[p] = nil
	end
end

local function ADAGHook(p, ch)
	if p == LP or not ch then return end
	ADAGClear(p)
	ADAG.Conns[p] = {}
	local h = GetHum(ch)
	if not h then return end
	local function bind(an)
		table.insert(ADAG.Conns[p], an.AnimationPlayed:Connect(function(tr)
			ADAGOnTrack(p, ch, tr)
		end))
	end
	local an = h:FindFirstChildOfClass("Animator")
	if an then bind(an)
	else
		table.insert(ADAG.Conns[p], h.ChildAdded:Connect(function(child)
			if child:IsA("Animator") then bind(child) end
		end))
	end
	table.insert(ADAG.Conns[p], p.CharacterAdded:Connect(function(c2)
		task.wait(0.1)
		if ADAG.On then ADAGHook(p, c2) end
	end))
end

function ADAGTgl(on)
	ADAG.On = on
	S.On.autodagger = on
	for k in pairs(ADAG.Conns) do ADAGClear(k) end
	if ADAG.PA then ADAG.PA:Disconnect(); ADAG.PA = nil end
	if ADAG.PR then ADAG.PR:Disconnect(); ADAG.PR = nil end
	if not on then
		local r = GetRoot(LP.Character)
		if r then pcall(function() r.Anchored = false end) end
		ADAG.Busy = false
		return
	end
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= LP and pl.Character then ADAGHook(pl, pl.Character) end
	end
	ADAG.PA = Players.PlayerAdded:Connect(function(pl)
		ADAG.Conns[pl] = {}
		table.insert(ADAG.Conns[pl], pl.CharacterAdded:Connect(function(ch)
			task.wait(0.1)
			if ADAG.On then ADAGHook(pl, ch) end
		end))
	end)
	ADAG.PR = Players.PlayerRemoving:Connect(ADAGClear)
end

FAKE = {"rbxassetid://127096285501517","rbxassetid://109133187196613","rbxassetid://75939529748815","rbxassetid://126894569253341","rbxassetid://81793464499285","rbxassetid://123307242865945","rbxassetid://97915871372697"}
FAKE_NAMES = {"Katana","Dagger","Shield","Iron Hand","Clock","Fish","Ledo Klenok"}
FP = {Track=nil}
function FPPlay()
	local h = GetHum(LP.Character); if not h then return end
	if FP.Track then pcall(function() FP.Track:Stop() end) end
	local a = Instance.new("Animation"); a.AnimationId = FAKE[S.Parry.Anim] or FAKE[1]
	local ok,tr = pcall(function() return h:LoadAnimation(a) end)
	if ok and tr then FP.Track = tr; tr:Play() end
end
function FPTgl(on)
	S.On.fakeparry = on
	if on then FPPlay()
	else if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track = nil end end
end
function FPPulse() if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track = nil end FPPlay() task.delay(1,function() if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track = nil end end) end

AC = {On=false,Conns={},Holding=false,PA=nil,PR=nil}
function ACPress()
	if AC.Holding then return end
	AC.Holding = true
	pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.C,false,game) end)
	task.delay(1.5,function() pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.C,false,game) end); AC.Holding = false end)
end
function ACHook(p,ch)
	if p==LP then return end
	if not AC.Conns[p] then AC.Conns[p] = {} end
	local h = GetHum(ch); if not h then return end
	local function onT(tr) if not AC.On then return end local a = tr.Animation if a and a.AnimationId=="rbxassetid://80411309607666" then ACPress() end end
	local an = h:FindFirstChildOfClass("Animator")
	if an then table.insert(AC.Conns[p],an.AnimationPlayed:Connect(onT)) end
	table.insert(AC.Conns[p],p.CharacterAdded:Connect(function(c2) task.wait(0.1) if AC.On then ACHook(p,c2) end end))
end
function ACTgl(on)
	AC.On = on; S.On.autocrouch = on
	for _,list in pairs(AC.Conns) do for _,c in ipairs(list) do pcall(function() c:Disconnect() end) end end
	AC.Conns = {}
	if on then
		for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then ACHook(pl,pl.Character) end end
		AC.PA = Players.PlayerAdded:Connect(function(pl) AC.Conns[pl] = {}; table.insert(AC.Conns[pl],pl.CharacterAdded:Connect(function(ch) task.wait(0.1) if AC.On then ACHook(pl,ch) end end)) end)
		AC.PR = Players.PlayerRemoving:Connect(function(pl) if AC.Conns[pl] then for _,c in ipairs(AC.Conns[pl]) do pcall(function() c:Disconnect() end) end AC.Conns[pl] = nil end end)
	else
		if AC.PA then AC.PA:Disconnect(); AC.PA = nil end
		if AC.PR then AC.PR:Disconnect(); AC.PR = nil end
		if AC.Holding then pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.C,false,game) end); AC.Holding = false end
	end
end

ASC = {On=false,Instant=false,Th=nil,LastHit=0,Conn=nil}

local function ASCPress()
	pcall(function()
		VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
		task.wait()
		VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
	end)
end

local function ASCCache()
	local pg = LP:FindFirstChild("PlayerGui")
	if not pg then return nil, nil, nil end
	local gui = pg:FindFirstChild("SkillCheckPromptGui")
	if not gui then return nil, nil, nil end
	local check = gui:FindFirstChild("Check")
	if not check or not check.Visible then return nil, nil, nil end
	local line = check:FindFirstChild("Line")
	local goal = check:FindFirstChild("Goal")
	return check, line, goal
end

function ASCTgl(on)
	ASC.On = on
	S.On.autoskill = on
	if ASC.Th then task.cancel(ASC.Th); ASC.Th = nil end
	if ASC.Conn then ASC.Conn:Disconnect(); ASC.Conn = nil end
	if not on then return end
	local hitFlag = false
	local lastRot = nil
	ASC.Conn = RunService.RenderStepped:Connect(function()
		if not ASC.On then return end
		local check, line, goal = ASCCache()
		if not check or not line or not goal then
			hitFlag = false
			lastRot = nil
			return
		end
		local gr = goal.Rotation
		if lastRot ~= gr then
			lastRot = gr
			hitFlag = false
		end
		if ASC.Instant then
			if hitFlag then return end
			hitFlag = true
			-- hypnosis: snap line into middle of success zone briefly then press
			local a, b = 104, 114 -- zone offsets used by hoopsonik/hypnosis
			task.spawn(function()
				task.wait(0.05)
				if not ASC.On then return end
				local ck2, ln2, gl2 = ASCCache()
				if not (ck2 and ln2 and gl2) then return end
				local mid = ((gl2.Rotation % 360) + (a + b) / 2) % 360
				local untilT = tick() + 0.2
				while tick() < untilT and ASC.On do
					pcall(function() ln2.Rotation = mid end)
					ASCPress()
					RunService.RenderStepped:Wait()
				end
			end)
			return
		end
		-- Perfect: when line enters goal window
		local lr = line.Rotation
		local o = lr % 360
		if o < 0 then o = o + 360 end
		local r = gr % 360
		if r < 0 then r = r + 360 end
		local y = (r + 104) % 360
		local C = (r + 114) % 360
		local inZone
		if y > C then
			inZone = (o >= y or o <= C)
		else
			inZone = (o >= y and o <= C)
		end
		if inZone and not hitFlag then
			hitFlag = true
			ASCPress()
			ASCPress()
		end
	end)
end

function ASCInstantTgl(on)
	ASC.Instant = on
	S.On.instantskill = on
	if on and not ASC.On then
		ASCTgl(true)
	end
end



-- ===================== SAVE TEAMMATE (pallet stun anim) =====================
-- When teammate is dying under a pallet, wait for killer pallet stun anim, TP + Space, return
SAVE_TM = {
	On = false,
	Busy = false,
	Range = 80,
	ReturnCF = nil,
	-- anim ids from user (pallet stun / break on killer)
	Anims = {
		["112233054056"] = true,
		["1027462057982"] = true,
		["13177598773209"] = true,
		["104904206635908"] = true,
		-- also store full rbxassetid form
		["rbxassetid://112233054056"] = true,
		["rbxassetid://1027462057982"] = true,
		["rbxassetid://13177598773209"] = true,
		["rbxassetid://104904206635908"] = true,
	},
}

local function STMAnimId(track)
	if not track then return nil end
	local a = track.Animation
	if not a then return nil end
	local id = tostring(a.AnimationId or "")
	-- normalize digits only key
	local digits = id:match("%d+")
	return id, digits
end

local function STMIsSaveAnim(track)
	local id, digits = STMAnimId(track)
	if not id then return false end
	if SAVE_TM.Anims[id] then return true end
	if digits and SAVE_TM.Anims[digits] then return true end
	-- partial match (sometimes id has extra path)
	if digits then
		for k,_ in pairs(SAVE_TM.Anims) do
			if tostring(k):find(digits, 1, true) or digits:find(tostring(k):match("%d+") or "___", 1, true) then
				return true
			end
		end
	end
	return false
end

local function STMFindKillerPlayingSaveAnim()
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= LP and pl.Character and IsKiller(pl) then
			local hum = GetHum(pl.Character)
			if hum then
				local animator = hum:FindFirstChildOfClass("Animator")
				if animator then
					for _,tr in ipairs(animator:GetPlayingAnimationTracks()) do
						if STMIsSaveAnim(tr) then
							return pl, tr
						end
					end
				end
			end
		end
	end
	return nil
end

local function STMFindDownedTeammateNearPallet()
	ScanInteractables()
	local myRoot = GetRoot(LP.Character)
	local best, bestD = nil, tonumber(SAVE_TM.Range) or 80
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= LP and pl.Character and not IsKiller(pl) then
			local c = pl.Character
			local knocked = c:GetAttribute("Knocked") == true
				or pl:GetAttribute("Knocked") == true
				or c:GetAttribute("Downed") == true
				or (GetHum(c) and GetHum(c).Health > 0 and GetHum(c).Health < 15)
			-- also "dying" under pallet - low health or crawl
			local hum = GetHum(c)
			if hum and hum.Health > 0 then
				local r = GetRoot(c)
				if r then
					-- near any pallet?
					local nearPal = false
					local palPos = nil
					for _,pal in ipairs(CACHE.pallets) do
						local pos = RDPPalletPos and select(1, RDPPalletPos(pal))
						if not pos and pal:IsA("Model") then
							local pp = pal:FindFirstChild("PalletPoint") or pal:FindFirstChildWhichIsA("BasePart", true)
							if pp then pos = pp:IsA("BasePart") and pp.Position or pp:GetPivot().Position end
						end
						if pos and (pos - r.Position).Magnitude < 10 then
							nearPal = true
							palPos = pos
							break
						end
					end
					if nearPal or knocked then
						local d = myRoot and (r.Position - myRoot.Position).Magnitude or 0
						if d < bestD then
							bestD = d
							best = {player = pl, root = r, palPos = palPos or r.Position}
						end
					end
				end
			end
		end
	end
	return best
end

function SaveTeammateDo()
	if SAVE_TM.Busy then return end
	SAVE_TM.Busy = true
	task.spawn(function()
		local ok, err = pcall(function()
			local myRoot = GetRoot(LP.Character)
			if not myRoot then error("no root") end
			SAVE_TM.ReturnCF = myRoot.CFrame

			-- fast poll: killer already in pallet anim OR nearest save spot
			local killer, track = STMFindKillerPlayingSaveAnim()
			if not killer then
				-- short wait only if anim not already playing (max ~0.6s)
				local t0 = tick()
				while tick() - t0 < 0.6 do
					killer, track = STMFindKillerPlayingSaveAnim()
					if killer then break end
					RunService.Heartbeat:Wait()
				end
			end

			local target = STMFindDownedTeammateNearPallet()
			local dest, lookAt
			if killer and killer.Character then
				local kr = GetRoot(killer.Character)
				if kr then
					dest = kr.Position
					lookAt = kr.Position
				end
			end
			if target and target.palPos then
				dest = target.palPos
				lookAt = target.palPos
			elseif target and target.root then
				dest = target.root.Position
				lookAt = dest
			end
			if not dest then error("no save target") end

			-- TP on top of pallet/killer facing target (no need to look beforehand)
			local cf = CFrame.new(dest + Vector3.new(0, 2.5, 0))
			if lookAt then
				cf = CFrame.new(dest + Vector3.new(0, 2.5, 0), lookAt)
			end
			myRoot.CFrame = cf
			-- instant space spam same frame
			for _ = 1, 12 do
				PressSpace()
				RunService.Heartbeat:Wait()
			end
			-- return immediately
			if SAVE_TM.ReturnCF and myRoot and myRoot.Parent then
				myRoot.CFrame = SAVE_TM.ReturnCF
			end
		end)
		SAVE_TM.Busy = false
	end)
end




NS = {On=false,Conn=nil}
function NSTgl(on)
	NS.On = on; S.On.noslow = on
	if NS.Conn then NS.Conn:Disconnect(); NS.Conn = nil end
	if on then
		local h = GetHum(LP.Character); if not h then return end
		h.WalkSpeed = 16
		NS.Conn = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if NS.On and h.WalkSpeed<16 then h.WalkSpeed = 16 end end)
	end
end

MW = {On=false,Conn=nil,Yaw=0}
function MWTgl(on)
	MW.On = on; S.On.moonwalk = on
	if MW.Conn then MW.Conn:Disconnect(); MW.Conn = nil end
	if on then
		local r = GetRoot(LP.Character); if r then local _,y,_ = r.CFrame:ToEulerAnglesXYZ(); MW.Yaw = y end
		MW.Conn = RunService.RenderStepped:Connect(function(dt)
			if not MW.On then return end
			local c = LP.Character; if not c then return end
			local r = GetRoot(c); local h = GetHum(c)
			if r and h then
				h.AutoRotate = false
				if h.MoveDirection.Magnitude>0.1 then
					local dir = -h.MoveDirection; local wave = math.sin(tick()*35)*0.8
					local d = (math.atan2(-dir.X,-dir.Z)+wave-MW.Yaw)%(math.pi*2)
					if d>math.pi then d = d-(math.pi*2) end
					MW.Yaw = MW.Yaw+d*0.1*dt*60
					r.CFrame = CFrame.new(r.Position)*CFrame.Angles(0,MW.Yaw,0)
				end
			end
		end)
	else local h = GetHum(LP.Character); if h then h.AutoRotate = true end end
end

FLY = {On=false,Conn=nil,BV=nil,BG=nil}
function FLYTgl(on)
	FLY.On = on; S.On.fly = on
	if FLY.Conn then FLY.Conn:Disconnect(); FLY.Conn = nil end
	if FLY.BV then FLY.BV:Destroy(); FLY.BV = nil end
	if FLY.BG then FLY.BG:Destroy(); FLY.BG = nil end
	if on then
		local c = LP.Character; if not c then return end
		local h = GetHum(c); local r = GetRoot(c); if not h or not r then return end
		h.PlatformStand = true
		FLY.BV = Instance.new("BodyVelocity"); FLY.BV.MaxForce = Vector3.new(40000,40000,40000); FLY.BV.Parent = r
		FLY.BG = Instance.new("BodyGyro"); FLY.BG.MaxTorque = Vector3.new(40000,40000,40000); FLY.BG.Parent = r
		FLY.Conn = RunService.Heartbeat:Connect(function()
			if not FLY.On or not FLY.BV then return end
			local cam = Workspace.CurrentCamera; local v = Vector3.new(0,0,0)
			if UIS:IsKeyDown(Enum.KeyCode.W) then v = v+cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then v = v-cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then v = v-cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then v = v+cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then v = v+Vector3.new(0,1,0) end
			if v.Magnitude>0 then FLY.BV.Velocity = v.Unit*60 end
			FLY.BG.CFrame = cam.CFrame
		end)
	else local h = GetHum(LP.Character); if h then h.PlatformStand = false end end
end

NC = {On=false,Conn=nil}
function NCTgl(on)
	NC.On = on; S.On.noclip = on
	if NC.Conn then NC.Conn:Disconnect(); NC.Conn = nil end
	if on then NC.Conn = RunService.Stepped:Connect(function() local c = LP.Character if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end end) end
end

GM = {On=false}
function GMTgl(on)
	GM.On = on; S.On.god = on
	local h = GetHum(LP.Character); if not h then return end
	if on then h.MaxHealth = 1e999; h.Health = 1e999 else h.MaxHealth = 100; h.Health = 100 end
end

DS = {On=false,Conn=nil,Ghost=nil,GhostOn=true,GhostTop=true,GhostTrans=0.45,GhostCol=Color3.fromRGB(0,255,200)}

function DSDestroyGhost()
	if DS.Ghost then pcall(function() DS.Ghost:Destroy() end); DS.Ghost = nil end
end

function DSBuildGhost(char, freezeCF)
	DSDestroyGhost()
	if not DS.GhostOn or not char then return end
	local root = GetRoot(char); if not root then return end
	local model = Instance.new("Model"); model.Name = "GoatLoseDesyncGhost"
	local hum = Instance.new("Humanoid"); hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; hum.Parent = model
	local baseCF = freezeCF or root.CFrame
	for _,part in ipairs(char:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			local cl = part:Clone()
			cl:ClearAllChildren()
			cl.Anchored = true
			cl.CanCollide = false
			cl.CanTouch = false
			cl.CanQuery = false
			cl.CastShadow = false
			cl.Material = Enum.Material.ForceField
			cl.Color = DS.GhostCol
			cl.Transparency = math.clamp(DS.GhostTrans, 0.15, 0.9)
			cl:SetAttribute("OriginalPartName", part.Name)
			local off = baseCF:ToObjectSpace(part.CFrame)
			cl.CFrame = baseCF * off
			cl.Parent = model
		end
	end
	local hl = Instance.new("Highlight")
	hl.Name = "GhostHighlight"
	hl.FillColor = DS.GhostCol
	hl.FillTransparency = DS.GhostTrans
	hl.OutlineColor = Color3.fromRGB(255,255,255)
	hl.OutlineTransparency = 0.15
	hl.DepthMode = DS.GhostTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
	hl.Adornee = model
	hl.Parent = model
	model.Parent = Workspace
	DS.Ghost = model
end

function DSUpdateGhostAppearance()
	if not DS.Ghost then return end
	pcall(function()
		for _,p in ipairs(DS.Ghost:GetChildren()) do
			if p:IsA("BasePart") then
				p.Color = DS.GhostCol
				p.Transparency = math.clamp(DS.GhostTrans, 0.15, 0.9)
			elseif p:IsA("Highlight") then
				p.FillColor = DS.GhostCol
				p.FillTransparency = DS.GhostTrans
				p.DepthMode = DS.GhostTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
			end
		end
	end)
end

function DSTgl(on)
	DS.On = on; S.On.desync = on
	if DS.Conn then DS.Conn:Disconnect(); DS.Conn = nil end
	local r = GetRoot(LP.Character); if r then r.Anchored = false end
	DSDestroyGhost()
	if on then
		local freezeCF = r and r.CFrame or nil
		if DS.GhostOn and LP.Character then DSBuildGhost(LP.Character, freezeCF) end
		DS.Conn = RunService.Heartbeat:Connect(function(dt)
			if not DS.On then return end
			local c = LP.Character; local root = c and GetRoot(c); local h = GetHum(c)
			if not root or not h then return end
			root.Anchored = true
			local md = h.MoveDirection
			if md.Magnitude > 0 then
				root.CFrame = root.CFrame + md * (h.WalkSpeed * dt)
			end
			if DS.GhostOn and (not DS.Ghost or not DS.Ghost.Parent) then
				DSBuildGhost(c, freezeCF or root.CFrame)
			end
		end)
	else
		DSDestroyGhost()
	end
end

SB = {On=false,Mult=1.3,Conn=nil,BaseSpeed=16}
function SBApply()
	-- keep WalkSpeed high + heartbeat CFrame push (non-legit)
	local h = GetHum(LP.Character)
	if h then
		if SB.On then
			h.WalkSpeed = math.max(16, (SB.BaseSpeed or 16) * (SB.Mult or 1.3))
		else
			h.WalkSpeed = SB.BaseSpeed or 16
		end
	end
end
function SBTgl(on)
	SB.On = on
	S.On.speedboost = on
	if SB.Conn then SB.Conn:Disconnect(); SB.Conn = nil end
	if not on then
		SBApply()
		return
	end
	local h0 = GetHum(LP.Character)
	if h0 and h0.WalkSpeed > 0 and h0.WalkSpeed < 100 then
		SB.BaseSpeed = 16
	end
	SBApply()
	SB.Conn = RunService.Heartbeat:Connect(function(dt)
		if not SB.On then return end
		local c = LP.Character
		if not c then return end
		local h = GetHum(c)
		local r = GetRoot(c)
		if not h or not r then return end
		local mult = tonumber(SB.Mult) or 1.3
		-- force walkspeed every frame (anti-reset)
		local want = 16 * mult
		if h.WalkSpeed < want * 0.95 then
			h.WalkSpeed = want
		end
		local md = h.MoveDirection
		if md.Magnitude > 0.05 then
			-- illegit: extra displacement beyond walkspeed
			local extra = (want - 16) * dt
			if extra < 0 then extra = want * 0.35 * dt end
			r.CFrame = r.CFrame + md.Unit * (want * dt * 0.85)
			-- also boost velocity
			pcall(function()
				local v = r.AssemblyLinearVelocity
				local horiz = Vector3.new(md.X, 0, md.Z).Unit * want
				r.AssemblyLinearVelocity = Vector3.new(horiz.X, v.Y, horiz.Z)
			end)
		end
	end)
end

CH = {Part=nil,Weld=nil,Conn=nil}
function CHBuild()
	if CH.Part then CH.Part:Destroy() end
	if CH.Conn then CH.Conn:Disconnect() end
	if IsLocalKiller() then return end -- no china hat on killer
	local c = LP.Character; if not c then return end
	local hd = c:FindFirstChild("Head"); if not hd then return end
	local part = Instance.new("Part"); part.Size = Vector3.new(2,0.25,2); part.CanCollide = false; part.Material = Enum.Material.ForceField; part.Color = S.China.Color
	local mesh = Instance.new("SpecialMesh"); mesh.MeshId = "rbxassetid://84530303562911"; mesh.TextureId = "rbxassetid://89342168321397"; mesh.MeshType = Enum.MeshType.FileMesh; mesh.Parent = part
	local weld = Instance.new("Weld"); weld.Part0 = hd; weld.Part1 = part; weld.C0 = CFrame.new(0,0.35,0); weld.Parent = part
	CH.Weld = weld; part.Parent = c; CH.Part = part
	local n = 0
	CH.Conn = RunService.RenderStepped:Connect(function() if CH.Part and CH.Part.Parent then n = (n+3)%360; weld.C0 = CFrame.new(0,0.35,0)*CFrame.Angles(0,math.rad(n),0); CH.Part.Color = S.China.Color end end)
end

-- ===================== TUNG TUNG SAHUR (R6 morph) =====================
TTS = {
	On = false,
	AssetId = 131328832889636,
	Scale = 0.8,
	RightOffset = 0.3,
	Conn = nil,
}

local TTS_PARTS = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}

local function TTSStrip(char)
	for _, child in ipairs(char:GetChildren()) do
		if child:IsA("CharacterMesh") or child:IsA("Shirt") or child:IsA("Pants")
			or child:IsA("ShirtGraphic") or child:IsA("Accessory") or child:IsA("Hat") then
			pcall(function() child:Destroy() end)
		end
	end
	local old = char:FindFirstChild("R6_VisualMorph_Shifted")
	if old then pcall(function() old:Destroy() end) end
	local head = char:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
		if face then face.Transparency = 1 end
	end
end

local function TTSBind(limb, target_part)
	target_part.Anchored = false
	target_part.CanCollide = false
	target_part.Massless = true
	if target_part:IsA("BasePart") then
		target_part.Size = target_part.Size * (TTS.Scale or 0.8)
		local mesh = target_part:FindFirstChildOfClass("SpecialMesh")
		if mesh then mesh.Scale = mesh.Scale * (TTS.Scale or 0.8) end
	end
	local off = TTS.RightOffset or 0.3
	target_part.CFrame = limb.CFrame * CFrame.new(off, 0, 0)
	local weld = Instance.new("Motor6D")
	weld.Name = "MorphJoint_" .. limb.Name
	weld.Part0 = limb
	weld.Part1 = target_part
	weld.C0 = CFrame.new(off, 0, 0)
	weld.C1 = CFrame.new()
	weld.Parent = limb
end

local function TTSApply(character)
	if not TTS.On or not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
	local torso = character:FindFirstChild("Torso") or character:WaitForChild("Torso", 3)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid then return end
	-- R15 fallback names
	if not torso then
		torso = character:FindFirstChild("UpperTorso")
	end
	if not torso or not root then return end

	TTSStrip(character)

	local uri = "rbxassetid://" .. tostring(TTS.AssetId)
	local ok, objects = pcall(function()
		return game:GetObjects(uri)
	end)

	local scale = TTS.Scale or 0.8
	local off = TTS.RightOffset or 0.3

	if not ok or not objects or #objects == 0 then
		for _, name in ipairs(TTS_PARTS) do
			local p = character:FindFirstChild(name)
			if p and name ~= "Torso" then p.Transparency = 1 end
		end
		if torso then
			local sm = torso:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", torso)
			sm.MeshType = Enum.MeshType.FileMesh
			sm.MeshId = uri
			sm.Scale = Vector3.new(scale, scale, scale)
		end
		return
	end

	local asset = objects[1]
	if asset:IsA("Model") then
		local matched = false
		local folder = Instance.new("Folder")
		folder.Name = "R6_VisualMorph_Shifted"
		folder.Parent = character

		local shirt = asset:FindFirstChildOfClass("Shirt")
		local pants = asset:FindFirstChildOfClass("Pants")
		local body_colors = asset:FindFirstChildOfClass("BodyColors")
		if shirt then shirt:Clone().Parent = character end
		if pants then pants:Clone().Parent = character end
		if body_colors then
			local old_bc = character:FindFirstChildOfClass("BodyColors")
			if old_bc then old_bc:Destroy() end
			body_colors:Clone().Parent = character
		end

		for _, limb_name in ipairs(TTS_PARTS) do
			local orig = character:FindFirstChild(limb_name)
			local custom = asset:FindFirstChild(limb_name)
			if orig and custom and custom:IsA("BasePart") then
				matched = true
				orig.Transparency = 1
				local clone = custom:Clone()
				for _, j in ipairs(clone:GetDescendants()) do
					if j:IsA("JointInstance") or j:IsA("WeldConstraint") then
						j:Destroy()
					end
				end
				clone.Parent = folder
				TTSBind(orig, clone)
			end
		end

		for _, acc in ipairs(asset:GetChildren()) do
			if acc:IsA("Accessory") or acc:IsA("Hat") then
				local handle = acc:FindFirstChild("Handle")
				if handle and handle:IsA("BasePart") then
					local cloned = acc:Clone()
					cloned.Parent = folder
					local ch = cloned:FindFirstChild("Handle")
					local head = character:FindFirstChild("Head") or torso
					if ch and head then TTSBind(head, ch) end
				end
			end
		end

		if not matched then
			for _, limb_name in ipairs(TTS_PARTS) do
				local orig = character:FindFirstChild(limb_name)
				if orig then orig.Transparency = 1 end
			end
			asset.Parent = folder
			local primary = asset.PrimaryPart or asset:FindFirstChildWhichIsA("BasePart", true)
			if primary then
				asset:PivotTo(torso.CFrame * CFrame.new(off, 0, 0))
				for _, desc in ipairs(asset:GetDescendants()) do
					if desc:IsA("BasePart") then
						desc.Size = desc.Size * scale
						desc.Anchored = false
						desc.CanCollide = false
						desc.Massless = true
						if desc ~= primary then
							local wc = Instance.new("WeldConstraint")
							wc.Part0 = primary
							wc.Part1 = desc
							wc.Parent = primary
						end
					end
				end
				TTSBind(torso, primary)
			end
		else
			pcall(function() asset:Destroy() end)
		end
		return
	end

	for _, limb_name in ipairs(TTS_PARTS) do
		local orig = character:FindFirstChild(limb_name)
		if orig then orig.Transparency = 1 end
	end
	if asset:IsA("MeshPart") or asset:IsA("BasePart") then
		asset.Size = asset.Size * scale
		asset.Parent = character
		TTSBind(torso, asset)
	elseif asset:IsA("SpecialMesh") then
		torso.Transparency = 0
		local old_mesh = torso:FindFirstChildOfClass("SpecialMesh")
		if old_mesh then old_mesh:Destroy() end
		asset.Scale = asset.Scale * scale
		asset.Parent = torso
	end
end

local function TTSClear(char)
	if not char then return end
	local folder = char:FindFirstChild("R6_VisualMorph_Shifted")
	if folder then pcall(function() folder:Destroy() end) end
	for _, name in ipairs(TTS_PARTS) do
		local limb = char:FindFirstChild(name)
		if limb and limb:IsA("BasePart") then
			limb.Transparency = 0
			for _, ch in ipairs(limb:GetChildren()) do
				if ch.Name:find("MorphJoint_") then pcall(function() ch:Destroy() end) end
			end
		end
	end
end


-- ===================== MUSIC (SPOTIFY / SPECTRAL) =====================
MUSIC = {
	On=false, CloseKey="M", Cleanup=nil,
	-- theme
	Accent = Color3.fromRGB(0, 255, 170),
	AccentAlt = Color3.fromRGB(0, 190, 255),
	Bg = Color3.fromRGB(11, 12, 19),
	Text = Color3.fromRGB(246, 248, 255),
	LyricLeft = Color3.fromRGB(145, 255, 220),
	LyricRight = Color3.fromRGB(165, 235, 255),
}
_G.GoatLoseMusicCloseKey = "M"

local SPECTRAL_SRC = [=[






-- language: Luau, file: SpectralMusic_v7_4_1.lua, 
-- Changes: Restored full UI, folder playlist scanner, volume controls, sync offset, hotkeys, and drift-corrected Spotify sync

if _G.SpectralCleanup then
    pcall(_G.SpectralCleanup)
end

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

pcall(function() ContextActionService:UnbindAction("SpectralMiniPlayerArrows") end)
for _, v in ipairs(Workspace:GetChildren()) do
    if v.Name == "SpectralLocalMP3" or v.Name == "SpectralLyricsWorld" then
        pcall(function()
            if v:IsA("Sound") then v:Stop() end
            v:Destroy()
        end)
    end
end
for _, v in ipairs(CoreGui:GetChildren()) do
    if v.Name == "SpectralFolderPlayerUI" then
        pcall(function() v:Destroy() end)
    end
end

local LocalPlayer = Players.LocalPlayer
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local getAsset = getcustomasset or getsynasset

local FOLDER_NAME = "SpectralMusic"
local CACHE_FOLDER = FOLDER_NAME .. "/_cache"
local LINKS_FILE = FOLDER_NAME .. "/links.txt"
local SPOTIFY_TOKEN_FILE = FOLDER_NAME .. "/spotify_token.txt"
local SPOTIFY_BRIDGE_FILE = FOLDER_NAME .. "/spotify_live.json"
local SPOTIFY_BRIDGE_ROOT = "spotify_live.json"

if isfolder and makefolder then
    if not isfolder(FOLDER_NAME) then pcall(makefolder, FOLDER_NAME) end
    if not isfolder(CACHE_FOLDER) then pcall(makefolder, CACHE_FOLDER) end
end

local WorldFolder = Instance.new("Folder")
WorldFolder.Name = "SpectralLyricsWorld"
WorldFolder.Parent = Workspace

-- State
local ScriptAlive = true
local AudioPlaylist = {}
local TextFilesList = {}
local ForcedCustomTxtPath = nil
local CurrentTrackIndex = 1
local CurrentSound = nil
local ParsedLyrics = {}
local LastTriggeredIndex = 0
local LastSpawnedClock = -999
local IsPlaying = false
local RenderConnection = nil
local InputConnection = nil
local PlaybackGeneration = 0
local ActiveTrackName = "Нет выбранного трека"
local SyncOffsetSec = 0.0
local CurrentVolume = 1.5
local NextSpawnSide = -1
local DefaultCoverAsset = "rbxassetid://14813415675"

-- Spotify State & Drift Smoothing
local SpotifyLiveEnabled = false
local SpotifyBearerToken = ""
local SpotifyTrackId = ""
local SpotifyAnchorPos = 0
local SpotifyAnchorTick = 0
local SpotifyDuration = 180
local SpotifyIsPlaying = false
local SpotifyCoverCache = {}

local C = {
    bg0          = Color3.fromRGB(6, 6, 10),
    bg1          = Color3.fromRGB(11, 12, 19),
    bg2          = Color3.fromRGB(17, 19, 30),
    bg3          = Color3.fromRGB(25, 28, 44),
    accent       = Color3.fromRGB(0, 255, 170),
    accentAlt    = Color3.fromRGB(0, 190, 255),
    accentPink   = Color3.fromRGB(215, 70, 255),
    spotifyGreen = Color3.fromRGB(30, 215, 96),
    accentDim    = Color3.fromRGB(0, 125, 85),
    accentGlow   = Color3.fromRGB(145, 255, 220),
    text         = Color3.fromRGB(246, 248, 255),
    textMid      = Color3.fromRGB(168, 176, 202),
    textDim      = Color3.fromRGB(96, 104, 130),
    red          = Color3.fromRGB(255, 68, 98),
    itemHover    = Color3.fromRGB(32, 36, 56),
    itemActive   = Color3.fromRGB(12, 48, 40),
}
-- live theme from GoatLose
pcall(function()
    local T = rawget(_G, "GoatLoseMusicTheme")
    if type(T) == "table" then
        if T.Bg then C.bg1 = T.Bg; C.bg2 = T.Bg; C.bg0 = T.Bg end
        if T.Accent then C.accent = T.Accent; C.accentDim = T.Accent end
        if T.AccentAlt then C.accentAlt = T.AccentAlt end
        if T.Text then C.text = T.Text end
        if T.LyricLeft then C.accentGlow = T.LyricLeft end
        if T.LyricRight then end -- used in spawn
    end
end)
_G.GoatLoseMusicC = C
local function isDefaultGreen(col)
    if typeof(col) ~= "Color3" then return false end
    -- detect spectral default greens / cyans
    local r,g,b = col.R*255, col.G*255, col.B*255
    if g > 150 and g > r + 40 and g > b + 20 then return true end -- green dominant
    if g > 180 and b > 150 and r < 180 then return true end -- cyan/mint
    if r < 50 and g > 200 and b < 120 then return true end -- pure accent green
    return false
end

_G.GoatLoseMusicApplyTheme = function()
    local T = rawget(_G, "GoatLoseMusicTheme")
    if type(T) ~= "table" then return end
    if T.Bg then
        C.bg0 = T.Bg; C.bg1 = T.Bg; C.bg2 = T.Bg; C.bg3 = T.Bg
    end
    if T.Accent then
        C.accent = T.Accent
        C.accentDim = T.Accent
        C.accentGlow = T.Accent
        C.spotifyGreen = T.Accent
        C.accentAlt = T.AccentAlt or T.Accent
    end
    if T.AccentAlt then C.accentAlt = T.AccentAlt end
    if T.Text then C.text = T.Text; C.textMid = T.Text; C.textDim = T.Text end
    if T.LyricLeft then C.accentGlow = T.LyricLeft end

    local acc = T.Accent or C.accent
    local txt = T.Text or C.text
    local bg = T.Bg or C.bg1

    local function paint(root)
        if not root then return end
        if root:IsA("Frame") or root:IsA("TextButton") then
            if root == MiniPlayer or root == MainFrame then
                root.BackgroundColor3 = bg
            end
            if root == ProgressFill or root.Name == "ProgressFill" then
                root.BackgroundColor3 = acc
            end
        end
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("UIStroke") then
                d.Color = acc
            elseif d:IsA("Frame") or d:IsA("TextButton") or d:IsA("ImageButton") then
                if d.Name == "ProgressFill" or d == ProgressFill then
                    d.BackgroundColor3 = acc
                elseif isDefaultGreen(d.BackgroundColor3) then
                    d.BackgroundColor3 = acc
                end
            elseif d:IsA("TextLabel") or d:IsA("TextButton") then
                if d == SourceBadge or d.Name == "SourceBadge" then
                    d.TextColor3 = acc
                elseif isDefaultGreen(d.TextColor3) then
                    d.TextColor3 = acc
                elseif d == MiniTitle or d == MiniLyric or d == DurationLabel
                    or d == MiniPrevBtn or d == MiniPlayBtn or d == MiniNextBtn then
                    d.TextColor3 = txt
                end
            end
        end
    end
    pcall(function() paint(MiniPlayer) end)
    pcall(function() paint(MainFrame) end)
    pcall(function()
        if ProgressFill then ProgressFill.BackgroundColor3 = acc end
        if SourceBadge then SourceBadge.TextColor3 = acc end
        if MiniTitle then MiniTitle.TextColor3 = txt end
        if MiniLyric then MiniLyric.TextColor3 = txt end
        if DurationLabel then DurationLabel.TextColor3 = txt end
        if MiniPlayer then MiniPlayer.BackgroundColor3 = bg end
        if MainFrame then MainFrame.BackgroundColor3 = bg end
        -- stroke on mini player itself
        for _,d in ipairs(MiniPlayer:GetChildren()) do
            if d:IsA("UIStroke") then d.Color = acc end
        end
    end)
end

-- ==========================================
-- CP1251 <-> UTF-8 & CYRILLIC ENGINE
-- ==========================================
local CP1251_MAP = {
    [128]="Ђ",[129]="Ѓ",[130]="‚",[131]="ѓ",[132]="„",[133]="…",[134]="†",[135]="‡",
    [136]="€",[137]="‰",[138]="Љ",[139]="‹",[140]="Њ",[141]="Ќ",[142]="Ћ",[143]="Џ",
    [144]="ђ",[145]="‘",[146]="’",[147]="“",[148]="”",[149]="•",[150]="–",[151]="—",
    [152]=" ",[153]="™",[154]="љ",[155]="›",[156]="њ",[157]="ќ",[158]="ћ",[159]="џ",
    [160]=" ",[161]="Ў",[162]="ў",[163]="Ј",[164]="¤",[165]="Ґ",[166]="¦",[167]="§",
    [168]="Ё",[169]="©",[170]="Є",[171]="«",[172]="¬",[173]="", [174]="®",[175]="Ї",
    [176]="°",[177]="±",[178]="І",[179]="і",[180]="ґ",[181]="µ",[182]="¶",[183]="·",
    [184]="ё",[185]="№",[186]="є",[187]="»",[188]="ј",[189]="Ѕ",[190]="ѕ",[191]="ї"
}
for b = 192, 255 do CP1251_MAP[b] = utf8.char(0x0410 + (b - 192)) end

local CYRILLIC_UPPER_TO_LOWER = {
    ["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",["Ж"]="ж",["З"]="з",
    ["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",
    ["С"]="с",["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",
    ["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я",
    ["І"]="і",["Ї"]="ї",["Є"]="є",["Ґ"]="ґ",["Ў"]="ў"
}

local function stripUTF8BOM(s)
    if not s or s == "" then return "" end
    if string.sub(s, 1, 3) == "\239\187\191" then s = string.sub(s, 4) end
    return s
end

local function ensureValidUTF8(s)
    if not s or s == "" then return "" end
    s = stripUTF8BOM(s)
    local okLen, validLen = pcall(utf8.len, s)
    if okLen and validLen ~= nil then
        return string.gsub(string.gsub(s, "\226\128\139", ""), "\194\160", " ")
    end
    local out = {}
    for i = 1, #s do
        local b = string.byte(s, i)
        if b < 128 then table.insert(out, string.char(b)) else table.insert(out, CP1251_MAP[b] or "") end
    end
    return table.concat(out)
end

local function trim(s)
    if not s then return "" end
    s = ensureValidUTF8(s)
    return string.match(s, "^%s*(.-%S)%s*$") or ""
end

local function utf8Lower(s)
    if not s then return "" end
    s = ensureValidUTF8(s)
    s = string.lower(s)
    for up, low in pairs(CYRILLIC_UPPER_TO_LOWER) do s = string.gsub(s, up, low) end
    return string.gsub(s, "ё", "е")
end

local function normalizeForMatch(s)
    s = utf8Lower(trim(s))
    s = string.gsub(s, "\226\128\147", "-")
    s = string.gsub(s, "\226\128\148", "-")
    s = string.gsub(s, "[_%-%.,!%?;:\"'%(%)%[%]%{%}]", " ")
    s = string.gsub(s, "%s+", " ")
    return trim(s)
end

local function namesMatch(a, b)
    if not a or not b then return false end
    local na = normalizeForMatch(string.gsub(a, "%.%w+$", ""))
    local nb = normalizeForMatch(string.gsub(b, "%.%w+$", ""))
    if na == "" or nb == "" then return false end
    if na == nb then return true end
    if #na >= 3 and #nb >= 3 then
        if string.find(na, nb, 1, true) or string.find(nb, na, 1, true) then return true end
    end
    return false
end

local function urlEncode(str)
    if not str then return "" end
    str = ensureValidUTF8(str)
    str = string.gsub(str, "\r?\n", "\r\n")
    str = string.gsub(str, "([^%w %-%_%.~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(str, " ", "+")
end

local function formatTime(seconds)
    seconds = math.max(0, math.floor(seconds or 0))
    return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function cleanTrackName(rawFilepath)
    local utf8Path = ensureValidUTF8(rawFilepath or "")
    local normalizedPath = string.gsub(utf8Path, "\\", "/")
    local filename = string.match(normalizedPath, "([^/]+)$") or utf8Path
    local baseNoExt = string.gsub(filename, "%.[^%.]+$", "")
    local cleanQuery = baseNoExt
    cleanQuery = string.gsub(cleanQuery, "%b()", "")
    cleanQuery = string.gsub(cleanQuery, "%b[]", "")
    cleanQuery = string.gsub(cleanQuery, "_", " ")
    cleanQuery = string.gsub(cleanQuery, "%s+", " ")
    cleanQuery = trim(cleanQuery)
    if cleanQuery == "" then cleanQuery = baseNoExt end
    return cleanQuery, filename, baseNoExt
end

local function safeGetCustomAsset(rawFilepath)
    if not getAsset then return nil end
    local hasNonAscii = string.find(rawFilepath, "[\128-\255]") ~= nil
    if not hasNonAscii then
        local ok, asset = pcall(getAsset, rawFilepath)
        if ok and asset and asset ~= "" then return asset end
    end
    if readfile and writefile then
        local ext = string.lower(string.match(rawFilepath, "%.(%w+)$") or "mp3")
        local hash = 5381
        for i = 1, #rawFilepath do hash = (hash * 33 + string.byte(rawFilepath, i)) % 0x7FFFFFFF end
        local safePath = string.format("%s/track_%08X.%s", CACHE_FOLDER, hash, ext)
        if not (isfile and isfile(safePath)) then
            local okRead, rawBytes = pcall(readfile, rawFilepath)
            if okRead and rawBytes and #rawBytes > 0 then pcall(writefile, safePath, rawBytes) end
        end
        local okSafe, safeAsset = pcall(getAsset, safePath)
        if okSafe and safeAsset and safeAsset ~= "" then return safeAsset end
    end
    local okFallback, assetFallback = pcall(getAsset, rawFilepath)
    if okFallback and assetFallback then return assetFallback end
    return nil
end

local function safeReadTextFile(rawPath)
    if not readfile or not rawPath then return nil end
    local ok, data = pcall(readfile, rawPath)
    if not ok or not data or #data == 0 then return nil end
    return trim(ensureValidUTF8(data))
end

if isfile and isfile(SPOTIFY_TOKEN_FILE) then
    SpotifyBearerToken = safeReadTextFile(SPOTIFY_TOKEN_FILE) or ""
end

local function scanTextFilesInFolder()
    TextFilesList = {}
    if not listfiles then return end
    local ok, files = pcall(listfiles, FOLDER_NAME)
    if not ok or type(files) ~= "table" then return end
    for _, rawPath in ipairs(files) do
        local utf8Norm = string.gsub(ensureValidUTF8(rawPath), "\\", "/")
        if not string.find(utf8Norm, "/_cache/") then
            local fname = string.match(utf8Norm, "([^/]+)$") or utf8Norm
            local ext = string.lower(string.match(fname, "%.(%w+)$") or "")
            local lowName = string.lower(fname)
            if (ext == "txt" or ext == "lrc") and lowName ~= "links.txt" and lowName ~= "spotify_token.txt" then
                local bNoExt = string.gsub(fname, "%.[^%.]+$", "")
                table.insert(TextFilesList, { rawPath = rawPath, fileName = fname, baseNoExt = bNoExt })
            end
        end
    end
end

local function fetchItunesCover(query)
    if not httpRequest or not query or query == "" then return "" end
    local url = "https://itunes.apple.com/search?term=" .. urlEncode(query) .. "&media=music&limit=1"
    local ok, res = pcall(function()
        return httpRequest({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Spectral/7.4" } })
    end)
    if not ok or not res or res.StatusCode ~= 200 or not res.Body then return "" end
    local okj, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
    if not okj or type(data) ~= "table" or type(data.results) ~= "table" or not data.results[1] then return "" end
    local art = data.results[1].artworkUrl100 or data.results[1].artworkUrl60
    if type(art) == "string" and art ~= "" then
        art = string.gsub(art, "100x100bb", "600x600bb")
        art = string.gsub(art, "60x60bb", "600x600bb")
        return art
    end
    return ""
end

local function resolveTrackCover(baseNoExt, remoteCoverUrl)
    local url = remoteCoverUrl
    if (not url or url == "") and baseNoExt and baseNoExt ~= "" then
        url = fetchItunesCover(baseNoExt)
    end
    if not url or url == "" then return DefaultCoverAsset end
    if SpotifyCoverCache[url] then return SpotifyCoverCache[url] end

    -- download jpg into executor workspace and load via getcustomasset
    if httpRequest and writefile then
        local hash = 5381
        for i = 1, #url do hash = (hash * 33 + string.byte(url, i)) % 0x7FFFFFFF end
        local cachePath = string.format("%s/cover_%08X.jpg", CACHE_FOLDER, hash)
        if not (isfile and isfile(cachePath)) then
            local okReq, res = pcall(function()
                return httpRequest({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
            end)
            if okReq and res and (res.StatusCode == 200 or res.StatusCode == 0) and res.Body and #res.Body > 500 then
                pcall(writefile, cachePath, res.Body)
            end
        end
        if getAsset then
            local asset = safeGetCustomAsset(cachePath)
            if asset and asset ~= "" then
                SpotifyCoverCache[url] = asset
                return asset
            end
            local okA, a2 = pcall(getAsset, cachePath)
            if okA and a2 and a2 ~= "" then
                SpotifyCoverCache[url] = a2
                return a2
            end
        end
    end
    return DefaultCoverAsset
end

-- ==========================================
-- LYRICS PARSERS & FETCHERS
-- ==========================================
local function parseLRC(lrcText)
    local lines = {}
    if not lrcText or lrcText == "" then return lines end
    lrcText = ensureValidUTF8(lrcText)
    for line in string.gmatch(lrcText, "[^\r\n]+") do
        local textPart = trim(string.gsub(line, "%[%d+:%d+%.?%d*%]", ""))
        for min, sec, frac in string.gmatch(line, "%[(%d+):(%d+)[%.%: ]?(%d*)%]") do
            if textPart ~= "" then
                local fVal = tonumber(frac) or 0
                local denom = (#frac == 3) and 1000 or ((#frac == 1) and 10 or 100)
                local t = math.max(0, tonumber(min) * 60 + tonumber(sec) + (fVal / denom))
                table.insert(lines, {time = t, text = textPart})
            end
        end
    end
    table.sort(lines, function(a, b) return a.time < b.time end)
    local filtered = {}
    for _, entry in ipairs(lines) do
        local prev = filtered[#filtered]
        if not prev or math.abs(entry.time - prev.time) > 0.15 then
            table.insert(filtered, entry)
        end
    end
    return filtered
end

local function buildTimedFromPlain(plainText, songDuration)
    local rawLines = {}
    if not plainText then return rawLines end
    plainText = ensureValidUTF8(plainText)
    for line in string.gmatch(plainText, "[^\r\n]+") do
        local trimmed = trim(line)
        if trimmed ~= "" and not string.match(trimmed, "^%[.*%]$") then
            table.insert(rawLines, {text = trimmed})
        end
    end
    local result = {}
    if #rawLines == 0 then return result end
    local usableDuration = (songDuration and songDuration > 15) and (songDuration - 3) or (#rawLines * 2.6)
    local step = math.clamp(usableDuration / #rawLines, 1.4, 3.8)
    local currentT = 0.8
    for _, item in ipairs(rawLines) do
        table.insert(result, {time = currentT, text = item.text})
        currentT = currentT + step
    end
    return result
end

local function fetchLRCLibBestMatch(query, trackDuration, artistName, trackTitleOnly)
    if not httpRequest then return nil, nil end
    local urlsToTry = {}
    if artistName and trackTitleOnly and artistName ~= "" and trackTitleOnly ~= "" then
        table.insert(urlsToTry, "https://lrclib.net/api/search?artist_name=" .. urlEncode(artistName) .. "&track_name=" .. urlEncode(trackTitleOnly))
    end
    table.insert(urlsToTry, "https://lrclib.net/api/search?q=" .. urlEncode(query))

    for _, lrcUrl in ipairs(urlsToTry) do
        local ok, res = pcall(function()
            return httpRequest({ Url = lrcUrl, Method = "GET", Headers = { ["User-Agent"] = "SpectralBench/7.4.1" } })
        end)
        if ok and res and res.StatusCode == 200 and res.Body then
            local decOk, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
            if decOk and type(data) == "table" and #data > 0 then
                local bestSynced, bestDiff = nil, 999999
                local fallbackPlain = nil
                for _, item in ipairs(data) do
                    if item.syncedLyrics and item.syncedLyrics ~= "" then
                        if trackDuration and trackDuration > 10 and item.duration then
                            local diff = math.abs(tonumber(item.duration) - trackDuration)
                            if diff < bestDiff then bestDiff = diff; bestSynced = ensureValidUTF8(item.syncedLyrics) end
                        else
                            bestSynced = ensureValidUTF8(item.syncedLyrics); break
                        end
                    elseif item.plainLyrics and item.plainLyrics ~= "" and not fallbackPlain then
                        fallbackPlain = ensureValidUTF8(item.plainLyrics)
                    end
                end
                if bestSynced then return bestSynced, true end
                if fallbackPlain then return fallbackPlain, false end
            end
        end
    end
    return nil, nil
end

-- ==========================================
-- 3D LYRICS ENGINE
-- ==========================================
local function clearActive3DNodes()
    for _, child in ipairs(WorldFolder:GetChildren()) do
        pcall(function() child:Destroy() end)
    end
end

local function splitLyricInTwo(text)
    local words = {}
    for word in string.gmatch(text or "", "%S+") do table.insert(words, word) end
    if #words <= 2 then return text or "", "" end
    local left, right = {}, {}
    local midpoint = math.ceil(#words / 2)
    for n, word in ipairs(words) do
        table.insert(n <= midpoint and left or right, word)
    end
    return table.concat(left, " "), table.concat(right, " ")
end

local function spawnSingle3DPart(partText, sideSign, holdDuration, generationTag)
    if not ScriptAlive or not partText or partText == "" then return end
    if generationTag and generationTag ~= PlaybackGeneration then return end

    clearActive3DNodes()

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local rightVec = root.CFrame.RightVector
    local lookVec = root.CFrame.LookVector
    local sideOffset = rightVec * (sideSign * 6.8)
    local spawnPos = root.Position + Vector3.new(0, 2.5, 0) + (lookVec * 3.0) + sideOffset

    local T = rawget(_G, "GoatLoseMusicTheme")
    local leftCol = (T and T.LyricLeft) or C.accentGlow
    local rightCol = (T and T.LyricRight) or Color3.fromRGB(165, 235, 255)
    local primaryColor = (sideSign < 0) and leftCol or rightCol
    local accentColor  = (sideSign < 0) and C.accent or C.accentAlt
    local tiltAngle    = (sideSign < 0) and -5 or 5

    local anchor = Instance.new("Part")
    anchor.Name = "SpectralLyric3DNode"
    anchor.Size = Vector3.new(0.2, 0.2, 0.2)
    anchor.Position = spawnPos - Vector3.new(0, 1.1, 0)
    anchor.Anchored = true
    anchor.CanCollide = false
    anchor.Parent = WorldFolder

    local bGui = Instance.new("BillboardGui")
    bGui.Adornee = anchor
    bGui.Size = UDim2.new(17.5, 0, 4.4, 0)
    bGui.AlwaysOnTop = true
    bGui.LightInfluence = 0
    bGui.MaxDistance = 140
    bGui.Parent = anchor

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 1, 0)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.BackgroundTransparency = 1
    holder.Rotation = tiltAngle * 2.0
    holder.Parent = bGui

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 0.18
    uiScale.Parent = holder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = partText
    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextTransparency = 1
    label.TextScaled = true
    label.TextWrapped = true
    label.Parent = holder

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, primaryColor),
        ColorSequenceKeypoint.new(1, accentColor)
    })
    grad.Rotation = 90
    grad.Parent = label

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(5, 7, 14)
    stroke.Thickness = 3.2
    stroke.Transparency = 0.05
    stroke.Parent = label

    TweenService:Create(uiScale, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.0}):Play()
    TweenService:Create(label, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    TweenService:Create(anchor, TweenInfo.new(holdDuration + 0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
        Position = spawnPos + Vector3.new(0, 1.35, 0)
    }):Play()

    task.delay(holdDuration, function()
        if not anchor or not anchor.Parent then return end
        TweenService:Create(uiScale, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.55}):Play()
        TweenService:Create(label, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        task.wait(0.24)
        if anchor and anchor.Parent then anchor:Destroy() end
    end)
end

local function spawn3DLyricSequence(lyricText, lineDurationSec, generationTag)
    if not ScriptAlive or not lyricText or lyricText == "" then return end
    lyricText = ensureValidUTF8(lyricText)

    local totalWindow = math.clamp(lineDurationSec or 2.6, 0.9, 5.2)
    local leftPart, rightPart = splitLyricInTwo(lyricText)

    if rightPart == "" then
        local side = NextSpawnSide
        NextSpawnSide = -NextSpawnSide
        spawnSingle3DPart(leftPart, side, math.max(0.55, totalWindow * 0.90), generationTag)
    else
        local firstSide = NextSpawnSide
        local secondSide = -firstSide
        NextSpawnSide = firstSide

        local halfTime = math.max(0.42, totalWindow * 0.47)
        spawnSingle3DPart(leftPart, firstSide, halfTime, generationTag)

        task.delay(halfTime, function()
            if not ScriptAlive or (generationTag and generationTag ~= PlaybackGeneration) then return end
            if not IsPlaying and not SpotifyIsPlaying then return end
            spawnSingle3DPart(rightPart, secondSide, halfTime, generationTag)
        end)
    end
end

-- ==========================================
-- UI CONSTRUCTION
-- ==========================================
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or C.accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpectralFolderPlayerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 12000
local _guiParent = nil
pcall(function()
    if gethui then _guiParent = gethui() end
end)
if not _guiParent then
    pcall(function() _guiParent = CoreGui end)
end
if not _guiParent then
    pcall(function() _guiParent = LocalPlayer:WaitForChild("PlayerGui") end)
end
ScreenGui.Parent = _guiParent
ScreenGui.Enabled = true

local MiniPlayer = Instance.new("Frame")
MiniPlayer.Size = UDim2.new(0, 395, 0, 128)
MiniPlayer.Position = UDim2.new(1, -415, 0, 20)
MiniPlayer.BackgroundColor3 = C.bg1
MiniPlayer.BorderSizePixel = 0
MiniPlayer.Active = true
MiniPlayer.Draggable = true
MiniPlayer.Parent = ScreenGui
makeCorner(MiniPlayer, 14)
makeStroke(MiniPlayer, C.accent, 1.4, 0.2)

local CoverFrame = Instance.new("Frame")
CoverFrame.Size = UDim2.new(0, 74, 0, 74)
CoverFrame.Position = UDim2.new(0, 14, 0, 14)
CoverFrame.BackgroundColor3 = C.bg3
CoverFrame.BorderSizePixel = 0
CoverFrame.Parent = MiniPlayer
makeCorner(CoverFrame, 37)
makeStroke(CoverFrame, C.accent, 1.6, 0.25)

local CoverImage = Instance.new("ImageLabel")
CoverImage.Size = UDim2.new(1, 0, 1, 0)
CoverImage.BackgroundTransparency = 1
CoverImage.Image = DefaultCoverAsset
CoverImage.ScaleType = Enum.ScaleType.Crop
CoverImage.Parent = CoverFrame
makeCorner(CoverImage, 37)

local MiniTitle = Instance.new("TextLabel")
MiniTitle.Size = UDim2.new(1, -110, 0, 20)
MiniTitle.Position = UDim2.new(0, 98, 0, 11)
MiniTitle.BackgroundTransparency = 1
MiniTitle.Text = "Ожидание трека..."
MiniTitle.Font = Enum.Font.GothamBold
MiniTitle.TextSize = 14
MiniTitle.TextColor3 = C.text
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
MiniTitle.TextTruncate = Enum.TextTruncate.AtEnd
MiniTitle.Parent = MiniPlayer

local SourceBadge = Instance.new("TextLabel")
SourceBadge.Size = UDim2.new(0, 185, 0, 14)
SourceBadge.Position = UDim2.new(0, 98, 0, 32)
SourceBadge.BackgroundTransparency = 1
SourceBadge.Text = "ГОТОВ"
SourceBadge.Font = Enum.Font.Code
SourceBadge.TextSize = 10
SourceBadge.TextColor3 = C.accentAlt
SourceBadge.TextXAlignment = Enum.TextXAlignment.Left
SourceBadge.Parent = MiniPlayer

local DurationLabel = Instance.new("TextLabel")
DurationLabel.Size = UDim2.new(0, 90, 0, 14)
DurationLabel.Position = UDim2.new(1, -102, 0, 32)
DurationLabel.BackgroundTransparency = 1
DurationLabel.Text = "00:00 / 00:00"
DurationLabel.Font = Enum.Font.Code
DurationLabel.TextSize = 10
DurationLabel.TextColor3 = C.textMid
DurationLabel.TextXAlignment = Enum.TextXAlignment.Right
DurationLabel.Parent = MiniPlayer

local ProgressBg = Instance.new("TextButton")
ProgressBg.Size = UDim2.new(1, -110, 0, 8)
ProgressBg.Position = UDim2.new(0, 98, 0, 49)
ProgressBg.BackgroundColor3 = C.bg3
ProgressBg.BorderSizePixel = 0
ProgressBg.Text = ""
ProgressBg.AutoButtonColor = false
ProgressBg.Parent = MiniPlayer
makeCorner(ProgressBg, 4)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = C.accent
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBg
makeCorner(ProgressFill, 4)

local MiniLyric = Instance.new("TextLabel")
MiniLyric.Size = UDim2.new(1, -110, 0, 20)
MiniLyric.Position = UDim2.new(0, 98, 0, 62)
MiniLyric.BackgroundTransparency = 1
MiniLyric.Text = "♪ Ожидание... ♪"
MiniLyric.Font = Enum.Font.GothamBold
MiniLyric.TextSize = 12
MiniLyric.TextColor3 = C.accentGlow
MiniLyric.TextXAlignment = Enum.TextXAlignment.Left
MiniLyric.TextTruncate = Enum.TextTruncate.AtEnd
MiniLyric.Parent = MiniPlayer

local MiniHintBg = Instance.new("Frame")
MiniHintBg.Size = UDim2.new(1, 0, 0, 28)
MiniHintBg.Position = UDim2.new(0, 0, 1, -28)
MiniHintBg.BackgroundColor3 = C.bg0
MiniHintBg.BackgroundTransparency = 0.2
MiniHintBg.BorderSizePixel = 0
MiniHintBg.Parent = MiniPlayer
makeCorner(MiniHintBg, 14)

local MiniHint = Instance.new("TextLabel")
MiniHint.Size = UDim2.new(1, -115, 1, 0)
MiniHint.Position = UDim2.new(0, 12, 0, 0)
MiniHint.BackgroundTransparency = 1
MiniHint.Text = "[←/→] Трек  [↓] Пауза  [Клик] Перемотка"
MiniHint.Font = Enum.Font.Code
MiniHint.TextSize = 10
MiniHint.TextColor3 = C.textDim
MiniHint.TextXAlignment = Enum.TextXAlignment.Left
MiniHint.Parent = MiniHintBg

local MiniPrevBtn = Instance.new("TextButton")
MiniPrevBtn.Size = UDim2.new(0, 26, 0, 20)
MiniPrevBtn.Position = UDim2.new(1, -90, 0.5, -10)
MiniPrevBtn.BackgroundColor3 = C.bg2
MiniPrevBtn.Text = "⏮"
MiniPrevBtn.Font = Enum.Font.GothamBold
MiniPrevBtn.TextSize = 11
MiniPrevBtn.TextColor3 = C.text
MiniPrevBtn.Parent = MiniHintBg
makeCorner(MiniPrevBtn, 5)

local MiniPlayBtn = Instance.new("TextButton")
MiniPlayBtn.Size = UDim2.new(0, 26, 0, 20)
MiniPlayBtn.Position = UDim2.new(1, -60, 0.5, -10)
MiniPlayBtn.BackgroundColor3 = C.accent
MiniPlayBtn.Text = "⏯"
MiniPlayBtn.Font = Enum.Font.GothamBold
MiniPlayBtn.TextSize = 11
MiniPlayBtn.TextColor3 = C.bg0
MiniPlayBtn.Parent = MiniHintBg
makeCorner(MiniPlayBtn, 5)

local MiniNextBtn = Instance.new("TextButton")
MiniNextBtn.Size = UDim2.new(0, 26, 0, 20)
MiniNextBtn.Position = UDim2.new(1, -30, 0.5, -10)
MiniNextBtn.BackgroundColor3 = C.bg2
MiniNextBtn.Text = "⏭"
MiniNextBtn.Font = Enum.Font.GothamBold
MiniNextBtn.TextSize = 11
MiniNextBtn.TextColor3 = C.text
MiniNextBtn.Parent = MiniHintBg
makeCorner(MiniNextBtn, 5)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 440, 0, 465)
MainFrame.Position = UDim2.new(0.5, -220, 0.16, 0)
MainFrame.BackgroundColor3 = C.bg1
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
makeCorner(MainFrame, 14)
makeStroke(MainFrame, C.accent, 1.3, 0.25)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -120, 0, 40)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ SPECTRAL v7.4.1  //  FULL UI RESTORED"
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 13
TitleLabel.TextColor3 = C.accentGlow
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 86, 0, 26)
RefreshBtn.Position = UDim2.new(1, -96, 0, 7)
RefreshBtn.BackgroundColor3 = C.bg2
RefreshBtn.TextColor3 = C.accent
RefreshBtn.Text = "↻ ОБНОВИТЬ"
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 10
RefreshBtn.Parent = MainFrame
makeCorner(RefreshBtn, 7)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -32, 0, 18)
StatusLabel.Position = UDim2.new(0, 16, 0, 42)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Поиск Spotify и локальных треков..."
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 11
StatusLabel.TextColor3 = C.textMid
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusLabel.Parent = MainFrame

local SpotifyRow = Instance.new("Frame")
SpotifyRow.Size = UDim2.new(1, -28, 0, 36)
SpotifyRow.Position = UDim2.new(0, 14, 0, 64)
SpotifyRow.BackgroundColor3 = C.bg2
SpotifyRow.BorderSizePixel = 0
SpotifyRow.Parent = MainFrame
makeCorner(SpotifyRow, 8)
makeStroke(SpotifyRow, C.spotifyGreen, 1, 0.45)

local SpotifyTokenBox = Instance.new("TextBox")
SpotifyTokenBox.Size = UDim2.new(1, -152, 0, 24)
SpotifyTokenBox.Position = UDim2.new(0, 6, 0.5, -12)
SpotifyTokenBox.BackgroundColor3 = C.bg0
SpotifyTokenBox.TextColor3 = C.text
SpotifyTokenBox.PlaceholderText = "Запусти spotify_bridge.py ИЛИ вставь Token"
SpotifyTokenBox.PlaceholderColor3 = C.textDim
SpotifyTokenBox.Text = SpotifyBearerToken
SpotifyTokenBox.Font = Enum.Font.Code
SpotifyTokenBox.TextSize = 10
SpotifyTokenBox.ClearTextOnFocus = false
SpotifyTokenBox.TextXAlignment = Enum.TextXAlignment.Left
SpotifyTokenBox.TextTruncate = Enum.TextTruncate.AtEnd
SpotifyTokenBox.Parent = SpotifyRow
makeCorner(SpotifyTokenBox, 6)

local SpotifyToggleBtn = Instance.new("TextButton")
SpotifyToggleBtn.Size = UDim2.new(0, 134, 0, 24)
SpotifyToggleBtn.Position = UDim2.new(1, -140, 0.5, -12)
SpotifyToggleBtn.BackgroundColor3 = C.bg3
SpotifyToggleBtn.TextColor3 = C.spotifyGreen
SpotifyToggleBtn.Text = "🎧 SPOTIFY: АВТО"
SpotifyToggleBtn.Font = Enum.Font.GothamBlack
SpotifyToggleBtn.TextSize = 10
SpotifyToggleBtn.Parent = SpotifyRow
makeCorner(SpotifyToggleBtn, 6)

local FileList = Instance.new("ScrollingFrame")
FileList.Size = UDim2.new(1, -28, 0, 235)
FileList.Position = UDim2.new(0, 14, 0, 108)
FileList.BackgroundColor3 = C.bg0
FileList.BorderSizePixel = 0
FileList.ScrollBarThickness = 4
FileList.ScrollBarImageColor3 = C.accent
FileList.CanvasSize = UDim2.new(0, 0, 0, 0)
FileList.AutomaticCanvasSize = Enum.AutomaticSize.Y
FileList.Parent = MainFrame
makeCorner(FileList, 10)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = FileList

local SyncRow = Instance.new("Frame")
SyncRow.Size = UDim2.new(1, -28, 0, 32)
SyncRow.Position = UDim2.new(0, 14, 0, 350)
SyncRow.BackgroundColor3 = C.bg2
SyncRow.BorderSizePixel = 0
SyncRow.Parent = MainFrame
makeCorner(SyncRow, 8)

local OffsetTitle = Instance.new("TextLabel")
OffsetTitle.Size = UDim2.new(0, 140, 1, 0)
OffsetTitle.Position = UDim2.new(0, 12, 0, 0)
OffsetTitle.BackgroundTransparency = 1
OffsetTitle.Text = "СДВИГ ТЕКСТА: +0.0s"
OffsetTitle.Font = Enum.Font.Code
OffsetTitle.TextSize = 11
OffsetTitle.TextColor3 = C.accentGlow
OffsetTitle.TextXAlignment = Enum.TextXAlignment.Left
OffsetTitle.Parent = SyncRow

local OffsetMinusBtn = Instance.new("TextButton")
OffsetMinusBtn.Size = UDim2.new(0, 48, 0, 22)
OffsetMinusBtn.Position = UDim2.new(1, -110, 0.5, -11)
OffsetMinusBtn.BackgroundColor3 = C.bg3
OffsetMinusBtn.Text = "-0.2s"
OffsetMinusBtn.Font = Enum.Font.Code
OffsetMinusBtn.TextSize = 10
OffsetMinusBtn.TextColor3 = C.text
OffsetMinusBtn.Parent = SyncRow
makeCorner(OffsetMinusBtn, 5)

local OffsetPlusBtn = Instance.new("TextButton")
OffsetPlusBtn.Size = UDim2.new(0, 48, 0, 22)
OffsetPlusBtn.Position = UDim2.new(1, -56, 0.5, -11)
OffsetPlusBtn.BackgroundColor3 = C.bg3
OffsetPlusBtn.Text = "+0.2s"
OffsetPlusBtn.Font = Enum.Font.Code
OffsetPlusBtn.TextSize = 10
OffsetPlusBtn.TextColor3 = C.text
OffsetPlusBtn.Parent = SyncRow
makeCorner(OffsetPlusBtn, 5)

OffsetMinusBtn.MouseButton1Click:Connect(function()
    SyncOffsetSec = SyncOffsetSec - 0.2
    LastTriggeredIndex = 0
    OffsetTitle.Text = string.format("СДВИГ ТЕКСТА: %+0.1fs", SyncOffsetSec)
end)

OffsetPlusBtn.MouseButton1Click:Connect(function()
    SyncOffsetSec = SyncOffsetSec + 0.2
    LastTriggeredIndex = 0
    OffsetTitle.Text = string.format("СДВИГ ТЕКСТА: %+0.1fs", SyncOffsetSec)
end)

local PrevMainBtn = Instance.new("TextButton")
PrevMainBtn.Size = UDim2.new(0.23, -10, 0, 34)
PrevMainBtn.Position = UDim2.new(0, 14, 0, 390)
PrevMainBtn.BackgroundColor3 = C.bg2
PrevMainBtn.TextColor3 = C.text
PrevMainBtn.Text = "⏮ ПРЕД"
PrevMainBtn.Font = Enum.Font.GothamBlack
PrevMainBtn.TextSize = 11
PrevMainBtn.Parent = MainFrame
makeCorner(PrevMainBtn, 8)

local PauseBtn = Instance.new("TextButton")
PauseBtn.Size = UDim2.new(0.32, -8, 0, 34)
PauseBtn.Position = UDim2.new(0.23, 8, 0, 390)
PauseBtn.BackgroundColor3 = C.accent
PauseBtn.TextColor3 = C.bg0
PauseBtn.Text = "⏯ ПАУЗА / ПЛЕЙ"
PauseBtn.Font = Enum.Font.GothamBlack
PauseBtn.TextSize = 11
PauseBtn.Parent = MainFrame
makeCorner(PauseBtn, 8)

local NextMainBtn = Instance.new("TextButton")
NextMainBtn.Size = UDim2.new(0.23, -8, 0, 34)
NextMainBtn.Position = UDim2.new(0.55, 4, 0, 390)
NextMainBtn.BackgroundColor3 = C.bg2
NextMainBtn.TextColor3 = C.text
NextMainBtn.Text = "СЛЕД ⏭"
NextMainBtn.Font = Enum.Font.GothamBlack
NextMainBtn.TextSize = 11
NextMainBtn.Parent = MainFrame
makeCorner(NextMainBtn, 8)

local StopAllBtn = Instance.new("TextButton")
StopAllBtn.Size = UDim2.new(0.22, -14, 0, 34)
StopAllBtn.Position = UDim2.new(0.78, 0, 0, 390)
StopAllBtn.BackgroundColor3 = C.bg3
StopAllBtn.TextColor3 = C.red
StopAllBtn.Text = "⏹ СТОП"
StopAllBtn.Font = Enum.Font.GothamBlack
StopAllBtn.TextSize = 11
StopAllBtn.Parent = MainFrame
makeCorner(StopAllBtn, 8)

-- ==========================================
-- PLAYBACK & DRIFT-CORRECTED SYNC ENGINE
-- ==========================================
local playLocalFile

local function stopCurrentTrack()
    PlaybackGeneration += 1
    IsPlaying = false
    SpotifyIsPlaying = false
    LastTriggeredIndex = 0
    LastSpawnedClock = -999
    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end
    if CurrentSound then
        pcall(function() CurrentSound:Stop() end)
        pcall(function() CurrentSound:Destroy() end)
        CurrentSound = nil
    end
    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name == "SpectralLocalMP3" then
            pcall(function() v:Stop(); v:Destroy() end)
        end
    end
    clearActive3DNodes()
end

_G.SpectralCleanup = function()
    ScriptAlive = false
    SpotifyLiveEnabled = false
    stopCurrentTrack()
    if InputConnection then InputConnection:Disconnect(); InputConnection = nil end
    pcall(function() ContextActionService:UnbindAction("SpectralMiniPlayerArrows") end)
    pcall(function() ScreenGui:Destroy() end)
    pcall(function() WorldFolder:Destroy() end)
end

local function getActiveLyricIndex(adjustedTime)
    local idx = 0
    for i = 1, #ParsedLyrics do
        if adjustedTime >= ParsedLyrics[i].time then idx = i else break end
    end
    return idx
end

local function sendSpotifyCommand(cmd, valMs)
    if not httpRequest then return false end
    local url = "http://127.0.0.1:29481/cmd?action=" .. urlEncode(cmd)
    if valMs then url = url .. "&ms=" .. tostring(math.floor(valMs)) end
    local okLocal, resLocal = pcall(function() return httpRequest({ Url = url, Method = "GET" }) end)
    if okLocal and resLocal and resLocal.StatusCode == 200 then return true end

    local token = trim(string.gsub(SpotifyTokenBox.Text or SpotifyBearerToken, "^Bearer%s+", ""))
    if token ~= "" then
        local apiEndpoint, apiMethod = nil, "POST"
        if cmd == "next" then apiEndpoint = "https://api.spotify.com/v1/me/player/next"
        elseif cmd == "prev" then apiEndpoint = "https://api.spotify.com/v1/me/player/previous"
        elseif cmd == "playpause" then
            apiMethod = "PUT"
            apiEndpoint = SpotifyIsPlaying and "https://api.spotify.com/v1/me/player/pause" or "https://api.spotify.com/v1/me/player/play"
        elseif cmd == "seek" and valMs then
            apiMethod = "PUT"
            apiEndpoint = "https://api.spotify.com/v1/me/player/seek?position_ms=" .. tostring(math.floor(valMs))
        end
        if apiEndpoint then
            pcall(function() httpRequest({ Url = apiEndpoint, Method = apiMethod, Headers = { ["Authorization"] = "Bearer " .. token } }) end)
            return true
        end
    end
    return false
end

ProgressBg.MouseButton1Down:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    local relX = math.clamp((mousePos.X - ProgressBg.AbsolutePosition.X) / math.max(1, ProgressBg.AbsoluteSize.X), 0, 1)

    if SpotifyLiveEnabled then
        local targetSec = relX * math.max(1, SpotifyDuration)
        SpotifyAnchorPos = targetSec
        SpotifyAnchorTick = tick()
        LastTriggeredIndex = 0
        clearActive3DNodes()
        sendSpotifyCommand("seek", targetSec * 1000)
    elseif CurrentSound and CurrentSound.TimeLength > 0 then
        CurrentSound.TimePosition = relX * CurrentSound.TimeLength
        LastTriggeredIndex = 0
        clearActive3DNodes()
    end
end)

local function parseBridgePayload(rawJson)
    if not rawJson or rawJson == "" then return nil end
    local okDec, data = pcall(function() return HttpService:JSONDecode(rawJson) end)
    if okDec and type(data) == "table" and data.title and data.title ~= "" then
        local artist = ensureValidUTF8(data.artist or "")
        local title = ensureValidUTF8(data.title or "")
        local full = (artist ~= "") and (artist .. " - " .. title) or title
        return {
            id = tostring(data.id or full),
            artist = artist,
            title = title,
            fullTitle = full,
            progressSec = (tonumber(data.progress_ms) or 0) / 1000.0,
            durationSec = math.max(1, (tonumber(data.duration_ms) or 180000) / 1000.0),
            isPlaying = data.is_playing == true,
            coverUrl = data.cover_url or "",
            lyrics = data.lyrics or {}
        }
    end
    return nil
end

local function querySpotifyCurrentlyPlaying()
    if httpRequest then
        local okLocal, resLocal = pcall(function() return httpRequest({ Url = "http://127.0.0.1:29481/status", Method = "GET" }) end)
        if okLocal and resLocal and resLocal.StatusCode == 200 and resLocal.Body then
            local parsed = parseBridgePayload(resLocal.Body)
            if parsed then return parsed end
        end
    end

    if isfile then
        for _, path in ipairs({SPOTIFY_BRIDGE_FILE, SPOTIFY_BRIDGE_ROOT}) do
            if isfile(path) then
                local parsed = parseBridgePayload(safeReadTextFile(path))
                if parsed then return parsed end
            end
        end
    end

    return nil, "Spotify не найден -> локальные MP3"
end

local function loadLyricsForSpotifyTrack(spState, generation)
    local newParsed = {}
    local sourceTag = "Spotify Bridge"
    if spState.lyrics and #spState.lyrics > 0 then
        for _, l in ipairs(spState.lyrics) do
            table.insert(newParsed, {time = tonumber(l.time) or 0, text = ensureValidUTF8(l.text)})
        end
        table.sort(newParsed, function(a, b) return a.time < b.time end)
    else
        local lrcData, isSynced = fetchLRCLibBestMatch(spState.fullTitle, spState.durationSec, spState.artist, spState.title)
        if lrcData then
            newParsed = isSynced and parseLRC(lrcData) or buildTimedFromPlain(lrcData, spState.durationSec)
            sourceTag = isSynced and "LRCLIB Synced" or "LRCLIB TXT"
        end
    end

    if not ScriptAlive or generation ~= PlaybackGeneration or not SpotifyLiveEnabled then return end
    CoverImage.Image = resolveTrackCover(spState.fullTitle, spState.coverUrl)
    ParsedLyrics = newParsed
    LastTriggeredIndex = 0
    NextSpawnSide = -1
    SourceBadge.Text = (#ParsedLyrics > 0) and sourceTag or "SPOTIFY (БЕЗ ТЕКСТА)"
    StatusLabel.Text = string.format("[%s] • %d строк • %s", sourceTag, #ParsedLyrics, spState.fullTitle)
end

local function fallbackToLocalPlaylist(reasonText)
    SpotifyLiveEnabled = false
    SpotifyIsPlaying = false
    SpotifyTrackId = ""
    SpotifyToggleBtn.BackgroundColor3 = C.bg3
    SpotifyToggleBtn.TextColor3 = C.spotifyGreen
    SpotifyToggleBtn.Text = "🎧 SPOTIFY: АВТО"
    SourceBadge.TextColor3 = C.accentAlt

    if #AudioPlaylist > 0 then
        local targetIdx = math.clamp(CurrentTrackIndex, 1, #AudioPlaylist)
        StatusLabel.Text = (reasonText or "Spotify не активен") .. " — играю локальный MP3"
        playLocalFile(AudioPlaylist[targetIdx], targetIdx)
    else
        stopCurrentTrack()
        StatusLabel.Text = (reasonText or "Spotify не активен")
        SourceBadge.Text = "ОЖИДАНИЕ"
    end
end

local function startSpotifyLiveSync()
    local initialState, errReason = querySpotifyCurrentlyPlaying()
    if not initialState then
        fallbackToLocalPlaylist(errReason)
        return
    end

    stopCurrentTrack()
    SpotifyLiveEnabled = true
    SpotifyTrackId = ""
    local generation = PlaybackGeneration

    SpotifyToggleBtn.BackgroundColor3 = C.spotifyGreen
    SpotifyToggleBtn.TextColor3 = C.bg0
    SpotifyToggleBtn.Text = "🎧 SPOTIFY: LIVE"
    SourceBadge.Text = "SPOTIFY ПОДКЛЮЧЕН"
    SourceBadge.TextColor3 = C.spotifyGreen

    task.spawn(function()
        local missedPolls = 0
        while ScriptAlive and SpotifyLiveEnabled and generation == PlaybackGeneration do
            local reqStart = tick()
            local spState, errMsg = querySpotifyCurrentlyPlaying()
            local latency = (tick() - reqStart) * 0.5

            if not ScriptAlive or not SpotifyLiveEnabled or generation ~= PlaybackGeneration then break end

            if spState then
                missedPolls = 0
                SpotifyDuration = spState.durationSec

                local targetPos = spState.progressSec + (spState.isPlaying and latency or 0)
                local currentEstimated = SpotifyAnchorPos + (SpotifyIsPlaying and (tick() - SpotifyAnchorTick) or 0)
                local drift = targetPos - currentEstimated

                if math.abs(drift) > 1.2 or SpotifyIsPlaying ~= spState.isPlaying then
                    SpotifyAnchorPos = targetPos
                    SpotifyAnchorTick = tick()
                    LastTriggeredIndex = 0
                elseif math.abs(drift) > 0.15 then
                    SpotifyAnchorPos = currentEstimated + (drift * 0.25)
                    SpotifyAnchorTick = tick()
                end

                SpotifyIsPlaying = spState.isPlaying
                IsPlaying = spState.isPlaying
                MiniTitle.TextColor3 = SpotifyIsPlaying and C.text or C.textMid

                if spState.id ~= SpotifyTrackId then
                    SpotifyTrackId = spState.id
                    ActiveTrackName = spState.fullTitle
                    MiniTitle.Text = spState.fullTitle
                    SourceBadge.Text = "ПОИСК ТЕКСТА..."
                    clearActive3DNodes()
                    -- cover ASAP into the circle
                    task.spawn(function()
                        local cover = resolveTrackCover(spState.fullTitle, spState.coverUrl or "")
                        if CoverImage and generation == PlaybackGeneration then
                            CoverImage.Image = cover
                        end
                    end)
                    task.spawn(function() loadLyricsForSpotifyTrack(spState, generation) end)
                end
            else
                missedPolls = missedPolls + 1
                if missedPolls >= 3 then
                    fallbackToLocalPlaylist(errMsg or "Spotify закрыт")
                    break
                end
            end
            task.wait(0.6)
        end
    end)

    RenderConnection = RunService.Heartbeat:Connect(function(dt)
        if not ScriptAlive or not SpotifyLiveEnabled or generation ~= PlaybackGeneration then return end
        local now = tick()
        local pos = math.clamp(SpotifyAnchorPos + (SpotifyIsPlaying and (now - SpotifyAnchorTick) or 0), 0, math.max(1, SpotifyDuration))
        ProgressFill.Size = UDim2.new(math.clamp(pos / math.max(1, SpotifyDuration), 0, 1), 0, 1, 0)
        DurationLabel.Text = formatTime(pos) .. " / " .. formatTime(SpotifyDuration)
        if SpotifyIsPlaying then CoverImage.Rotation = (CoverImage.Rotation + dt * 65) % 360 end

        if not SpotifyIsPlaying or #ParsedLyrics == 0 then return end
        local syncedClock = pos - SyncOffsetSec
        local activeIdx = getActiveLyricIndex(syncedClock)

        if activeIdx > 0 and activeIdx ~= LastTriggeredIndex and math.abs(now - LastSpawnedClock) > 0.22 then
            LastTriggeredIndex = activeIdx
            LastSpawnedClock = now
            local activeEntry = ParsedLyrics[activeIdx]
            local nextEntry = ParsedLyrics[activeIdx + 1]
            if activeEntry then
                local windowToNext = nextEntry and math.clamp(nextEntry.time - activeEntry.time, 0.9, 5.2) or 2.8
                spawn3DLyricSequence(activeEntry.text, windowToNext, generation)
                MiniLyric.Text = activeEntry.text
            end
        end
    end)
end

task.spawn(function()
    while ScriptAlive do
        if not SpotifyLiveEnabled then
            local spCheck = querySpotifyCurrentlyPlaying()
            if spCheck and spCheck.isPlaying and ScriptAlive then
                startSpotifyLiveSync()
            end
        end
        task.wait(2.5)
    end
end)

SpotifyToggleBtn.MouseButton1Click:Connect(function()
    if SpotifyLiveEnabled then
        fallbackToLocalPlaylist("Переключено на локальные MP3")
    else
        startSpotifyLiveSync()
    end
end)

-- ==========================================
-- LOCAL MP3 PLAYBACK
-- ==========================================
playLocalFile = function(trackEntry, indexInPlaylist)
    if not ScriptAlive or not trackEntry or not getAsset then return end
    if indexInPlaylist then CurrentTrackIndex = indexInPlaylist end

    stopCurrentTrack()
    local generation = PlaybackGeneration

    local rawFilepath = trackEntry.rawPath
    local searchQuery = trackEntry.cleanName

    ActiveTrackName = searchQuery
    MiniTitle.Text = searchQuery
    MiniTitle.TextColor3 = C.text
    SourceBadge.Text = "ЗАГРУЗКА MP3..."
    task.spawn(function()
        local cover = resolveTrackCover(searchQuery, "")
        if CoverImage and generation == PlaybackGeneration then
            CoverImage.Image = cover
        end
    end)

    local assetUrl = safeGetCustomAsset(rawFilepath)
    if not assetUrl then
        StatusLabel.Text = "Ошибка чтения MP3: " .. trackEntry.displayName
        return
    end

    CurrentSound = Instance.new("Sound")
    CurrentSound.Name = "SpectralLocalMP3"
    CurrentSound.SoundId = assetUrl
    CurrentSound.Volume = CurrentVolume
    CurrentSound.Looped = false
    CurrentSound.Parent = Workspace
    local sound = CurrentSound

    sound.Ended:Connect(function()
        if ScriptAlive and generation == PlaybackGeneration and CurrentSound == sound and #AudioPlaylist > 0 then
            local nextIdx = (CurrentTrackIndex % #AudioPlaylist) + 1
            task.defer(function() playLocalFile(AudioPlaylist[nextIdx], nextIdx) end)
        end
    end)

    local t0 = tick()
    while ScriptAlive and sound.Parent and not sound.IsLoaded and (tick() - t0) < 4.0 do
        if generation ~= PlaybackGeneration then return end
        task.wait(0.05)
    end
    if not ScriptAlive or generation ~= PlaybackGeneration or CurrentSound ~= sound then return end

    local trackDuration = (sound.TimeLength and sound.TimeLength > 0) and sound.TimeLength or 180
    StatusLabel.Text = "Ищу текст: " .. searchQuery

    task.spawn(function()
        local artistPart, titlePart = string.match(searchQuery, "^(.-)%s+%-%s+(.+)$")
        local lrcData, isSynced = fetchLRCLibBestMatch(searchQuery, trackDuration, artistPart, titlePart)
        local newParsedLyrics = {}
        local sourceTag = "Без текста"
        if lrcData then
            newParsedLyrics = isSynced and parseLRC(lrcData) or buildTimedFromPlain(lrcData, trackDuration)
            sourceTag = isSynced and "LRCLIB Synced" or "LRCLIB TXT"
        end

        if not ScriptAlive or generation ~= PlaybackGeneration or CurrentSound ~= sound then return end

        ParsedLyrics = newParsedLyrics
        SourceBadge.Text = sourceTag
        StatusLabel.Text = string.format("[%s] • %d строк • %s", sourceTag, #ParsedLyrics, ActiveTrackName)

        LastTriggeredIndex = 0
        NextSpawnSide = -1
        sound.TimePosition = 0
        sound:Play()
        IsPlaying = true

        RenderConnection = RunService.Heartbeat:Connect(function(dt)
            if not ScriptAlive or generation ~= PlaybackGeneration or CurrentSound ~= sound or not sound.Parent then return end
            local pos = sound.TimePosition
            local len = (sound.TimeLength > 0) and sound.TimeLength or trackDuration or 1
            ProgressFill.Size = UDim2.new(math.clamp(pos / len, 0, 1), 0, 1, 0)
            DurationLabel.Text = formatTime(pos) .. " / " .. formatTime(len)
            if sound.IsPlaying then CoverImage.Rotation = (CoverImage.Rotation + dt * 55) % 360 end

            if not IsPlaying or #ParsedLyrics == 0 then return end
            local now = tick()
            local syncedClock = pos - SyncOffsetSec
            local activeIdx = getActiveLyricIndex(syncedClock)

            if activeIdx > 0 and activeIdx ~= LastTriggeredIndex and math.abs(now - LastSpawnedClock) > 0.22 then
                LastTriggeredIndex = activeIdx
                LastSpawnedClock = now
                local activeEntry = ParsedLyrics[activeIdx]
                local nextEntry = ParsedLyrics[activeIdx + 1]
                if activeEntry then
                    local windowToNext = nextEntry and math.clamp(nextEntry.time - activeEntry.time, 0.9, 5.2) or 2.8
                    spawn3DLyricSequence(activeEntry.text, windowToNext, generation)
                    MiniLyric.Text = activeEntry.text
                end
            end
        end)
    end)
end

-- ==========================================
-- TRANSPORT & HOTKEYS
-- ==========================================
local function togglePauseResume()
    if SpotifyLiveEnabled then
        SpotifyIsPlaying = not SpotifyIsPlaying
        IsPlaying = SpotifyIsPlaying
        SpotifyAnchorTick = tick()
        MiniTitle.TextColor3 = SpotifyIsPlaying and C.text or C.textMid
        sendSpotifyCommand("playpause")
        return
    end
    if not CurrentSound then return end
    if CurrentSound.IsPlaying then
        CurrentSound:Pause()
        IsPlaying = false
        MiniTitle.TextColor3 = C.textMid
    else
        CurrentSound:Resume()
        IsPlaying = true
        MiniTitle.TextColor3 = C.text
    end
end

local function switchTrack(delta)
    if SpotifyLiveEnabled then
        SpotifyAnchorPos = 0
        SpotifyAnchorTick = tick()
        LastTriggeredIndex = 0
        clearActive3DNodes()
        sendSpotifyCommand(delta > 0 and "next" or "prev")
        return
    end
    if #AudioPlaylist == 0 then return end
    local nextIdx = ((CurrentTrackIndex - 1 + delta) % #AudioPlaylist) + 1
    playLocalFile(AudioPlaylist[nextIdx], nextIdx)
end

MiniPrevBtn.MouseButton1Click:Connect(function() switchTrack(-1) end)
MiniPlayBtn.MouseButton1Click:Connect(togglePauseResume)
MiniNextBtn.MouseButton1Click:Connect(function() switchTrack(1) end)

PrevMainBtn.MouseButton1Click:Connect(function() switchTrack(-1) end)
PauseBtn.MouseButton1Click:Connect(togglePauseResume)
NextMainBtn.MouseButton1Click:Connect(function() switchTrack(1) end)

ContextActionService:BindActionAtPriority(
    "SpectralMiniPlayerArrows",
    function(_, inputState, inputObject)
        if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
        if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
        local key = inputObject.KeyCode
        if key == Enum.KeyCode.Right then switchTrack(1); return Enum.ContextActionResult.Sink
        elseif key == Enum.KeyCode.Left then switchTrack(-1); return Enum.ContextActionResult.Sink
        elseif key == Enum.KeyCode.Down then togglePauseResume(); return Enum.ContextActionResult.Sink
        end
        return Enum.ContextActionResult.Pass
    end,
    false,
    Enum.ContextActionPriority.High.Value + 50,
    Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.Down
)

local function refreshFolderList()
    for _, child in ipairs(FileList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    AudioPlaylist = {}
    if not listfiles then return end
    scanTextFilesInFolder()

    local ok, files = pcall(function() return listfiles(FOLDER_NAME) end)
    if ok and type(files) == "table" then
        for _, rawPath in ipairs(files) do
            local utf8Norm = string.gsub(ensureValidUTF8(rawPath), "\\", "/")
            if not string.find(utf8Norm, "/_cache/") then
                local ext = string.lower(string.match(utf8Norm, "%.(%w+)$") or "")
                if ext == "mp3" or ext == "ogg" or ext == "wav" then
                    local cleanName, fname, baseNoExt = cleanTrackName(rawPath)
                    table.insert(AudioPlaylist, { rawPath = rawPath, displayName = fname, cleanName = cleanName, baseNoExt = baseNoExt })
                end
            end
        end
    end

    for idx, entry in ipairs(AudioPlaylist) do
        local itemBtn = Instance.new("TextButton")
        itemBtn.LayoutOrder = idx
        itemBtn.Size = UDim2.new(1, 0, 0, 32)
        itemBtn.BackgroundColor3 = C.bg2
        itemBtn.TextColor3 = C.text
        itemBtn.Text = "   ▶   " .. entry.cleanName
        itemBtn.Font = Enum.Font.GothamMedium
        itemBtn.TextSize = 12
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
        itemBtn.Parent = FileList
        makeCorner(itemBtn, 7)

        local capturedIdx, capturedEntry = idx, entry
        itemBtn.MouseButton1Click:Connect(function()
            SpotifyLiveEnabled = false
            playLocalFile(capturedEntry, capturedIdx)
        end)
    end
end

RefreshBtn.MouseButton1Click:Connect(refreshFolderList)
StopAllBtn.MouseButton1Click:Connect(function()
    SpotifyLiveEnabled = false
    stopCurrentTrack()
    StatusLabel.Text = "Остановлено"
end)

InputConnection = UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    -- ESC always hides main panel (unbind/close UI)
    if input.KeyCode == Enum.KeyCode.Escape then
        if MainFrame then MainFrame.Visible = false end
        return
    end
    local closeName = (rawget(_G, "GoatLoseMusicCloseKey")) or "M"
    if closeName == "None" or closeName == "" then closeName = "M" end
    if input.KeyCode.Name == closeName then
        if MainFrame then MainFrame.Visible = not MainFrame.Visible end
    end
end)

refreshFolderList()
pcall(function()
    ScreenGui.Enabled = true
    if MainFrame then MainFrame.Visible = true end
    if MiniPlayer then MiniPlayer.Visible = true end
end)
task.spawn(function()
    local ok, err = pcall(startSpotifyLiveSync)
    if not ok then warn("[Spectral] spotify:", err) end
end)
print("[Spectral] UI ready")
pcall(function() if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end end)
-- keep mini player colors in sync if user changes theme live
task.spawn(function()
    while ScriptAlive do
        task.wait(0.5)
        pcall(function()
            if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end
        end)
    end
end)






]=]

function MusicTgl(on)
	MUSIC.On = on
	_G.GoatLoseMusicCloseKey = (MUSIC.CloseKey and MUSIC.CloseKey ~= "" and MUSIC.CloseKey ~= "None") and MUSIC.CloseKey or "M"

	-- OFF = only hide main panel, KEEP player + lyrics running (don't destroy)
	if not on then
		pcall(function()
			local parents = {}
			pcall(function() if gethui then table.insert(parents, gethui()) end end)
			pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
			pcall(function() table.insert(parents, LP:FindFirstChild("PlayerGui")) end)
			for _, parent in ipairs(parents) do
				local gui = parent and parent:FindFirstChild("SpectralFolderPlayerUI")
				if gui then
					for _, ch in ipairs(gui:GetDescendants()) do
						if ch:IsA("Frame") and ch.Name == "MainFrame" then
							ch.Visible = false
						end
					end
				end
			end
		end)
		return
	end

	-- already running? just show MainFrame
	local already = false
	pcall(function()
		local parents = {}
		pcall(function() if gethui then table.insert(parents, gethui()) end end)
		pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
		pcall(function() table.insert(parents, LP:FindFirstChild("PlayerGui")) end)
		for _, parent in ipairs(parents) do
			if parent and parent:FindFirstChild("SpectralFolderPlayerUI") then
				already = true
				local gui = parent:FindFirstChild("SpectralFolderPlayerUI")
				gui.Enabled = true
				for _, ch in ipairs(gui:GetDescendants()) do
					if ch:IsA("Frame") and ch.Name == "MainFrame" then
						ch.Visible = true
					end
				end
			end
		end
	end)
	if already then return end

	_G.GoatLoseMusicTheme = {
		Accent = MUSIC.Accent,
		AccentAlt = MUSIC.AccentAlt,
		Bg = MUSIC.Bg,
		Text = MUSIC.Text,
		LyricLeft = MUSIC.LyricLeft,
		LyricRight = MUSIC.LyricRight,
	}
	print("[GoatLose Music] loading...")
	local fn, err = loadstring(SPECTRAL_SRC)
	if not fn then
		warn("[GoatLose Music] load error:", tostring(err))
		MUSIC.On = false
		return
	end
	local ok, err2 = pcall(fn)
	if not ok then
		warn("[GoatLose Music] run error:", tostring(err2))
		MUSIC.On = false
		return
	end
	print("[GoatLose Music] ok")

	MUSIC.Cleanup = function()
		pcall(function()
			if _G.SpectralCleanup then _G.SpectralCleanup() end
		end)
		pcall(function()
			local CoreGui = game:GetService("CoreGui")
			local Workspace = game:GetService("Workspace")
			for _, v in ipairs(Workspace:GetChildren()) do
				if v.Name == "SpectralLocalMP3" or v.Name == "SpectralLyricsWorld" then
					if v:IsA("Sound") then pcall(function() v:Stop() end) end
					pcall(function() v:Destroy() end)
				end
			end
			for _, v in ipairs(CoreGui:GetChildren()) do
				if v.Name == "SpectralFolderPlayerUI" then pcall(function() v:Destroy() end) end
			end
			pcall(function()
				if gethui then
					local h = gethui()
					if h then
						local g = h:FindFirstChild("SpectralFolderPlayerUI")
						if g then g:Destroy() end
					end
				end
			end)
			pcall(function()
				game:GetService("ContextActionService"):UnbindAction("SpectralMiniPlayerArrows")
			end)
		end)
	end

	task.defer(function()
		pcall(function()
			local parents = {}
			pcall(function() if gethui then table.insert(parents, gethui()) end end)
			pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
			for _, parent in ipairs(parents) do
				local gui = parent and parent:FindFirstChild("SpectralFolderPlayerUI")
				if gui then
					gui.Enabled = true
					for _, ch in ipairs(gui:GetDescendants()) do
						if ch:IsA("Frame") and ch.Name == "MainFrame" then
							ch.Visible = true
						end
					end
				end
			end
		end)
	end)
end


-- ===================== DOWNLOAD XIVIVIDE.EXE =====================
XIVIVIDE = {On=false, Cleanup=nil}

function XivivideTgl(on)
	XIVIVIDE.On = on
	if not on then
		if XIVIVIDE.Cleanup then pcall(XIVIVIDE.Cleanup) end
		XIVIVIDE.Cleanup = nil
		return
	end
	if XIVIVIDE.Cleanup then pcall(XIVIVIDE.Cleanup) end

	local parentGui = (gethui and gethui()) or game:GetService("CoreGui")
	local SoundService = game:GetService("SoundService")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")

	local soundUrl = "https://raw.githubusercontent.com/koza78889-lab/kazel_vd/main/XIVIVIDE%20-%20%D1%82%D1%80%D0%BE%D0%BB%D0%B8%D1%82%20%D0%BC%D0%B5%D0%BD%D1%8F%20%D0%B2%D0%BE%D0%B2%D0%B0%20%D1%85%D0%B2%D0%B0%D1%82%D0%B8%D1%82%20%5Bmp3uk.net%5D.mp3"
	local soundFileName = "xivivide_vova.mp3"

	if writefile and isfile and not isfile(soundFileName) then
		local success, data = pcall(function()
			local req = (syn and syn.request) or http_request or request
			if req then
				local r = req({Url = soundUrl, Method = "GET"})
				return r and (r.Body or r.body)
			end
			return game:HttpGet(soundUrl)
		end)
		if success and data then
			pcall(writefile, soundFileName, data)
		end
	end

	if parentGui:FindFirstChild("XivivideGui") then
		parentGui.XivivideGui:Destroy()
	end
	if SoundService:FindFirstChild("XivivideMusic") then
		SoundService.XivivideMusic:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "XivivideGui"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 999999
	screenGui.Parent = parentGui

	local sound = Instance.new("Sound")
	sound.Name = "XivivideMusic"
	if getcustomasset and isfile and isfile(soundFileName) then
		sound.SoundId = getcustomasset(soundFileName)
	else
		sound.SoundId = "rbxassetid://90621701981627"
	end
	sound.Volume = 2
	sound.Looped = true
	sound.Parent = SoundService
	sound:Play()

	local isRunning = true
	local maxPopups = 80
	local currentPopups = 0

	local function spawnVirusPopup()
		if not isRunning or not screenGui.Parent or currentPopups >= maxPopups then return end
		currentPopups = currentPopups + 1

		local sizeX = math.random(160, 300)
		local sizeY = sizeX + 26

		local window = Instance.new("Frame")
		window.Size = UDim2.new(0, 0, 0, 0)
		window.AnchorPoint = Vector2.new(0.5, 0.5)
		window.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(15, 85) / 100, 0)
		window.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
		window.BorderSizePixel = 2
		window.BorderColor3 = Color3.fromRGB(40, 40, 40)
		window.Rotation = math.random(-8, 8)
		window.Parent = screenGui

		local topBar = Instance.new("Frame")
		topBar.Size = UDim2.new(1, 0, 0, 26)
		topBar.BackgroundColor3 = Color3.fromRGB(190, 20, 20)
		topBar.BorderSizePixel = 0
		topBar.Parent = window

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, -30, 1, 0)
		title.Position = UDim2.new(0, 6, 0, 0)
		title.BackgroundTransparency = 1
		title.Text = "⚠️ XIVIVIDE_TROJAN.exe"
		title.TextColor3 = Color3.fromRGB(255, 255, 255)
		title.Font = Enum.Font.Code
		title.TextSize = 14
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = topBar

		local closeBtn = Instance.new("TextButton")
		closeBtn.Size = UDim2.new(0, 22, 0, 22)
		closeBtn.Position = UDim2.new(1, -24, 0, 2)
		closeBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
		closeBtn.Text = "X"
		closeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
		closeBtn.Font = Enum.Font.SourceSansBold
		closeBtn.TextSize = 16
		closeBtn.Parent = topBar

		closeBtn.MouseButton1Click:Connect(function()
			spawnVirusPopup()
			spawnVirusPopup()
		end)

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Size = UDim2.new(1, -8, 1, -34)
		imageLabel.Position = UDim2.new(0, 4, 0, 30)
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.Image = "rbxthumb://type=Asset&id=85666779383231&w=420&h=420"
		imageLabel.Parent = window

		TweenService:Create(
			window,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, sizeX, 0, sizeY) }
		):Play()

		task.spawn(function()
			while isRunning and window.Parent do
				window.Position = window.Position + UDim2.new(0, math.random(-3, 3), 0, math.random(-3, 3))
				task.wait(0.05)
			end
		end)
	end

	task.spawn(function()
		while isRunning and screenGui.Parent do
			spawnVirusPopup()
			task.wait(0.25)
		end
	end)

	-- stop only via toggle OFF (no Delete key)
	XIVIVIDE.Cleanup = function()
		isRunning = false
		pcall(function() if screenGui then screenGui:Destroy() end end)
		pcall(function() if sound then sound:Stop(); sound:Destroy() end end)
	end
end


function TTSTgl(on)
	TTS.On = on
	S.On.tungtung = on
	if TTS.Conn then TTS.Conn:Disconnect(); TTS.Conn = nil end
	if not on then
		if LP.Character then TTSClear(LP.Character) end
		return
	end
	if LP.Character then
		task.spawn(TTSApply, LP.Character)
	end
	TTS.Conn = LP.CharacterAdded:Connect(function(ch)
		if not TTS.On then return end
		task.wait(0.25)
		TTSApply(ch)
	end)
end



-- ===================== KILLER HEAD HIDE (local visual) =====================
KHIDE = {On=true, Conn=nil}

local function KHIDEApply(char)
	if not char then return end
	if not IsLocalKiller() then
		-- restore head if was survivor
		local hd = char:FindFirstChild("Head")
		if hd then
			pcall(function()
				if hd.Transparency >= 0.99 and not (TTS and TTS.On) then
					hd.Transparency = 0
				end
			end)
		end
		return
	end
	local hd = char:FindFirstChild("Head")
	if hd then
		hd.Transparency = 1
		for _,d in ipairs(hd:GetChildren()) do
			if d:IsA("Decal") or d:IsA("Texture") then
				pcall(function() d.Transparency = 1 end)
			end
		end
	end
	-- hide face accessories locally
	for _,a in ipairs(char:GetChildren()) do
		if a:IsA("Accessory") or a:IsA("Hat") then
			local n = a.Name:lower()
			if n:find("face") or n:find("head") or n:find("hair") then
				local h = a:FindFirstChild("Handle")
				if h then h.Transparency = 1 end
			end
		end
	end
	-- no china hat
	if CH.Part then pcall(function() CH.Part:Destroy() end); CH.Part = nil end
end

function KHIDEStart()
	if KHIDE.Conn then return end
	KHIDE.Conn = RunService.Heartbeat:Connect(function()
		if not KHIDE.On then return end
		local c = LP.Character
		if c then KHIDEApply(c) end
	end)
	LP.CharacterAdded:Connect(function(ch)
		task.wait(0.2)
		if KHIDE.On then KHIDEApply(ch) end
	end)
end
KHIDEStart()


function CHTgl(on)
	S.On.chinahat = on
	if on then
		if IsLocalKiller() then
			-- never show China hat as killer
			if CH.Conn then CH.Conn:Disconnect(); CH.Conn = nil end
			if CH.Part then CH.Part:Destroy(); CH.Part = nil end
		else
			CHBuild()
		end
	else
		if CH.Conn then CH.Conn:Disconnect(); CH.Conn = nil end
		if CH.Part then CH.Part:Destroy(); CH.Part = nil end
	end
end

PC = {Segs=nil,Anchor=nil,Label=nil,Conn=nil,On=false}
function PCBuild()
	if PC.Segs then for _,s in ipairs(PC.Segs) do s:Destroy() end end
	local segs = {}
	for i = 1, 48 do local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.CastShadow = false; p.Material = Enum.Material.Neon; p.Color = S.PC.Color; p.Transparency = 0.2; p.Parent = Workspace; table.insert(segs,p) end
	PC.Segs = segs
	if PC.Anchor then PC.Anchor:Destroy() end
	local a = Instance.new("Part"); a.Anchored = true; a.CanCollide = false; a.Transparency = 1; a.Size = Vector3.new(0.1,0.1,0.1); a.Parent = Workspace
	local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0,200,0,32); bb.StudsOffset = Vector3.new(0,4,0); bb.AlwaysOnTop = true; bb.Parent = a
	local l = Instance.new("TextLabel",bb); l.Size = UDim2.new(1,0,1,0); l.BackgroundTransparency = 1; l.TextStrokeTransparency = 0; l.Font = Enum.Font.GothamBold; l.TextSize = 14
	PC.Anchor = a; PC.Label = l
end
function PCUpd()
	if not (PC.On and IsSurv()) then
		if PC.Segs then for _,s in ipairs(PC.Segs) do s.Transparency = 1 end end
		if PC.Anchor then PC.Anchor.Transparency = 1 end
		return
	end
	local r = GetRoot(LP.Character); if not r then return end
	if not PC.Segs then PCBuild() end
	local rng = S.Parry.Range; local n = 1e999
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character then
			local rr = GetRoot(pl.Character); local h = GetHum(pl.Character)
			if rr and h and h.Health>0 and IsKiller(pl) then local m = (rr.Position-r.Position).Magnitude if m<n then n = m end end
		end
	end
	local inR = n<=rng; local col = inR and Color3.fromRGB(255,50,50) or S.PC.Color
	local y = r.Position.Y-2.9; local sl = (2*math.pi*rng)/48
	for i,s in ipairs(PC.Segs) do
		local a = (i-1)/48*2*math.pi
		s.Size = Vector3.new(0.12,0.12,sl*1.15)
		s.CFrame = CFrame.new(r.Position.X+math.cos(a)*rng,y,r.Position.Z+math.sin(a)*rng)*CFrame.Angles(0,-a,0)
		s.Color = col; s.Transparency = 0.2
	end
	if PC.Anchor then PC.Anchor.Transparency = 1; PC.Anchor.CFrame = CFrame.new(r.Position.X,y,r.Position.Z) end
	if PC.Label then PC.Label.Text = string.format("r: %.1f | killer: %s",rng,n==1e999 and "---" or string.format("%.1f",n)); PC.Label.TextColor3 = inR and Color3.fromRGB(255,80,80) or S.PC.Color end
end
function PCTgl(on)
	PC.On = on; S.On.parrycircle = on
	if PC.Conn then PC.Conn:Disconnect(); PC.Conn = nil end
	if PC.Segs then for _,s in ipairs(PC.Segs) do s:Destroy() end PC.Segs = nil end
	if PC.Anchor then PC.Anchor:Destroy(); PC.Anchor = nil end
	if on then PC.Conn = RunService.Heartbeat:Connect(PCUpd) end
end

function UpdateTint()
	if S.Tint.On then
		local cc = Lighting:FindFirstChild("GoatLoseTint")
		if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "GoatLoseTint"; cc.Parent = Lighting end
		cc.Enabled = true
		cc.TintColor = Color3.new(math.min(S.Tint.R/255*S.Tint.Br,1),math.min(S.Tint.G/255*S.Tint.Br,1),math.min(S.Tint.B/255*S.Tint.Br,1))
	else local cc = Lighting:FindFirstChild("GoatLoseTint"); if cc then cc:Destroy() end end
end

KL = {Loop=nil}
function KLTgl(on)
	S.On.killerlight = on
	if KL.Loop then task.cancel(KL.Loop); KL.Loop = nil end
	if on then
		KL.Loop = task.spawn(function()
			while S.On.killerlight do
				for _,pl in ipairs(Players:GetPlayers()) do
					if pl~=LP and pl.Character and (IsKiller(pl) or (pl.Team and pl.Team.Name:lower():find("killer"))) then
						local hd = pl.Character:FindFirstChild("Head"); local lt = hd and hd:FindFirstChild("RedSurfaceLight")
						if lt then lt.Color = S.KL.Color end
					end
				end
				task.wait(0.5)
			end
		end)
	end
end

RC = {On=false,Conn=nil,HL=nil}
function RCTgl(on)
	RC.On = on; S.On.rainbow = on
	if RC.Conn then RC.Conn:Disconnect(); RC.Conn = nil end
	if RC.HL then RC.HL:Destroy(); RC.HL = nil end
	if on then
		RC.Conn = RunService.Heartbeat:Connect(function()
			if not RC.On then return end
			local c = LP.Character; if not c then return end
			local col = Color3.fromHSV((tick()%4)/4,1,1)
			if not RC.HL or not RC.HL.Parent then RC.HL = Instance.new("Highlight"); RC.HL.Name = "GoatLoseRainbow"; RC.HL.FillTransparency = 0.4; RC.HL.OutlineTransparency = 0 end
			RC.HL.Parent = c; RC.HL.Adornee = c; RC.HL.FillColor = col; RC.HL.OutlineColor = col
		end)
	end
end

CROSSGUI = nil
function ApplyVisuals()
	local L = Lighting; local V = S.VS
	local cc = L:FindFirstChild("GoatLoseVS_CC")
	if V.RTX or V.Preset~="Default" or V.Tint~="Default" or V.Vivid or math.abs(V.Sat-0.25)>0.001 or math.abs(V.Con-0.12)>0.001 then
		if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "GoatLoseVS_CC"; cc.Parent = L end
		local sat = V.Sat; local con = V.Con; local tint = Color3.new(1,1,1)
		if V.Vivid then sat = 0.55; con = -0.35; tint = Color3.new(1,1,1) end
		if V.RTX then sat = sat + 0.15; con = con + 0.1 end
		if not V.Vivid then
			if V.Tint=="Warm" then tint = Color3.fromRGB(255,240,220)
			elseif V.Tint=="Cold" then tint = Color3.fromRGB(220,240,255) end
		end
		cc.Enabled = true; cc.Saturation = sat; cc.Contrast = con; cc.TintColor = tint
	else if cc then cc:Destroy() end end

	local bl = L:FindFirstChild("GoatLoseVS_Bloom")
	if (V.Bloom or V.RTX) and V.BloomI>0 and not V.Vivid then
		if not bl then bl = Instance.new("BloomEffect"); bl.Name = "GoatLoseVS_Bloom"; bl.Parent = L end
		bl.Enabled = true; bl.Intensity = V.BloomI; bl.Size = V.BloomS; bl.Threshold = V.BloomT
	else if bl then bl:Destroy() end end

	local sr = L:FindFirstChild("GoatLoseVS_Sun")
	if (V.SunRays or V.RTX or V.Vivid) and V.SunI>0 then
		if not sr then sr = Instance.new("SunRaysEffect"); sr.Name = "GoatLoseVS_Sun"; sr.Parent = L end
		sr.Enabled = true; sr.Intensity = V.SunI; sr.Spread = V.SunSpread or 0.7
	else if sr then sr:Destroy() end end

	local at = L:FindFirstChild("GoatLoseVS_Atmo")
	if (V.Fog or V.RTX) and not V.Vivid then
		if not at then at = Instance.new("Atmosphere"); at.Name = "GoatLoseVS_Atmo"; at.Parent = L end
		at.Enabled = true; at.Density = V.Atmo; at.Offset = 0.25; at.Color = V.FogColor; at.Decay = V.FogColor; at.Glare = 0.4; at.Haze = 0.1
	else if at then at:Destroy() end end

	if V.NoFog or V.Vivid then
		L.FogStart = 999999; L.FogEnd = 100000
	else
		L.FogStart = V.FogStart or 0
		L.FogEnd = V.FogEnd or 800
		if V.Fog then L.FogColor = V.FogColor end
	end

	local df = L:FindFirstChild("GoatLoseVS_DOF")
	if V.DOF then
		if not df then df = Instance.new("DepthOfFieldEffect"); df.Name = "GoatLoseVS_DOF"; df.Parent = L end
		df.Enabled = true; df.FocusDistance = 25; df.InFocusRadius = 15; df.NearIntensity = 0.1; df.FarIntensity = 0.65
	else if df then df:Destroy() end end

	if V.Light then L.Ambient = V.LightColor; L.OutdoorAmbient = V.LightColor end
	if V.Time=="Custom" then L.ClockTime = V.ClockTime
	elseif V.Vivid then L.ClockTime = 14.5
	elseif V.Time=="Day" then L.ClockTime = 14
	elseif V.Time=="Sunset" then L.ClockTime = 18
	elseif V.Time=="Sunrise" then L.ClockTime = 6.5
	elseif V.Time=="Night" then L.ClockTime = 0
	end

	if V.RTX then L.Brightness = 2.5; L.ExposureCompensation = 0.4; L.GlobalShadows = true end
	local cam = Workspace.CurrentCamera
	if cam and V.FOVOn ~= false then
		local fov = tonumber(V.FOV) or 70
		if math.abs(cam.FieldOfView - fov) > 0.05 then
			cam.FieldOfView = fov
		end
	end

	if not V.Crosshair then
		if CROSSGUI then CROSSGUI:Destroy(); CROSSGUI = nil end
	elseif not CROSSGUI or not CROSSGUI.Parent then
		CROSSGUI = Instance.new("ScreenGui"); CROSSGUI.Name = "GoatLoseCross"; CROSSGUI.ResetOnSpawn = false
		pcall(function() CROSSGUI.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
		if not CROSSGUI.Parent then CROSSGUI.Parent = LP:WaitForChild("PlayerGui") end
		local holder = N("Frame",CROSSGUI,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1})
		local sz = V.CrossSize; local th = math.max(1,math.floor(sz*0.2)); local gap = math.floor(sz*0.3)
		local col = V.CrossColor
		if V.CrossStyle=="Classic" or V.CrossStyle=="Tactical" then
			N("Frame",holder,{Size=UDim2.new(0,th,0,sz),Position=UDim2.new(0,-th/2,0,-sz-gap),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,th,0,sz),Position=UDim2.new(0,-th/2,0,gap),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,sz,0,th),Position=UDim2.new(0,-sz-gap,0,-th/2),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,sz,0,th),Position=UDim2.new(0,gap,0,-th/2),BackgroundColor3=col,BorderSizePixel=0})
		end
		if V.CrossStyle=="Dot" or V.CrossStyle=="DotCircle" then
			local d = N("Frame",holder,{Size=UDim2.new(0,th+2,0,th+2),Position=UDim2.new(0,-(th+2)/2,0,-(th+2)/2),BackgroundColor3=col,BorderSizePixel=0}); corner(d,5)
		end
		if V.CrossStyle=="Circle" or V.CrossStyle=="DotCircle" then
			local c = N("Frame",holder,{Size=UDim2.new(0,sz*2,0,sz*2),Position=UDim2.new(0,-sz,0,-sz),BackgroundTransparency=1,BorderSizePixel=0})
			local st = Instance.new("UIStroke",c); st.Color = col; st.Thickness = th
			local cn = Instance.new("UICorner",c); cn.CornerRadius = UDim.new(0.5,0)
		end
	end
	pcall(function()
		if S.AtmoName and S.AtmoName ~= "Normal" and S.AtmoName ~= "" then
			-- re-ensure sky still present
			local hasSky = false
			for _,ch in ipairs(Lighting:GetChildren()) do
				if ch:IsA("Sky") then hasSky = true break end
			end
			if not hasSky then ApplyAtmo(S.AtmoName) end
		end
	end)
end

function ApplyAtmo(name)
	name = name or S.AtmoName or "Normal"
	S.AtmoName = name
	local L = Lighting; local Terrain = Workspace:FindFirstChild("Terrain")
	-- only strip sky/atmosphere we own or conflicting; keep GoatLoseVS_* effects
	for _,ch in pairs(L:GetChildren()) do
		if ch.Name:find("GoatLoseVS_") then
			-- keep visual system effects
		elseif ch:IsA("Sky") or ch:IsA("Atmosphere") then
			ch:Destroy()
		elseif ch:IsA("BloomEffect") or ch:IsA("ColorCorrectionEffect") or ch:IsA("SunRaysEffect") or ch:IsA("DepthOfFieldEffect") then
			-- destroy only non-GoatLose effects when applying atmo packs that add their own
			if not ch.Name:find("GoatLose") then
				-- leave VS effects; destroy random
			end
		end
	end
	if name == "Normal" then
		L.FogEnd = 100000; L.FogStart = 0; L.Brightness = 1; L.ClockTime = 14
		if Terrain then Terrain.WaterColor = Color3.fromRGB(45,105,135); Terrain.WaterReflectance = 0.3; Terrain.WaterTransparency = 0.3 end
		return
	end
	if name == "Void" then
		local Sky = Instance.new("Sky"); Sky.Name = "VoidSky"
		Sky.SkyboxBk="rbxassetid://6444884337"; Sky.SkyboxDn="rbxassetid://6444884785"; Sky.SkyboxFt="rbxassetid://6444884337"; Sky.SkyboxLf="rbxassetid://6444884337"; Sky.SkyboxRt="rbxassetid://6444884337"; Sky.SkyboxUp="rbxassetid://6412503613"
		Sky.StarCount = 2500; Sky.SunAngularSize = 12; Sky.MoonAngularSize = 11; Sky.Parent = L
		L.FogEnd = 950; L.FogStart = 80; L.FogColor = Color3.fromRGB(45,55,85)
		local Atm = Instance.new("Atmosphere"); Atm.Density = 0.32; Atm.Offset = 0.12; Atm.Color = Color3.fromRGB(50,60,100); Atm.Decay = Color3.fromRGB(25,30,55); Atm.Glare = 0.22; Atm.Haze = 1.6; Atm.Parent = L
		L.Ambient = Color3.fromRGB(70,75,110); L.OutdoorAmbient = Color3.fromRGB(90,95,140)
		L.Brightness = 2.4; L.ClockTime = 19.8; L.GeographicLatitude = 30
		local Bl = Instance.new("BloomEffect"); Bl.Intensity = 0.5; Bl.Size = 22; Bl.Threshold = 0.88; Bl.Parent = L
		local CC = Instance.new("ColorCorrectionEffect"); CC.Brightness = 0.06; CC.Contrast = 0.12; CC.Saturation = 0.22; CC.TintColor = Color3.fromRGB(220,225,255); CC.Parent = L
		local SR = Instance.new("SunRaysEffect"); SR.Intensity = 0.09; SR.Spread = 0.65; SR.Parent = L
		local DOF = Instance.new("DepthOfFieldEffect"); DOF.FarIntensity = 0.12; DOF.FocusDistance = 50; DOF.InFocusRadius = 35; DOF.NearIntensity = 0.08; DOF.Parent = L
		if Terrain then Terrain.WaterColor = Color3.fromRGB(20,30,55); Terrain.WaterReflectance = 0.35; Terrain.WaterTransparency = 0.4 end
		return
	end
	if name == "Dark" then
		local Sky = Instance.new("Sky"); Sky.Name = "DarkSky"
		Sky.SkyboxBk="rbxassetid://1546949252"; Sky.SkyboxDn="rbxassetid://1546949252"; Sky.SkyboxFt="rbxassetid://1546949252"; Sky.SkyboxLf="rbxassetid://1546949252"; Sky.SkyboxRt="rbxassetid://1546949252"; Sky.SkyboxUp="rbxassetid://1546949252"
		Sky.StarCount = 100; Sky.SunAngularSize = 5; Sky.MoonAngularSize = 5; Sky.Parent = L
		L.FogEnd = 500; L.FogStart = 50; L.FogColor = Color3.fromRGB(10,10,15)
		local Atm = Instance.new("Atmosphere"); Atm.Density = 0.5; Atm.Offset = 0; Atm.Color = Color3.fromRGB(5,5,10); Atm.Decay = Color3.fromRGB(0,0,0); Atm.Glare = 0; Atm.Haze = 3; Atm.Parent = L
		L.Ambient = Color3.fromRGB(20,20,30); L.OutdoorAmbient = Color3.fromRGB(30,30,40)
		L.Brightness = 0.8; L.ClockTime = 0; L.GeographicLatitude = 0
		local Bl = Instance.new("BloomEffect"); Bl.Intensity = 0.3; Bl.Size = 15; Bl.Threshold = 0.9; Bl.Parent = L
		local CC = Instance.new("ColorCorrectionEffect"); CC.Brightness = -0.1; CC.Contrast = 0.2; CC.Saturation = -0.3; CC.TintColor = Color3.fromRGB(180,180,200); CC.Parent = L
		if Terrain then Terrain.WaterColor = Color3.fromRGB(5,5,10); Terrain.WaterReflectance = 0.1; Terrain.WaterTransparency = 0.2 end
		return
	end
end
ATMO_NAMES = {"Normal","Void","Dark"}
ATMO_IDX = 1

DR = {Track=nil}
function DRPlay()
	local h = GetHum(LP.Character); if not h then return end
	if DR.Track then pcall(function() DR.Track:Stop() end) end
	local a1 = Instance.new("Animation"); a1.AnimationId = "rbxassetid://99198989"
	local ok,tr = pcall(function() return h:LoadAnimation(a1) end)
	if ok and tr then DR.Track = tr; tr.Looped = true; tr:Play(); tr:AdjustSpeed(S.Droch.Speed) end
end
function DRTgl(on) S.On.drochka = on if on then DRPlay() else if DR.Track then pcall(function() DR.Track:Stop() end); DR.Track = nil end end end

BW = {On=false,Saved=nil}
function BWPress()
	local r = GetRoot(LP.Character); if not r then return end
	if not BW.On then
		local best,bd = nil,S.BW.Range
		for _,d in ipairs(Workspace:GetDescendants()) do
			local n = d.Name:lower()
			if n:find("window") or n:find("vault") then
				local part = d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
				if part then local m = (part.Position-r.Position).Magnitude; if m<bd then bd = m; best = part end end
			end
		end
		if not best then return end
		BW.Saved = r.CFrame
		r.CFrame = best.CFrame+Vector3.new(0,2,0)
		BW.On = true; S.On.blockwindow = true
	else
		if BW.Saved then r.CFrame = BW.Saved end
		BW.Saved = nil; BW.On = false; S.On.blockwindow = false
	end
end

function ClickTPDo(screenPos)
	local char = LP.Character
	local r = GetRoot(char)
	if not r then return end
	local cam = Workspace.CurrentCamera
	if not cam then return end
	local maxDist = tonumber(S.CTP.Dist) or 50
	local through = S.CTP.ThroughWalls ~= false
	local snap = S.CTP.SnapGround ~= false

	local mouse = LP:GetMouse()
	local mx, my
	if screenPos then
		mx, my = screenPos.X, screenPos.Y
	else
		-- GetMouseLocation includes inset; ScreenPointToRay expects same
		local loc = UIS:GetMouseLocation()
		mx, my = loc.X, loc.Y
	end
	local ray = cam:ViewportPointToRay(mx, my)
	local origin, dir = ray.Origin, ray.Direction.Unit
	local target = origin + dir * maxDist

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local filter = {char}
	params.FilterDescendantsInstances = filter
	params.IgnoreWater = true

	if through then
		-- cast but only snap to floor (high up-dot); walls ignored
		local res = Workspace:Raycast(origin, dir * maxDist, params)
		if res and snap then
			local upDot = res.Normal:Dot(Vector3.new(0, 1, 0))
			if upDot > 0.5 then
				target = res.Position
			else
				-- hit wall: keep going past along ray to maxDist
				target = origin + dir * maxDist
			end
		elseif not res then
			target = origin + dir * maxDist
		elseif res and not snap then
			target = origin + dir * maxDist
		end
	else
		local res = Workspace:Raycast(origin, dir * maxDist, params)
		if res then
			target = res.Position
		else
			target = origin + dir * maxDist
		end
	end

	-- solid TP
	r.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
	pcall(function()
		r.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	end)
end

function TPRandomSurvivor()
	local my = GetRoot(LP.Character)
	if not my then return end
	local list = {}
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl ~= LP and pl.Character then
			if IsKiller(pl) then
			else
				local hum = GetHum(pl.Character)
				local root = GetRoot(pl.Character)
				if root and hum and hum.Health > 0 then
					table.insert(list, root)
				end
			end
		end
	end
	if #list == 0 then return end
	local target = list[math.random(1, #list)]
	my.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
	pcall(function() my.AssemblyLinearVelocity = Vector3.new() end)
end



IH = {On=false,Loop=nil}
function HealOnce()
	pcall(function()
		local rem = RS:FindFirstChild("Remotes"); local H = rem and rem:FindFirstChild("Healing"); local ev = H and H:FindFirstChild("HealEvent")
		local r = GetRoot(LP.Character)
		if ev and r then ev:FireServer(r,true) end
	end)
end
function IHTgl(on)
	IH.On = on; S.On.instantheal = on
	if IH.Loop then task.cancel(IH.Loop); IH.Loop = nil end
	if on then
		IH.Loop = task.spawn(function()
			while IH.On do
				local c = LP.Character; local h = GetHum(c)
				if c and h and h.Health>0 then
					local knocked = c:GetAttribute("Knocked")==true or LP:GetAttribute("Knocked")==true
					if knocked then
						h.Health = h.MaxHealth
						pcall(function() c:SetAttribute("Knocked",false) end)
						pcall(function() LP:SetAttribute("Knocked",false) end)
					end
				end
				task.wait(0.05)
			end
		end)
	end
end

CACHE = {pallets={},vaults={}}
function ScanInteractables()
	local pals,vaults = {},{}
	for _,d in ipairs(Workspace:GetDescendants()) do
		if d.Name=="Palletwrong" then table.insert(pals,d)
		elseif d:IsA("Model") then
			local n = d.Name:lower()
			if n:find("window") or n:find("vault") then
				local b,i,t = false,false,false
				for _,c in ipairs(d:GetDescendants()) do local cn = c.Name:lower() if cn=="bottom" then b = true elseif cn=="inviswall" then i = true elseif cn=="vaulttrigger" then t = true end end
				if b and i and t then table.insert(vaults,d) end
			end
		end
	end
	CACHE.pallets = pals; CACHE.vaults = vaults
end

function HoldRoot(sec)
	local r = GetRoot(LP.Character); if not r then return end
	local saved = r.CFrame
	task.spawn(function() local t0 = tick() while tick()-t0<sec do if r.Parent then r.CFrame = saved end task.wait() end end)
end

function DropAllPallets()
	local rem = RS:FindFirstChild("Remotes"); local P = rem and rem:FindFirstChild("Pallet"); local ev = P and P:FindFirstChild("PalletDropEvent")
	if not ev then return end
	ScanInteractables()
	for _,pal in ipairs(CACHE.pallets) do
		for _,c in ipairs(pal:GetChildren()) do if c.Name=="PalletPoint" then pcall(function() ev:FireServer(c) end); break end end
	end
	HoldRoot(0.4)
end

RDP = {On=false,Target=nil,HL=nil,Loop=nil,Range=12}

local function RDPGetDropEvent()
	local rem = RS:FindFirstChild("Remotes")
	local P = rem and rem:FindFirstChild("Pallet")
	local ev = P and (P:FindFirstChild("PalletDropEvent") or P:FindFirstChild("DropEvent") or P:FindFirstChild("Drop"))
	if ev then return ev end
	if rem then
		for _,d in ipairs(rem:GetDescendants()) do
			if d:IsA("RemoteEvent") and d.Name:lower():find("pallet") and d.Name:lower():find("drop") then
				return d
			end
		end
	end
	return nil
end

local function RDPPalletPos(pal)
	if not pal then return nil end
	local pp = pal:FindFirstChild("PalletPoint")
	if pp and pp:IsA("BasePart") then return pp.Position, pp end
	if pp then
		local part = pp:IsA("BasePart") and pp or pp:FindFirstChildWhichIsA("BasePart", true)
		if part then return part.Position, pp end
	end
	if pal:IsA("BasePart") then return pal.Position, pal end
	local part = pal:FindFirstChildWhichIsA("BasePart", true)
	if part then return part.Position, part end
	return nil
end

-- nearest pallet within Range (standing next to it)
function FindTargetPallet()
	ScanInteractables()
	local root = GetRoot(LP.Character)
	if not root then return nil end
	local best, bestDist = nil, tonumber(RDP.Range) or 12
	for _,pal in ipairs(CACHE.pallets) do
		local pos = RDPPalletPos(pal)
		if pos then
			local d = (pos - root.Position).Magnitude
			if d < bestDist then
				bestDist = d
				best = pal
			end
		end
	end
	-- also scan live for Palletwrong / names with pallet
	if not best then
		for _,d in ipairs(Workspace:GetDescendants()) do
			local n = d.Name:lower()
			if n == "palletwrong" or (d:IsA("Model") and n:find("pallet") and not n:find("point")) then
				local pos = RDPPalletPos(d)
				if pos then
					local dist = (pos - root.Position).Magnitude
					if dist < bestDist then
						bestDist = dist
						best = d
					end
				end
			end
		end
	end
	return best
end

function DropTargetPallet()
	local pal = FindTargetPallet()
	if not pal then return end
	local ev = RDPGetDropEvent()
	if not ev then return end
	local _, point = RDPPalletPos(pal)
	-- prefer PalletPoint child
	local pp = pal:FindFirstChild("PalletPoint") or point
	if pp then
		pcall(function() ev:FireServer(pp) end)
	else
		pcall(function() ev:FireServer(pal) end)
	end
	RDP.Target = pal
	HoldRoot(0.25)
end

function RDPTgl(on)
	RDP.On = on
	S.On.remotedrop = on
	if RDP.Loop then task.cancel(RDP.Loop); RDP.Loop = nil end
	if RDP.HL then pcall(function() RDP.HL:Destroy() end); RDP.HL = nil end
	RDP.Target = nil
	if not on then return end
	RDP.Loop = task.spawn(function()
		while RDP.On do
			RDP.Target = FindTargetPallet()
			if RDP.Target then
				if not RDP.HL or not RDP.HL.Parent then
					RDP.HL = Instance.new("Highlight")
					RDP.HL.Name = "GoatLosePalletVac"
					RDP.HL.FillColor = Color3.fromRGB(0,255,200)
					RDP.HL.OutlineColor = Color3.fromRGB(0,255,200)
					RDP.HL.FillTransparency = 0.55
					RDP.HL.Parent = LP.PlayerGui
				end
				RDP.HL.Adornee = RDP.Target
			elseif RDP.HL then
				RDP.HL.Adornee = nil
			end
			task.wait(0.12)
		end
	end)
end


function BlockWP()
	local rem = RS:FindFirstChild("Remotes")
	local W = rem and rem:FindFirstChild("Window"); local VE = W and W:FindFirstChild("VaultEvent")
	local P = rem and rem:FindFirstChild("Pallet"); local PS = P and P:FindFirstChild("PalletSlideEvent")
	ScanInteractables()
	if VE then for _,v in ipairs(CACHE.vaults) do for _,d in ipairs(v:GetDescendants()) do if d.Name=="VaultTrigger" then pcall(function() VE:FireServer(d,true) end) end end end end
	if PS then for _,pal in ipairs(CACHE.pallets) do for _,d in ipairs(pal:GetDescendants()) do if d.Name=="PalletPointSlide" or d.Name:find("Slide") then pcall(function() PS:FireServer(d,true) end) end end end end
end

function UnlockWP()
	local rem = RS:FindFirstChild("Remotes")
	local W = rem and rem:FindFirstChild("Window"); local VC = W and W:FindFirstChild("VaultCompleteEvent")
	local P = rem and rem:FindFirstChild("Pallet"); local PCn = P and P:FindFirstChild("PalletSlideCompleteEvent")
	ScanInteractables()
	if VC then for _,v in ipairs(CACHE.vaults) do for _,d in ipairs(v:GetDescendants()) do if d.Name=="VaultTrigger" then pcall(function() VC:FireServer(d,false) end) end end end end
	if PCn then for _,pal in ipairs(CACHE.pallets) do for _,d in ipairs(pal:GetDescendants()) do if d.Name=="PalletPointSlide" or d.Name:find("Slide") then pcall(function() PCn:FireServer(d) end) end end end end
end

function GenBuff()
	-- Hypnosis Max: occupy all slots except 1, then fully release so YOU can still repair
	local c = LP.Character
	local r = c and GetRoot(c)
	if not r then return end

	local function partOf(obj)
		if not obj then return nil end
		if obj:IsA("Model") then
			return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
		end
		return obj:FindFirstChildWhichIsA("BasePart")
	end

	local gens = {}
	local Map = Workspace:FindFirstChild("Map")
	if Map then
		for _, folderName in ipairs({"Generators", "Gens"}) do
			local f = Map:FindFirstChild(folderName)
			if f then
				for _, ch in ipairs(f:GetChildren()) do
					if ch.Name == "Generator" or string.find(string.lower(ch.Name), "generator") then
						table.insert(gens, ch)
					end
				end
			end
		end
		if #gens == 0 then
			for _, d in ipairs(Map:GetDescendants()) do
				if d:IsA("Model") and (d.Name == "Generator" or string.find(string.lower(d.Name), "generator")) then
					table.insert(gens, d)
				end
			end
		end
	end
	if #gens == 0 then
		for _, d in ipairs(Workspace:GetDescendants()) do
			if d:IsA("Model") and (d.Name == "Generator" or string.find(d.Name, "Generator")) then
				table.insert(gens, d)
			end
		end
	end

	local best, bestDist = nil, math.huge
	for _, g in ipairs(gens) do
		local pt = partOf(g)
		if pt then
			local dist = (pt.Position - r.Position).Magnitude
			if dist < bestDist then
				bestDist = dist
				best = g
			end
		end
	end
	if not best or bestDist > 35 then return end

	local pts = {}
	for _, ch in ipairs(best:GetChildren()) do
		local n = string.lower(ch.Name)
		if string.find(n, "generatorpoint") or string.find(n, "point") then
			table.insert(pts, ch)
		end
	end
	table.sort(pts, function(a, b) return a.Name < b.Name end)

	local rem = RS:FindFirstChild("Remotes")
	local G = rem and rem:FindFirstChild("Generator")
	local ev = G and G:FindFirstChild("RepairEvent")
	if not ev then
		ev = RS:FindFirstChild("RepairEvent", true)
	end
	if not ev and rem then
		for _, d in ipairs(rem:GetDescendants()) do
			if d:IsA("RemoteEvent") and (d.Name == "RepairEvent" or d.Name == "Repair") then
				ev = d
				break
			end
		end
	end
	if not ev then return end

	-- do NOT fireproximityprompt - that locks local player onto gen and blocks normal repair
	local n = #pts
	if n >= 2 then
		if n == 2 then
			pcall(function() ev:FireServer(pts[2], true) end)
			task.wait(0.2)
			pcall(function() ev:FireServer(pts[1], true) end)
			task.wait(0.2)
			pcall(function() ev:FireServer(pts[1], false) end)
		else
			local last = pts[n]
			for i = 1, n - 1 do
				local pt = pts[i]
				pcall(function() ev:FireServer(pt, true) end)
				task.wait(0.15)
				pcall(function() ev:FireServer(last, true) end)
				task.wait(0.15)
				pcall(function() ev:FireServer(last, false) end)
				if i < n - 1 then task.wait(0.1) end
			end
		end
	elseif n == 1 then
		pcall(function() ev:FireServer(pts[1], true) end)
		task.wait(0.2)
		pcall(function() ev:FireServer(pts[1], false) end)
	end

	-- CRITICAL: release ALL points so local player can interact/repair normally after
	task.wait(0.1)
	for _, pt in ipairs(pts) do
		pcall(function() ev:FireServer(pt, false) end)
	end
	-- clear local repair flags if game uses attributes
	pcall(function()
		if c then
			c:SetAttribute("Repairing", false)
			c:SetAttribute("IsRepairing", false)
		end
		LP:SetAttribute("Repairing", false)
	end)
end


function AutoUnhook()
	local c = LP.Character; local r = c and GetRoot(c); local h = GetHum(c)
	if not r or not h then return end
	local hooked = c:GetAttribute("IsHooked")==true or LP:GetAttribute("IsHooked")==true or (tonumber(c:GetAttribute("HookedProgress")) or 0)>0
	if not hooked then return end
	local saved = r.CFrame
	local rem = RS:FindFirstChild("Remotes")
	local Car = rem and rem:FindFirstChild("Carry")
	local selfUn = Car and Car:FindFirstChild("SelfUnHookEvent")
	local killer = nil
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character and (IsKiller(pl) or (pl.Team and pl.Team.Name:lower():find("killer"))) then killer = pl.Character break end
	end
	if killer then
		local kr = GetRoot(killer)
		if kr then
			local t0 = tick()
			while tick()-t0<60 do
				local charge = tonumber(c:GetAttribute("anticampCharge")) or tonumber(LP:GetAttribute("anticampCharge")) or 0
				if charge>=100 then break end
				if r.Parent then r.CFrame = CFrame.new(kr.Position-Vector3.new(0,16,0)) end
				task.wait(0.06)
			end
		end
	end
	if r.Parent then r.CFrame = saved end
	task.wait(0.2)
	if selfUn then pcall(function() selfUn:FireServer() end) end
end

-- ===================== DBD HUD OVERLAY ENGINE =====================
DBDH = {On=false,Loop=nil,Orig={},Icons={}}
HUD_DEFS = {
Healthy = {rbx="", urls={"https://www.dropbox.com/scl/fi/tkdvl8hv4supk25pksj7f/3d3yth.png?rlkey=cn2s8u9bjtfl596oo9vqa2ov7&st=sdbcs9pc&dl=1","https://files.catbox.moe/3d3yth.png"}},
Injured = {rbx="", urls={"https://www.dropbox.com/scl/fi/hmjn93oqkofu6qm64ra5g/dj03nn.png?rlkey=pwa7gyja0i2lv86711ozn00sz&st=00vp3w9y&dl=1","https://files.catbox.moe/dj03nn.png"}},
Carried = {rbx="", urls={"https://www.dropbox.com/scl/fi/f09u75eegwgyj5t11z9g4/8099e0.png?rlkey=fchscox15467e2p6p38gghw8x&st=5k74o3o3&dl=1","https://files.catbox.moe/8099e0.png"}},
Hooked  = {rbx="", urls={"https://www.dropbox.com/scl/fi/n1b2c4c8s9t2m9d/hooked.png?rlkey=3n28941k0&dl=1","https://files.catbox.moe/hooked.png"}},
Dead    = {rbx="", urls={"https://www.dropbox.com/scl/fi/dead_icon.png?rlkey=dead&dl=1","https://files.catbox.moe/dead.png"}}
}

function FetchHUDAssets()
	for k,v in pairs(HUD_DEFS) do
		if v.rbx ~= "" then DBDH.Icons[k] = v.rbx
		else
			for _,u in ipairs(v.urls) do
				local body = httpGetBody(u)
				if body then
					pcall(function()
						if writefile then
							local fn = "GoatLose_Hud_"..k..".png"
							writefile(fn,body)
							if getcustomasset then DBDH.Icons[k] = getcustomasset(fn) end
						end
					end)
					if DBDH.Icons[k] then break end
				end
			end
		end
	end
end
task.spawn(FetchHUDAssets)

function DBDHTgl(on)
	DBDH.On = on; S.On.dbdhud = on
	if DBDH.Loop then task.cancel(DBDH.Loop); DBDH.Loop = nil end
	if on then
		DBDH.Loop = task.spawn(function()
			while DBDH.On do
				local pg = LP:FindFirstChild("PlayerGui"); local hg = pg and pg:FindFirstChild("IngameHudGui")
				if hg then
					local frame = hg:FindFirstChild("Frame") or hg:FindFirstChild("Survivors")
					if frame then
						for _,child in ipairs(frame:GetChildren()) do
							if child:IsA("ImageLabel") or child:IsA("Frame") then
								local img = child:IsA("ImageLabel") and child or child:FindFirstChildWhichIsA("ImageLabel")
								if img then
									if not DBDH.Orig[img] then DBDH.Orig[img] = img.Image end
									local st = child:GetAttribute("Status") or "Healthy"
									if DBDH.Icons[st] then img.Image = DBDH.Icons[st] end
								end
							end
						end
					end
				end
				task.wait(0.2)
			end
		end)
	else
		for img,orig in pairs(DBDH.Orig) do if img and img.Parent then img.Image = orig end end
		DBDH.Orig = {}
	end
end


-- ===================== VEIL AIMBOT / NO ATTACK CD / MASKED =====================
VEIL = {
	AimOn = false,
	Conn = nil,
	Target = nil,
	Key = "MouseButton2",
	FOV = 150,
	Smooth = 0.05,
	Part = "UpperTorso",
	Pred = 0.05,
	Silent = false,
	Priority = "Nearest",
	Speed = 150,
	Gravity = 98,
}

local function veilKeyDown()
	local k = VEIL.Key
	if k == "MouseButton2" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
	if k == "MouseButton1" then return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
	local ok, code = pcall(function() return Enum.KeyCode[k] end)
	if ok and code then return UIS:IsKeyDown(code) end
	return false
end

local function veilInSpearMode()
	local c = LP.Character
	if not c then return false end
	if c:GetAttribute("spearmode") == true then return true end
	if LP:GetAttribute("spearmode") == true then return true end
	-- tool named veil/spear
	for _,d in ipairs(c:GetChildren()) do
		local n = d.Name:lower()
		if n:find("veil") or n:find("spear") then return true end
	end
	return false
end

local function veilSolveAim(origin, targetPos, targetVel, projSpeed, gravity)
	-- simple ballistic lead
	local to = targetPos - origin
	local dist = to.Magnitude
	if dist < 0.1 then return to.Unit, targetPos end
	local speed = projSpeed or 150
	local tflight = dist / speed
	local lead = targetPos + (targetVel or Vector3.new()) * tflight
	-- gravity drop compensate
	local g = gravity or 98
	lead = lead + Vector3.new(0, 0.5 * g * tflight * tflight * 0.15, 0)
	local dir = (lead - origin)
	if dir.Magnitude < 0.1 then return to.Unit, lead end
	return dir.Unit, lead
end

local function veilPickTarget(cam)
	local center = UIS:GetMouseLocation()
	-- when holding, use screen center-ish mouse
	local bestList = {}
	local myTeam = LP.Team
	local fov = tonumber(VEIL.FOV) or 150
	local partName = VEIL.Part or "UpperTorso"
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl == LP then
		elseif myTeam and pl.Team == myTeam then
		elseif pl.Character then
			local hum = GetHum(pl.Character)
			local part = pl.Character:FindFirstChild(partName)
				or pl.Character:FindFirstChild("UpperTorso")
				or pl.Character:FindFirstChild("Torso")
				or GetRoot(pl.Character)
			if hum and hum.Health > 0 and part then
				local sp, onScreen = cam:WorldToViewportPoint(part.Position)
				if onScreen and sp.Z > 0 then
					local dist = (Vector2.new(sp.X, sp.Y) - Vector2.new(center.X, center.Y)).Magnitude
					if dist <= fov then
						table.insert(bestList, {
							root = part,
							dist = dist,
							health = hum.Health,
							maxHealth = math.max(hum.MaxHealth, 1),
							world = (part.Position - cam.CFrame.Position).Magnitude,
						})
					end
				end
			end
		end
	end
	if #bestList == 0 then return nil end
	local prio = VEIL.Priority or "Nearest"
	table.sort(bestList, function(a, b)
		if prio == "Furthest" then return a.world > b.world end
		if prio == "Injured" then return (a.health/a.maxHealth) < (b.health/b.maxHealth) end
		if prio == "Healed" then return (a.health/a.maxHealth) > (b.health/b.maxHealth) end
		if prio == "NearestInjured" then
			local ai = a.health/a.maxHealth < 0.5 and 0 or 1
			local bi = b.health/b.maxHealth < 0.5 and 0 or 1
			if ai ~= bi then return ai < bi end
			return a.world < b.world
		end
		-- Nearest (screen FOV dist)
		return a.dist < b.dist
	end)
	return bestList[1].root
end

local function veilFireSpear(pos)
	pcall(function()
		local rem = RS:FindFirstChild("Remotes")
		local killers = rem and rem:FindFirstChild("Killers")
		local veil = killers and killers:FindFirstChild("Veil")
		local spear = veil and (veil:FindFirstChild("Spearthrow") or veil:FindFirstChild("SpearThrow") or veil:FindFirstChild("Throw"))
		if spear then
			spear:FireServer(pos)
			return
		end
		if rem then
			for _,d in ipairs(rem:GetDescendants()) do
				if d:IsA("RemoteEvent") then
					local n = d.Name:lower()
					if n:find("spear") and (n:find("throw") or n:find("fire")) then
						d:FireServer(pos)
						return
					end
				end
			end
		end
	end)
end

function VeilAimTgl(on)
	VEIL.AimOn = on
	S.On.veilaim = on
	if VEIL.Conn then
		pcall(function() RunService:UnbindFromRenderStep("GoatLose_VeilAim") end)
		pcall(function() VEIL.Conn:Disconnect() end)
		VEIL.Conn = nil
	end
	VEIL.Target = nil
	if not on then return end

	local function step()
		if not VEIL.AimOn then VEIL.Target = nil return end
		if not veilInSpearMode() then VEIL.Target = nil return end
		if not veilKeyDown() then VEIL.Target = nil return end
		local cam = Workspace.CurrentCamera
		if not cam then return end
		local char = LP.Character
		if not char then return end

		local tgt = VEIL.Target
		if not tgt or not tgt.Parent then
			tgt = veilPickTarget(cam)
			VEIL.Target = tgt
		else
			local hum = tgt.Parent:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				tgt = veilPickTarget(cam)
				VEIL.Target = tgt
			end
		end
		if not tgt then return end

		local head = char:FindFirstChild("Head") or GetRoot(char)
		local origin = cam.CFrame.Position
		if head then
			-- hypnosis offset from head for spear spawn
			origin = head.CFrame:PointToWorldSpace(Vector3.new(1.35, 0.34, -2.51))
		end

		local root = tgt.Parent:FindFirstChild("HumanoidRootPart") or tgt
		local vel = Vector3.new()
		pcall(function() vel = root.AssemblyLinearVelocity or root.Velocity or Vector3.new() end)
		local ping = 0.04
		pcall(function() ping = LP:GetNetworkPing() end)
		local predT = ping + (tonumber(VEIL.Pred) or 0.05)
		local aimPos = tgt.Position + vel * predT

		local dir, lead = veilSolveAim(origin, aimPos, vel, VEIL.Speed or 150, VEIL.Gravity or 98)
		-- face character toward target horizontally
		local hrp = GetRoot(char)
		if hrp then
			local look = Vector3.new(lead.X, hrp.Position.Y, lead.Z)
			pcall(function() hrp.CFrame = CFrame.new(hrp.Position, look) end)
		end
		local goal = CFrame.lookAt(cam.CFrame.Position, origin + dir * (lead - origin).Magnitude)
		local sm = tonumber(VEIL.Smooth) or 0.05
		if sm <= 0 then
			cam.CFrame = goal
		else
			cam.CFrame = cam.CFrame:Lerp(goal, math.clamp(sm, 0.02, 1))
		end
		if VEIL.Silent then
			veilFireSpear(lead)
		end
	end

	pcall(function()
		RunService:BindToRenderStep("GoatLose_VeilAim", Enum.RenderPriority.Camera.Value + 1, step)
		VEIL.Conn = {Disconnect = function()
			pcall(function() RunService:UnbindFromRenderStep("GoatLose_VeilAim") end)
		end}
	end)
	-- fallback Heartbeat if Bind fails
	if not VEIL.Conn then
		VEIL.Conn = RunService.RenderStepped:Connect(step)
	end
end

function MaskedApply(id)
	if MASK.Busy then return end
	MASK.Busy = true
	task.spawn(function()
		local ok, err = pcall(function()
			local rem = RS:FindFirstChild("Remotes")
			local killers = rem and rem:FindFirstChild("Killers")
			local masked = killers and killers:FindFirstChild("Masked")
			local deact = masked and masked:FindFirstChild("Deactivatepower")
			local act = masked and masked:FindFirstChild("Activatepower")
			if deact then
				deact:FireServer()
			else
				pcall(function() RS.Remotes.Killers.Masked.Deactivatepower:FireServer() end)
			end
			if id then
				task.wait(4)
				if act then
					act:FireServer(id)
				else
					pcall(function() RS.Remotes.Killers.Masked.Activatepower:FireServer(id) end)
				end
			end
		end)
		MASK.Busy = false
	end)
end

-- ===================== ABYSSWALKER INFINITE CORRUPT + ANTISUN =====================
CORRUPT = {On=false, Conn=nil, HoldStart=0, Holding=false, Rate=0.3, HoldNeed=1.4, Last=0, Mode="Hold"}

local function CorruptGetRemote()
	local rem = RS:FindFirstChild("Remotes")
	local killers = rem and rem:FindFirstChild("Killers")
	local abyss = killers and (killers:FindFirstChild("Abysswalker") or killers:FindFirstChild("AbyssWalker") or killers:FindFirstChild("Knight"))
	if abyss then
		local c = abyss:FindFirstChild("corrupt") or abyss:FindFirstChild("Corrupt") or abyss:FindFirstChild("Corruption")
		if c then return c end
	end
	if rem then
		for _,d in ipairs(rem:GetDescendants()) do
			local n = d.Name:lower()
			if d:IsA("RemoteEvent") and (n == "corrupt" or n == "corruption") then
				return d
			end
		end
	end
	return nil
end

local function CorruptFire()
	local r = CorruptGetRemote()
	if not r then return end
	pcall(function() r:FireServer() end)
	pcall(function() r:FireServer(true) end)
	pcall(function() r:FireServer(false) end)
	pcall(function() r:FireServer(1) end)
end

function CorruptTgl(on)
	CORRUPT.On = on
	S.On.infcorrupt = on
	if CORRUPT.Conn then CORRUPT.Conn:Disconnect(); CORRUPT.Conn = nil end
	CORRUPT.Holding = false
	CORRUPT.HoldStart = 0
	if not on then return end
	CORRUPT.Conn = RunService.Heartbeat:Connect(function()
		if not CORRUPT.On then return end
		if not IsLocalKiller() then
			CORRUPT.Holding = false
			return
		end
		local mode = CORRUPT.Mode or "Hold"
		local down = UIS:IsKeyDown(Enum.KeyCode.Q)
		local now = tick()
		local rate = tonumber(CORRUPT.Rate) or 0.3

		if mode == "Instant" then
			-- spam while Q held, no 1.4s wait (what actually works for you)
			if not down then
				CORRUPT.Holding = false
				return
			end
			if now - (CORRUPT.Last or 0) >= rate then
				CORRUPT.Last = now
				CorruptFire()
			end
			return
		end

		-- Hold mode: need hold >= HoldNeed then spam
		if down then
			if not CORRUPT.Holding then
				CORRUPT.Holding = true
				CORRUPT.HoldStart = now
			end
			local held = now - (CORRUPT.HoldStart or now)
			if held >= (tonumber(CORRUPT.HoldNeed) or 1.4) then
				if now - (CORRUPT.Last or 0) >= rate then
					CORRUPT.Last = now
					CorruptFire()
				end
			end
		else
			CORRUPT.Holding = false
			CORRUPT.HoldStart = 0
		end
	end)
end



NACD = {On=false, Conn=nil, Holding=false, LastFire=0, Rate=0.05}

local function NACDGetRemote()
	local rem = RS:FindFirstChild("Remotes")
	if not rem then return nil end
	local attacks = rem:FindFirstChild("Attacks")
	if attacks then
		local ba = attacks:FindFirstChild("BasicAttack")
		if ba then return ba end
	end
	-- fallback scan
	for _,d in ipairs(rem:GetDescendants()) do
		if d:IsA("RemoteEvent") and d.Name:lower() == "basicattack" then
			return d
		end
	end
	return nil
end

local function NACDFire()
	local remote = NACDGetRemote()
	if not remote then return end
	-- ONLY remote — no VIM mouse (mouse events freeze game/menu GUIs)
	pcall(function() remote:FireServer(false) end)
	pcall(function() remote:FireServer() end)
end

function NACDTgl(on)
	NACD.On = on
	S.On.noattackcd = on
	if NACD.Conn then NACD.Conn:Disconnect(); NACD.Conn = nil end
	NACD.Holding = false
	if not on then return end
	-- while toggle ON: if LMB held, spam BasicAttack
	NACD.Conn = RunService.Heartbeat:Connect(function()
		if not NACD.On then return end
		local held = false
		pcall(function()
			held = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		end)
		-- mobile: also treat MOBILE_AIM_HOLD if present
		if not held and MOBILE_AIM_HOLD then held = true end
		NACD.Holding = held
		if not held then return end
		local now = tick()
		local rate = tonumber(NACD.Rate) or 0.05
		if now - (NACD.LastFire or 0) < rate then return end
		NACD.LastFire = now
		NACDFire()
	end)
end





-- ===================== HIDE DEFAULT NAMETAGS =====================
HIDENAME = {On=false,Conn=nil}

local function HNStrip(char)
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		pcall(function()
			hum.NameDisplayDistance = 0
			hum.HealthDisplayDistance = 0
			hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end)
	end
	-- only default name distance (do NOT kill game billboards/UI)
end

function HideNamesTgl(on)
	HIDENAME.On = on
	S.On.hidenames = on
	if HIDENAME.Conn then HIDENAME.Conn:Disconnect(); HIDENAME.Conn = nil end
	if not on then
		-- restore distances
		for _,pl in ipairs(Players:GetPlayers()) do
			if pl.Character then
				local hum = pl.Character:FindFirstChildOfClass("Humanoid")
				if hum then
					pcall(function()
						hum.NameDisplayDistance = 100
						hum.HealthDisplayDistance = 100
						hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
					end)
				end
			end
		end
		return
	end
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl.Character then HNStrip(pl.Character) end
	end
	HIDENAME.Conn = RunService.Heartbeat:Connect(function()
		if not HIDENAME.On then return end
		for _,pl in ipairs(Players:GetPlayers()) do
			if pl.Character then HNStrip(pl.Character) end
		end
	end)
	Players.PlayerAdded:Connect(function(pl)
		pl.CharacterAdded:Connect(function(ch)
			task.wait(0.5)
			if HIDENAME.On then HNStrip(ch) end
		end)
	end)
end

-- ===================== NAME / OUTFIT CHANGER =====================
NAMECH = {Text = "Anonymous", Conn = nil, On = false}
OUTFIT = {User = "", Busy = false}

local function NCApplyLocal(name)
	name = tostring(name or "Anonymous")
	if name == "" then name = "Anonymous" end
	local c = LP.Character
	if not c then return end
	local hum = GetHum(c)
	-- Billboard / nametag under character
	for _,d in ipairs(c:GetDescendants()) do
		if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
			for _,l in ipairs(d:GetDescendants()) do
				if l:IsA("TextLabel") or l:IsA("TextButton") then
					local t = l.Text or ""
					if t ~= "" and (#t < 40) then
						if t == LP.Name or t == LP.DisplayName or t:find(LP.Name) or t:find(LP.DisplayName) then
							l.Text = name
						end
					end
				end
			end
		end
	end
	-- common Humanoid DisplayDistance / name
	if hum then
		pcall(function() hum.DisplayName = name end)
		pcall(function() hum.NameDisplayDistance = 100 end)
	end
	-- PlayerGui live list / hud labels with own name
	local pg = LP:FindFirstChild("PlayerGui")
	if pg then
		for _,l in ipairs(pg:GetDescendants()) do
			if l:IsA("TextLabel") or l:IsA("TextButton") then
				local tx = l.Text or ""
				if tx == LP.DisplayName or tx == LP.Name or tx == ("@"..LP.Name) then
					if not l:GetAttribute("GL_OrigName") then
						l:SetAttribute("GL_OrigName", tx)
					end
					if tx:sub(1,1) == "@" then
						l.Text = "@"..name
					else
						l.Text = name
					end
				end
			end
		end
	end
end

function NameChangerSet(text)
	NAMECH.Text = tostring(text or "Anonymous")
	if NAMECH.Text == "" then NAMECH.Text = "Anonymous" end
	NCApplyLocal(NAMECH.Text)
end

function NameChangerTgl(on)
	NAMECH.On = on
	S.On.namech = on
	if NAMECH.Conn then NAMECH.Conn:Disconnect(); NAMECH.Conn = nil end
	if on then
		NCApplyLocal(NAMECH.Text)
		NAMECH.Conn = RunService.Heartbeat:Connect(function()
			if not NAMECH.On then return end
			if tick() % 1 < 0.05 then NCApplyLocal(NAMECH.Text) end
		end)
		LP.CharacterAdded:Connect(function()
			task.wait(0.6)
			if NAMECH.On then NCApplyLocal(NAMECH.Text) end
		end)
	end
end

OUTFIT_PRESETS = {
	["Best Skin"] = "Kakainovaya_kohka",
	["Kakainovaya_kohka"] = "Kakainovaya_kohka",
}

local function httpGet(url)
	local body
	pcall(function()
		if type(request) == "function" then
			local r = request({Url = url, Method = "GET"})
			if r and (r.Body or r.body) then body = r.Body or r.body end
		elseif type(http_request) == "function" then
			local r = http_request({Url = url, Method = "GET"})
			if r and (r.Body or r.body) then body = r.Body or r.body end
		elseif game.HttpGet then
			body = game:HttpGet(url)
		end
	end)
	return body
end

local function resolveUserId(input)
	input = tostring(input or ""):gsub("^%s+",""):gsub("%s+$","")
	if input == "" then return nil, "empty" end
	if OUTFIT_PRESETS and OUTFIT_PRESETS[input] then
		input = OUTFIT_PRESETS[input]
	end
	if tonumber(input) then
		local n = tonumber(input)
		if n and n > 0 then return n end
	end
	input = input:gsub("^@","")
	-- 1) Players:GetUserIdFromNameAsync
	local uid
	local ok = pcall(function()
		uid = Players:GetUserIdFromNameAsync(input)
	end)
	if ok and type(uid) == "number" and uid > 0 then return uid end
	-- 2) case-insensitive: try exact via new API
	local body = httpGet("https://users.roblox.com/v1/usernames/users")
	-- POST preferred
	local postBody
	pcall(function()
		local payload = HttpService:JSONEncode({usernames = {input}, excludeBannedUsers = false})
		local req = (syn and syn.request) or http_request or request
		if req then
			local r = req({
				Url = "https://users.roblox.com/v1/usernames/users",
				Method = "POST",
				Headers = {["Content-Type"] = "application/json"},
				Body = payload,
			})
			postBody = r and (r.Body or r.body)
		end
	end)
	if postBody then
		local okj, data = pcall(function() return HttpService:JSONDecode(postBody) end)
		if okj and type(data) == "table" and type(data.data) == "table" then
			for _, row in ipairs(data.data) do
				if row and tonumber(row.id) then
					return tonumber(row.id)
				end
			end
		end
	end
	-- 3) legacy get-by-username
	body = httpGet("https://api.roblox.com/users/get-by-username?username=" .. HttpService:UrlEncode(input))
	if body then
		local okj, data = pcall(function() return HttpService:JSONDecode(body) end)
		if okj and type(data) == "table" and tonumber(data.Id) then
			return tonumber(data.Id)
		end
	end
	-- 4) thumbnail/profile search fallback
	body = httpGet("https://users.roblox.com/v1/users/search?keyword=" .. HttpService:UrlEncode(input) .. "&limit=10")
	if body then
		local okj, data = pcall(function() return HttpService:JSONDecode(body) end)
		if okj and type(data) == "table" and type(data.data) == "table" then
			local lower = input:lower()
			for _, row in ipairs(data.data) do
				if row and type(row.name) == "string" and row.name:lower() == lower and tonumber(row.id) then
					return tonumber(row.id)
				end
			end
			-- if only one result, take it
			if #data.data == 1 and tonumber(data.data[1].id) then
				return tonumber(data.data[1].id)
			end
		end
	end
	return nil, "user not found: "..input
end

local function clearCharacterAppearance(char)
	for _,d in ipairs(char:GetChildren()) do
		if d:IsA("Accessory") or d:IsA("Hat") or d:IsA("Shirt") or d:IsA("Pants")
			or d:IsA("ShirtGraphic") or d:IsA("BodyColors") or d:IsA("CharacterMesh")
			or d:IsA("Pants") or d.Name == "Shirt" or d.Name == "Pants" then
			pcall(function() d:Destroy() end)
		end
	end
	-- layered clothing / wraps
	for _,d in ipairs(char:GetDescendants()) do
		if d:IsA("Accessory") or d:IsA("Hat") or d:IsA("WrapLayer") or d:IsA("WrapTarget") then
			pcall(function() d:Destroy() end)
		end
	end
end

local function weldParts(part0, part1, c0, c1)
	local weld = Instance.new("Weld")
	weld.Part0 = part0
	weld.Part1 = part1
	weld.C0 = c0 or CFrame.new()
	weld.C1 = c1 or CFrame.new()
	weld.Parent = part0
	return weld
end

local function findAttachment(root, name)
	if not root then return nil end
	for _, d in pairs(root:GetDescendants()) do
		if d:IsA("Attachment") and d.Name == name then return d end
	end
	return nil
end

local function weldAccessory(char, accessory)
	if not accessory or not char then return end
	-- ensure we work with a clone not parented elsewhere
	if accessory.Parent and accessory.Parent ~= workspace and accessory.Parent ~= char then
		accessory = accessory:Clone()
	end
	accessory.Parent = workspace
	local handle = accessory:FindFirstChild("Handle")
	if handle then
		handle.CanCollide = false
		handle.Massless = true
		local attachment = handle:FindFirstChildOfClass("Attachment")
		if attachment then
			local parentAttachment = findAttachment(char, attachment.Name)
			if parentAttachment then
				weldParts(parentAttachment.Parent, handle, parentAttachment.CFrame, attachment.CFrame)
			else
				local head = char:FindFirstChild("Head")
				if head then
					weldParts(head, handle, CFrame.new(0, 0, 0), attachment.CFrame)
				end
			end
		else
			local head = char:FindFirstChild("Head")
			if head then
				local ap = accessory.AttachmentPoint or CFrame.new()
				weldParts(head, handle, CFrame.new(0, 0.5, 0), ap)
			end
		end
	end
	accessory.Parent = char
	return accessory
end

-- PKL-style: GetObjects only (works on most executors)
local function addAccessoryById(char, accessoryId)
	accessoryId = tonumber(tostring(accessoryId):match("%d+"))
	if not accessoryId or accessoryId <= 0 then return false end
	local success, objects = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(accessoryId))
	end)
	if not success or not objects or #objects == 0 then
		-- fallback InsertService
		pcall(function()
			local model = game:GetService("InsertService"):LoadAsset(accessoryId)
			if model then
				objects = model:GetChildren()
			end
		end)
	end
	if not objects or #objects == 0 then return false end
	local got = false
	for _, obj in ipairs(objects) do
		if obj:IsA("Accessory") or obj:IsA("Hat") then
			weldAccessory(char, obj)
			got = true
		elseif obj:IsA("Model") or obj:IsA("Folder") then
			for _, ch in ipairs(obj:GetChildren()) do
				if ch:IsA("Accessory") or ch:IsA("Hat") then
					weldAccessory(char, ch)
					got = true
				end
			end
		end
	end
	return got
end


local function loadAccessoryAsset(char, assetId)
	return addAccessoryById(char, assetId)
end

local function fetchAvatarAssetIds(uid)
	local ids, seen = {}, {}
	local function add(id)
		id = tonumber(id)
		if id and id > 0 and not seen[id] then
			seen[id] = true
			table.insert(ids, id)
		end
	end
	local body = httpGet("https://avatar.roblox.com/v1/users/"..tostring(uid).."/currently-wearing")
	if body then
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if ok and type(data) == "table" and type(data.assetIds) == "table" then
			for _,id in ipairs(data.assetIds) do add(id) end
		end
	end
	body = httpGet("https://avatar.roblox.com/v2/avatar/users/"..tostring(uid).."/avatar")
	if body then
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if ok and type(data) == "table" and type(data.assets) == "table" then
			for _,a in ipairs(data.assets) do
				if type(a) == "table" then add(a.id or a.assetId) end
			end
		end
	end
	body = httpGet("https://avatar.roblox.com/v1/users/"..tostring(uid).."/avatar")
	if body then
		local ok, data = pcall(function() return HttpService:JSONDecode(body) end)
		if ok and type(data) == "table" and type(data.assets) == "table" then
			for _,a in ipairs(data.assets) do
				if type(a) == "table" then add(a.id or a.assetId) end
			end
		end
	end
	return ids
end

local function applyBodyColors(char, desc)
	local bc = char:FindFirstChildOfClass("BodyColors")
	if not bc then
		bc = Instance.new("BodyColors")
		bc.Parent = char
	end
	pcall(function()
		bc.HeadColor3 = desc.HeadColor
		bc.TorsoColor3 = desc.TorsoColor
		bc.LeftArmColor3 = desc.LeftArmColor
		bc.RightArmColor3 = desc.RightArmColor
		bc.LeftLegColor3 = desc.LeftLegColor
		bc.RightLegColor3 = desc.RightLegColor
	end)
	local map = {
		Head = desc.HeadColor,
		Torso = desc.TorsoColor, UpperTorso = desc.TorsoColor, LowerTorso = desc.TorsoColor,
		["Left Arm"] = desc.LeftArmColor, LeftUpperArm = desc.LeftArmColor, LeftLowerArm = desc.LeftArmColor, LeftHand = desc.LeftArmColor,
		["Right Arm"] = desc.RightArmColor, RightUpperArm = desc.RightArmColor, RightLowerArm = desc.RightArmColor, RightHand = desc.RightArmColor,
		["Left Leg"] = desc.LeftLegColor, LeftUpperLeg = desc.LeftLegColor, LeftLowerLeg = desc.LeftLegColor, LeftFoot = desc.LeftLegColor,
		["Right Leg"] = desc.RightLegColor, RightUpperLeg = desc.RightLegColor, RightLowerLeg = desc.RightLegColor, RightFoot = desc.RightLegColor,
	}
	for name, col in pairs(map) do
		local part = char:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			pcall(function()
				part.Color = col
				part.Material = Enum.Material.Plastic
			end)
		end
	end
end

local function resolveClothingTemplate(assetId, className)
	assetId = tonumber(tostring(assetId):match("%d+"))
	if not assetId or assetId == 0 then return nil end
	local template = "rbxassetid://" .. tostring(assetId)
	pcall(function()
		local objs
		if type(game.GetObjects) == "function" then
			objs = game:GetObjects("rbxassetid://" .. tostring(assetId))
		end
		if (not objs or #objs == 0) then
			local model = game:GetService("InsertService"):LoadAsset(assetId)
			if model then objs = model:GetChildren() end
		end
		if type(objs) == "table" then
			for _, obj in ipairs(objs) do
				if className == "Shirt" and obj:IsA("Shirt") then
					template = obj.ShirtTemplate
					pcall(function() obj:Destroy() end)
					return
				elseif className == "Pants" and obj:IsA("Pants") then
					template = obj.PantsTemplate
					pcall(function() obj:Destroy() end)
					return
				elseif className == "ShirtGraphic" and obj:IsA("ShirtGraphic") then
					template = obj.Graphic
					pcall(function() obj:Destroy() end)
					return
				end
			end
		end
	end)
	return template
end

local function applyShirtPants(char, desc)
	-- remove old clothing first
	for _, cl in ipairs({"Shirt", "Pants", "ShirtGraphic"}) do
		local old = char:FindFirstChildOfClass(cl)
		if old then pcall(function() old:Destroy() end) end
	end
	pcall(function()
		local id = desc.Shirt
		if id and tonumber(id) and tonumber(id) ~= 0 then
			local tpl = resolveClothingTemplate(id, "Shirt")
			local s = Instance.new("Shirt")
			s.Name = "Shirt"
			s.ShirtTemplate = tpl or ("rbxassetid://" .. tostring(id))
			s.Parent = char
		end
	end)
	pcall(function()
		local id = desc.Pants
		if id and tonumber(id) and tonumber(id) ~= 0 then
			local tpl = resolveClothingTemplate(id, "Pants")
			local p = Instance.new("Pants")
			p.Name = "Pants"
			p.PantsTemplate = tpl or ("rbxassetid://" .. tostring(id))
			p.Parent = char
		end
	end)
	pcall(function()
		local id = desc.GraphicTShirt
		if id and tonumber(id) and tonumber(id) ~= 0 then
			local tpl = resolveClothingTemplate(id, "ShirtGraphic")
			local g = Instance.new("ShirtGraphic")
			g.Name = "ShirtGraphic"
			g.Graphic = tpl or ("rbxassetid://" .. tostring(id))
			g.Parent = char
		end
	end)
end

local function applyAccessoriesFromDesc(char, desc)
	local fields = {
		"BackAccessory","FaceAccessory","FrontAccessory","HairAccessory",
		"HatAccessory","NeckAccessory","ShouldersAccessory","WaistAccessory",
		"Hair","Head","Face","Hat","Neck","Shoulders","Front","Back","Waist"
	}
	for _, field in ipairs(fields) do
		local ok, val = pcall(function() return desc[field] end)
		if ok and val ~= nil and val ~= "" and val ~= 0 then
			if type(val) == "string" then
				for id in string.gmatch(val, "%d+") do
					addAccessoryById(char, id)
				end
			elseif type(val) == "number" then
				addAccessoryById(char, val)
			end
		end
	end
end

local function applyFace(char, desc)
	pcall(function()
		if not desc.Face or tonumber(desc.Face) == 0 then return end
		local head = char:FindFirstChild("Head")
		if not head then return end
		local face = head:FindFirstChild("face")
		if not face then
			face = Instance.new("Decal")
			face.Name = "face"
			face.Face = Enum.NormalId.Front
			face.Parent = head
		end
		face.Texture = "http://www.roblox.com/asset/?id=" .. tostring(desc.Face)
	end)
end

-- Prefer full model from description (client-safe), then copy look onto our character
local function applyFromModel(char, model)
	if not model or not char then return false end
	clearCharacterAppearance(char)
	-- body colors from model
	local mbc = model:FindFirstChildOfClass("BodyColors")
	if mbc then
		local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
		bc.Parent = char
		pcall(function()
			bc.HeadColor3 = mbc.HeadColor3
			bc.TorsoColor3 = mbc.TorsoColor3
			bc.LeftArmColor3 = mbc.LeftArmColor3
			bc.RightArmColor3 = mbc.RightArmColor3
			bc.LeftLegColor3 = mbc.LeftLegColor3
			bc.RightLegColor3 = mbc.RightLegColor3
		end)
	end
	-- paint parts by name
	for _,mp in ipairs(model:GetChildren()) do
		if mp:IsA("BasePart") then
			local cp = char:FindFirstChild(mp.Name)
			if cp and cp:IsA("BasePart") then
				pcall(function()
					cp.Color = mp.Color
					cp.Material = mp.Material
					cp.Reflectance = mp.Reflectance
					cp.Transparency = mp.Transparency
				end)
			end
		end
	end
	-- shirt / pants
	for _,cl in ipairs(model:GetChildren()) do
		if cl:IsA("Shirt") or cl:IsA("Pants") or cl:IsA("ShirtGraphic") then
			local copy = cl:Clone()
			copy.Parent = char
		end
	end
	-- accessories (children + descendants)
	local seen = {}
	local function addAcc(acc)
		if seen[acc] then return end
		seen[acc] = true
		weldAccessory(char, acc:Clone())
	end
	for _,acc in ipairs(model:GetChildren()) do
		if acc:IsA("Accessory") or acc:IsA("Hat") then addAcc(acc) end
	end
	for _,acc in ipairs(model:GetDescendants()) do
		if acc:IsA("Accessory") or acc:IsA("Hat") then addAcc(acc) end
	end
	-- face decal
	local mhead = model:FindFirstChild("Head")
	local chead = char:FindFirstChild("Head")
	if mhead and chead then
		local mface = mhead:FindFirstChild("face") or mhead:FindFirstChildOfClass("Decal")
		if mface then
			local cface = chead:FindFirstChild("face") or chead:FindFirstChildOfClass("Decal")
			if not cface then
				cface = Instance.new("Decal")
				cface.Name = "face"
				cface.Face = Enum.NormalId.Front
				cface.Parent = chead
			end
			cface.Texture = mface.Texture
		end
	end
	return true
end

local function applyDescriptionClient(char, desc)
	-- 1) try CreateHumanoidModelFromDescription / FromUserId
	local model
	pcall(function()
		if Players.CreateHumanoidModelFromDescription then
			model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
		end
	end)
	if not model then
		pcall(function()
			if Players.CreateHumanoidModelFromDescription then
				model = Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R6)
			end
		end)
	end
	if model then
		model.Parent = nil
		local ok = applyFromModel(char, model)
		pcall(function() model:Destroy() end)
		if ok then return end
	end
	-- 2) manual description fields
	clearCharacterAppearance(char)
	applyBodyColors(char, desc)
	applyShirtPants(char, desc)
	applyAccessoriesFromDesc(char, desc)
	applyFace(char, desc)
end


-- ===================== OUTFIT (GetObjects real assets R6/R15) =====================
local function OutfitCleanCharacter(character)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Accessory") or obj:IsA("Hat") or obj:IsA("Shirt") or obj:IsA("Pants")
			or obj:IsA("ShirtGraphic") or obj:IsA("CharacterMesh") or obj:IsA("BodyColors") then
			pcall(function() obj:Destroy() end)
		end
	end
	local validLimbs = {
		Head=true, Torso=true, ["Left Arm"]=true, ["Right Arm"]=true, ["Left Leg"]=true, ["Right Leg"]=true,
		UpperTorso=true, LowerTorso=true, LeftUpperArm=true, LeftLowerArm=true, LeftHand=true,
		RightUpperArm=true, RightLowerArm=true, RightHand=true, LeftUpperLeg=true, LeftLowerLeg=true,
		LeftFoot=true, RightUpperLeg=true, RightLowerLeg=true, RightFoot=true, HumanoidRootPart=true
	}
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA("Model") or child:IsA("Folder") then
			if child.Name ~= "R6_VisualMorph_Shifted" then -- keep TTS if active? clear outfits folders
				pcall(function() child:Destroy() end)
			end
		elseif child:IsA("BasePart") and not validLimbs[child.Name] then
			pcall(function() child:Destroy() end)
		end
	end
end

local function OutfitWeldAccessory(character, acc)
	local handle = acc:FindFirstChild("Handle")
	if not handle then
		pcall(function() acc:Destroy() end)
		return
	end
	acc.Parent = character
	handle.CanCollide = false
	handle.Massless = true
	handle.Anchored = false
	for _, v in ipairs(handle:GetChildren()) do
		if v:IsA("Weld") or v:IsA("Motor6D") or v:IsA("ManualWeld") then
			v:Destroy()
		end
	end
	local accAtt = handle:FindFirstChildOfClass("Attachment")
	if accAtt then
		local charAtt = character:FindFirstChild(accAtt.Name, true)
		if charAtt and charAtt:IsA("Attachment") and charAtt.Parent and charAtt.Parent:IsA("BasePart") then
			local limb = charAtt.Parent
			handle.CFrame = limb.CFrame * charAtt.CFrame * accAtt.CFrame:Inverse()
			local weld = Instance.new("Weld")
			weld.Name = "AccessoryWeld"
			weld.Part0 = limb
			weld.Part1 = handle
			weld.C0 = charAtt.CFrame
			weld.C1 = accAtt.CFrame
			weld.Parent = handle
			return
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		local offset = CFrame.new(0, 0.5, 0)
		local ap = CFrame.new()
		pcall(function() ap = acc.AttachmentPoint end)
		handle.CFrame = head.CFrame * offset * ap:Inverse()
		local weld = Instance.new("Weld")
		weld.Name = "HeadWeld"
		weld.Part0 = head
		weld.Part1 = handle
		weld.C0 = offset
		weld.C1 = ap
		weld.Parent = handle
	end
end

local function OutfitLoadAsset(character, assetId)
	if not assetId or assetId == 0 then return end
	local ok, objs = pcall(function()
		return game:GetObjects("rbxassetid://" .. tostring(assetId))
	end)
	if not ok or not objs then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local isR6 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6
	for _, root in ipairs(objs) do
		if root:IsA("Shirt") or root:IsA("Pants") or root:IsA("ShirtGraphic") then
			root.Parent = character
		elseif root:IsA("Accessory") or root:IsA("Hat") then
			OutfitWeldAccessory(character, root)
		elseif root:IsA("CharacterMesh") then
			root.Parent = character
		elseif root:IsA("SpecialMesh") or root:IsA("CylinderMesh") or root:IsA("BlockMesh") then
			local head = character:FindFirstChild("Head")
			if head then
				local oldMesh = head:FindFirstChildOfClass("SpecialMesh")
				if oldMesh then oldMesh:Destroy() end
				root.Parent = head
			end
		else
			for _, sub in ipairs(root:GetDescendants()) do
				if sub:IsA("CharacterMesh") then
					sub:Clone().Parent = character
				elseif sub:IsA("Accessory") or sub:IsA("Hat") then
					OutfitWeldAccessory(character, sub:Clone())
				elseif sub:IsA("Shirt") or sub:IsA("Pants") or sub:IsA("ShirtGraphic") then
					sub:Clone().Parent = character
				elseif sub:IsA("Decal") and (sub.Name == "face" or (sub.Parent and sub.Parent.Name == "Head")) then
					local head = character:FindFirstChild("Head")
					if head then
						local oldFace = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
						if oldFace then oldFace:Destroy() end
						local newFace = sub:Clone()
						newFace.Name = "face"
						newFace.Parent = head
					end
				elseif sub:IsA("MeshPart") and not isR6 then
					local limb = character:FindFirstChild(sub.Name)
					if limb and limb:IsA("MeshPart") then
						pcall(function()
							limb.MeshId = sub.MeshId
							limb.TextureID = sub.TextureID
							limb.Transparency = sub.Transparency
						end)
					end
				end
			end
			pcall(function() root:Destroy() end)
		end
	end
end

local function OutfitApplyByUserId(userId)
	local character = LP.Character
	if not character then return false, "no character" end
	local ok, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(userId)
	end)
	if not ok or not desc then
		ok, desc = pcall(function()
			return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
		end)
	end
	if not ok or not desc then return false, "desc fail" end

	OutfitCleanCharacter(character)

	local bc = Instance.new("BodyColors")
	bc.HeadColor3 = desc.HeadColor
	bc.TorsoColor3 = desc.TorsoColor
	bc.LeftArmColor3 = desc.LeftArmColor
	bc.RightArmColor3 = desc.RightArmColor
	bc.LeftLegColor3 = desc.LeftLegColor
	bc.RightLegColor3 = desc.RightLegColor
	bc.Parent = character

	local partColors = {
		Head = desc.HeadColor,
		Torso = desc.TorsoColor, UpperTorso = desc.TorsoColor, LowerTorso = desc.TorsoColor,
		["Left Arm"] = desc.LeftArmColor, LeftUpperArm = desc.LeftArmColor, LeftLowerArm = desc.LeftArmColor, LeftHand = desc.LeftArmColor,
		["Right Arm"] = desc.RightArmColor, RightUpperArm = desc.RightArmColor, RightLowerArm = desc.RightArmColor, RightHand = desc.RightArmColor,
		["Left Leg"] = desc.LeftLegColor, LeftUpperLeg = desc.LeftLegColor, LeftLowerLeg = desc.LeftLegColor, LeftFoot = desc.LeftLegColor,
		["Right Leg"] = desc.RightLegColor, RightUpperLeg = desc.RightLegColor, RightLowerLeg = desc.RightLegColor, RightFoot = desc.RightLegColor,
	}
	for name, color in pairs(partColors) do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			part.Color = color
			part.Transparency = (name == "HumanoidRootPart") and 1 or 0
		end
	end

	if desc.Shirt and desc.Shirt > 0 then OutfitLoadAsset(character, desc.Shirt) end
	if desc.Pants and desc.Pants > 0 then OutfitLoadAsset(character, desc.Pants) end
	if desc.GraphicTShirt and desc.GraphicTShirt > 0 then OutfitLoadAsset(character, desc.GraphicTShirt) end

	local head = character:FindFirstChild("Head")
	if head then
		if desc.Head == 134082579 then
			head.Transparency = 1
			local f = head:FindFirstChild("face") or head:FindFirstChildOfClass("Decal")
			if f then f.Transparency = 1 end
		else
			head.Transparency = 0
			if desc.Face and desc.Face > 0 then OutfitLoadAsset(character, desc.Face) end
		end
	end

	for _, bpId in ipairs({desc.Head, desc.Torso, desc.LeftArm, desc.RightArm, desc.LeftLeg, desc.RightLeg}) do
		if bpId and bpId > 0 and bpId ~= 134082579 then
			OutfitLoadAsset(character, bpId)
		end
	end

	local assetIds, seen = {}, {}
	local function addId(id)
		local n = tonumber(id)
		if n and n > 0 and not seen[n] then
			seen[n] = true
			table.insert(assetIds, n)
		end
	end
	for _, csv in ipairs({
		desc.HatAccessory, desc.HairAccessory, desc.FaceAccessory,
		desc.NeckAccessory, desc.ShouldersAccessory, desc.FrontAccessory,
		desc.BackAccessory, desc.WaistAccessory
	}) do
		if type(csv) == "string" then
			for idStr in string.gmatch(csv, "([^,]+)") do addId(idStr) end
		end
	end
	pcall(function()
		for _, item in ipairs(desc:GetAccessories(true) or {}) do
			addId(item.AssetId)
		end
	end)
	for _, id in ipairs(assetIds) do
		OutfitLoadAsset(character, id)
	end
	return true
end

function OutfitApplyFromUser(input)
	if OUTFIT.Busy then
		-- auto-unstick after 8s
		if OUTFIT.BusyAt and (tick() - OUTFIT.BusyAt) > 8 then
			OUTFIT.Busy = false
		else
			return false, "busy"
		end
	end
	if IsLocalKiller() then
		if OUTFIT.StatusLabel then
			pcall(function() OUTFIT.StatusLabel.Set("Outfit: blocked (Killer)") end)
		end
		return false, "killer - outfit disabled"
	end
	OUTFIT.Busy = true
	OUTFIT.BusyAt = tick()
	OUTFIT.User = tostring(input or "")
	local ok, err = pcall(function()
		local uid, e2 = resolveUserId(OUTFIT.User)
		if not uid then error(e2 or "user not found") end
		if OUTFIT.StatusLabel then
			pcall(function() OUTFIT.StatusLabel.Set("Outfit: uid "..tostring(uid).." loading...") end)
		end
		OUTFIT.LastUid = uid
		local ok2, e3 = OutfitApplyByUserId(uid)
		if not ok2 then error(e3 or "apply fail") end
		if OUTFIT.StatusLabel then
			pcall(function() OUTFIT.StatusLabel.Set("Outfit OK: "..tostring(OUTFIT.User)) end)
		end
		local uname
		pcall(function() uname = Players:GetNameFromUserIdAsync(uid) end)
		if uname then
			OUTFIT.User = uname
			if NAMECH and NAMECH.On then NameChangerSet(uname) end
		end
	end)
	OUTFIT.Busy = false
	if not ok then
		if OUTFIT.StatusLabel then
			pcall(function() OUTFIT.StatusLabel.Set("Outfit fail: "..tostring(err)) end)
		end
		return false, err
	end
	return true
end

function OutfitApplyAnonymous()
	if IsLocalKiller() then
		if OUTFIT.StatusLabel then
			pcall(function() OUTFIT.StatusLabel.Set("Outfit: blocked (Killer)") end)
		end
		return false, "killer - outfit disabled"
	end
	local ok, err = pcall(function()
		local c = LP.Character
		if not c then error("no character") end
		clearCharacterAppearance(c)
		local desc = Instance.new("HumanoidDescription")
		desc.HeadColor = Color3.fromRGB(163,162,165)
		desc.TorsoColor = Color3.fromRGB(163,162,165)
		desc.LeftArmColor = Color3.fromRGB(163,162,165)
		desc.RightArmColor = Color3.fromRGB(163,162,165)
		desc.LeftLegColor = Color3.fromRGB(163,162,165)
		desc.RightLegColor = Color3.fromRGB(163,162,165)
		applyBodyColors(c, desc)
		NameChangerSet("Anonymous")
		NameChangerTgl(true)
	end)
	return ok, err
end



-- ===================== TAB CONSTRUCTION =====================


-- TAB 1: MAIN
local p1 = AddTab("Main")
local s1 = AddSection(p1,"Parry & Combat Controls")
AddToggle(s1,"Auto Dagger",false,function(v) ADAGTgl(v) end)
AddSlider(s1,"Auto Dagger Range",3,30,12,1,function(v) ADAG.Range = v end)
AddKeybind(s1,"Auto Dagger Keybind","None",function() ADAGTgl(not ADAG.On) end)
AddToggle(s1,"Parry Range Circle",false,function(v) PCTgl(v) end)
AddColor(s1,"Circle Color",S.PC.Color,function(c) S.PC.Color = c end)
AddToggle(s1,"Fake Parry Emote",false,function(v) FPTgl(v) end)
AddDropdown(s1,"Emote Anim",FAKE_NAMES,"Katana",function(v)
	for i,name in ipairs(FAKE_NAMES) do if name == v then S.Parry.Anim = i break end end
	if S.On.fakeparry then FPPlay() end
end)
AddButton(s1,"Trigger Fake Parry",function() FPPulse() end)
AddToggle(s1,"Auto Crouch",false,function(v) ACTgl(v) end)

local s2 = AddSection(p1,"Automation & Survival")
AddToggle(s2,"Auto SkillCheck",false,function(v) ASCTgl(v) end)
AddToggle(s2,"Instant SkillCheck",false,function(v) ASCInstantTgl(v) end)
AddKeybind(s2,"Auto SkillCheck Keybind","None",function() ASCTgl(not ASC.On) end)
AddKeybind(s2,"Instant SkillCheck Keybind","None",function() ASCInstantTgl(not ASC.Instant) end)
AddKeybind(s2,"Save Teammate Keybind","None",function() SaveTeammateDo() end)
AddSlider(s2,"Save Teammate Range",20,150,80,0,function(v) SAVE_TM.Range = v end)
AddToggle(s2,"Instant Heal",false,function(v) IHTgl(v) end)
AddButton(s2,"Manual Heal Once",function() HealOnce() end)
AddButton(s2,"Gen Buff (Repair)",function() GenBuff() end)
AddButton(s2,"Auto Unhook",function() AutoUnhook() end)
AddKeybind(s2,"Fake Parry Keybind","None",function() FPPulse() end)
AddKeybind(s2,"Instant Heal Keybind","None",function() IHTgl(not IH.On) end)
AddKeybind(s2,"Manual Heal Keybind","None",function() HealOnce() end)
AddKeybind(s2,"Gen Buff Keybind","None",function() GenBuff() end)
AddKeybind(s2,"Auto Unhook Keybind","None",function() AutoUnhook() end)

-- TAB 2: VISUALS
local p2 = AddTab("Visuals")
local sv1 = AddSection(p2,"ESP & Overlays")
AddToggle(sv1,"Player Highlights",false,function(v) S.ESP.On = v; RefreshESP() end)
AddColor(sv1,"Survivor Color",S.ESP.Surv,function(c) S.ESP.Surv = c; RefreshESP() end)
AddColor(sv1,"Killer Color",S.ESP.Kill,function(c) S.ESP.Kill = c; RefreshESP() end)
AddToggle(sv1,"Fill Highlights",false,function(v) S.ESP.Fill = v; RefreshESP() end)
AddColor(sv1,"Fill Color",S.ESP.FillColor,function(c) S.ESP.FillColor = c; RefreshESP() end)
AddToggle(sv1,"CS2 Box & Skeleton ESP",false,function(v) CS2Tgl(v) end)
AddColor(sv1,"CS2 Color",S.ESP.CS2C,function(c) S.ESP.CS2C = c end)

local sv2 = AddSection(p2,"Object ESP")
AddToggle(sv2,"Generator ESP",false,function(v) S.ESP.Gen = v; RefreshObjESP() end)
AddColor(sv2,"Generator Color",S.ESP.GenC,function(c) S.ESP.GenC = c; RefreshObjESP() end)
AddToggle(sv2,"Pallet ESP",false,function(v) S.ESP.Pallet = v; RefreshObjESP() end)
AddColor(sv2,"Pallet Color",S.ESP.PalC,function(c) S.ESP.PalC = c; RefreshObjESP() end)

local sv3 = AddSection(p2,"Cosmetics & Visual Modifiers")
AddToggle(sv3,"Music (Spotify Python)",false,function(v) MusicTgl(v) end)
AddKeybind(sv3,"Music UI Toggle Key","M",function(k)
	if type(k)=="string" and k~="" and k~="None" then
		MUSIC.CloseKey = k
		_G.GoatLoseMusicCloseKey = k
	end
end)
AddColor(sv3,"Music Accent",MUSIC.Accent,function(c)
	MUSIC.Accent = c
	_G.GoatLoseMusicTheme = _G.GoatLoseMusicTheme or {}
	_G.GoatLoseMusicTheme.Accent = c
	pcall(function() if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end end)
end)
AddColor(sv3,"Music Player BG",MUSIC.Bg,function(c)
	MUSIC.Bg = c
	_G.GoatLoseMusicTheme = _G.GoatLoseMusicTheme or {}
	_G.GoatLoseMusicTheme.Bg = c
	pcall(function() if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end end)
end)
AddColor(sv3,"Music Text",MUSIC.Text,function(c)
	MUSIC.Text = c
	_G.GoatLoseMusicTheme = _G.GoatLoseMusicTheme or {}
	_G.GoatLoseMusicTheme.Text = c
	pcall(function() if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end end)
end)
AddColor(sv3,"Lyric Color L",MUSIC.LyricLeft,function(c)
	MUSIC.LyricLeft = c
	_G.GoatLoseMusicTheme = _G.GoatLoseMusicTheme or {}
	_G.GoatLoseMusicTheme.LyricLeft = c
end)
AddColor(sv3,"Lyric Color R",MUSIC.LyricRight,function(c)
	MUSIC.LyricRight = c
	_G.GoatLoseMusicTheme = _G.GoatLoseMusicTheme or {}
	_G.GoatLoseMusicTheme.LyricRight = c
end)
AddLabel(sv3,"M = panel | ESC = close | OFF = hide only")
AddLabel(sv3,"Folder: SpectralMusic | Bridge: 127.0.0.1:29481")
AddToggle(sv3,"China Hat",false,function(v) CHTgl(v) end)
AddColor(sv3,"Hat Color",S.China.Color,function(c) S.China.Color = c end)
AddToggle(sv3,"Tung Tung Sahur",false,function(v) TTSTgl(v) end)
AddToggle(sv3,"Download Xivivide.exe",false,function(v) XivivideTgl(v) end)
AddLabel(sv3,"Xivivide: only toggle OFF stops")
AddSlider(sv3,"TTS Scale",0.4,1.2,0.8,2,function(v) TTS.Scale = v end)
AddSlider(sv3,"TTS Right Offset",0,1,0.3,2,function(v) TTS.RightOffset = v end)
AddToggle(sv3,"Rainbow Highlight",false,function(v) RCTgl(v) end)
AddToggle(sv3,"Killer Light Color Fix",false,function(v) KLTgl(v) end)
AddColor(sv3,"Killer Light Color",S.KL.Color,function(c) S.KL.Color = c end)
AddToggle(sv3,"DBD Status Icons",false,function(v) DBDHTgl(v) end)

-- TAB 3: MOVEMENT
local sv4 = AddSection(p2,"Emote Wheel")
AddToggle(sv4,"Emote Wheel",false,function(v) EWTgl(v) end)
AddKeybind(sv4,"Emote Wheel Key","B",function() end)
task.defer(function()
	local ctrl = CFG_CONTROLS["Emote Wheel Key"]
	if ctrl then
		local oldSet = ctrl.set
		ctrl.set = function(k)
			oldSet(k)
			EWSetKey(k)
		end
		local g = ctrl.get and ctrl.get()
		if type(g) == "string" and g ~= "" and g ~= "None" then EWSetKey(g) end
	end
end)
AddLabel(sv4,"Hold key - pick sector / center STOP")

local p3 = AddTab("Movement")
local sm1 = AddSection(p3,"Movement Options")
AddToggle(sm1,"No Slowdown",false,function(v) NSTgl(v) end)
AddToggle(sm1,"Moonwalk Engine",false,function(v) MWTgl(v) end)
AddToggle(sm1,"Fly System",false,function(v) FLYTgl(v) end)
AddToggle(sm1,"Noclip",false,function(v) NCTgl(v) end)
AddToggle(sm1,"Speedboost",false,function(v) SBTgl(v) end)
AddSlider(sm1,"Speed Multiplier",1,5,1.8,2,function(v) SB.Mult = v; if SB.On then SBApply() end end)
AddToggle(sm1,"Desync Movement",false,function(v) DSTgl(v) end)
AddToggle(sm1,"Desync Ghost",true,function(v) DS.GhostOn = v; if not v then DSDestroyGhost() elseif DS.On and LP.Character then DSBuildGhost(LP.Character) end end)
AddToggle(sm1,"Ghost Always On Top",true,function(v) DS.GhostTop = v; DSUpdateGhostAppearance() end)
AddSlider(sm1,"Ghost Transparency",0.1,0.9,0.45,2,function(v) DS.GhostTrans = v; DSUpdateGhostAppearance() end)
AddColor(sm1,"Ghost Color",Color3.fromRGB(0,255,200),function(c) DS.GhostCol = c; DSUpdateGhostAppearance() end)
AddKeybind(sm1,"Desync Keybind","None",function() DSTgl(not DS.On) end)
AddKeybind(sm1,"Fly Keybind","None",function() FLYTgl(not FLY.On) end)
AddKeybind(sm1,"Noclip Keybind","None",function() NCTgl(not NC.On) end)
AddKeybind(sm1,"Speedboost Keybind","None",function() SBTgl(not SB.On) end)
AddKeybind(sm1,"Moonwalk Keybind","None",function() MWTgl(not MW.On) end)

-- TAB 4: WORLD / INTERACT
local p4 = AddTab("World")
local sw1 = AddSection(p4,"Pallets & Vaults")
AddButton(s4 or sw1,"Drop All Pallets",function() DropAllPallets() end)
AddToggle(sw1,"Pallet Vacuum (highlight near)",false,function(v) RDPTgl(v) end)
AddSlider(sw1,"Pallet Vacuum Range",4,25,12,0,function(v) RDP.Range = v end)
AddButton(sw1,"Drop Near Pallet",function() DropTargetPallet() end)
AddKeybind(sw1,"Pallet Vacuum Keybind","None",function() DropTargetPallet() end)
AddButton(sw1,"Block Windows & Pallets",function() BlockWP() end)
AddButton(sw1,"Unlock Windows & Pallets",function() UnlockWP() end)
AddKeybind(sw1,"Window Vault Teleport","None",function() BWPress() end)
AddSlider(sw1,"Vault Search Range",5,30,14,0,function(v) S.BW.Range = v end)

local sw2 = AddSection(p4,"Teleportation")
AddSlider(sw2,"Click TP Max Dist",10,500,80,0,function(v) S.CTP.Dist = v end)
AddToggle(sw2,"Click TP Through Walls",true,function(v) S.CTP.ThroughWalls = v end)
AddToggle(sw2,"Click TP Snap Floor",true,function(v) S.CTP.SnapGround = v end)
AddKeybind(sw2,"Click Teleport Key","None",function() ClickTPDo() end)
AddKeybind(sw2,"TP Random Survivor","None",function() TPRandomSurvivor() end)
AddButton(sw2,"TP Random Survivor",function() TPRandomSurvivor() end)


-- ===================== EMOTE WHEEL (hold B) =====================
EW = {On=false, Track=nil, Holding=false, Open=false, Selected=0, Conn=nil, Gui=nil, Render=nil, Conns={}, Key="B", PrevMouseBeh=nil, PrevMouseIcon=nil}
EW_EMOTES = {
	{name="Laugh", id="138303785534052"},
	{name="Flip", id="74705617908505"},
	{name="Mannrobics", id="134677515695156"},
	{name="Rambunctious", id="81054496834622"},
}

local function EWParent()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then return cg end
	return LP:WaitForChild("PlayerGui")
end

local function EWStop()
	if EW.Track then
		local tr = EW.Track
		EW.Track = nil
		pcall(function() tr:Stop(0.1); tr:Destroy() end)
	end
end

local function EWPlay(emote)
	EWStop()
	local ok, track = pcall(function()
		local hum = GetHum(LP.Character)
		if not hum then return nil end
		local an = hum:FindFirstChildOfClass("Animator")
		if not an then an = Instance.new("Animator"); an.Parent = hum end
		local a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://" .. emote.id
		local tr = an:LoadAnimation(a)
		pcall(function() a:Destroy() end)
		tr.Priority = Enum.AnimationPriority.Action
		tr.Looped = false
		tr:Play(0.1)
		return tr
	end)
	if ok and track then
		EW.Track = track
		pcall(function()
			track.Stopped:Connect(function()
				if EW.Track == track then EW.Track = nil end
				pcall(function() track:Destroy() end)
			end)
		end)
	end
end

local function EWDestroyGui()
	if EW.Render then EW.Render:Disconnect(); EW.Render = nil end
	if EW.Gui then pcall(function() EW.Gui:Destroy() end); EW.Gui = nil end
	EW.Open = false
	EMOTE_WHEEL_OPEN = false
end

local function EWBuildGui()
	EWDestroyGui()
	local parent = EWParent()
	local gui = Instance.new("ScreenGui")
	gui.Name = "GoatLoseEmoteWheel"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 999
	gui.Parent = parent
	EW.Gui = gui

	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.AnchorPoint = Vector2.new(0.5, 0)
	header.Position = UDim2.new(0.5, 0, 0.5, -210)
	header.Size = UDim2.fromOffset(400, 45)
	header.BackgroundTransparency = 1
	header.TextColor3 = Color3.new(1,1,1)
	header.TextSize = 26
	header.Font = Enum.Font.GothamBold
	header.Text = "Stop Emote"
	header.Visible = false
	header.Parent = gui
	local hs = Instance.new("UIStroke"); hs.Color = Color3.new(0,0,0); hs.Thickness = 2; hs.Parent = header

	local wheel = Instance.new("Frame")
	wheel.Name = "Wheel"
	wheel.AnchorPoint = Vector2.new(0.5, 0.5)
	wheel.Position = UDim2.fromScale(0.5, 0.5)
	wheel.Size = UDim2.fromOffset(360, 360)
	wheel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	wheel.BackgroundTransparency = 0.1
	wheel.Visible = false
	wheel.Parent = gui
	Instance.new("UICorner", wheel).CornerRadius = UDim.new(1, 0)
	local ws = Instance.new("UIStroke"); ws.Color = Color3.fromRGB(0, 255, 200); ws.Thickness = 3; ws.Parent = wheel

	local stopBtn = Instance.new("TextButton")
	stopBtn.Name = "Stop"
	stopBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	stopBtn.Position = UDim2.fromScale(0.5, 0.5)
	stopBtn.Size = UDim2.fromOffset(90, 90)
	stopBtn.BackgroundColor3 = Color3.fromRGB(180, 48, 62)
	stopBtn.TextColor3 = Color3.new(1,1,1)
	stopBtn.Text = "STOP"
	stopBtn.TextSize = 15
	stopBtn.Font = Enum.Font.GothamBold
	stopBtn.AutoButtonColor = true
	stopBtn.Parent = wheel
	Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(1, 0)
	local ss = Instance.new("UIStroke"); ss.Color = Color3.fromRGB(255,255,255); ss.Thickness = 2; ss.Parent = stopBtn

	local radius = 115
	local buttons = {}
	local total = #EW_EMOTES
	for i, emote in ipairs(EW_EMOTES) do
		local angle = math.rad(-90 + (i - 1) * (360 / total))
		local x = 0.5 + math.cos(angle) * radius / 360
		local y = 0.5 + math.sin(angle) * radius / 360
		local btn = Instance.new("TextButton")
		btn.Name = "Emote_" .. i
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Position = UDim2.fromScale(x, y)
		btn.Size = UDim2.fromOffset(76, 76)
		btn.BackgroundColor3 = Color3.fromRGB(26, 38, 62)
		btn.BackgroundTransparency = 0.25
		btn.Text = emote.name
		btn.TextColor3 = Color3.fromRGB(240, 245, 255)
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamBold
		btn.AutoButtonColor = false
		btn.Parent = wheel
		Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
		local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(0, 255, 200); st.Thickness = 1.5; st.Parent = btn
		buttons[i] = btn
	end

	EW._header = header
	EW._wheel = wheel
	EW._stop = stopBtn
	EW._stopStroke = ss
	EW._buttons = buttons
end

local function EWSetOpen(open)
	if not EW.Gui then EWBuildGui() end
	if EW.Open == open then return end
	EW.Open = open
	EMOTE_WHEEL_OPEN = open
	EW._wheel.Visible = open
	EW._header.Visible = open
	if open then
		-- unlock cursor while wheel is open
		EW.PrevMouseBeh = UIS.MouseBehavior
		EW.PrevMouseIcon = UIS.MouseIconEnabled
		pcall(function()
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			UIS.MouseIconEnabled = true
		end)
		EW.Selected = 0
		EW._header.Text = "Stop Emote"
		EW._stop.BackgroundColor3 = Color3.fromRGB(180, 48, 62)
		EW._stopStroke.Color = Color3.fromRGB(255,255,255)
		for _,b in ipairs(EW._buttons) do
			b.BackgroundColor3 = Color3.fromRGB(26, 38, 62)
		end
		if EW.Render then EW.Render:Disconnect() end
		EW.Render = RunService.RenderStepped:Connect(function()
			-- keep unlocked while open
			pcall(function()
				if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
					UIS.MouseBehavior = Enum.MouseBehavior.Default
				end
				if not UIS.MouseIconEnabled then
					UIS.MouseIconEnabled = true
				end
			end)

			local mousePos = UIS:GetMouseLocation()
			local absPos = EW._wheel.AbsolutePosition
			local absSize = EW._wheel.AbsoluteSize
			local cx = absPos.X + absSize.X / 2
			local cy = absPos.Y + absSize.Y / 2
			local dx = mousePos.X - cx
			local dy = mousePos.Y - cy
			local dist = math.sqrt(dx*dx + dy*dy)
			-- STOP deadzone 65px so center button always wins
			if dist < 65 then
				EW.Selected = 0
				EW._header.Text = "Stop Emote"
				EW._stop.BackgroundColor3 = Color3.fromRGB(180, 48, 62)
				EW._stopStroke.Color = Color3.fromRGB(255,255,255)
				for _,b in ipairs(EW._buttons) do
					b.BackgroundColor3 = Color3.fromRGB(26, 38, 62)
				end
				return
			end
			EW._stop.BackgroundColor3 = Color3.fromRGB(40, 44, 60)
			EW._stopStroke.Color = Color3.fromRGB(180, 48, 62)
			local angle = math.deg(math.atan2(dy, dx)) + 90
			if angle < 0 then angle = angle + 360 end
			local sector = 360 / #EW_EMOTES
			local index = math.floor((angle + sector/2) / sector) % #EW_EMOTES + 1
			EW.Selected = index
			EW._header.Text = EW_EMOTES[index].name
			for i,b in ipairs(EW._buttons) do
				if i == index then
					b.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
					b.TextColor3 = Color3.fromRGB(10, 12, 16)
				else
					b.BackgroundColor3 = Color3.fromRGB(26, 38, 62)
					b.TextColor3 = Color3.fromRGB(240, 245, 255)
				end
			end
		end)
	else
		if EW.Render then EW.Render:Disconnect(); EW.Render = nil end
		-- lock cursor back when wheel closed
		pcall(function()
			if EW.PrevMouseBeh ~= nil then
				UIS.MouseBehavior = EW.PrevMouseBeh
			else
				UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			end
			if EW.PrevMouseIcon ~= nil then
				UIS.MouseIconEnabled = EW.PrevMouseIcon
			else
				UIS.MouseIconEnabled = false
			end
		end)
	end
end

function EWTgl(on)
	EW.On = on
	S.On.emotewheel = on
	for _,c in ipairs(EW.Conns) do pcall(function() c:Disconnect() end) end
	EW.Conns = {}
	if EW.Conn then EW.Conn:Disconnect(); EW.Conn = nil end
	pcall(function()
		game:GetService("ContextActionService"):UnbindAction("GoatLoseEmoteWheel")
	end)
	if not on then
		EWSetOpen(false)
		EWDestroyGui()
		EWStop()
		return
	end
	EWBuildGui()
	local function EWKeyCode()
		local name = tostring(EW.Key or "B")
		local ok, code = pcall(function() return Enum.KeyCode[name] end)
		if ok and code then return code end
		return Enum.KeyCode.B
	end
	local CAS = game:GetService("ContextActionService")
	local function rebind()
		pcall(function() CAS:UnbindAction("GoatLoseEmoteWheel") end)
		local kc = EWKeyCode()
		CAS:BindActionAtPriority(
			"GoatLoseEmoteWheel",
			function(_, state, input)
				if not EW.On then return Enum.ContextActionResult.Pass end
				if input.KeyCode ~= EWKeyCode() then return Enum.ContextActionResult.Pass end
				if state == Enum.UserInputState.Begin then
					EW.Holding = true
					EWSetOpen(true)
					return Enum.ContextActionResult.Sink
				elseif state == Enum.UserInputState.End then
					if EW.Holding then
						EW.Holding = false
						if EW.Open then
							if EW.Selected == 0 then
								EWStop()
							elseif EW_EMOTES[EW.Selected] then
								EWPlay(EW_EMOTES[EW.Selected])
							end
						end
						EWSetOpen(false)
					end
					return Enum.ContextActionResult.Sink
				end
				return Enum.ContextActionResult.Pass
			end,
			false,
			Enum.ContextActionPriority.High.Value + 10000,
			kc
		)
	end
	EW.Rebind = rebind
	rebind()
	table.insert(EW.Conns, LP.CharacterAdded:Connect(function() EWStop() end))
	table.insert(EW.Conns, UIS.WindowFocusReleased:Connect(function()
		EW.Holding = false
		EWSetOpen(false)
	end))
end

function EWSetKey(keyName)
	if type(keyName) ~= "string" or keyName == "" or keyName == "None" then return end
	EW.Key = keyName
	if EW.On and EW.Rebind then
		pcall(EW.Rebind)
	end
end



-- TAB 5: GRAPHICS
local p5 = AddTab("Graphics")
local sg1 = AddSection(p5,"Shaders & Environment")
AddToggle(sg1,"Hide Default Nametags",false,function(v) HideNamesTgl(v) end)
AddToggle(sg1,"Vivid Preset Engine",true,function(v) S.VS.Vivid = v; ApplyVisuals() end)
AddToggle(sg1,"RTX Visual Enhancements",false,function(v) S.VS.RTX = v; ApplyVisuals() end)
AddToggle(sg1,"Remove World Fog",true,function(v) S.VS.NoFog = v; ApplyVisuals() end)
AddToggle(sg1,"Depth Of Field",false,function(v) S.VS.DOF = v; ApplyVisuals() end)
AddSlider(sg1,"Camera Field Of View",40,120,70,0,function(v)
	S.VS.FOV = v
	S.VS.FOVOn = true
	pcall(function()
		local cam = Workspace.CurrentCamera
		if cam then cam.FieldOfView = v end
	end)
	ApplyVisuals()
end)
AddToggle(sg1,"Custom FOV Enabled",true,function(v)
	S.VS.FOVOn = v
	if v then
		pcall(function()
			local cam = Workspace.CurrentCamera
			if cam then cam.FieldOfView = S.VS.FOV or 70 end
		end)
	else
		pcall(function()
			local cam = Workspace.CurrentCamera
			if cam then cam.FieldOfView = 70 end
		end)
	end
end)
AddDropdown(sg1,"Lighting Presets",{"Default","Day","Sunset","Sunrise","Night"},"Default",function(v) S.VS.Time = v; ApplyVisuals() end)
AddDropdown(sg1,"Atmosphere Cycle",ATMO_NAMES,"Normal",function(v) ApplyAtmo(v) end)

local sg2 = AddSection(p5,"Custom Crosshair")
AddToggle(sg2,"Show Crosshair",false,function(v) S.VS.Crosshair = v; ApplyVisuals() end)
AddDropdown(sg2,"Crosshair Style",{"Classic","Tactical","Dot","Circle","DotCircle"},"Classic",function(v) S.VS.CrossStyle = v; ApplyVisuals() end)
AddColor(sg2,"Crosshair Color",S.VS.CrossColor,function(c) S.VS.CrossColor = c; ApplyVisuals() end)
AddSlider(sg2,"Crosshair Scale",4,30,10,0,function(v) S.VS.CrossSize = v; ApplyVisuals() end)

-- TAB 6: CONFIG
local p6 = AddTab("Config")
local sc1 = AddSection(p6,"Config Hub")
AddLabel(sc1,"Browse built-in & local presets. Load From Dev below.")

local CfgStatus = AddLabel(sc1,"Selected: None")
local CfgMsg = AddLabel(sc1,"Ready")
AddKeybind(sc1,"Menu Toggle Key","RightShift",function() end)
task.defer(function()
	local ctrl = CFG_CONTROLS["Menu Toggle Key"]
	if ctrl then
		local oldSet = ctrl.set
		ctrl.set = function(k)
			oldSet(k)
			if type(k)=="string" and k~="" and k~="None" then MENU_KEY = k end
		end
		local g = ctrl.get and ctrl.get()
		if type(g)=="string" and g~="" and g~="None" then MENU_KEY = g end
	end
end)

local function cfgSerialize(v)
	if typeof(v) == "Color3" then
		return {math.floor(v.R*255+0.5), math.floor(v.G*255+0.5), math.floor(v.B*255+0.5)}
	end
	return v
end

local function cfgNotify(msg)
	if CfgMsg and CfgMsg.Set then CfgMsg.Set(tostring(msg)) end
end

local function refreshCfgUI()
	local names,set = getConfigNames()
	if CFG_SELECTED ~= "" and set[CFG_SELECTED] then
		CfgStatus.Set("Selected: "..CFG_SELECTED.."  |  configs: "..tostring(#names))
	elseif #names > 0 then
		CFG_SELECTED = names[1]
		CfgStatus.Set("Selected: "..CFG_SELECTED.."  |  configs: "..tostring(#names))
	else
		CFG_SELECTED = ""
		CfgStatus.Set("Selected: None  |  configs: 0")
	end
end

local function cfgCollect()
	local data = {}
	for key,ctrl in pairs(CFG_CONTROLS) do
		if ctrl and type(ctrl.get) == "function" then
			local ok,val = pcall(ctrl.get)
			if ok then data[key] = cfgSerialize(val) end
		end
	end
	-- Name / Outfit (not bound to standard controls)
	data["GL_NameChangerOn"] = NAMECH and NAMECH.On == true
	data["GL_NameChangerText"] = (NAMECH and NAMECH.Text) or "Anonymous"
	data["GL_OutfitUser"] = (OUTFIT and OUTFIT.User) or ""
	return data
end

local function cfgApply(data)
	if type(data) ~= "table" then return 0 end
	local n = 0
	for key,val in pairs(data) do
		if key:sub(1,3) == "GL_" then
			-- handled below
		else
			local ctrl = CFG_CONTROLS[key]
			if ctrl and type(ctrl.set) == "function" then
				local ok = pcall(ctrl.set, val)
				if ok then n = n + 1 end
			end
		end
	end
	-- menu key
	local mk = data["Menu Toggle Key"]
	if type(mk) == "string" and mk ~= "" and mk ~= "None" then MENU_KEY = mk end

	-- Music theme from config (RGB arrays)
	local function cfgCol(v, fallback)
		if type(v) == "table" and v[1] then
			return Color3.fromRGB(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)
		end
		return fallback
	end
	if data["Music Accent"] then MUSIC.Accent = cfgCol(data["Music Accent"], MUSIC.Accent) end
	if data["Music Player BG"] then MUSIC.Bg = cfgCol(data["Music Player BG"], MUSIC.Bg) end
	if data["Music Text"] then MUSIC.Text = cfgCol(data["Music Text"], MUSIC.Text) end
	if data["Lyric Color L"] then MUSIC.LyricLeft = cfgCol(data["Lyric Color L"], MUSIC.LyricLeft) end
	if data["Lyric Color R"] then MUSIC.LyricRight = cfgCol(data["Lyric Color R"], MUSIC.LyricRight) end
	local muk = data["Music UI Toggle Key"]
	if type(muk) == "string" and muk ~= "" and muk ~= "None" then
		MUSIC.CloseKey = muk
		_G.GoatLoseMusicCloseKey = muk
	end
	_G.GoatLoseMusicTheme = {
		Accent = MUSIC.Accent,
		AccentAlt = MUSIC.AccentAlt or MUSIC.Accent,
		Bg = MUSIC.Bg,
		Text = MUSIC.Text,
		LyricLeft = MUSIC.LyricLeft,
		LyricRight = MUSIC.LyricRight,
	}
	pcall(function()
		if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end
	end)
	if data["Music (Spotify Python)"] == true then
		task.spawn(function()
			task.wait(0.5)
			pcall(MusicTgl, true)
			task.wait(0.3)
			pcall(function() if _G.GoatLoseMusicApplyTheme then _G.GoatLoseMusicApplyTheme() end end)
		end)
	end

	-- Name changer
	local nameText = data["GL_NameChangerText"]
	if type(nameText) == "string" and nameText ~= "" then
		pcall(function() NameChangerSet(nameText) end)
		n = n + 1
	end
	if data["GL_NameChangerOn"] == true then
		pcall(function() NameChangerTgl(true) end)
		n = n + 1
	elseif data["GL_NameChangerOn"] == false then
		pcall(function() NameChangerTgl(false) end)
	end

	-- Outfit by saved username (async so load doesn't freeze)
	local outfitUser = data["GL_OutfitUser"]
	if type(outfitUser) == "string" and outfitUser ~= "" then
		n = n + 1
		OUTFIT.User = outfitUser
		task.spawn(function()
			task.wait(1.0)
			if IsLocalKiller() then
				if OUTFIT.StatusLabel then
					pcall(function() OUTFIT.StatusLabel.Set("Outfit saved, wait Survivor to apply") end)
				end
				return
			end
			local ok, err = OutfitApplyFromUser(outfitUser)
			if OUTFIT and OUTFIT.StatusLabel then
				pcall(function()
					if ok then
						OUTFIT.StatusLabel.Set("Outfit loaded: "..outfitUser)
					else
						OUTFIT.StatusLabel.Set("Outfit load fail: "..tostring(err))
					end
				end)
			end
		end)
	end
	return n
end

AddButton(sc1,"Select Next Config",function()
	local names = getConfigNames()
	if #names == 0 then
		cfgNotify("No configs yet - Create or Save first")
		return
	end
	local idx = 0
	for i,n in ipairs(names) do if n == CFG_SELECTED then idx = i break end end
	idx = idx + 1
	if idx > #names then idx = 1 end
	CFG_SELECTED = names[idx]
	refreshCfgUI()
	cfgNotify("Selected: "..CFG_SELECTED)
end)

AddButton(sc1,"Create New Config",function()
	ensureCfgFolder()
	CFG_SELECTED = safeCfgName(nextAutoCfgName())
	addCfgIndex(CFG_SELECTED)
	-- save empty/current snapshot so file exists
	local data = cfgCollect()
	local ok,err = pcall(function()
		if not writefile then error("writefile missing") end
		writefile(cfgPath(CFG_SELECTED), HttpService:JSONEncode(data))
	end)
	refreshCfgUI()
	if ok then cfgNotify("Created: "..CFG_SELECTED) else cfgNotify("Create failed: "..tostring(err)) end
end)

AddButton(sc1,"Save Config",function()
	ensureCfgFolder()
	if CFG_SELECTED == "" then CFG_SELECTED = safeCfgName(nextAutoCfgName()) end
	local data = cfgCollect()
	local count = 0
	for _ in pairs(data) do count = count + 1 end
	local ok,err = pcall(function()
		if not writefile then error("writefile not available on this executor") end
		writefile(cfgPath(CFG_SELECTED), HttpService:JSONEncode(data))
		addCfgIndex(CFG_SELECTED)
	end)
	refreshCfgUI()
	if ok then
		cfgNotify("Saved "..CFG_SELECTED.." ("..tostring(count).." values)")
	else
		cfgNotify("Save failed: "..tostring(err))
	end
end)

AddButton(sc1,"Load Config",function()
	local names = getConfigNames()
	if CFG_SELECTED == "" then
		if #names > 0 then CFG_SELECTED = names[1] else
			cfgNotify("Nothing to load")
			return
		end
	end
	-- Built-in Config Hub presets
	if BUILTIN_CONFIGS and BUILTIN_CONFIGS[CFG_SELECTED] then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(BUILTIN_CONFIGS[CFG_SELECTED])
		end)
		if ok and type(data) == "table" then
			local n = cfgApply(data)
			cfgNotify("Loaded built-in: "..CFG_SELECTED.." ("..tostring(n).." applied)")
		else
			cfgNotify("Built-in decode failed")
		end
		refreshCfgUI()
		return
	end
	local path = cfgPath(CFG_SELECTED)
	if not readfile then
		cfgNotify("readfile not available on this executor")
		return
	end
	local exists = false
	pcall(function() if isfile and isfile(path) then exists = true end end)
	if not exists then
		local okBody, body = pcall(function() return readfile(path) end)
		if not okBody or type(body) ~= "string" or #body == 0 then
			cfgNotify("File missing: "..path)
			return
		end
		local ok,data = pcall(function() return HttpService:JSONDecode(body) end)
		if ok and type(data)=="table" then
			local n = cfgApply(data)
			cfgNotify("Loaded "..CFG_SELECTED.." ("..tostring(n).." applied)")
		else
			cfgNotify("Bad JSON in "..CFG_SELECTED)
		end
		refreshCfgUI()
		return
	end
	local ok,data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
	if ok and type(data)=="table" then
		local n = cfgApply(data)
		cfgNotify("Loaded "..CFG_SELECTED.." ("..tostring(n).." applied)")
	else
		cfgNotify("Load failed / bad JSON")
	end
	refreshCfgUI()
end)

AddButton(sc1,"Delete Config",function()
	if CFG_SELECTED == "" then cfgNotify("Nothing selected"); return end
	if BUILTIN_CONFIGS and BUILTIN_CONFIGS[CFG_SELECTED] then
		cfgNotify("Cannot delete built-in preset")
		return
	end
	local path = cfgPath(CFG_SELECTED)
	local name = CFG_SELECTED
	pcall(function() if delfile and isfile and isfile(path) then delfile(path) end end)
	pcall(function() if delfile then delfile(path) end end)
	removeCfgIndex(name)
	CFG_SELECTED = ""
	refreshCfgUI()
	cfgNotify("Deleted: "..name)
end)

refreshCfgUI()
cfgNotify("Config ready - Save then Load")


local scHub = AddSection(p6,"Community / From Dev")
AddLabel(scHub,"From Dev - Legit  |  Author: GoatLose  |  FREE / SURVIVOR")
AddButton(scHub,"LOAD  From Dev - Legit",function()
	CFG_SELECTED = "From Dev - Legit"
	local raw = BUILTIN_CONFIGS and BUILTIN_CONFIGS["From Dev - Legit"]
	if not raw then cfgNotify("Built-in missing"); return end
	local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok and type(data)=="table" then
		local n = cfgApply(data)
		cfgNotify("Loaded From Dev - Legit ("..tostring(n).." applied)")
		refreshCfgUI()
	else
		cfgNotify("Decode failed")
	end
end)
AddLabel(scHub,"От разраба - Legit  |  Author: GoatLose  |  FREE / SURVIVOR")
AddButton(scHub,"LOAD  От разраба - Legit",function()
	CFG_SELECTED = "От разраба - Legit"
	local raw = BUILTIN_CONFIGS and BUILTIN_CONFIGS["От разраба - Legit"]
	if not raw then cfgNotify("Built-in missing"); return end
	local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
	if ok and type(data)=="table" then
		local n = cfgApply(data)
		cfgNotify("Loaded От разраба - Legit ("..tostring(n).." applied)")
		refreshCfgUI()
	else
		cfgNotify("Decode failed")
	end
end)

-- TAB 7: EXTRA
local p7 = AddTab("Extra")
local se1 = AddSection(p7,"Fun & Trolling Features")
AddToggle(se1,"Drochka Animation Loop",false,function(v) DRTgl(v) end)
AddSlider(se1,"Animation Speed Multiplier",0.5,10,2.5,1,function(v) S.Droch.Speed = v; if DR.Track then DR.Track:AdjustSpeed(v) end end)
AddToggle(se1,"God Mode Client Override",false,function(v) GMTgl(v) end)

local se2 = AddSection(p7,"Veil Aimbot")
AddToggle(se2,"Veil Spear Aimbot",false,function(v) VeilAimTgl(v) end)
AddDropdown(se2,"Aimbot Hold Key",{"MouseButton2","MouseButton1","E","Q","LeftShift"},"MouseButton2",function(v) VEIL.Key = v end)
AddSlider(se2,"Aimbot FOV",50,400,150,0,function(v) VEIL.FOV = v end)
AddSlider(se2,"Aim Smoothness",0,0.3,0.05,2,function(v) VEIL.Smooth = v end)
AddSlider(se2,"Spear Speed",80,250,150,0,function(v) VEIL.Speed = v end)
AddSlider(se2,"Spear Gravity",0,200,98,0,function(v) VEIL.Gravity = v end)
AddSlider(se2,"Prediction Offset",0,0.2,0.05,2,function(v) VEIL.Pred = v end)
AddDropdown(se2,"Target Part",{"Head","UpperTorso","HumanoidRootPart"},"UpperTorso",function(v) VEIL.Part = v end)
AddDropdown(se2,"Priority",{"Nearest","Furthest","Injured","Healed","NearestInjured","NearestHealed"},"Nearest",function(v) VEIL.Priority = v end)
AddToggle(se2,"Silent Spear Fire",true,function(v) VEIL.Silent = v end)
AddKeybind(se2,"Veil Aimbot Keybind","None",function() VeilAimTgl(not VEIL.AimOn) end)

local se3 = AddSection(p7,"No Attack Cooldown")
AddToggle(se3,"No Attack Cooldown",false,function(v) NACDTgl(v) end)
AddSlider(se3,"Attack Delay (sec)",0.02,0.5,0.05,2,function(v) NACD.Rate = v end)
AddKeybind(se3,"No Attack CD Keybind","None",function() NACDTgl(not NACD.On) end)
AddLabel(se3,"Remote: Remotes.Attacks.BasicAttack")
AddLabel(se3,"Hold LMB while ON — delay = time between fires")

local se4 = AddSection(p7,"Masked Powers")
AddButton(se4,"Richter - Stealth",function() MaskedApply("Richter") end)
AddButton(se4,"Alex - Chainsaw",function() MaskedApply("Alex") end)
AddButton(se4,"Brandon - Walk Faster",function() MaskedApply("Brandon") end)
AddButton(se4,"Rabbit - Fast Vaults",function() MaskedApply("Rabbit") end)
AddButton(se4,"Cobra - Extended Lunges",function() MaskedApply("Cobra") end)
AddButton(se4,"Tony - Lethal Punches",function() MaskedApply("Tony") end)
AddButton(se4,"Normal - No Buffs",function() MaskedApply(nil) end)


-- ===================== FPV DRONE (KILLER) — exact user script =====================
FPV = {On=false, Running=false, Stop=nil}

function FPVStart()
	if FPV.Running then return end
	if not IsLocalKiller() then return end
	FPV.Running = true

	local ok, err = pcall(function()
		local Players = game:GetService("Players")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local RunService = game:GetService("RunService")
		local UserInputService = game:GetService("UserInputService")
		local SoundService = game:GetService("SoundService")
		local Debris = game:GetService("Debris")
		local LocalPlayer = Players.LocalPlayer
		local Camera = workspace.CurrentCamera
		local DRONE_ASSET_ID = "rbxassetid://74015974812929"
		local SOUND_ASSET_ID = "rbxassetid://114037851906101"
		local EXPLOSION_SOUND_ID = "rbxassetid://142070127"
		local FLIGHT_SPEED = 85
		local HIT_RADIUS = 7
		local EXPLOSION_RADIUS = 18
		local CAMERA_DISTANCE = 14
		local ATTACK_COOLDOWN = 0.3
		local ROTATION_OFFSET = CFrame.Angles(0, math.rad(270), 0)
		local BasicAttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attacks"):WaitForChild("BasicAttack")
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local rootPart = character:WaitForChild("HumanoidRootPart")
		local originCFrame = rootPart.CFrame
		local oldMinZoom = LocalPlayer.CameraMinZoomDistance
		local oldMaxZoom = LocalPlayer.CameraMaxZoomDistance
		local oldMouseBehavior = UserInputService.MouseBehavior
		local oldMouseIconEnabled = UserInputService.MouseIconEnabled
		LocalPlayer.CameraMaxZoomDistance = math.max(oldMaxZoom, CAMERA_DISTANCE)
		LocalPlayer.CameraMinZoomDistance = CAMERA_DISTANCE
		local activeTarget = nil
		local isFlying = true
		local isTerminating = false
		local startTime = os.clock()
		local lastAttackTime = 0
		local mutedSounds = {}
		local soundAddedConn = nil
		local function muteGameAudio(exceptionSound)
			local function processInstance(inst)
				if inst:IsA("Sound") and inst ~= exceptionSound then
					if mutedSounds[inst] == nil then
						mutedSounds[inst] = inst.Volume
						inst.Volume = 0
					end
				end
			end
			for _, desc in ipairs(workspace:GetDescendants()) do processInstance(desc) end
			for _, desc in ipairs(SoundService:GetDescendants()) do processInstance(desc) end
			soundAddedConn = game.DescendantAdded:Connect(function(desc)
				if isTerminating then processInstance(desc) end
			end)
		end
		local function restoreGameAudio()
			if soundAddedConn then soundAddedConn:Disconnect(); soundAddedConn = nil end
			for snd, origVol in pairs(mutedSounds) do
				if snd and snd.Parent then snd.Volume = origVol end
			end
			table.clear(mutedSounds)
		end
		local function createFPVGui()
			local gui = Instance.new("ScreenGui")
			gui.Name = "FPV_OSD_Gui"
			gui.IgnoreGuiInset = true
			gui.ResetOnSpawn = false
			local success = pcall(function()
				gui.Parent = game:GetService("CoreGui")
			end)
			if not success then
				gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
			end
			local osdFrame = Instance.new("Frame")
			osdFrame.Size = UDim2.fromScale(1, 1)
			osdFrame.BackgroundTransparency = 1
			osdFrame.Parent = gui
			local crosshair = Instance.new("TextLabel")
			crosshair.Size = UDim2.fromOffset(220, 36)
			crosshair.Position = UDim2.fromScale(0.5, 0.5)
			crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
			crosshair.BackgroundTransparency = 1
			crosshair.Text = "- - [  +  ] - -"
			crosshair.TextColor3 = Color3.fromRGB(235, 255, 235)
			crosshair.Font = Enum.Font.RobotoMono
			crosshair.TextSize = 18
			crosshair.Parent = osdFrame
			local chStroke = Instance.new("UIStroke")
			chStroke.Color = Color3.fromRGB(0, 0, 0)
			chStroke.Thickness = 1.6
			chStroke.Transparency = 0.1
			chStroke.Parent = crosshair
			local function makeOSDText(pos, anchor, alignY, alignX)
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.fromOffset(300, 85)
				lbl.Position = pos
				lbl.AnchorPoint = anchor
				lbl.BackgroundTransparency = 1
				lbl.TextColor3 = Color3.fromRGB(245, 245, 245)
				lbl.Font = Enum.Font.RobotoMono
				lbl.TextSize = 15
				lbl.TextXAlignment = alignX
				lbl.TextYAlignment = alignY
				lbl.Parent = osdFrame
				local stroke = Instance.new("UIStroke")
				stroke.Color = Color3.fromRGB(0, 0, 0)
				stroke.Thickness = 1.5
				stroke.Transparency = 0.05
				stroke.Parent = lbl
				return lbl
			end
			local topLeft = makeOSDText(UDim2.fromScale(0.035, 0.045), Vector2.new(0, 0), Enum.TextYAlignment.Top, Enum.TextXAlignment.Left)
			local topRight = makeOSDText(UDim2.fromScale(0.965, 0.045), Vector2.new(1, 0), Enum.TextYAlignment.Top, Enum.TextXAlignment.Right)
			local bottomLeft = makeOSDText(UDim2.fromScale(0.035, 0.945), Vector2.new(0, 1), Enum.TextYAlignment.Bottom, Enum.TextXAlignment.Left)
			local bottomRight = makeOSDText(UDim2.fromScale(0.965, 0.945), Vector2.new(1, 1), Enum.TextYAlignment.Bottom, Enum.TextXAlignment.Right)
			local scanlines = {}
			for i = 1, 10 do
				local bar = Instance.new("Frame")
				bar.Size = UDim2.new(1, 0, 0, math.random(2, 8))
				bar.Position = UDim2.fromScale(0, math.random())
				bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				bar.BackgroundTransparency = 0.9
				bar.BorderSizePixel = 0
				bar.Parent = osdFrame
				table.insert(scanlines, bar)
			end
			local noSignalFrame = Instance.new("Frame")
			noSignalFrame.Size = UDim2.fromScale(1, 1)
			noSignalFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			noSignalFrame.BackgroundTransparency = 0.03
			noSignalFrame.Visible = false
			noSignalFrame.Parent = gui
			local staticBars = {}
			for i = 1, 45 do
				local sBar = Instance.new("Frame")
				sBar.Size = UDim2.new(1, 0, 0, math.random(4, 30))
				sBar.Position = UDim2.fromScale(0, i / 45)
				sBar.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
				sBar.BackgroundTransparency = 0.4
				sBar.BorderSizePixel = 0
				sBar.Parent = noSignalFrame
				table.insert(staticBars, sBar)
			end
			local noSignalLabel = Instance.new("TextLabel")
			noSignalLabel.Size = UDim2.fromOffset(420, 80)
			noSignalLabel.Position = UDim2.fromScale(0.5, 0.5)
			noSignalLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			noSignalLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			noSignalLabel.BackgroundTransparency = 0.15
			noSignalLabel.BorderSizePixel = 2
			noSignalLabel.BorderColor3 = Color3.fromRGB(255, 255, 255)
			noSignalLabel.Text = "NO SIGNAL"
			noSignalLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
			noSignalLabel.Font = Enum.Font.RobotoMono
			noSignalLabel.TextSize = 46
			noSignalLabel.Parent = noSignalFrame
			return {
				gui = gui, osdFrame = osdFrame,
				topLeft = topLeft, topRight = topRight, bottomLeft = bottomLeft, bottomRight = bottomRight,
				scanlines = scanlines, noSignalFrame = noSignalFrame, staticBars = staticBars, noSignalLabel = noSignalLabel
			}
		end
		local osd = createFPVGui()
		local function loadDroneModel()
			local success, result = pcall(function()
				return game:GetObjects(DRONE_ASSET_ID)[1]
			end)
			local dronePart
			if success and result then
				if result:IsA("Model") then
					result.Parent = workspace
					dronePart = result.PrimaryPart or result:FindFirstChildWhichIsA("BasePart")
					for _, desc in ipairs(result:GetDescendants()) do
						if desc:IsA("BasePart") then
							desc.CanCollide = false
							desc.Anchored = true
						end
					end
				elseif result:IsA("BasePart") then
					result.Parent = workspace
					result.CanCollide = false
					result.Anchored = true
					dronePart = result
				end
			end
			if not dronePart then
				dronePart = Instance.new("Part")
				dronePart.Size = Vector3.new(2, 1, 2)
				dronePart.Anchored = true
				dronePart.CanCollide = false
				dronePart.Parent = workspace
			end
			dronePart.CFrame = originCFrame * CFrame.new(0, 5, 0) * ROTATION_OFFSET
			local sound = Instance.new("Sound")
			sound.SoundId = SOUND_ASSET_ID
			sound.Looped = true
			sound.Volume = 1.5
			sound.Parent = dronePart
			sound:Play()
			return dronePart, result or dronePart, sound
		end
		local droneCore, droneContainer, droneSound = loadDroneModel()
		Camera = workspace.CurrentCamera
		Camera.CameraSubject = droneCore
		Camera.CameraType = Enum.CameraType.Custom
		local function getClosestPlayerToDrone(radius)
			local checkRadius = radius or HIT_RADIUS
			local closestRoot = nil
			local shortestDist = checkRadius
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
					local humanoid = player.Character:FindFirstChild("Humanoid")
					if targetRoot and humanoid and humanoid.Health > 0 then
						local dist = (droneCore.Position - targetRoot.Position).Magnitude
						if dist <= shortestDist then
							shortestDist = dist
							closestRoot = targetRoot
						end
					end
				end
			end
			return closestRoot
		end
		local renderConnection
		local inputConnection
		local function fullCleanup()
			isFlying = false
			isTerminating = false
			activeTarget = nil
			if renderConnection then renderConnection:Disconnect() end
			if inputConnection then inputConnection:Disconnect() end
			restoreGameAudio()
			if droneSound then droneSound:Stop() end
			if droneContainer then droneContainer:Destroy() end
			if osd and osd.gui then osd.gui:Destroy() end
			LocalPlayer.CameraMinZoomDistance = oldMinZoom
			LocalPlayer.CameraMaxZoomDistance = oldMaxZoom
			UserInputService.MouseBehavior = oldMouseBehavior
			UserInputService.MouseIconEnabled = oldMouseIconEnabled
			if character and character:FindFirstChild("Humanoid") then
				Camera.CameraSubject = character.Humanoid
			end
			if rootPart then
				rootPart.CFrame = originCFrame
				rootPart.AssemblyLinearVelocity = Vector3.zero
			end
			FPV.Running = false
		end
		FPV.Stop = fullCleanup
		local function triggerDetonation(hitTarget)
			if isTerminating then return end
			isTerminating = true
			isFlying = false
			activeTarget = hitTarget or getClosestPlayerToDrone(EXPLOSION_RADIUS)
			local expSound = nil
			if droneCore then
				local expPos = droneCore.Position
				local explosion = Instance.new("Explosion")
				explosion.Position = expPos
				explosion.BlastRadius = EXPLOSION_RADIUS
				explosion.BlastPressure = 0
				explosion.DestroyJointRadiusPercent = 0
				explosion.Parent = workspace
				local expSoundPart = Instance.new("Part")
				expSoundPart.Transparency = 1
				expSoundPart.Anchored = true
				expSoundPart.CanCollide = false
				expSoundPart.Position = expPos
				expSoundPart.Parent = workspace
				expSound = Instance.new("Sound")
				expSound.SoundId = EXPLOSION_SOUND_ID
				expSound.Volume = 3.0
				expSound.Parent = expSoundPart
				expSound:Play()
				Debris:AddItem(expSoundPart, 5)
			end
			if droneSound then droneSound:Stop() end
			if droneContainer then droneContainer:Destroy() end
			muteGameAudio(expSound)
			osd.osdFrame.Visible = false
			osd.noSignalFrame.Visible = true
			task.delay(5, function()
				fullCleanup()
			end)
		end
		renderConnection = RunService.RenderStepped:Connect(function(dt)
			if not character or not character.Parent then
				character = LocalPlayer.Character
				if character then
					rootPart = character:FindFirstChild("HumanoidRootPart")
				end
			end
			Camera = workspace.CurrentCamera
			if isFlying and droneCore then
				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
				UserInputService.MouseIconEnabled = false
				local moveVector = Vector3.zero
				local camCF = Camera.CFrame
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0, 1, 0) end
				if moveVector.Magnitude > 0 then
					moveVector = moveVector.Unit * (FLIGHT_SPEED * dt)
				end
				local newCFrame = CFrame.new(droneCore.Position + moveVector, droneCore.Position + moveVector + camCF.LookVector) * ROTATION_OFFSET
				if droneContainer:IsA("Model") and droneContainer.PrimaryPart then
					droneContainer:SetPrimaryPartCFrame(newCFrame)
				else
					droneCore.CFrame = newCFrame
				end
				local elapsed = os.clock() - startTime
				local mins = math.floor(elapsed / 60)
				local secs = math.floor(elapsed % 60)
				local distFromHome = math.floor((droneCore.Position - originCFrame.Position).Magnitude)
				local alt = math.floor(droneCore.Position.Y)
				local bat = math.max(14.0, 16.8 - elapsed * 0.03)
				local cellBat = bat / 4
				osd.topLeft.Text = string.format("BAT   %.1fV (%.2fV/C)\nRSSI  -%ddBm [LQ 99%%]\nMODE  ACRO / ARMED", bat, cellBat, math.random(48, 60))
				osd.topRight.Text = string.format("VTX   5800MHz 800mW\nALT   %03d M\nDIST  %04d M", alt, distFromHome)
				osd.bottomLeft.Text = string.format("SPD   %02d KM/H\nTHR   %02d%%\nAMP   %.1fA", FLIGHT_SPEED, moveVector.Magnitude > 0 and math.random(72, 95) or 12, moveVector.Magnitude > 0 and 42.5 or 3.2)
				osd.bottomRight.Text = string.format("ON    %02d:%02d\nCAM   FPV-180\nLINK  CRSF 500Hz", mins, secs)
				for _, bar in ipairs(osd.scanlines) do
					bar.Position = UDim2.fromScale(0, math.random())
					bar.BackgroundTransparency = math.random(86, 96) / 100
				end
				local hitTarget = getClosestPlayerToDrone(HIT_RADIUS)
				if hitTarget then
					triggerDetonation(hitTarget)
				end
			end
			if isTerminating and osd.noSignalFrame.Visible then
				for _, sBar in ipairs(osd.staticBars) do
					sBar.Position = UDim2.fromScale(0, math.random())
					local gray = math.random(25, 240)
					sBar.BackgroundColor3 = Color3.fromRGB(gray, gray, gray)
					sBar.BackgroundTransparency = math.random(12, 65) / 100
					sBar.Size = UDim2.new(1, 0, 0, math.random(3, 35))
				end
				osd.noSignalLabel.Visible = (math.floor(os.clock() * 10) % 2 == 0)
			end
			if activeTarget then
				local targetHum = activeTarget.Parent and activeTarget.Parent:FindFirstChild("Humanoid")
				if not activeTarget.Parent or (targetHum and targetHum.Health <= 0) then
					activeTarget = nil
				elseif rootPart then
					rootPart.CFrame = activeTarget.CFrame * CFrame.new(0, 0, 2.5)
					rootPart.AssemblyLinearVelocity = Vector3.zero
					local now = os.clock()
					if now - lastAttackTime >= ATTACK_COOLDOWN then
						lastAttackTime = now
						BasicAttackRemote:FireServer()
					end
				end
			end
		end)
		inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == Enum.KeyCode.K then
				triggerDetonation(nil)
			elseif input.KeyCode == Enum.KeyCode.X then
				fullCleanup()
			end
		end)
	end)
	if not ok then
		FPV.Running = false
		warn("[GoatLose FPV]", err)
	end
end

function FPVStop()
	if FPV.Stop then pcall(FPV.Stop) end
	FPV.Running = false
end



local se5 = AddSection(p7,"Abysswalker")
AddToggle(se5,"Infinite Corrupt",false,function(v) CorruptTgl(v) end)
AddDropdown(se5,"Corrupt Mode",{"Hold","Instant"},"Hold",function(v) CORRUPT.Mode = v end)
AddSlider(se5,"Corrupt Hold Time (Q)",0.5,3,1.4,1,function(v) CORRUPT.HoldNeed = v end)
AddSlider(se5,"Corrupt Delay (sec)",0.05,1,0.3,2,function(v) CORRUPT.Rate = v end)
AddKeybind(se5,"Infinite Corrupt Keybind","None",function() CorruptTgl(not CORRUPT.On) end)
AddLabel(se5,"Remote: Remotes.Killers.Abysswalker.corrupt")
AddLabel(se5,"Hold=wait Hold Time then spam | Instant=spam while Q")

local se6 = AddSection(p7,"FPV Drone (Killer)")
AddButton(se6,"Start FPV Drone",function() FPVStart() end)
AddButton(se6,"Stop FPV Drone",function() FPVStop() end)
AddKeybind(se6,"FPV Drone Keybind","None",function()
	if FPV.Running then FPVStop() else FPVStart() end
end)
AddLabel(se6,"WASD+Space/Ctrl fly | K detonate | X exit")
AddLabel(se6,"Hit player -> explode + BasicAttack stick")

local se5 = AddSection(p7,"Name & Outfit")
OUTFIT.StatusLabel = AddLabel(se5,"Outfit: idle")
AddToggle(se5,"Name Changer Loop",false,function(v) NameChangerTgl(v) end)
-- text fields via dropdown-less: use button + stored value through repeated set
local nameBoxVal = "Anonymous"
local outfitBoxVal = ""
AddDropdown(se5,"Name Preset",{"Anonymous","GoatLose","Player","Custom"},"Anonymous",function(v)
	if v ~= "Custom" then
		nameBoxVal = v
		NameChangerSet(v)
	end
end)
AddButton(se5,"Set Name: Anonymous",function() nameBoxVal = "Anonymous"; NameChangerSet("Anonymous"); NameChangerTgl(true) end)
AddButton(se5,"Set Name = LocalPlayer.Name",function() nameBoxVal = LP.Name; NameChangerSet(LP.Name) end)
-- custom name via key cycling is weak; use TextBox factory inline
do
	local row = N("Frame",se5,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	local tb = N("TextBox",row,{Size=UDim2.new(1,-90,1,-6),Position=UDim2.new(0,6,0,3),BackgroundColor3=Color3.fromRGB(20,23,30),Text="",PlaceholderText="Custom name...",TextColor3=C_TXT,PlaceholderColor3=C_DIM,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,ZIndex=7})
	corner(tb,4)
	local btn = N("TextButton",row,{Size=UDim2.fromOffset(78,22),Position=UDim2.new(1,-82,0.5,-11),BackgroundColor3=C_ACC,Text="Apply",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(10,12,16),ZIndex=7}); corner(btn,5)
	btn.Activated:Connect(function()
		local v = tb.Text:gsub("^%s+",""):gsub("%s+$","")
		if v == "" then v = "Anonymous" end
		nameBoxVal = v
		NameChangerSet(v)
		NameChangerTgl(true)
	end)
end
do
	local row = N("Frame",se5,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	local tb = N("TextBox",row,{Size=UDim2.new(1,-90,1,-6),Position=UDim2.new(0,6,0,3),BackgroundColor3=Color3.fromRGB(20,23,30),Text="",PlaceholderText="Username or UserId...",TextColor3=C_TXT,PlaceholderColor3=C_DIM,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,ZIndex=7})
	corner(tb,4)
	local btn = N("TextButton",row,{Size=UDim2.fromOffset(78,22),Position=UDim2.new(1,-82,0.5,-11),BackgroundColor3=C_ACC,Text="Outfit",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=Color3.fromRGB(10,12,16),ZIndex=7}); corner(btn,5)
	btn.Activated:Connect(function()
		local v = tb.Text:gsub("^%s+",""):gsub("%s+$","")
		if OUTFIT.StatusLabel then (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit: loading "..v.."...") end
		task.spawn(function()
			local ok, err = OutfitApplyFromUser(v)
			if OutfitStatus then
				if ok then (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit: applied "..v)
				else (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit fail: "..tostring(err)) end
			end
		end)
	end)
end
AddButton(se5,"Best Skin (Kakainovaya_kohka)",function()
	(OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit: loading Best Skin...")
	task.spawn(function()
		local ok, err = OutfitApplyFromUser("Kakainovaya_kohka")
		if ok then (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit: Best Skin applied")
		else (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit fail: "..tostring(err)) end
	end)
end)
AddButton(se5,"Anonymous Mode (blank skin + name)",function()
	local ok, err = OutfitApplyAnonymous()
	if ok then (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit: Anonymous")
	else (OUTFIT.StatusLabel and OUTFIT.StatusLabel.Set or function() end)("Outfit fail: "..tostring(err)) end
end)


-- ===================== PERSISTENT VISUALS =====================
VIS_PERSIST = {Conn = nil}

-- FOV lock: Violence District resets FOV every frame in match
FOV_LOCK = {Conn=nil}
local function FOVLockStart()
	if FOV_LOCK.Conn then return end
	FOV_LOCK.Conn = RunService.RenderStepped:Connect(function()
		if not S or not S.VS or S.VS.FOVOn == false then return end
		local cam = Workspace.CurrentCamera
		if not cam then return end
		local fov = tonumber(S.VS.FOV) or 70
		if math.abs(cam.FieldOfView - fov) > 0.1 then
			cam.FieldOfView = fov
		end
	end)
end
FOVLockStart()

local function StartVisualPersist()
	if VIS_PERSIST.Conn then return end
	-- re-apply every few sec so spectator/camera switch cannot wipe forever
	VIS_PERSIST.Conn = RunService.Heartbeat:Connect(function()
		if tick() % 2.5 > 0.05 then return end
		pcall(ApplyVisuals)
		pcall(function()
			if S.AtmoName and S.AtmoName ~= "" and S.AtmoName ~= "Normal" then
				local hasSky = false
				for _,ch in ipairs(Lighting:GetChildren()) do
					if ch:IsA("Sky") then hasSky = true break end
				end
				if not hasSky then ApplyAtmo(S.AtmoName) end
			end
		end)
		if HIDENAME and HIDENAME.On then
			for _,pl in ipairs(Players:GetPlayers()) do
				if pl.Character then pcall(HNStrip, pl.Character) end
			end
		end
	end)
	pcall(function()
		LP.CharacterAdded:Connect(function()
			task.wait(0.4)
			pcall(ApplyVisuals)
			if NAMECH and NAMECH.On then pcall(NCApplyLocal, NAMECH.Text) end
			-- re-apply outfit only if allowed role
			if OUTFIT and OUTFIT.User and OUTFIT.User ~= "" and CanUseOutfitChanger() then
				task.spawn(function()
					task.wait(0.6)
					pcall(OutfitApplyFromUser, OUTFIT.User)
				end)
			end
		end)
	end)
	pcall(function()
		Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			task.wait(0.15)
			pcall(ApplyVisuals)
		end)
	end)
	-- team change -> outfit visibility rules
	pcall(function()
		LP:GetPropertyChangedSignal("Team"):Connect(function()
			task.wait(0.2)
			pcall(ApplyVisuals)
			if IsLocalKiller() then
				if OUTFIT and OUTFIT.StatusLabel then
					pcall(function() OUTFIT.StatusLabel.Set("Outfit: disabled as Killer") end)
				end
			elseif OUTFIT and OUTFIT.User and OUTFIT.User ~= "" and CanUseOutfitChanger() then
				task.spawn(function() pcall(OutfitApplyFromUser, OUTFIT.User) end)
			end
		end)
	end)
end
StartVisualPersist()

-- ===================== INITIAL SELECTION & KEYBIND TOGGLES =====================
SelectTab("Main")

UIS.InputBegan:Connect(function(i,gp)
	if gp or BINDING then return end
	local name = i.KeyCode.Name
	if name == MENU_KEY or i.KeyCode == Enum.KeyCode.Escape then
		if i.KeyCode == Enum.KeyCode.Escape and not Main.Visible then return end
		Main.Visible = not Main.Visible
	end
end)

ApplyVisuals()
end
