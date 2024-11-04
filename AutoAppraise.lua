local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local FluentUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Roblox/FluentUI/main/FluentUI.lua"))()
local WeightVal, DelayVal = 100, 0.8
local MutList = {"Aurora", "Mythical", "Midas", "Ghastly", "Sinister", "Mosaic", "Electric", "Glossy", "Silver", "Darkened", "Translucent", "Frozen", "Albino", "Negative"}

local win = FluentUI:NewWindow({
    Title = "Fisch Auto Appraise ",
    Size = UDim2.new(0, 400, 0, 400),
    Draggable = true,
})

local tab = win:Tab("Auto Appraise")

local AutoToggle = tab:Toggle("Auto Appraise Toggle", false, function(t)
    AutoToggle.Value = t
end)

local AppraiseDelay = tab:Textbox("Input Appraise Delay", tostring(DelayVal), function(t)
    DelayVal = tonumber(t) or DelayVal
end)

local WeightToggle = tab:Toggle("Weight Filter Toggle", false, function(t)
    WeightToggle.Value = t
end)

local WeightBox = tab:Textbox("Input Weight Target", tostring(WeightVal), function(t)
    WeightVal = tonumber(t) or WeightVal
end)

local SparklingToggle = tab:Toggle("Sparkling", false, function(t)
    SparklingToggle.Value = t
end)

local ShinyToggle = tab:Toggle("Shiny", false, function(t)
    ShinyToggle.Value = t
end)

local MutationToggle = tab:Toggle("Mutation Toggle", false, function(t)
    MutationToggle.Value = t
end)

local MutationList = tab:MultiDropdown("Mutation Target", MutList, {"Glossy", "Ghastly"}, function(t)
    MutationList.Value = t
end)

WeightBox:Set(tostring(WeightVal))
AppraiseDelay:Set(tostring(DelayVal))

local function has_value(tab, val)
    for _, value in ipairs(tab) do
        if type(value) ~= "table" and string.find(tostring(value), tostring(val)) then
            return true
        elseif type(value) == "table" and value.Name and string.find(value.Name, val) then
            return true
        end
    end
    return false
end

local function getTools()
    for _, v in pairs(player.Character:GetChildren()) do
        if v:IsA("Tool") then
            return v
        end
    end
    return nil
end

player.Backpack.ChildAdded:Connect(function(instance)
    if instance:IsA("Tool") and not instance:FindFirstChild("link") then
        repeat task.wait() until instance:FindFirstChild("link")
        local oldtools = getTools()
        if oldtools then oldtools.Parent = player.Backpack end
        if AutoToggle.Value then
            player.PlayerGui.hud.safezone.backpack.events.equip:FireServer(instance)
        end
    end
end)

local function applyFilter(statFolder)
    if WeightToggle.Value and statFolder.Weight.Value < tonumber(WeightVal) then
        return false
    end
    if SparklingToggle.Value and not statFolder:FindFirstChild("Sparkling") then
        return false
    end
    if ShinyToggle.Value and not statFolder:FindFirstChild("Shiny") then
        return false
    end
    if MutationToggle.Value then
        local Mutation = statFolder:FindFirstChild("Mutation")
        if not Mutation or not has_value(MutationList.Value, Mutation.Value) then
            return false
        end
    end
    return true
end

local function AutoAppraise()
    if not AutoToggle.Value then return end
    local tools = getTools()
    if tools and AutoToggle.Value then
        local statFolder = tools.link.Value
        local Filtered = applyFilter(statFolder)
        if Filtered then return end
        workspace.world.npcs.Appraiser.appraiser.appraise:InvokeServer()
        task.wait(tonumber(DelayVal))
    end
end

while wait() do
    AutoAppraise()
end
