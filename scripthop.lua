-- [[ 🛡️ Stealth Wrapper v16.8 - Fast Start & Full Features ]]
local ScriptID = "Stealth_v16_8"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ส่วนที่ 1: ปิดปาก Error และ Log ]
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

local IsLoading = true 
local Player = game.Players.LocalPlayer
local FileName = "Status_" .. Player.Name .. ".txt"

-- [ 🚀 ฟังก์ชันสำหรับการ Hop (ค้นหาเซิร์ฟคนน้อย) ]
local function HopServer()
    warn("🚀 [Stealth] กำลังค้นหาเซิร์ฟเวอร์คนน้อย (เน้นเนียน)...")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local servers = HttpService:JSONDecode(game:HttpGet(url))
        if servers and servers.data then
            local BestServer = nil
            for _, s in pairs(servers.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    if not BestServer or s.playing < BestServer.playing then BestServer = s end
                end
            end
            if BestServer then TeleportService:TeleportToPlaceInstance(game.PlaceId, BestServer.id, Player) end
        end
    end)
end

-- [ 1. ระบบ Clicker กดปุ่มเข้าเกมอัตโนมัติ ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(15)
    while IsLoading do
        pcall(function()
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            local targets = {"PLAY", "NEXT", "CONFIRM", "OK", "ตกลง", "เล่น", "SKIP", "START", "X", "CLOSE"}
            for _, v in pairs(PlayerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) and v.Visible then
                    for _, t in pairs(targets) do
                        if string.find(string.upper(v.Text or v.Name), t) then
                            local pos, size = v.AbsolutePosition, v.AbsoluteSize
                            VirtualInputManager:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 56, 0, true, game, 1)
                            VirtualInputManager:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 56, 0, false, game, 1)
                        end
                    end
                end
            end
        end)
        task.wait(5)
    end
end)

-- [ 2. 🛡️ ระบบเช็คไฟล์สถานะ + การทำงานหลัก ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        root.Anchored = true
        
        local alreadyReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then alreadyReady = true end
        end
        
        if not alreadyReady then
            -- [[ รอบที่ 1: โหมดแช่ไอดี 30 นาที ]]
            local startTime = os.date("%X")
            writefile(FileName, "Started at: " .. startTime)
            warn("🆕 [Stealth] เริ่มแช่ 30 นาที (เริ่มตอน " .. startTime .. ")")
            
            task.wait(1800) -- แช่ 30 นาที
            
            writefile(FileName, "Ready")
            warn("✅ [Stealth] แช่ครบแล้ว! ปิดเกม...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ รอบที่ 2: โหมดฟาร์มจริง + ระบบ Hop ]]
            warn("🚀 [Stealth] พร้อมฟาร์ม: กำลังพรางตัว...")
            
            -- ปรับเวลาสุ่มเป็น 4-8 นาที (240 - 480 วินาที)
            local waitTime = math.random(240, 480) 
            warn("⏳ [Stealth] จะเริ่มรันในอีก " .. waitTime .. " วินาที (4-8 นาที)")
            
            task.spawn(function()
                task.wait(40) 
                IsLoading = false 
            end)
            
            task.wait(waitTime)
            if root then root.Anchored = false end
            
            warn("🔥 [Stealth] รัน Achitsak...")
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            -- ระบบ Hop (30-45 นาที)
            task.spawn(function()
                local hopWait = math.random(30, 45)
                warn("⏰ [Stealth] จะย้ายเซิร์ฟเวอร์ในอีก " .. hopWait .. " นาที")
                task.wait(hopWait * 60)
                HopServer()
            end)
        end
    end
end)
