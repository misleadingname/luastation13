require("love.filesystem")
require("love.timer")

local channel = love.thread.getChannel("PrototypeWatchdog")
local fileTimes = {}
local files = {}

local function recurse(path)
	local dir = love.filesystem.getDirectoryItems(path)
	for _, file in ipairs(dir) do
		local fullPath = path .. "/" .. file
		local info = love.filesystem.getInfo(fullPath)
		if info and info.type == "directory" then
			recurse(fullPath)
		elseif info and info.type == "file" then
			if fileTimes[fullPath] and fileTimes[fullPath] ~= info.modtime then
				table.insert(files, fullPath)
			end

			fileTimes[fullPath] = info.modtime
		end
	end
end

while true do
	recurse("resources/prototypes")
	for _, file in ipairs(files) do
		channel:push(file)
	end

	files = {}
	love.timer.sleep(1)
end
