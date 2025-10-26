require("client.ui.components.ui")
require("client.ui.systems.parentSystem")
require("client.ui.systems.layoutSystem")
require("client.ui.systems.targetingSystem")
require("client.ui.systems.textFieldSystem")
require("client.ui.systems.renderingSystem")

local systems = LS13.ECS.Systems
local manager = require("client.ui.manager")

local ui = {}
ui.manager = manager
ui.currentScene = nil

local cursor = {
	position = Vector2.new(0, 0),
	activeButtons = {},
}

function ui.init()
	ui.world = LS13.ECSManager.world()
	ui.cursor = cursor
	ui.nlay = require("lib.nlay")

	ui.world:addSystems( -- (this comment is only here to make stylua behave)
		systems.UiParentSystem,
		systems.UiLayoutSystem,
		systems.UiTargettingSystem,
		systems.UiTextFieldSystem,
		systems.UiRenderingSystem
	)

	manager.init()
end

function ui.update(dt)
	cursor.position.x, cursor.position.y = love.mouse.getPosition()
	ui.world:emit("update", dt)
end

function ui.draw()
	ui.world:emit("draw")
end

function ui.mousePressed(x, y, button)
	cursor.position.x, cursor.position.y = x, y
	cursor.activeButtons[button] = true
	ui.world:emit("press", button)
end

function ui.mouseReleased(x, y, button)
	cursor.position.x, cursor.position.y = x, y
	cursor.activeButtons[button] = false
	ui.world:emit("release", button)
end

function ui.keyPressed(key, scancode, isrepeat)
	ui.world:emit("keyPressed", key, scancode, isrepeat)
end

function ui.keyReleased(key, scancode)
	ui.world:emit("keyReleased", key, scancode)
end

function ui.textInput(text)
	ui.world:emit("textInput", text)
end

function ui.clear()
	if ui.currentScene then
		ui.currentScene:destroy(ui.world)
		ui.currentScene = nil
	end
	ui.world:clear()
end

function ui.createScene(sceneId)
	if ui.currentScene then
		ui.currentScene:destroy(ui.world)
	end

	ui.currentScene = manager.createScene(sceneId, ui.world)
	if not ui.currentScene then
		LS13.Logging.LogError("Failed to create scene: %s", sceneId)
		return false
	end

	ui.world:emit("rebuild")
	LS13.Logging.LogInfo("Created scene: %s", sceneId)
	return ui.currentScene
end

function ui.updateDimensions(width, height)
	local nlay = require("lib.nlay")
	nlay.update(0, 0, width, height)

	-- Rebuild constraints when dimensions change
	ui.world:emit("rebuild")
end

function ui.getCurrentScene()
	return ui.currentScene
end

function ui.test_scene()
	local root = LS13.ECSManager.entity("root")
	root:give("UiElement")
	root:give(
		"UiTransform",
		Vector2.new(0.5, 0.5),
		Vector2.new(0.75, 0.75),
		0,
		"ratio",
		"ratio",
		"ratio",
		"ratio",
		Vector2.new(0.5, 0.5)
	)
	root:give("UiLayout", "vertical", Vector2.new(12, 12), 8, "begin", "top")
	root:give("UiPanel", "Graphic.UiPanel")

	local header = LS13.ECSManager.entity("header")
	header:give("UiElement", root)
	header:give("UiTransform", Vector2.new(0, 0), Vector2.new(1, 32), 0, "ratio", "ratio", "ratio", "pixel")
	header:give("UiLabel", "testing bullshit", Color.white, "Font.DefaultLarge", "center", "center")

	local buttonContainer = LS13.ECSManager.entity("buttonContainer")
	buttonContainer:give("UiElement", root)
	buttonContainer:give("UiTransform", Vector2.new(0, 0), Vector2.new(1, 200), 0, "ratio", "ratio", "ratio", "pixel")
	buttonContainer:give("UiLayout", "vertical", Vector2.new(4, 4), 6, "center", "stretch")

	local btn1 = LS13.ECSManager.entity("playBtn")
	btn1:give("UiElement", buttonContainer)
	btn1:give("UiTransform", Vector2.new(0, 0), Vector2.new(1, 32), 0, "ratio", "ratio", "ratio", "pixel")
	btn1:give("UiPanel", "Graphic.UiButton")
	btn1:give("UiTarget")
	btn1:give("UiLabel", "OPTION 1", Color.white, "Font.Default", "center", "center")
	btn1.UiTarget.onClick = function()
		LS13.Logging.LogDebug("1")
	end

	local btn2 = LS13.ECSManager.entity("optionsBtn")
	btn2:give("UiElement", buttonContainer)
	btn2:give("UiTransform", Vector2.new(0, 0), Vector2.new(1, 32), 0, "ratio", "ratio", "ratio", "pixel")
	btn2:give("UiPanel", "Graphic.UiButton")
	btn2:give("UiTarget")
	btn2:give("UiLabel", "OPTION 2", Color.white, "Font.Default", "center", "center")
	btn2.UiTarget.onClick = function()
		LS13.Logging.LogDebug("2")
	end

	local btn3 = LS13.ECSManager.entity("optionsBtn")
	btn3:give("UiElement", buttonContainer)
	btn3:give("UiTransform", Vector2.new(0, 0), Vector2.new(1, 32), 0, "ratio", "ratio", "ratio", "pixel")
	btn3:give("UiPanel", "Graphic.UiButton")
	btn3:give("UiTarget")
	btn3:give("UiLabel", "play sad sound", Color.white, "Font.Default", "center", "center")
	btn3.UiTarget.onClick = function()
		love.audio.play(LS13.SoundManager.NewSource("Sound.Fallback"))
	end

	ui.world:addEntity(root)
	ui.world:addEntity(header)
	ui.world:addEntity(buttonContainer)
	ui.world:addEntity(btn1)
	ui.world:addEntity(btn2)
	ui.world:addEntity(btn3)
end

return ui
