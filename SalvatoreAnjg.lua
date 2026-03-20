local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local throwRemote = ReplicatedStorage:FindFirstChild("Fishing_RemoteThrow")
if not throwRemote then warn("Fishing_RemoteThrow tidak ditemukan") return end
local fishingFolder = ReplicatedStorage:FindFirstChild("Fishing")
if not fishingFolder then warn("Fishing folder tidak ditemukan") return end
local toServer = fishingFolder:FindFirstChild("ToServer")
if not toServer then warn("ToServer tidak ditemukan") return end
local minigameStarted = toServer:FindFirstChild("MinigameStarted")
if not minigameStarted then warn("MinigameStarted tidak ditemukan") return end
local reelFinished = toServer:FindFirstChild("ReelFinished")
if not reelFinished then warn("ReelFinished tidak ditemukan") return end
local sellRemote = ReplicatedStorage:FindFirstChild("Economy"):FindFirstChild("ToServer"):FindFirstChild("SellUnder")
if not sellRemote then warn("SellUnder tidak ditemukan") return end

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

getgenv().Blati = false
getgenv().ForceSecret = false
getgenv().InfiniteJump = false
getgenv().Noclip = false
getgenv().WalkSpeedValue = 16
getgenv().AutoSell = false
getgenv().SellMode = "Count"
getgenv().SellValue = 10

local fishCaught = 0
local lastSellTime = 0
local humanoid = nil

local function getHumanoid()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        humanoid = player.Character.Humanoid
        return humanoid
    end
    return nil
end

player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    getHumanoid()
end)
getHumanoid()

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "HamzHub",
    LoadingTitle = "HamzHub Is Loading",
    LoadingSubtitle = "",
    ShowText = "HamzHub",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = false,
    },
})

local MainTab = Window:CreateTab("MAIN", 4483362458)
local PlayerTab = Window:CreateTab("PLAYER", 4483362458)

MainTab:CreateLabel("MANCING MANUAL 1X BARU IDUPIN BLATI")

local blatiLoop
local function startBlati()
    if blatiLoop then return end
    blatiLoop = task.spawn(function()
        while getgenv().Blati do
            if sessionID and humanoid then
                throwRemote:FireServer(0.017203017487190664, sessionID)
                task.wait()
                minigameStarted:FireServer(sessionID)
                task.wait()
                local successArgs = { duration = 2.2980389329604805, result = "SUCCESS", insideRatio = 0.8 }
                reelFinished:FireServer(successArgs, sessionID)
                fishCaught = fishCaught + 1
                if getgenv().AutoSell and getgenv().SellMode == "Count" and fishCaught >= getgenv().SellValue then
                    if sellRemote then sellRemote:FireServer(800) end
                    fishCaught = 0
                end
            else
                task.wait(0.1)
            end
        end
    end)
end

MainTab:CreateToggle({
    Name = "BLATI (Instant Fishing)",
    CurrentValue = false,
    Flag = "BlatiFlag",
    Callback = function(Value)
        getgenv().Blati = Value
        if Value then
            startBlati()
            local args = { "bd4238ec-6bbc-4523-8c63-a17356e1f130" }
            game:GetService("ReplicatedStorage"):FindFirstChild("FishUI"):FindFirstChild("ToServer"):FindFirstChild("ToggleFavorite"):FireServer(unpack(args))
            game:GetService("ReplicatedStorage"):FindFirstChild("BobberShop"):FindFirstChild("ToServer"):FindFirstChild("GetEquippedBobber"):InvokeServer()
            local backpackTool = player.Backpack:FindFirstChildOfClass("Tool")
            if backpackTool then
                backpackTool.Parent = player.Character
            end
        else
            if blatiLoop then
                task.cancel(blatiLoop)
                blatiLoop = nil
            end
        end
    end,
})
