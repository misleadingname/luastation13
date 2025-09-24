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

	client.UI = require("lib/inky")

	love.window.setTitle(string.format("%s: %s", title, splash))
	stateManager:setState(states.Loading)

	if DEBUG then states.Debug:enter() end
end

function client.update(dt)
	stateManager:update(dt)
	if DEBUG then states.Debug:update(dt) end
end

function love.draw()
	stateManager:draw()
	if DEBUG then states.Debug:draw() end
end

return client
