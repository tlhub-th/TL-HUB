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
