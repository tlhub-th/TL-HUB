local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local WARNING_DELAY = 2.6 -- โซนเตือนสีแดง (รอ 2.6 วิ)
local CLOAKER_DELAY = 0.25 -- ดีเลย์ของ Cloaker
local DAEDALUS_DELAY = 0 -- ดีเลย์ของ Daedalus (0 วิ)
local SHIELDER_DELAY = 0 -- ดีเลย์ของ Shielder (0 วิ)
local TANK_ALERT_DELAY = 1.5 -- ดีเลย์หลังจากเจอ CombatAlert "TANK" (รอ 1.5 วิ)

local PARRY_COOLDOWN = 0.3
local lastParryTime = 0

-- ฟังก์ชันยิง RemoteEvent สั่ง Parry
local function triggerParry()
    if os.clock() - lastParryTime < PARRY_COOLDOWN then return end
    lastParryTime = os.clock()

    local parryEvent = nil
    local currentchar = localPlayer.Character
    local backpack = localPlayer:FindFirstChild("Backpack")
    
    if backpack and backpack:FindFirstChild("BRACE") and backpack.BRACE:FindFirstChild("Parry") then
        parryEvent = backpack.BRACE.Parry
    elseif currentchar and currentchar:FindFirstChild("BRACE") and currentchar.BRACE:FindFirstChild("Parry") then
        parryEvent = currentchar.BRACE.Parry
    end

    if parryEvent then
        parryEvent:FireServer("start")
        print("[Auto-Parry] 🛡️ Parry Executed!")
    else
        pcall(function()
            localPlayer.Backpack.BRACE.Parry:FireServer("start")
            print("[Auto-Parry] 🛡️ Parry Executed (Direct Path)!")
        end)
    end
end

-- ==========================================
-- 1. โซนเตือนสีแดง (Warning - Wait 2.6s)
-- ==========================================
local function checkWarning(obj)
    if obj.Name:lower():find("warning") then
        print("[Auto-Parry] ⚠️ Detected Warning: " .. obj:GetFullName())
        task.delay(WARNING_DELAY, function()
            triggerParry()
        end)
    end
end

for _, desc in ipairs(workspace:GetDescendants()) do checkWarning(desc) end
workspace.DescendantAdded:Connect(checkWarning)

-- ==========================================
-- 2. โซน RailgunImpact (Parry ทันทีเมื่อพบ)
-- ==========================================
local function checkRailgun(obj)
    if obj.Name:lower():find("railgunimpact") then
        print("[Auto-Parry] ⚡ Detected RailgunImpact! Parrying Instantly.")
        triggerParry()
    end
end

for _, desc in ipairs(workspace:GetDescendants()) do checkRailgun(desc) end
workspace.DescendantAdded:Connect(checkRailgun)

-- ==========================================
-- 3. โซน CombatAlert (ดักจับ "TANK" และ "SNIPER")
-- ==========================================
pcall(function()
    local combatAlertEvent = ReplicatedStorage.Remotes.Replication.CombatAlert
    if combatAlertEvent then
        combatAlertEvent.OnClientEvent:Connect(function(alertType, ...)
            if type(alertType) == "string" then
                local upperAlert = alertType:upper()
                
                -- Tank Alert (รอ 1.5 วิ)
                if upperAlert == "TANK" then
                    print("[Auto-Parry] 🛡️ CombatAlert: TANK! Waiting " .. TANK_ALERT_DELAY .. "s...")
                    task.delay(TANK_ALERT_DELAY, function()
                        triggerParry()
                    end)
                
                -- Sniper Alert (Parry ทันที)
                elseif upperAlert == "SNIPER" then
                    print("[Auto-Parry] 🎯 CombatAlert: SNIPER! Parrying Instantly.")
                    triggerParry()
                end
            end
        end)
        print("[Auto-Parry] 📡 CombatAlert Listener Attached!")
    end
end)

-- ==========================================
-- 4. โซนเช็คระยะประชิด (Cloaker, Daedalus & Shielder)
-- ==========================================
localPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
end)

RunService.RenderStepped:Connect(function()
    if not rootPart or not rootPart.Parent then return end

    local myPos = rootPart.Position

    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") then
            local objName = obj.Name:lower()
            local modelRoot = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso")
            
            if modelRoot then
                local distance = (modelRoot.Position - myPos).Magnitude

                -- เช็ค Cloaker (ระยะ 10 Studs)
                if distance <= 10 and objName:find("cloaker") then
                    task.delay(CLOAKER_DELAY, function()
                        triggerParry()
                    end)
                    break
                
                -- เช็ค Daedalus (ระยะ 10 Studs)
                elseif distance <= 10 and objName:find("daedalus") then
                    task.delay(DAEDALUS_DELAY, function()
                        triggerParry()
                    end)
                    break

                -- เช็ค Shielder (ระยะ 30 Studs -> ดีเลย์ 0 วิ)
                elseif distance <= 30 and objName:find("shielder") then
                    task.delay(SHIELDER_DELAY, function()
                        triggerParry()
                    end)
                    break
                end
            end
        end
    end
end)

print("[Auto-Parry] 🚀 Active: Warning, Railgun, Tank, Sniper, Cloaker, Daedalus & Shielder (30 Studs, 0s Delay)")
