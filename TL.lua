local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "TL Hub",
    Icon = "door-open",
    Author = "by .Just Random Dev",
    Theme = Midnight
})

Window:Section({
    Title = "Universe"
})

local Tab = Window:Tab({
    Title = "Main",
    Icon = "bird",
})

-- ⚙️ Global Variables (ตัวแปรกลางสำหรับเก็บค่าจาก Slider)
local speedVal = 16
local jumpVal = 50
local flySpeedVal = 28
local gravityVal = 196.2

local speedEnabled = false
local jumpEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local flyEnabled = false
local gravityEnabled = false

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= 1. SPEED HACK =================
Tab:Toggle({
    Title = "Enable Speed",
    Callback = function(state)
        speedEnabled = state
        local function ApplySpeed(char)
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.WalkSpeed = speedEnabled and speedVal or 16
            end
        end
        if LocalPlayer.Character then ApplySpeed(LocalPlayer.Character) end
    end
})

Tab:Slider({
    Title = "Set Speed",
    Value = { Min = 0.1, Max = 500, Default = 16 },
    Callback = function(value)
        speedVal = value
        if speedEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then humanoid.WalkSpeed = speedVal end
        end
    end
})

-- ================= 2. JUMP POWER =================
Tab:Toggle({
    Title = "Enable Jump High",
    Callback = function(state)
        jumpEnabled = state
        local function ApplyJump(char)
            local humanoid = char:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = jumpEnabled and jumpVal or 50
            end
        end
        if LocalPlayer.Character then ApplyJump(LocalPlayer.Character) end
    end
})

Tab:Slider({
    Title = "Set Jump High",
    Value = { Min = 0.1, Max = 500, Default = 50 },
    Callback = function(value)
        jumpVal = value
        if jumpEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then 
                humanoid.UseJumpPower = true
                humanoid.JumpPower = jumpVal 
            end
        end
    end
})

-- ================= 3. NOCLIP =================
Tab:Toggle({
    Title = "Enable Noclip",
    Callback = function(state)
        noclipEnabled = state
    end
})

RunService.RenderStepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then 
                v.CanCollide = false 
            end
        end
    end
end)

-- ================= 4. INFINITE JUMP =================
Tab:Toggle({
    Title = "Enable InfJump",
    Callback = function(state)
        infJumpEnabled = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ================= 5. FLY MODE =================
local flyDir = Vector3.new()

Tab:Toggle({
    Title = "Enable Fly",
    Callback = function(state)
        flyEnabled = state
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid then humanoid.PlatformStand = flyEnabled end
        end
    end
})

Tab:Slider({
    Title = "Fly Speed",
    Value = { Min = 1, Max = 300, Default = 28 },
    Callback = function(value)
        flySpeedVal = value
    end
})

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not flyEnabled then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyDir += Vector3.new(0,0,-1) end
    if key == Enum.KeyCode.S then flyDir += Vector3.new(0,0,1) end
    if key == Enum.KeyCode.A then flyDir += Vector3.new(-1,0,0) end
    if key == Enum.KeyCode.D then flyDir += Vector3.new(1,0,0) end
    if key == Enum.KeyCode.Space then flyDir += Vector3.new(0,1,0) end
    if key == Enum.KeyCode.LeftControl then flyDir += Vector3.new(0,-1,0) end
end)

UserInputService.InputEnded:Connect(function(input, gp)
    if gp or not flyEnabled then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyDir -= Vector3.new(0,0,-1) end
    if key == Enum.KeyCode.S then flyDir -= Vector3.new(0,0,1) end
    if key == Enum.Keycode.A then flyDir -= Vector3.new(-1,0,0) end -- ป้องกันเคสตัวพิมพ์เล็ก/ใหญ่
    if key == Enum.KeyCode.D then flyDir -= Vector3.new(1,0,0) end
    if key == Enum.KeyCode.Space then flyDir -= Vector3.new(0,1,0) end
    if key == Enum.KeyCode.LeftControl then flyDir -= Vector3.new(0,-1,0) end
end)
-- แก้ไขคีย์บอร์ดหลุดพิมพ์เล็กใหญ่สำหรับ A
UserInputService.InputEnded:Connect(function(input, gp)
    if gp or not flyEnabled then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.A then flyDir -= Vector3.new(-1,0,0) end
end)

RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart and flyDir.Magnitude > 0 then
            local cam = workspace.CurrentCamera.CFrame
            local move = (cam.LookVector * -flyDir.Z + cam.RightVector * flyDir.X + Vector3.new(0, flyDir.Y, 0)).Unit
            rootPart.Velocity = move * flySpeedVal
        end
    end
end)

-- ================= 6. GRAVITY MODIFIER =================
Tab:Toggle({
    Title = "Enable Gravity Modify",
    Callback = function(state)
        gravityEnabled = state
        if not gravityEnabled then
            workspace.Gravity = 196.2 -- คืนค่าเดิมเมื่อปิด
        end
    end
})

Tab:Slider({
    Title = "Gravity Value",
    Value = { Min = 0, Max = 500, Default = 196.2 },
    Callback = function(value)
        gravityVal = value
    end
})

RunService.RenderStepped:Connect(function()
    if gravityEnabled then
        workspace.Gravity = gravityVal
    end
end)

-- ================= 7. ADVANCED UNIVERSAL ESP =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ตั้งค่าสถานะการเปิด/ปิด (Toggles)
local espSettings = {
    Enabled = false,
    TeamCheck = true,
    Box = true,
    Name = true,
    HealthBar = true,
    HeadDot = true,
    Tracer = true,
    FriendlyColor = Color3.fromRGB(0, 255, 0),    -- สีเขียวสำหรับทีมเดียวกัน
    EnemyColor = Color3.fromRGB(255, 0, 0),       -- สีแดงสำหรับศัตรู
}

local espCache = {}

-- ฟังก์ชั่นเช็คประเภท Rig ของตัวละคร (R6 หรือ R15)
local function GetRigType(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            return "R6"
        else
            return "R15"
        end
    end
    return "Unknown"
end

-- ฟังก์ชั่นสร้าง Drawing Objects สำหรับผู้เล่นแต่ละคน
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBarBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
    }
    
    -- ตั้งค่าเริ่มต้น Box
    esp.Box.Visible = false
    esp.Box.Thickness = 1.5
    esp.Box.Filled = false
    
    -- ตั้งค่าเริ่มต้น Name
    esp.Name.Visible = false
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    
    -- ตั้งค่าเริ่มต้น HealthBar
    esp.HealthBarBg.Visible = false
    esp.HealthBarBg.Filled = true
    esp.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
    
    esp.HealthBar.Visible = false
    esp.HealthBar.Filled = true
    
    -- ตั้งค่าเริ่มต้น Tracer
    esp.Tracer.Visible = false
    esp.Tracer.Thickness = 1
    
    -- ตั้งค่าเริ่มต้น HeadDot
    esp.HeadDot.Visible = false
    esp.HeadDot.Radius = 4
    esp.HeadDot.Filled = true
    
    espCache[player] = esp
end

local function RemoveESP(player)
    if espCache[player] then
        for _, obj in pairs(espCache[player]) do
            pcall(function() obj:Remove() end)
        end
        espCache[player] = nil
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

-- ลูปการทำงานเรนเดอร์ ESP แบบ Real-time
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(espCache) do
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local head = character and character:FindFirstChild("Head")
        
        local hideEverything = true
        
        if espSettings.Enabled and character and rootPart and humanoid and humanoid.Health > 0 then
            -- ระบบเช็คทีม (Team Check)
            local isFriendly = false
            if espSettings.TeamCheck and player.Team == LocalPlayer.Team then
                isFriendly = true
            end
            
            -- กำหนดสีตามทีม
            local currentThemeColor = isFriendly and espSettings.FriendlyColor or espSettings.EnemyColor
            
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            if onScreen then
                hideEverything = false
                local rigType = GetRigType(character)
                
                -- คำนวณขนาดกล่อง Box ตามระยะทาง
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight / 2
                
                -- 1. Box ESP
                if espSettings.Box then
                    esp.Box.Visible = true
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(vector.X - boxWidth / 2, headPos.Y)
                    esp.Box.Color = currentThemeColor
                else
                    esp.Box.Visible = false
                end
                
                -- 2. Name & Distance & Rig ESP
                if espSettings.Name then
                    local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                    esp.Name.Visible = true
                    esp.Name.Text = string.format("%s [%d m]\n(%s)", player.Name, distance, rigType)
                    esp.Name.Position = Vector2.new(vector.X, headPos.Y - 18)
                    esp.Name.Color = currentThemeColor
                else
                    esp.Name.Visible = false
                end
                
                -- 3. Health Bar
                if espSettings.HealthBar then
                    local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    local barHeight = boxHeight * healthPercent
                    
                    esp.HealthBarBg.Visible = true
                    esp.HealthBarBg.Size = Vector2.new(3, boxHeight)
                    esp.HealthBarBg.Position = Vector2.new(vector.X - boxWidth / 2 - 6, headPos.Y)
                    
                    esp.HealthBar.Visible = true
                    esp.HealthBar.Size = Vector2.new(1.5, barHeight)
                    esp.HealthBar.Position = Vector2.new(vector.X - boxWidth / 2 - 5, headPos.Y + (boxHeight - barHeight))
                    esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                else
                    esp.HealthBarBg.Visible = false
                    esp.HealthBar.Visible = false
                end
                
                -- 4. Head Dot
                if espSettings.HeadDot and head then
                    local headVector, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                    if headOnScreen then
                        esp.HeadDot.Visible = true
                        esp.HeadDot.Position = Vector2.new(headVector.X, headVector.Y)
                        esp.HeadDot.Color = currentThemeColor
                    else
                        esp.HeadDot.Visible = false
                    end
                else
                    esp.HeadDot.Visible = false
                end
                
                -- 5. Tracer Lines
                if espSettings.Tracer then
                    esp.Tracer.Visible = true
                    esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.Tracer.To = Vector2.new(vector.X, legPos.Y)
                    esp.Tracer.Color = currentThemeColor
                else
                    esp.Tracer.Visible = false
                end
            end
        end
        
        if hideEverything then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBarBg.Visible = false
            esp.HealthBar.Visible = false
            esp.HeadDot.Visible = false
            esp.Tracer.Visible = false
        end
    end
end)


-- ================= 🎨 UI Integration (Display Section) =================
local DisplaySection = Tab:Section({
    Title = "Display & ESP",
    Icon = "monitor",
    Opened = true
})
 
DisplaySection:Toggle({ 
    Title = "Enable Universal ESP",
    Callback = function(state)
        espSettings.Enabled = state
    end
})

DisplaySection:Toggle({ 
    Title = "Team Check (แยกสีทีม)",
    Callback = function(state)
        espSettings.TeamCheck = state
    end
})

DisplaySection:Toggle({ 
    Title = "Show Box ESP",
    Callback = function(state)
        espSettings.Box = state
    end
})

DisplaySection:Toggle({ 
    Title = "Show Name & Rig",
    Callback = function(state)
        espSettings.Name = state
    end
})

DisplaySection:Toggle({ 
    Title = "Show Health Bar",
    Callback = function(state)
        espSettings.HealthBar = state
    end
})

DisplaySection:Toggle({ 
    Title = "Show Head Dot",
    Callback = function(state)
        espSettings.HeadDot = state
    end
})

DisplaySection:Toggle({ 
    Title = "Show Tracer Lines",
    Callback = function(state)
        espSettings.Tracer = state
    end
})

-- ================= 🛠️ UTILITIES & PERFORMANCE (ADVANCED DROPDOWN) =================

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local UtilitiesSection = Tab:Section({
    Title = "Utilities & Tools",
    Icon = "wrench",
    Opened = true
})

UtilitiesSection:Dropdown({
    Title = "Universal Utilities Hub",
    Values = {
        -- กลุ่มที่ 1: การเคลื่อนที่และวาร์ป
        {
            Title = "Click Teleport",
            Desc = "วาร์ปไปจุดที่คลิก (เปิด/ปิดผ่านปุ่มลัด)",
            Icon = "mouse-pointer",
            Callback = function()
                local mouse = LocalPlayer:GetMouse()
                local conn
                conn = mouse.Button1Down:Connect(function()
                    if mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
                    end
                    conn:Disconnect()
                    WindUI:Notify({ Title = "TL Hub", Content = "Click Teleport สำเร็จ!", Duration = 2 })
                end)
            end
        },
        {
            Title = "Save Current Position",
            Desc = "บันทึกพิกัดตำแหน่งปัจจุบันไว้สำหรับวาร์ปกลับ",
            Icon = "bookmark-plus",
            Callback = function()
                getgenv().SavedPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
                WindUI:Notify({ Title = "TL Hub", Content = "บันทึกพิกัดสำเร็จ!", Duration = 2 })
            end
        },
        {
            Title = "Load Saved Position",
            Desc = "วาร์ปกลับไปยังพิกัดที่บันทึกไว้",
            Icon = "map-pin",
            Callback = function()
                if getgenv().SavedPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().SavedPos
                    WindUI:Notify({ Title = "TL Hub", Content = "วาร์ปกลับจุดที่บันทึกแล้ว!", Duration = 2 })
                else
                    WindUI:Notify({ Title = "TL Hub", Content = "ยังไม่ได้บันทึกพิกัด!", Duration = 2 })
                end
            end
        },
        
        { Type = "Divider" },

        -- กลุ่มที่ 2: ความปลอดภัย & ป้องกันตัว
        {
            Title = "Anti-Void Protection",
            Desc = "ดึงตัวละครกลับขึ้นมาถ้าตกลงไปในหลุม/ใต้แมพ",
            Icon = "shield-alert",
            Callback = function()
                task.spawn(function()
                    while task.wait(0.5) do
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            if char.HumanoidRootPart.Position.Y < -100 then
                                char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 150, 0)
                            end
                        end
                    end
                end)
                WindUI:Notify({ Title = "TL Hub", Content = "เปิดระบบ Anti-Void เรียบร้อย", Duration = 2 })
            end
        },
        {
            Title = "Anti-Fling / Anti-Bring",
            Desc = "ป้องกันคนอื่นชนตัวเรากระเด็นออกนอกแมพ",
            Icon = "shield-check",
            Callback = function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 100, 100)
                        end
                    end
                end
                WindUI:Notify({ Title = "TL Hub", Content = "เปิดระบบ Anti-Fling แล้ว", Duration = 2 })
            end
        },

        { Type = "Divider" },

        -- กลุ่มที่ 3: ระบบเซิร์ฟเวอร์ & เครื่องมือ
        {
            Title = "Server Hop (Random)",
            Desc = "สุ่มย้ายไปเซิร์ฟเวอร์อื่นเพื่อหาห้องใหม่",
            Icon = "shuffle",
            Callback = function()
                WindUI:Notify({ Title = "TL Hub", Content = "กำลังสุ่มย้ายเซิร์ฟเวอร์...", Duration = 2 })
                local Http = game:GetService("HttpService")
                local TPS = game:GetService("TeleportService")
                local Servers = Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
                for _, s in pairs(Servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TPS:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        break
                    end
                end
            end
        },
        {
            Title = "Instant Rejoin",
            Desc = "กดเพื่อเข้าเซิร์ฟเวอร์เดิมซ้ำทันที",
            Icon = "rotate-cw",
            Callback = function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end
        },
        {
            Title = "FPS Booster (Potato Mode)",
            Desc = "ปิดเงาและเอฟเฟกต์ภาพเพื่อเพิ่มความลื่น",
            Icon = "zap",
            Callback = function()
                local Lighting = game:GetService("Lighting")
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 999999
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.Reflectance = 0
                    end
                end
                WindUI:Notify({ Title = "TL Hub", Content = "เปิดโหมดเพิ่ม FPS แล้ว!", Duration = 2 })
            end
        },

        { Type = "Divider" },

        -- กลุ่มที่ 4: การจัดการ UI
        {
            Title = "Copy Game ID / Place ID",
            Desc = "คัดลอก Place ID ของเกมนี้ไปยังคลิปบอร์ด",
            Icon = "copy",
            Callback = function()
                if setclipboard then
                    setclipboard(tostring(game.PlaceId))
                    WindUI:Notify({ Title = "TL Hub", Content = "คัดลอก Place ID สำเร็จ: " .. game.PlaceId, Duration = 2 })
                end
            end
        },
    }
})

