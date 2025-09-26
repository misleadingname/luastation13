local ui = {}
ui.Inky = require("lib/Inky")

ui.defineElement = ui.Inky.defineElement

-- Load UI components
ui.Manager = require("client/ui/manager")
ui.Scene = require("client/ui/controls/scene")
ui.Panel = require("client/ui/controls/panel")
ui.Container = require("client/ui/controls/container")
ui.Button = require("client/ui/controls/button")
ui.Label = require("client/ui/controls/label")

-- Load UI scenes
ui.scenes = {
	Menu = require("client/ui/scenes/menu")
}

-- Create global UI manager instance
ui.manager = ui.Manager:new()

-- Initialize with menu scene
ui.manager:addScene("menu", ui.scenes.Menu())
ui.manager:setCurrentScene("menu")

-- Convenience functions
function ui.getCurrentScene()
	return ui.manager:getCurrentScene()
end

function ui.setCurrentScene(name)
	return ui.manager:setCurrentScene(name)
end

function ui.render(x, y, w, h)
	ui.manager:render(x, y, w, h)
end

function ui.update(dt)
	ui.manager:update(dt)
end

function ui.handleMouse(x, y)
	ui.manager:updateMouse(x, y)
end

function ui.handleMousePressed(x, y, button)
	ui.manager:handleMousePressed(x, y, button)
end

function ui.handleMouseReleased(x, y, button)
	ui.manager:handleMouseReleased(x, y, button)
end

function ui.handleKeyPressed(key, scancode, isrepeat)
	ui.manager:handleKeyPressed(key, scancode, isrepeat)
end

function ui.handleKeyReleased(key, scancode)
	ui.manager:handleKeyReleased(key, scancode)
end

function ui.handleTextInput(text)
	ui.manager:handleTextInput(text)
end

return ui
