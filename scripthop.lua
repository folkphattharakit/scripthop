-- [[ 🛡️ Stealth Wrapper v17.8 - v17.3 Clicker Hybrid ]]
local ScriptID = "Stealth_v17_8"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ระบบป้องกัน Log ]
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

local AntiAFKActive = false
local Player = game.Players.LocalPlayer
local FileName = "Status_" .. Player.Name .. ".txt"
local IsLoading = true 

-- [ 💤 ระบบกันหลุด Anti-AFK (ทำงานเฉพาะช่วงแช่ไอดีจาก v17.6) ]
local function StartTemporaryAntiAFK()
    AntiAFKActive = true
    task.spawn(function()
        warn("💤 [Stealth] Anti-AFK เริ่มทำงานเฉพาะช่วงแช่ไอดี...")
        while AntiAFKActive do
            task.wait(math.random(100, 200))
            if not AntiAFKActive then break end
            pcall(function()
                local camera = workspace.CurrentCamera
                camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(0.01), 0)
            end)
        end
        warn("🛑 [Stealth] Anti-AFK หยุดทำงานแล้ว (เข้าสู่โหมดฟาร์ม)")
    end)
end

-- [ 1. 🎯 ระบบ Clicker (ดึงจาก v17.3 มาทั้งหมด: ไวและแม่นยำ) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local StartClickTime = tick()
    warn("⏳ [Stealth] ระบบ Clicker 17.3 เริ่มทำงาน (หยุดใน 40 วินาที)")

    while IsLoading do
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
                        
                        -- ระบบกดย้ำ 2 ครั้งแบบ 17.3
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        task.wait(0.2)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(3) -- ความเร็วเท่าเดิมแบบ 17.3
    end
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการแช่ (ใช้ระบบ v17.6) ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        local isReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then isReady = true end
        end
        
        if not isReady then
            -- [[ รอบที่ 1: แช่ 30 นาทีแบบลอยตัว (v17.6) ]]
            StartTemporaryAntiAFK()
            
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.Position = root.Position + Vector3.new(0, 20, 0)
            bp.Parent = root
            
            local startTime = os.date("%X")
            writefile(FileName, "Started at: " .. startTime)
            warn("🆕 [Stealth] ไอดีใหม่: เริ่มแช่ 30 นาที...")
            
            task.wait(1800)
            
            AntiAFKActive = false
            writefile(FileName, "Ready")
            warn("✅ [Stealth] แช่เสร็จแล้ว! กำลังปิดเกม...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ รอบที่ 2: ฟาร์มจริง ]]
            warn("🚀 [Stealth] ตรวจพบไฟล์ Ready: กำลังสุ่มรอฟาร์ม (4-8 นาที)...")
            task.wait(math.random(240, 480))
            
            local oldBp = root:FindFirstChildOfClass("BodyPosition")
            if oldBp then oldBp:Destroy() end
            
            -- [ 🔑 รันสคริปต์หลัก ]
            script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            task.spawn(function()
                task.wait(math.random(30, 45) * 60)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak-Script/Hop/main/Hop.lua"))()
            end)
        end
    end
end)
