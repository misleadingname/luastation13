local systems = LS13.ECS.Systems

local ui = {}
local cursor = {
	position = Vector2.new(0, 0),
}

function ui.init()
	ui.world = LS13.ECSManager.world()
	ui.cursor = cursor

	ui.world:addSystems(
		-- update systems
		systems.UiLayoutSystem,
		systems.UiTargettingSystem,

		-- render systems
		systems.UiPanelSystem,
		systems.UiLabelSystem
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
	ui.world:emit("press", button)
end

function ui.mouseReleased(x, y, button)
	cursor.position.x, cursor.position.y = x, y
	ui.world:emit("release", button)
end

function ui.test_scene()
	local ent1 = LS13.ECSManager.entity("parent")
	local ent2 = LS13.ECSManager.entity("child")

	local text = function()
		return love.timer.getDelta()
	end

	ent1:give("UiElement")
	ent1:give("UiTarget")
	ent1:give("UiTransform", Vector2.new(32, 32), Vector2.new(96, 24))
	ent1:give("UiLabel", text, Color.white, "Font.Default", "center", "center")
	ent1:give("UiPanel")

	ent1.UiTarget.onClick = function(btn)
		LS13.Logging.LogDebug("Clicked! M%s", btn)
	end

	-- ent2:give("UiElement", ent1)
	-- ent2:give("UiTransform", Vector2.new(20, 20))
	-- ent2:give("UiLabel", "hi im child!")

	ui.world:addEntity(ent1)
	-- ui.world:addEntity(ent2)
end

return ui
