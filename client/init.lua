local states = {
	Loading = require("client.states.loading"),
	Menu = require("client.states.menu"),
}

local function handleError(error)
	LS13.Logging.LogFatal("Unhandled error: %s %s", error, debug.traceback())
end

local client = {}

function client.load(args)
	love.window.setTitle(LS13.Info.Name)

	LS13.States = states
	LS13.UI = require("client.ui")
	LS13.Console = require("client.console")
	LS13.StateManager = require("lib.GameStateManager.gamestateManager")

	LS13.UI.init()

	if DEBUG then LS13.DebugOverlay = require("client.debugOverlay") end
	LS13.StateManager:setState(states.Loading)
end

function client.update(dt)
	xpcall(function()
		LS13.StateManager:update(dt)
		LS13.Console.update(dt)
		LS13.UI.update(dt)

		if DEBUG and LS13.DebugOverlay then LS13.DebugOverlay.update(dt) end
	end, handleError)
end

function love.draw()
	xpcall(function()
		LS13.StateManager:draw()

		LS13.UI.draw()
		LS13.Console.draw()

		if DEBUG and LS13.DebugOverlay then LS13.DebugOverlay.draw() end
	end, handleError)
end

function love.mousepressed(x, y, button)
	LS13.Logging.LogDebug("Mouse button %s pressed at X: %s Y: %s", button, x, y)
	xpcall(function()
		LS13.UI.mousePressed(x, y, button)
	end, handleError)
end

function love.mousereleased(x, y, button)
	xpcall(function()
		LS13.UI.mouseReleased(x, y, button)
	end, handleError)
end

return client
