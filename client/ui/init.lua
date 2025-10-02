local systems = LS13.ECS.Systems

local ui = {}
local world

function ui.init()
	world = LS13.ECSManager.world()

	world:addSystems(
		systems.GraphicsRenderSystem,
		systems.UiLayoutSystem
	)
end

function ui.update(dt)
	world:emit("update")
end

function ui.draw()
	world:emit("draw")
end

function ui.mousePressed(x, y, button)
end

function ui.mouseReleased(x, y, button)
end

function ui.Test()
	local ent1 = LS13.ECSManager.entity("parent")
	local ent2 = LS13.ECSManager.entity("child")

	ent2:give("UiElement", ent1)
	ent2:give("UiTransform")

	ent1:give("UiElement")
	ent1:give("UiTransform")
	ent1:give("UiLayout")

	LS13.Logging.LogInfo(ent1:getComponent("Metadata").name)
	LS13.Logging.LogInfo(ent2:getComponent("Metadata").name)

	world:addEntity(ent2)
	world:addEntity(ent1)
end

return ui
