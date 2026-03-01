-- [[ 🛡️ Stealth Wrapper v17.0 - Original Clicker & Full Stealth ]]
local ScriptID = "Stealth_v17_Final"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ระบบป้องกัน Log และ Error ]
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

-- [ 🚀 ฟังก์ชันสำหรับการ Hop (ค้นหาเซิร์ฟคนน้อย) ]
local function HopServer()
    warn("🚀 [Stealth] กำลังย้ายไปเซิร์ฟเวอร์ที่คนน้อยที่สุด...")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local raw = game:HttpGet(url)
        local servers = HttpService:JSONDecode(raw)
        if servers and servers.data then
            local BestServer = nil
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if not BestServer or server.playing < BestServer.playing then
                        BestServer = server
                    end
                end
            end
            if BestServer then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, BestServer.id, Player)
            end
        end
    end)
    task.wait(10)
    TeleportService:Teleport(game.PlaceId, Player)
end

-- [ 1. 🎯 ระบบ Clicker (ยกมาจากสคริปต์เก่าที่แม่นยำที่สุด) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(math.random(15, 20)) -- เวลารอเริ่มกดตามสคริปต์เก่า
    while IsLoading do
        pcall(function()
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            -- รายชื่อปุ่มเป้าหมายทั้งหมดจากสคริปต์เก่า
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
                        local pos = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 56 
                        
                        -- ระบบกดย้ำ 2 รอบตามสคริปต์เดิม
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(math.random(2, 5) / 10)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(4) -- ความถี่ในการสแกนตามสคริปต์เก่า
    end
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการแช่ 30 นาที ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        root.Anchored = true
        
        -- เช็คสถานะแช่ไอดีจาก workspace
        local isReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then isReady = true end
        end
        
        if not isReady then
            -- [[ รอบที่ 1: แช่ไอดีใหม่ 30 นาที ]]
            local startTime = os.date("%X")
            writefile(FileName, "Started at: " .. startTime)
            warn("🆕 [Stealth] ไอดีใหม่: เริ่มแช่ 30 นาที (เริ่มตอน " .. startTime .. ")")
            
            task.wait(1800) -- แช่ 30 นาที
            
            writefile(FileName, "Ready")
            warn("✅ [Stealth] แช่เสร็จแล้ว! กำลังปิดเกม...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ รอบที่ 2: ฟาร์มจริง + ระบบสุ่มรอ 4-8 นาที ]]
            warn("🚀 [Stealth] ตรวจพบไฟล์ Ready: กำลังเตรียมตัวฟาร์ม...")
            
            -- ปรับเวลาสุ่มรอ 4-8 นาทีตามที่คุณสั่ง
            local waitTime = math.random(240, 480) 
            warn("⏳ [Stealth] จะเริ่มฟาร์มในอีก " .. waitTime .. " วินาที")
            
            task.spawn(function()
                task.wait(45) -- ปิด Clicker หลังเข้าเกมแล้ว 45 วินาที
                IsLoading = false 
            end)
            
            task.wait(waitTime)
            if root then root.Anchored = false end
            
            warn("🔥 [Stealth] เริ่มรันสคริปต์หลัก Achitsak")
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            -- ระบบ Hop อัตโนมัติ (30-45 นาที)
            task.spawn(function()
                local hopWait = math.random(30, 45)
                task.wait(hopWait * 60)
                HopServer()
            end)
        end
    end
end)
