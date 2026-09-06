-- Read-only camera diagnostics. Run after closing the menu, then move the mouse
-- (and hold the right mouse button if that is how you normally turn the camera).
local players = game:GetService("Players")
local input = game:GetService("UserInputService")
local player = players.LocalPlayer
local function report(key, value)
    warn("[Palantir camera] " .. key .. ": " .. tostring(value))
end
local camera = workspace.CurrentCamera
report("CameraType", camera and camera.CameraType)
report("CameraSubject", camera and camera.CameraSubject)
report("MouseBehavior", input.MouseBehavior)
report("Menu mouse enforcement", shared._PalantirX_MouseEnforce ~= nil)
local scripts = player and player:FindFirstChild("PlayerScripts")
local actor = scripts and scripts:FindFirstChild("ClientActor")
local manager = actor and actor:FindFirstChild("ClientManager")
report("ClientManager.Enabled", manager and manager.Enabled)
local character = player and player.Character
local root = character and character:FindFirstChild("HumanoidRootPart")
report("Character anchored", root and root.Anchored)
if scripts then
    for _, item in ipairs(scripts:GetDescendants()) do
        if item:IsA("LocalScript") and not item.Enabled then
            report("Disabled LocalScript", item:GetFullName())
        end
    end
end
local parents = {game:GetService("CoreGui")}
if player and player:FindFirstChild("PlayerGui") then
    table.insert(parents, player.PlayerGui)
end
if type(gethui) == "function" then
    local ok, hidden = pcall(gethui)
    if ok and hidden then table.insert(parents, hidden) end
end
local seen = {}
for _, parent in ipairs(parents) do
    local ok, descendants = pcall(parent.GetDescendants, parent)
    if ok then
        for _, item in ipairs(descendants) do
            if item:IsA("GuiButton") and item.Modal and not seen[item] then
                seen[item] = true
                report("Modal button", item:GetFullName() .. " Visible=" .. tostring(item.Visible))
            end
        end
    end
end
local movements = 0
local connection = input.InputChanged:Connect(function(event)
    if event.UserInputType == Enum.UserInputType.MouseMovement then movements += 1 end
end)
local start = camera and camera.CFrame
report("Sampling", "Move the mouse for five seconds")
task.wait(5)
connection:Disconnect()
report("Mouse movement events", movements)
report("Camera changed", camera and camera.CFrame ~= start)
report("Final CameraType", camera and camera.CameraType)
report("Final MouseBehavior", input.MouseBehavior)
