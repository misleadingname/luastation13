local ecs = LS13.ECSManager

local worldComponent = ecs.component("World", function(c)
	c.worldId = "default"
	c.tilemap = Tilemap.new()

	c.zMin = 0
	c.zMax = 0
end)

LS13.ECS.Components.World = worldComponent
