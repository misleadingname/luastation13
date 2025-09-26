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
	client.StateManager = stateManager
	client.States = states

	client.UI = require("client/ui")
	LS13.Util.PrintTable(LS13.UI)

	love.window.setTitle(string.format("%s: %s", title, splash))
	stateManager:setState(states.Loading)

	if DEBUG then states.Debug:enter() end
end

function client.update(dt)
	stateManager:update(dt)
	client.UI.update(dt)

	if DEBUG then states.Debug:update(dt) end
end

function love.draw()
	stateManager:draw()

	love.graphics.setColor(1, 1, 1, 1)
	LS13.UI.render()

	if DEBUG then states.Debug:draw() end
end

function love.mousemoved(x, y)
	LS13.UI.handleMouse(x, y)
end

function love.mousepressed(x, y, button)
	LS13.UI.handleMousePressed(x, y, button)
end

function love.mousereleased(x, y, button)
	LS13.UI.handleMouseReleased(x, y, button)
end

function love.keypressed(key, scancode, isrepeat)
	LS13.UI.handleKeyPressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
	LS13.UI.handleKeyReleased(key, scancode)
end

function love.textedited(text)
	LS13.UI.handleTextInput(text)
end

return client
