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

return Utilities
