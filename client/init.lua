local states = {
	Loading = require("client.states.loading"),
	Debug = require("client.states.debug"),
	Menu = require("client.states.menu"),
}

local function handleError(error)
	LS13.Logging.LogFatal("Unhandled error: %s %s", error, debug.traceback())
end

local client = {}

function client.load(args)
	LS13.States = states
	LS13.UI = require("client.ui")
	LS13.Console = require("client.console")
	LS13.StateManager = require("lib.GameStateManager.gamestateManager")

	LS13.StateManager:setState(states.Loading)

	if DEBUG then states.Debug:enter() end
end

function client.update(dt)
	LS13.StateManager:update(dt)
	-- client.UI.Update(dt)

	if DEBUG then states.Debug:update(dt) end

	LS13.Console.update(dt)
end

function love.draw()
	xpcall(function()
		LS13.StateManager:draw()
	end, handleError)

	if DEBUG then states.Debug:draw() end

	LS13.Console.draw()
end

function love.mousepressed(x, y, button)
	xpcall(function()
		LS13.UI.MousePressed(x, y, button)
	end, handleError)
end

function love.mousereleased(x, y, button)
	xpcall(function()
		LS13.UI.MouseReleased(x, y, button)
	end, handleError)
end

return client
