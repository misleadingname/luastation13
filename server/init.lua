local server = {}

local minDt
local nextTime

function server.load()
	LS13.Networking = require("server.networking")
	LS13.PrototypeManager.ParseAll()

	require("server.states")
	LS13.WorldManager = require("server.world")
	LS13.RoundManager = require("server.round")

	LS13.StateManager.switchState("Preround")
	if not LS13.Networking.start(NETWORK_DEFAULT_PORT, 16) then
		LS13.Logging.LogFatal("Failed to create host, bail!")
		love.event.quit()
		return
	end

	LS13.RoundManager.start()

	minDt = 1 / 60
	nextTime = love.timer.getTime()
end

function server.preframe()
	nextTime += minDt
end

function server.update(dt)
	-- LS13.Logging.LogDebug("%s", 1 / dt)
	LS13.Networking.update()
	LS13.StateManager.update(dt)
	LS13.WorldManager.update(dt)
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
