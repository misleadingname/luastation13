local systems = LS13.ECS.Systems

local ui = {}
local world

function ui.init()
	world = LS13.ECSManager.world()

	world:addSystems(
		systems.GraphicsRenderSystem
	)
end

function ui.update(dt)
end

function ui.draw()
	world:emit("draw")
end

function ui.mousePressed(x, y, button)
end

function ui.mouseReleased(x, y, button)
end

function ui.Test()
	local testObj = LS13.ECSManager.entity()
	testObj:give("Transform", Vector2.new(32, 32))
	testObj:give("Graphic", "Graphic.Gilb")
	world:addEntity(testObj)
end

return ui
