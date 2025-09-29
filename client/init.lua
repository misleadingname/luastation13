local stateManager = require("lib/gamestatemanager/gameStateManager")

local states = {
	Loading = require("client/states/loading"),
	Debug = require("client/states/debug"),
	Menu = require("client/states/menu"),
}

local client = {}

function client.load(args)
	local splashes = require("client/silly/splashes")

	local splash = splashes[math.random(1, #splashes)]
	local title = love.window.getTitle()

	client.Role = "client"
	client.States = states
	client.StateManager = stateManager

	client.UI = require("client/ui")

	love.window.setTitle(string.format("%s: %s", title, splash))
	stateManager:setState(states.Loading)

	if DEBUG then states.Debug:enter() end
end

function client.update(dt)
	stateManager:update(dt)
	-- client.UI.Update(dt)

	if DEBUG then states.Debug:update(dt) end
end

function love.draw()
	stateManager:draw()

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
