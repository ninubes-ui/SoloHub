-- Matikan loop lama jika script di-execute ulang
if getgenv().SoloHubLoop then 
    pcall(function() task.cancel(getgenv().SoloHubLoop) end)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- 1. DATABASE BASE, RARITY & AUTO-SCANNER
-- ==========================================
local SeedList = {
    "Carrot", "Wheat", "Tomato", "Strawberry", "Blueberry", "Pineapple", "Grape", 
    "Apple", "Tulip", "Pumpkin", "Bamboo", "Mushroom", "Coconut", "Cactus", 
    "Mango", "Cherry", "Lotus", "Sunflower", "Acorn", "Beanstalk", "Poison Apple", 
    "Thorn Rose", "Pomegranate", "Plum", "Ghost Pepper", "Poison Ivy", "Romanesco", 
    "Baby Cactus", "Glow Mushroom", "Horned Melon", "Corn", "Pinetree", "Moon Bloom", 
    "Banana", "Dragon Fruit", "Green Bean", "Venom Spitter", "Hypno Bloom", "Briar Rose", 
    "Fire Fern", "Rocket Pop", "Sun Bloom", "Eclipse Bloom", "Star Fruit", 
    "Venus Fly Trap", "Cinnamon Stick", "Conifer Cone", "Potato", "Honeysuckle", "Sugar Cane"
}

local GearList = {
    "Common Watering Can", "Super Watering Can", "Syrup Watering Can", "Super Syrup Watering Can",
    "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Super Sprinkler", "Legendary Sprinkler",
    "Syrup Sprinkler", "Super Syrup Sprinkler", "Trowel", "Rake", "Big Rake", "Mega Rake"
}

local PetList = { "All Pets", "Bunny", "Frog", "Raccoon", "Robin", "Deer", "Fox", "Bear", "Boar", "Squirrel", "Owl", "Duck", "Wolf", "Turtle" }

-- DATABASE RARITY SEED
local RarityDatabase = {
    ["Common"] = {"Carrot", "Wheat", "Strawberry", "Blueberry"},
    ["Uncommon"] = {"Sugar Cane", "Tulip", "Tomato", "Apple"},
    ["Rare"] = {"Bamboo", "Corn", "Cactus", "Pineapple"},
    ["Epic"] = {"Mushroom", "Green Bean", "Banana", "Grape", "Coconut", "Mango"},
    ["Legendary"] = {"Rocket Pop", "Dragon Fruit", "Acorn", "Cherry", "Sunflower"},
    ["Mythic"] = {"Fire Fern", "Venus Fly Trap", "Pomegranate", "Poison Apple"},
    ["Super"] = {"Venom Spitter", "Moon Bloom", "Sun Bloom", "Hypno Bloom", "Dragon's Breath", "Star Fruit"},
    ["Exotic"] = {"Jump Mushroom", "Speed Mushroom", "Shrink Mushroom", "Supersize Mushroom", "Invisibility Mushroom"}
}

-- DATABASE RARITY GEAR
local GearRarityDatabase = {
    ["Common"] = {"Common Watering Can", "Common Sprinkler", "Trowel"},
    ["Uncommon"] = {"Uncommon Sprinkler", "Rake"},
    ["Rare"] = {"Rare Sprinkler", "Big Rake"},
    ["Epic"] = {"Super Watering Can", "Super Sprinkler", "Mega Rake"},
    ["Legendary"] = {"Syrup Watering Can", "Legendary Sprinkler"},
    ["Mythic"] = {"Super Syrup Watering Can", "Syrup Sprinkler", "Super Syrup Sprinkler"}
}

-- DATABASE RARITY PET
local PetRarityDatabase = {
    ["Common"] = {"Bunny", "Frog"},
    ["Uncommon"] = {"Raccoon", "Robin"},
    ["Rare"] = {"Deer", "Fox", "Boar"},
    ["Epic"] = {"Bear", "Squirrel", "Owl"},
    ["Legendary"] = {"Duck", "Wolf", "Turtle"}
}

local RarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super", "Exotic"}
local GearRarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
local PetRarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary"}

-- FUNGSI SMART SCANNER V3 (STRICT CLASS CHECK)
local function AutoScanGameItems()
    print("🔴 [Solo Hub] Memulai proses scanning internal game v3...")
    local newPets, newSeeds, newGears = 0, 0, 0
    
    local mapFolder = workspace:FindFirstChild("Map")
    if mapFolder then
        local wildSpawns = mapFolder:FindFirstChild("WildPetSpawns")
        if wildSpawns then
            for _, pet in ipairs(wildSpawns:GetChildren()) do
                local cleanName = string.split(pet.Name, "_")[1] or pet.Name
                if not table.find(PetList, cleanName) then
                    table.insert(PetList, cleanName)
                    newPets = newPets + 1
                end
            end
        end
    end
    
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Folder") or obj:IsA("Configuration") then
            local folderName = string.lower(obj.Name)
            
            if string.find(folderName, "seed") or string.find(folderName, "crop") then
                for _, item in ipairs(obj:GetChildren()) do
                    if not table.find(SeedList, item.Name) and not item:IsA("Script") then
                        table.insert(SeedList, item.Name)
                        newSeeds = newSeeds + 1
                    end
                end
                
            elseif string.find(folderName, "pet") and not string.find(folderName, "tool") and not string.find(folderName, "gear") then
                for _, item in ipairs(obj:GetChildren()) do
                    local cleanName = string.split(item.Name, "_")[1] or item.Name
                    if item:IsA("Model") and not table.find(PetList, cleanName) then
                        table.insert(PetList, cleanName)
                        newPets = newPets + 1
                    end
                end
                
            elseif string.find(folderName, "gear") or string.find(folderName, "tool") or string.find(folderName, "watering") then
                for _, item in ipairs(obj:GetChildren()) do
                    if item:IsA("Tool") and not table.find(GearList, item.Name) then
                        table.insert(GearList, item.Name)
                        newGears = newGears + 1
                    end
                end
            end
        end
    end
    
    table.sort(SeedList)
    table.sort(GearList)
    table.sort(PetList, function(a, b)
        if a == "All Pets" then return true end
        if b == "All Pets" then return false end
        return a < b
    end)
    
    print(string.format("🔴 [Solo Hub] Scan Selesai! Ditemukan: %d Pet Baru, %d Seed Baru, %d Gear Baru.", newPets, newSeeds, newGears))
end

AutoScanGameItems()

getgenv().Config = {
    SelectedSeeds = {},
    SelectedRarities = {},
    SelectedGears = {},
    SelectedGearRarities = {},
    SelectedPets = {},
    SelectedPetRarities = {},
    
    AutoBuySeed = false,
    AutoBuyRarity = false,
    AutoBuyGear = false,
    AutoBuyGearRarity = false,
    AutoBuyPet = false,
    AutoBuyPetRarity = false
}

-- ==========================================
-- 2. ENGINE INJECTOR & PACKET BUFFER
-- ==========================================
local PacketRemote = nil
pcall(function() PacketRemote = ReplicatedStorage:WaitForChild("SharedModules", 2):WaitForChild("Packet", 2):WaitForChild("RemoteEvent", 2) end)
if not PacketRemote then
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name == "RemoteEvent" then
            PacketRemote = v
            break
        end
    end
end

local function fireNetBuffer(headerCode, itemName)
    if not PacketRemote then return end
    pcall(function()
        local len = string.len(itemName)
        local buf = buffer.create(3 + len)
        buffer.writeu8(buf, 0, headerCode)
        buffer.writeu8(buf, 1, 0)
        buffer.writeu8(buf, 2, len)
        buffer.writestring(buf, 3, itemName)
        PacketRemote:FireServer(buf)
    end)
end

local function firePetBuffer(petID)
    if not PacketRemote then return end
    pcall(function()
        local buf = buffer.create(3)
        buffer.writeu8(buf, 0, 1)  
        buffer.writeu8(buf, 1, 0)  
        buffer.writeu8(buf, 2, 53) 
        PacketRemote:FireServer(buf, { [1] = petID })
    end)
end

local tamedPets = {}
local isWorkingOnPet = false

getgenv().SoloHubLoop = task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if getgenv().Config.AutoBuySeed then
                for sName, isSelected in pairs(getgenv().Config.SelectedSeeds) do
                    if isSelected then fireNetBuffer(160, sName); task.wait(0.05) end
                end
            end
            if getgenv().Config.AutoBuyRarity then
                for rName, isSelected in pairs(getgenv().Config.SelectedRarities) do
                    if isSelected and RarityDatabase[rName] then
                        for _, sName in ipairs(RarityDatabase[rName]) do
                            fireNetBuffer(160, sName); task.wait(0.05)
                        end
                    end
                end
            end
            
            if getgenv().Config.AutoBuyGear then
                for gName, isSelected in pairs(getgenv().Config.SelectedGears) do
                    if isSelected then fireNetBuffer(164, gName); task.wait(0.05) end
                end
            end
            if getgenv().Config.AutoBuyGearRarity then
                for rName, isSelected in pairs(getgenv().Config.SelectedGearRarities) do
                    if isSelected and GearRarityDatabase[rName] then
                        for _, gName in ipairs(GearRarityDatabase[rName]) do
                            fireNetBuffer(164, gName); task.wait(0.05)
                        end
                    end
                end
            end
            
            if (getgenv().Config.AutoBuyPet or getgenv().Config.AutoBuyPetRarity) and not isWorkingOnPet then
                local char = LocalPlayer.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local mapFolder = workspace:FindFirstChild("Map")
                
                if humanoid and hrp and mapFolder then
                    local wildSpawns = mapFolder:FindFirstChild("WildPetSpawns")
                    if wildSpawns then
                        local foundPet = nil
                        local petPart = nil
                        local targetPrompt = nil
                        
                        for _, pet in ipairs(wildSpawns:GetChildren()) do
                            local isTarget = false
                            local cleanPetName = string.split(pet.Name, "_")[1] or pet.Name
                            
                            if getgenv().Config.AutoBuyPet then
                                if getgenv().Config.SelectedPets["All Pets"] then
                                    isTarget = true
                                else
                                    for selPet, isSelected in pairs(getgenv().Config.SelectedPets) do
                                        if isSelected and string.find(pet.Name, selPet) then
                                            isTarget = true; break
                                        end
                                    end
                                end
                            end
                            
                            if not isTarget and getgenv().Config.AutoBuyPetRarity then
                                for rName, isSelected in pairs(getgenv().Config.SelectedPetRarities) do
                                    if isSelected and PetRarityDatabase[rName] then
                                        if table.find(PetRarityDatabase[rName], cleanPetName) then
                                            isTarget = true; break
                                        end
                                    end
                                end
                            end
                            
                            if isTarget and not tamedPets[pet.Name] then
                                local prompt = pet:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    targetPrompt = prompt
                                    if pet:IsA("Model") then
                                        petPart = pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart", true)
                                    elseif pet:IsA("BasePart") then
                                        petPart = pet
                                    end
                                    
                                    if petPart then
                                        foundPet = pet; break
                                    end
                                end
                            end
                        end
                        
                        if foundPet and petPart and targetPrompt then
                            isWorkingOnPet = true
                            task.spawn(function()
                                pcall(function()
                                    local timeout = tick() + 15
                                    while foundPet.Parent and petPart.Parent and tick() < timeout do
                                        local distance = (hrp.Position - petPart.Position).Magnitude
                                        if distance <= 5 then break end
                                        humanoid:MoveTo(petPart.Position)
                                        task.wait(0.2)
                                    end
                                    
                                    humanoid:MoveTo(hrp.Position)
                                    if foundPet.Parent and petPart.Parent then
                                        targetPrompt.RequiresLineOfSight = false
                                        targetPrompt.MaxActivationDistance = 20
                                        targetPrompt.HoldDuration = 0
                                        for i = 1, 5 do
                                            pcall(function() fireproximityprompt(targetPrompt) end)
                                            task.wait(0.1)
                                        end
                                        
                                        tamedPets[foundPet.Name] = true
                                        firePetBuffer(foundPet.Name)
                                        task.wait(0.1)
                                        local uuid = string.split(foundPet.Name, "_")[#string.split(foundPet.Name, "_")]
                                        if uuid then firePetBuffer("WildPet_" .. uuid) end
                                        task.wait(1)
                                    end
                                    if foundPet then
                                        task.delay(6, function() tamedPets[foundPet.Name] = nil end)
                                    end
                                end)
                                task.wait(0.5)
                                isWorkingOnPet = false
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- 3. UI SOLO HUB (FULLSCREEN, CLEAN TEXTBOX, COLLAPSIBLE)
-- ==========================================
if CoreGui:FindFirstChild("SoloHub_GUI") then CoreGui.SoloHub_GUI:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SoloHub_GUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local CloseArea = Instance.new("TextButton")
CloseArea.Size = UDim2.new(1, 0, 1, 0)
CloseArea.BackgroundTransparency = 1
CloseArea.Text = ""
CloseArea.ZIndex = 90 
CloseArea.Visible = false
CloseArea.Parent = ScreenGui

local activeWindows = {}
local function CloseAllWindows()
    CloseArea.Visible = false
    for _, win in ipairs(activeWindows) do
        if win.Size.Y.Offset > 0 then
            local tw = TweenService:Create(win, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, 0)})
            tw:Play()
            task.delay(0.25, function()
                if win.Size.Y.Offset == 0 then win.Visible = false end
            end)
        end
    end
end
CloseArea.MouseButton1Click:Connect(CloseAllWindows)

local OpenLogo = Instance.new("ImageButton")
OpenLogo.Size = UDim2.new(0, 50, 0, 50)
OpenLogo.Position = UDim2.new(0, 50, 0, 50)
OpenLogo.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
OpenLogo.Image = "rbxassetid://13470876403"
OpenLogo.ImageColor3 = Color3.fromRGB(220, 30, 30)
OpenLogo.Visible = false
OpenLogo.Active = true
OpenLogo.Draggable = true
OpenLogo.Parent = ScreenGui

Instance.new("UICorner", OpenLogo).CornerRadius = UDim.new(1, 0)
local LogoStroke = Instance.new("UIStroke", OpenLogo)
LogoStroke.Color = Color3.fromRGB(150, 0, 0)
LogoStroke.Thickness = 2

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 400) 
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 10) 
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(150, 0, 0) 
Instance.new("UIStroke", MainFrame).Thickness = 2

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local LogoImg = Instance.new("ImageLabel")
LogoImg.Size = UDim2.new(0, 24, 0, 24)
LogoImg.Position = UDim2.new(0, 15, 0.5, -12)
LogoImg.BackgroundTransparency = 1
LogoImg.Image = "rbxassetid://13470876403" 
LogoImg.ImageColor3 = Color3.fromRGB(220, 30, 30) 
LogoImg.ScaleType = Enum.ScaleType.Crop
LogoImg.Parent = TopBar

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(0, 100, 1, 0)
LogoText.Position = UDim2.new(0, 45, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "Solo Hub"
LogoText.TextColor3 = Color3.fromRGB(255, 60, 60)
LogoText.Font = Enum.Font.GothamBold
LogoText.TextSize = 18
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = TopBar

local GamePill = Instance.new("Frame")
GamePill.Size = UDim2.new(0, 120, 0, 24)
GamePill.Position = UDim2.new(0, 135, 0.5, -12)
GamePill.BackgroundColor3 = Color3.fromRGB(80, 10, 10)
GamePill.Parent = TopBar
Instance.new("UICorner", GamePill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", GamePill).Color = Color3.fromRGB(150, 20, 20)

local GameText = Instance.new("TextLabel")
GameText.Size = UDim2.new(1, 0, 1, 0)
GameText.BackgroundTransparency = 1
GameText.Text = "Grow a Garden 2"
GameText.TextColor3 = Color3.fromRGB(255, 200, 200)
GameText.Font = Enum.Font.GothamSemibold
GameText.TextSize = 11
GameText.Parent = GamePill

-- ====================
-- CONTROL BUTTONS
-- ====================
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- 🔴 FITUR BARU: TOMBOL MAXIMIZE & RESTORE
local MaxBtn = Instance.new("TextButton")
MaxBtn.Size = UDim2.new(0, 24, 0, 24)
MaxBtn.Position = UDim2.new(1, -64, 0.5, -12)
MaxBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
MaxBtn.Text = "[ ]"
MaxBtn.TextSize = 11
MaxBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
MaxBtn.Font = Enum.Font.GothamBold
MaxBtn.Parent = TopBar
Instance.new("UICorner", MaxBtn).CornerRadius = UDim.new(0, 4)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -94, 0.5, -12) -- Digeser sedikit
MinBtn.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() 
    if getgenv().SoloHubLoop then task.cancel(getgenv().SoloHubLoop) end
    ScreenGui:Destroy() 
end)

MinBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false 
    OpenLogo.Visible = true 
    CloseAllWindows()
end)

-- 🔴 LOGIC FULLSCREEN / DEFAULT SIZE
local isMaximized = false
local preMaxPos = UDim2.new(0.5, -210, 0.5, -200)

MaxBtn.MouseButton1Click:Connect(function()
    CloseAllWindows()
    if not isMaximized then
        preMaxPos = MainFrame.Position -- Simpan posisi sebelum diperbesar
        isMaximized = true
        MaxBtn.Text = "><"
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, -40, 1, -40),
            Position = UDim2.new(0, 20, 0, 20)
        }):Play()
    else
        isMaximized = false
        MaxBtn.Text = "[ ]"
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 400),
            Position = preMaxPos
        }):Play()
    end
end)

OpenLogo.MouseButton1Click:Connect(function() 
    OpenLogo.Visible = false 
    MainFrame.Visible = true 
end)

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1, -20, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 45)
ContentScroll.BackgroundColor3 = Color3.fromRGB(18, 15, 15)
ContentScroll.BorderSizePixel = 0
ContentScroll.ScrollBarThickness = 3
ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y 
ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0) 
ContentScroll.Parent = MainFrame
Instance.new("UICorner", ContentScroll).CornerRadius = UDim.new(0, 8)

local ContentLayout = Instance.new("UIListLayout", ContentScroll)
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateCollapsibleSection(title)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(0.95, 0, 0, 35) 
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.ClipsDescendants = true 
    sectionFrame.Parent = ContentScroll
    
    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, 0, 0, 35)
    headerBtn.BackgroundColor3 = Color3.fromRGB(25, 18, 18)
    headerBtn.Text = ""
    headerBtn.Parent = sectionFrame
    Instance.new("UICorner", headerBtn).CornerRadius = UDim.new(0, 6)
    
    local marker = Instance.new("Frame")
    marker.Size = UDim2.new(0, 3, 0.5, 0)
    marker.Position = UDim2.new(0, 10, 0.25, 0)
    marker.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    marker.Parent = headerBtn
    
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(255, 230, 230)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = headerBtn
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -30, 0.5, -10)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 100, 100)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 12
    arrow.Parent = headerBtn

    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, 0, 0, 0)
    contentContainer.Position = UDim2.new(0, 0, 0, 42)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = sectionFrame
    
    local contentLayout = Instance.new("UIListLayout", contentContainer)
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local isOpen = true
    
    local function UpdateSize()
        local targetHeight = isOpen and (contentLayout.AbsoluteContentSize.Y + 45) or 35
        local targetRotation = isOpen and 0 or -90
        
        TweenService:Create(sectionFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0.95, 0, 0, targetHeight)}):Play()
        TweenService:Create(arrow, TweenInfo.new(0.3), {Rotation = targetRotation}):Play()
    end
    
    headerBtn.MouseButton1Click:Connect(function()
        CloseAllWindows()
        isOpen = not isOpen
        UpdateSize()
    end)
    
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            sectionFrame.Size = UDim2.new(0.95, 0, 0, contentLayout.AbsoluteContentSize.Y + 45)
        end
    end)
    
    task.delay(0.1, UpdateSize)
    return contentContainer
end

local function CreateMultiSelect(title, list, configKey, parentObj)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(22, 15, 15)
    container.Parent = parentObj
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(200, 150, 150)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0, 160, 0, 24)
    dropBtn.Position = UDim2.new(1, -170, 0.5, -12)
    dropBtn.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
    dropBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 11
    dropBtn.TextXAlignment = Enum.TextXAlignment.Center
    dropBtn.Parent = container
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", dropBtn).Color = Color3.fromRGB(80, 20, 20)
    
    local function updateBtnText()
        local count = 0
        for _, val in pairs(getgenv().Config[configKey]) do
            if val then count = count + 1 end
        end
        if count == 0 then dropBtn.Text = "None Selected"
        elseif count == 1 then dropBtn.Text = "1 Selected"
        else dropBtn.Text = count .. " Selected" end
    end
    updateBtnText()

    local dropWindow = Instance.new("Frame")
    dropWindow.Size = UDim2.new(0, 180, 0, 0) 
    dropWindow.BackgroundColor3 = Color3.fromRGB(15, 10, 10)
    dropWindow.ZIndex = 100 
    dropWindow.Visible = false
    dropWindow.ClipsDescendants = true 
    dropWindow.Parent = ScreenGui
    Instance.new("UICorner", dropWindow).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", dropWindow).Color = Color3.fromRGB(120, 20, 20)
    
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -10, 0, 24)
    searchBox.Position = UDim2.new(0, 5, 0, 5)
    searchBox.BackgroundColor3 = Color3.fromRGB(25, 15, 15)
    -- 🔴 FIX: MENGHAPUS TULISAN TEXTBOX BAWAAN
    searchBox.Text = "" 
    searchBox.PlaceholderText = "Search..."
    searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 11
    searchBox.ZIndex = 101
    searchBox.Parent = dropWindow
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 4)

    local listScroll = Instance.new("ScrollingFrame")
    listScroll.Size = UDim2.new(1, 0, 1, -35)
    listScroll.Position = UDim2.new(0, 0, 0, 35)
    listScroll.BackgroundTransparency = 1
    listScroll.BorderSizePixel = 0
    listScroll.ZIndex = 100
    listScroll.ScrollBarThickness = 2
    listScroll.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    listScroll.Parent = dropWindow

    local listLayout = Instance.new("UIListLayout", listScroll)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local itemBtns = {}
    for _, itemText in ipairs(list) do
        local isSelected = getgenv().Config[configKey][itemText] or false
        
        local itemBtn = Instance.new("TextButton")
        itemBtn.Size = UDim2.new(1, -10, 0, 24)
        itemBtn.Position = UDim2.new(0, 5, 0, 0)
        itemBtn.BackgroundTransparency = 1
        itemBtn.Text = (isSelected and "[+] " or "[ ] ") .. itemText
        itemBtn.TextColor3 = isSelected and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(150, 150, 150)
        itemBtn.Font = Enum.Font.Gotham
        itemBtn.TextSize = 11
        itemBtn.TextXAlignment = Enum.TextXAlignment.Left
        itemBtn.ZIndex = 101
        itemBtn.Parent = listScroll
        
        itemBtn.MouseButton1Click:Connect(function()
            local currentStatus = getgenv().Config[configKey][itemText]
            local newStatus = not currentStatus
            getgenv().Config[configKey][itemText] = newStatus
            
            itemBtn.Text = (newStatus and "[+] " or "[ ] ") .. itemText
            itemBtn.TextColor3 = newStatus and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(150, 150, 150)
            updateBtnText()
        end)
        
        itemBtns[itemText] = itemBtn
    end
    
    listScroll.CanvasSize = UDim2.new(0, 0, 0, #list * 24)
    
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(searchBox.Text)
        local visibleCount = 0
        
        for text, btn in pairs(itemBtns) do
            if query == "" or string.find(string.lower(text), query) then
                btn.Visible = true
                visibleCount = visibleCount + 1
            else
                btn.Visible = false
            end
        end
        listScroll.CanvasSize = UDim2.new(0, 0, 0, visibleCount * 24)
    end)

    dropBtn.MouseButton1Click:Connect(function()
        if dropWindow.Size.Y.Offset > 0 then
            CloseAllWindows()
        else
            CloseAllWindows()
            CloseArea.Visible = true
            dropWindow.Visible = true
            
            local absPos = dropBtn.AbsolutePosition
            dropWindow.Position = UDim2.new(0, absPos.X, 0, absPos.Y + 26)
            
            TweenService:Create(dropWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 180, 0, 160)}):Play()
        end
    end)

    table.insert(activeWindows, dropWindow)
end

local function CreateToggle(title, configKey, parentObj)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 35)
    container.BackgroundColor3 = Color3.fromRGB(22, 15, 15)
    container.Parent = parentObj
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(240, 100, 100)
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container

    local toggleBase = Instance.new("TextButton")
    toggleBase.Size = UDim2.new(0, 34, 0, 18)
    toggleBase.Position = UDim2.new(1, -44, 0.5, -9)
    toggleBase.BackgroundColor3 = getgenv().Config[configKey] and Color3.fromRGB(220, 20, 20) or Color3.fromRGB(40, 20, 20)
    toggleBase.Text = ""
    toggleBase.Parent = container
    Instance.new("UICorner", toggleBase).CornerRadius = UDim.new(1, 0)

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 14, 0, 14)
    toggleCircle.Position = getgenv().Config[configKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleBase
    Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

    toggleBase.MouseButton1Click:Connect(function()
        getgenv().Config[configKey] = not getgenv().Config[configKey]
        local isEnabled = getgenv().Config[configKey]
        
        local targetPos = isEnabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = isEnabled and Color3.fromRGB(220, 20, 20) or Color3.fromRGB(40, 20, 20)
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
    end)
end

-- ==========================================
-- EKSKUSI PENYUSUNAN UI
-- ==========================================
Instance.new("Frame", ContentScroll).Size = UDim2.new(1, 0, 0, 2)

local SeedSection = CreateCollapsibleSection("Shop Seeds")
CreateMultiSelect("Select Seeds", SeedList, "SelectedSeeds", SeedSection)
CreateMultiSelect("Select Rarity", RarityList, "SelectedRarities", SeedSection)
CreateToggle("Auto Buy Seeds", "AutoBuySeed", SeedSection)
CreateToggle("Auto Buy All Seeds (Rarity)", "AutoBuyRarity", SeedSection)

local GearSection = CreateCollapsibleSection("Shop Gear")
CreateMultiSelect("Select Gear", GearList, "SelectedGears", GearSection)
CreateMultiSelect("Select Rarity", GearRarityList, "SelectedGearRarities", GearSection)
CreateToggle("Auto Buy Gear", "AutoBuyGear", GearSection)
CreateToggle("Auto Buy All Gear (Rarity)", "AutoBuyGearRarity", GearSection)

local PetSection = CreateCollapsibleSection("Buy Pets")
CreateMultiSelect("Pet Finder", PetList, "SelectedPets", PetSection)
CreateMultiSelect("Select Rarity", PetRarityList, "SelectedPetRarities", PetSection)
CreateToggle("Auto Walk & Tame Pets", "AutoBuyPet", PetSection)
CreateToggle("Auto Tame Pets (Rarity)", "AutoBuyPetRarity", PetSection)
