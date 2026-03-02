-- [[ 🛡️ Stealth Wrapper v17.10 - No Flying / Ground Stand ]]
local ScriptID = "Stealth_v17_10"
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

-- [ 💤 ระบบกันหลุด Anti-AFK (ทำงานเฉพาะช่วงแช่) ]
local function StartTemporaryAntiAFK()
    AntiAFKActive = true
    task.spawn(function()
        warn("💤 [Stealth] Anti-AFK (Camera Mode) เริ่มทำงาน...")
        while AntiAFKActive do
            task.wait(math.random(60, 120))
            if not AntiAFKActive then break end
            pcall(function()
                local camera = workspace.CurrentCamera
                -- สุ่มขยับมุมกล้องนิดเดียว เหมือนคนขยับเมาส์
                local offset = math.rad(math.random(-5, 5) / 10)
                camera.CFrame = camera.CFrame * CFrame.Angles(0, offset, 0)
            end)
        end
    end)
end

-- [ 1. 🎯 ระบบ Clicker (รอ 15 วิ / หยุดที่ 45 วิ / ระบบ 17.3) ]
task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    local StartTime = tick()
    
    task.wait(15) -- [[ รอ 15 วินาทีก่อนเริ่ม ]]
    warn("🎯 [Stealth] เริ่มระบบ Clicker (17.3 Style)")

    while IsLoading do
        local currentTime = tick() - StartTime
        if currentTime > 45 then 
            IsLoading = false
            warn("🛑 [Stealth] ระบบ Clicker หยุดทำงานถาวร!")
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
        task.wait(3)
    end
end)

-- [ 2. 🛡️ ระบบจัดการไอดี และการแช่บนพื้น (Ground Aging) ]
task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    
    if root then
        local isReady = false
        if isfile(FileName) then
            if readfile(FileName) == "Ready" then isReady = true end
        end
        
        if not isReady then
            -- [[ รอบที่ 1: แช่ 30 นาทีบนพื้นปกติ ]]
            StartTemporaryAntiAFK()
            
            -- ใส่แรงสั่นเบาๆ ให้ตัวละคร (Micro-movement) กันระบบตรวจจับ Static Character
            local force = Instance.new("BodyVelocity")
            force.MaxForce = Vector3.new(50, 0, 50) 
            force.Velocity = Vector3.new(0, 0, 0)
            force.Parent = root
            
            local startTime = os.date("%X")
            writefile(FileName, "Started at: " .. startTime)
            warn("🆕 [Stealth] แช่ไอดี 30 นาที (บนพื้นปกติ)...")
            
            task.wait(1800)
            
            AntiAFKActive = false
            writefile(FileName, "Ready")
            warn("✅ แช่เสร็จแล้ว! กำลังปิดเกม...")
            task.wait(2)
            game:Shutdown()
        else
            -- [[ รอบที่ 2: ฟาร์มจริง ]]
            warn("🚀 [Stealth] Ready: สุ่มรอฟาร์ม (4-8 นาที)...")
            task.wait(math.random(240, 480))
            
            -- ล้างค่าแรงสั่นออกก่อนรันสคริปต์หลัก
            local oldForce = root:FindFirstChildOfClass("BodyVelocity")
            if oldForce then oldForce:Destroy() end
            
            -- [ 🔑 รันสคริปต์หลัก Achitsak ]
            script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
            loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
            
            -- ระบบ Hop
            task.spawn(function()
                task.wait(math.random(30, 45) * 60)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak-Script/Hop/main/Hop.lua"))()
            end)
        end
    end
end)
