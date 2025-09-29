local states = {
	Loading = require("client/states/loading"),
	Debug = require("client/states/debug"),
	Menu = require("client/states/menu"),
}

local client = {}

function client.load(args)
	
	LS13.States = states
	LS13.UI = require("client/ui")
	LS13.StateManager = require("lib/gamestatemanager/gameStateManager")

	LS13.StateManager:setState(states.Loading)

	if DEBUG then states.Debug:enter() end
end

function client.update(dt)
	LS13.StateManager:update(dt)
	-- client.UI.Update(dt)

	if DEBUG then states.Debug:update(dt) end
end

function love.draw()
	LS13.StateManager:draw()

	love.graphics.setColor(1, 1, 1, 1)
	-- LS13.UI.Draw()

	if DEBUG then states.Debug:draw() end
end

function love.mousepressed(x, y, button)
	LS13.UI.MousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	LS13.UI.MouseReleased(x, y, button)
end

return client
