-- [[ 🛡️ Stealth Wrapper v17.2 - 40s Limit Clicker & Anti-AFK ]]
local ScriptID = "Stealth_v17_2"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ระบบป้องกัน Log และ Error ]
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

-- [ 💤 ระบบกันหลุด Anti-AFK ]
task.spawn(function()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local IsLoading = true 
local Player = game.Players.LocalPlayer
local FileName = "Status_" .. Player.Name .. ".txt"

-- [ 1. 🎯 ระบบ Clicker (ทำงานแค่ 40 วินาทีแล้วหยุดถาวร) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local StartClickTime = tick()
    warn("⏳ [Stealth] ระบบ Clicker เริ่มทำงาน (จะหยุดใน 40 วินาที)")

    while IsLoading do
        -- เช็คว่ารันมาเกิน 40 วินาทีหรือยัง
        if tick() - StartClickTime > 40 then 
            IsLoading = false
            warn("🛑 [Stealth] ครบ 40 วินาทีแล้ว สั่งหยุดระบบ Clicker ถาวร!")
            break 
        end

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
                        local pos = v.AbsolutePosition
                        local size = v.AbsoluteSize
                        local centerX = pos.X + (size.X / 2)
                        local centerY = pos.Y + (size.Y / 2) + 56 
                        
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(0.2)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(3) -- สแกนทุก 3 วินาทีเพื่อให้กดได้หลายปุ่มภายใน 40 วิ
    end
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการแช่ 30 นาที ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        root.Anchored = true
        
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
            -- [[ รอบที่ 2: ฟาร์มจริง (สุ่มรอ 4-8 นาที) ]]
            warn("🚀 [Stealth] ตรวจพบไฟล์ Ready: กำลังสุ่มรอฟาร์ม...")
            local waitTime = math.random(240, 480) 
            task.wait(waitTime)
            
            if root then root.Anchored = false end
            warn("🔥 [Stealth] เริ่มรันสคริปต์หลัก Achitsak")
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            -- ระบบ Hop (30-45 นาที)
            task.spawn(function()
                task.wait(math.random(30, 45) * 60)
                -- ฟังก์ชัน Hop เดิม
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak-Script/Hop/main/Hop.lua"))()
            end)
        end
    end
end)
