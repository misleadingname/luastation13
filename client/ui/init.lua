local systems = LS13.ECS.Systems

local ui = {}
local cursor = {
	position = Vector2.new(0, 0),
}

function ui.init()
	ui.world = LS13.ECSManager.world()
	ui.cursor = cursor

	ui.world:addSystems( -- (this comment is only here to make stylua behave)
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
	ui.world:emit("press", button)
end

function ui.mouseReleased(x, y, button)
	cursor.position.x, cursor.position.y = x, y
	ui.world:emit("release", button)
end

function ui.test_scene()
	local ent1 = LS13.ECSManager.entity("parent")
	local ent2 = LS13.ECSManager.entity("child")

	ent1:give("UiElement", nil, { ent2 })
	ent1:give("UiTarget")
	ent1:give("UiTransform", Vector2.new(32, 32), Vector2.new(256, 128))
	ent1:give("UiPanel")
	ent1:give(
		"UiLabel",
		"AAAAAAAAAAAAAA\nAAAAAAAAAAAAAAAA\nAAAAAAAAAAAAAA",
		Color.white,
		"Font.Default",
		"center",
		"center"
	)

	ent1.UiTarget.onClick = function(button)
		LS13.Logging.LogDebug("A pressed")
	end

	ent2:give("UiElement", ent1)
	ent2:give("UiTarget")
	ent2:give("UiTransform", Vector2.new(16, 64), Vector2.new(256, 128))
	ent2:give("UiPanel")
	ent2:give(
		"UiLabel",
		"BBBBBBBBBBBBBB\nBBBBBBBBBBBBBBBB\nBBBBBBBBBBBBBB",
		Color.white,
		"Font.Default",
		"center",
		"center"
	)

	ent2.UiTarget.onClick = function(button)
		LS13.Logging.LogDebug("B pressed")
	end

	ui.world:addEntity(ent1)
	ui.world:addEntity(ent2)
end

return ui
