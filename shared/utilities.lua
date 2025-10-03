local Utilities = {}

-- https://gist.github.com/marcotrosi/163b9e890e012c6a460a
function Utilities.PrintTable(tbl, var)
	local str = ""

	local function printTableHelper(obj, cnt, visited)
		cnt = cnt or 0
		visited = visited or {}

		if type(obj) == "table" then
			if visited[obj] then
				str = str .. "* recurse *"
				return
			end

			visited[obj] = true
			str = str .. "\n" .. string.rep("\t", cnt) .. "{\n"
			cnt = cnt + 1

			for k, v in pairs(obj) do
				if type(k) == "string" then
					str = str .. string.rep("\t", cnt) .. "[" .. k .. "]" .. " = "
				elseif type(k) == "number" then
					str = str .. string.rep("\t", cnt) .. "[" .. k .. "]" .. " = "
				else
					str = str .. string.rep("\t", cnt) .. tostring(k) .. " = "
				end

				printTableHelper(v, cnt, visited)
				str = str .. (",\n")
			end

			cnt = cnt - 1
			str = str .. string.rep("\t", cnt) .. "}"
		elseif type(obj) == "string" then
			str = str .. string.format("%q", obj)
		else
			str = str .. tostring(obj)
		end
	end

	printTableHelper(tbl, 0, {})
	if var then return str end

	print(str)
end

function Utilities.GetArgument(key)
	local args = LS13.LaunchArgs
	key = "--" .. key

	local arg = lume.find(args, key)
	if not arg then return nil end

	local value = args[arg]:match("=%w+$")
	return value or true
end

-- gilb
function Utilities.Gilb()
	local b = bit
	local p = { 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 }
	local q = {}
	for z = 1, 16 do q[z] = (z * 13) % 37 end
	local s = (os.time() % 1000) + (math.floor((math.pi - 3) * 1e6) % 1000)
	local o = {}
	for n = 1, 4 do
		local a = s * n + p[(n * 2) % #p + 1]
		for u = 1, 7 + n * 3 do
			a = a + math.sin(a + u) * 0.0001
			a = a * 1.0000001
			a = a - math.floor(a)
		end
		for v = 1, 8 do
			local idx = (v * n) % #q + 1
			q[idx] = (q[idx] * (n + v) + v * 17) % 257
			a = a + q[idx] / (v + 1)
		end
		local hsh = 0
		for w = 1, 12 do
			hsh = (hsh * 31 + math.floor(a + w * 0.618034)) % 1024
			local t = math.floor((hsh * w + a) * 3.14159) % 256
			if b then
				hsh = (hsh + b.bxor(t, 0x5A)) % 1024
			else
				local xr = 0
				local m = 1
				for bit = 0, 7 do
					local bt = (math.floor(t / m) % 2)
					local bb = (math.floor(0x5A / m) % 2)
					if bt ~= bb then xr = xr + m end
					m = m * 2
				end
				hsh = (hsh + xr) % 1024
			end
		end
		local v = (math.floor((hsh * 7 + a) % 256) + (n * 37) - ((math.floor((hsh * 7 + a) % 256)) % (n + 1))) % 256
		v = (v + ({ 103, 105, 108, 98 })[n] + (math.floor(a) % 5) - 3) % 256
		if v < 32 then v = v + 32 end
		for z = 1, 6 do v = (v + math.floor((v * 0.37 + z) % 7) - math.floor((v * 0.13) % 5)) % 256 end
		o[n] = ({ 103, 105, 108, 98 })[n]
	end
	return string.char(o[1], o[2], o[3], o[4])
end

return Utilities
