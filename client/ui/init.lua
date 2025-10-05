require("client.ui.components.ui")
require("client.ui.systems.parentSystem")
require("client.ui.systems.layoutSystem")
require("client.ui.systems.targetingSystem")
require("client.ui.systems.renderingSystem")

local systems = LS13.ECS.Systems

local ui = {}

local cursor = {
	position = Vector2.new(0, 0),
	activeButtons = {}
}

function ui.init()
	ui.world = LS13.ECSManager.world()
	ui.cursor = cursor

	ui.world:addSystems( -- (this comment is only here to make stylua behave)
		systems.UiParentSystem,
		systems.UiLayoutSystem,
		systems.UiTargettingSystem,
		systems.UiRenderingSystem
	)
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

function ui.test_scene()
	local container = LS13.ECSManager.entity("parent")
	container:give("UiElement")
	container:give("UiTransform", Vector2.new(32, 32), Vector2.new(200, 450))
	container:give("UiLayout", "vertical", Vector2.new(8, 8), 4, "begin", "center")
	container:give("UiPanel")

	local label1 = LS13.ECSManager.entity("child")
	label1:give("UiElement", container)
	label1:give("UiTransform", Vector2.new(0, 0), Vector2.new(100, 32))
	label1:give("UiLabel", "Hello, World!")

	local label2 = LS13.ECSManager.entity("child")
	label2:give("UiElement", container)
	label2:give("UiTransform", Vector2.new(32, 0), Vector2.new(100, 23))
	label2:give("UiLabel", "Hello, World!")

	ui.world:addEntity(container)
	ui.world:addEntity(label1)
	ui.world:addEntity(label2)
end

return ui
