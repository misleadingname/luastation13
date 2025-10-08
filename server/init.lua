local server = {}

local minDt = 1 / 30
local nextTime = love.timer.getTime()

function server.load()
	print("just shut the fuck up shared")

	LS13.Networking = require("server.networking")
	LS13.Networking.Protocol = require("shared.networking.protocol")
	LS13.PrototypeManager.ParseAll()

	-- TODO: SWAP WITH MULTIWORLD
	LS13.World = LS13.ECSManager.world()
	LS13.World:addSystems(LS13.ECS.Systems.NetworkingSystem)

	local worldEntity = LS13.ECSManager.entity("World")
	worldEntity:give("World")
	LS13.World:addEntity(worldEntity)
	-- END TODO
	require("server.states")
	LS13.RoundManager = require("server.roundmanager")

	LS13.Logging.LogInfo("Created world entity with tilemap")
	LS13.Networking.start(NETWORK_DEFAULT_PORT, 2)
	LS13.StateManager.switchState("Preround")

	minDt = 1 / 60
	nextTime = love.timer.getTime()
end

function server.preframe()
	nextTime = nextTime + minDt
end

function server.update(dt)
	-- LS13.Logging.LogDebug("%s", 1 / dt)
	LS13.Networking.update()
	LS13.StateManager.update(dt)

	if LS13.World then
		LS13.World:emit("update", dt)
	end
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
