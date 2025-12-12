local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local vu1 = {
    cache = {}
}

-- Module A: RedeemCode
local function vu9()
    local vu2 = game:GetService("ReplicatedStorage")
    local vu3 = nil
    pcall(function()
        vu3 = vu2:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10):WaitForChild("CodeService", 10):WaitForChild("RF", 10):WaitForChild("RedeemCode", 10)
    end)
    local vu4 = {
        "100KLIKES", "40KLIKES", "20KLIKES", "15KLIKES", "10KLIKES", "5KLIKES",
        "BETARELEASE!", "POSTRELEASEQNA", "100K!", "200K!"
    }
    return function()
        if vu3 then
            for _, code in ipairs(vu4) do
                task.spawn(function()
                    vu3:InvokeServer(code)
                end)
                task.wait(0.2)
            end
        end
    end
end
function vu1.a()
    local v10 = vu1.cache.a
    if not v10 then
        v10 = { c = vu9() }
        vu1.cache.a = v10
    end
    return v10.c
end

-- Module B: Movement/Noclip
local function vu43()
    local vu11 = game:GetService("TweenService")
    local vu12 = game:GetService("RunService")
    local vu13 = game:GetService("Players")
    local vu14 = {}
    local vu15 = nil
    local vu16 = 0
    local vu17 = nil
    local function vu18()
        if not vu17 then
            vu17 = Instance.new("Part")
            vu17.Name = "TweenPlatform"
            vu17.Size = Vector3.new(6, 1, 6)
            vu17.Transparency = 1
            vu17.Anchored = true
            vu17.CanCollide = true
            vu17.CastShadow = false
        end
        return vu17
    end
    local function vu25()
        local v19 = vu13.LocalPlayer.Character
        if v19 then
            for _, v23 in pairs(v19:GetDescendants()) do
                if v23:IsA("BasePart") and v23.CanCollide == true then
                    v23.CanCollide = false
                end
            end
            local v24 = v19:FindFirstChild("HumanoidRootPart")
            if v24 and (vu17 and vu17.Parent) then
                vu17.CFrame = v24.CFrame * CFrame.new(0, - 3.5, 0)
            end
        end
    end
    local function vu30(p26)
        if not p26:FindFirstChild("HazeBodyVelocity") then
            local v27 = Instance.new("BodyVelocity")
            v27.Name = "HazeBodyVelocity"
            v27.Velocity = Vector3.zero
            v27.MaxForce = Vector3.new(9000000000, 9000000000, 9000000000)
            v27.Parent = p26
        end
        if not p26:FindFirstChild("HazeBodyAngularVelocity") then
            local v28 = Instance.new("BodyAngularVelocity")
            v28.Name = "HazeBodyAngularVelocity"
            v28.AngularVelocity = Vector3.zero
            v28.MaxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
            v28.Parent = p26
        end
        local v29 = p26.Parent:FindFirstChild("Humanoid")
        if v29 then
            v29.PlatformStand = true
        end
    end
    local function vu35(p31)
        local v32 = p31:FindFirstChild("HazeBodyVelocity")
        if v32 then v32:Destroy() end
        local v33 = p31:FindFirstChild("HazeBodyAngularVelocity")
        if v33 then v33:Destroy() end
        local v34 = p31.Parent:FindFirstChild("Humanoid")
        if v34 then v34.PlatformStand = false end
    end
    function vu14.EnableNoclip()
        if not vu15 then
            vu15 = vu12.Stepped:Connect(vu25)
        end
        vu18().Parent = workspace
    end
    function vu14.DisableNoclip()
        if vu15 and vu16 <= 0 then
            vu15:Disconnect()
            vu15 = nil
            if vu17 then vu17.Parent = nil end
        end
    end
    function vu14.TweenMove(pu36, p37, p38)
        if pu36 then
            local v39 = p38 or 24
            local v40 = (pu36.Position - p37.Position).Magnitude
            if v40 < 5 then
                pu36.CFrame = p37
                return 0
            end
            local v41 = v40 / v39
            vu16 = vu16 + 1
            vu14.EnableNoclip()
            vu30(pu36)
            local v42 = vu11:Create(pu36, TweenInfo.new(v41, Enum.EasingStyle.Linear), {
                CFrame = p37
            })
            v42.Completed:Connect(function()
                vu16 = vu16 - 1
                vu14.DisableNoclip()
                if vu16 <= 0 and pu36 then
                    vu35(pu36)
                end
            end)
            v42:Play()
            return v41
        end
    end
    return vu14
end
function vu1.b()
    local v44 = vu1.cache.b
    if not v44 then
        v44 = { c = vu43() }
        vu1.cache.b = v44
    end
    return v44.c
end

-- Module C: Auto Mine
local function vu145()
    local vu45 = game:GetService("ReplicatedStorage")
    local vu46 = game:GetService("RunService")
    local vu47 = vu1.b()
    local vu48 = nil
    pcall(function()
        vu48 = vu45:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10):WaitForChild("ToolService", 10):WaitForChild("RF", 10):WaitForChild("ToolActivated", 10)
    end)
    return function(pu49, pu50, pu51)
        local function v67()
            local v52 = {}
            local v53 = {}
            local v54 = workspace:FindFirstChild("Rocks")
            if v54 then
                for _, v58 in ipairs(v54:GetChildren()) do
                    for _, v62 in ipairs(v58:GetChildren()) do
                        if v62.Name ~= "SpawnLocation" then
                            if v62:IsA("Model") and (v62:FindFirstChild("Hitbox") and not v53[v62.Name]) then
                                v53[v62.Name] = true
                                table.insert(v52, v62.Name)
                            end
                        else
                            for _, v66 in ipairs(v62:GetChildren()) do
                                if v66:IsA("Model") and (v66:FindFirstChild("Hitbox") and not v53[v66.Name]) then
                                    v53[v66.Name] = true
                                    table.insert(v52, v66.Name)
                                end
                            end
                        end
                    end
                end
            end
            table.sort(v52)
            return v52
        end
        if pu51 then
            pu51.GetRockTypes = v67
        end
        local vu68 = 0
        local function vu80()
            local v69 = {}
            local v70 = workspace:FindFirstChild("Rocks")
            if not v70 then return v69 end
            for _, v74 in ipairs(v70:GetDescendants()) do
                if v74.Name == "Hitbox" and v74:IsA("BasePart") then
                    local v75 = v74.Parent
                    if v75 then v75 = v74.Parent.Name end
                    local v76
                    if pu49.MineTargets and v75 then
                        v76 = pu49.MineTargets[v75]
                    else
                        v76 = false
                    end
                    if not v76 and (pu49.MineTarget and v75) then
                        v76 = v75 == pu49.MineTarget
                    end
                    if v76 then
                        local v77 = v74.Parent:FindFirstChild("infoFrame")
                        local v78 = v77 and v77:FindFirstChild("Frame") and v77.Frame:FindFirstChild("rockHP")
                        if v78 then
                            v78 = v77.Frame.rockHP.Text
                        end
                        if v78 then
                            local v79 = tonumber(v78:gsub(",", ""):match("^(%d+)"))
                            if v79 and 0 < v79 then
                                table.insert(v69, v74)
                            end
                        else
                            table.insert(v69, v74)
                        end
                    end
                end
            end
            return v69
        end
        local function vu101(p81, p82)
            local v83 = pu50.Character
            if not (v83 and v83:FindFirstChild("HumanoidRootPart")) then
                return nil
            end
            local v84 = v83.HumanoidRootPart
            local v88 = p81 or 15
            local v89 = nil
            for _, v90 in ipairs(vu80()) do
                if v90 ~= p82 then
                    local v91 = (v90.Position - v84.Position).Magnitude
                    if v91 < v88 then
                        v89 = v90
                        v88 = v91
                    end
                end
            end
            if not v89 then
                if os.clock() - vu68 > 60 then
                    if pu51 and pu51.Notify then
                        pu51.Notify("Auto Mine", "Searching for rocks...", 5)
                    end
                    vu68 = os.clock()
                end
                local v92 = workspace:FindFirstChild("Proximity")
                if v92 then
                    local v96 = {}
                    for _, v97 in ipairs(v92:GetChildren()) do
                        if v97:IsA("Model") and v97.PrimaryPart then
                            table.insert(v96, v97.PrimaryPart.CFrame)
                        elseif v97:IsA("BasePart") then
                            table.insert(v96, v97.CFrame)
                        end
                    end
                    if # v96 > 0 then
                        local v98 = v83:FindFirstChild("HumanoidRootPart")
                        if v98 then
                            local v99 = v96[math.random(1, # v96)]
                            local v100 = vu47.TweenMove(v98, v99 + Vector3.new(0, - 10, 0))
                            task.wait(1 + v100)
                        end
                    end
                end
            end
            return v89
        end
        local vu102 = nil
        local vu103 = 0
        local vu104 = nil
        local vu105 = 0
        local vu106 = false
        local vu107 = 0
        local vu108 = nil
        local vu109 = 0
        vu46.Heartbeat:Connect(function()
            local v110 = pu50.Character
            local v111
            if v110 then v111 = v110:FindFirstChild("HumanoidRootPart") else v111 = v110 end
            if v110 then v110 = v110:FindFirstChild("Humanoid") end
            if pu49.AutoMine and (vu102 and (vu102.Parent and (v111 and v110))) then
                if v110.Health < vu105 and vu105 - v110.Health >= 5 then
                    vu106 = true
                    vu107 = os.clock()
                end
                vu105 = v110.Health
                if vu106 and os.clock() - vu107 > 3 then
                    vu106 = false
                end
                local v112 = vu102.Position
                local v113 = v112 - Vector3.new(0, 5, 0)
                local v114 = false
                if pu49.MineLavaCheck then
                    if not (vu104 and vu104.Parent) then
                        local v115 = workspace:FindFirstChild("Assets")
                        if v115 then v115 = v115:FindFirstChild("Cave Area [2]") end
                        if v115 then v115 = v115:FindFirstChild("Lava") end
                        vu104 = v115
                    end
                    if vu104 and vu104:IsA("BasePart") then
                        local v116 = vu104.CFrame:PointToObjectSpace(v113)
                        local v117 = vu104.Size
                        v114 = math.abs(v116.X) <= v117.X / 2 and (math.abs(v116.Y) <= v117.Y / 2 and math.abs(v116.Z) <= v117.Z / 2) and true or v114
                    end
                    v114 = vu106 and true or v114
                end
                if v114 then
                    v113 = v112 + Vector3.new(5, 0, 0)
                end
                if (vu47.TweenMove(v111, CFrame.lookAt(v113, v112)) or 0) > 0 then
                    vu109 = os.clock()
                end
            elseif v110 then
                vu105 = v110.Health
            end
        end)
        task.spawn(function()
            while true do
                while true do
                    task.wait(0.1)
                    if pu51.ConsumingPotion then
                        while pu51.ConsumingPotion do task.wait(0.1) end
                    end
                    local v118 = pu50.Character
                    local v119
                    if v118 then v119 = v118:FindFirstChild("HumanoidRootPart") else v119 = v118 end
                    if pu49.AutoMine and (vu48 and (v119 and v118:FindFirstChild("Humanoid"))) then
                        break
                    end
                    vu102 = nil
                end
                local v120 = nil 
                if pu50.Character then v120 = pu50.Character:FindFirstChildWhichIsA("Tool") end
                local v121
                if v120 and v120.Name:lower():match("pickaxe") then
                    v121 = v120
                end
                if pu50.Backpack then
                    for _, v124 in ipairs(pu50.Backpack:GetChildren()) do
                         if v124:IsA("Tool") and v124.Name:lower():match("pickaxe") then
                            v121 = v124
                            break
                        end
                    end
                end
                 if v121 and pu50.Character and pu50.Character:FindFirstChild("Humanoid") then
                    pu50.Character.Humanoid:EquipTool(v121)
                end

                local v125 = false
                if vu102 and vu102.Parent then
                    local v126 = vu102.Parent
                    if v126 then v126 = vu102.Parent.Name end
                    local v127
                    if pu49.MineTargets and v126 then
                        v127 = pu49.MineTargets[v126]
                    else
                        v127 = false
                    end
                    if not v127 and (pu49.MineTarget and v126) then
                        v127 = v126 == pu49.MineTarget
                    end
                    if v127 then
                        local v128 = vu102.Parent:FindFirstChild("infoFrame")
                        local v129 = v128 and v128:FindFirstChild("Frame") and v128.Frame:FindFirstChild("rockHP")
                        if v129 then v129 = v128.Frame.rockHP.Text end
                        if v129 then
                            local v130 = tonumber(v129:match("^(%d+)"))
                            v125 = v130 and 0 < v130 and true or v125
                        else
                            v125 = true
                        end
                    end
                end
                if not v125 then vu102 = nil end
                local v131 = not vu102 and vu101(500)
                if v131 then
                    vu102 = v131
                    local v132 = vu47.TweenMove(pu50.Character.HumanoidRootPart, CFrame.lookAt(v131.Position, v131.Position)) or 0
                    vu103 = os.clock() + 0.5 + v132
                    vu108 = nil
                    vu109 = os.clock() + v132
                end
                local v133 = vu102
                if v121 and (v133 and (pu50.Character.Humanoid.Health > 0 and v133.Parent)) then
                    local v134 = v133.Parent:FindFirstChild("infoFrame")
                    local v135 = v134 and v134:FindFirstChild("Frame") and v134.Frame:FindFirstChild("rockHP")
                    if v135 then v135 = v134.Frame.rockHP.Text end
                    if v135 then v135 = tonumber(v135:gsub(",", ""):match("^(%d+)")) end
                    if v135 then
                        if vu108 then
                            if v135 >= vu108 then
                                if os.clock() - vu109 > 8 and os.clock() > vu103 + 2 then
                                    local v136 = vu101(500, v133)
                                    if v136 then
                                        vu102 = v136
                                        local v137 = vu47.TweenMove(pu50.Character.HumanoidRootPart, CFrame.lookAt(v136.Position, v136.Position)) or 0
                                        vu103 = os.clock() + 0.5 + v137
                                        vu108 = nil
                                        vu109 = os.clock() + v137
                                        v133 = vu102
                                    else
                                        vu109 = os.clock()
                                    end
                                end
                            else
                                vu108 = v135
                                vu109 = os.clock()
                            end
                        else
                            vu108 = v135
                            vu109 = os.clock()
                        end
                    end
                    if vu103 < os.clock() and (pu50.Character.HumanoidRootPart.Position - v133.Position).Magnitude <= 15 then
                        vu48:InvokeServer("Pickaxe")
                    end
                    task.wait(0.1)
                elseif not (v133 and v133.Parent) then
                    vu102 = nil
                end
            end
        end)
    end
end
function vu1.c()
    local v146 = vu1.cache.c
    if not v146 then
        v146 = { c = vu145() }
        vu1.cache.c = v146
    end
    return v146.c
end

-- Module D: Auto Run
local function vu152()
    local vu147 = game:GetService("ReplicatedStorage")
    local vu148 = nil
    pcall(function()
        vu148 = vu147:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10):WaitForChild("CharacterService", 10):WaitForChild("RF", 10):WaitForChild("Run", 10)
    end)
    return function(pu149, pu150, _)
        task.spawn(function()
            while true do
                repeat task.wait(0.1) until pu149.AutoRun and vu148
                local v151 = pu150.Character
                if v151 and (v151:FindFirstChild("Humanoid") and v151.Humanoid.Health > 0) then
                    vu148:InvokeServer()
                end
            end
        end)
    end
end
function vu1.d()
    local v153 = vu1.cache.d
    if not v153 then
        v153 = { c = vu152() }
        vu1.cache.d = v153
    end
    return v153.c
end

-- Module E: Auto Attack
local function vu237()
    local v154 = game:GetService("ReplicatedStorage")
    local vu155 = game:GetService("RunService")
    local vu156 = vu1.b()
    local v157 = v154:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10):WaitForChild("ToolService", 10)
    local vu158 = v157:WaitForChild("RF", 10):WaitForChild("ToolActivated", 10)
    local vu159 = v157:WaitForChild("RF", 10):WaitForChild("StartBlock", 10)
    local vu160 = v157:WaitForChild("RF", 10):WaitForChild("StopBlock", 10)
    return function(pu161, pu162, pu163)
        local vu164 = {}
        local function v174()
            local v165 = {}
            local v166 = {}
            local v167 = workspace:FindFirstChild("Living")
            local v168 = game:GetService("Players")
            if v167 then
                for _, v172 in ipairs(v167:GetChildren()) do
                    if v172:IsA("Model") and (v172:FindFirstChild("Humanoid") and not (v168:GetPlayerFromCharacter(v172) or v172:FindFirstChild("RaceFolder"))) then
                        local v173 = v172.Name:gsub("%d+$", ""):match("^%s*(.-)%s*$")
                        if not v166[v173] then
                            v166[v173] = true
                            table.insert(v165, v173)
                        end
                    end
                end
            end
            table.sort(v165)
            return v165
        end
        if pu163 then
            pu163.GetMobTypes = v174
        end
        local function vu183()
            local v175 = {}
            local v176 = workspace:FindFirstChild("Living")
            if not v176 then return v175 end
            local v177 = game:GetService("Players")
            for _, v181 in ipairs(v176:GetChildren()) do
                if v181:IsA("Model") and v181:FindFirstChild("Humanoid") then
                    local v182 = v181.Name:gsub("%d+$", ""):match("^%s*(.-)%s*$")
                    if pu161.AttackTargets and (pu161.AttackTargets[v182] and (not v177:GetPlayerFromCharacter(v181) and (not v181:FindFirstChild("RaceFolder") and (v181.Humanoid.Health > 0 and v181:FindFirstChild("HumanoidRootPart"))))) then
                        table.insert(v175, v181)
                    end
                end
            end
            return v175
        end
        local function vu196(p184)
            local v185 = pu162.Character
            if not (v185 and v185:FindFirstChild("HumanoidRootPart")) then
                return nil
            end
            local v186 = v185.HumanoidRootPart
            local v190 = p184 or 100
            local v191 = nil
            for _, v192 in ipairs(vu183()) do
                local v193 = false
                if vu164[v192] then
                    if os.clock() - vu164[v192] <= 10 then
                        v193 = true
                    else
                        vu164[v192] = nil
                    end
                end
                if not v193 then
                    local v194 = v192:FindFirstChild("HumanoidRootPart")
                    if v194 then
                        local v195 = (v194.Position - v186.Position).Magnitude
                        if v195 < v190 then
                            v191 = v192
                            v190 = v195
                        end
                    end
                end
            end
            return v191
        end
        local vu197 = nil
        local vu198 = false
        local vu199 = 0
        local vu200 = 0
        local vu201 = 0
        local vu202 = nil
        local vu203 = 0
        local vu204 = false
        local vu205 = 0
        vu155.Heartbeat:Connect(function()
            local v206 = pu162.Character
            local v207
            if v206 then v207 = v206:FindFirstChild("HumanoidRootPart") else v207 = v206 end
            if v206 then v206 = v206:FindFirstChild("Humanoid") end
            if pu161.AutoAttack and (vu197 and (vu197.Parent and (v207 and v206))) then
                if v206.Health < vu203 and vu203 - v206.Health >= 5 then
                    vu204 = true
                    vu205 = os.clock()
                end
                vu203 = v206.Health
                if vu204 and os.clock() - vu205 > 3 then
                    vu204 = false
                end
                local v208 = vu197:FindFirstChild("HumanoidRootPart")
                if v208 then
                    local v209 = v208.Position - Vector3.new(0, 6, 0)
                    local v210 = false
                    if pu161.AttackLavaCheck then
                        if not (vu202 and vu202.Parent) then
                            local v211 = workspace:FindFirstChild("Assets")
                            if v211 then v211 = v211:FindFirstChild("Cave Area [2]") end
                            if v211 then v211 = v211:FindFirstChild("Lava") end
                            vu202 = v211
                        end
                        if vu202 and vu202:IsA("BasePart") then
                            local v212 = vu202.CFrame:PointToObjectSpace(v209)
                            local v213 = vu202.Size
                            v210 = math.abs(v212.X) <= v213.X / 2 and (math.abs(v212.Y) <= v213.Y / 2 and math.abs(v212.Z) <= v213.Z / 2) and true or v210
                        end
                        v210 = vu204 and true or v210
                    end
                    if v210 then
                        v209 = (v208.CFrame * CFrame.new(0, 0, 3)).Position
                    end
                    if (vu156.TweenMove(v207, CFrame.lookAt(v209, v208.Position)) or 0) > 0 then
                        vu201 = vu201 + vu155.Heartbeat:Wait()
                        vu201 = os.clock()
                    end
                end
            elseif v206 then
                vu203 = v206.Health
            end
        end)
        task.spawn(function()
            while true do
                while true do
                    task.wait(0.1)
                    if pu163.ConsumingPotion then
                        while pu163.ConsumingPotion do task.wait(0.1) end
                    end
                    local v214 = pu162.Character
                    local v215
                    if v214 then v215 = v214:FindFirstChild("HumanoidRootPart") else v215 = v214 end
                    if pu161.AutoAttack and (vu158 and (v215 and v214:FindFirstChild("Humanoid"))) then
                        break
                    end
                    vu197 = nil
                    if vu198 then
                        pcall(function() vu160:InvokeServer() end)
                        vu198 = false
                    end
                end
                
                local v217 = nil
                 if pu162.Character then v217 = pu162.Character:FindFirstChildWhichIsA("Tool") end
                 if not (v217 and v217.Name:lower():match("weapon")) then
                    v217 = nil
                 end
                if pu162.Backpack then
                   for _, t in ipairs(pu162.Backpack:GetChildren()) do
                       if t:IsA("Tool") and t.Name:lower():match("weapon") then
                           v217 = t
                           break
                       end
                   end
                end
                if v217 and pu162.Character and pu162.Character:FindFirstChild("Humanoid") then
                    pu162.Character.Humanoid:EquipTool(v217)
                end

                local v221 = false
                if vu197 and vu197.Parent and vu197:FindFirstChild("Humanoid") then
                    local v222 = vu197.Name:gsub("%d+$", "")
                    v221 = vu197.Humanoid.Health > 0 and (pu161.AttackTargets and pu161.AttackTargets[v222]) and true or v221
                end
                if not v221 then
                    vu197 = nil
                    if vu198 then
                        vu160:InvokeServer()
                        vu198 = false
                    end
                end
                if not vu197 then
                    vu197 = vu196(500)
                    if vu197 and vu197:FindFirstChild("Humanoid") then
                        vu200 = vu197.Humanoid.Health
                        vu201 = os.clock()
                    end
                    if not vu197 then
                        if os.clock() - vu199 > 60 then
                            if pu163 and pu163.Notify then
                                pu163.Notify("Auto Attack", "Searching for mobs...", 5)
                            end
                            vu199 = os.clock()
                        end
                        -- Teleport to Proximity items logic if no mobs
                        local v223 = workspace:FindFirstChild("Proximity")
                        if v223 then
                            local v227 = {}
                            for _, v228 in ipairs(v223:GetChildren()) do
                                if v228:IsA("Model") and v228.PrimaryPart then
                                    table.insert(v227, v228.PrimaryPart.CFrame)
                                elseif v228:IsA("BasePart") then
                                    table.insert(v227, v228.CFrame)
                                end
                            end
                            if # v227 > 0 then
                                local v229 = pu162.Character:FindFirstChild("HumanoidRootPart")
                                if v229 then
                                    local v230 = v227[math.random(1, # v227)]
                                    local v231 = vu156.TweenMove(v229, v230 + Vector3.new(0, - 10, 0))
                                    task.wait(1 + v231)
                                end
                            end
                        end
                    end
                end
                if vu197 and vu197.Parent and vu197:FindFirstChild("Humanoid") then
                    local v232 = vu197.Humanoid.Health
                    if v232 < vu200 then
                        vu201 = os.clock()
                    end
                    if os.clock() - vu201 > 15 then
                        if pu163 and pu163.Notify then
                            pu163.Notify("Auto Attack", "Target stuck/glitched. Skipping...", 2)
                        end
                        vu164[vu197] = os.clock()
                        vu197 = nil
                    end
                    vu200 = v232
                end
                local v233 = vu197
                if v217 and (v233 and (pu162.Character.Humanoid.Health > 0 and v233.Parent)) then
                    local v234 = false
                    if pu161.AutoParry then
                        local v235 = v233:FindFirstChild("Status")
                        if v235 then v235 = v235:FindFirstChild("Attacking") end
                        v234 = v235 and v235.Value == true and true or v234
                    end
                    if v234 then
                        if not vu198 then
                            vu159:InvokeServer()
                            vu198 = true
                        end
                    else
                        if vu198 then
                            vu160:InvokeServer()
                            vu198 = false
                        end
                        local v236 = v233:FindFirstChild("HumanoidRootPart")
                        if v236 and (pu162.Character.HumanoidRootPart.Position - v236.Position).Magnitude <= 15 then
                            vu158:InvokeServer("Weapon")
                        end
                    end
                elseif not (v233 and v233.Parent) then
                    vu197 = nil
                    if vu198 then
                        vu160:InvokeServer()
                        vu198 = false
                    end
                end
            end
        end)
    end
end
function vu1.e()
    local v238 = vu1.cache.e
    if not v238 then
        v238 = { c = vu237() }
        vu1.cache.e = v238
    end
    return v238.c
end

-- Module F: Instant Forge & Ore Scraper
local function vu315()
    local vu239 = game:GetService("ReplicatedStorage")
    local vu240 = game:GetService("RunService")
    local vu241 = game:GetService("TweenService")
    local vu242 = game:GetService("Players")
    local vu243 = game:GetService("Workspace")

    local v267 = vu239
    vu239:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10):WaitForChild("ForgeService", 10):WaitForChild("RF", 10):WaitForChild("ChangeSequence", 10)
    
    local function vu294(pu268, p269, p270)
        local v271 = vu239:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services")
        local v272 = v271:WaitForChild("ForgeService"):WaitForChild("RF")
        local v273 = v271:WaitForChild("ProximityService"):WaitForChild("RF")
        local vu274 = v272:WaitForChild("ChangeSequence")
        local vu275 = v272:WaitForChild("StartForge")
        local vu276 = v273:WaitForChild("Forge")
        local vu277 = vu243:WaitForChild("Proximity"):WaitForChild("Forge")
        if vu274 and (vu275 and (vu276 and vu277)) then
            local vu278 = p269 or "Weapon"
            -- Helper for status notifications if callback provided
            local function notify(title, msg, dur)
                if p270 then p270(title, msg, dur or 2) end
            end

            local v290, v291 = pcall(function()
                notify("Instant Forge", "Connecting to Forge...", 2)
                vu276:InvokeServer(vu277)
                task.wait(0.1)
                -- notify("Instant Forge", "Igniting Furnace...", 0.2)
                vu275:InvokeServer(vu277)
                task.wait(0.1)
                -- notify("Instant Forge", "Melting Ores...", 0.35)
                local v280 = {
                    "Melt",
                    {
                        FastForge = false,
                        ItemType = vu278,
                        Ores = pu268
                    }
                }
                vu274:InvokeServer(unpack(v280))
                -- notify("Instant Forge", "Smelting in process...", 0.45)
                task.wait(2)
                -- notify("Instant Forge", "Preparing to pour...", 0.55)
                task.wait(2)
                -- notify("Instant Forge", "Pouring Molten Metal...", 0.65)
                local v281 = vu274
                local v282 = v281.InvokeServer
                local v283 = {
                    ClientTime = vu243:GetServerTimeNow()
                }
                v282(v281, "Pour", v283)
                task.wait(0.3)
                -- notify("Instant Forge", "Hammering & Shaping...", 0.8)
                local v284 = vu274
                local v285 = v284.InvokeServer
                local v286 = {
                    ClientTime = vu243:GetServerTimeNow()
                }
                v285(v284, "Hammer", v286)
                task.wait(0.3)
                -- notify("Instant Forge", "Cooling Blade...", 0.9)
                task.spawn(function()
                    local v287 = vu274
                    local v288 = v287.InvokeServer
                    local v289 = {
                        ClientTime = vu243:GetServerTimeNow()
                    }
                    v288(v287, "Water", v289)
                end)
                task.wait(1)
                notify("Instant Forge", "Finalizing Item!", 2)
                vu274:InvokeServer("Showcase", {})
                task.wait(0.5)
            end)
            if v290 then
                notify("Forge", "Forge Complete!", 5)
            else
                notify("Forge", "Failed: " .. tostring(v291), 5)
            end
        elseif p270 then
            p270("Error", "Failed to find necessary remotes or Forge model.", 5)
        end
    end
    local function vu313()
        local v295 = vu242.LocalPlayer
        if not v295 then return {} end
        local v296 = v295:FindFirstChild("PlayerGui")
        if not v296 then return {} end
        local v297 = v296:FindFirstChild("Forge")
        if not v297 then return {} end
        local v298 = v297:FindFirstChild("OreSelect")
        if not v298 then return {} end
        local v299 = v298:FindFirstChild("OresFrame")
        if not v299 then return {} end
        local v300 = v299:FindFirstChild("Frame")
        if not v300 then return {} end
        local v301 = v300:FindFirstChild("Background")
        if not v301 then return {} end
        local v306 = {}
        for _, v307 in ipairs(v301:GetChildren()) do
            local v308 = v307:FindFirstChild("Main")
            if v308 then v308 = v308:FindFirstChild("Quantity") end
            if v308 then
                local v309 = nil
                if v308:IsA("TextLabel") or (v308:IsA("TextBox") or v308:IsA("TextButton")) then
                    v309 = v308.Text
                else
                    local v310 = v308:FindFirstChild("Text")
                    if v310 and (v310:IsA("TextLabel") or (v310:IsA("TextBox") or v310:IsA("TextButton"))) then
                        v309 = v310.Text
                    end
                end
                if v309 then
                    local v311 = v307.Name
                    local v312 = tonumber(v309:match("%d+"))
                    if v312 then
                        v306[v311] = v312
                    end
                end
            end
        end
        return v306
    end
    return function(_, _, p314)
        if p314 then
            p314.InstantForge = vu294
            p314.GetAvailableOres = vu313
        end
    end
end
function vu1.f()
    local v316 = vu1.cache.f
    if not v316 then
        v316 = { c = vu315() }
        vu1.cache.f = v316
    end
    return v316.c
end

-- Module G: Infinite Fly & Click TP
local function vu338()
    local vu317 = game:GetService("UserInputService")
    local vu318 = game:GetService("RunService")
    local vu319 = vu1.b()
    return function(pu320, pu321, _)
        local vu322 = pu321:GetMouse()
        vu317.InputBegan:Connect(function(p323, p324)
            if not p324 then
                if pu320.ClickTeleport and p323.UserInputType == Enum.UserInputType.MouseButton1 and vu317:IsKeyDown(Enum.KeyCode.LeftControl) then
                    local v325 = pu321.Character
                    if v325 then v325 = v325:FindFirstChild("HumanoidRootPart") end
                    if v325 and vu322.Hit then
                        vu319.TweenMove(v325, CFrame.new(vu322.Hit.Position + Vector3.new(0, 3, 0)))
                    end
                end
            end
        end)
        local vu326 = nil
        local vu327 = nil
        local vu328 = 50
        local vu329 = false
        local function vu331()
            vu329 = false
            if vu326 then vu326:Destroy(); vu326 = nil end
            if vu327 then vu327:Destroy(); vu327 = nil end
            local v330 = pu321.Character
            if v330 then v330 = v330:FindFirstChild("Humanoid") end
            if v330 then v330.PlatformStand = false end
        end
        local function vu337()
            local vu332 = pu321.Character
            local v333; if vu332 then v333 = vu332:FindFirstChild("HumanoidRootPart") else v333 = vu332 end
            local v334; if vu332 then v334 = vu332:FindFirstChild("Humanoid") else v334 = vu332 end
            if v333 and v334 then
                vu329 = true
                v334.PlatformStand = true
                vu326 = Instance.new("BodyGyro", v333)
                vu326.P = 90000
                vu326.maxTorque = Vector3.new(9000000000, 9000000000, 9000000000)
                vu326.cframe = v333.CFrame
                vu327 = Instance.new("BodyVelocity", v333)
                vu327.velocity = Vector3.new(0, 0, 0)
                vu327.maxForce = Vector3.new(9000000000, 9000000000, 9000000000)
                task.spawn(function()
                    while vu329 and vu332.Parent do
                        local v335 = workspace.CurrentCamera
                        local v336 = Vector3.new()
                        if vu317:IsKeyDown(Enum.KeyCode.W) then v336 = v336 + v335.CFrame.LookVector end
                        if vu317:IsKeyDown(Enum.KeyCode.S) then v336 = v336 - v335.CFrame.LookVector end
                        if vu317:IsKeyDown(Enum.KeyCode.A) then v336 = v336 - v335.CFrame.RightVector end
                        if vu317:IsKeyDown(Enum.KeyCode.D) then v336 = v336 + v335.CFrame.RightVector end
                        if v336.Magnitude <= 0 then
                            vu327.velocity = Vector3.new(0, 0, 0)
                        else
                            vu327.velocity = v336.Unit * vu328
                        end
                        vu326.cframe = v335.CFrame
                        vu318.RenderStepped:Wait()
                    end
                    vu331()
                end)
            end
        end
        task.spawn(function()
            while true do
                while true do
                    task.wait(0.2)
                    if not pu320.InfiniteFly then break end
                    if not vu329 and pu321.Character and pu321.Character:FindFirstChild("HumanoidRootPart") then
                        vu337()
                    end
                end
                if vu329 then vu331() end
            end
        end)
        pu321.CharacterAdded:Connect(function()
            if vu329 then vu331() end
        end)
    end
end
function vu1.g()
    local v339 = vu1.cache.g
    if not v339 then
        v339 = { c = vu338() }
        vu1.cache.g = v339
    end
    return v339.c
end

-- Module H: WalkSpeed
local function vu354()
    return function(pu340, pu341, _)
        local vu342 = nil
        local vu343 = nil
        local vu344 = false
        local function vu350()
            if not vu344 then
                vu344 = true
                local function vu346()
                    if vu344 then
                        local v345 = pu341.Character
                        if v345 then v345 = v345:FindFirstChild("Humanoid") end
                        if v345 and (pu340.WalkSpeed and (pu340.WalkSpeed > 16 and v345.WalkSpeed ~= pu340.WalkSpeed)) then
                            v345.WalkSpeed = pu340.WalkSpeed
                        end
                    end
                end
                local function v349(p347)
                    local v348 = p347:WaitForChild("Humanoid", 10)
                    if v348 then
                        vu346()
                        if vu343 then vu343:Disconnect() end
                        vu343 = v348:GetPropertyChangedSignal("WalkSpeed"):Connect(vu346)
                    end
                end
                if pu341.Character then v349(pu341.Character) end
                if vu342 then vu342:Disconnect() end
                vu342 = pu341.CharacterAdded:Connect(v349)
            end
        end
        local function vu352()
            vu344 = false
            if vu343 then vu343:Disconnect(); vu343 = nil end
            if vu342 then vu342:Disconnect(); vu342 = nil end
            local v351 = pu341.Character
            if v351 then v351 = v351:FindFirstChild("Humanoid") end
            if v351 then v351.WalkSpeed = 16 end
        end
        task.spawn(function()
            while true do
                while true do
                    task.wait(0.5)
                    if pu340.WalkSpeed and pu340.WalkSpeed > 16 then break end
                    if vu344 then vu352() end
                end
                if not vu344 then vu350() end
                if vu344 then
                    local v353 = pu341.Character
                    if v353 then v353 = v353:FindFirstChild("Humanoid") end
                    if v353 and v353.WalkSpeed ~= pu340.WalkSpeed then
                        v353.WalkSpeed = pu340.WalkSpeed
                    end
                end
            end
        end)
    end
end
function vu1.h()
    local v355 = vu1.cache.h
    if not v355 then
        v355 = { c = vu354() }
        vu1.cache.h = v355
    end
    return v355.c
end

-- Module I: Auto Sell
local function vu415()
    local vu356 = game:GetService("ReplicatedStorage")
    local vu357 = nil
    local vu358 = nil
    pcall(function()
        local v359 = vu356:WaitForChild("Shared", 10):WaitForChild("Packages", 10):WaitForChild("Knit", 10):WaitForChild("Services", 10)
        local v360 = v359:WaitForChild("DialogueService", 10)
        local v361 = v359:WaitForChild("ProximityService", 10)
        vu357 = v360:WaitForChild("RF", 10):WaitForChild("RunCommand", 10)
        vu358 = v361:WaitForChild("RF", 10):WaitForChild("ForceDialogue", 10)
    end)
    local function vu377(p362)
        local v363 = p362:FindFirstChild("PlayerGui")
        local v364 = {}
        local v365 = v363 and v363:FindFirstChild("Menu") and (v363.Menu:FindFirstChild("Frame") and v363.Menu.Frame:FindFirstChild("Frame") and (v363.Menu.Frame.Frame:FindFirstChild("Menus") and v363.Menu.Frame.Frame.Menus:FindFirstChild("Stash")))
        if v365 then v365 = v363.Menu.Frame.Frame.Menus.Stash:FindFirstChild("Background") end
        if v365 then
            for _, v369 in ipairs(v365:GetChildren()) do
                local v370 = v369:FindFirstChild("Main")
                if v370 then
                    local v371 = v370:FindFirstChild("ItemName")
                    local v372 = v370:FindFirstChild("Quantity")
                    if v371 and (v371:IsA("TextLabel") and (v372 and v372:IsA("TextLabel"))) then
                        local v373 = v371.Text:match("^%s*(.-)%s*$")
                        local v374 = v372.Text
                        if v373 and (v373 ~= "" and not (v373:match("Totem") or v373:match("Portal"))) then
                            local v375 = (v374 == nil or (v374 == "" or (v374 == " " or v374 == 0))) and "1" or v374
                            local v376 = tonumber(v375:match("%d+")) or 1
                            if v376 >= 1 then v364[v373] = v376 end
                        end
                    end
                end
            end
        end
        return v364
    end
    local vu378 = nil
    local vu379 = {}
    local function vu383(p380, p381)
        if vu357 then
            local vu382 = { "SellConfirm", { Basket = { [p380] = tonumber(p381) } } }
            pcall(function() vu357:InvokeServer(unpack(vu382)) end)
        end
    end
    return function(pu384, pu385, pu386)
        if pu386 then
            pu386.GetInventory = vu377
            pu386.SellItem = vu383
        end
        local vu387 = false
        local function vu388()
            if not vu378 then
                vu378 = workspace:WaitForChild("Proximity", 5):WaitForChild("Greedy Cey", 5)
            end
            return vu378
        end
        task.spawn(function()
            while true do
                task.wait(2)
                local v389 = vu388()
                local v390 = false
                if pu384.AutoSellItems then
                    for _, v394 in pairs(pu384.AutoSellItems) do
                        if v394 then v390 = true; break end
                    end
                end
                if v390 and (not vu387 and (vu358 and v389)) then
                    vu358:InvokeServer(v389, "SellConfirmMisc")
                    vu387 = true
                    if pu386.Notify then
                        pu386.Notify("Auto Sell", "Please press 'Deal' on the menu to enable selling.", 8)
                    end
                end
                local v395 = vu377(pu385)
                local v396 = os.clock()
                local v400 = false
                if pu384.AutoSellItems then
                    for v401, v402 in pairs(pu384.AutoSellItems) do
                        if v402 then
                            local v403 = v395[v401]
                            if v403 and (0 < v403 and not vu379[v401]) then
                                vu379[v401] = { quantity = v403, lastChangeTime = v396 }
                            end
                            if v403 and (0 < v403 and vu379[v401]) then
                                if vu379[v401].quantity == v403 then
                                    v400 = v396 - vu379[v401].lastChangeTime > 8 and true or v400
                                else
                                    vu379[v401].quantity = v403
                                    vu379[v401].lastChangeTime = v396
                                end
                            end
                            if (not v403 or v403 <= 0) and vu379[v401] then
                                vu379[v401] = nil
                            end
                            if v403 and 0 < v403 then
                                vu383(v401, v403)
                            end
                        end
                    end
                end
                if v400 and (v389 and vu358) then
                    vu387 = false
                    vu358:InvokeServer(v389, "SellConfirmMisc")
                    for _, v414 in pairs(vu379) do
                        if v414 then v414.lastChangeTime = v396 end
                    end
                    if pu386.Notify then
                        pu386.Notify("Auto Sell", "Re-initialized sell dialogue (stuck items detected).", 5)
                    end
                end
            end
        end)
    end
end
function vu1.i()
    local v416 = vu1.cache.i
    if not v416 then
        v416 = { c = vu415() }
        vu1.cache.i = v416
    end
    return v416.c
end

-- Module J: Server Hop
local function vu435()
    local vu417 = game:GetService("HttpService")
    local vu418 = game:GetService("TeleportService")
    return function(_, pu419, pu420)
        local function v434()
            local v421 = game.PlaceId
            local v422 = game.JobId
            if pu420.Notify then
                pu420.Notify("Server Hop", "Scanning servers for Place: " .. tostring(v421), 2)
            end
            local v423 = {}
            local vu424 = "https://games.roblox.com/v1/games/" .. tostring(v421) .. "/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
            local v425, v426 = pcall(function() return game:HttpGet(vu424) end)
            if v425 then
                local v427 = vu417:JSONDecode(v426)
                if v427 and v427.data then
                    for _, v431 in pairs(v427.data) do
                        if type(v431) == "table" and (tonumber(v431.playing) and (tonumber(v431.maxPlayers) and (v431.playing < v431.maxPlayers and v431.id ~= v422))) then
                            table.insert(v423, v431.id)
                        end
                    end
                end
                if # v423 <= 0 then
                    if pu420.Notify then pu420.Notify("Server Hop", "No suitable servers found.", 3) end
                else
                    local v432 = math.min(5, # v423)
                    local v433 = v423[math.random(1, v432)]
                    if pu420.Notify then pu420.Notify("Server Hop", "Found server! Teleporting...", 3) end
                    vu418:TeleportToPlaceInstance(v421, v433, pu419)
                end
            elseif pu420.Notify then
                pu420.Notify("Error", "Failed to fetch servers API.", 3)
            end
        end
        if pu420 then pu420.ServerHopLow = v434 end
    end
end
function vu1.j()
    local v436 = vu1.cache.j
    if not v436 then
        v436 = { c = vu435() }
        vu1.cache.j = v436
    end
    return v436.c
end

-- Module K: Auto Potion
local function vu466()
    local v437 = game:GetService("ReplicatedStorage")
    local vu438 = game:GetService("Workspace")
    local vu439 = v437:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ProximityService"):WaitForChild("RF"):WaitForChild("Purchase")
    local function vu450(p440, p441, p442)
        if p440.Character then
            local v443 = p440.Character
            local v444 = v443:FindFirstChild("Humanoid")
            if v444 and v444.Health > 0 then
                if string.find(p441, "HealthPotion") and v444.Health >= v444.MaxHealth * 0.5 then
                    return
                else
                    local v445 = p440:FindFirstChild("PlayerGui")
                    if v445 then v445 = v445:FindFirstChild("Hotbar") end
                    if v445 then v445 = v445:FindFirstChild("Perks") end
                    if not (v445 and v445:FindFirstChild(p441)) then
                        local v446 = p440.Backpack:FindFirstChild(p441) or v443:FindFirstChild(p441)
                        if not v446 then
                            local vu447 = { p441, 1 }
                            pcall(function() vu439:InvokeServer(unpack(vu447)) end)
                            v446 = p440.Backpack:WaitForChild(p441, 2)
                        end
                        p442.ConsumingPotion = true
                        task.wait(1)
                        if v446 then
                            if v446.Parent ~= v443 then
                                v444:EquipTool(v446)
                                task.wait(0.2)
                            end
                            local v448 = v443:FindFirstChild(p441)
                            if v448 then v448:Activate() end
                             local vu449 = { p441 }
                             pcall(function()
                                game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated"):InvokeServer(unpack(vu449))
                             end)
                             task.wait(1)
                        end
                    end
                end
            end
        end
    end
    local function vu458()
        local v451 = {}
        local v452 = vu438:FindFirstChild("Proximity")
        if not v452 then return v451 end
        for _, v457 in ipairs(v452:GetChildren()) do
            if v457.Name:match("Potion") then
                v451[v457.Name] = true
            end
        end
        return v451
    end
    return function(pu459, pu460, pu461)
        if pu461 then
            pu461.GetPotionList = vu458
        else
            warn("[DEBUG] Logic: Helper table is missing!")
        end
        task.spawn(function()
            while true do
                if pu459 and pu459.AutoPotions then
                    for v464, v465 in pairs(pu459.AutoPotions) do
                        if v465 then
                            task.wait(0.1)
                            vu450(pu460, v464, pu461)
                            task.wait(2)
                            pu461.ConsumingPotion = false
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end
function vu1.k()
    local v467 = vu1.cache.k
    if not v467 then
        v467 = { c = vu466() }
        vu1.cache.k = v467
    end
    return v467.c
end

repeat task.wait(0.1) until game:IsLoaded()
if game.GameId == 7671049560 then
    if _G.HazePrivate then
        warn("[Haze] UI already initialized")
        return nil
    else
        local vu468 = game.Players.LocalPlayer
        -- Store Config
        local Config = {
            AutoRun = false,
            AutoMine = false,
            MineLavaCheck = true,
            MineTargets = { Pebble = true },
            AutoAttack = false,
            AttackLavaCheck = true,
            AutoParry = false,
            AttackTargets = {},
            ForgeItemType = "Weapon",
            InfiniteFly = false,
            ClickTeleport = false,
            WalkSpeed = 16,
            AutoSellItems = {},
            AutoPotions = {}
        }
        
        -- Logic Initialization
        local vu487 = {}
        function vu487.Notify(title, msg, duration)
             Fluent:Notify({
                 Title = title,
                 Content = msg,
                 Duration = duration or 3
             })
        end
        
        -- Run logic modules
        vu1.c()(Config, vu468, vu487)
        vu1.d()(Config, vu468, vu487)
        vu1.e()(Config, vu468, vu487)
        vu1.f()(Config, vu468, vu487)
        vu1.g()(Config, vu468, vu487)
        vu1.h()(Config, vu468, vu487)
        vu1.i()(Config, vu468, vu487)
        vu1.j()(Config, vu468, vu487)
        vu1.k()(Config, vu468, vu487)

        -- Fluent UI Setup
        local Window = Fluent:CreateWindow({
            Title = "Haze Script " .. (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Game Title"),
            SubTitle = "Refactored by Antigravity",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true,
            Theme = "Dark",
            MinimizeKey = Enum.KeyCode.RightControl
        })

        local Tabs = {
            Main = Window:AddTab({ Title = "Main", Icon = "home" }),
            Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
            Forge = Window:AddTab({ Title = "Forge", Icon = "hammer" }),
            Shop = Window:AddTab({ Title = "Shop", Icon = "shopping-cart" }),
            Potions = Window:AddTab({ Title = "Potions", Icon = "flask-conical" }),
            Player = Window:AddTab({ Title = "Player", Icon = "user" }),
            Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
            Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
        }

        local Options = Fluent.Options

        -- Main Tab (Farming)
        do
            local Section = Tabs.Main:AddSection("Farming")

            local ToggleAutoMine = Section:AddToggle("AutoMine", {Title = "Auto Mine", Default = Config.AutoMine })
            ToggleAutoMine:OnChanged(function() Config.AutoMine = Options.AutoMine.Value end)

            local ToggleMineLava = Section:AddToggle("MineLavaCheck", {Title = "Mine Lava Check", Default = Config.MineLavaCheck })
            ToggleMineLava:OnChanged(function() Config.MineLavaCheck = Options.MineLavaCheck.Value end)

            -- Dynamic Mine Targets
            Section:AddParagraph("MineTargetsHelp", {Title = "Targets", Content = "Select rocks to mine."})
            local MineTargetsDropdown = Section:AddDropdown("MineTargets", {
                Title = "Rock Types",
                Values = {"Pebble"},
                Multi = true,
                Default = {"Pebble"},
            })
            MineTargetsDropdown:OnChanged(function(Value)
                for k, v in pairs(Config.MineTargets) do Config.MineTargets[k] = false end
                for k, v in pairs(Value) do
                    if v then Config.MineTargets[k] = true end
                end
            end)

            -- Live visual updater loop for targets
            task.spawn(function()
                local knownRocks = {}
                while true do
                    if vu487.GetRockTypes then
                        local types = vu487.GetRockTypes()
                        local newFound = false
                        for _, t in ipairs(types) do
                            if not knownRocks[t] then
                                knownRocks[t] = true
                                newFound = true
                            end
                        end
                        if newFound then
                            local values = {}
                            for k, _ in pairs(knownRocks) do table.insert(values, k) end
                            table.sort(values)
                            MineTargetsDropdown:SetValues(values)
                        end
                    end
                    task.wait(5)
                end
            end)
        end

        -- Combat Tab
        do
            local Section = Tabs.Combat:AddSection("Combat")

            local ToggleAutoAttack = Section:AddToggle("AutoAttack", {Title = "Auto Attack", Default = Config.AutoAttack })
            ToggleAutoAttack:OnChanged(function() Config.AutoAttack = Options.AutoAttack.Value end)

            local ToggleAttackLava = Section:AddToggle("AttackLavaCheck", {Title = "Attack Lava Check", Default = Config.AttackLavaCheck })
            ToggleAttackLava:OnChanged(function() Config.AttackLavaCheck = Options.AttackLavaCheck.Value end)

            local ToggleAutoParry = Section:AddToggle("AutoParry", {Title = "Auto Block", Default = Config.AutoParry })
            ToggleAutoParry:OnChanged(function() Config.AutoParry = Options.AutoParry.Value end)
            
            Section:AddParagraph("AttackTargetsHelp", {Title = "Targets", Content = "Select mobs to attack."})
            local AttackTargetsDropdown = Section:AddDropdown("AttackTargets", {
                Title = "Mob Types",
                Values = {},
                Multi = true,
                Default = {},
            })
            AttackTargetsDropdown:OnChanged(function(Value)
                for k, v in pairs(Config.AttackTargets) do Config.AttackTargets[k] = false end
                for k, v in pairs(Value) do
                    if v then Config.AttackTargets[k] = true end
                end
            end)

             task.spawn(function()
                local knownMobs = {}
                while true do
                    if vu487.GetMobTypes then
                        local types = vu487.GetMobTypes()
                        local newFound = false
                        for _, t in ipairs(types) do
                            if not knownMobs[t] then
                                knownMobs[t] = true
                                newFound = true
                            end
                        end
                        if newFound then
                            local values = {}
                            for k, _ in pairs(knownMobs) do table.insert(values, k) end
                            table.sort(values)
                            AttackTargetsDropdown:SetValues(values)
                        end
                    end
                    task.wait(5)
                end
            end)
        end

        -- Forge Tab
        do
            local Section = Tabs.Forge:AddSection("Instant Forge")
            Section:AddParagraph("ForgeWarn", {Title = "WARNING", Content = "If you use Instant Forge, you MUST quit and reopen the game before using the forge manually!"})

            local DropdownForgeType = Section:AddDropdown("ForgeItemType", {
                Title = "Forge Item Type",
                Values = {"Weapon", "Armor"},
                Multi = false,
                Default = Config.ForgeItemType,
            })
            DropdownForgeType:OnChanged(function(Value) Config.ForgeItemType = Value end)
            
            -- Dynamic Ores Sliders
            local OreSliders = {}
            task.spawn(function()
                 local lastOres = {} -- Simple check to avoid redraw spam
                 while true do
                     if vu487.GetAvailableOres then
                         local ores = vu487.GetAvailableOres()
                         -- Check if changes
                         local changed = false
                         for k, v in pairs(ores) do
                             if lastOres[k] ~= v then changed = true break end
                         end
                         if not changed then
                             for k, v in pairs(lastOres) do
                                 if ores[k] == nil then changed = true break end
                             end
                         end

                         if changed then
                             lastOres = {}
                             for k, v in pairs(ores) do lastOres[k] = v end

                             -- Rebuild UI? Fluent doesn't support removing elements easily.
                             -- We will try to update existing or add new ones.
                             -- Note: Removing is tricky.
                             -- For now, we just add sliders for new ores found.
                             -- If an ore disappears (quantity 0), we can just leave it or disable interaction?
                             -- Ideally we clear options, but Fluent doesn't expose it easily.
                             -- We will Add sliders if they don't exist.
                             for oreName, quantity in pairs(ores) do
                                 if not OreSliders[oreName] then
                                     OreSliders[oreName] = Section:AddSlider("Ore_" .. oreName, {
                                         Title = oreName,
                                         Min = 0,
                                         Max = quantity,
                                         Default = 0,
                                         Rounding = 0,
                                     })
                                 else
                                     -- Update max? Fluent Slider has SetValues? No.
                                     -- We can assume the user sees the max in the label if we could update it.
                                     -- Just update if we can, else ignore.
                                 end
                             end
                         end
                     end
                     task.wait(2)
                 end
            end)

            Section:AddButton({
                Title = "Instant Forge",
                Description = "Craft item with selected ores",
                Callback = function()
                    if vu487.InstantForge then
                         local selectedOres = {}
                         local totalCount = 0
                         local typesCount = 0
                         
                         for oreName, slider in pairs(OreSliders) do
                             local val = slider.Value -- Access Fluent Slider value
                             if val > 0 then
                                 selectedOres[oreName] = val
                                 totalCount = totalCount + val
                                 typesCount = typesCount + 1
                             end
                         end
                         
                         if totalCount < 3 then
                             Fluent:Notify({Title = "Error", Content = "You must select at least 3 ores!", Duration = 3})
                             return
                         end
                         if typesCount > 4 then
                             Fluent:Notify({Title = "Error", Content = "Too many ore types! Max 4 allowed.", Duration = 3})
                             return
                         end
                         
                         vu487.InstantForge(selectedOres, Config.ForgeItemType, function(t, m, d) Fluent:Notify({Title=t, Content=m, Duration=d}) end)
                    end
                end
            })
        end

        -- Shop Tab (Auto Sell)
        do
            local Section = Tabs.Shop:AddSection("Auto Sell")
            Section:AddParagraph("ShopDesc", {Title = "Description", Content = "Select items to auto-sell."})
            
            local SellDropdown = Section:AddDropdown("AutoSellItems", {
                Title = "Items to Sell",
                Values = {},
                Multi = true,
                Default = {},
            })
             SellDropdown:OnChanged(function(Value)
                for k, v in pairs(Config.AutoSellItems) do Config.AutoSellItems[k] = false end
                for k, v in pairs(Value) do
                    if v then Config.AutoSellItems[k] = true end
                end
            end)

             task.spawn(function()
                local knownItems = {}
                while true do
                    local inventory = (vu487.GetInventory and vu487.GetInventory(vu468)) or {}
                     local newFound = false
                     -- Flatten inventory to names
                     for name, _ in pairs(inventory) do
                         if not knownItems[name] then
                             knownItems[name] = true
                             newFound = true
                         end
                     end
                     -- Also check configured items even if not in inventory
                     if Config.AutoSellItems then
                        for name, _ in pairs(Config.AutoSellItems) do
                             if not knownItems[name] then
                                 knownItems[name] = true
                                 newFound = true
                             end
                        end
                     end

                    if newFound then
                        local values = {}
                        for k, _ in pairs(knownItems) do table.insert(values, k) end
                        table.sort(values)
                        SellDropdown:SetValues(values)
                    end
                    task.wait(5)
                end
            end)
        end

        -- Potions Tab
        do
            local Section = Tabs.Potions:AddSection("Auto Potions")
            local PotionDropdown = Section:AddDropdown("AutoPotions", {
                Title = "Potions to Auto-Consume",
                Values = {},
                Multi = true,
                Default = {},
            })
             PotionDropdown:OnChanged(function(Value)
                for k, v in pairs(Config.AutoPotions) do Config.AutoPotions[k] = false end
                for k, v in pairs(Value) do
                    if v then Config.AutoPotions[k] = true end
                end
            end)

            task.spawn(function()
                local knownPots = {}
                while true do
                     if vu487.GetPotionList then
                         local pots = vu487.GetPotionList()
                         local newFound = false
                         for name, _ in pairs(pots) do
                             if not knownPots[name] then
                                 knownPots[name] = true
                                 newFound = true
                             end
                         end
                         if newFound then
                            local values = {}
                            for k, _ in pairs(knownPots) do table.insert(values, k) end
                            table.sort(values)
                            PotionDropdown:SetValues(values)
                         end
                     end
                   task.wait(5)
                end
            end)
        end

        -- Player Tab
        do
            local Section = Tabs.Player:AddSection("Movement")
            
            Section:AddToggle("AutoRun", {Title = "Auto Run", Default = Config.AutoRun}):OnChanged(function() Config.AutoRun = Options.AutoRun.Value end)
            Section:AddToggle("InfiniteFly", {Title = "Infinite Fly", Default = Config.InfiniteFly}):OnChanged(function() Config.InfiniteFly = Options.InfiniteFly.Value end)
            Section:AddToggle("ClickTeleport", {Title = "Click TP (Ctrl+Click)", Default = Config.ClickTeleport}):OnChanged(function() Config.ClickTeleport = Options.ClickTeleport.Value end)
            
            Section:AddSlider("WalkSpeed", {Title = "Walk Speed", Min = 16, Max = 100, Default = 16, Rounding = 1}):OnChanged(function(Value) Config.WalkSpeed = Value end)
            
            Section:AddButton({
                Title = "Server Hop (Low)",
                Description = "Find a lower player count server",
                Callback = function()
                     if vu487.ServerHopLow then vu487.ServerHopLow() end
                end
            })

            Tabs.Player:AddSection("Codes"):AddButton({
                Title = "Claim All Codes",
                Callback = function()
                     local redeem = vu1.a()
                     if redeem then
                         redeem()
                         Fluent:Notify({Title = "Codes", Content = "Attempting to claim all codes...", Duration = 3})
                     end
                end
            })
        end

        -- Teleport Tab
        do
            local Section = Tabs.Teleport:AddSection("Locations")
            -- We just list all Proximity items as buttons
            task.spawn(function()
                local v625 = workspace:FindFirstChild("Proximity")
                if v625 then
                    local children = v625:GetChildren()
                    table.sort(children, function(a,b) return a.Name < b.Name end)
                    for _, item in ipairs(children) do
                        if item:IsA("Model") or item:IsA("BasePart") then
                            Section:AddButton({
                                Title = item.Name,
                                Callback = function()
                                    local char = vu468.Character
                                    local root = char and char:FindFirstChild("HumanoidRootPart")
                                    if root then
                                        local targetCF = item:IsA("Model") and (item.PrimaryPart and item.PrimaryPart.CFrame or item:GetPivot()) or item.CFrame
                                        if targetCF then
                                           vu1.b().TweenMove(root, targetCF + Vector3.new(0, 3, 0))
                                        end
                                    end
                                end
                            })
                        end
                    end
                else
                    Section:AddParagraph("NoProx", {Title = "Info", Content = "No Proximity Folder Found"})
                end
            end)
        end

        -- Settings
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("HazeScript")
        SaveManager:SetFolder("HazeScript/TheForge")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)

        Window:SelectTab(1)
        Fluent:Notify({
            Title = "Haze Script",
            Content = "Refactored UI Loaded Successfully",
            Duration = 5
        })
        SaveManager:LoadAutoloadConfig()
    end
end
