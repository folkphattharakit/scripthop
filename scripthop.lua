-- [[ 🛡️ Stealth Wrapper v16.1 Ultra Stealth - For Gen Accounts ]]
local ScriptID = "Stealth_Ultra_v16"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ระบบป้องกัน Log และ Error: บล็อก Error "no owner id" ] --
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then 
        return -- สั่งให้เงียบ ไม่ส่ง Log นี้ออกไป
    end
    oldWarn(...)
end

local oldPrint = print
print = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then 
        return 
    end
    oldPrint(...)
end

_G.StartTime = tick()
script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
local IsLoading = true 

-- [ ฟังก์ชันสำหรับการ Hop แบบหาเซิร์ฟคนน้อยที่สุด + กัน Error ]
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
            TeleportService:TeleportToPlaceInstance(PlaceId, BestServer.id, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
        end
    end)
    
    task.wait(10)
    TeleportService:Teleport(PlaceId, game.Players.LocalPlayer)
end

-- [ ⏰ ระบบนับเวลา Hop ]
task.spawn(function()
    local randomMinutes = math.random(30, 45) 
    warn("⏰ [Stealth] ระบบ Hop: จะย้ายเซิร์ฟเวอร์ในอีก " .. randomMinutes .. " นาที")
    task.wait(randomMinutes * 60)
    HopServer()
end)

-- [ 1. ระบบ Clicker ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(math.random(15, 20))
    while IsLoading do
        pcall(function()
            local PlayerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
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
                        local pos = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 56 
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(math.random(2, 5) / 10)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(4)
        if not IsLoading then break end
    end
end)

-- [ 2. 🛡️ หัวใจหลัก: ระบบจำลองพฤติกรรมคนเล่นใหม่ ]
task.spawn(function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then 
        root.Anchored = true 
        warn("✅ [Stealth] ไอดีเจน: เริ่มระบบจำลองพฤติกรรมมนุษย์...")
        
        task.spawn(function()
            task.wait(math.random(35, 40)) 
            IsLoading = false 
            warn("🛑 [Stealth] ปิดระบบ Auto-Click แล้ว")
        end)

        local startupWait = math.random(180, 300)
        warn("⏳ [Stealth] กำลังเลียนแบบการอ่านเมนู/เดินเล่น: จะเริ่มใน " .. startupWait .. " วินาที")
        task.wait(startupWait) 

        if root then root.Anchored = false end
        warn("🚀 [Stealth] ปลอดภัยแล้ว! เริ่มรันสคริปต์หลัก")
        
        -- รันสคริปต์หลัก (Achitsak)
        loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
    end
end)
