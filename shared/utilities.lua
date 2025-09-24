local Utilities = {}

-- https://gist.github.com/marcotrosi/163b9e890e012c6a460a
function Utilities.PrintTable(tbl)
	local function printTableHelper(obj, cnt, visited)
		cnt = cnt or 0
		visited = visited or {}

		if type(obj) == "table" then
			if visited[obj] then
				io.write("* recurse *")
				return
			end

			visited[obj] = true
			io.write("\n", string.rep("\t", cnt), "{\n")
			cnt = cnt + 1

			for k, v in pairs(obj) do
				if type(k) == "string" then
					io.write(string.rep("\t", cnt), '["' .. k .. '"]', " = ")
				elseif type(k) == "number" then
					io.write(string.rep("\t", cnt), "[" .. k .. "]", " = ")
				else
					io.write(string.rep("\t", cnt), tostring(k), " = ")
				end

				printTableHelper(v, cnt, visited)
				io.write(",\n")
			end

			cnt = cnt - 1
			io.write(string.rep("\t", cnt), "}")
		elseif type(obj) == "string" then
			io.write(string.format("%q", obj))
		else
			io.write(tostring(obj))
		end
	end

	printTableHelper(tbl, 0, {})
end

return Utilities
