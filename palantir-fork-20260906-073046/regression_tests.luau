local condition3


condition3 = function()
	local function f385(...)
		local t719 = { _version = "0.1.2" }
		local items4 = {
			["\\"] = "\\",
			["\""] = "\"",
			["\8"] = "b",
			["\12"] = "f",
			["\n"] = "n",
			["\r"] = "r",
			["\t"] = "t"
		}
		local t720 = { ["/"] = "/" }
		local v941, v942, f386
		f386, v942, v941 = pairs(items4)
		local v943, f387
		while true do
			local v944
			v941, v944 = f386(v942, v941)
			f387 = nil
			v943 = nil
			if v941 == nil then
				break
			end
			t720[v944] = v941
		end

		local function f388(key45)
			local v945 = items4[key45]
			if not v945 then
				v945 = string.format("u%04x", key45:byte())
			end
			return "\\" .. v945
		end

		local function f389()
			return "null"
		end

		local function f390(items5, p220)
			local stack7 = {}
			if not p220 then
				p220 = {}
			end
			if p220[items5] then
				error("circular reference")
			end
			p220[items5] = true
			if rawget(items5, 1) == nil and next(items5) ~= nil then
				for key46, value9 in pairs(items5) do
					if type(key46) ~= "string" then
						error("invalid table: mixed or invalid key types")
					end
					table.insert(stack7, f387(key46, p220) .. ":" .. f387(value9, p220))
				end
				p220[items5] = nil
				return "{" .. table.concat(stack7, ",") .. "}"
			end
			local v946 = 0
			for key47, _ in pairs(items5) do
				if type(key47) ~= "number" then
					error("invalid table: mixed or invalid key types")
				end
				v946 = v946 + 1
			end
			if v946 ~= #items5 then
				error("invalid table: sparse array")
			end
			for _, value10 in ipairs(items5) do
				table.insert(stack7, f387(value10, p220))
			end
			p220[items5] = nil
			return "[" .. table.concat(stack7, ",") .. "]"
		end

		local function f391(p221)
			return "\"" .. p221:gsub("[%z\1-\31\\\"]", f388) .. "\""
		end

		local function f392(p222)
			if not (p222 == p222 and not (p222 <= -math.huge) and not (math.huge <= p222)) then
				error("unexpected number value '" .. tostring(p222) .. "'")
			end
			return (string.format("%.14g", p222))
		end

		local t721 = { ["nil"] = f389, table = f390, string = f391, number = f392 }
		v943 = tostring
		t721.boolean = v943

		f387 = function(p223, p224)
			local key48 = type(p223)
			local condition76 = t721[key48]
			if condition76 then
				return (condition76(p223, p224))
			end
			error("unexpected type '" .. key48 .. "'")
		end

		v943 = "encode"

		function t719.encode(p225)
			return (f387(p225))
		end

		v943 = nil

		local function f393(...)
			local t722 = {}
			local v947 = select("#", ...)
			for index = 1, v947 do
				t722[select(index, ...)] = true
			end
			return t722
		end

		local v948 = f393(" ", "\t", "\r", "\n")
		local v949 = f393(" ", "\t", "\r", "\n", "]", "}", ",")
		local v950 = f393("\\", "/", "\"", "b", "f", "n", "r", "t", "u")
		local v951 = f393("true", "false", "null")
		local t723 = { ["true"] = true, ["false"] = false, null = nil }

		local function f394(p226, p227, p228, p229)
			local v952 = p227 - 1
			while true do
				v952 = v952 + 1
				if not (v952 <= #p226) then
					break
				end
				if p228[p226:sub(v952, v952)] ~= p229 then
					return v952
				end
			end
			return #p226 + 1
		end

		local function f395(p230, p231, p232)
			local v953 = 1
			local v954 = 1
			for index15 = 1, p231 - 1 do
				v954 = v954 + 1
				if p230:sub(index15, index15) == "\n" then
					v953 = v953 + 1
					v954 = 1
				end
			end
			error(string.format("%s at line %d col %d", p232, v953, v954))
		end

		local function f396(p233)
			local _ = math.floor
			if p233 <= 127 then
				return (string.char(p233))
			end
			if p233 <= 2047 then
				return (string.char(math.floor(p233 / 64) + 192, p233 % 64 + 128))
			end
			if p233 <= 65535 then
				return (string.char(
					math.floor(p233 / 4096) + 224,
					math.floor(p233 % 4096 / 64) + 128,
					p233 % 64 + 128
				))
			end
			if p233 <= 1114111 then
				return (string.char(
					math.floor(p233 / 262144) + 240,
					math.floor(p233 % 262144 / 4096) + 128,
					math.floor(p233 % 4096 / 64) + 128,
					p233 % 64 + 128
				))
			end
			error(string.format("invalid unicode codepoint '%x'", p233))
		end

		local function f397(p234)
			local v955 = tonumber(p234:sub(1, 4), 16)
			local condition77 = tonumber(p234:sub(7, 10), 16)
			if condition77 then
				return (f396((v955 - 55296) * 1024 + (condition77 - 56320) + 65536))
			end
			return (f396(v955))
		end

		local function f398(p235, p236)
			local v956 = ""
			local v957 = p236 + 1
			local v958 = v957
			while v958 <= #p235 do
				local byte2 = p235:byte(v958)
				if byte2 < 32 then
					f395(p235, v958, "control character in string")
				elseif byte2 == 92 then
					local v959 = v956 .. p235:sub(v957, v958 - 1)
					v958 = v958 + 1
					local sub = p235:sub(v958, v958)
					if sub == "u" then
						local match4 = p235:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", v958 + 1)
						if not match4 then
							match4 = p235:match("^%x%x%x%x", v958 + 1)
						end
						if not match4 then
							match4 = f395(p235, v958 - 1, "invalid unicode escape in string")
						end
						v956 = v959 .. f397(match4)
						v958 = v958 + #match4
					else
						if not v950[sub] then
							f395(p235, v958 - 1, "invalid escape char '" .. sub .. "' in string")
						end
						v956 = v959 .. t720[sub]
					end
					v957 = v958 + 1
				elseif byte2 == 34 then
					return v956 .. p235:sub(v957, v958 - 1), v958 + 1
				end
				v958 = v958 + 1
			end
			f395(p235, p236, "expected closing quote for string")
		end

		local function f399(p237, p238)
			local v960 = f394(p237, p238, v949)
			local sub2 = p237:sub(p238, v960 - 1)
			local v961 = tonumber(sub2)
			if not v961 then
				f395(p237, p238, "invalid number '" .. sub2 .. "'")
			end
			return v961, v960
		end

		local function f400(p239, p240)
			local v962 = f394(p239, p240, v949)
			local sub3 = p239:sub(p240, v962 - 1)
			if not v951[sub3] then
				f395(p239, p240, "invalid literal '" .. sub3 .. "'")
			end
			return t723[sub3], v962
		end

		local function f401(p241, p242)
			local v963 = 1
			local t724 = {}
			local v964 = p242 + 1
			local _leave17 = false
			local v965
			while true do
				v965 = f394(p241, v964, v948, true)
				if p241:sub(v965, v965) == "]" then
					break
				end
				local v966, v967
				v967, v966 = v943(p241, v965)
				t724[v963] = v967
				v963 = v963 + 1
				local v968 = f394(p241, v966, v948, true)
				local sub4 = p241:sub(v968, v968)
				v964 = v968 + 1
				if sub4 == "]" then
					_leave17 = true
					break
				end
				if sub4 ~= "," then
					f395(p241, v964, "expected ']' or ','")
				end
			end
			if not _leave17 then
				v964 = v965 + 1
			end
			return t724, v964
		end

		local function f402(p243, p244)
			local t725 = {}
			local v969 = p244 + 1
			local _leave18 = false
			local v970
			while true do
				v970 = f394(p243, v969, v948, true)
				if p243:sub(v970, v970) == "}" then
					break
				end
				if p243:sub(v970, v970) ~= "\"" then
					f395(p243, v970, "expected string for key")
				end
				local v971, v972
				v972, v971 = v943(p243, v970)
				local v973 = f394(p243, v971, v948, true)
				if p243:sub(v973, v973) ~= ":" then
					f395(p243, v973, "expected ':' after key")
				end
				local v974, v975
				v975, v974 = v943(p243, (f394(p243, v973 + 1, v948, true)))
				t725[v972] = v975
				local v976 = f394(p243, v974, v948, true)
				local sub5 = p243:sub(v976, v976)
				v969 = v976 + 1
				if sub5 == "}" then
					_leave18 = true
					break
				end
				if sub5 ~= "," then
					f395(p243, v969, "expected '}' or ','")
				end
			end
			if not _leave18 then
				v969 = v970 + 1
			end
			return t725, v969
		end

		local t726 = {
			["\""] = f398,
			["0"] = f399,
			["1"] = f399,
			["2"] = f399,
			["3"] = f399,
			["4"] = f399,
			["5"] = f399,
			["6"] = f399,
			["7"] = f399,
			["8"] = f399,
			["9"] = f399,
			["-"] = f399,
			t = f400,
			f = f400,
			n = f400,
			["["] = f401,
			["{"] = f402
		}

		v943 = function(p245, p246)
			local sub6 = p245:sub(p246, p246)
			local condition78 = t726[sub6]
			if condition78 then
				return condition78(p245, p246)
			end
			f395(p245, p246, "unexpected character '" .. sub6 .. "'")
		end

		function t719.decode(p247)
			if type(p247) ~= "string" then
				error("expected argument of type string, got " .. type(p247))
			end
			local v977, v978
			v978, v977 = v943(p247, f394(p247, 1, v948, true))
			local v979 = f394(p247, v977, v948, true)
			if v979 <= #p247 then
				f395(p247, v979, "trailing garbage")
			end
			return v978
		end

		return t719
	end

	return (f385())
end


local json = condition3()
local decoded = json.decode('{"name":"test","values":[1,true,false],"escaped":"a\\nb"}')
assert(decoded.name == "test")
assert(decoded.values[1] == 1 and decoded.values[2] == true and decoded.values[3] == false)
assert(decoded.escaped == "a\nb")
assert(json.decode(json.encode({message = "hello", value = 42})).value == 42)
assert(json.decode('"\\u0041"') == "A")
assert(not pcall(json.decode, '{bad json}'))
local function f79(_, p134, ...)

				local t288 = select(1, ...)
				if type(t288) == "table" then
					p134.Text = t288.Text
					p134.Func = t288.Func
					p134.DoubleClick = t288.DoubleClick
					p134.DoubleClickText = t288.DoubleClickText
					p134.Tooltip = t288.Tooltip
				else
					p134.Text = select(1, ...)
					p134.Func = select(2, ...)
				end
				local _ = assert
				local v594
				v594 = type(p134.Func) == "function"
				assert(v594, "AddButton: `Func` callback is missing.")
			end

			
local callback = function() end
local target = {}
f79(nil, target, "Run", callback)
assert(target.Text == "Run" and target.Func == callback)
target = {}
f79(nil, target, {Text = "Confirm", Func = callback, DoubleClick = true, Tooltip = "Tip"})
assert(target.Text == "Confirm" and target.Func == callback and target.DoubleClick and target.Tooltip == "Tip")
assert(not pcall(f79, nil, {}, "Missing callback"))
print("PASS: JSON initialization, decode/encode/escapes, invalid input, button argument forms")

local Vector2 = {zero = {}, new = function(...) return {...} end}
local UDim2 = {fromOffset = function(...) return {...} end, fromScale = function(...) return {...} end}
local function windowOptions(...)

			local t577 = { select(2, ...) }
			local t578 = { AnchorPoint = Vector2.zero }
			local t579 = select(2, ...)
			if type(t579) ~= "table" then
				t578.Title = t577[1]
				local v803 = t577[2]
				if not v803 then
					v803 = false
				end
				t578.AutoShow = v803
				t579 = t578
			end
			if type(t579.Title) ~= "string" then
				t579.Title = "No title"
			end
			if type(t579.TabPadding) ~= "number" then
				t579.TabPadding = 0
			end
			if type(t579.MenuFadeTime) ~= "number" then
				t579.MenuFadeTime = 0.2
			end
			if typeof(t579.Position) ~= "UDim2" then
				t579.Position = UDim2.fromOffset(175, 50)
			end
			if typeof(t579.Size) ~= "UDim2" then
				t579.Size = UDim2.fromOffset(680, 620)
			end
			if t579.Center then
				t579.AnchorPoint = Vector2.new(0.5, 0.5)
				t579.Position = UDim2.fromScale(0.5, 0.5)
			end
			
return t579
end
assert(windowOptions({}, {Title = "Window", Center = true}).Title == "Window")
assert(windowOptions({}, "Legacy", true).AutoShow == true)
assert(windowOptions({}, "Legacy", true).Title == "Legacy")
local table56 = {GiveSignal = function() end}
local v810, v811, v812, v399 = false, false, nil, false
local v804 = {Visible = false}
local v391 = {Enabled = true, Parent = {}}
local v884 = {Modal = false}
local object98 = {MouseBehavior = "LockCenter", MouseIconEnabled = false}
local t598 = {MenuFadeTime = 0}
local t64, t66, t67, t68 = {}, {}, {}, {}
local shared = {}
local Enum = {MouseBehavior = {Default = "Default"}}
local frameCallback
local disconnects = 0
local game = {GetService = function()
    return {RenderStepped = {Connect = function(_, callback)
        frameCallback = callback
        return {Disconnect = function() disconnects += 1 end}
    end}}
end}
local savedMouseBehavior, savedMouseIcon

			local function releaseMenuMouse()
				v884.Modal = false
				if v812 then
					v812:Disconnect()
					v812 = nil
				end
				shared._PalantirX_MouseEnforce = nil
				if savedMouseBehavior ~= nil then
					object98.MouseBehavior = savedMouseBehavior
					object98.MouseIconEnabled = savedMouseIcon
					savedMouseBehavior, savedMouseIcon = nil, nil
				end
			end

			
function table56.Toggle(forceVisible)

				if v810 then
					return
				end
				local condition72
				condition72 = 0.01 < t598.MenuFadeTime
				if condition72 then
					v810 = true
				end
				if type(forceVisible) == "boolean" then
					v399 = forceVisible
				else
					v399 = not v399
				end
				v804.Visible = v399
				v884.Modal = v399
				if v399 then
					if savedMouseBehavior == nil then
						savedMouseBehavior = object98.MouseBehavior
						savedMouseIcon = object98.MouseIconEnabled
					end
					object98.MouseBehavior = Enum.MouseBehavior.Default
					object98.MouseIconEnabled = true
					if not v812 then
						local function f365()
							if not (v399 and v804.Visible and v391.Enabled and v391.Parent) then
								v399 = false
								releaseMenuMouse()
								return
							end
							if object98.MouseBehavior ~= Enum.MouseBehavior.Default then
								object98.MouseBehavior = Enum.MouseBehavior.Default
							end
							if not object98.MouseIconEnabled then
								object98.MouseIconEnabled = true
							end
						end

						v812 = game:GetService("RunService").RenderStepped:Connect(f365)
						table56:GiveSignal(v812)
						shared._PalantirX_MouseEnforce = v812
					end
				else
					releaseMenuMouse()
				end
				if v399 then
					v804.Visible = true
				end
				if not v399 then
					local _ = next
					local v885 = t64
					local v886 = nil
					while true do
						local object99
						v886, object99 = next(v885, v886)
						if v886 == nil then
							break
						end
						object99:Hide()
					end
					local _ = next
					local v887 = t66
					local v888 = nil
					while true do
						local v889
						v888, v889 = next(v887, v888)
						if v888 == nil then
							break
						end
						v889:Hide()
					end
					local _ = next
					local v890 = t67
					local v891 = nil
					while true do
						local v892
						v891, v892 = next(v890, v891)
						if v891 == nil then
							break
						end
						v892.Visible = false
					end
					local _ = next
					local v893 = t68
					local v894 = nil
					while true do
						local v895
						v894, v895 = next(v893, v894)
						if v894 == nil then
							break
						end
						v895.Visible = false
					end
				end
				v811 = true
				v804.Visible = v399
				v810 = false
			end

			
table56.Toggle(true)
table56.Toggle(true)
assert(v804.Visible and v884.Modal)
v391.Enabled = false
frameCallback()
assert(not v884.Modal and shared._PalantirX_MouseEnforce == nil and disconnects == 1)
assert(object98.MouseBehavior == "LockCenter" and object98.MouseIconEnabled == false)
v391.Enabled = true
table56.Toggle(true)
table56.Toggle(false)
assert(not v804.Visible and not v884.Modal and disconnects == 2)
assert(object98.MouseBehavior == "LockCenter" and object98.MouseIconEnabled == false)
print("PASS: window options, repeated show, hidden-menu mouse release, explicit close")

do
local now = 0
local os = {clock = function() return now end}
local messages = {}
local env = {}
local getgenv = function() return env end
local warn = function(message) table.insert(messages, message) end
local print = warn
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

for i = 1, 100 do warn("Repeated failure") end
assert(#messages == 1 and env.PALANTIR_LOG.suppressed == 99)
for i = 1, 20 do print("Message " .. i) end
assert(#messages == 5)
now = 11
warn("Repeated failure")
assert(#messages == 6)
for i = 1, 200 do warn("More " .. i) end
assert(#env.PALANTIR_LOG.records <= 100)
end
print("PASS: repeated-log suppression, global rate budget, window reset, bounded log history")
