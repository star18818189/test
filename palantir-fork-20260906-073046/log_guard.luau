-- Scoped to the bundled entry; does not replace the game's global logger.
local originalWarn, originalPrint = warn, print
local logEnvironment = (getgenv and getgenv()) or _G
local logState = {records = {}, suppressed = 0}
logEnvironment.PALANTIR_LOG = logState
local windowStart, emitted = os.clock(), 0
local recent = {}
local function emitLog(sink, ...)
    local args = table.pack(...)
    local pieces = {}
    for i = 1, args.n do pieces[i] = tostring(args[i]) end
    local message = table.concat(pieces, "\t")
    if message == "" then return end
    local now = os.clock()
    if now - windowStart >= 10 then
        windowStart, emitted, recent = now, 0, {}
    end
    if recent[message] then
        logState.suppressed += 1
        return
    end
    if #logState.records >= 100 then table.remove(logState.records, 1) end
    table.insert(logState.records, message)
    if emitted >= 5 then
        logState.suppressed += 1
        return
    end
    recent[message] = true
    emitted += 1
    sink(...)
end
local function warn(...) emitLog(originalWarn, ...) end
local function print(...) emitLog(originalPrint, ...) end
