local server = {}

local minDt = 1 / 30
local nextTime = love.timer.getTime()

function server.load()
	print("just shut the fuck up shared")

	LS13.Networking = require("server.networking")

	LS13.PrototypeManager.ParseAll()

	LS13.Networking.start(6969, 2)

	minDt = 1 / 60
	nextTime = love.timer.getTime()
end

function server.preframe()
	nextTime = nextTime + minDt
end

function server.update(dt)
	-- LS13.Logging.LogDebug("%s", 1 / dt)
	LS13.Networking.process()
end

function server.postframe()
	local curTime = love.timer.getTime()
	if nextTime <= curTime then
		nextTime = curTime
		return
	end
	love.timer.sleep(nextTime - curTime)
end

function love.quit()
	LS13.Networking.shutdown()
end

return server
