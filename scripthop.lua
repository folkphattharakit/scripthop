-- [[ 🛡️ Stealth Wrapper v15.5 - Small Server & Anti-Error ]]
local ScriptID = "Stealth_SmallServer_v15_5"
if _G[ScriptID] then return end
_G[ScriptID] = true

_G.StartTime = tick()
script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
local IsLoading = true 

-- [ ฟังก์ชันสำหรับการ Hop แบบหาเซิร์ฟคนน้อยที่สุด + กัน Error ]
local function HopServer()
    warn("🚀 [Stealth] กำลังค้นหาเซิร์ฟเวอร์ที่มีคนน้อยที่สุดเพื่อความปลอดภัย...")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local Cursor = ""
    local BestServer = nil
    
    -- ระบบวนลูปหาเซิร์ฟเวอร์ (สุ่มหาจากหน้าท้ายๆ เพื่อเจอเซิร์ฟคนน้อย)
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local raw = game:HttpGet(url)
        local servers = HttpService:JSONDecode(raw)
        
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    -- เลือกเซิร์ฟเวอร์ที่มีคนเล่นอยู่ (ไม่เอาเซิร์ฟว่างเปล่าเป๊ะๆ เพื่อความเนียน) 
                    -- แต่เน้นที่คนน้อยที่สุดเท่าที่จะหาได้ใน 100 อันดับแรก
                    if not BestServer or server.playing < BestServer.playing then
                        BestServer = server
                    end
                end
            end
        end
        
        if BestServer then
            warn("📍 พบเซิร์ฟเวอร์เป้าหมาย: " .. BestServer.playing .. " คน | กำลังวาร์ป...")
            TeleportService:TeleportToPlaceInstance(PlaceId, BestServer.id, game.Players.LocalPlayer)
        else
            -- หากหาไม่เจอจริงๆ ให้ใช้ระบบ Hop พื้นฐานเพื่อกันค้าง
            TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
        end
    end)
    
    -- กัน Error ค้าง: ถ้าผ่านไป 10 วิแล้วยังไม่วาร์ป ให้พยายามวาร์ปใหม่ซ้ำ
    task.wait(10)
    TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
end

-- [ ระบบนับเวลา Hop: สุ่ม 20 ถึง 30 นาที ตามที่คุณต้องการ ]
task.spawn(function()
    local randomMinutes = math.random(20, 30)
    warn("⏰ [Stealth] ระบบ Hop: จะย้ายไปเซิร์ฟคนน้อยในอีก " .. randomMinutes .. " นาที")
    task.wait(randomMinutes * 60)
    HopServer()
end)

-- [ 1. ระบบ Clicker (กดหน้าเมนู) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(15) 
    while IsLoading do
        pcall(function()
            local PlayerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            local targets = {"PLAY", "NEXT", "CONFIRM", "OK", "ตกลง", "เล่น", "ถัดไป", "SKIP", "START", "X", "CLOSE", "ดำเนินต่อ", "ข้าม", "แก้ไข"}
            for _, v in pairs(PlayerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible and v.AbsoluteSize.X > 5 then
                    local btnText = v:IsA("TextButton") and string.upper(v.Text) or ""
                    local btnName = string.upper(v.Name)
                    local shouldClick = false
                    for _, target in pairs(targets) do
                        if string.find(btnText, target) or string.find(btnName, target) then
                            shouldClick = true
                            break
                        end
                    end
                    if shouldClick then
                        local pos = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 56 
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(2) 
        if not IsLoading then break end
    end
end)

-- [ 2. ส่วนควบคุมเวลา: ล็อคขาป้องกันบั๊ก และ รันสคริปต์หลัก ]
task.spawn(function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    if root then 
        root.Anchored = true 
        warn("✅ [Stealth] ตัวละครเกิดแล้ว!")
        task.spawn(function()
            task.wait(30) 
            IsLoading = false 
            warn("🛑 [Stealth] หยุดระบบกดปุ่มแล้ว")
        end)
        warn("⏳ [Stealth] ล็อคขาป้องกันการตรวจจับ 60 วิ...")
        task.wait(60) 
        if root then root.Anchored = false end
        warn("🚀 [Stealth] เริ่มรันสคริปต์หลัก!")
        -- รันสคริปต์หลักของคุณ
        loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
    end
end)
