-- Goatlose COMPLETE v21 | config list + real load | cursor lock except emote | mobile UI | Vivid visuals engine | Violence District
Players=game:GetService("Players") Workspace=game:GetService("Workspace")
RunService=game:GetService("RunService") UIS=game:GetService("UserInputService")
TweenService=game:GetService("TweenService")
Lighting=game:GetService("Lighting") HttpService=game:GetService("HttpService")
VIM=game:GetService("VirtualInputManager") RS=game:GetService("ReplicatedStorage")
LP=Players.LocalPlayer
BINDING=false
GOAT_STARTED=false
math.randomseed(os.time())

-- ===== GLOBAL MOBILE / CURSOR STATE =====
MOBILE=false
pcall(function() MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled end)
EMOTE_WHEEL_OPEN=false
MOBILE_AIM_HOLD=false

-- ===================== SPLASH SCREEN (10s + weighted music with start offsets) =====================
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
    local total=0
    for _,t in ipairs(SPLASH_TRACKS) do total=total+(tonumber(t.weight) or 1) end
    local roll=math.random(total); local acc=0
    for _,t in ipairs(SPLASH_TRACKS) do acc=acc+(tonumber(t.weight) or 1); if roll<=acc then return t end end
    return SPLASH_TRACKS[1]
end
local function PlaySplashMusic()
    local track=pickSplashTrack()
    local s=Instance.new("Sound"); s.Name="GoatSplashMusic"; s.SoundId="rbxassetid://"..track.id; s.Volume=0; s.TimePosition=track.offset
    s.Parent=Workspace.CurrentCamera or Workspace
    task.spawn(function()
        pcall(function() game:GetService("ContentProvider"):PreloadAsync({s}) end)
        pcall(function() s.TimePosition=track.offset end)
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
    local sg=Instance.new("ScreenGui"); sg.Name="GoatSplash"; sg.ResetOnSpawn=false; sg.IgnoreGuiInset=true
    pcall(function() sg.Parent=(gethui and gethui()) or game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent=LP:WaitForChild("PlayerGui") end
    local bg=Instance.new("Frame",sg); bg.Size=UDim2.fromScale(1,1); bg.BackgroundColor3=Color3.fromRGB(8,9,13); bg.BorderSizePixel=0
    local logo=Instance.new("TextLabel",bg); logo.Size=UDim2.new(1,0,0,60); logo.Position=UDim2.new(0,0,0.5,-80); logo.BackgroundTransparency=1; logo.Text="🐐 GoatLose"; logo.Font=Enum.Font.GothamBlack; logo.TextSize=42; logo.TextColor3=Color3.fromRGB(255,105,180)
    local status=Instance.new("TextLabel",bg); status.Size=UDim2.new(1,0,0,20); status.Position=UDim2.new(0,0,0.5,-8); status.BackgroundTransparency=1; status.Text="initializing..."; status.Font=Enum.Font.Gotham; status.TextSize=13; status.TextColor3=Color3.fromRGB(150,156,170)
    local barBg=Instance.new("Frame",bg); barBg.Size=UDim2.new(0,320,0,6); barBg.Position=UDim2.new(0.5,-160,0.5,28); barBg.BackgroundColor3=Color3.fromRGB(30,33,42); barBg.BorderSizePixel=0
    local c1=Instance.new("UICorner",barBg); c1.CornerRadius=UDim.new(0,3)
    local bar=Instance.new("Frame",barBg); bar.Size=UDim2.new(0,0,1,0); bar.BackgroundColor3=Color3.fromRGB(255,105,180); bar.BorderSizePixel=0
    local c2=Instance.new("UICorner",bar); c2.CornerRadius=UDim.new(0,3)
    local pct=Instance.new("TextLabel",bg); pct.Size=UDim2.new(1,0,0,16); pct.Position=UDim2.new(0,0,0.5,42); pct.BackgroundTransparency=1; pct.Text="0%"; pct.Font=Enum.Font.GothamSemibold; pct.TextSize=12; pct.TextColor3=Color3.fromRGB(210,215,225)
    local music=PlaySplashMusic()
    local steps=100; local stepTime=SPLASH_TIME/steps
    local messages={[1]="initializing...",[20]="loading assets...",[45]="preparing ui...",[70]="injecting hooks...",[92]="ready..."}
    for i=1,steps do
        local p=i/steps; bar.Size=UDim2.new(p,0,1,0); pct.Text=tostring(math.floor(p*100)).."%"
        if messages[i] then status.Text=messages[i] end
        task.wait(stepTime)
    end
    StopSplashMusic(music); task.wait(0.25); pcall(function() sg:Destroy() end)
end
ShowSplash()
-- ================================================================================================

-- ===================== DEFAULT BACKGROUND =====================
local BG_GATE_ID="97305033309089"
local BG_MENU_ID=""
GATE_BG=nil MAIN_BG=nil
local function setBgImage(img,id)
    if not img then return end
    local url=(type(id)=="string" and id~="") and ("rbxassetid://"..id) or ""
    img.Image=url; img.Visible=(url~="")
end
function ApplyBg() setBgImage(GATE_BG,BG_GATE_ID); setBgImage(MAIN_BG,BG_MENU_ID) end
-- ==============================================================

-- ===================== KEY CACHE (versioned + 24h TTL) =====================
local CACHE_FILE="Goatlose_KeyCache.json"
local CURRENT_VER="21"
local TTL=24*3600
local function cacheSave(uname,key) pcall(function() if writefile then writefile(CACHE_FILE,HttpService:JSONEncode({username=uname,key=key,ver=CURRENT_VER,exp=os.time()+TTL})) end end) end
local function cacheLoad()
    if not (readfile and isfile and isfile(CACHE_FILE)) then return nil end
    local ok,d=pcall(function() return HttpService:JSONDecode(readfile(CACHE_FILE)) end)
    if ok and type(d)=="table" then return d end
    return nil
end
local function cacheAllow(uname)
    local d=cacheLoad(); if not d then return false end
    if d.username~=uname then return false end
    if type(d.key)~="string" or #d.key==0 then return false end
    if d.ver~=CURRENT_VER then return false end
    if type(d.exp)~="number" or os.time()>d.exp then return false end
    return true
end
local MASTER_KEYS={ ["Казель"]=true, ["казель"]=true, ["ArtemFemboy"]=true, ["artemfemboy"]=true }
-- ===========================================================================

if not cacheAllow(LP.Name) then
    local KS_Gui=Instance.new("ScreenGui"); KS_Gui.Name="KeySystemGui"; KS_Gui.ResetOnSpawn=false; KS_Gui.IgnoreGuiInset=true
    pcall(function() KS_Gui.Parent=(gethui and gethui()) or game:GetService("CoreGui") end)
    if not KS_Gui.Parent then KS_Gui.Parent=LP:WaitForChild("PlayerGui") end
    local Frame=Instance.new("Frame")
    Frame.Size=UDim2.new(0,320,0,200); Frame.Position=UDim2.new(0.5,-160,0.5,-100)
    Frame.BackgroundColor3=Color3.fromRGB(236,72,153); Frame.BorderSizePixel=0; Frame.ClipsDescendants=true; Frame.Parent=KS_Gui
    local FC=Instance.new("UICorner"); FC.CornerRadius=UDim.new(0,10); FC.Parent=Frame
    local FG=Instance.new("UIGradient"); FG.Rotation=45
    FG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,105,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(147,51,234))}); FG.Parent=Frame
    GATE_BG=Instance.new("ImageLabel"); GATE_BG.Size=UDim2.new(1,0,1,0); GATE_BG.BackgroundTransparency=1; GATE_BG.Image=""; GATE_BG.ScaleType=Enum.ScaleType.Crop; GATE_BG.Transparency=0.35; GATE_BG.ZIndex=1; GATE_BG.Parent=Frame
    ApplyBg()
    local CloseButton=Instance.new("TextButton"); CloseButton.Text="✕"; CloseButton.Font=Enum.Font.GothamBold; CloseButton.TextSize=18; CloseButton.TextColor3=Color3.fromRGB(255,255,255); CloseButton.BackgroundTransparency=1; CloseButton.ZIndex=3; CloseButton.Size=UDim2.new(0,28,0,28); CloseButton.Position=UDim2.new(1,-32,0,4); CloseButton.Parent=Frame
    local TitleLabel=Instance.new("TextLabel"); TitleLabel.Text="🐐 GoatLose — Enter Key"; TitleLabel.Font=Enum.Font.GothamBold; TitleLabel.TextSize=16; TitleLabel.TextColor3=Color3.fromRGB(255,255,255); TitleLabel.TextStrokeTransparency=0; TitleLabel.TextStrokeColor3=Color3.fromRGB(40,10,40); TitleLabel.BackgroundTransparency=1; TitleLabel.Size=UDim2.new(1,0,0,30); TitleLabel.Position=UDim2.new(0,0,0,12); TitleLabel.ZIndex=2; TitleLabel.Parent=Frame
    local KeyBox=Instance.new("TextBox"); KeyBox.PlaceholderText="t.me/GoatL0se"; KeyBox.Text=""; KeyBox.Font=Enum.Font.Gotham; KeyBox.TextSize=14; KeyBox.TextColor3=Color3.fromRGB(255,255,255); KeyBox.PlaceholderColor3=Color3.fromRGB(255,190,225); KeyBox.BackgroundColor3=Color3.fromRGB(40,20,45); KeyBox.ZIndex=2; KeyBox.Size=UDim2.new(1,-40,0,34); KeyBox.Position=UDim2.new(0,20,0,52); KeyBox.ClearTextOnFocus=false; KeyBox.Parent=Frame
    local KC=Instance.new("UICorner"); KC.CornerRadius=UDim.new(0,6); KC.Parent=KeyBox
    local StatusLabel=Instance.new("TextLabel"); StatusLabel.Text=""; StatusLabel.Font=Enum.Font.Gotham; StatusLabel.TextSize=12; StatusLabel.TextColor3=Color3.fromRGB(255,255,255); StatusLabel.TextStrokeTransparency=0; StatusLabel.TextStrokeColor3=Color3.fromRGB(40,10,40); StatusLabel.BackgroundTransparency=1; StatusLabel.Size=UDim2.new(1,-40,0,36); StatusLabel.Position=UDim2.new(0,20,0,92); StatusLabel.TextWrapped=true; StatusLabel.ZIndex=2; StatusLabel.Parent=Frame
    local LoginButton=Instance.new("TextButton"); LoginButton.Text="LOGIN"; LoginButton.Font=Enum.Font.GothamBold; LoginButton.TextSize=15; LoginButton.TextColor3=Color3.fromRGB(236,72,153); LoginButton.BackgroundColor3=Color3.fromRGB(255,255,255); LoginButton.ZIndex=2; LoginButton.Size=UDim2.new(1,-40,0,36); LoginButton.Position=UDim2.new(0,20,0,148); LoginButton.Parent=Frame
    local LC=Instance.new("UICorner"); LC.CornerRadius=UDim.new(0,6); LC.Parent=LoginButton
    CloseButton.Activated:Connect(function() KS_Gui:Destroy() end)
    LoginButton.Activated:Connect(function()
        local key=KeyBox.Text:gsub("^%s+",""):gsub("%s+$","")
        if key=="" then StatusLabel.TextColor3=Color3.fromRGB(255,210,210); StatusLabel.Text="Please enter a key"; return end
        if MASTER_KEYS[key] then
            cacheSave(LP.Name,key); StatusLabel.TextColor3=Color3.fromRGB(255,255,255); StatusLabel.Text="Success! (master)"
            task.wait(0.3); pcall(function() KS_Gui:Destroy() end); if not GOAT_STARTED then pcall(goatMain) end; return
        end
        StatusLabel.TextColor3=Color3.fromRGB(255,255,255); StatusLabel.Text="Checking..."
        local settled=false
        local function succeed() if settled then return end settled=true; cacheSave(LP.Name,key); StatusLabel.TextColor3=Color3.fromRGB(255,255,255); StatusLabel.Text="Success!"; task.wait(0.4); pcall(function() KS_Gui:Destroy() end); if not GOAT_STARTED then pcall(goatMain) end end
        local function fail(m) if settled then return end settled=true; StatusLabel.TextColor3=Color3.fromRGB(255,200,200); StatusLabel.Text=m end
        task.spawn(function() task.wait(15); if not settled then fail("Timed Out, try using VPN") end end)
        task.spawn(function()
            local success,response=pcall(function() return HttpService:RequestAsync({Url="https://solyariy.devrobloxnoob.workers.dev/validate",Method="POST",Headers={["Content-Type"]="application/json"},Body=HttpService:JSONEncode({key=key,username=LP.Name})}) end)
            if settled then return end
            if not success then fail("Network error"); return end
            local code=response.StatusCode
            if code>=500 then fail("Server down, try later"); return end
            local dok,decoded=pcall(function() return HttpService:JSONDecode(response.Body) end)
            if not dok then fail("Bad server reply"); return end
            if code==200 and decoded and decoded.valid then succeed() else fail((decoded and decoded.message) or "Invalid key") end
        end)
    end)
end

function goatMain()
if GOAT_STARTED then return end
GOAT_STARTED=true
C_BG=Color3.fromRGB(16,19,26) C_SIDE=Color3.fromRGB(12,14,19) C_BOX=Color3.fromRGB(22,26,34)
C_ROW=Color3.fromRGB(28,32,42) C_ACC=Color3.fromRGB(59,130,246) C_TXT=Color3.fromRGB(210,215,225) C_DIM=Color3.fromRGB(120,126,140)
Gui=Instance.new("ScreenGui"); Gui.ResetOnSpawn=false; Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
pcall(function() Gui.Parent=(gethui and gethui()) or game:GetService("CoreGui") end)
if not Gui.Parent then Gui.Parent=LP:WaitForChild("PlayerGui") end
function N(c,p,pr) local o=Instance.new(c) for k,v in pairs(pr or {}) do o[k]=v end o.Parent=p return o end
function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p return c end
Main=N("Frame",Gui,{Size=UDim2.fromOffset(640,440),Position=UDim2.new(0.5,-320,0.5,-220),BackgroundColor3=C_BG,BorderSizePixel=0,Active=true,Draggable=true,ClipsDescendants=true,Visible=false})
corner(Main,10)
MAIN_BG=N("ImageLabel",Main,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Image="",ScaleType=Enum.ScaleType.Crop,Transparency=0.45,ZIndex=1}); corner(MAIN_BG,10)
ApplyBg()
Top=N("Frame",Main,{Size=UDim2.new(1,0,0,40),BackgroundColor3=C_SIDE,BorderSizePixel=0,ZIndex=2}); corner(Top,10)
N("TextLabel",Top,{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="Goatlose COMPLETE v21",Font=Enum.Font.GothamBlack,TextSize=15,TextColor3=C_ACC,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3})
N("TextLabel",Top,{Size=UDim2.new(0.5,-12,1,0),Position=UDim2.new(0.5,0,0,0),BackgroundTransparency=1,Text="RightShift / Esc - menu",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=3})
Side=N("Frame",Main,{Size=UDim2.new(0,140,1,-40),Position=UDim2.new(0,0,0,40),BackgroundColor3=C_SIDE,BorderSizePixel=0,ZIndex=2}); corner(Side,10)
TabList=N("Frame",Side,{Size=UDim2.new(1,-14,1,-14),Position=UDim2.new(0,7,0,7),BackgroundTransparency=1,ZIndex=3})
N("UIListLayout",TabList,{Padding=UDim.new(0,5)})
Content=N("Frame",Main,{Size=UDim2.new(1,-140,1,-40),Position=UDim2.new(0,140,0,40),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2})

-- ===== MOBILE RESIZE =====
if MOBILE then
	local cam=Workspace.CurrentCamera
	local vw=cam and cam.ViewportSize.X or 800
	local vh=cam and cam.ViewportSize.Y or 600
	local w=math.clamp(math.floor(vw*0.88),280,390)
	local h=math.clamp(math.floor(vh*0.70),300,430)
	Main.Size=UDim2.fromOffset(w,h); Main.Position=UDim2.new(0.5,-w/2,0.5,-h/2)
	Top.Size=UDim2.new(1,0,0,36); Side.Size=UDim2.new(0,108,1,-36)
	Content.Position=UDim2.new(0,108,0,36); Content.Size=UDim2.new(1,-108,1,-36)
	for _,ch in ipairs(Top:GetChildren()) do
		if ch:IsA("TextLabel") and ch.Text:find("RightShift") then ch.Visible=false end
	end
end

pages={} tabBtns={}
function SelectTab(n) for k,p in pairs(pages) do p.Scroll.Visible=(k==n) end for k,b in pairs(tabBtns) do if k==n then b.L.TextColor3=Color3.fromRGB(255,255,255); b.B.BackgroundColor3=C_BOX else b.L.TextColor3=C_DIM; b.B.BackgroundColor3=C_SIDE end end end

-- ===================== CONFIG REGISTRY =====================
CFG_CONTROLS={} CFG_USED_KEYS={}
CFG_FOLDER="Goatlose" CFG_INDEX_FILE="Goatlose/_index.json" CFG_SELECTED=""
local function cfgKey(title)
	local base=tostring(title or "control"); local key=base; local n=1
	while CFG_USED_KEYS[key] do n=n+1; key=base.." ("..n..")" end
	CFG_USED_KEYS[key]=true; return key
end
local function safeCfgName(n)
	n=tostring(n or ""); n=n:match("([^/\\]+)$") or n; n=n:gsub("%.json$",""); n=n:gsub("^%s+",""):gsub("%s+$",""); n=n:gsub('[/\\:%*%?"<>|]','_')
	if n=="" then n="config" end; return n:sub(1,40)
end
local function ensureCfgFolder() pcall(function() if type(makefolder)=="function" and type(isfolder)=="function" and not isfolder(CFG_FOLDER) then makefolder(CFG_FOLDER) end end) end
local function cfgPath(name) return CFG_FOLDER.."/"..safeCfgName(name)..".json" end
local function loadCfgIndex()
	local out={} local set={}
	pcall(function()
		if readfile and isfile and isfile(CFG_INDEX_FILE) then
			local d=HttpService:JSONDecode(readfile(CFG_INDEX_FILE)); local arr=nil
			if type(d)=="table" then if type(d.names)=="table" then arr=d.names elseif #d>0 then arr=d end end
			if type(arr)=="table" then for _,v in ipairs(arr) do local n=safeCfgName(v); if n~="" and not set[n] then set[n]=true; table.insert(out,n) end end end
		end
	end)
	return out
end
local function saveCfgIndex(names) ensureCfgFolder(); pcall(function() if writefile then writefile(CFG_INDEX_FILE,HttpService:JSONEncode({names=names or {}})) end end) end
local function addCfgIndex(name) name=safeCfgName(name); local list=loadCfgIndex(); local set={} for _,v in ipairs(list) do set[v]=true end if not set[name] then table.insert(list,name) end table.sort(list); saveCfgIndex(list) end
local function removeCfgIndex(name) name=safeCfgName(name); local list=loadCfgIndex(); local out={} for _,v in ipairs(list) do if v~=name then table.insert(out,v) end end saveCfgIndex(out) end
local function getConfigNames()
	local list={} local set={}
	local function push(n) n=safeCfgName(n); if n~="" and n~="_index" and not set[n] then set[n]=true; table.insert(list,n) end end
	for _,n in ipairs(loadCfgIndex()) do push(n) end
	pcall(function() if type(listfiles)=="function" then local files=listfiles(CFG_FOLDER); if type(files)=="table" then for _,f in ipairs(files) do local bn=tostring(f):match("([^/\\]+)$") or tostring(f); local nm=bn:gsub("%.json$",""); if nm~="_index" then push(nm) end end end end end)
	table.sort(list); return list,set
end
local function nextAutoCfgName() local list,set=getConfigNames(); for i=1,999 do local n="GoatCfg"..i; if not set[n] then return n end end; return "GoatCfg"..tostring(math.floor(os.time())) end
-- ===========================================================

function AddTab(n)
	local b=N("TextButton",TabList,{Size=UDim2.new(1,0,0,32),BackgroundColor3=C_SIDE,AutoButtonColor=false,Text="",ZIndex=4}); corner(b,7)
	local l=N("TextLabel",b,{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text=n,Font=Enum.Font.GothamSemibold,TextSize=13,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
	local sc=N("ScrollingFrame",Content,{Size=UDim2.new(1,-14,1,-14),Position=UDim2.new(0,7,0,7),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=3})
	N("UIListLayout",sc,{Padding=UDim.new(0,9)})
	pages[n]={Scroll=sc}; tabBtns[n]={B=b,L=l}
	b.Activated:Connect(function() SelectTab(n) end)
	return sc
end
function AddSection(ps,t)
	local box=N("Frame",ps,{Size=UDim2.new(1,0,0,32),BackgroundColor3=C_BOX,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=4}); corner(box,8)
	N("TextLabel",box,{Size=UDim2.new(1,-14,0,28),Position=UDim2.new(0,10,0,2),BackgroundTransparency=1,Text=t,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5})
	local rows=N("Frame",box,{Size=UDim2.new(1,-10,0,5),Position=UDim2.new(0,5,0,30),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5})
	N("UIListLayout",rows,{Padding=UDim.new(0,4)}); N("UIPadding",rows,{PaddingBottom=UDim.new(0,7)})
	return rows
end
function AddToggle(p,t,d,cb)
	local row=N("TextButton",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,AutoButtonColor=false,Text="",ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local tr=N("Frame",row,{Size=UDim2.fromOffset(32,17),Position=UDim2.new(1,-41,0.5,-8),BackgroundColor3=Color3.fromRGB(45,50,62),BorderSizePixel=0,ZIndex=7}); corner(tr,8)
	local kn=N("Frame",tr,{Size=UDim2.fromOffset(13,13),Position=UDim2.new(0,2,0.5,-6),BackgroundColor3=Color3.fromRGB(150,156,170),BorderSizePixel=0,ZIndex=8}); corner(kn,6)
	local on=false
	local function set(v) on=v; tr.BackgroundColor3=v and C_ACC or Color3.fromRGB(45,50,62); kn.Position=v and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,2,0.5,-6); kn.BackgroundColor3=v and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,156,170); pcall(cb,v) end
	CFG_CONTROLS[cfgKey(t)]={type="toggle",set=set,get=function() return on end}
	row.Activated:Connect(function() set(not on) end)
	set(on)
	return {Set=set,Get=function() return on end}
end
function AddSlider(p,t,mn,mx,d,dec,cb,reg)
	reg = reg ~= false
	local row=N("Frame",p,{Size=UDim2.new(1,0,0,34),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(0.6,-9,0,15),Position=UDim2.new(0,9,0,3),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local val=N("TextLabel",row,{Size=UDim2.new(0.4,-9,0,15),Position=UDim2.new(0.6,0,0,3),BackgroundTransparency=1,Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=7})
	local tr=N("Frame",row,{Size=UDim2.new(1,-18,0,4),Position=UDim2.new(0,9,0,24),BackgroundColor3=Color3.fromRGB(45,50,62),BorderSizePixel=0,ZIndex=7}); corner(tr,2)
	local fl=N("Frame",tr,{Size=UDim2.new(0.5,0,1,0),BackgroundColor3=C_ACC,BorderSizePixel=0,ZIndex=8}); corner(fl,2)
	local kn=N("Frame",tr,{Size=UDim2.fromOffset(9,9),Position=UDim2.new(0.5,-4,0.5,-4),BackgroundColor3=Color3.fromRGB(235,238,245),BorderSizePixel=0,ZIndex=9}); corner(kn,4)
	local value=d; local drag=false
	local function ap(f) f=math.clamp(f,0,1); value=mn+(mx-mn)*f; if dec and dec>0 then local pw=10^dec value=math.floor(value*pw+0.5)/pw end; fl.Size=UDim2.new(f,0,1,0); kn.Position=UDim2.new(f,-4,0.5,-4); val.Text=tostring(value); pcall(cb,value) end
	local function isDown(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
	local function isMove(i) return i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch end
	local function isEnd(i) return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch end
	local hit=N("TextButton",row,{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=10,Active=true})
	hit.InputBegan:Connect(function(i) if isDown(i) then drag=true; local dn=tr.AbsoluteSize.X; if dn<=0 then dn=1 end; ap((i.Position.X-tr.AbsolutePosition.X)/dn) end end)
	UIS.InputChanged:Connect(function(i) if drag and isMove(i) then local dn=tr.AbsoluteSize.X; if dn<=0 then dn=1 end; ap((i.Position.X-tr.AbsolutePosition.X)/dn) end end)
	UIS.InputEnded:Connect(function(i) if drag and isEnd(i) then drag=false end end)
	local api={Set=function(v) ap((v-mn)/(mx-mn)) end,Get=function() return value end}
	if reg then CFG_CONTROLS[cfgKey(t)]={type="slider",set=api.Set,get=api.Get} end
	ap((d-mn)/(mx-mn))
	return api
end
function AddColor(p,t,d,cb)
	local holder=N("Frame",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=6}); corner(holder,6)
	local row=N("TextButton",holder,{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,AutoButtonColor=false,Text="",ZIndex=7})
	N("TextLabel",row,{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8})
	local pv=N("Frame",row,{Size=UDim2.fromOffset(32,13),Position=UDim2.new(1,-41,0.5,-6),BackgroundColor3=d,BorderSizePixel=0,ZIndex=8}); corner(pv,4)
	local ex=N("Frame",holder,{Size=UDim2.new(1,-10,0,0),Position=UDim2.new(0,5,0,28),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=8})
	N("UIListLayout",ex,{Padding=UDim.new(0,3)}); N("UIPadding",ex,{PaddingBottom=UDim.new(0,5)})
	local cur={r=d.R*255,g=d.G*255,b=d.B*255}
	local function live() local c=Color3.fromRGB(cur.r,cur.g,cur.b); pv.BackgroundColor3=c; pcall(cb,c) end
	AddSlider(ex,"R",0,255,cur.r,0,function(v) cur.r=v; live() end,false)
	AddSlider(ex,"G",0,255,cur.g,0,function(v) cur.g=v; live() end,false)
	AddSlider(ex,"B",0,255,cur.b,0,function(v) cur.b=v; live() end,false)
	local api={Get=function() return {cur.r,cur.g,cur.b} end,Set=function(c) if typeof(c)=="Color3" then cur.r=c.R*255; cur.g=c.G*255; cur.b=c.B*255 elseif type(c)=="table" then cur.r=c[1] or 0; cur.g=c[2] or 0; cur.b=c[3] or 0 end; live() end}
	CFG_CONTROLS[cfgKey(t)]={type="color",set=function(v) if typeof(v)=="Color3" then api.Set(v) elseif type(v)=="table" then api.Set(Color3.fromRGB(v[1] or 0,v[2] or 0,v[3] or 0)) end end,get=function() return api.Get() end}
	row.Activated:Connect(function() ex.Visible=not ex.Visible end)
	return api
end
function AddKeybind(p,t,dk,op)
	local row=N("Frame",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-76,1,0),Position=UDim2.new(0,9,0,0),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local bw=MOBILE and 46 or 60
	local bx=N("TextButton",row,{Size=UDim2.fromOffset(bw,17),Position=UDim2.new(1,-(bw+8),0.5,-8),BackgroundColor3=MOBILE and C_ACC or Color3.fromRGB(20,23,30),AutoButtonColor=false,Font=Enum.Font.GothamSemibold,TextSize=10,TextColor3=MOBILE and Color3.fromRGB(10,12,16) or C_DIM,ZIndex=7}); corner(bx,5)
	local cur=dk; local lis=false; local lw=0
	local function lb() if cur=="None" then bx.Text="[None]" else bx.Text="["..cur.."]" end; bx.TextColor3=C_DIM end
	local function lbMobile() if cur=="None" or cur=="MWheel" then bx.Text="TAP" else bx.Text=cur:sub(1,4) end end
	local function setKey(k) if type(k)=="string" and k~="" then cur=k else cur="None" end; if MOBILE then lbMobile() else lb() end end
	if MOBILE then
		lbMobile(); bx.Activated:Connect(function() pcall(op) end)
	else
		lb(); bx.Activated:Connect(function() lis=true; BINDING=true; bx.Text="[...]"; bx.TextColor3=C_ACC end)
		UIS.InputBegan:Connect(function(i,gp)
			if lis then lis=false; BINDING=false; if i.KeyCode==Enum.KeyCode.Escape then cur="None"; lb(); return end; if i.KeyCode~=Enum.KeyCode.Unknown then cur=i.KeyCode.Name; lb() end; return end
			if gp then return end
			if cur~="None" and cur~="MWheel" and i.KeyCode.Name==cur then pcall(op) end
		end)
		UIS.InputChanged:Connect(function(i,gp)
			if gp then return end
			if lis and i.UserInputType==Enum.UserInputType.MouseWheel then lis=false; BINDING=false; cur="MWheel"; lb(); return end
			if cur=="MWheel" and i.Position.Z>0 and tick()-lw>0.2 then lw=tick(); pcall(op) end
		end)
	end
	CFG_CONTROLS[cfgKey(t)]={type="keybind",set=setKey,get=function() return cur end}
	return {Get=function() return cur end,Set=setKey}
end
function AddDropdown(p,t,vals,def,cb)
	local row=N("Frame",p,{Size=UDim2.new(1,0,0,52),BackgroundColor3=C_ROW,BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(1,-18,0,16),Position=UDim2.new(0,9,0,3),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local list=N("Frame",row,{Size=UDim2.new(1,-18,0,18),Position=UDim2.new(0,9,0,21),BackgroundColor3=Color3.fromRGB(20,23,30),BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=7}); corner(list,4)
	N("UIListLayout",list,{Padding=UDim.new(0,2)}); N("UIPadding",list,{PaddingTop=UDim.new(0,2),PaddingBottom=UDim.new(0,2),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)})
	local cur=def
	local function setValue(v) cur=v; for _,o in ipairs(list:GetChildren()) do if o:IsA("TextButton") then o.TextColor3=(o.Text==v) and C_ACC or C_DIM end end; pcall(cb,v) end
	for _,v in ipairs(vals) do
		local b=N("TextButton",list,{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Text=v,Font=Enum.Font.Gotham,TextSize=11,TextColor3=(v==def) and C_ACC or C_DIM,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=8})
		b.Activated:Connect(function() setValue(v) end)
	end
	CFG_CONTROLS[cfgKey(t)]={type="dropdown",set=setValue,get=function() return cur end}
	return {Get=function() return cur end,Set=setValue}
end
function AddButton(p,t,cb)
	local b=N("TextButton",p,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,AutoButtonColor=false,Text=t,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=C_TXT,ZIndex=6}); corner(b,6)
	b.Activated:Connect(function() pcall(cb) end)
	return b
end
function AddLabel(p,t)
	local l=N("TextLabel",p,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=t,Font=Enum.Font.Gotham,TextSize=10,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
	return {Set=function(s) l.Text=s end}
end
function GetRoot(c) if not c then return nil end return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso") end
function GetHum(c) if not c then return nil end return c:FindFirstChildOfClass("Humanoid") end
function IsKiller(p) if not p or not p.Character then return false end local n=p.Name:lower() if n:find("killer") or n:find("hunter") or n:find("murderer") or n:find("slasher") then return true end for _,w in ipairs({"Knife","Axe","Sword","Parrying Dagger","Machete","Bat","Weapon"}) do if p.Character:FindFirstChild(w) or p.Character:FindFirstChild(w:lower()) then return true end end local a,b=0,0 for _,v in pairs(p.Character:GetDescendants()) do if v:IsA("BasePart") then a=a+1 if v.Color.R<0.3 and v.Color.G<0.3 and v.Color.B<0.3 then b=b+1 end end end return a>0 and b/a>0.5 end
function IsSurv() local t=LP.Team if not t then return false end local n=t.Name:lower() return n:find("survivor")~=nil or n=="survivors" or n=="survivor" end
function PressSpace() pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.Space,false,game) end) task.wait(0.02) pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.Space,false,game) end) end
function httpGetBody(u)
	if type(request)=="function" then local o,r=pcall(request,{Url=u,Method="GET"}); if o and r and r.Body then return r.Body end end
	if type(http_request)=="function" then local o,r=pcall(http_request,{Url=u,Method="GET"}); if o and r and r.Body then return r.Body end end
	local o,r=pcall(function() return game:HttpGet(u) end); if o and r then return r end
	return nil
end
function GetNum(pl,key,def) local v=pl:GetAttribute(key) if typeof(v)=="number" then return v end if pl.Character then local c=pl.Character:GetAttribute(key) if typeof(c)=="number" then return c end end return def end
function GetStr(pl,key,def) local v=pl:GetAttribute(key) if typeof(v)=="string" and v~="" then return v end return def end
S={
ESP={On=false,Surv=Color3.fromRGB(0,255,0),Kill=Color3.fromRGB(255,0,0),Fill=false,FillColor=Color3.fromRGB(255,0,0),CS2=false,CS2C=Color3.fromRGB(0,255,0),Gen=false,Pallet=false,GenC=Color3.fromRGB(0,255,255),PalC=Color3.fromRGB(127,0,255)},
Parry={Range=10,Anim=1}, CTP={On=false,Dist=50}, BW={Range=14}, Droch={Speed=2.5},
China={Color=Color3.fromRGB(255,0,255)}, PC={Color=Color3.fromRGB(0,255,80)}, Tint={On=false,R=255,G=200,B=200,Br=1},
KL={Color=Color3.fromRGB(255,255,0)}, Traj={Color=Color3.fromRGB(0,240,255)},
VS={RTX=false,DOF=false,Tint="Default",Preset="Default",Sat=0.55,Con=-0.35,Atmo=0.3,Fog=false,FogColor=Color3.fromRGB(120,160,200),FogStart=0,FogEnd=100000,NoFog=true,Light=false,LightColor=Color3.fromRGB(255,255,255),Time="Default",ClockTime=14.5,Bloom=false,BloomI=0,BloomS=24,BloomT=0.85,SunRays=true,SunI=0.45,SunSpread=0.7,FOV=70,Crosshair=false,CrossStyle="Classic",CrossColor=Color3.fromRGB(0,255,255),CrossSize=10,Vivid=true},
On={},
}
function RefreshESP()
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character then
			local hl=pl.Character:FindFirstChild("GoatESP")
			if S.ESP.On then
				if not hl then hl=Instance.new("Highlight"); hl.Name="GoatESP"; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=pl.Character end
				local ik=IsKiller(pl)
				if ik and S.ESP.Fill then hl.FillTransparency=0.5; hl.FillColor=S.ESP.FillColor else hl.FillTransparency=1 end
				hl.OutlineColor=ik and S.ESP.Kill or S.ESP.Surv
			elseif hl then hl:Destroy() end
		end
	end
end
function RefreshObjESP()
	for _,d in ipairs(Workspace:GetDescendants()) do
		local isGen=(d.Name:lower():find("generator")~=nil) and (d:IsA("Model") or d:IsA("BasePart"))
		local isPal=d.Name=="Palletwrong"
		if isGen or isPal then
			local hl=d:FindFirstChild("GoatObj")
			local want=(isGen and S.ESP.Gen) or (isPal and S.ESP.Pallet)
			if want then
				if not hl then hl=Instance.new("Highlight"); hl.Name="GoatObj"; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=d end
				hl.FillColor=isGen and S.ESP.GenC or S.ESP.PalC; hl.OutlineColor=hl.FillColor; hl.FillTransparency=0.5
			elseif hl then hl:Destroy() end
		end
	end
end
task.spawn(function() while true do task.wait(2) if S.ESP.On then RefreshESP() end if S.ESP.Gen or S.ESP.Pallet then RefreshObjESP() end end end)
Players.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function() task.wait(0.5) RefreshESP() end) end)
CS2={P={},C=nil}
BONES={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
BONES6={{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"Torso","Left Leg"},{"Torso","Right Leg"}}
function CS2Hide(e) if e then e.b.Visible=false; e.n.Visible=false; for _,l in ipairs(e.l) do l.Visible=false end end end
function CS2Upd()
	local cam=Workspace.CurrentCamera
	for _,pl in ipairs(Players:GetPlayers()) do
		local e=CS2.P[pl]; local ch=(pl~=LP) and pl.Character or nil; local r=ch and GetRoot(ch); local hd=ch and ch:FindFirstChild("Head")
		if not (S.ESP.CS2 and ch and r and hd) then CS2Hide(e)
		else
			if not e then e={l={}}; e.b=Drawing.new("Square"); e.b.Thickness=1; e.b.Filled=false; e.b.Transparency=1; e.n=Drawing.new("Text"); e.n.Size=13; e.n.Center=true; e.n.Outline=true; for i=1,14 do e.l[i]=Drawing.new("Line"); e.l[i].Thickness=1.5; e.l[i].Transparency=1 end; CS2.P[pl]=e end
			local tp=cam:WorldToViewportPoint(hd.Position+Vector3.new(0,0.6,0)); local bt=cam:WorldToViewportPoint(r.Position-Vector3.new(0,3.1,0)); local vis=tp.Z>0
			local h=bt.Y-tp.Y; local w=h*0.45
			e.b.Visible=vis; e.b.Color=S.ESP.CS2C; e.b.Position=Vector2.new(tp.X-w/2,tp.Y); e.b.Size=Vector2.new(w,h)
			e.n.Visible=vis; e.n.Color=Color3.fromRGB(255,255,255); e.n.Position=Vector2.new(tp.X,tp.Y-14); e.n.Text=pl.DisplayName
			local bs=ch:FindFirstChild("UpperTorso") and BONES or BONES6
			for i,pr in ipairs(bs) do
				local l=e.l[i]; local a=ch:FindFirstChild(pr[1]); local b=ch:FindFirstChild(pr[2])
				if l and a and b then local pa=cam:WorldToViewportPoint(a.Position); local pb=cam:WorldToViewportPoint(b.Position); l.Visible=vis; l.Color=S.ESP.CS2C; l.From=Vector2.new(pa.X,pa.Y); l.To=Vector2.new(pb.X,pb.Y) elseif l then l.Visible=false end
			end
		end
	end
end
function CS2Tgl(on)
	S.On.cs2=on
	if on then if not CS2.C then CS2.C=RunService.RenderStepped:Connect(CS2Upd) end return end
	if CS2.C then CS2.C:Disconnect(); CS2.C=nil end
	for _,e in pairs(CS2.P) do CS2Hide(e) end
end
PARRY={} for _,id in ipairs({"rbxassetid://110355011987939","rbxassetid://139369275981139","rbxassetid://117042998468241","rbxassetid://133963973694098","rbxassetid://113255068724446","rbxassetid://74968262036854","rbxassetid://118907603246885","rbxassetid://78432063483146","rbxassetid://129784271201071","rbxassetid://122812055447896","rbxassetid://138720291317243","rbxassetid://106871536134254","rbxassetid://109402730355822","rbxassetid://111920872708571","rbxassetid://105374834496520"}) do PARRY[id]=true end
AP={On=false,Conns={},Spam=false}
function APSpam()
	if AP.Spam then return end
	AP.Spam=true
	local r=GetRoot(LP.Character); if r then r.Anchored=true end
	pcall(function() VIM:SendMouseButtonEvent(0,0,1,true,game,0) end)
	task.spawn(function() task.wait() pcall(function() VIM:SendMouseButtonEvent(0,0,1,false,game,0) end) AP.Spam=false end)
	task.delay(0.9,function() if r and r.Parent and not S.On.fakeparry then r.Anchored=false end end)
end
function APClear(p) if AP.Conns[p] then for _,c in ipairs(AP.Conns[p]) do pcall(function() c:Disconnect() end) end AP.Conns[p]=nil end end
function APHook(p,ch)
	if p==LP then return end
	APClear(p); AP.Conns[p]={}
	local function onT(tr) if not AP.On or not IsSurv() then return end local a=tr.Animation; if a then a=a.AnimationId end if a and PARRY[a] then local my=GetRoot(LP.Character); local th=GetRoot(ch) if my and th and (my.Position-th.Position).Magnitude<=S.Parry.Range then APSpam() end end end
	local h=GetHum(ch); if not h then return end
	local an=h:FindFirstChildOfClass("Animator")
	if an then table.insert(AP.Conns[p],an.AnimationPlayed:Connect(onT))
	else
		local wc
		wc=h.ChildAdded:Connect(function(child) if child:IsA("Animator") then wc:Disconnect(); local l=AP.Conns[p]; if l then table.insert(l,child.AnimationPlayed:Connect(onT)) end end end)
		table.insert(AP.Conns[p],wc)
	end
	table.insert(AP.Conns[p],p.CharacterAdded:Connect(function(c2) task.wait(0.1) if AP.On then APHook(p,c2) end end))
end
function APTgl(on)
	AP.On=on; S.On.autoparry=on
	for k in pairs(AP.Conns) do APClear(k) end
	if on then
		for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then APHook(pl,pl.Character) end end
		AP.PA=Players.PlayerAdded:Connect(function(pl) AP.Conns[pl]={}; table.insert(AP.Conns[pl],pl.CharacterAdded:Connect(function(ch) task.wait(0.1) if AP.On then APHook(pl,ch) end end)) end)
		AP.PR=Players.PlayerRemoving:Connect(APClear)
	else
		if AP.PA then AP.PA:Disconnect(); AP.PA=nil end
		if AP.PR then AP.PR:Disconnect(); AP.PR=nil end
	end
end
FAKE={"rbxassetid://127096285501517","rbxassetid://109133187196613","rbxassetid://75939529748815","rbxassetid://126894569253341","rbxassetid://81793464499285","rbxassetid://123307242865945","rbxassetid://97915871372697"}
FAKE_NAMES={"Katana","Dagger","Shield","Iron Hand","Clock","Fish","Ledo Klenok"}
FP={Track=nil}
function FPPlay()
	local h=GetHum(LP.Character); if not h then return end
	if FP.Track then pcall(function() FP.Track:Stop() end) end
	local a=Instance.new("Animation"); a.AnimationId=FAKE[S.Parry.Anim] or FAKE[1]
	local ok,tr=pcall(function() return h:LoadAnimation(a) end)
	if ok and tr then FP.Track=tr; tr:Play() end
end
function FPTgl(on)
	S.On.fakeparry=on
	if on then FPPlay()
	else if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track=nil end end
end
function FPPulse() if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track=nil end FPPlay() task.delay(1,function() if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track=nil end end) end
AC={On=false,Conns={},Holding=false,PA=nil,PR=nil}
function ACPress()
	if AC.Holding then return end
	AC.Holding=true
	pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode.C,false,game) end)
	task.delay(1.5,function() pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.C,false,game) end); AC.Holding=false end)
end
function ACHook(p,ch)
	if p==LP then return end
	if not AC.Conns[p] then AC.Conns[p]={} end
	local h=GetHum(ch); if not h then return end
	local function onT(tr) if not AC.On then return end local a=tr.Animation if a and a.AnimationId=="rbxassetid://80411309607666" then ACPress() end end
	local an=h:FindFirstChildOfClass("Animator")
	if an then table.insert(AC.Conns[p],an.AnimationPlayed:Connect(onT)) end
	table.insert(AC.Conns[p],p.CharacterAdded:Connect(function(c2) task.wait(0.1) if AC.On then ACHook(p,c2) end end))
end
function ACTgl(on)
	AC.On=on; S.On.autocrouch=on
	for _,list in pairs(AC.Conns) do for _,c in ipairs(list) do pcall(function() c:Disconnect() end) end end
	AC.Conns={}
	if on then
		for _,pl in ipairs(Players:GetPlayers()) do if pl~=LP and pl.Character then ACHook(pl,pl.Character) end end
		AC.PA=Players.PlayerAdded:Connect(function(pl) AC.Conns[pl]={}; table.insert(AC.Conns[pl],pl.CharacterAdded:Connect(function(ch) task.wait(0.1) if AC.On then ACHook(pl,ch) end end)) end)
		AC.PR=Players.PlayerRemoving:Connect(function(pl) if AC.Conns[pl] then for _,c in ipairs(AC.Conns[pl]) do pcall(function() c:Disconnect() end) end AC.Conns[pl]=nil end end)
	else
		if AC.PA then AC.PA:Disconnect(); AC.PA=nil end
		if AC.PR then AC.PR:Disconnect(); AC.PR=nil end
		if AC.Holding then pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode.C,false,game) end); AC.Holding=false end
	end
end
ASC={On=false,Th=nil}
function ASCTgl(on)
	ASC.On=on; S.On.autoskill=on
	if ASC.Th then task.cancel(ASC.Th); ASC.Th=nil end
	if on then
		ASC.Th=task.spawn(function()
			while ASC.On do
				task.wait()
				local pg=LP:FindFirstChild("PlayerGui"); local pr=pg and pg:FindFirstChild("SkillCheckPromptGui"); local ck=pr and pr:FindFirstChild("Check")
				if ck and ck.Visible then
					local ln=ck:FindFirstChild("Line"); local gl=ck:FindFirstChild("Goal")
					if ln and gl then
						local rot=ln.Rotation
						if rot>=104+gl.Rotation and rot<=114+gl.Rotation then PressSpace(); repeat task.wait() until not ck.Visible or not ASC.On end
					end
				end
			end
		end)
	end
end
NS={On=false,Conn=nil}
function NSTgl(on)
	NS.On=on; S.On.noslow=on
	if NS.Conn then NS.Conn:Disconnect(); NS.Conn=nil end
	if on then
		local h=GetHum(LP.Character); if not h then return end
		h.WalkSpeed=16
		NS.Conn=h:GetPropertyChangedSignal("WalkSpeed"):Connect(function() if NS.On and h.WalkSpeed<16 then h.WalkSpeed=16 end end)
	end
end
MW={On=false,Conn=nil,Yaw=0}
function MWTgl(on)
	MW.On=on; S.On.moonwalk=on
	if MW.Conn then MW.Conn:Disconnect(); MW.Conn=nil end
	if on then
		local r=GetRoot(LP.Character); if r then local _,y,_=r.CFrame:ToEulerAnglesXYZ(); MW.Yaw=y end
		MW.Conn=RunService.RenderStepped:Connect(function(dt)
			if not MW.On then return end
			local c=LP.Character; if not c then return end
			local r=GetRoot(c); local h=GetHum(c)
			if r and h then
				h.AutoRotate=false
				if h.MoveDirection.Magnitude>0.1 then
					local dir=-h.MoveDirection; local wave=math.sin(tick()*35)*0.8
					local d=(math.atan2(-dir.X,-dir.Z)+wave-MW.Yaw)%(math.pi*2)
					if d>math.pi then d=d-(math.pi*2) end
					MW.Yaw=MW.Yaw+d*0.1*dt*60
					r.CFrame=CFrame.new(r.Position)*CFrame.Angles(0,MW.Yaw,0)
				end
			end
		end)
	else local h=GetHum(LP.Character); if h then h.AutoRotate=true end end
end
FLY={On=false,Conn=nil,BV=nil,BG=nil}
function FLYTgl(on)
	FLY.On=on; S.On.fly=on
	if FLY.Conn then FLY.Conn:Disconnect(); FLY.Conn=nil end
	if FLY.BV then FLY.BV:Destroy(); FLY.BV=nil end
	if FLY.BG then FLY.BG:Destroy(); FLY.BG=nil end
	if on then
		local c=LP.Character; if not c then return end
		local h=GetHum(c); local r=GetRoot(c); if not h or not r then return end
		h.PlatformStand=true
		FLY.BV=Instance.new("BodyVelocity"); FLY.BV.MaxForce=Vector3.new(40000,40000,40000); FLY.BV.Parent=r
		FLY.BG=Instance.new("BodyGyro"); FLY.BG.MaxTorque=Vector3.new(40000,40000,40000); FLY.BG.Parent=r
		FLY.Conn=RunService.Heartbeat:Connect(function()
			if not FLY.On or not FLY.BV then return end
			local cam=Workspace.CurrentCamera; local v=Vector3.new(0,0,0)
			if UIS:IsKeyDown(Enum.KeyCode.W) then v=v+cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then v=v-cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then v=v-cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then v=v+cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then v=v+Vector3.new(0,1,0) end
			if v.Magnitude>0 then FLY.BV.Velocity=v.Unit*60 end
			FLY.BG.CFrame=cam.CFrame
		end)
	else local h=GetHum(LP.Character); if h then h.PlatformStand=false end end
end
NC={On=false,Conn=nil}
function NCTgl(on)
	NC.On=on; S.On.noclip=on
	if NC.Conn then NC.Conn:Disconnect(); NC.Conn=nil end
	if on then NC.Conn=RunService.Stepped:Connect(function() local c=LP.Character if c then for _,v in pairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide=false end end end end) end
end
GM={On=false}
function GMTgl(on)
	GM.On=on; S.On.god=on
	local h=GetHum(LP.Character); if not h then return end
	if on then h.MaxHealth=1e999; h.Health=1e999 else h.MaxHealth=100; h.Health=100 end
end
DS={On=false,Conn=nil}
function DSTgl(on)
	DS.On=on; S.On.desync=on
	if DS.Conn then DS.Conn:Disconnect(); DS.Conn=nil end
	local r=GetRoot(LP.Character); if r then r.Anchored=false end
	if on then
		DS.Conn=RunService.Heartbeat:Connect(function(dt)
			if not DS.On then return end
			local c=LP.Character; local root=c and GetRoot(c); local h=GetHum(c)
			if not root or not h then return end
			root.Anchored=true
			local md=h.MoveDirection
			if md.Magnitude>0 then root.CFrame=root.CFrame+md*(h.WalkSpeed*dt) end
		end)
	end
end
SB={On=false,Mult=1.3}
function SBApply()
	local models={}
	if LP.Character then table.insert(models,LP.Character) end
	local w=Workspace:FindFirstChild(LP.Name)
	if w and w:IsA("Model") then table.insert(models,w) end
	for _,m in ipairs(models) do
		if SB.On then m:SetAttribute("speedboost",SB.Mult) else m:SetAttribute("speedboost",1) end
	end
	local h=GetHum(LP.Character)
	if h then if SB.On then h.WalkSpeed=16*SB.Mult else h.WalkSpeed=16 end end
end
function SBTgl(on) SB.On=on; S.On.speedboost=on; SBApply() end
CH={Part=nil,Weld=nil,Conn=nil}
function CHBuild()
	if CH.Part then CH.Part:Destroy() end
	if CH.Conn then CH.Conn:Disconnect() end
	local c=LP.Character; if not c then return end
	local hd=c:FindFirstChild("Head"); if not hd then return end
	local part=Instance.new("Part"); part.Size=Vector3.new(2,0.25,2); part.CanCollide=false; part.Material=Enum.Material.ForceField; part.Color=S.China.Color
	local mesh=Instance.new("SpecialMesh"); mesh.MeshId="rbxassetid://84530303562911"; mesh.TextureId="rbxassetid://89342168321397"; mesh.MeshType=Enum.MeshType.FileMesh; mesh.Parent=part
	local weld=Instance.new("Weld"); weld.Part0=hd; weld.Part1=part; weld.C0=CFrame.new(0,0.35,0); weld.Parent=part
	CH.Weld=weld; part.Parent=c; CH.Part=part
	local n=0
	CH.Conn=RunService.RenderStepped:Connect(function() if CH.Part and CH.Part.Parent then n=(n+3)%360; weld.C0=CFrame.new(0,0.35,0)*CFrame.Angles(0,math.rad(n),0); CH.Part.Color=S.China.Color end end)
end
function CHTgl(on)
	S.On.chinahat=on
	if on then CHBuild() else if CH.Conn then CH.Conn:Disconnect(); CH.Conn=nil end if CH.Part then CH.Part:Destroy(); CH.Part=nil end end
end
PC={Segs=nil,Anchor=nil,Label=nil,Conn=nil,On=false}
function PCBuild()
	if PC.Segs then for _,s in ipairs(PC.Segs) do s:Destroy() end end
	local segs={}
	for i=1,48 do local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CastShadow=false; p.Material=Enum.Material.Neon; p.Color=S.PC.Color; p.Transparency=0.2; p.Parent=Workspace; table.insert(segs,p) end
	PC.Segs=segs
	if PC.Anchor then PC.Anchor:Destroy() end
	local a=Instance.new("Part"); a.Anchored=true; a.CanCollide=false; a.Transparency=1; a.Size=Vector3.new(0.1,0.1,0.1); a.Parent=Workspace
	local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,200,0,32); bb.StudsOffset=Vector3.new(0,4,0); bb.AlwaysOnTop=true; bb.Parent=a
	local l=Instance.new("TextLabel",bb); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.TextStrokeTransparency=0; l.Font=Enum.Font.GothamBold; l.TextSize=14
	PC.Anchor=a; PC.Label=l
end
function PCUpd()
	if not (PC.On and IsSurv()) then
		if PC.Segs then for _,s in ipairs(PC.Segs) do s.Transparency=1 end end
		if PC.Anchor then PC.Anchor.Transparency=1 end
		return
	end
	local r=GetRoot(LP.Character); if not r then return end
	if not PC.Segs then PCBuild() end
	local rng=S.Parry.Range; local n=1e999
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character then
			local rr=GetRoot(pl.Character); local h=GetHum(pl.Character)
			if rr and h and h.Health>0 and IsKiller(pl) then local m=(rr.Position-r.Position).Magnitude if m<n then n=m end end
		end
	end
	local inR=n<=rng; local col=inR and Color3.fromRGB(255,50,50) or S.PC.Color
	local y=r.Position.Y-2.9; local sl=(2*math.pi*rng)/48
	for i,s in ipairs(PC.Segs) do
		local a=(i-1)/48*2*math.pi
		s.Size=Vector3.new(0.12,0.12,sl*1.15)
		s.CFrame=CFrame.new(r.Position.X+math.cos(a)*rng,y,r.Position.Z+math.sin(a)*rng)*CFrame.Angles(0,-a,0)
		s.Color=col; s.Transparency=0.2
	end
	if PC.Anchor then PC.Anchor.Transparency=1; PC.Anchor.CFrame=CFrame.new(r.Position.X,y,r.Position.Z) end
	if PC.Label then PC.Label.Text=string.format("r: %.1f | killer: %s",rng,n==1e999 and "---" or string.format("%.1f",n)); PC.Label.TextColor3=inR and Color3.fromRGB(255,80,80) or S.PC.Color end
end
function PCTgl(on)
	PC.On=on; S.On.parrycircle=on
	if PC.Conn then PC.Conn:Disconnect(); PC.Conn=nil end
	if PC.Segs then for _,s in ipairs(PC.Segs) do s:Destroy() end PC.Segs=nil end
	if PC.Anchor then PC.Anchor:Destroy(); PC.Anchor=nil end
	if on then PC.Conn=RunService.Heartbeat:Connect(PCUpd) end
end
function UpdateTint()
	if S.Tint.On then
		local cc=Lighting:FindFirstChild("GoatTint")
		if not cc then cc=Instance.new("ColorCorrectionEffect"); cc.Name="GoatTint"; cc.Parent=Lighting end
		cc.Enabled=true
		cc.TintColor=Color3.new(math.min(S.Tint.R/255*S.Tint.Br,1),math.min(S.Tint.G/255*S.Tint.Br,1),math.min(S.Tint.B/255*S.Tint.Br,1))
	else local cc=Lighting:FindFirstChild("GoatTint"); if cc then cc:Destroy() end end
end
KL={Loop=nil}
function KLTgl(on)
	S.On.killerlight=on
	if KL.Loop then task.cancel(KL.Loop); KL.Loop=nil end
	if on then
		KL.Loop=task.spawn(function()
			while S.On.killerlight do
				for _,pl in ipairs(Players:GetPlayers()) do
					if pl~=LP and pl.Character and (IsKiller(pl) or (pl.Team and pl.Team.Name:lower():find("killer"))) then
						local hd=pl.Character:FindFirstChild("Head"); local lt=hd and hd:FindFirstChild("RedSurfaceLight")
						if lt then lt.Color=S.KL.Color end
					end
				end
				task.wait(0.5)
			end
		end)
	end
end
RC={On=false,Conn=nil,HL=nil}
function RCTgl(on)
	RC.On=on; S.On.rainbow=on
	if RC.Conn then RC.Conn:Disconnect(); RC.Conn=nil end
	if RC.HL then RC.HL:Destroy(); RC.HL=nil end
	if on then
		RC.Conn=RunService.Heartbeat:Connect(function()
			if not RC.On then return end
			local c=LP.Character; if not c then return end
			local col=Color3.fromHSV((tick()%4)/4,1,1)
			if not RC.HL or not RC.HL.Parent then RC.HL=Instance.new("Highlight"); RC.HL.Name="GoatRainbow"; RC.HL.FillTransparency=0.4; RC.HL.OutlineTransparency=0 end
			RC.HL.Parent=c; RC.HL.Adornee=c; RC.HL.FillColor=col; RC.HL.OutlineColor=col
		end)
	end
end
CROSSGUI=nil
function ApplyVisuals()
	local L=Lighting; local V=S.VS
	local cc=L:FindFirstChild("GoatVS_CC")
	if V.RTX or V.Preset~="Default" or V.Tint~="Default" or V.Vivid or math.abs(V.Sat-0.25)>0.001 or math.abs(V.Con-0.12)>0.001 then
		if not cc then cc=Instance.new("ColorCorrectionEffect"); cc.Name="GoatVS_CC"; cc.Parent=L end
		local sat=V.Sat; local con=V.Con; local tint=Color3.new(1,1,1)
		if V.Vivid then sat=0.55; con=-0.35; tint=Color3.new(1,1,1) end
		if V.RTX then sat=sat+0.15; con=con+0.1 end
		if not V.Vivid then
			if V.Tint=="Warm" then tint=Color3.fromRGB(255,240,220)
			elseif V.Tint=="Cold" then tint=Color3.fromRGB(220,240,255) end
		end
		cc.Enabled=true; cc.Saturation=sat; cc.Contrast=con; cc.TintColor=tint
	else if cc then cc:Destroy() end end
	local bl=L:FindFirstChild("GoatVS_Bloom")
	if (V.Bloom or V.RTX) and V.BloomI>0 and not V.Vivid then
		if not bl then bl=Instance.new("BloomEffect"); bl.Name="GoatVS_Bloom"; bl.Parent=L end
		bl.Enabled=true; bl.Intensity=V.BloomI; bl.Size=V.BloomS; bl.Threshold=V.BloomT
	else if bl then bl:Destroy() end end
	local sr=L:FindFirstChild("GoatVS_Sun")
	if (V.SunRays or V.RTX or V.Vivid) and V.SunI>0 then
		if not sr then sr=Instance.new("SunRaysEffect"); sr.Name="GoatVS_Sun"; sr.Parent=L end
		sr.Enabled=true; sr.Intensity=V.SunI; sr.Spread=V.SunSpread or 0.7
	else if sr then sr:Destroy() end end
	local at=L:FindFirstChild("GoatVS_Atmo")
	if (V.Fog or V.RTX) and not V.Vivid then
		if not at then at=Instance.new("Atmosphere"); at.Name="GoatVS_Atmo"; at.Parent=L end
		at.Enabled=true; at.Density=V.Atmo; at.Offset=0.25; at.Color=V.FogColor; at.Decay=V.FogColor; at.Glare=0.4; at.Haze=0.1
	else if at then at:Destroy() end end
	if V.NoFog or V.Vivid then
		L.FogStart=999999; L.FogEnd=100000
	else
		L.FogStart=V.FogStart or 0
		L.FogEnd=V.FogEnd or 800
		if V.Fog then L.FogColor=V.FogColor end
	end
	local df=L:FindFirstChild("GoatVS_DOF")
	if V.DOF then
		if not df then df=Instance.new("DepthOfFieldEffect"); df.Name="GoatVS_DOF"; df.Parent=L end
		df.Enabled=true; df.FocusDistance=25; df.InFocusRadius=15; df.NearIntensity=0.1; df.FarIntensity=0.65
	else if df then df:Destroy() end end
	if V.Light then L.Ambient=V.LightColor; L.OutdoorAmbient=V.LightColor end
	if V.Time=="Custom" then L.ClockTime=V.ClockTime
	elseif V.Vivid then L.ClockTime=14.5
	elseif V.Time=="Day" then L.ClockTime=14
	elseif V.Time=="Sunset" then L.ClockTime=18
	elseif V.Time=="Sunrise" then L.ClockTime=6.5
	elseif V.Time=="Night" then L.ClockTime=0
	end
	if V.RTX then L.Brightness=2.5; L.ExposureCompensation=0.4; L.GlobalShadows=true end
	local cam=Workspace.CurrentCamera; if cam then cam.FieldOfView=V.FOV end
	if CROSSGUI then CROSSGUI:Destroy(); CROSSGUI=nil end
	if V.Crosshair then
		CROSSGUI=Instance.new("ScreenGui"); CROSSGUI.Name="GoatCross"; CROSSGUI.ResetOnSpawn=false
		pcall(function() CROSSGUI.Parent=(gethui and gethui()) or game:GetService("CoreGui") end)
		if not CROSSGUI.Parent then CROSSGUI.Parent=LP:WaitForChild("PlayerGui") end
		local holder=N("Frame",CROSSGUI,{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0),BackgroundTransparency=1})
		local sz=V.CrossSize; local th=math.max(1,math.floor(sz*0.2)); local gap=math.floor(sz*0.3)
		local col=V.CrossColor
		if V.CrossStyle=="Classic" or V.CrossStyle=="Tactical" then
			N("Frame",holder,{Size=UDim2.new(0,th,0,sz),Position=UDim2.new(0,-th/2,0,-sz-gap),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,th,0,sz),Position=UDim2.new(0,-th/2,0,gap),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,sz,0,th),Position=UDim2.new(0,-sz-gap,0,-th/2),BackgroundColor3=col,BorderSizePixel=0})
			N("Frame",holder,{Size=UDim2.new(0,sz,0,th),Position=UDim2.new(0,gap,0,-th/2),BackgroundColor3=col,BorderSizePixel=0})
		end
		if V.CrossStyle=="Dot" or V.CrossStyle=="DotCircle" then
			local d=N("Frame",holder,{Size=UDim2.new(0,th+2,0,th+2),Position=UDim2.new(0,-(th+2)/2,0,-(th+2)/2),BackgroundColor3=col,BorderSizePixel=0}); corner(d,5)
		end
		if V.CrossStyle=="Circle" or V.CrossStyle=="DotCircle" then
			local c=N("Frame",holder,{Size=UDim2.new(0,sz*2,0,sz*2),Position=UDim2.new(0,-sz,0,-sz),BackgroundTransparency=1,BorderSizePixel=0})
			local st=Instance.new("UIStroke",c); st.Color=col; st.Thickness=th
			local cn=Instance.new("UICorner",c); cn.CornerRadius=UDim.new(0.5,0)
		end
	end
end
function ApplyAtmo(name)
	local L=Lighting; local Terrain=Workspace:FindFirstChild("Terrain")
	for _,ch in pairs(L:GetChildren()) do
		if ch:IsA("Sky") or ch:IsA("BloomEffect") or ch:IsA("ColorCorrectionEffect") or ch:IsA("SunRaysEffect") or ch:IsA("DepthOfFieldEffect") or ch:IsA("Atmosphere") then ch:Destroy() end
	end
	if name=="Normal" then
		L.FogEnd=100000; L.FogStart=0; L.Brightness=1; L.ClockTime=14
		if Terrain then Terrain.WaterColor=Color3.fromRGB(45,105,135); Terrain.WaterReflectance=0.3; Terrain.WaterTransparency=0.3 end
		return
	end
	if name=="Void" then
		local Sky=Instance.new("Sky"); Sky.Name="VoidSky"
		Sky.SkyboxBk="rbxassetid://6444884337"; Sky.SkyboxDn="rbxassetid://6444884785"; Sky.SkyboxFt="rbxassetid://6444884337"; Sky.SkyboxLf="rbxassetid://6444884337"; Sky.SkyboxRt="rbxassetid://6444884337"; Sky.SkyboxUp="rbxassetid://6412503613"
		Sky.StarCount=2500; Sky.SunAngularSize=12; Sky.MoonAngularSize=11; Sky.Parent=L
		L.FogEnd=950; L.FogStart=80; L.FogColor=Color3.fromRGB(45,55,85)
		local Atm=Instance.new("Atmosphere"); Atm.Density=0.32; Atm.Offset=0.12; Atm.Color=Color3.fromRGB(50,60,100); Atm.Decay=Color3.fromRGB(25,30,55); Atm.Glare=0.22; Atm.Haze=1.6; Atm.Parent=L
		L.Ambient=Color3.fromRGB(70,75,110); L.OutdoorAmbient=Color3.fromRGB(90,95,140)
		L.Brightness=2.4; L.ClockTime=19.8; L.GeographicLatitude=30
		local Bl=Instance.new("BloomEffect"); Bl.Intensity=0.5; Bl.Size=22; Bl.Threshold=0.88; Bl.Parent=L
		local CC=Instance.new("ColorCorrectionEffect"); CC.Brightness=0.06; CC.Contrast=0.12; CC.Saturation=0.22; CC.TintColor=Color3.fromRGB(220,225,255); CC.Parent=L
		local SR=Instance.new("SunRaysEffect"); SR.Intensity=0.09; SR.Spread=0.65; SR.Parent=L
		local DOF=Instance.new("DepthOfFieldEffect"); DOF.FarIntensity=0.12; DOF.FocusDistance=50; DOF.InFocusRadius=35; DOF.NearIntensity=0.08; DOF.Parent=L
		if Terrain then Terrain.WaterColor=Color3.fromRGB(20,30,55); Terrain.WaterReflectance=0.35; Terrain.WaterTransparency=0.4 end
		return
	end
	if name=="Dark" then
		local Sky=Instance.new("Sky"); Sky.Name="DarkSky"
		Sky.SkyboxBk="rbxassetid://1546949252"; Sky.SkyboxDn="rbxassetid://1546949252"; Sky.SkyboxFt="rbxassetid://1546949252"; Sky.SkyboxLf="rbxassetid://1546949252"; Sky.SkyboxRt="rbxassetid://1546949252"; Sky.SkyboxUp="rbxassetid://1546949252"
		Sky.StarCount=100; Sky.SunAngularSize=5; Sky.MoonAngularSize=5; Sky.Parent=L
		L.FogEnd=500; L.FogStart=50; L.FogColor=Color3.fromRGB(10,10,15)
		local Atm=Instance.new("Atmosphere"); Atm.Density=0.5; Atm.Offset=0; Atm.Color=Color3.fromRGB(5,5,10); Atm.Decay=Color3.fromRGB(0,0,0); Atm.Glare=0; Atm.Haze=3; Atm.Parent=L
		L.Ambient=Color3.fromRGB(20,20,30); L.OutdoorAmbient=Color3.fromRGB(30,30,40)
		L.Brightness=0.8; L.ClockTime=0; L.GeographicLatitude=0
		local Bl=Instance.new("BloomEffect"); Bl.Intensity=0.3; Bl.Size=15; Bl.Threshold=0.9; Bl.Parent=L
		local CC=Instance.new("ColorCorrectionEffect"); CC.Brightness=-0.1; CC.Contrast=0.2; CC.Saturation=-0.3; CC.TintColor=Color3.fromRGB(180,180,200); CC.Parent=L
		if Terrain then Terrain.WaterColor=Color3.fromRGB(5,5,10); Terrain.WaterReflectance=0.1; Terrain.WaterTransparency=0.2 end
		return
	end
end
ATMO_NAMES={"Normal","Void","Dark"}
ATMO_IDX=1
DR={Track=nil}
function DRPlay()
	local h=GetHum(LP.Character); if not h then return end
	if DR.Track then pcall(function() DR.Track:Stop() end) end
	local a1=Instance.new("Animation"); a1.AnimationId="rbxassetid://99198989"
	local ok,tr=pcall(function() return h:LoadAnimation(a1) end)
	if ok and tr then DR.Track=tr; tr.Looped=true; tr:Play(); tr:AdjustSpeed(S.Droch.Speed) end
end
function DRTgl(on) S.On.drochka=on if on then DRPlay() else if DR.Track then pcall(function() DR.Track:Stop() end); DR.Track=nil end end end
BW={On=false,Saved=nil}
function BWPress()
	local r=GetRoot(LP.Character); if not r then return end
	if not BW.On then
		local best,bd=nil,S.BW.Range
		for _,d in ipairs(Workspace:GetDescendants()) do
			local n=d.Name:lower()
			if n:find("window") or n:find("vault") then
				local part=d:IsA("BasePart") and d or d:FindFirstChildWhichIsA("BasePart")
				if part then local m=(part.Position-r.Position).Magnitude; if m<bd then bd=m; best=part end end
			end
		end
		if not best then return end
		BW.Saved=r.CFrame
		r.CFrame=best.CFrame+Vector3.new(0,2,0)
		BW.On=true; S.On.blockwindow=true
	else
		if BW.Saved then r.CFrame=BW.Saved end
		BW.Saved=nil; BW.On=false; S.On.blockwindow=false
	end
end
function ClickTPDo(screenPos)
	local r=GetRoot(LP.Character); if not r then return end
	local target=nil
	local cam=Workspace.CurrentCamera
	if screenPos and cam then
		local ray=cam:ScreenPointToRay(screenPos.X,screenPos.Y)
		local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={LP.Character}
		local res=Workspace:Raycast(ray.Origin,ray.Direction*1000,params)
		target=res and res.Position or (ray.Origin+ray.Direction*80)
	else
		target=LP:GetMouse().Hit.Position
	end
	local d=(target-r.Position).Magnitude
	if d>S.CTP.Dist then target=r.Position+(target-r.Position).Unit*S.CTP.Dist end
	r.CFrame=CFrame.new(target+Vector3.new(0,2.5,0))
end
IH={On=false,Loop=nil}
function HealOnce()
	pcall(function()
		local rem=RS:FindFirstChild("Remotes"); local H=rem and rem:FindFirstChild("Healing"); local ev=H and H:FindFirstChild("HealEvent")
		local r=GetRoot(LP.Character)
		if ev and r then ev:FireServer(r,true) end
	end)
end
function IHTgl(on)
	IH.On=on; S.On.instantheal=on
	if IH.Loop then task.cancel(IH.Loop); IH.Loop=nil end
	if on then
		IH.Loop=task.spawn(function()
			while IH.On do
				local c=LP.Character; local h=GetHum(c)
				if c and h and h.Health>0 then
					local knocked=c:GetAttribute("Knocked")==true or LP:GetAttribute("Knocked")==true
					if knocked then
						h.Health=h.MaxHealth
						pcall(function() c:SetAttribute("Knocked",false) end)
						pcall(function() LP:SetAttribute("Knocked",false) end)
					end
				end
				task.wait(0.05)
			end
		end)
	end
end
CACHE={pallets={},vaults={}}
function ScanInteractables()
	local pals,vaults={},{}
	for _,d in ipairs(Workspace:GetDescendants()) do
		if d.Name=="Palletwrong" then table.insert(pals,d)
		elseif d:IsA("Model") then
			local n=d.Name:lower()
			if n:find("window") or n:find("vault") then
				local b,i,t=false,false,false
				for _,c in ipairs(d:GetDescendants()) do local cn=c.Name:lower() if cn=="bottom" then b=true elseif cn=="inviswall" then i=true elseif cn=="vaulttrigger" then t=true end end
				if b and i and t then table.insert(vaults,d) end
			end
		end
	end
	CACHE.pallets=pals; CACHE.vaults=vaults
end
function HoldRoot(sec)
	local r=GetRoot(LP.Character); if not r then return end
	local saved=r.CFrame
	task.spawn(function() local t0=tick() while tick()-t0<sec do if r.Parent then r.CFrame=saved end task.wait() end end)
end
function DropAllPallets()
	local rem=RS:FindFirstChild("Remotes"); local P=rem and rem:FindFirstChild("Pallet"); local ev=P and P:FindFirstChild("PalletDropEvent")
	if not ev then return end
	ScanInteractables()
	for _,pal in ipairs(CACHE.pallets) do
		for _,c in ipairs(pal:GetChildren()) do if c.Name=="PalletPoint" then pcall(function() ev:FireServer(c) end); break end end
	end
	HoldRoot(0.4)
end
RDP={On=false,Target=nil,HL=nil,Loop=nil}
function FindTargetPallet()
	local cam=Workspace.CurrentCamera
	ScanInteractables()
	if #CACHE.pallets==0 then return nil end
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Include; params.FilterDescendantsInstances=CACHE.pallets
	local res=cam:Raycast(cam.CFrame.Position,cam.CFrame.LookVector*500,params)
	if res then local p=res.Instance; while p and p~=Workspace do if p.Name=="Palletwrong" then return p end p=p.Parent end end
	return nil
end
function DropTargetPallet()
	local pal=RDP.Target or FindTargetPallet()
	if not pal then return end
	local rem=RS:FindFirstChild("Remotes"); local P=rem and rem:FindFirstChild("Pallet"); local ev=P and P:FindFirstChild("PalletDropEvent")
	if not ev then return end
	local point=pal:FindFirstChild("PalletPoint")
	if point then pcall(function() ev:FireServer(point) end); HoldRoot(0.3) end
end
function RDPTgl(on)
	RDP.On=on; S.On.remotedrop=on
	if RDP.Loop then task.cancel(RDP.Loop); RDP.Loop=nil end
	if RDP.HL then RDP.HL:Destroy(); RDP.HL=nil end
	RDP.Target=nil
	if on then
		RDP.Loop=task.spawn(function()
			while RDP.On do
				RDP.Target=FindTargetPallet()
				if RDP.Target then
					if not RDP.HL or not RDP.HL.Parent then RDP.HL=Instance.new("Highlight"); RDP.HL.Name="GoatRDP"; RDP.HL.FillColor=Color3.fromRGB(0,255,255); RDP.HL.OutlineColor=Color3.fromRGB(0,255,255); RDP.HL.FillTransparency=0.6 end
					RDP.HL.Adornee=RDP.Target
				elseif RDP.HL then RDP.HL.Adornee=nil end
				task.wait(0.1)
			end
		end)
	end
end
function BlockWP()
	local rem=RS:FindFirstChild("Remotes")
	local W=rem and rem:FindFirstChild("Window"); local VE=W and W:FindFirstChild("VaultEvent")
	local P=rem and rem:FindFirstChild("Pallet"); local PS=P and P:FindFirstChild("PalletSlideEvent")
	ScanInteractables()
	if VE then for _,v in ipairs(CACHE.vaults) do for _,d in ipairs(v:GetDescendants()) do if d.Name=="VaultTrigger" then pcall(function() VE:FireServer(d,true) end) end end end end
	if PS then for _,pal in ipairs(CACHE.pallets) do for _,d in ipairs(pal:GetDescendants()) do if d.Name=="PalletPointSlide" or d.Name:find("Slide") then pcall(function() PS:FireServer(d,true) end) end end end end
end
function UnlockWP()
	local rem=RS:FindFirstChild("Remotes")
	local W=rem and rem:FindFirstChild("Window"); local VC=W and W:FindFirstChild("VaultCompleteEvent")
	local P=rem and rem:FindFirstChild("Pallet"); local PCn=P and P:FindFirstChild("PalletSlideCompleteEvent")
	ScanInteractables()
	if VC then for _,v in ipairs(CACHE.vaults) do for _,d in ipairs(v:GetDescendants()) do if d.Name=="VaultTrigger" then pcall(function() VC:FireServer(d,false) end) end end end end
	if PCn then for _,pal in ipairs(CACHE.pallets) do for _,d in ipairs(pal:GetDescendants()) do if d.Name=="PalletPointSlide" or d.Name:find("Slide") then pcall(function() PCn:FireServer(d) end) end end end end
end
function GenBuff()
	local c=LP.Character; local r=c and GetRoot(c); if not r then return end
	local gens={}
	local Map=Workspace:FindFirstChild("Map")
	if Map then for _,d in ipairs(Map:GetDescendants()) do if d:IsA("Model") and d.Name:lower():find("generator") then table.insert(gens,d) end end end
	if #gens==0 then for _,d in ipairs(Workspace:GetDescendants()) do if d:IsA("Model") and d.Name=="Generator" then table.insert(gens,d) end end end
	local best,bd=nil,1e9
	for _,g in ipairs(gens) do local p=g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart") if p then local m=(p.Position-r.Position).Magnitude if m<bd then bd=m; best=g end end end
	if not best or bd>35 then return end
	local rem=RS:FindFirstChild("Remotes"); local G=rem and rem:FindFirstChild("Generator"); local ev=G and G:FindFirstChild("RepairEvent")
	if not ev then return end
	local pts={}
	for _,ch in ipairs(best:GetChildren()) do if ch.Name:lower():find("generatorpoint") or ch.Name:lower():find("point") then table.insert(pts,ch) end end
	table.sort(pts,function(a,b) return a.Name<b.Name end)
	if #pts>=2 then
		pcall(function() ev:FireServer(pts[2],true) end); task.wait(0.2)
		pcall(function() ev:FireServer(pts[1],true) end); task.wait(0.2)
		pcall(function() ev:FireServer(pts[1],false) end)
	elseif #pts==1 then
		pcall(function() ev:FireServer(pts[1],true) end); task.wait(0.2)
		pcall(function() ev:FireServer(pts[1],false) end)
	end
end
function AutoUnhook()
	local c=LP.Character; local r=c and GetRoot(c); local h=GetHum(c)
	if not r or not h then return end
	local hooked=c:GetAttribute("IsHooked")==true or LP:GetAttribute("IsHooked")==true or (tonumber(c:GetAttribute("HookedProgress")) or 0)>0
	if not hooked then return end
	local saved=r.CFrame
	local rem=RS:FindFirstChild("Remotes")
	local Car=rem and rem:FindFirstChild("Carry")
	local selfUn=Car and Car:FindFirstChild("SelfUnHookEvent")
	local killer=nil
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character and (IsKiller(pl) or (pl.Team and pl.Team.Name:lower():find("killer"))) then killer=pl.Character break end
	end
	if killer then
		local kr=GetRoot(killer)
		if kr then
			local t0=tick()
			while tick()-t0<60 do
				local charge=tonumber(c:GetAttribute("anticampCharge")) or tonumber(LP:GetAttribute("anticampCharge")) or 0
				if charge>=100 then break end
				if r.Parent then r.CFrame=CFrame.new(kr.Position-Vector3.new(0,16,0)) end
				task.wait(0.06)
			end
		end
	end
	if r.Parent then r.CFrame=saved end
	task.wait(0.2)
	if selfUn then pcall(function() selfUn:FireServer() end) end
end

-- ===================== DBD HUD ICONS (rbx priority, then http) =====================
DBDH={On=false,Loop=nil,Orig={},Icons={}}
HUD_DEFS={
Healthy={rbx="", urls={
"https://www.dropbox.com/scl/fi/tkdvl8hv4supk25pksj7f/3d3yth.png?rlkey=cn2s8u9bjtfl596oo9vqa2ov7&st=sdbcs9pc&dl=1",
"https://files.catbox.moe/3d3yth.png"}},
Injured={rbx="", urls={
"https://www.dropbox.com/scl/fi/hmjn93oqkofu6qm64ra5g/dj03nn.png?rlkey=pwa7gyja0i2lv86711ozn00sz&st=00vp3w9y&dl=1",
"https://files.catbox.moe/dj03nn.png"}},
Knocked={rbx="", urls={
"https://www.dropbox.com/scl/fi/ys7aenxrophei7qxvykgw/yjkbwq.png?rlkey=vytohdnrqwv5u8dexxufzji48&st=36389vx9&dl=1",
"https://files.catbox.moe/yjkbwq.png"}},
Hooked={rbx="", urls={
"https://www.dropbox.com/scl/fi/9tp2khew0roiuqp1n6y2v/ivumkl.png?rlkey=tdz82ksji33fpks62bbu297yy&st=i07wnkxc&dl=1",
"https://files.catbox.moe/ivumkl.png"}},
Carried={rbx="", urls={
"https://www.dropbox.com/scl/fi/ca7o7of16fqrl37w63bt9/jgozjg.png?rlkey=779b759nz089vsuwbttsab9pt&st=p21mj2o6&dl=1",
"https://files.catbox.moe/jgozjg.png"}},
Chased={rbx="", urls={
"https://www.dropbox.com/scl/fi/fromzf9crr7hs6qfh8k6y/him9yt.png?rlkey=5t32852xljc7vx4g024h6aq8d&st=t5x42bdi&dl=1",
"https://files.catbox.moe/him9yt.png"}},
Gen={rbx="", urls={
"https://www.dropbox.com/scl/fi/i933njt3259vfyk90u1tl/731qb0.png?rlkey=6gj01osv0x9c510gkc727yk34&st=mmqarsxn&dl=1",
"https://files.catbox.moe/731qb0.png"}},
}
local function isPNG(s) return type(s)=="string" and #s>8 and s:byte(1)==137 and s:sub(2,4)=="PNG" end
function LoadHUDIcons()
    if next(DBDH.Icons) then return true end
    local gca=getcustomasset or getsynasset
    local okCount=0
    for k,def in pairs(HUD_DEFS) do
        if def.rbx and def.rbx~="" then
            DBDH.Icons[k]="rbxassetid://"..def.rbx; okCount=okCount+1
        else
            local fname="GoatDBDH_"..k..".png"
            if writefile and isfile and gca then
                if isfile(fname) then
                    local okc,content=pcall(readfile,fname)
                    if not (okc and isPNG(content)) then pcall(function() if delfile then delfile(fname) end end) end
                end
                if not isfile(fname) then
                    for _,u in ipairs(def.urls) do
                        local b=httpGetBody(u)
                        if isPNG(b) then pcall(function() writefile(fname,b) end); break end
                    end
                end
                if isfile(fname) then
                    local okc,content=pcall(readfile,fname)
                    if okc and isPNG(content) then pcall(function() DBDH.Icons[k]=gca(fname); okCount=okCount+1 end) end
                end
            end
        end
    end
    return okCount>0
end
function PlayerState(pl)
	local c=pl.Character; if not c then return nil end
	if c:GetAttribute("IsCarried")==true or pl:GetAttribute("IsCarried")==true then return "Carried" end
	if c:GetAttribute("IsHooked")==true or pl:GetAttribute("IsHooked")==true then return "Hooked" end
	local hp=c:GetAttribute("HookedProgress"); if type(hp)=="number" and hp>0 then return "Hooked" end
	if c:GetAttribute("Knocked")==true or pl:GetAttribute("Knocked")==true then return "Knocked" end
	if c:GetAttribute("IsChased")==true or pl:GetAttribute("IsChased")==true then return "Chased" end
	local h=GetHum(c)
	if h and h.Health<h.MaxHealth then return "Injured" end
	return "Healthy"
end
function DBDHTgl(on)
	DBDH.On=on; S.On.dbdhud=on
	if DBDH.Loop then task.cancel(DBDH.Loop); DBDH.Loop=nil end
	if on then
		if not LoadHUDIcons() then return end
		DBDH.Loop=task.spawn(function()
			while DBDH.On do
				pcall(function()
					local pg=LP:FindFirstChildOfClass("PlayerGui"); if not pg then return end
					for _,sg in ipairs(pg:GetChildren()) do
						if sg:IsA("ScreenGui") then
							local sn=sg.Name:lower()
							if sn:find("survivor") or sn:find("slasher") or sn:find("killer") then
								for _,img in ipairs(sg:GetDescendants()) do
									if img:IsA("ImageLabel") then
										local par=img.Parent
										local rowName=par and par.Name:lower() or ""
										if rowName:match("^survivor%d+") or rowName=="survivor" then
											local pname=nil
											for _,t in ipairs(par:GetDescendants()) do if t:IsA("TextLabel") and t.Text~="" then pname=t.Text break end end
											if pname then
												for _,pl in ipairs(Players:GetPlayers()) do
													if pl.Name==pname or pl.DisplayName==pname or pname:lower():find(pl.Name:lower(),1,true) or pname:lower():find(pl.DisplayName:lower(),1,true) then
														local st=PlayerState(pl)
														local icon=st and DBDH.Icons[st]
														if icon and img.Image~=icon then
															if DBDH.Orig[img]==nil then DBDH.Orig[img]=img.Image end
															img.Image=icon
														end
													end
												end
											end
										end
									end
								end
								local gen=sg:FindFirstChild("Gen",true) or sg:FindFirstChild("Generators",true)
								if gen then
									local img=gen:FindFirstChildWhichIsA("ImageLabel",true)
									if img and DBDH.Icons.Gen and img.Image~=DBDH.Icons.Gen then
										if DBDH.Orig[img]==nil then DBDH.Orig[img]=img.Image end
										img.Image=DBDH.Icons.Gen
									end
								end
							end
						end
					end
				end)
				task.wait(0.2)
			end
		end)
	else
		for img,orig in pairs(DBDH.Orig) do pcall(function() if img.Parent then img.Image=orig end end) end
		DBDH.Orig={}
	end
end
-- ==================================================================================

function IsVeilSpearmode()
	local c=LP.Character
	if not c then return false end
	return c:GetAttribute("spearmode")==true or LP:GetAttribute("spearmode")==true
end
function SolveProj(origin,targetPos,targetVel,speed,grav)
	local t=(targetPos-origin).Magnitude/speed
	for i=1,6 do
		local pred=targetPos+targetVel*t
		t=(pred-origin).Magnitude/speed
	end
	local pred=targetPos+targetVel*t
	local dir=(pred-origin+Vector3.new(0,0.5*grav*t*t,0)).Unit
	return dir,t
end
function SpearOrigin()
	local cam=Workspace.CurrentCamera
	local c=LP.Character
	local hd=c and c:FindFirstChild("Head")
	if hd then return hd.CFrame:PointToWorldSpace(Vector3.new(1.35,0.34,-2.51)) end
	return cam.CFrame.Position
end
TRAJ={On=false,Noclip=false,Folder=nil,Parts={},Conn=nil}
function TrajBuild()
	if TRAJ.Folder then TRAJ.Folder:Destroy() end
	TRAJ.Folder=Instance.new("Folder"); TRAJ.Folder.Name="GoatTraj"; TRAJ.Folder.Parent=Workspace
	TRAJ.Parts={}
	for i=1,60 do
		local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.CastShadow=false; p.Material=Enum.Material.Neon; p.Size=Vector3.new(0.1,0.1,1); p.Transparency=0.3; p.Color=S.Traj.Color; p.Parent=TRAJ.Folder
		table.insert(TRAJ.Parts,p)
	end
end
function TrajUpdate()
	if not (TRAJ.On and IsVeilSpearmode()) then
		if TRAJ.Folder then TRAJ.Folder.Parent=nil end
		return
	end
	if not TRAJ.Folder or not TRAJ.Folder.Parent then TrajBuild() end
	local cam=Workspace.CurrentCamera
	local origin=SpearOrigin()
	local dir=cam.CFrame.LookVector
	local speed=150; local grav=98
	local vel=dir*speed
	local pos=origin
	local dt=0.035
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances={LP.Character,TRAJ.Folder}
	for step=1,60 do
		local newVel=vel+Vector3.new(0,-grav,0)*dt
		local mid=pos+(vel+newVel)*0.5*dt
		local seg=mid-pos
		if not TRAJ.Noclip and seg.Magnitude>0.001 then
			local hit=Workspace:Raycast(pos,seg,params)
			if hit then
				local p=TRAJ.Parts[step]
				if p then
					local hs=hit.Position-pos
					p.Transparency=0; p.Color=S.Traj.Color
					p.Size=Vector3.new(0.1,0.1,math.max(0.1,hs.Magnitude))
					p.CFrame=CFrame.lookAt(pos+hs*0.5,hit.Position)
				end
				for j=step+1,60 do if TRAJ.Parts[j] then TRAJ.Parts[j].Transparency=1 end end
				return
			end
		end
		local p=TRAJ.Parts[step]
		if p and seg.Magnitude>0.01 then
			p.Transparency=0.3; p.Color=S.Traj.Color
			p.Size=Vector3.new(0.1,0.1,seg.Magnitude)
			p.CFrame=CFrame.lookAt(pos+seg*0.5,mid)
		end
		pos=mid; vel=newVel
	end
end
function TrajTgl(on)
	TRAJ.On=on; S.On.trajectory=on
	if TRAJ.Conn then TRAJ.Conn:Disconnect(); TRAJ.Conn=nil end
	if TRAJ.Folder then TRAJ.Folder:Destroy(); TRAJ.Folder=nil end
	if on then TrajBuild(); TRAJ.Conn=RunService.RenderStepped:Connect(TrajUpdate) end
end
VAIM={On=false,Key="None",Target=nil}
function VaimFind()
	local cam=Workspace.CurrentCamera
	local best,bd=nil,1e9
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl~=LP and pl.Character then
			local r=GetRoot(pl.Character); local h=GetHum(pl.Character)
			if r and h and h.Health>0 then
				local team=pl.Team
				local isSurv=team and (team.Name=="Survivors" or team.Name:lower():find("survivor"))
				if isSurv or not team then
					local m=(r.Position-cam.CFrame.Position).Magnitude
					if m<bd then bd=m; best=pl end
				end
			end
		end
	end
	return best
end
function VaimUpdate()
	if not (VAIM.On and IsVeilSpearmode()) then VAIM.Target=nil; return end
	local held=MOBILE_AIM_HOLD==true
	if not held then
		if VAIM.Key~="None" then
			local kc=Enum.KeyCode[VAIM.Key]
			if kc then held=UIS:IsKeyDown(kc) end
		else
			held=UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
		end
	end
	if not held then VAIM.Target=nil; return end
	local best=VaimFind()
	VAIM.Target=best
	if not best then return end
	local r=GetRoot(best.Character)
	if not r then return end
	local vel=r.AssemblyLinearVelocity or Vector3.new(0,0,0)
	local cam=Workspace.CurrentCamera
	local dir,t=SolveProj(SpearOrigin(),r.Position,vel,150,98)
	local goal=CFrame.lookAt(cam.CFrame.Position,cam.CFrame.Position+dir)
	cam.CFrame=cam.CFrame:Lerp(goal,0.35)
end
SSILENT={On=false,Hooked=false,Orig=nil}
function SSilentHook()
	if SSILENT.Hooked then return true end
	if not hookmetamethod or not getnamecallmethod or not newcclosure then return false end
	SSILENT.Orig=hookmetamethod(game,"__namecall",newcclosure(function(self,...)
		local args={...}
		if getnamecallmethod()=="FireServer" and typeof(self)=="Instance" and self.Name=="Spearthrow" and SSILENT.On and IsVeilSpearmode() and VAIM.Target then
			local r=GetRoot(VAIM.Target.Character)
			if r then
				local vel=r.AssemblyLinearVelocity or Vector3.new(0,0,0)
				local dir,t=SolveProj(SpearOrigin(),r.Position,vel,150,98)
				local newArgs={}
				for i,a in ipairs(args) do
					if typeof(a)=="Vector3" and math.abs(a.Magnitude-1)<0.05 then newArgs[i]=dir else newArgs[i]=a end
				end
				return SSILENT.Orig(self,unpack(newArgs))
			end
		end
		return SSILENT.Orig(self,...)
	end))
	SSILENT.Hooked=true
	return true
end
function SSilentTgl(on)
	SSILENT.On=on; S.On.spearsilent=on
	if on then SSilentHook() end
end
MASKS={"Alex","Tony","Brandon","Rabbit","Cobra","Richter","Normal"}
MASK_SEL="Normal"
function ApplyMask(name)
	local rem=RS:FindFirstChild("Remotes")
	local K=rem and rem:FindFirstChild("Killers")
	local M=K and K:FindFirstChild("Masked")
	if not M then return false end
	pcall(function() local D=M:FindFirstChild("Deactivatepower"); if D then D:FireServer() end end)
	if name=="Normal" then return true end
	task.wait(0.5)
	pcall(function() local A=M:FindFirstChild("Activatepower"); if A then A:FireServer(name) end end)
	return true
end
function IsFirstPerson()
	if LP.CameraMode==Enum.CameraMode.LockFirstPerson then return true end
	local cam=Workspace.CurrentCamera
	local r=GetRoot(LP.Character)
	if cam and r then return (cam.CFrame.Position-r.Position).Magnitude<2 end
	return false
end
function ApplyCursor()
	if MOBILE then return end
	if EMOTE_WHEEL_OPEN then
		UIS.MouseIconEnabled=true
		UIS.MouseBehavior=Enum.MouseBehavior.Default
		return
	end
	if Main and Main.Visible then
		UIS.MouseIconEnabled=false
		UIS.MouseBehavior=Enum.MouseBehavior.Default
		return
	end
	UIS.MouseIconEnabled=false
	if IsFirstPerson() then UIS.MouseBehavior=Enum.MouseBehavior.LockCenter else UIS.MouseBehavior=Enum.MouseBehavior.LockCurrent end
end

-- ================= YOUR EMOTE WHEEL (VERBATIM LOGIC + cursor state) =================
EMOTE_WHEEL={Built=false, Bind="None"}
function BuildEmoteWheel()
	if EMOTE_WHEEL.Built then return end
	EMOTE_WHEEL.Built=true
	if _G.EmoteWheelActive then if _G.EmoteWheelCleanup then _G.EmoteWheelCleanup() end end
	_G.EmoteWheelActive=true
	local player=LP
	local playerGui=player:WaitForChild("PlayerGui")
	local character=player.Character or player.CharacterAdded:Wait()
	local humanoid=character:WaitForChild("Humanoid")
	local animator=humanoid:WaitForChild("Animator")
	local WHEEL_RADIUS=180
	local BUTTON_SIZE=90
	local NUM_SLOTS=8
	local emoteData={
		[1]={id="rbxassetid://74705617908505",name="Backflip"},
		[2]={id="rbxassetid://140625405103474",name="Oneplays"},
		[3]={id="rbxassetid://134677515695156",name="Mannrobics"},
		[4]={id="rbxassetid://138303785534052",name="Schadenfreude"},
		[5]={id="rbxassetid://114593021219597",name="Floating Rest"},
		[6]={id="rbxassetid://81054496834622",name="Rambunctious"},
		[7]={id="rbxassetid://75586690784894",name="Griddy"},
		[8]={id="rbxassetid://122615684039119",name="Source"}
	}
	local oldGui=playerGui:FindFirstChild("EmoteWheelUI")
	if oldGui then oldGui:Destroy() end
	local screenGui=Instance.new("ScreenGui")
	screenGui.Name="EmoteWheelUI"; screenGui.ResetOnSpawn=false; screenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; screenGui.IgnoreGuiInset=true; screenGui.Parent=playerGui
	local mainFrame=Instance.new("Frame")
	mainFrame.Size=UDim2.new(0,500,0,500); mainFrame.Position=UDim2.new(0.5,-250,0.5,-250); mainFrame.BackgroundTransparency=1; mainFrame.Visible=false; mainFrame.Active=true; mainFrame.Parent=screenGui
	local centerBtn=Instance.new("TextButton")
	centerBtn.Size=UDim2.new(0,120,0,120); centerBtn.Position=UDim2.new(0.5,-60,0.5,-60); centerBtn.BackgroundColor3=Color3.fromRGB(40,40,50); centerBtn.Text="X"; centerBtn.Font=Enum.Font.GothamBold; centerBtn.TextSize=48; centerBtn.TextColor3=Color3.fromRGB(255,255,255); centerBtn.AutoButtonColor=false; centerBtn.Parent=mainFrame
	local centerCorner=Instance.new("UICorner"); centerCorner.CornerRadius=UDim.new(1,0); centerCorner.Parent=centerBtn
	local centerStroke=Instance.new("UIStroke"); centerStroke.Color=Color3.fromRGB(255,255,255); centerStroke.Transparency=0.7; centerStroke.Thickness=2; centerStroke.Parent=centerBtn
	local currentTrack=nil; local activeSlotIndex=nil; local hoveredSlotIndex=nil; local slots={}; local isOpen=false
	local connections={}
	local function connectSignal(signal,func) local conn=signal:Connect(func); table.insert(connections,conn); return conn end
	local function stopAnim()
		if currentTrack then currentTrack:Stop(); currentTrack=nil end
		if activeSlotIndex and slots[activeSlotIndex] then TweenService:Create(slots[activeSlotIndex],TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(60,60,70)}):Play() end
		activeSlotIndex=nil
	end
	local function playAnim(animId,slotIndex,emoteName)
		local anim=Instance.new("Animation"); anim.AnimationId=animId
		if currentTrack then currentTrack:Stop() end
		currentTrack=animator:LoadAnimation(anim); currentTrack:Play()
		if activeSlotIndex and activeSlotIndex~=slotIndex and slots[activeSlotIndex] then TweenService:Create(slots[activeSlotIndex],TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(60,60,70)}):Play() end
		activeSlotIndex=slotIndex
		if slots[slotIndex] then TweenService:Create(slots[slotIndex],TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(120,80,200)}):Play() end
	end
	for i=1,NUM_SLOTS do
		local angle=(i-1)*(360/NUM_SLOTS); local rad=math.rad(angle)
		local x=math.cos(rad)*WHEEL_RADIUS; local y=math.sin(rad)*WHEEL_RADIUS
		local hasEmote=emoteData[i]~=nil
		local slotBtn=Instance.new("TextButton")
		slotBtn.Size=UDim2.new(0,BUTTON_SIZE,0,BUTTON_SIZE); slotBtn.Position=UDim2.new(0.5,x-BUTTON_SIZE/2,0.5,y-BUTTON_SIZE/2)
		slotBtn.BackgroundColor3=hasEmote and Color3.fromRGB(60,60,70) or Color3.fromRGB(30,30,35)
		slotBtn.BackgroundTransparency=hasEmote and 0.4 or 0.7
		slotBtn.Text=hasEmote and emoteData[i].name or ""; slotBtn.TextColor3=Color3.fromRGB(255,255,255); slotBtn.Font=Enum.Font.GothamSemibold; slotBtn.TextSize=12; slotBtn.TextWrapped=true; slotBtn.AutoButtonColor=false; slotBtn.Parent=mainFrame
		local slotCorner=Instance.new("UICorner"); slotCorner.CornerRadius=UDim.new(0,12); slotCorner.Parent=slotBtn
		local slotStroke=Instance.new("UIStroke"); slotStroke.Color=Color3.fromRGB(255,255,255); slotStroke.Transparency=hasEmote and 0.9 or 0.95; slotStroke.Thickness=1; slotStroke.Parent=slotBtn
		if hasEmote then
			connectSignal(slotBtn.MouseButton1Click,function() playAnim(emoteData[i].id,i,emoteData[i].name) end)
			connectSignal(slotBtn.MouseEnter,function() hoveredSlotIndex=i; if activeSlotIndex~=i then TweenService:Create(slotBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.2,Size=UDim2.new(0,BUTTON_SIZE+5,0,BUTTON_SIZE+5)}):Play(); TweenService:Create(slotStroke,TweenInfo.new(0.15),{Transparency=0.5}):Play() end end)
			connectSignal(slotBtn.MouseLeave,function() if hoveredSlotIndex==i then hoveredSlotIndex=nil end; if activeSlotIndex~=i then TweenService:Create(slotBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.4,Size=UDim2.new(0,BUTTON_SIZE,0,BUTTON_SIZE)}):Play(); TweenService:Create(slotStroke,TweenInfo.new(0.15),{Transparency=0.9}):Play() end end)
		end
		slots[i]=slotBtn
	end
	connectSignal(centerBtn.MouseButton1Click,stopAnim)
	local heartbeatConn
	local function forceUnlockMouse() UIS.MouseBehavior=Enum.MouseBehavior.Default end
	local function openWheel()
		if isOpen then return end
		isOpen=true; EMOTE_WHEEL_OPEN=true
		heartbeatConn=RunService.Heartbeat:Connect(forceUnlockMouse); mainFrame.Visible=true
		pcall(ApplyCursor)
	end
	local function closeWheel()
		if not isOpen then return end
		isOpen=false
		if heartbeatConn then heartbeatConn:Disconnect(); heartbeatConn=nil end
		if hoveredSlotIndex and emoteData[hoveredSlotIndex] then playAnim(emoteData[hoveredSlotIndex].id,hoveredSlotIndex,emoteData[hoveredSlotIndex].name) end
		mainFrame.Visible=false; hoveredSlotIndex=nil
		EMOTE_WHEEL_OPEN=false
		pcall(ApplyCursor)
	end
	EMOTE_WHEEL.Toggle=function() if isOpen then closeWheel() else openWheel() end end
	_G.EmoteWheelCleanup=function()
		_G.EmoteWheelActive=false
		if heartbeatConn then heartbeatConn:Disconnect() end
		for _,conn in ipairs(connections) do conn:Disconnect() end
		connections={}; stopAnim(); if screenGui then screenGui:Destroy() end
		EMOTE_WHEEL.Built=false
		EMOTE_WHEEL_OPEN=false
		pcall(ApplyCursor)
	end
end
-- ====================================================================

-- ================= MOBILE FLOATING CONTROLS =================
local function CreateMobileControls()
	if not MOBILE then return end
	local msg=Instance.new("ScreenGui"); msg.Name="GoatMobileControls"; msg.ResetOnSpawn=false; msg.IgnoreGuiInset=true; msg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	pcall(function() msg.Parent=(gethui and gethui()) or game:GetService("CoreGui") end)
	if not msg.Parent then msg.Parent=LP:WaitForChild("PlayerGui") end
	local function makeFloatBtn(text,color,size,pos,onclick)
		local b=Instance.new("TextButton",msg)
		b.Size=UDim2.fromOffset(size,size); b.Position=pos; b.BackgroundColor3=color; b.BackgroundTransparency=0.08; b.Text=text; b.Font=Enum.Font.GothamBlack; b.TextSize=math.max(12,math.floor(size*0.42)); b.TextColor3=Color3.fromRGB(255,255,255); b.AutoButtonColor=false; b.Active=true; b.ZIndex=60
		corner(b,math.floor(size/2))
		local st=Instance.new("UIStroke",b); st.Color=Color3.fromRGB(255,255,255); st.Transparency=0.65; st.Thickness=1.2
		local drag=false; local sp=Vector2.new(); local fp=UDim2.new(); local moved=false
		b.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true; sp=i.Position; fp=b.Position; moved=false end end)
		UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then local d=i.Position-sp; if d.Magnitude>8 then moved=true end; b.Position=UDim2.new(fp.X.Scale,fp.X.Offset+d.X,fp.Y.Scale,fp.Y.Offset+d.Y) end end)
		UIS.InputEnded:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1) then drag=false; if not moved then pcall(onclick) end end end)
		return b
	end
	makeFloatBtn("🐐",Color3.fromRGB(236,72,153),54,UDim2.new(0,10,0.45,-27),function()
		if Main then Main.Visible=not Main.Visible; ApplyCursor() end
	end)
	local cam=Workspace.CurrentCamera
	local sw=cam and cam.ViewportSize.X or 360
	local dockW=math.clamp(sw-20,240,310)
	local btnSize=math.clamp(math.floor((dockW-24)/7),28,38)
	local dock=Instance.new("Frame",msg); dock.Name="GoatBindDock"; dock.Size=UDim2.fromOffset(dockW,btnSize+14); dock.Position=UDim2.new(0,8,1,-108); dock.BackgroundColor3=Color3.fromRGB(16,19,26); dock.BackgroundTransparency=0.18; dock.BorderSizePixel=0; dock.Visible=false; dock.ZIndex=59; dock.Active=true; corner(dock,12)
	local dl=Instance.new("UIListLayout",dock); dl.FillDirection=Enum.FillDirection.Horizontal; dl.HorizontalAlignment=Enum.HorizontalAlignment.Center; dl.VerticalAlignment=Enum.VerticalAlignment.Center; dl.Padding=UDim.new(0,3)
	local function addDockBtn(txt,col,fn)
		local b=Instance.new("TextButton",dock); b.Size=UDim2.fromOffset(btnSize,btnSize); b.BackgroundColor3=col; b.BackgroundTransparency=0.12; b.Text=txt; b.Font=Enum.Font.GothamBold; b.TextSize=math.max(8,math.floor(btnSize*0.25)); b.TextColor3=Color3.fromRGB(255,255,255); b.AutoButtonColor=false; b.ZIndex=60; corner(b,math.floor(btnSize/2))
		local st=Instance.new("UIStroke",b); st.Color=Color3.fromRGB(255,255,255); st.Transparency=0.72; st.Thickness=1
		b.Activated:Connect(function() pcall(fn) end)
		return b
	end
	addDockBtn("EM",Color3.fromRGB(120,80,200),function() BuildEmoteWheel(); if EMOTE_WHEEL.Toggle then EMOTE_WHEEL.Toggle() end end)
	addDockBtn("FP",Color3.fromRGB(59,130,246),function() FPPulse() end)
	addDockBtn("MW",Color3.fromRGB(34,197,94),function() MWTgl(not MW.On) end)
	addDockBtn("TP",Color3.fromRGB(255,150,0),function() S.CTP.On=not S.CTP.On; if utilStatus then utilStatus.Set("Click TP: "..(S.CTP.On and "on" or "off")) end end)
	addDockBtn("PAL",Color3.fromRGB(0,220,255),function() DropTargetPallet() end)
	addDockBtn("UN",Color3.fromRGB(239,68,68),function() AutoUnhook() end)
	local aim=Instance.new("TextButton",dock); aim.Size=UDim2.fromOffset(btnSize,btnSize); aim.BackgroundColor3=Color3.fromRGB(255,105,180); aim.BackgroundTransparency=0.12; aim.Text="AIM"; aim.Font=Enum.Font.GothamBold; aim.TextSize=math.max(8,math.floor(btnSize*0.25)); aim.TextColor3=Color3.fromRGB(255,255,255); aim.AutoButtonColor=false; aim.Active=true; aim.ZIndex=60; corner(aim,math.floor(btnSize/2))
	local ast=Instance.new("UIStroke",aim); ast.Color=Color3.fromRGB(255,255,255); ast.Transparency=0.72; ast.Thickness=1
	local function aimDown(i) if i and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1) then MOBILE_AIM_HOLD=true; aim.BackgroundColor3=Color3.fromRGB(255,255,255); aim.TextColor3=Color3.fromRGB(236,72,153) end end
	local function aimUp(i) if i and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1) then MOBILE_AIM_HOLD=false; aim.BackgroundColor3=Color3.fromRGB(255,105,180); aim.TextColor3=Color3.fromRGB(255,255,255) end end
	aim.InputBegan:Connect(aimDown); aim.InputEnded:Connect(aimUp); UIS.InputEnded:Connect(aimUp)
	local dockOpen=false
	makeFloatBtn("⚡",Color3.fromRGB(59,130,246),48,UDim2.new(0,10,1,-64),function() dockOpen=not dockOpen; dock.Visible=dockOpen end)
end
-- ============================================================

HomePage=AddTab("Home") VisualPage=AddTab("Visual") SurvPage=AddTab("Survivor") KillerPage=AddTab("Killer") FunPage=AddTab("Fun") SetPage=AddTab("Settings")
hs1=AddSection(HomePage,"Dashboard")
welc=N("Frame",hs1,{Size=UDim2.new(1,0,0,64),BackgroundColor3=C_BOX,BorderSizePixel=0,ZIndex=6}); corner(welc,8)
N("TextLabel",welc,{Size=UDim2.new(1,-74,0,20),Position=UDim2.new(0,10,0,10),BackgroundTransparency=1,Text="Welcome back, "..(LP.DisplayName or LP.Name).."!",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C_ACC,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
sessT=N("TextLabel",welc,{Size=UDim2.new(1,-74,0,16),Position=UDim2.new(0,10,0,32),BackgroundTransparency=1,Text="Active Session - Executor: loading...",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_DIM,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
av=N("Frame",welc,{Size=UDim2.new(0,44,0,44),Position=UDim2.new(1,-54,0.5,-22),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=7}); corner(av,22)
avI=N("ImageLabel",av,{Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundTransparency=1,Image="",ZIndex=8}); corner(avI,20)
pcall(function() local ok,url=Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100); if ok and url then avI.Image=url end end)
EXEC="Unknown"
pcall(function()
	local f=nil
	if type(identify_executor)=="function" then f=identify_executor elseif type(getexecutorname)=="function" then f=getexecutorname elseif type(getexecutor)=="function" then f=getexecutor end
	if f then local v=f(); if type(v)=="string" and v~="" then EXEC=v end end
end)
LIVE=math.random(8,22)
function SetSess() sessT.Text="Active Session - Executor: "..EXEC.." | Live Users: "..LIVE end
SetSess()
task.spawn(function() while true do task.wait(20) LIVE=math.clamp(LIVE+math.random(-2,2),5,30) SetSess() end end)
hs2=AddSection(HomePage,"Player Statistics")
chipHolder=N("Frame",hs2,{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,ZIndex=6})
N("UIListLayout",chipHolder,{Padding=UDim.new(0,6),FillDirection=Enum.FillDirection.Horizontal})
selected=LP chips={}
card=N("Frame",hs2,{Size=UDim2.new(1,0,0,86),BackgroundColor3=C_BOX,BorderSizePixel=0,ZIndex=6}); corner(card,8)
cName=N("TextLabel",card,{Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text="",Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=C_ACC,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
cL1=N("TextLabel",card,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0,10,0,30),BackgroundTransparency=1,Text="Level: 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
cL2=N("TextLabel",card,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0,10,0,48),BackgroundTransparency=1,Text="Screws: 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
cL3=N("TextLabel",card,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0,10,0,66),BackgroundTransparency=1,Text="Gears: 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
cR1=N("TextLabel",card,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0.5,10,0,30),BackgroundTransparency=1,Text="Selected Killer: None",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
cR2=N("TextLabel",card,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0.5,10,0,48),BackgroundTransparency=1,Text="Killer Chance: 0%",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
function RefreshCard()
	local pl=selected or LP
	if not pl or not pl.Parent then pl=LP; selected=LP end
	cName.Text=(pl.DisplayName or pl.Name).." (@"..pl.Name..")"
	cL1.Text="Level: "..GetNum(pl,"Level",0)
	cL2.Text="Screws: "..GetNum(pl,"Screws",0)
	cL3.Text="Gears: "..GetNum(pl,"Gears",0)
	cR1.Text="Selected Killer: "..GetStr(pl,"SelectedKiller","None")
	cR2.Text="Killer Chance: "..GetNum(pl,"KillerChance",0).."%"
end
function BuildChips()
	for _,c in ipairs(chips) do pcall(function() c:Destroy() end) end
	chips={}
	for _,pl in ipairs(Players:GetPlayers()) do
		local isSel=(pl==selected)
		local b=N("TextButton",chipHolder,{Size=UDim2.new(0,0,0,24),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=isSel and C_ACC or C_ROW,BorderSizePixel=0,Text="  "..(pl.DisplayName or pl.Name).."  ",Font=Enum.Font.Gotham,TextSize=11,TextColor3=isSel and Color3.fromRGB(10,12,16) or C_TXT,AutoButtonColor=false,ZIndex=7})
		corner(b,12)
		table.insert(chips,b)
		b.Activated:Connect(function() selected=pl; BuildChips(); RefreshCard() end)
	end
end
hs3=AddSection(HomePage,"Session & Lifetime Earnings")
earn=N("Frame",hs3,{Size=UDim2.new(1,0,0,52),BackgroundColor3=C_BOX,BorderSizePixel=0,ZIndex=6}); corner(earn,8)
e1=N("TextLabel",earn,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0,10,0,8),BackgroundTransparency=1,Text="Screws (Session): 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
e2=N("TextLabel",earn,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0,10,0,28),BackgroundTransparency=1,Text="Screws (Lifetime): 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
e3=N("TextLabel",earn,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0.5,10,0,8),BackgroundTransparency=1,Text="Gears (Session): 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
e4=N("TextLabel",earn,{Size=UDim2.new(0.5,-12,0,16),Position=UDim2.new(0.5,10,0,28),BackgroundTransparency=1,Text="Gears (Lifetime): 0",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
LF_FILE="Goatlose_Lifetime.json"
life={Screws=0,Gears=0}
pcall(function()
	if readfile and isfile and isfile(LF_FILE) then
		local d=HttpService:JSONDecode(readfile(LF_FILE))
		if type(d)=="table" then life.Screws=d.Screws or 0; life.Gears=d.Gears or 0 end
	end
end)
startS=GetNum(LP,"Screws",0) startG=GetNum(LP,"Gears",0)
function RefreshEarn()
	local cs=GetNum(LP,"Screws",0); local cg=GetNum(LP,"Gears",0)
	local ds=math.max(0,cs-startS); local dg=math.max(0,cg-startG)
	e1.Text="Screws (Session): "..ds
	e2.Text="Screws (Lifetime): "..(life.Screws+ds)
	e3.Text="Gears (Session): "..dg
	e4.Text="Gears (Lifetime): "..(life.Gears+dg)
end
task.spawn(function()
	while true do
		task.wait(3)
		RefreshCard(); RefreshEarn()
		pcall(function()
			if writefile then
				writefile(LF_FILE,HttpService:JSONEncode({Screws=life.Screws+math.max(0,GetNum(LP,"Screws",0)-startS),Gears=life.Gears+math.max(0,GetNum(LP,"Gears",0)-startG)}))
			end
		end)
	end
end)
Players.PlayerAdded:Connect(BuildChips)
Players.PlayerRemoving:Connect(function(pl) if selected==pl then selected=LP end BuildChips() end)
BuildChips(); RefreshCard(); RefreshEarn()
e1s=AddSection(VisualPage,"ESP")
AddToggle(e1s,"ESP",false,function(v) S.ESP.On=v; RefreshESP() end)
AddColor(e1s,"Survivor Color",Color3.fromRGB(0,255,0),function(c) S.ESP.Surv=c; RefreshESP() end)
AddColor(e1s,"Killer Color",Color3.fromRGB(255,0,0),function(c) S.ESP.Kill=c; RefreshESP() end)
AddToggle(e1s,"Killer Fill",false,function(v) S.ESP.Fill=v; RefreshESP() end)
AddColor(e1s,"Fill Color",Color3.fromRGB(255,0,0),function(c) S.ESP.FillColor=c; RefreshESP() end)
AddToggle(e1s,"CS2 ESP",false,CS2Tgl)
AddColor(e1s,"CS2 Color",Color3.fromRGB(0,255,0),function(c) S.ESP.CS2C=c end)
AddToggle(e1s,"Generator ESP",false,function(v) S.ESP.Gen=v; RefreshObjESP() end)
AddColor(e1s,"Gen Color",Color3.fromRGB(0,255,255),function(c) S.ESP.GenC=c; RefreshObjESP() end)
AddToggle(e1s,"Pallet ESP",false,function(v) S.ESP.Pallet=v; RefreshObjESP() end)
AddColor(e1s,"Pallet Color",Color3.fromRGB(127,0,255),function(c) S.ESP.PalC=c; RefreshObjESP() end)
e2s=AddSection(VisualPage,"World")
AddToggle(e2s,"China Hat",false,CHTgl)
AddColor(e2s,"China Hat Color",Color3.fromRGB(255,0,255),function(c) S.China.Color=c; if CH.Part then CH.Part.Color=c end end)
AddToggle(e2s,"World Tint",false,function(v) S.Tint.On=v; UpdateTint() end)
AddSlider(e2s,"Red",0,255,255,0,function(v) S.Tint.R=v; UpdateTint() end)
AddSlider(e2s,"Green",0,255,200,0,function(v) S.Tint.G=v; UpdateTint() end)
AddSlider(e2s,"Blue",0,255,200,0,function(v) S.Tint.B=v; UpdateTint() end)
AddSlider(e2s,"Brightness",0,5,1,1,function(v) S.Tint.Br=v; UpdateTint() end)
AddToggle(e2s,"Killer Light",false,KLTgl)
AddColor(e2s,"Killer Light Color",Color3.fromRGB(255,255,0),function(c) S.KL.Color=c end)
AddToggle(e2s,"Rainbow Character",false,RCTgl)
AddToggle(e2s,"DBD HUD",false,DBDHTgl)
atmoBtn=AddButton(e2s,"Atmosphere: Normal",function()
	ATMO_IDX=ATMO_IDX%#ATMO_NAMES+1
	local n=ATMO_NAMES[ATMO_IDX]
	atmoBtn.Text="Atmosphere: "..n
	ApplyAtmo(n)
end)

-- ===================== VISUALS SUITE (hypnosis-style) =====================
VIS_SUB_TABS={"Пресеты","Кастомизация","Свет и Тени"}
VIS_SUB_CUR="Пресеты"
VIS_SUB_FRAMES={}
visSubBtns={}
function SelectVisSub(n)
	VIS_SUB_CUR=n
	for k,f in pairs(VIS_SUB_FRAMES) do f.Visible=(k==n) end
	for _,b in ipairs(visSubBtns) do
		if b.Name==n then b.BackgroundColor3=C_BOX; b.TextColor3=Color3.fromRGB(255,255,255) else b.BackgroundColor3=C_SIDE; b.TextColor3=C_DIM end
	end
end
function MakeVisSubFrame(parent,name)
	local fr=N("Frame",parent,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5})
	N("UIListLayout",fr,{Padding=UDim.new(0,4)})
	VIS_SUB_FRAMES[name]=fr
	return fr
end
e3s=AddSection(VisualPage,"Ultimate Visuals Engine")
local vsHead=N("Frame",e3s,{Size=UDim2.new(1,0,0,26),BackgroundColor3=C_BOX,BorderSizePixel=0,ZIndex=6}); corner(vsHead,6)
N("TextLabel",vsHead,{Size=UDim2.new(0.6,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text="🎨 ULTIMATE VISUALS ENGINE",Font=Enum.Font.GothamBlack,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
local subRow=N("Frame",e3s,{Size=UDim2.new(1,0,0,30),BackgroundTransparency=1,ZIndex=6})
N("UIListLayout",subRow,{Padding=UDim.new(0,4),FillDirection=Enum.FillDirection.Horizontal})
for _,name in ipairs(VIS_SUB_TABS) do
	local icon = name=="Пресеты" and "⚙️" or (name=="Кастомизация" and "▦" or "☀️")
	local lbl = icon.."  "..name
	local b=N("TextButton",subRow,{Size=UDim2.new(1/3,-3,1,0),BackgroundColor3=C_SIDE,AutoButtonColor=false,Text=lbl,Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=C_DIM,ZIndex=7}); corner(b,6)
	b.Name=name; table.insert(visSubBtns,b)
	b.Activated:Connect(function() SelectVisSub(name) end)
end
local visContainer=N("Frame",e3s,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=5})
N("UIListLayout",visContainer,{Padding=UDim.new(0,0)})

-- TAB 1: ПРЕСЕТЫ
local tabPresets=MakeVisSubFrame(visContainer,"Пресеты")
N("TextLabel",tabPresets,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Быстрые пресеты графики:",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
local presetNames={"Vivid Life (дефолт)","RTX Booster","Cinematic","Clean Daylight","Cyberpunk Neon","Warm Sunset","Moonlight","Default"}
for _,pn in ipairs(presetNames) do
	local pb=N("TextButton",tabPresets,{Size=UDim2.new(1,0,0,26),BackgroundColor3=C_ROW,AutoButtonColor=false,Text=pn,Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7}); corner(pb,6)
	pb.Activated:Connect(function()
		S.VS.Preset=pn
		if pn=="Vivid Life (дефолт)" then
			S.VS.Vivid=true; S.VS.Sat=0.55; S.VS.Con=-0.35; S.VS.BloomI=0; S.VS.SunI=0.45; S.VS.FogEnd=100000; S.VS.ClockTime=14.5; S.VS.RTX=false
		elseif pn=="RTX Booster" then
			S.VS.Vivid=false; S.VS.RTX=true; S.VS.Sat=0.45; S.VS.Con=0.25; S.VS.BloomI=0.9; S.VS.SunI=0.55; S.VS.ClockTime=13
		elseif pn=="Cinematic" then
			S.VS.Vivid=false; S.VS.DOF=true; S.VS.Sat=0.3; S.VS.Con=0.2; S.VS.BloomI=0.6; S.VS.ClockTime=17
		elseif pn=="Clean Daylight" then
			S.VS.Vivid=false; S.VS.Sat=0.2; S.VS.Con=0.1; S.VS.Tint="Default"; S.VS.ClockTime=14
		elseif pn=="Cyberpunk Neon" then
			S.VS.Vivid=false; S.VS.Sat=0.55; S.VS.Con=0.25; S.VS.Tint="Cold"; S.VS.BloomI=1.1; S.VS.ClockTime=22
		elseif pn=="Warm Sunset" then
			S.VS.Vivid=false; S.VS.Sat=0.3; S.VS.Con=0.14; S.VS.Tint="Warm"; S.VS.ClockTime=18
		elseif pn=="Moonlight" then
			S.VS.Vivid=false; S.VS.Sat=0.15; S.VS.Con=0.2; S.VS.Tint="Cold"; S.VS.ClockTime=0
		else
			S.VS.Vivid=false; S.VS.RTX=false; S.VS.DOF=false; S.VS.Sat=0.25; S.VS.Con=0.12; S.VS.BloomI=0.8; S.VS.SunI=0.1; S.VS.FogEnd=800; S.VS.ClockTime=14
		end
		ApplyVisuals()
		SelectVisSub("Кастомизация")
	end)
end

-- TAB 2: КАСТОМИЗАЦИЯ
local tabCustom=MakeVisSubFrame(visContainer,"Кастомизация")
local function makeValBox(parent,text,val,min,max,onChange)
	local row=N("Frame",parent,{Size=UDim2.new(1,0,0,28),BackgroundColor3=C_ROW,BorderSizePixel=0,ZIndex=6}); corner(row,6)
	N("TextLabel",row,{Size=UDim2.new(0.55,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=text,Font=Enum.Font.Gotham,TextSize=11,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
	local vb=N("TextBox",row,{Size=UDim2.new(0.45,-10,0,20),Position=UDim2.new(0.55,0,0.5,-10),BackgroundColor3=Color3.fromRGB(20,40,70),BorderSizePixel=0,Text=tostring(val),PlaceholderText="0",Font=Enum.Font.GothamSemibold,TextSize=11,TextColor3=Color3.fromRGB(120,180,255),ZIndex=7}); corner(vb,4)
	vb.ClearTextOnFocus=false
	vb.Focused:Connect(function() vb.Text="" end)
	vb.FocusLost:Connect(function()
		local n=tonumber(vb.Text)
		if not n then vb.Text=tostring(min); onChange(min); return end
		n=math.clamp(n,min,max); vb.Text=tostring(n); onChange(n)
	end)
	return {Set=function(x) vb.Text=tostring(x) end}
end
N("TextLabel",tabCustom,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Цветокоррекция",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
satBox=makeValBox(tabCustom,"Сочность (Saturation)",S.VS.Sat,-1,1,function(v) S.VS.Sat=v; ApplyVisuals() end)
conBox=makeValBox(tabCustom,"Контраст (Contrast)",S.VS.Con,-1,1,function(v) S.VS.Con=v; ApplyVisuals() end)
N("TextLabel",tabCustom,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Свечение и Лучи",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
bloomBox=makeValBox(tabCustom,"Bloom (Свечение)",S.VS.BloomI,0,3,function(v) S.VS.BloomI=v; S.VS.Bloom=(v>0); ApplyVisuals() end)
sunBox=makeValBox(tabCustom,"Sun Rays (Лучи солнца)",S.VS.SunI,0,1,function(v) S.VS.SunI=v; S.VS.SunRays=(v>0); ApplyVisuals() end)
N("TextLabel",tabCustom,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Окружение",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
fogEndBox=makeValBox(tabCustom,"Дальность тумана (FogEnd)",S.VS.FogEnd,0,100000,function(v) S.VS.FogEnd=v; S.VS.NoFog=(v>=99999); ApplyVisuals() end)
clockBox=makeValBox(tabCustom,"Время суток (ClockTime)",S.VS.ClockTime,0,24,function(v) S.VS.ClockTime=v; S.VS.Time="Custom"; ApplyVisuals() end)
fovBox=makeValBox(tabCustom,"Поле зрения (FOV)",S.VS.FOV,70,160,function(v) S.VS.FOV=v; ApplyVisuals() end)

-- TAB 3: СВЕТ И ТЕНИ
local tabLight=MakeVisSubFrame(visContainer,"Свет и Тени")
N("TextLabel",tabLight,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Ambient & Outdoor",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
AddToggle(tabLight,"Custom Ambient Light",S.VS.Light,function(v) S.VS.Light=v; ApplyVisuals() end)
AddColor(tabLight,"Ambient Color",S.VS.LightColor,function(c) S.VS.LightColor=c; ApplyVisuals() end)
N("TextLabel",tabLight,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Fog",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
AddToggle(tabLight,"No Fog",S.VS.NoFog,function(v) S.VS.NoFog=v; if v then S.VS.FogEnd=100000 elseif fogEndBox then fogEndBox.Set(800) end; ApplyVisuals() end)
AddToggle(tabLight,"Custom Fog",S.VS.Fog,function(v) S.VS.Fog=v; ApplyVisuals() end)
AddColor(tabLight,"Fog Color",S.VS.FogColor,function(c) S.VS.FogColor=c; ApplyVisuals() end)
AddSlider(tabLight,"Fog Start",0,500,S.VS.FogStart,0,function(v) S.VS.FogStart=v; ApplyVisuals() end)
N("TextLabel",tabLight,{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="Shadows & Extras",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C_TXT,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6})
AddToggle(tabLight,"Global Shadows",true,function(v) Lighting.GlobalShadows=v end)
AddToggle(tabLight,"Cinematic Depth of Field",S.VS.DOF,function(v) S.VS.DOF=v; ApplyVisuals() end)
AddToggle(tabLight,"RTX Graphics Booster",S.VS.RTX,function(v) S.VS.RTX=v; ApplyVisuals() end)
AddDropdown(tabLight,"Color Tint Preset",{"Default","Warm","Cold"},S.VS.Tint,function(v) S.VS.Tint=v; ApplyVisuals() end)
AddDropdown(tabLight,"Time of Day",{"Default","Day","Sunset","Sunrise","Night","Custom"},S.VS.Time,function(v)
	S.VS.Time=v
	local map={Default=14,Day=14,Sunset=18,Sunrise=6.5,Night=0}
	if v~="Custom" and clockBox then S.VS.ClockTime=map[v] or 14; clockBox.Set(S.VS.ClockTime) end
	ApplyVisuals()
end)
SelectVisSub("Пресеты")
-- ============================================================================

s1=AddSection(SurvPage,"Parry")
AddSlider(s1,"Parry Range",2,25,10,1,function(v) S.Parry.Range=v end)
AddToggle(s1,"Auto Parry (stop)",false,APTgl)
AddToggle(s1,"Fake Parry",false,FPTgl)
animBtn=AddButton(s1,"Fake Parry Anim: Katana",function()
	S.Parry.Anim=(S.Parry.Anim%#FAKE)+1
	animBtn.Text="Fake Parry Anim: "..FAKE_NAMES[S.Parry.Anim]
	if FP.Track then pcall(function() FP.Track:Stop() end); FP.Track=nil; if S.On.fakeparry then FPPlay() end end
end)
AddKeybind(s1,"Fake Parry Key","None",FPPulse)
AddToggle(s1,"Auto Skillcheck",false,ASCTgl)
AddToggle(s1,"Parry Circle",false,PCTgl)
AddColor(s1,"Circle Color",Color3.fromRGB(0,255,80),function(c) S.PC.Color=c end)
s2=AddSection(SurvPage,"Movement")
AddToggle(s2,"No Slowdown",false,NSTgl)
AddToggle(s2,"Auto Moonwalk",false,MWTgl)
AddKeybind(s2,"Moonwalk Key","None",function() MWTgl(not MW.On) end)
AddToggle(s2,"Auto Crouch",false,ACTgl)
AddToggle(s2,"Fly",false,FLYTgl)
AddToggle(s2,"NoClip",false,NCTgl)
AddToggle(s2,"GodMode",false,GMTgl)
AddToggle(s2,"Desync",false,DSTgl)
AddToggle(s2,"Speed Boost",false,SBTgl)
AddSlider(s2,"Speed Multiplier",1,3,1.3,1,function(v) SB.Mult=v; if SB.On then SBApply() end end)
s3=AddSection(SurvPage,"Utility")
utilStatus=AddLabel(s3,"Click TP: off")
AddKeybind(s3,"Block Window","None",BWPress)
AddSlider(s3,"Block Range",2,30,14,0,function(v) S.BW.Range=v end)
AddKeybind(s3,"Click TP","None",function() S.CTP.On=not S.CTP.On; utilStatus.Set("Click TP: "..(S.CTP.On and "on" or "off")) end)
AddSlider(s3,"Click TP Dist",5,200,50,0,function(v) S.CTP.Dist=v end)
AddToggle(s3,"Instant Heal",false,IHTgl)
AddButton(s3,"Heal (remote)",HealOnce)
AddToggle(s3,"Remote Drop Pallet",false,RDPTgl)
AddKeybind(s3,"Drop Target Pallet","None",DropTargetPallet)
AddButton(s3,"Drop All Pallets",DropAllPallets)
AddButton(s3,"Block Windows & Pallets",BlockWP)
AddButton(s3,"Unlock Windows & Pallets",UnlockWP)
AddButton(s3,"Gen Buff",GenBuff)
AddButton(s3,"Auto Unhook",AutoUnhook)
k1=AddSection(KillerPage,"VEIL")
AddToggle(k1,"Veil Spear Trajectory",false,TrajTgl)
AddToggle(k1,"Trajectory Noclip",false,function(v) TRAJ.Noclip=v; S.On.trajnoclip=v end)
AddColor(k1,"Trajectory Color",Color3.fromRGB(0,240,255),function(c) S.Traj.Color=c end)
AddToggle(k1,"Enable Veil Spear Aimbot",false,function(v) VAIM.On=v; S.On.veilaim=v end)
AddKeybind(k1,"Aimbot Hold Key","None",function() end)
AddToggle(k1,"Spear Silent Aim",false,SSilentTgl)
k2=AddSection(KillerPage,"MASKED")
AddDropdown(k2,"Custom Mask",MASKS,"Normal",function(v) MASK_SEL=v end)
AddButton(k2,"Apply Mask",function() ApplyMask(MASK_SEL) end)
f1=AddSection(FunPage,"Fun")
AddToggle(f1,"Drochka (walk ok)",false,DRTgl)
AddSlider(f1,"Hand Speed",0.5,6,2.5,1,function(v) S.Droch.Speed=v; if DR.Track then DR.Track:AdjustSpeed(v) end end)
AddKeybind(f1,"Emote Wheel Key","None",function()
	BuildEmoteWheel()
	if EMOTE_WHEEL.Toggle then EMOTE_WHEEL.Toggle() end
end)

-- ===================== CONFIG LIST (real save/load) =====================
c1=AddSection(SetPage,"Configs")
local cfgStatus=AddLabel(c1,"configs: loading...")
local cfgSelLabel=AddLabel(c1,"selected: none")
local cfgList=N("ScrollingFrame",c1,{Size=UDim2.new(1,0,0,140),BackgroundColor3=C_ROW,BorderSizePixel=0,ScrollBarThickness=3,AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=6}); corner(cfgList,6)
N("UIListLayout",cfgList,{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})
N("UIPadding",cfgList,{PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4),PaddingLeft=UDim.new(0,4),PaddingRight=UDim.new(0,4)})
local function refreshConfigList()
	for _,ch in ipairs(cfgList:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
	local names=getConfigNames()
	if CFG_SELECTED=="" and #names>0 then CFG_SELECTED=names[1] end
	cfgSelLabel.Set("selected: "..(CFG_SELECTED~="" and CFG_SELECTED or "none"))
	cfgStatus.Set("configs: "..tostring(#names))
	for i,name in ipairs(names) do
		local sel=(name==CFG_SELECTED)
		local b=N("TextButton",cfgList,{Size=UDim2.new(1,0,0,26),BackgroundColor3=sel and C_ACC or C_BOX,Text=name,Font=Enum.Font.GothamSemibold,TextSize=12,TextColor3=sel and Color3.fromRGB(10,12,16) or C_TXT,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,LayoutOrder=i,ZIndex=7})
		corner(b,5)
		b.Activated:Connect(function() CFG_SELECTED=name; refreshConfigList() end)
	end
end
local function saveConfigTo(name)
	name=safeCfgName(name); if name=="" then name=nextAutoCfgName() end
	ensureCfgFolder()
	local data={controls={},special={Atmo=ATMO_IDX,ParryAnim=S.Parry.Anim}}
	for k,c in pairs(CFG_CONTROLS) do pcall(function() data.controls[k]={type=c.type,value=c.get()} end) end
	local ok=pcall(function() writefile(cfgPath(name),HttpService:JSONEncode(data)) end)
	if ok then addCfgIndex(name); CFG_SELECTED=name; refreshConfigList(); cfgStatus.Set("saved: "..name) else cfgStatus.Set("save failed") end
end
local function loadConfigFrom(name)
	name=safeCfgName(name)
	if name=="" then cfgStatus.Set("select config"); return end
	local ok,raw=pcall(function() return readfile(cfgPath(name)) end)
	if not ok or not raw then cfgStatus.Set("load failed: "..name); return end
	local dok,data=pcall(function() return HttpService:JSONDecode(raw) end)
	if not dok or type(data)~="table" then cfgStatus.Set("bad json"); return end
	if type(data.controls)=="table" then
		for k,v in pairs(data.controls) do
			local c=CFG_CONTROLS[k]
			if c and type(v)=="table" and v.type==c.type then pcall(function() c.set(v.value) end) end
		end
	end
	if type(data.special)=="table" then
		if data.special.Atmo then ATMO_IDX=math.clamp(tonumber(data.special.Atmo) or ATMO_IDX,1,#ATMO_NAMES); if atmoBtn then atmoBtn.Text="Atmosphere: "..ATMO_NAMES[ATMO_IDX] end; pcall(function() ApplyAtmo(ATMO_NAMES[ATMO_IDX]) end) end
		if data.special.ParryAnim then S.Parry.Anim=math.clamp(tonumber(data.special.ParryAnim) or S.Parry.Anim,1,#FAKE); if animBtn then animBtn.Text="Fake Parry Anim: "..FAKE_NAMES[S.Parry.Anim] end end
	end
	cfgStatus.Set("loaded: "..name)
end
local function deleteConfig(name)
	name=safeCfgName(name); if name=="" then return end
	pcall(function() if delfile and isfile and isfile(cfgPath(name)) then delfile(cfgPath(name)) end end)
	removeCfgIndex(name); if CFG_SELECTED==name then CFG_SELECTED="" end
	refreshConfigList(); cfgStatus.Set("deleted: "..name)
end
AddButton(c1,"Refresh List",function() refreshConfigList() end)
AddButton(c1,"Load Selected",function() loadConfigFrom(CFG_SELECTED) end)
AddButton(c1,"Save Selected",function() if CFG_SELECTED=="" then saveConfigTo(nextAutoCfgName()) else saveConfigTo(CFG_SELECTED) end end)
AddButton(c1,"Save New Auto",function() saveConfigTo(nextAutoCfgName()) end)
AddButton(c1,"Delete Selected",function() deleteConfig(CFG_SELECTED) end)
refreshConfigList()
-- =======================================================================

m1=AddSection(SetPage,"Menu")
AddLabel(m1,"RightShift / Esc - open/close (PC)")
AddLabel(m1,"🐐 button opens/closes menu (Mobile)")
AddLabel(m1,"Cursor locked except Emote Wheel")
AddLabel(m1,"All binds default None")
SelectTab("Home")
ApplyBg()
CreateMobileControls()
Main.Visible=true
ApplyCursor()
RunService.RenderStepped:Connect(function() if VAIM.On then VaimUpdate() end end)
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode==Enum.KeyCode.Escape and not BINDING then
		if Main.Visible then Main.Visible=false; ApplyCursor() end
		return
	end
	if input.KeyCode==Enum.KeyCode.RightShift then Main.Visible=not Main.Visible; ApplyCursor(); return end
	if S.CTP.On and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
		ClickTPDo(Vector2.new(input.Position.X,input.Position.Y))
	end
end)
LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	RefreshESP()
	if MW.On then MWTgl(true) end
	if S.On.chinahat then CHBuild() end
	if S.On.drochka then DRPlay() end
	BW.On=false; BW.Saved=nil
	if SB.On then SBApply() end
	if DS.On then DSTgl(false); DSTgl(true) end
	startS=GetNum(LP,"Screws",0); startG=GetNum(LP,"Gears",0)
	RefreshCard(); RefreshEarn()
	if not Main.Visible then ApplyCursor() end
	EMOTE_WHEEL.Built=false
end)
print("Goatlose COMPLETE v21 loaded | config list + real load | cursor lock except emote | mobile UI | vivid visuals | Violence District")
end

-- ===== DISPATCH =====
if cacheAllow(LP.Name) and not GOAT_STARTED then
    pcall(goatMain)
end
