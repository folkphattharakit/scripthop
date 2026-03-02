-- [[ 🛡️ Stealth Wrapper v17.6 - Target Anti-AFK & Safe Float ]]
local ScriptID = "Stealth_v17_6"
if _G[ScriptID] then return end
_G[ScriptID] = true

-- [ 🛑 ระบบป้องกัน Log ]
local oldWarn = warn
warn = function(...)
    local msg = tostring(...)
    if string.find(msg:lower(), "owner") or string.find(msg:lower(), "id") then return end
    oldWarn(...)
end

local AntiAFKActive = false -- สถานะเริ่มต้นคือปิดไว้
local Player = game.Players.LocalPlayer
local FileName = "Status_" .. Player.Name .. ".txt"
local IsLoading = true 

-- [ 💤 ฟังก์ชัน Anti-AFK (ทำงานเฉพาะเมื่อเรียกใช้) ]
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
        warn("🛑 [Stealth] Anti-AFK หยุดทำงานแล้ว (เข้าสู่โหมดฟาร์ม/Ready)")
    end)
end

-- [ 1. 🎯 ระบบ Clicker (หยุดถาวรใน 40 วินาที + สุ่มจุดกด) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local StartClickTime = tick()
    while IsLoading do
        if tick() - StartClickTime > 40 then 
            IsLoading = false
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
                        local randX = pos.X + (size.X / 2) + math.random(-8, 8)
                        local randY = pos.Y + (size.Y / 2) + 56 + math.random(-8, 8)
                        VirtualInputManager:SendMouseButtonEvent(randX, randY, 0, true, game, 1)
                        VirtualInputManager:SendMouseButtonEvent(randX, randY, 0, false, game, 1)
                    end
                end
            end
        end)
        task.wait(math.random(3, 6))
    end
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการแช่ ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        local isReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then isReady = true end
        end
        
        if not isReady then
            -- [[ รอบที่ 1: แช่ไอดีใหม่ 30 นาที ]]
            StartTemporaryAntiAFK() -- เปิด Anti-AFK เฉพาะตอนนี้
            
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.Position = root.Position + Vector3.new(0, 20, 0)
            bp.Parent = root
            
            local startTime = os.date("%X")
            writefile(FileName, "Started at: " .. startTime)
            warn("🆕 [Stealth] ไอดีใหม่: เริ่มแช่ 30 นาที...")
            
            task.wait(1800) -- แช่ 30 นาที
            
            AntiAFKActive = false -- สั่งปิด Anti-AFK ทันทีที่ครบเวลา
            writefile(FileName, "Ready")
            warn("✅ [Stealth] แช่เสร็จแล้ว! กำลังปิดเกม...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ รอบที่ 2 เป็นต้นไป: ฟาร์มจริง (Anti-AFK จะไม่ถูกเปิด) ]]
            warn("🚀 [Stealth] สถานะ Ready: กำลังสุ่มรอฟาร์ม (4-8 นาที)...")
            task.wait(math.random(240, 480))
            
            -- ตรวจสอบและเอาตัวลอยออก (ถ้ามี)
            local oldBp = root:FindFirstChildOfClass("BodyPosition")
            if oldBp then oldBp:Destroy() end
            
            -- [ 🔑 รันสคริปต์หลัก ]
            script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            -- ระบบ Hop (30-45 นาที)
            task.spawn(function()
                task.wait(math.random(30, 45) * 60)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak-Script/Hop/main/Hop.lua"))()
            end)
        end
    end
end)
