local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ================== REMOTE CHECK ==================
local throwRemote = ReplicatedStorage:FindFirstChild("Fishing_RemoteThrow")
if throwRemote then print("✅ Fishing_RemoteThrow ditemukan") else warn("❌ Fishing_RemoteThrow tidak ditemukan") return end

local fishingFolder = ReplicatedStorage:FindFirstChild("Fishing")
if fishingFolder then print("✅ Fishing folder ditemukan") else warn("❌ Fishing folder tidak ditemukan") return end

local toServer = fishingFolder:FindFirstChild("ToServer")
local minigameStarted = toServer and toServer:FindFirstChild("MinigameStarted")
local reelFinished = toServer and toServer:FindFirstChild("ReelFinished")
local sellRemote = ReplicatedStorage:FindFirstChild("Economy") and ReplicatedStorage.Economy:FindFirstChild("ToServer") and ReplicatedStorage.Economy.ToServer:FindFirstChild("SellUnder")

if not minigameStarted then warn("❌ MinigameStarted tidak ditemukan") end
if not reelFinished then warn("❌ ReelFinished tidak ditemukan") end
if not sellRemote then warn("❌ SellUnder tidak ditemukan") end

-- ================== SESSION ID HOOK ==================
local sessionID = nil
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    if getnamecallmethod() == "FireServer" and self == throwRemote then
        local args = {...}
        if typeof(args[2]) == "string" and #args[2] > 20 then
            sessionID = args[2]
            print("✅ Session ID captured: " .. sessionID)
        end
    end
    return oldNamecall(self, ...)
end))

-- ================== SETTINGS ==================
getgenv().Blati = false
getgenv().ForceSecret = false
getgenv().InfiniteJump = false
getgenv().Noclip = false
getgenv().WalkSpeedValue = 16
getgenv().AutoSell = false
getgenv().SellMode = "Count"      -- Count / Time
getgenv().SellValue = 10

local fishCaught = 0
local lastSellTime = os.clock()
local humanoid = nil
local blatiLoop = nil
local infJumpConn = nil
local noclipConn = nil

local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        humanoid = player.Character.Humanoid
        humanoid.WalkSpeed = getgenv().WalkSpeedValue
        return humanoid
    end
    return nil
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    getHumanoid()
end)
getHumanoid()

-- ================== BLATI FUNCTION (VERSI TEMEN LU) ==================
local function startBlati()
    if blatiLoop then return end
    blatiLoop = task.spawn(function()
        while getgenv().Blati do
            if sessionID and humanoid then
                print("🎣 Memulai proses memancing...")
                throwRemote:FireServer(0.017203017487190664, sessionID)
                task.wait()
                minigameStarted:FireServer(sessionID)
                task.wait()

                local result = getgenv().ForceSecret and "SECRET" or "SUCCESS"
                local successArgs = { duration = 2.2980389329604805, result = result, insideRatio = 0.8 }
                reelFinished:FireServer(successArgs, sessionID)

                fishCaught = fishCaught + 1
                print("🐟 Ikan tertangkap! Total: " .. fishCaught)

                -- AUTO SELL LOGIC
                if getgenv().AutoSell then
                    if getgenv().SellMode == "Count" and fishCaught >= getgenv().SellValue then
                        if sellRemote then sellRemote:FireServer(800) end
                        print("💰 Auto Sell (Count) - " .. fishCaught .. " ikan")
                        fishCaught = 0
                    elseif getgenv().SellMode == "Time" and (os.clock() - lastSellTime >= getgenv().SellValue) then
                        if sellRemote then sellRemote:FireServer(800) end
                        print("💰 Auto Sell (Time) - setiap " .. getgenv().SellValue .. " detik")
                        lastSellTime = os.clock()
                    end
                end
            else
                warn("⚠️ SessionID atau Humanoid belum siap, tunggu...")
                task.wait(0.1)
            end
        end
    end)
end

-- ================== RAYFIELD UI ==================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "HamzHub v2",
    LoadingTitle = "HamzHub Is Loading",
    LoadingSubtitle = "BLATI + Full Features",
    ShowText = "HamzHub",
    Theme = "Default",
    ToggleUIKeybind = "K",
})

local MainTab = Window:CreateTab("MAIN", 4483362458)
local PlayerTab = Window:CreateTab("PLAYER", 4483362458)

MainTab:CreateLabel("MANCING MANUAL 1X BARU IDUPIN BLATI")

-- BLATI TOGGLE
MainTab:CreateToggle({
    Name = "BLATI (Instant Fishing)",
    CurrentValue = false,
    Flag = "BlatiFlag",
    Callback = function(Value)
        getgenv().Blati = Value
        if Value then
            startBlati()
            -- Setup otomatis (favorite + bobber + equip rod)
            local args = { "bd4238ec-6bbc-4523-8c63-a17356e1f130" }
            ReplicatedStorage:FindFirstChild("FishUI"):FindFirstChild("ToServer"):FindFirstChild("ToggleFavorite"):FireServer(unpack(args))
            ReplicatedStorage:FindFirstChild("BobberShop"):FindFirstChild("ToServer"):FindFirstChild("GetEquippedBobber"):InvokeServer()
            
            local tool = player.Backpack:FindFirstChildOfClass("Tool")
            if tool then tool.Parent = player.Character end
        else
            if blatiLoop then task.cancel(blatiLoop) blatiLoop = nil end
        end
    end,
})

-- FORCE SECRET
MainTab:CreateToggle({
    Name = "Force Secret Fish",
    CurrentValue = false,
    Callback = function(Value) getgenv().ForceSecret = Value end,
})

-- AUTO SELL
MainTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Callback = function(Value) getgenv().AutoSell = Value end,
})

MainTab:CreateDropdown({
    Name = "Sell Mode",
    Options = {"Count", "Time"},
    CurrentOption = {"Count"},
    Multiple = false,
    Callback = function(Value) getgenv().SellMode = Value[1] end,
})

MainTab:CreateSlider({
    Name = "Sell Value",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(Value) getgenv().SellValue = Value end,
})

-- PLAYER TAB
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().InfiniteJump = Value
        if Value then
            if infJumpConn then infJumpConn:Disconnect() end
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if humanoid then humanoid.Jump = true end
            end)
        else
            if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
        end
    end,
})

PlayerTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().Noclip = Value
        if Value then
            if noclipConn then noclipConn:Disconnect() end
            noclipConn = RunService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        end
    end,
})

PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        getgenv().WalkSpeedValue = Value
        if humanoid then humanoid.WalkSpeed = Value end
    end,
})

print("🚀 HamzHub v2 Loaded! Tekan K untuk buka menu.")
