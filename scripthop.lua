-- [[ 🛡️ Stealth Wrapper v15.5 - GitHub Main ]]
local ScriptID = "Stealth_SmallServer_v15_5"
if _G[ScriptID] then return end
_G[ScriptID] = true

_G.StartTime = tick()
script_key = "MXTDMJvBpOEoioKwDYJUAhkpixiUrXpj"
local IsLoading = true 

-- [ ฟังก์ชันสำหรับการ Hop เซิร์ฟคนน้อย ]
local function HopServer()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local raw = game:HttpGet(url)
        local servers = HttpService:JSONDecode(raw)
        local BestServer = nil
        if servers and servers.data then
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    if not BestServer or server.playing < BestServer.playing then BestServer = server end
                end
            end
        end
        if BestServer then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, BestServer.id, game.Players.LocalPlayer)
        else
            TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
        end
    end)
    task.wait(10)
    TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
end

-- [ ระบบนับเวลา Hop 20-30 นาที ]
task.spawn(function()
    task.wait(math.random(20, 30) * 60)
    HopServer()
end)

-- [ 1. ระบบ Clicker กด PLAY/OK ]
task.spawn(function()
    local VIM = game:GetService("VirtualInputManager")
    task.wait(15) 
    while IsLoading do
        pcall(function()
            local targets = {"PLAY", "NEXT", "CONFIRM", "OK", "ตกลง", "เล่น"}
            for _, v in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
                if v:IsA("TextButton") and v.Visible then
                    for _, t in pairs(targets) do
                        if v.Text:upper():find(t) then
                            local pos, size = v.AbsolutePosition, v.AbsoluteSize
                            VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 56, 0, true, game, 1)
                            VIM:SendMouseButtonEvent(pos.X + (size.X/2), pos.Y + (size.Y/2) + 56, 0, false, game, 1)
                        end
                    end
                end
            end
        end)
        task.wait(2) 
        if not IsLoading then break end
    end
end)

-- [ 2. ล็อคขา 60 วิ และรัน Main Script ของคุณ ]
task.spawn(function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 40)
    if root then 
        root.Anchored = true 
        warn("✅ [Stealth] ล็อคขาป้องกันแบน 60 วิ...")
        task.spawn(function() task.wait(30) IsLoading = false end)
        task.wait(60) 
        root.Anchored = false
        warn("🚀 [Stealth] เริ่มรัน Main Script...")

        -- [[ รันสคริปต์หลักพร้อม Configs ของคุณตามรูป image_9d5dff.png ]]
        getgenv().Configs = {
            ['Money'] = 1005000, 
            ['Skill'] = {
                ['Farmer'] = 1,
                ['Swiper'] = 1
            }
        }
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Achitsak/PRRoblox/main/flkshxp/bloxspin.lua"))()
    end
end)
