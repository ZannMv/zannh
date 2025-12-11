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
 -- fluent with retry logic and fallback
local Fluent, SaveManager, InterfaceManager

local function tryLoadLibrary(url, name, maxRetries)
    maxRetries = maxRetries or 3
    for attempt = 1, maxRetries do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        
        if success then
            print("✓ Loaded " .. name)
            return true, result
        else
            warn(string.format("⚠ Failed to load %s (Attempt %d/%d): %s", name, attempt, maxRetries, tostring(result)))
            if attempt < maxRetries then
                task.wait(attempt * 0.5) -- Progressive delay
            end
        end
    end
    return false, nil
end

local fluentLoaded, fluentLib = tryLoadLibrary(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "Fluent UI"
)

if not fluentLoaded then
    error([[
========================================
ERROR: Cannot load Fluent UI library!
========================================
The game may be blocking external HTTP requests.

SOLUTION:
Use 'theforge2_noui.lua' instead - it works without external UI libraries.
Or try a different executor/VPN.
========================================
]])
    return
end

Fluent = fluentLib

local saveLoaded, saveLib = tryLoadLibrary(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua",
    "SaveManager"
)
SaveManager = saveLoaded and saveLib or nil

local interfaceLoaded, interfaceLib = tryLoadLibrary(
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua",
    "InterfaceManager"  
)
InterfaceManager = interfaceLoaded and interfaceLib or nil
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
local ForgeController = {}

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
        if not part:IsA("BasePart") then continue end

        totalPos = totalPos + part.Position
        count += 1
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

function Utility.getAllTableChildrenKeys(t, k)
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

-- Movement Controller

local proxy = Instance.new("CFrameValue")

proxy.Value = CFrame.new(0,0,0)

function MovementController.teleport(position, useCFrame)
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

-- Mining Controller

function MiningController.breakOre(hitbox, toggle)
    if not hitbox then return end

    MovementController.teleport((hitbox.CFrame - Vector3.new(0,4,0)) * CFrame.Angles(math.rad(90), 0, 0), true)

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

        pcall(function()
            toolActivatedRF:InvokeServer("Pickaxe")
        end)
        task.wait(0.05) -- Slight delay to prevent spam detection

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

        if #children == 0 then continue end

        local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
        local lastTime = children[1]:GetAttribute("LastHitTime")

        if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then continue end

        if glitchedOres[ore] then
            if tick() - glitchedOres[ore] > 1000 then
                glitchedOres[ore] = nil
            else
                continue
            end
        end

        if ore:GetAttribute("IsOccupied") == false then continue end

        local hitbox = children[1]:FindFirstChild("Hitbox")

        local gui = children[1]:FindFirstChild("infoFrame")

        if not gui then continue end

        if (gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false then continue end

        if hitbox then
            local dist = (HRP.Position - hitbox.Position).Magnitude

            if dist < closestDist then

                closestDist = dist
                closestOre = hitbox
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

            if #children == 0 then continue end

            local lastPlayer = children[1]:GetAttribute("LastHitPlayer")
            local lastTime = children[1]:GetAttribute("LastHitTime")

            if lastPlayer and lastPlayer ~= player.Name and lastTime and (tick()  - lastTime < 10) then continue end

            if glitchedOres[ore] then
                if tick() - glitchedOres[ore] > 1000 then
                    glitchedOres[ore] = nil
                else
                    continue
                end
            end

            if ore:GetAttribute("IsOccupied") == false then continue end

            if not (options.wantedRocksDropdown.Value[children[1].Name]) then continue end

            local hitbox = children[1]:FindFirstChild("Hitbox")

            local gui = children[1]:FindFirstChild("infoFrame")

            if not gui then continue end

            if (gui.Frame:FindFirstChild("rockHP") and gui.Frame.rockHP.Text == "0 HP") or false then continue end

            if hitbox then
                local dist = (HRP.Position - hitbox.Position).Magnitude

                if dist < closestDist then

                    closestDist = dist
                    closestOre = hitbox
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

function SellController.getInventory()

    return knitModule.GetController("PlayerController").Replica.Data.Inventory

end

function SellController.getSellable()
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

function SellController.formatSellable(oreTable, miscTable)
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

function SellController.getSeller()
    return workspace.Proximity["Greedy Cey"]
end

function SellController.sellInventory()

    MovementController.teleport(SellController.getSeller():GetPivot() , false)

    local oreTable, miscTable = SellController.getSellable()

    local sellRequest = SellController.formatSellable(oreTable, miscTable)

    pcall(function()
        dialogueRF:InvokeServer(workspace.Proximity:FindFirstChild("Greedy Cey"))
    end)

    task.wait(0.2)

    pcall(function()
        dialogueRE:FireServer("Opened")
    end)

    task.wait(0.2)

    pcall(function()
        dialogueRE:FireServer("Closed")
    end)

    task.wait(0.3)

    pcall(function()
        runCommandRF:InvokeServer(unpack(sellRequest))
    end)
end

function SellController.isInventoryFull()

    return purchaseModule:GetRemainingStashCapacity() == 0

end

function SellController.getRarities()
    return Utility.getHeadersOfTable(raritiesData)
end

function SellController.getOreRarity(ore)
    for _, oreChild in pairs(oresData) do

        if oreChild.Name == ore then

            return oreChild.Rarity
            
        end
    end

    print("Rarity not found for: " .. ore)

    return "RARITY NOT FOUND"
end

function SellController.getMiscRarity(misc)

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

function SellController.getOres()
    return Utility.getAllTableChildrenKeys(oresData , "Name")
end

function SellController.getRunes()

    local result = {}

    for _,v in pairs(runesModuleDir:WaitForChild("Runes"):GetDescendants()) do
        if v:IsA("ModuleScript") then
            table.insert(result, v.Name)
        end
    end

    return result
end

function SellController.getMisc()
    return Utility.mergeTables(Utility.getAllTableChildrenKeys(materialData.Items , "Name") , SellController.getRunes())
end

-- Combat Controller

function CombatController.killEnemy(enemy)
    if not HRP or not character then return end
    if not enemy then return end

    local hpText =
        enemy
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP") or {Text = "0 HP"}

    MovementController.teleport(CFrame.new(enemy:GetPivot().Position - enemy:GetPivot().LookVector * 8 , enemy:GetPivot().Position), false)

    repeat

        task.wait()

        if not character or not character.Parent then continue end

        MovementController.teleport(CFrame.new(enemy:GetPivot().Position - enemy:GetPivot().LookVector * 8 , enemy:GetPivot().Position), true)
        
        task.spawn(function() 
            pcall(function()
                toolActivatedRF:InvokeServer("Weapon") 
            end)
        end)
        
        task.wait(0.05) -- Prevent spam

    until not enemy.Parent or hpText.Text == "0 HP" or not HRP.Parent or not character.Parent

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
        if not enemy:FindFirstChild("HumanoidRootPart") then continue end
        if not enemy:GetAttribute("IsNpc") == true then continue end
        local hpText =
        enemy
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP").Text or "0 HP"

        if hpText == "0 HP" then continue end

        local dist = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude

        if dist < closestDist then
            closestDist = dist
            closestEnemy = enemy
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
        if not enemy:FindFirstChild("HumanoidRootPart") then continue end
        if not enemy:GetAttribute("IsNpc") == true then continue end

        local hpText =
        enemy
        and enemy:FindFirstChild("HumanoidRootPart")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP")
        and enemy:FindFirstChild("HumanoidRootPart"):FindFirstChild("infoFrame"):FindFirstChild("Frame"):FindFirstChild("rockHP").Text or "0 HP"

        if hpText == "0 HP" then continue end

        if options.AutoKilledMobs.Value[CombatController.getEnemyName(enemy)] then

            local dist = (HRP.Position - enemy.HumanoidRootPart.Position).Magnitude

            if dist < closestDist then
                closestDist = dist
                closestEnemy = enemy
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

        if not desc:IsA("ClickDetector") then continue end

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

-- Combat Tab

Tabs.combatTab:AddDropdown("AutoKilledMobs",
{
    Title = "Select Mobs To Auto Kill",
    Values = CombatController.getEnemyTypesAtIsland(Utility.getCurrentIsland()),
    Multi = true,
    Default = {}
})

Tabs.combatTab:AddToggle("AutoKillMobsToggle", {Title = "Auto Kill Selected Mobs Toggle", Default = false})

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
                continue
            end

            local ore = options.AutoFarmOresFromCaveToggle.Value and MiningController.getClosestOreInCave(cave) or MiningController.getClosestOreWithNames()

            if ore then
                MiningController.breakOre(ore, (options.AutoFarmOresFromCaveToggle.Value and options.AutoFarmOresFromCaveToggle) or options.AutoFarmOresWithNameToggle)
            else
                print("Didnt Get Ore")
                task.wait(1)
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

-- Safe Anti-AFK System (uses character movement instead of virtual input)
task.spawn(function()
    while task.wait(240) do -- Every 4 minutes
        pcall(function()
            if character and HRP and humanoid and humanoid.Health > 0 then
                -- Small subtle movement to prevent AFK kick without triggering anti-cheat
                local originalCF = HRP.CFrame
                HRP.CFrame = originalCF * CFrame.new(0, 0.1, 0)
                task.wait(0.05)
                HRP.CFrame = originalCF
            end
        end)
    end
end)
