-- [[ 🛡️ Stealth Wrapper v17.21 - Minimal 5 Min Wait Edition ]]
local ScriptID = "Stealth_v17_21"
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

-- [ 💤 ระบบกันหลุด Anti-AFK ]
local function StartTemporaryAntiAFK()
    AntiAFKActive = true
    task.spawn(function()
        warn("💤 [Stealth] Anti-AFK เริ่มทำงาน...")
        while AntiAFKActive do
            task.wait(math.random(60, 120))
            if not AntiAFKActive then break end
            pcall(function()
                local camera = workspace.CurrentCamera
                local offset = math.rad(math.random(-5, 5) / 10)
                camera.CFrame = camera.CFrame * CFrame.Angles(0, offset, 0)
            end)
        end
    end)
end

-- [ 🚀 ระบบนับเวลาถอยหลัง 5 นาที ]
task.spawn(function()
    warn("⏳ [Stealth] ระบบเริ่มทำงาน: กำลังรอ 5 นาที (300 วินาที) ก่อนรันสคริปต์หลัก...")
    
    -- เริ่มระบบกันหลุดระหว่างรอ
    StartTemporaryAntiAFK()
    
    -- ยืนนิ่งๆ รอครบ 5 นาที
    task.wait(460)
    
    -- เมื่อครบเวลา จะรอจนกว่าตัวละครจะเกิด (เผื่อกรณีคลิกเข้าเกมช้า)
    local char = Player.Character or Player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 60)
    
    if root then
        warn("💎 [Stealth] ครบ 5 นาทีแล้ว! กำลังรันสคริปต์หลัก...")
        
        -- [ 🔑 รันสคริปต์หลัก Achitsak ]
        script_key = "dcqwGHfLTHFGcHTZPhrgzZVIPLxMVVMf"
        loadstring(game:HttpGet('https://api.luarmor.net/files/v3/loaders/50cc49ea3e0a5a40cd1fb5545dc938b6.lua'))()
        
        -- ปิดระบบ Anti-AFK ของ Wrapper เพื่อให้สคริปต์หลักจัดการต่อ
        AntiAFKActive = false
        warn("✅ [Stealth] สคริปต์หลักถูกเรียกใช้งานแล้ว")
    end
end)
