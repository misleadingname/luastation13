local stateManager = require("lib/gamestatemanager/gameStateManager")

local states = {
	loading = require("client/states/loading"),
}

local client = {}
client.Role = "client"

client.StateManager = stateManager
client.States = states

function client.load()
	local splashes = require("client/silly/splashes")

	local splash = splashes[math.random(1, #splashes)]
	local title = love.window.getTitle()

	love.window.setTitle(string.format("%s: %s", title, splash))
	stateManager:setState(states.loading)
end

function client.update(dt)
	stateManager:update(dt)
end

function love.draw()
	stateManager:draw()
end

return client