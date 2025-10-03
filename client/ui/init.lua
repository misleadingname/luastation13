local systems = LS13.ECS.Systems

local ui = {}

function ui.init()
	ui.world = LS13.ECSManager.world()

	ui.world:addSystems(
	-- update systems
		systems.UiLayoutSystem,

		-- render systems
		systems.UiLabelSystem
	)
end

function ui.update(dt)
	ui.world:emit("update")
end

function ui.draw()
	ui.world:emit("draw")
end

function ui.mousePressed(x, y, button)
end

function ui.mouseReleased(x, y, button)
end

function ui.test_scene()
	local ent1 = LS13.ECSManager.entity("parent")
	local ent2 = LS13.ECSManager.entity("child")

	ent1:give("UiElement")
	ent1:give("UiTransform", Vector2.new(20, 20))
	ent1:give("UiLabel", "hi im parent!")

	ent2:give("UiElement", ent1)
	ent2:give("UiTransform", Vector2.new(20, 20))
	ent2:give("UiLabel", "hi im child!")

	ui.world:addEntity(ent1)
	ui.world:addEntity(ent2)
end

return ui
