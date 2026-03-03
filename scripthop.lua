-- [[ 🛡️ Stealth Wrapper v17.21 - Force Click / No Stop Edition ]]
local ScriptID = "Stealth_v17_21"
if _G[ScriptID] then return end
_G[ScriptID] = true

local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

local Player = game.Players.LocalPlayer
local IsInGame = false -- ตัวแปรใหม่สำหรับเช็คว่าเข้าถึงตัวเกมจริงๆ หรือยัง

-- [ 1. 🎯 ระบบ Clicker - ตัวนี้จะทำงานไม่หยุดจนกว่า IsInGame จะเป็น true ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    task.wait(15) 
    warn("🎯 [Stealth] ระบบ Clicker เริ่มการเฝ้าระวังหน้าจอ...")

    while not IsInGame do 
        pcall(function()
            local PlayerGui = Player:FindFirstChild("PlayerGui")
            if not PlayerGui then return end
            
            local targets = {"PLAY", "NEXT", "CONFIRM", "OK", "เล่น", "ตกลง", "ถัดไป", "SKIP", "START"}
            for _, v in pairs(PlayerGui:GetDescendants()) do
                -- เช็คทั้งชื่อปุ่ม, ข้อความในปุ่ม และความโปร่งใส เพื่อให้มั่นใจว่าปุ่มพร้อมกดจริงๆ
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
                        local centerY = pos.Y + (size.Y / 2) + 56 -- พิกัดแม่นๆ ของคุณ
                        
                        -- สั่งกดย้ำ 2 รอบต่อ 1 ปุ่มเพื่อให้มั่นใจ
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
                        warn("⚡ [Stealth] กำลังกดปุ่ม: " .. (btnText ~= "" and btnText or btnName))
                    end
                end
            end
        end)
        task.wait(2) -- วนเช็คทุก 2 วินาที
    end
    warn("✅ [Stealth] ตรวจพบตัวละครในเกมแล้ว หยุดระบบ Clicker")
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการตรวจสอบตัวละคร ]
task.spawn(function()
    -- รอโหลดข้อมูลผู้เล่นกัน Error nil Name
    while not (Player and Player.Parent and Player.Name ~= "") do
        task.wait(5) 
    end
    
    local FileName = "Status_" .. Player.Name .. ".txt"
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 60)
    
    if root then
        IsInGame = true -- เมื่อเจอตัวละคร ให้ส่งสัญญาณหยุดระบบ Clicker
        
        local isReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then isReady = true end
        end
        
        if not isReady then
            -- [ รอบวอร์ม 30 นาที ]
            local force = Instance.new("BodyVelocity", root)
            force.MaxForce = Vector3.new(50, 0, 50) 
            force.Velocity = Vector3.new(0, 0, 0)
            
            writefile(FileName, "Started at: " .. os.date("%X"))
            warn("🆕 [Stealth] เริ่มวอร์มไอดี 30 นาที...")
            task.wait(1800) 
            
            writefile(FileName, "Ready")
            warn("✅ วอร์มเสร็จแล้ว! กำลังรีเซ็ตไอดี...")
            task.wait(2)
            game:Shutdown()
        else
            -- [ รอบ Ready ]
            warn("🚀 [Stealth] Ready: กำลังรอ 5 นาทีก่อนเริ่มสคริปต์หลัก...")
            task.wait(300) 
            
            if root:FindFirstChildOfClass("BodyVelocity") then root:FindFirstChildOfClass("BodyVelocity"):Destroy() end
            
            -- [ 🔑 รันสคริปต์หลัก ]
            script_key = "dcqwGHfLTHFGcHTZPhrgzZVIPLxMVVMf"
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            warn("💎 [Stealth] สคริปต์หลักทำงานแล้ว!")
        end
    end
end)
