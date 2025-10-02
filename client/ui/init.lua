local systems = LS13.ECS.Systems

local ui = {}
local ui_world

function ui.init()
	ui_world = LS13.ECSManager.world()

	ui_world:addSystems(
		systems.GraphicsRenderSystem,
		systems.UiLayoutSystem
	)
end

function ui.update(dt)
	ui_world:emit("update")
end

function ui.draw()
	ui_world:emit("draw")
end

function ui.mousePressed(x, y, button)
end

function ui.mouseReleased(x, y, button)
end

function ui.Test()
	local ent2 = LS13.ECSManager.entity()
	ent2:give("UiElement", ent1)
	ent2:give("UiTransform")
	ui_world:addEntity(ent2)
	local ent1 = LS13.ECSManager.entity()
	ent1:give("UiElement")
	ent1:give("UiTransform")
	ent1:give("UiLayout")
	ui_world:addEntity(ent1)
end

return ui
