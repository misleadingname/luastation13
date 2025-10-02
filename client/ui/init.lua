local systems = LS13.ECS.Systems

local ui = {}
local ui_world

function ui.init()
	ui_world = LS13.ECSManager.world()

	ui_world:addSystems(
		systems.GraphicsRenderSystem
	)
end

function ui.update(dt)
end

function ui.draw()
	ui_world:emit("draw")
end

function ui.mousePressed(x, y, button)
end

function ui.mouseReleased(x, y, button)
end

function ui.Test()
	local testObj = LS13.ECSManager.entity()
	testObj:give("Transform", Vector2.new(32, 32))
	testObj:give("Graphic", "Graphic.Gilb")
	ui_world:addEntity(testObj)
end

return ui
