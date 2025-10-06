local server = {}

local minDt = 1 / 30
local nextTime = love.timer.getTime()

function server.load()
	print("just shut the fuck up shared")

	LS13.Networking = require("server.networking")

	LS13.PrototypeManager.ParseAll()

	minDt = 1 / 60
	nextTime = love.timer.getTime()
end

function server.preframe()
	nextTime = nextTime + minDt
end

function server.update(dt)
	LS13.Logging.LogDebug("FPS: %s", 1 / dt)
end

function server.postframe()
	local curTime = love.timer.getTime()
	if nextTime <= curTime then
		nextTime = curTime
		return
	end
	love.timer.sleep(nextTime - curTime)
end

return server
