-- services --
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local replicatedStorage = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
-- local player
local player = players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character:WaitForChild("HumanoidRootPart")
local humanoid = character:FindFirstChildOfClass("Humanoid")
 -- fluent
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "The Forge GUI",
    SubTitle = "by @ZannID",
    TabWidth = 160,
    Size = UDim2.fromOffset(650, 500),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.K
})

local options = Fluent.Options

local Tabs = {
    oresTab = Window:AddTab({Title = "Ores Tab" , Icon = "hammer"}),
    combatTab = Window:AddTab({Title = "Combat Tab" , Icon = "sword"}),
    teleportTab = Window:AddTab({Title = "Teleport Tab", Icon = "map"}),
    movementTab = Window:AddTab({Title = "Movement Tab", Icon = "plane"}),
    autoSellTab = Window:AddTab({Title = "Auto Sell Tab" , Icon = "dollar-sign"}),
    forgingTab = Window:AddTab({Title = "Forge Tab", Icon = "landmark"}),
    settingsTab = Window:AddTab({Title = "Config", Icon = "settings"})
}

-- Death Connections To Retain Local References

player.CharacterAdded:Connect(function(char)
    character = char
    HRP = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
end)

-- Remotes

local toolActivatedRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
local runCommandRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RF"):WaitForChild("RunCommand")
local dialogueRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ProximityService"):WaitForChild("RF"):WaitForChild("Dialogue")
local dialogueRE = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RE"):WaitForChild("DialogueEvent")
local codeServiceRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CodeService"):WaitForChild("RF"):WaitForChild("RedeemCode")
local startBlockRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("StartBlock")
local stopBlockRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("StopBlock")
local changeSequenceRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ForgeService"):WaitForChild("RF"):WaitForChild("ChangeSequence")
local startForgeRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ForgeService"):WaitForChild("RF"):WaitForChild("StartForge")
local forgeRF = replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ProximityService"):WaitForChild("RF"):WaitForChild("Forge")

-- Modules

local knitModule = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("KnitClient"))
local purchaseModule = require(replicatedStorage:WaitForChild("Controllers"):WaitForChild("ProximityController"):WaitForChild("Purchase"))
local enemiesData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Enemies"))
local islandData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Islands"))
local raritiesData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Rarities"))
local oresData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Ore"))
local materialData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Materials"))
local rockData = require(replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Rock"))

-- Table To Stored Weird Ores (For Auto Mining)

local glitchedOres = {} -- This Will Store Ores As BasePart : time and will remove them once the time passed since the last mining try is more than like 1k seconds

-- More Organized Work

local Utility = {}
local MovementController = {}
local MiningController = {}
local SellController = {}
local CombatController = {}

local TeleportController = {}

function TeleportController.getNPCs()
    local npcs = {}
    local proximity = workspace:FindFirstChild("Proximity")
    if proximity then
        for _, npc in pairs(proximity:GetChildren()) do
            if npc:IsA("Model") and not string.match(npc.Name:lower(), "potion") then
               table.insert(npcs, npc.Name)
            end
        end
    end
    table.sort(npcs)
    return npcs
end

function TeleportController.getShops()
    local shops = {}
    local shopsFolder = workspace:FindFirstChild("Shops")
    if shopsFolder then
        for _, shop in pairs(shopsFolder:GetChildren()) do
            if shop:IsA("Model") then
                table.insert(shops, shop.Name)
            end
        end
    end
    table.sort(shops)
    return shops
end

function TeleportController.teleportTo(name, isNPC)
    local folder = isNPC and workspace:FindFirstChild("Proximity") or workspace:FindFirstChild("Shops")
    if not folder then return end
    
    local target = folder:FindFirstChild(name)
    if target then
        local targetPart = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart", true)
        if targetPart then
             MovementController.teleport(targetPart:GetPivot() * CFrame.new(0, 3, 0), false)
             Fluent:Notify({Title = "Teleport", Content = "Teleported to " .. name, Duration = 3})
        else
             Fluent:Notify({Title = "Error", Content = "Could not find part for " .. name, Duration = 3})
        end
    else
         Fluent:Notify({Title = "Error", Content = name .. " not found!", Duration = 3})
    end
end

local ForgeController = {}

function ForgeController.instantForge(ores : table, itemType : string)
    local forgeModel = workspace:WaitForChild("Proximity"):WaitForChild("Forge", 5)
    
    if not forgeModel then
        Fluent:Notify({Title = "Error", Content = "Forge model not found in Proximity!", Duration = 5})
        return
    end

    local success, err = pcall(function()
        -- 1. Connect
        forgeRF:InvokeServer(forgeModel)
        task.wait(0.1)
        
        -- 2. Ignite
        startForgeRF:InvokeServer(forgeModel)
        task.wait(0.1)
        
        -- 3. Melt
        changeSequenceRF:InvokeServer("Melt", {
            FastForge = false,
            ItemType = itemType,
            Ores = ores
        })
        task.wait(2) 
        
        -- 4. Pour
        changeSequenceRF:InvokeServer("Pour", {ClientTime = workspace:GetServerTimeNow()})
        task.wait(0.3)
        
        -- 5. Hammer
        changeSequenceRF:InvokeServer("Hammer", {ClientTime = workspace:GetServerTimeNow()})
        task.wait(0.3)
        
        -- 6. Water
        changeSequenceRF:InvokeServer("Water", {ClientTime = workspace:GetServerTimeNow()})
        task.wait(1)
        
        -- 7. Showcase (Finish)
        changeSequenceRF:InvokeServer("Showcase", {})
    end)

    if success then
        Fluent:Notify({Title = "Forge", Content = "Instant Forge Complete!", Duration = 5})
    else
        warn("Instant Forge Failed:", err)
        Fluent:Notify({Title = "Error", Content = "Forge Failed: " .. tostring(err), Duration = 5})
    end
end

-- Static Directories

local cavesFolder = workspace:WaitForChild("Rocks")
local enemiesFolder = workspace:WaitForChild("Living")
local runesModuleDir = replicatedStorage:WaitForChild("Shared"):WaitForChild("Data"):WaitForChild("Runes")
local forgeControllerModuleDir = replicatedStorage:WaitForChild("Controllers"):WaitForChild("ForgeController")

-- For Some Reason Some Mob's Islands Have Weird Values Like "Iron Valley" Which Isn't Even An Island So I'll Make A Little Lookup Table Since There Dont Seem To Be Any Links Between Iron Valley And Stonewake's Cross etc.

local weirdIslandData =
{
    ["Iron Valley"] = "Stonewake's Cross"
}

-- Functions

-- Utility Functions

function Utility.getAveragePosOfParts(parts)
    local totalPos = Vector3.zero
    local count = 0

    for _, part in pairs(parts) do
        if part:IsA("BasePart") then
            totalPos = totalPos + part.Position
            count = count + 1
        end
    end

    if count == 0 then return Vector3.zero end

    return totalPos / count
end

function Utility.getStringsOfTable(t)
    local result = {}

    for _, v in pairs(t) do
        table.insert(result, tostring(v))
    end

    return result
end

function Utility.getHeadersOfTable(t)
    local result = {}

    for i, _ in pairs(t) do
        table.insert(result, tostring(i))
    end

    return result
end

function Utility.getAllTableChildrenKeys(t , k)
    local result = {}

    for _,v in pairs(t) do
        table.insert(result, v[k])
    end

    return result
end

function Utility.mergeTables(t1, t2)
    local result = table.clone(t1)

    for i,v in pairs(t2) do
        table.insert(result, v )
    end

    return result
end

function Utility.getCurrentIsland()
    local placeID = game.PlaceId

    for _,island in pairs(islandData.Data) do
        if island.PlaceId == placeID then
            return island.Name
        end
    end

    return "NOT FOUND"

end

function Utility.equipTool(name)
    local backpack = player.Backpack
    local char = player.Character
    
    if char then
        if char:FindFirstChild(name) then return end
        for _, t in pairs(char:GetChildren()) do
             if t:IsA("Tool") and string.find(t.Name, name) then return end
        end
    end

    if backpack then
        local tool = backpack:FindFirstChild(name)
        if not tool then
             for _, t in pairs(backpack:GetChildren()) do
                 if t:IsA("Tool") and string.find(t.Name, name) then
                     tool = t
                     break
                 end
             end
        end
        
        if tool then
            humanoid:EquipTool(tool)
        end
    end
end

function Utility.redeemCodes()
    local codes = {
        "100KLIKES", "40KLIKES", "20KLIKES", "15KLIKES", "10KLIKES",
        "5KLIKES", "BETARELEASE!", "POSTRELEASEQNA", "100K!", "200K!"
    }
    
    for _, code in ipairs(codes) do
        task.spawn(function()
            codeServiceRF:InvokeServer(code)
        end)
        task.wait(0.2)
    end
    Fluent:Notify({Title = "Success", Content = "Attempted to redeem all codes!", Duration = 5})
end

function Utility.serverHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local _place = game.PlaceId
    local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
    
    local function ListServers(cursor)
       local Raw = game:HttpGet(_servers .. ((cursor and "&cursor="..cursor) or ""))
       return Http:JSONDecode(Raw)
    end
    
    local Server, Next; repeat
       local Servers = ListServers(Next)
       Server = Servers.data[1]
       Next = Servers.nextPageCursor
    until Server
    
    TPS:TeleportToPlaceInstance(_place,Server.id,game.Players.LocalPlayer)
end

-- Movement Controller

local proxy = Instance.new("CFrameValue")

proxy.Value = CFrame.new(0,0,0)

function MovementController.teleport(position : CFrame , useCFrame : boolean)
    if not HRP or not character then return end

    proxy.Value = character:GetPivot()

    local dist = (HRP.Position - position.Position).Magnitude
    local length = dist / 50 -- 50 studs/s

    local tweenInfo = TweenInfo.new(length, Enum.EasingStyle.Linear)

    local tbl = useCFrame and {Value = position} or {Value = CFrame.new(position.Position)}

    local tween = ts:Create(proxy, tweenInfo, tbl)

    local con

    con = rs.Heartbeat:Connect(function()
        if character and character.Parent then
            character:PivotTo(useCFrame and proxy.Value or CFrame.new(proxy.Value.Position) * (HRP.CFrame - HRP.Position))
        else
            con:Disconnect()
        end
    end)

    tween:Play()
    tween.Completed:Wait()

    con:Disconnect()

end

function MovementController.enableFly(speed)
    if not HRP or not character then return end
    
    local bg = Instance.new("BodyGyro", HRP)
    bg.P = 90000
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = HRP.CFrame
    bg.Name = "FlyGyro"

    local bv = Instance.new("BodyVelocity", HRP)
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Name = "FlyVelocity"
    
    local flyCon
    flyCon = rs.RenderStepped:Connect(function()
        if not options.InfiniteFly.Value or not character or not character.Parent or not HRP.Parent then
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
            if flyCon then flyCon:Disconnect() end
            if humanoid then humanoid.PlatformStand = false end
            return
        end
        
        humanoid.PlatformStand = true
        local cam = workspace.CurrentCamera
        local moveVec = Vector3.zero
        
        if uis:IsKeyDown(Enum.KeyCode.W) then moveVec = moveVec + cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.S) then moveVec = moveVec - cam.CFrame.LookVector end
        if uis:IsKeyDown(Enum.KeyCode.A) then moveVec = moveVec - cam.CFrame.RightVector end
        if uis:IsKeyDown(Enum.KeyCode.D) then moveVec = moveVec + cam.CFrame.RightVector end
        
        bg.CFrame = cam.CFrame
        bv.Velocity = moveVec.Unit * (speed or 50)
        if moveVec.Magnitude == 0 then bv.Velocity = Vector3.zero end
    end)
end

function MovementController.disableFly()
    if HRP then
        if HRP:FindFirstChild("FlyGyro") then HRP.FlyGyro:Destroy() end
        if HRP:FindFirstChild("FlyVelocity") then HRP.FlyVelocity:Destroy() end
    end
    if humanoid then humanoid.PlatformStand = false end
end

-- Click TP Logic
uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and uis:IsKeyDown(Enum.KeyCode.LeftControl) and options.ClickTP.Value then
        local pos = mouse.Hit.Position + Vector3.new(0, 3, 0)
        MovementController.teleport(CFrame.new(pos), false)
    end
end)

-- Mining Controller

function MiningController.breakOre(hitbox : BasePart, toggle : table)
    if not hitbox then return end
    
    Utility.equipTool("Pickaxe")
    
    local mineDist = options.MineDistance and options.MineDistance.Value or 4
    MovementController.teleport((hitbox.CFrame - Vector3.new(0,mineDist,0)) * CFrame.Angles(math.rad(90), 0, 0), true)

    HRP.Anchored = true

    -- ok so, the game waits a bit after the rock is hit to actually destroy the hitbox so in order to fix that i can either try to reverse engineer and see if rock states are stored on the client (prob not) or just find a pattern

    -- i decided to find a pattern, ill just scan the gui until its 0 hp, its the simplest way and most reliable

    local timeUnchanged = 0
    local lastChange = tick()
    local hpGUI = hitbox.Parent
    and hitbox.Parent:FindFirstChild("infoFrame")
    and hitbox.Parent.infoFrame:FindFirstChild("Frame")
    and hitbox.Parent.infoFrame.Frame:FindFirstChild("rockHP")

    if not hpGUI then return end

    local lastValue = hpGUI.Text
    repeat

        toolActivatedRF:InvokeServer("Pickaxe")
        task.wait()

        if hpGUI.Text ~= lastValue then
            lastChange = tick()
            lastValue = hpGUI.Text
        else
            timeUnchanged = tick() - lastChange
        end

        local lastPlayer = hitbox.Parent:GetAttribute("LastHitPlayer")
        local lastTime = hitbox.Parent:GetAttribute("LastHitTime")

        if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then break end

    until
    not hitbox.Parent -- no hitbox (ore is destroyed)
    or ((hitbox.Parent:FindFirstChild("infoFrame") and hitbox.Parent.infoFrame:FindFirstChild("Frame") and hitbox.Parent.infoFrame.Frame:FindFirstChild("rockHP")) and hitbox.Parent.infoFrame.Frame.rockHP.Text == "0 HP") -- hp reached 0
    or not toggle.Value -- auto mine toggled off
    or timeUnchanged > 4 -- not mining (hp of ore not changing for 4+ secs)

    if timeUnchanged > 4 then
        glitchedOres[hitbox.Parent.Parent] = tick()
    end

    HRP.Anchored = false

end

function MiningController.getRockTypes()
    return Utility.getHeadersOfTable(rockData)
end

function MiningController.getClosestOreInCave(cave)

    if not HRP then return end

    local closestOre = nil
    local closestDist = math.huge

    for _, ore in pairs(cave and cave:GetChildren() or cavesFolder:GetDescendants()) do

        local children = ore:GetChildren()

        if #children > 0 then

            local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
            local lastTime = children[1]:GetAttribute("LastHitTime")
            
            local skip = false
            if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then 
                 skip = true
            end

            if not skip and glitchedOres[ore] then
                if tick() - glitchedOres[ore] > 1000 then
                    glitchedOres[ore] = nil
                else
                    skip = true
                end
            end

            if not skip and ore:GetAttribute("IsOccupied") ~= false then

                local hitbox = children[1]:FindFirstChild("Hitbox")

                local gui = children[1]:FindFirstChild("infoFrame")

                if gui then
                     if not ((gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false) then
                         if hitbox then
                            local dist = (HRP.Position - hitbox.Position).Magnitude

                            if dist < closestDist then

                                closestDist = dist
                                closestOre = hitbox
                            end
                        end
                     end
                end
            end
        end
    end

    return closestOre
end

function MiningController.getClosestOreWithNames()
    if not HRP then return end

    local closestOre = nil
    local closestDist = math.huge

    for _, cave in pairs(cavesFolder:GetChildren()) do

        for _,ore in pairs(cave:GetChildren()) do

            local children = ore:GetChildren()

            if #children > 0 then

                local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
                local lastTime = children[1]:GetAttribute("LastHitTime")
                
                local skip = false
                if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then 
                    skip = true
                end

                if not skip and glitchedOres[ore] then
                    if tick() - glitchedOres[ore] > 1000 then
                        glitchedOres[ore] = nil
                    else
                        skip = true
                    end
                end

                if not skip and ore:GetAttribute("IsOccupied") ~= false then
                    if options.wantedRocksDropdown.Value[children[1].Name] then

                        local hitbox = children[1]:FindFirstChild("Hitbox")
                        local gui = children[1]:FindFirstChild("infoFrame")

                        if gui then
                            if not ((gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false) then
                                if hitbox then
                                    local dist = (HRP.Position - hitbox.Position).Magnitude
                
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestOre = hitbox
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closestOre
end

function MiningController.getCurrentCave()

    if not HRP then return end

    local closestCave = nil
    local closestDist = math.huge

    for _,cave in pairs(cavesFolder:GetChildren()) do

        local dist = (HRP.Position - Utility.getAveragePosOfParts(cave:GetChildren())).Magnitude

        if dist < closestDist then

            closestDist = dist
            closestCave = cave
        end
    end

    return closestCave
end

-- Sell Controller

function SellController.getInventory() : table

    return knitModule.GetController("PlayerController").Replica.Data.Inventory

end

function SellController.getSellable() : (table,table)
    local oreTable = {}
    local miscTable = {}

    for name, value in pairs(knitModule.GetController("PlayerController").Replica.Data.Inventory) do -- get all ores

        if typeof(value) == "number" then

            oreTable[name] = value
        end
    end

    for name,value in pairs(knitModule.GetController("PlayerController").Replica.Data.Inventory.Misc) do -- get all misc
        if value then
            miscTable[name] = value
        end
    end

    return oreTable, miscTable
end

function SellController.formatSellable(oreTable : table, miscTable : table) : table
    local tbl = {}

    for i , v in pairs(oreTable) do
        if i then
            if not options.DONTAutoSellOres.Value[i] and not options.DONTAutoSellRarities.Value[SellController.getOreRarity(i)] then
                tbl[i] = v
            end
        end
    end

    for _,v in pairs(miscTable) do
        if v.Name or v.GUID then
            if not options.DONTAutoSellMisc.Value[v.Name or v.Id] and not options.DONTAutoSellRarities.Value[SellController.getMiscRarity(v.Name or v.Id)] then
                tbl[v.Name or v.GUID] = v.Quantity or 1
            end
        end
    end

    return {"SellConfirm" , {["Basket"] = tbl}}
end

function SellController.getSeller() : Model?
    return workspace.Proximity["Greedy Cey"]
end

function SellController.sellInventory()

    MovementController.teleport(SellController.getSeller():GetPivot() , false)

    local oreTable, miscTable = SellController.getSellable()

    local sellRequest = SellController.formatSellable(oreTable, miscTable)

    dialogueRF:InvokeServer(workspace.Proximity:FindFirstChild("Greedy Cey")) -- init auto sell ig?

    task.wait()

    dialogueRE:FireServer("Opened")

    task.wait(0.1)

    dialogueRE:FireServer("Closed")

    task.wait(0.5)

    runCommandRF:InvokeServer(unpack(sellRequest))
end

function SellController.isInventoryFull() : boolean

    return purchaseModule:GetRemainingStashCapacity() == 0

end

function SellController.getRarities() : table
    return Utility.getHeadersOfTable(raritiesData)
end

function SellController.getOreRarity(ore : string) : string
    for _, oreChild in pairs(oresData) do

        if oreChild.Name == ore then

            return oreChild.Rarity
            
        end
    end

    print("Rarity not found for: " .. ore)

    return "RARITY NOT FOUND"
end

function SellController.getMiscRarity(misc : string) : string

    for _, miscChild in pairs(materialData.Items) do

        if miscChild.Name == misc then

            return miscChild.Rarity
            
        end
    end

    for _, runeChild in pairs(runesModuleDir:GetDescendants()) do

        if runeChild.Name == misc then

            return require(runeChild).Rarity
            
        end
    end

    print("Rarity not found for: " .. misc)

    return "RARITY NOT FOUND"
end

function SellController.getOres() : table
    return Utility.getAllTableChildrenKeys(oresData , "Name")
end

function SellController.getRunes() : table

    local result = {}

    for _,v in pairs(runesModuleDir:WaitForChild("Runes"):GetDescendants()) do
        if v:IsA("ModuleScript") then
            table.insert(result, v.Name)
        end
    end

    return result
end

function SellController.getMisc() : table
    return Utility.mergeTables(Utility.getAllTableChildrenKeys(materialData.Items , "Name") , SellController.getRunes())
end

-- Combat Controller

function CombatController.killEnemy(enemy : Model)
    if not HRP or not character then return end
    if not enemy then return end
    if not enemy.Parent then return end -- Check if enemy exists

    -- 0. Equip Weapon
    Utility.equipTool("Weapon")
    
    local targetHRP = enemy:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = enemy:FindFirstChild("Humanoid")
    
    if not targetHRP or not targetHumanoid then return end

    -- 1. Initial Approach
    -- Use the configured distance for initial teleport too
    local initialDist = options.CombatDistance and options.CombatDistance.Value or 3
    local offset = Vector3.new(0, initialDist, 0) -- Positive for ABOVE
    MovementController.teleport(CFrame.new(targetHRP.Position + offset), false)

    -- 2. Setup Connections
    
    if humanoid then
        humanoid.PlatformStand = true
    end

    local steppedCon
    local heartbeatCon
    
    -- Noclip Enemy (Stepped)
    steppedCon = rs.Stepped:Connect(function()
        if enemy and enemy.Parent then
            for _, v in ipairs(enemy:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide == true then
                    v.CanCollide = false
                end
            end
        end
    end)

    -- Lock Position (Heartbeat) - DYNAMIC DISTANCE
    heartbeatCon = rs.Heartbeat:Connect(function()
        if enemy and enemy.Parent and targetHRP and targetHRP.Parent and HRP and HRP.Parent then
            local currentDist = options.CombatDistance and options.CombatDistance.Value or 3
            local currentOffset = Vector3.new(0, currentDist, 0) -- Positive for ABOVE
            
            local targetPos = targetHRP.Position + currentOffset
            
            -- Use CFrame.lookAt with a tiny offset to avoid LookVector == -UpVector singularity (Looking straight down)
            -- This prevents NaN/Malformed CFrames which cause the game's effect scripts to error
            local safeTargetPos = targetHRP.Position + currentOffset + Vector3.new(0.01, 0, 0)
            HRP.CFrame = CFrame.lookAt(safeTargetPos, targetHRP.Position)
            HRP.Velocity = Vector3.new(0,0,0)
            HRP.RotVelocity = Vector3.new(0,0,0)
        end
    end)
    
    -- 3. Attack Loop
    while enemy and enemy.Parent and targetHumanoid and targetHumanoid.Health > 0 and options.AutoKillMobsToggle.Value do
        
        -- Check if we died or missing refs
        if not character or not character.Parent or not HRP.Parent then break end
        if humanoid and humanoid.Health <= 0 then break end

         pcall(function()
            toolActivatedRF:InvokeServer("Weapon")
        end)
        
        task.wait(0.3)
    end
    
    -- 4. Cleanup
    if steppedCon then steppedCon:Disconnect() end
    if heartbeatCon then heartbeatCon:Disconnect() end
    
    if humanoid then
        humanoid.PlatformStand = false
    end
    
    -- Stabilize logic form original script to prevent falling/flinging after disable
    if HRP then
        HRP.Velocity = Vector3.zero
        HRP.RotVelocity = Vector3.zero
    end

end

function CombatController.getEnemyTypesAtIsland(islandName)

    if islandName == "NOT FOUND" then print("Island Name Not Found") return {"ISLAND NOT FOUND"} end

    print("Getting Enemy Types At Island: " .. islandName)

    local tbl = {}

    for _,v in pairs(enemiesData) do

        if (v.Island == islandName) or (weirdIslandData[v.Island] == islandName) then -- weird island data basically links stuff like "Iron Valley" to "Stonewake's Cross"

            table.insert(tbl,v.Name)

        end
    end

    return tbl
end

function CombatController.getClosestEnemy()
    if not HRP then return end

    local closestEnemy = nil
    local closestDist = math.huge

    for _, enemy in pairs(enemiesFolder:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy:GetAttribute("IsNpc") == true then
            local hpText =
            enemy
            and enemy:FindFirstChild("HumanoidRootPart")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP").Text or "0 HP"

            if hpText ~= "0 HP" then
                local dist = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude

                if dist < closestDist then
                    closestDist = dist
                    closestEnemy = enemy
                end
            end
        end
    end

    return closestEnemy
end

function CombatController.getEnemyName(enemy)
    local hrp = enemy and enemy:FindFirstChild("HumanoidRootPart")

    local textLabel = hrp
        and hrp:FindFirstChild("infoFrame")
        and hrp.infoFrame:FindFirstChild("Frame")
        and hrp.infoFrame.Frame:FindFirstChild("rockName")

    return (textLabel and textLabel.Text) or ""
end


function CombatController.getEnemyByName()

    local closestEnemy = nil
    local closestDist = math.huge

    for _,enemy in pairs(enemiesFolder:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy:GetAttribute("IsNpc") == true then

            local hpText =
            enemy
            and enemy:FindFirstChild("HumanoidRootPart")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
            and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP").Text or "0 HP"

            if hpText ~= "0 HP" then
                if options.AutoKilledMobs.Value[CombatController.getEnemyName(enemy)] then
        
                    local dist = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude
        
                    if dist < closestDist then
                        closestDist = dist
                        closestEnemy = enemy
                    end
                end
            end
        end
    end

    return closestEnemy
end

-- Forge Controller

function ForgeController.getMeltMinigameMainFunc()

    for _, con in pairs(getconnections(rs.RenderStepped)) do
        
        if con.Function then
            
            local success, isNumber = pcall(function()
                return typeof(getupvalue(con.Function, 22)) == "number"
            end)

            if success and isNumber then
                
                return con.Function

            end

        end

    end

    return nil

end

function ForgeController.getPourMinigameMainFunc()

    for _, con in pairs(getconnections(rs.RenderStepped)) do
        
        if con.Function then
            
            local success, isNumber = pcall(function()
                return typeof(getupvalue(con.Function, 23)) == "boolean"
            end)

            if success and isNumber then
                
                return con.Function

            end

        end

    end

    return nil

end

function ForgeController.getHammerMinigameMainFunc()

    for _,desc in pairs(workspace.Debris:GetDescendants()) do

        if desc:IsA("ClickDetector") then

            for _, con in pairs(getconnections(desc.MouseClick)) do
    
                if con.Function then
    
                    local success, isNumber = pcall(function()
                        return typeof(getupvalue(con.Function, 1)) == "number"
                    end)
    
                    if success and isNumber then
    
                        return con.Function
    
                    end
    
                end
    
            end
        end

    end

    return nil

end

function ForgeController.completeHammerMinigameSecond()

    local mainMinigameGUI = player.PlayerGui.Forge.HammerMinigame

    local con

    con = mainMinigameGUI.ChildAdded:Connect(function(child)
    
        if child.Name == "Frame" and child:IsA("TextButton") then
            local circle = child:FindFirstChild("Frame"):WaitForChild("Circle")
            
            task.spawn(function()

                repeat
                    task.wait(0.01)
                until circle.Size.X.Scale <= 1.2
            
                firesignal(child.MouseButton1Click)
            end)
        end
    end)

    repeat
        task.wait()
    until not mainMinigameGUI.Visible

    con:Disconnect()

end

function ForgeController.completeForge()

        local meltMinigameFunction = nil

        repeat
            meltMinigameFunction = ForgeController.getMeltMinigameMainFunc()
            task.wait()
        until meltMinigameFunction

        print("Got Melt Minigame Function")
        
        setupvalue(meltMinigameFunction, 19 , true)

        local pourMinigameFunction = nil

        repeat
            pourMinigameFunction = ForgeController.getPourMinigameMainFunc()
            task.wait()
        until pourMinigameFunction

        print("Got Pour Minigame Function")

        setupvalue(pourMinigameFunction , 23 , true)

        local hammerMinigameFunction = nil

        repeat
            hammerMinigameFunction = ForgeController.getHammerMinigameMainFunc()
            task.wait()
        until hammerMinigameFunction

        print("Got Hammer Minigame Function")

        setupvalue(hammerMinigameFunction , 1 , 69420)

        ForgeController.completeHammerMinigameSecond()

end

-- GUI Setup

-- Mining Tab

local caveSelectDropdown = Tabs.oresTab:AddDropdown(
    "CaveDropdown",
    {
    Title = "Select Cave",
    Values = Utility.getStringsOfTable(cavesFolder:GetChildren()),
    Multi = false,
    Default = 1,
    }
)

Tabs.oresTab:AddDropdown(
    "wantedRocksDropdown",
    {
    Title = "Select Wanted Rocks",
    Values = MiningController.getRockTypes(),
    Multi = true,
    Default = {}
    }
)

Tabs.oresTab:AddToggle("AutoFarmOresFromCaveToggle", {Title = "Auto Farm Rocks From Selected Cave", Default = false})

Tabs.oresTab:AddToggle("AutoFarmOresWithNameToggle" , {Title = "Auto Farm Rocks With Selected Names", Default = false})

Tabs.oresTab:AddSlider("MineDistance", {
    Title = "Mine Distance",
    Description = "Vertical distance from ore",
    Default = 4,
    Min = 1,
    Max = 15,
    Rounding = 1,
})

-- Combat Tab

Tabs.combatTab:AddDropdown("AutoKilledMobs",
{
    Title = "Select Mobs To Auto Kill",
    Values = CombatController.getEnemyTypesAtIsland(Utility.getCurrentIsland()),
    Multi = true,
    Default = {}
})

Tabs.combatTab:AddToggle("AutoKillMobsToggle", {Title = "Auto Kill Selected Mobs Toggle", Default = false})

Tabs.combatTab:AddToggle("AutoParry", {Title = "Auto Parry", Default = false})

Tabs.combatTab:AddToggle("AutoConsumePotions", {Title = "Auto Consume Potions", Default = false})

Tabs.combatTab:AddSlider("CombatDistance", {
    Title = "Combat Distance",
    Description = "Distance below enemy (Haze Style)",
    Default = 6,
    Min = 1,
    Max = 20,
    Rounding = 1,
})

-- Movement Tab

Tabs.movementTab:AddToggle("InfiniteFly", {
    Title = "Infinite Fly",
    Default = false,
    Callback = function(v)
        if v then
            MovementController.enableFly(options.FlySpeed.Value or 50)
        else
            MovementController.disableFly()
        end
    end
})

-- Teleport Tab

local npcDropdown = Tabs.teleportTab:AddDropdown("TeleportNPC", {
    Title = "Select NPC",
    Values = TeleportController.getNPCs(),
    Multi = false,
    Default = 1,
})

Tabs.teleportTab:AddButton({
    Title = "Refresh NPC List",
    Callback = function()
        npcDropdown:SetValues(TeleportController.getNPCs())
        npcDropdown:SetValue(nil)
    end
})

Tabs.teleportTab:AddButton({
    Title = "Tween To NPC",
    Callback = function()
        if npcDropdown.Value then
            TeleportController.teleportTo(npcDropdown.Value, true)
        else
            Fluent:Notify({Title = "Error", Content = "Please select an NPC", Duration = 3})
        end
    end
})

Tabs.teleportTab:AddParagraph({Title = "Shops", Content = "Teleport to shops"})

local shopDropdown = Tabs.teleportTab:AddDropdown("TeleportShop", {
    Title = "Select Shop",
    Values = TeleportController.getShops(),
    Multi = false,
    Default = 1,
})

Tabs.teleportTab:AddButton({
    Title = "Refresh Shop List",
    Callback = function()
        shopDropdown:SetValues(TeleportController.getShops())
        shopDropdown:SetValue(nil)
    end
})

Tabs.teleportTab:AddButton({
    Title = "Tween To Shop",
    Callback = function()
         if shopDropdown.Value then
            TeleportController.teleportTo(shopDropdown.Value, false)
        else
            Fluent:Notify({Title = "Error", Content = "Please select a Shop", Duration = 3})
        end
    end
})

-- Movement Tab

Tabs.movementTab:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1,
})

Tabs.movementTab:AddToggle("ClickTP", {
    Title = "Click TP (Ctrl + Click)",
    Default = false
})

Tabs.movementTab:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 1,
    Callback = function(v)
        if humanoid then
            humanoid.WalkSpeed = v
        end
    end
})

-- Loop to enforce WalkSpeed
task.spawn(function()
    while true do
        task.wait(0.5)
        if options.WalkSpeed and humanoid and humanoid.WalkSpeed ~= options.WalkSpeed.Value then
             humanoid.WalkSpeed = options.WalkSpeed.Value
        end
    end
end)

-- Auto Potion Loop
task.spawn(function()
    while true do
        task.wait(1)
        if options.AutoConsumePotions and options.AutoConsumePotions.Value then
            if character and humanoid and humanoid.Health < humanoid.MaxHealth * 0.5 then
                local backpack = player.Backpack
                local potion = nil
                
                -- Check backpack
                for _, item in pairs(backpack:GetChildren()) do
                    if item:IsA("Tool") and (string.find(item.Name, "Potion") or string.find(item.Name, "Health")) then
                        potion = item
                        break
                    end
                end
                
                -- Check character (already equipped)
                for _, item in pairs(character:GetChildren()) do
                     if item:IsA("Tool") and (string.find(item.Name, "Potion") or string.find(item.Name, "Health")) then
                        potion = item
                        break
                    end
                end

                if potion then
                    Utility.equipTool(potion.Name)
                    toolActivatedRF:InvokeServer(potion.Name)
                end
            end
        end
    end
end)

-- Settings Tab

Tabs.settingsTab:AddButton({
    Title = "Redeem All Codes",
    Description = "Redeems known codes",
    Callback = function()
        Utility.redeemCodes()
    end
})

Tabs.settingsTab:AddButton({
    Title = "Server Hop",
    Description = "Joins a different server",
    Callback = function()
        Utility.serverHop()
    end
})

-- Forging Tab

Tabs.forgingTab:AddDropdown("ForgeOreType", {
    Title = "Select Ore",
    Values = SellController.getOres(),
    Multi = false,
    Default = 1,
})

Tabs.forgingTab:AddDropdown("ForgeItemType", {
    Title = "Select Item Type",
    Values = {"Weapon", "Armor"},
    Multi = false,
    Default = 1,
})

Tabs.forgingTab:AddSlider("ForgeQuantity", {
    Title = "Quantity",
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 1,
})

Tabs.forgingTab:AddButton({
    Title = "Instant Forge",
    Description = "Forges selected item instantly",
    Callback = function()
        local ore = options.ForgeOreType.Value
        local itemType = options.ForgeItemType.Value
        local quantity = options.ForgeQuantity.Value
        
        if ore and itemType then
             local oresTable = {[ore] = quantity}
             ForgeController.instantForge(oresTable, itemType)
        else
             Fluent:Notify({Title = "Error", Content = "Please select ore and item type", Duration = 3})
        end
    end
})

-- Selling Tab

Tabs.autoSellTab:AddDropdown("DONTAutoSellOres",
{
    Title = "Select Ores To KEEP",
    Values = SellController.getOres(),
    Multi = true,
    Default = {}
})

Tabs.autoSellTab:AddDropdown("DONTAutoSellMisc",
{
    Title = "Select Misc To KEEP",
    Values = SellController.getMisc(),
    Multi = true,
    Default = {}
})

Tabs.autoSellTab:AddDropdown("DONTAutoSellRarities",
{
    Title = "Select Rarities To KEEP",
    Values = SellController.getRarities(),
    Multi = true,
    Default = {}
})

Tabs.autoSellTab:AddToggle("AutoSellToggle" , {Title = "Auto Sell On Full Inventory", Default = false})

Tabs.autoSellTab:AddButton({
    Title = "Sell",
    Description = "Test Sell",
    Callback = function()
        SellController.sellInventory()
    end,
})

-- Forging Tab

Tabs.forgingTab:AddParagraph({Title = "How To Use Auto-Forge", Content = "1: Enter The Forge And Select The Ores And Weapon You Want\n2: Press The Auto-Forge Button\n3: Start Minigame\n4: Enjoy!"})

Tabs.forgingTab:AddButton({
    Title = "Forge",
    Description = "Auto Forge (Follow Steps Above)",
    Callback = function()
        Fluent:Notify({
            Title = "AUTO FORGE",
            Content = "START",
            Subcontent = "Auto Forge Started",
            Duration = 3,
        })

        ForgeController.completeForge()

        Fluent:Notify({
            Title = "AUTO FORGE",
            Content = "END",
            Subcontent = "Auto Forge Ended",
            Duration = 5,
        })
    end
})

-- Main Loop

local function determineState()

    if options.AutoSellToggle.Value and SellController.isInventoryFull() then
        return "Selling"
    elseif options.AutoKillMobsToggle.Value and CombatController.getEnemyByName() then
        return "Killing"
    elseif (options.AutoFarmOresFromCaveToggle.Value or options.AutoFarmOresWithNameToggle.Value) and (MiningController.getClosestOreInCave(cavesFolder:FindFirstChild(caveSelectDropdown.Value)) or MiningController.getClosestOreWithNames()) then
        return "Mining"
    else
        return "Idle"
    end

end

local HZ = 20
local interval = 1 / HZ

task.spawn(function()
    while true do

        task.wait(interval)

        local state = determineState()

        if state == "Mining" then

            local caveName = caveSelectDropdown.Value
            local cave = cavesFolder:FindFirstChild(caveName)

            if not cave then
                task.wait(1)
            else
                local ore = options.AutoFarmOresFromCaveToggle.Value and MiningController.getClosestOreInCave(cave) or MiningController.getClosestOreWithNames()
    
                if ore then
                    MiningController.breakOre(ore, (options.AutoFarmOresFromCaveToggle.Value and options.AutoFarmOresFromCaveToggle) or options.AutoFarmOresWithNameToggle)
                else
                    print("Didnt Get Ore")
                    task.wait(1)
                end
            end

        elseif state == "Selling" then

            SellController.sellInventory()

        elseif state == "Killing" then

            local enemy = CombatController.getEnemyByName()

            if enemy then
                print("Killing Enemy")
                CombatController.killEnemy(enemy)
            end

        end
    end
end)

local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

if isMobile then

    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(1, -80, 0.5, -40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 120, 255)
    btn.Text = "Toggle GUI"
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Active = true
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)

end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("TofiHub")
SaveManager:SetFolder("Tofi_Hub/The_Forge")

InterfaceManager:BuildInterfaceSection(Tabs.settingsTab)
SaveManager:BuildConfigSection(Tabs.settingsTab)


Window:SelectTab(1)

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

while task.wait(300) do
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.Tilde, false, nil)
    task.wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.Tilde, false, nil)
end
