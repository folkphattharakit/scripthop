-- [[ 🛡️ Stealth Wrapper v16.5 - Full Integrated Edition ]]
local ScriptID = "Stealth_Ultra_v16_5"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ส่วนที่ 1: ปิดปาก Error "no owner id" ]
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

local oldPrint = print
print = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldPrint(...)
end

_G.StartTime = tick()
script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
local IsLoading = true 
local Player = game.Players.LocalPlayer
local FileName = "Status_" .. Player.Name .. ".txt"

-- [ 🚀 ฟังก์ชันสำหรับการ Hop (ของคุณเดิมเป๊ะ) ]
local function HopServer()
    warn("🚀 [Stealth] กำลังค้นหาเซิร์ฟเวอร์คนน้อย (เน้นเนียน)...")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local BestServer = nil
    
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local raw = game:HttpGet(url)
        local servers = HttpService:JSONDecode(raw)
        
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if not BestServer or server.playing < BestServer.playing then
                        BestServer = server
                    end
                end
            end
        end
        
        if BestServer then
            warn("📍 พบเป้าหมาย: " .. BestServer.playing .. " คน | กำลังวาร์ป...")
            TeleportService:TeleportToPlaceInstance(PlaceId, BestServer.id, Player)
        else
            TeleportService:Teleport(PlaceId, Player)
        end
    end)
    task.wait(10)
    TeleportService:Teleport(PlaceId, Player)
end

-- [ ⏰ ระบบนับเวลา Hop (ทำงานเฉพาะตอนฟาร์มจริง) ]
local function StartHopTimer()
    task.spawn(function()
        local randomMinutes = math.random(35, 50) 
        warn("⏰ [Stealth] ระบบ Hop: จะย้ายเซิร์ฟเวอร์ในอีก " .. randomMinutes .. " นาที")
        task.wait(randomMinutes * 60)
        HopServer()
    end)
end

-- [ 1. ระบบ Clicker (ของคุณเดิมเป๊ะ) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(math.random(15, 20))
    while IsLoading do
        pcall(function()
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            local targets = {"PLAY", "NEXT", "CONFIRM", "OK", "ตกลง", "เล่น", "ถัดไป", "SKIP", "START", "X", "CLOSE", "ดำเนินต่อ", "ข้าม"}
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
                        local pos, size = v.AbsolutePosition, v.AbsoluteSize
                        local centerX, centerY = pos.X + (size.X / 2), pos.Y + (size.Y / 2) + 56 
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(0.3)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(4)
    end
end)

-- [ 2. 🛡️ หัวใจหลัก: ระบบจำลองพฤติกรรม + เช็คไฟล์ ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then 
        root.Anchored = true 
        
        -- เช็คสถานะการแช่ไอดี
        if not isfile(FileName) then
            -- [[ โหมดแช่ไอดีใหม่ 30 นาที ]]
            warn("🆕 [Stealth] ไอดีใหม่: เริ่มระบบสะสม Playtime 30 นาที (ห้ามปิด)...")
            task.wait(1800) 
            writefile(FileName, "Ready")
            warn("✅ [Stealth] แช่เสร็จแล้ว! กำลังปิดเกมเพื่อให้ระบบบันทึกค่า...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ โหมดฟาร์มจริง (สำหรับไอดีที่แช่แล้ว) ]]
            warn("✅ [Stealth] ไอดีพร้อมฟาร์ม: เริ่มระบบพรางตัว...")
            
            task.spawn(function()
                task.wait(math.random(35, 40)) 
                IsLoading = false 
                warn("🛑 [Stealth] ปิดระบบ Auto-Click แล้ว")
            end)

            local startupWait = math.random(300, 900) -- สุ่มรอ 5-15 นาทีเพื่อกระจายความเสี่ยง
            warn("⏳ [Stealth] จะเริ่มรันสคริปต์ฟาร์มใน " .. startupWait .. " วินาที")
            task.wait(startupWait) 

            if root then root.Anchored = false end
            warn("🚀 [Stealth] เริ่มรันสคริปต์หลัก (Achitsak)")
            StartHopTimer() -- เริ่มนับเวลา Hop เฉพาะตอนเริ่มฟาร์ม
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
        end
    end
end)
