local states = {
<<<<<<< HEAD
	Loading = require("client.states.loading"),
	Debug = require("client.states.debug"),
	Menu = require("client.states.menu"),
=======
    Loading = require("client/states/loading"),
    Debug = require("client/states/debug"),
    Menu = require("client/states/menu"),
>>>>>>> 403c37942b59204a3891300e7493602f2e5648a4
}

local client = {}

function client.load(args)
<<<<<<< HEAD
	
	LS13.States = states
	LS13.UI = require("client.ui")
	LS13.StateManager = require("lib.gamestatemanager.gameStateManager")
=======
    LS13.States = states
    LS13.UI = require("client/ui")
    LS13.StateManager = require("lib/gamestatemanager/gameStateManager")
>>>>>>> 403c37942b59204a3891300e7493602f2e5648a4

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
