-- Read-only camera diagnostics. Run after closing the menu, then move the mouse
-- (and hold the right mouse button if that is how you normally turn the camera).
local players = game:GetService("Players")
local input = game:GetService("UserInputService")
local player = players.LocalPlayer
local reportLines = {}
local function report(key, value)
    local line = "[Palantir camera] " .. key .. ": " .. tostring(value)
    table.insert(reportLines, line)
    warn(line)
end
report("Prepare", "Close the console, Roblox settings, and Palantir menu. Sampling starts in 8 seconds; then hold right mouse and move it for 6 seconds.")
task.wait(8)
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
local function visibility(item)
    local ancestor = item
    local screen = false
    while ancestor do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then
            return false, "hidden ancestor: " .. ancestor:GetFullName()
        end
        if ancestor:IsA("ScreenGui") then
            screen = true
            if not ancestor.Enabled then
                return false, "disabled ScreenGui: " .. ancestor:GetFullName()
            end
        end
        ancestor = ancestor.Parent
    end
    return screen, screen and "visible hierarchy" or "no ScreenGui"
end
local seen = {}
for _, parent in ipairs(parents) do
    local ok, descendants = pcall(parent.GetDescendants, parent)
    if ok then
        for _, item in ipairs(descendants) do
            if item:IsA("GuiButton") and item.Modal and not seen[item] then
                seen[item] = true
                local visible, reason = visibility(item)
                if visible then
                    report("Potentially active modal", item:GetFullName() .. " (" .. reason .. ")")
                end
            end
        end
    end
end
local movements = 0
local rightMouseMovements = 0
local processedMovements = 0
local connection = input.InputChanged:Connect(function(event, processed)
    if event.UserInputType == Enum.UserInputType.MouseMovement then
        movements += 1
        if processed then processedMovements += 1 end
        if input:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            rightMouseMovements += 1
        end
    end
end)
local start = camera and camera.CFrame
local maxAngle, maxPosition, frames = 0, 0, 0
local modes = {}
local cameraReplaced = false
local sampling = game:GetService("RunService").RenderStepped:Connect(function()
    frames += 1
    modes[tostring(input.MouseBehavior)] = true
    local current = workspace.CurrentCamera
    if current ~= camera then cameraReplaced = true end
    if current and start then
        local relative = start:ToObjectSpace(current.CFrame)
        local _, angle = relative:ToAxisAngle()
        maxAngle = math.max(maxAngle, math.deg(math.abs(angle)))
        maxPosition = math.max(maxPosition, (current.CFrame.Position - start.Position).Magnitude)
    end
end)
task.wait(6)
connection:Disconnect()
sampling:Disconnect()
report("Mouse movement events", movements)
report("Movement events while holding right mouse", rightMouseMovements)
report("UI-processed movement events", processedMovements)
report("Camera rotation degrees (maximum)", string.format("%.3f", maxAngle))
report("Camera translation studs (maximum)", string.format("%.3f", maxPosition))
report("Rendered frames", frames)
report("CurrentCamera replaced", cameraReplaced)
for mode in pairs(modes) do report("Mouse mode observed", mode) end
report("Final CameraType", camera and camera.CameraType)
report("Final MouseBehavior", input.MouseBehavior)
local output = table.concat(reportLines, "\n")
if type(writefile) == "function" then
    local ok, err = pcall(writefile, "palantir-camera-report.txt", output)
    if not ok then warn("Could not save camera report: " .. tostring(err)) end
end
if type(setclipboard) == "function" then pcall(setclipboard, output) end
local environment = (getgenv and getgenv()) or _G
environment.PALANTIR_CAMERA_REPORT = output
